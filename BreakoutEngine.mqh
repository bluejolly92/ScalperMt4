//+------------------------------------------------------------------+
//| BreakoutEngine.mqh                                               |
//+------------------------------------------------------------------+

#include <ScalperMt4/Inputs.mqh>

bool CheckBreakoutSignal(double &slOut, double &tpOut)
{
   double atr = iATR(NULL, PERIOD_M15, ATR_Period, 0);
   if (atr < MinATR)
   {
      if (EnableVerboseLog)
         Print("⛔ ATR troppo basso: ", atr);
      return false;
   }

   double high = iHigh(NULL, PERIOD_M15, 1);
   double low  = iLow(NULL, PERIOD_M15, 1);
   double close = iClose(NULL, PERIOD_M15, 1);

   bool breakoutUp = (close > high);
   bool breakoutDown = (close < low);

   if (breakoutUp)
   {
      slOut = NormalizeDouble(Bid - atr * SL_ATR_Mult, Digits);
      tpOut = NormalizeDouble(Bid + atr * TP_ATR_Mult, Digits);
      return true;
   }

   if (breakoutDown)
   {
      slOut = NormalizeDouble(Ask + atr * SL_ATR_Mult, Digits);
      tpOut = NormalizeDouble(Ask - atr * TP_ATR_Mult, Digits);
      return true;
   }

   return false;
}
