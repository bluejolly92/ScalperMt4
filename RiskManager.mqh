//+------------------------------------------------------------------+
//| RiskManager.mqh - Calcolo dinamico SL e TP basati su ATR        |
//+------------------------------------------------------------------+
#ifndef __RISK_MANAGER_MQH__
#define __RISK_MANAGER_MQH__

#include <ScalperMt4/Inputs.mqh>
#include <ScalperMt4/Logger.mqh>

// Funzione che ritorna true se ATR > MinATR e imposta SL/TP dinamici
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

   LogDebug("📐 SL/TP dinamici calcolati → SL: " + DoubleToString(sl, Digits) + " | TP: " + DoubleToString(tp, Digits));
   return true;
}

#endif
