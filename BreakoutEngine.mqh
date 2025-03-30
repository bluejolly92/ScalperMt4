//+------------------------------------------------------------------+
//| BreakoutEngine.mqh - Logica per segnali breakout                |
//+------------------------------------------------------------------+
#ifndef __BREAKOUT_ENGINE_MQH__
#define __BREAKOUT_ENGINE_MQH__

#include <ScalperMt4/Inputs.mqh>

bool CheckBreakoutSignal(double &sl, double &tp)
{
   double atr = iATR(Symbol(), PERIOD_M15, ATR_Period, 0);
   if (atr < MinATR)
   {
      if (EnableVerboseLog)
         Print("❌ ATR troppo basso: ", atr);
      return false;
   }

   double high = iHigh(Symbol(), PERIOD_M15, 1);
   double low  = iLow(Symbol(), PERIOD_M15, 1);
   double close = iClose(Symbol(), PERIOD_M15, 1);

   if (close > high) // Breakout rialzista
   {
      sl = NormalizeDouble(Bid - atr * SL_ATR_Mult, Digits);
      tp = NormalizeDouble(Bid + atr * TP_ATR_Mult, Digits);
      if (EnableVerboseLog) Print("📈 Breakout LONG rilevato");
      return true;
   }
   else if (close < low) // Breakout ribassista
   {
      sl = NormalizeDouble(Ask + atr * SL_ATR_Mult, Digits);
      tp = NormalizeDouble(Ask - atr * TP_ATR_Mult, Digits);
      if (EnableVerboseLog) Print("📉 Breakout SHORT rilevato");
      return true;
   }

   return false;
}

#endif
