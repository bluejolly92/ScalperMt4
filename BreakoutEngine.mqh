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

   double high_prev = iHigh(Symbol(), tf, 1);
   double low_prev  = iLow(Symbol(), tf, 1);
   double high_curr = iHigh(Symbol(), tf, 0);
   double low_curr  = iLow(Symbol(), tf, 0);

   // Breakout LONG
   if (high_curr > high_prev)
   {
      if (!CalculateDynamicSLTP(true, sl, tp))
      {
         LogDebug("❌ SL/TP non calcolabili per breakout LONG");
         return false;
      }

      LogInfo("📈 Breakout LONG rilevato - SL: " + DoubleToString(sl, Digits) + " | TP: " + DoubleToString(tp, Digits));
      return true;
   }

   // Breakout SHORT
   if (low_curr < low_prev)
   {
      if (!CalculateDynamicSLTP(false, sl, tp))
      {
         LogDebug("❌ SL/TP non calcolabili per breakout SHORT");
         return false;
      }

      LogInfo("📉 Breakout SHORT rilevato - SL: " + DoubleToString(sl, Digits) + " | TP: " + DoubleToString(tp, Digits));
      return true;
   }

   LogDebug("Nessun breakout rilevato. HighCurr: " + DoubleToString(high_curr, Digits) +
            " | LowCurr: " + DoubleToString(low_curr, Digits) +
            " | HighPrev: " + DoubleToString(high_prev, Digits) +
            " | LowPrev: " + DoubleToString(low_prev, Digits));
   return false;
}


#endif
