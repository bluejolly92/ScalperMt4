//+------------------------------------------------------------------+
//| BreakoutEngine.mqh - Logica per segnali breakout                |
//+------------------------------------------------------------------+
#ifndef __BREAKOUT_ENGINE_MQH__
#define __BREAKOUT_ENGINE_MQH__

#include <ScalperMt4/Inputs.mqh>
#include <ScalperMt4/Logger.mqh>

bool CheckBreakoutSignal(double &sl, double &tp)
{
   double atr = iATR(Symbol(), PERIOD_M15, ATR_Period, 0);
   if (atr < MinATR)
   {
      LogDebug("ATR troppo basso: " + DoubleToString(atr, 5));
      return false;
   }

   double high = iHigh(Symbol(), PERIOD_M15, 1);
   double low  = iLow(Symbol(), PERIOD_M15, 1);
   double close = iClose(Symbol(), PERIOD_M15, 1);

   if (close > high) // Breakout rialzista
   {
      sl = NormalizeDouble(Bid - atr * SL_ATR_Mult, Digits);
      tp = NormalizeDouble(Bid + atr * TP_ATR_Mult, Digits);
      LogInfo("📈 Breakout LONG rilevato - SL: " + DoubleToString(sl, Digits) + " | TP: " + DoubleToString(tp, Digits));
      return true;
   }
   else if (close < low) // Breakout ribassista
   {
      sl = NormalizeDouble(Ask + atr * SL_ATR_Mult, Digits);
      tp = NormalizeDouble(Ask - atr * TP_ATR_Mult, Digits);
      LogInfo("📉 Breakout SHORT rilevato - SL: " + DoubleToString(sl, Digits) + " | TP: " + DoubleToString(tp, Digits));
      return true;
   }

   LogDebug("Nessun breakout rilevato. Close: " + DoubleToString(close, Digits));
   return false;
}

#endif
