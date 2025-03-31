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
   double atr = iATR(Symbol(), PERIOD_M15, ATR_Period, 0);
   if (atr <= 0.0 || atr < MinATR)
   {
      LogDebug("❌ ATR troppo basso o nullo per SL/TP: " + DoubleToString(atr, 5));
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

   LogDebug("📐 SL/TP calcolati → SL: " + DoubleToString(sl, Digits) + " | TP: " + DoubleToString(tp, Digits));
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
      LogError("⚠️ SL troppo vicino al prezzo (" + DoubleToString(slDistance, Digits) + "). Impossibile calcolare il lotto.");
      return 0.0;
   }

   double tickValue = MarketInfo(Symbol(), MODE_TICKVALUE);
   if (tickValue <= 0.0)
   {
      LogError("❌ Errore nel recupero del valore del tick.");
      return 0.0;
   }

   double lot = (accountRisk / slDistance) / tickValue;
   lot = MathMax(LotSizeMin, MathMin(LotSizeMax, lot));
   lot = NormalizeDouble(lot, 2);

   LogDebug("🎯 Lotto dinamico: " + DoubleToString(lot, 2) +
            " | SL distanza: " + DoubleToString(slDistance, Digits) +
            " | Rischio: " + DoubleToString(accountRisk, 2));
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
      LogInfo("🚫 MaxOpenTrades raggiunto per " + Symbol() + ": " + IntegerToString(count));
      return false;
   }

   return true;
}

#endif
