//+------------------------------------------------------------------+
//| RiskManager.mqh - Calcolo SL/TP e Lotto Dinamico                |
//+------------------------------------------------------------------+
#ifndef __RISK_MANAGER_MQH__
#define __RISK_MANAGER_MQH__

#include <ScalperMt4/Inputs.mqh>
#include <ScalperMt4/Logger.mqh>

// === Calcolo SL/TP dinamici ===
bool CalculateDynamicSLTP(bool isBuy, double &sl, double &tp)
{
   double atr = iATR(NULL, PERIOD_M15, ATR_Period, 0);

   if (atr < MinATR)
   {
      LogDebug("❌ ATR troppo basso per calcolo SL/TP: " + DoubleToString(atr, 5));
      return false;
   }

   double price = isBuy ? Bid : Ask;
   double slOffset = atr * SL_ATR_Mult;
   double tpOffset = atr * TP_ATR_Mult;

   if (isBuy)
   {
      sl = NormalizeDouble(price - slOffset, Digits);
      tp = NormalizeDouble(price + tpOffset, Digits);
   }
   else
   {
      sl = NormalizeDouble(price + slOffset, Digits);
      tp = NormalizeDouble(price - tpOffset, Digits);
   }

   LogDebug("📐 SL/TP dinamici → SL: " + DoubleToString(sl, Digits) + " | TP: " + DoubleToString(tp, Digits));
   return true;
}

// === Calcolo lotto dinamico in base a RiskPercent e SL ===
double CalculateLotSize(double slPrice, bool isBuy)
{
   double accountRisk = AccountBalance() * (RiskPercent / 100.0);
   double price = isBuy ? Bid : Ask;
   double slDistance = MathAbs(price - slPrice);

   if (slDistance <= Point)
   {
      LogError("⚠️ SL troppo vicino al prezzo. Rischio non calcolabile.");
      return 0.0;
   }

   double lot = (accountRisk / slDistance) / MarketInfo(Symbol(), MODE_TICKVALUE);
   lot = MathMax(LotSizeMin, MathMin(LotSizeMax, lot));
   lot = NormalizeDouble(lot, 2);

   LogDebug("🎯 Lotto calcolato: " + DoubleToString(lot, 2) + " | SL distance: " + DoubleToString(slDistance, Digits));
   return lot;
}

// === Verifica se si può aprire un nuovo ordine ===
bool CanOpenNewTrade()
{
   int count = 0;
   for (int i = 0; i < OrdersTotal(); i++)
   {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) &&
          OrderSymbol() == Symbol() &&
          OrderMagicNumber() == MagicNumber)
      {
         count++;
      }
   }

   if (count >= MaxOpenTrades)
   {
      LogInfo("🚫 MaxOpenTrades raggiunto: " + IntegerToString(count));
      return false;
   }

   return true;
}

#endif
