//+------------------------------------------------------------------+
//| TradeManager.mqh - Gestione ordini aperti                       |
//+------------------------------------------------------------------+
#ifndef __TRADE_MANAGER_MQH__
#define __TRADE_MANAGER_MQH__

#include <ScalperMt4/Inputs.mqh>
#include <ScalperMt4/Logger.mqh>

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
      double atr = iATR(NULL, PERIOD_M15, ATR_Period, 0);
      double trailingDistance = atr * SL_ATR_Mult;
      double newSL = 0.0;

      // --- BREAK-EVEN LOGIC ---
      if (EnableBreakEven)
      {
         if (OrderType() == OP_BUY)
         {
            if (Bid - openPrice > atr)
            {
               newSL = NormalizeDouble(openPrice, Digits);
               if (sl < newSL)
               {
                  OrderModify(OrderTicket(), OrderOpenPrice(), newSL, tp, 0, clrGreen);
                  LogInfo("🔁 Break-even BUY applicato - SL spostato a " + DoubleToString(newSL, Digits));
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
                  OrderModify(OrderTicket(), OrderOpenPrice(), newSL, tp, 0, clrRed);
                  LogInfo("🔁 Break-even SELL applicato - SL spostato a " + DoubleToString(newSL, Digits));
               }
            }
         }
      }

      // --- TRAILING STOP LOGIC ---
      if (EnableTrailing)
      {   
         if (OrderType() == OP_BUY)
         {
            newSL = NormalizeDouble(Bid - trailingDistance, Digits);
            if (newSL > sl && (Bid - newSL) > MarketInfo(Symbol(), MODE_STOPLEVEL) * Point)
            {
               OrderModify(OrderTicket(), OrderOpenPrice(), newSL, tp, 0, clrYellow);
               LogDebug("📈 Trailing SL BUY aggiornato a " + DoubleToString(newSL, Digits));
            }
         }
         else if (OrderType() == OP_SELL)
         {
            newSL = NormalizeDouble(Ask + trailingDistance, Digits);
            if (newSL < sl && (newSL - Ask) > MarketInfo(Symbol(), MODE_STOPLEVEL) * Point)
            {
               OrderModify(OrderTicket(), OrderOpenPrice(), newSL, tp, 0, clrOrange);
               LogDebug("📉 Trailing SL SELL aggiornato a " + DoubleToString(newSL, Digits));
            }
         }
      }
   }
}

#endif
