//+------------------------------------------------------------------+
//| BreakoutEngine.mqh - Logica per segnali breakout                |
//+------------------------------------------------------------------+
#ifndef __BREAKOUT_ENGINE_MQH__
#define __BREAKOUT_ENGINE_MQH__

#include <ScalperMt4/Inputs.mqh>
#include <ScalperMt4/Logger.mqh>
#include <ScalperMt4/RiskManager.mqh>

bool CheckBreakoutSignal(double &sl, double &tp)
{
   int tf = Period();

   double high  = iHigh(Symbol(), tf, 1);   // Candela precedente
   double low   = iLow(Symbol(), tf, 1);
   double close = iClose(Symbol(), tf, 0);  // Candela corrente

   // Breakout LONG
   if (close > high)
   {
      if (!CalculateDynamicSLTP(true, sl, tp))
      {
         LogDebug("❌ SL/TP dinamici non calcolabili per breakout LONG");
         return false;
      }

      LogInfo("📈 Breakout LONG rilevato - SL: " + DoubleToString(sl, Digits) +
              " | TP: " + DoubleToString(tp, Digits));
      return true;
   }

   // Breakout SHORT
   if (close < low)
   {
      if (!CalculateDynamicSLTP(false, sl, tp))
      {
         LogDebug("❌ SL/TP dinamici non calcolabili per breakout SHORT");
         return false;
      }

      LogInfo("📉 Breakout SHORT rilevato - SL: " + DoubleToString(sl, Digits) +
              " | TP: " + DoubleToString(tp, Digits));
      return true;
   }

   LogDebug("Nessun breakout rilevato. Close: " + DoubleToString(close, Digits) +
            " | High: " + DoubleToString(high, Digits) +
            " | Low: " + DoubleToString(low, Digits));
   return false;
}

#endif
