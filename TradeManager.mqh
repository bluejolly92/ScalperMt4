//+------------------------------------------------------------------+
//| TradeManager.mqh - Gestione ordini aperti                       |
//+------------------------------------------------------------------+
#ifndef __TRADE_MANAGER_MQH__
#define __TRADE_MANAGER_MQH__

#include <ScalperMt4/Inputs.mqh>
#include <ScalperMt4/Riskmanager.mqh>
#include <ScalperMt4/Logger.mqh>
#include <ScalperMt4/Utils.mqh>

// === Gestione ordini aperti: Break-even e trailing ===
void ManageOpenTrades()
{
   for (int i = 0; i < OrdersTotal(); i++)
   {
      if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if (OrderSymbol() != Symbol()) continue;
      if (OrderMagicNumber() != MagicNumber) continue;

      double openPrice = OrderOpenPrice();
      double sl = OrderStopLoss();
      double tp = OrderTakeProfit();
      double atr = iATR(Symbol(), PERIOD_M15, ATR_Period, 0);

      if (atr <= 0.0) continue;

      double trailingDistance = atr * SL_ATR_Mult;
      if (trailingDistance <= Point) continue;

      double newSL = 0.0;

      // === BREAK-EVEN ===
      if (EnableBreakEven)
      {
         if (OrderType() == OP_BUY)
         {
            if (Bid - openPrice > atr)
            {
               newSL = NormalizeDouble(openPrice, Digits);
               if (sl < newSL)
               {
                  if (!OrderModify(OrderTicket(), openPrice, newSL, tp, 0, clrGreen))
                     LogError("❌ Errore break-even BUY: " + ErrorDescription(GetLastError()));
                  else
                     LogInfo("🔁 Break-even BUY → SL spostato a " + DoubleToString(newSL, Digits));
               }
            }
         }
         else if (OrderType() == OP_SELL)
         {
            if (openPrice - Ask > atr)
            {
               newSL = NormalizeDouble(openPrice, Digits);
               if (sl > newSL || sl == 0.0)
               {
                  if (!OrderModify(OrderTicket(), openPrice, newSL, tp, 0, clrRed))
                     LogError("❌ Errore break-even SELL: " + ErrorDescription(GetLastError()));
                  else
                     LogInfo("🔁 Break-even SELL → SL spostato a " + DoubleToString(newSL, Digits));
               }
            }
         }
      }

      // === TRAILING STOP ===
      if (EnableTrailing)
      {
         int stopLevel = MarketInfo(Symbol(), MODE_STOPLEVEL);
         double stopDistance = stopLevel * Point;

         if (OrderType() == OP_BUY)
         {
            newSL = NormalizeDouble(Bid - trailingDistance, Digits);
            if (newSL > sl && (Bid - newSL) > stopDistance)
            {
               if (!OrderModify(OrderTicket(), openPrice, newSL, tp, 0, clrYellow))
                  LogError("❌ Errore trailing BUY: " + ErrorDescription(GetLastError()));
               else
                  LogDebug("📈 Trailing SL BUY → aggiornato a " + DoubleToString(newSL, Digits));
            }
         }
         else if (OrderType() == OP_SELL)
         {
            newSL = NormalizeDouble(Ask + trailingDistance, Digits);
            if (newSL < sl && (newSL - Ask) > stopDistance)
            {
               if (!OrderModify(OrderTicket(), openPrice, newSL, tp, 0, clrOrange))
                  LogError("❌ Errore trailing SELL: " + ErrorDescription(GetLastError()));
               else
                  LogDebug("📉 Trailing SL SELL → aggiornato a " + DoubleToString(newSL, Digits));
            }
         }
      }
   }
}

// === Apertura nuovo ordine ===
bool OpenTrade(bool isBuy, double sl, double tp)
{
   if (!CanOpenNewTrade())
      return false;

   double lot = CalculateLotSize(sl, isBuy);
   if (lot <= 0.0)
   {
      LogError("❌ Lotto non valido. Operazione annullata.");
      return false;
   }

   double price = isBuy ? Ask : Bid;
   int slippage = Slippage;
   int ticket = -1;

   if (isBuy)
   {
      ticket = OrderSend(Symbol(), OP_BUY, lot, price, slippage, sl, tp, "Breakout BUY", MagicNumber, 0, clrBlue);
   }
   else
   {
      ticket = OrderSend(Symbol(), OP_SELL, lot, price, slippage, sl, tp, "Breakout SELL", MagicNumber, 0, clrRed);
   }

   if (ticket < 0)
   {
      LogError("❌ Errore apertura ordine: " + ErrorDescription(GetLastError()));
      return false;
   }

   LogInfo("✅ Ordine aperto correttamente. Ticket: " + IntegerToString(ticket));
   return true;
}

#endif
