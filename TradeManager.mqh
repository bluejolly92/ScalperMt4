//+------------------------------------------------------------------+
//| TradeManager.mqh - Gestione ordini aperti                       |
//+------------------------------------------------------------------+
#ifndef __TRADE_MANAGER_MQH__
#define __TRADE_MANAGER_MQH__

#include <ScalperMt4/Inputs.mqh>
#include <ScalperMt4/Riskmanager.mqh>
#include <ScalperMt4/Logger.mqh>
#include <ScalperMt4/Utils.mqh>

// === Mappa ticket → ultimo SL applicato (cache per il trailing) ===
double LastTrailingSL[1000];  // Cache fino a 1000 ticket

// === Gestione ordini aperti: Break-even e trailing ===
void ManageOpenTrades()
{
   for (int i = 0; i < OrdersTotal(); i++)
   {
      if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if (OrderSymbol() != Symbol()) continue;
      if (OrderMagicNumber() != MagicNumber) continue;

      int ticket = OrderTicket();
      int type = OrderType();
      double openPrice = OrderOpenPrice();
      double sl = OrderStopLoss();
      double tp = OrderTakeProfit();
      double atr = iATR(Symbol(), PERIOD_M15, TrailingATRPeriod, 0);
      if (atr <= 0.0 || tp <= 0.0) continue;

      double maxDistance = MathAbs(tp - openPrice);
      double currentGain = (type == OP_BUY) ? Bid - openPrice : openPrice - Ask;
      double gainPct = (currentGain / maxDistance) * 100.0;
      double trailingDistance = atr * TrailingATRMultiplier;
      double throttleDistance = atr * TrailingThrottleFactor;
      double newSL = 0.0;

      // === BREAK-EVEN ===
      if (EnableBreakEven && gainPct >= BreakEvenPct)
      {
         newSL = NormalizeDouble(openPrice, Digits);
         if ((type == OP_BUY && sl < newSL) || (type == OP_SELL && (sl > newSL || sl == 0.0)))
         {
            if (OrderModify(ticket, openPrice, newSL, tp, 0, clrAqua))
               LogInfo("🔁 Break-even → SL spostato a " + DoubleToString(newSL, Digits));
            else
               LogError("❌ Errore break-even: " + ErrorDescription(GetLastError()));
            LastTrailingSL[ticket] = newSL;
         }
      }

      // === TRAILING STOP ===
      if (EnableTrailing && gainPct >= TrailingActivationPct)
      {
         int stopLevel = MarketInfo(Symbol(), MODE_STOPLEVEL);
         double stopDistance = stopLevel * Point;
         double marketPrice = (type == OP_BUY) ? Bid : Ask;
         double desiredSL = NormalizeDouble(marketPrice - trailingDistance, Digits);
         if (type == OP_SELL)
            desiredSL = NormalizeDouble(marketPrice + trailingDistance, Digits);

         // Verifica throttling
         double lastSL = LastTrailingSL[ticket];
         if (lastSL != 0.0 && MathAbs(desiredSL - lastSL) < throttleDistance)
            continue;  // troppo vicino al precedente SL

         bool shouldModify =
            (type == OP_BUY && desiredSL > sl + Point && (marketPrice - desiredSL) > stopDistance) ||
            (type == OP_SELL && desiredSL < sl - Point && (desiredSL - marketPrice) > stopDistance);

         if (shouldModify && NormalizeDouble(sl, Digits) != NormalizeDouble(desiredSL, Digits))
         {
            if (OrderModify(ticket, openPrice, desiredSL, tp, 0, clrYellow))
            {
               LogDebug((type == OP_BUY ? "📈" : "📉") + " Trailing SL → aggiornato a " + DoubleToString(desiredSL, Digits));
               LastTrailingSL[ticket] = desiredSL;
            }
            else
            {
               LogError("❌ Errore trailing: " + ErrorDescription(GetLastError()));
            }
         }
      }
   }
}

// === Apertura nuovo ordine ===
bool OpenTrade(bool isBuy, double sl, double tp)
{
   if (!CanOpenNewTrade())
   {
      LogInfo("🚫 MaxOpenTrades raggiunto. Nessun nuovo ordine verrà aperto.");
      return false;
   }

   double lot = CalculateLotSize(sl, isBuy, RiskPercent);
   if (lot <= 0.0)
   {
      LogError("❌ Lotto non valido. Operazione annullata.");
      return false;
   }

   double price = isBuy ? Ask : Bid;
   int slippage = Slippage;

   double stopLevelPips = MarketInfo(Symbol(), MODE_STOPLEVEL) * Point;
   if ((isBuy && ((price - sl) < stopLevelPips || (tp - price) < stopLevelPips)) ||
       (!isBuy && ((sl - price) < stopLevelPips || (price - tp) < stopLevelPips)))
   {
      LogError("❌ SL o TP troppo vicini al prezzo. SL: " + DoubleToString(sl, Digits) + 
               ", TP: " + DoubleToString(tp, Digits) + ", Prezzo: " + DoubleToString(price, Digits));
      return false;
   }

   int ticket = -1;

   if (isBuy)
      ticket = OrderSend(Symbol(), OP_BUY, lot, price, slippage, sl, tp, "Breakout BUY", MagicNumber, 0, clrBlue);
   else
      ticket = OrderSend(Symbol(), OP_SELL, lot, price, slippage, sl, tp, "Breakout SELL", MagicNumber, 0, clrRed);

   if (ticket < 0)
   {
      int err = GetLastError();
      LogError("❌ Errore apertura ordine (codice " + IntegerToString(err) + "): " + ErrorDescription(err));
      return false;
   }

   LogInfo("✅ Ordine aperto correttamente. Ticket: " + IntegerToString(ticket));
   return true;
}

#endif
