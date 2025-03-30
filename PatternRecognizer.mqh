//+------------------------------------------------------------------+
//| File: PatternRecognizer.mqh                                      |
//| Descrizione: Riconoscimento pattern engulfing bullish/bearish   |
//+------------------------------------------------------------------+

#include <ScalperMt4/Inputs.mqh>

bool IsEngulfingSignal()
{
   if (!EnableEngulfing)
      return false;

   double atrH1 = iATR(NULL, PERIOD_H1, ATRPeriod, 0);
   if (atrH1 < MinATR)
   {
      if (EnableVerboseLog)
         Print(" ATR H1 troppo basso per pattern: ", atrH1);
      return false;
   }

   int shift = 1; // candela precedente rispetto a quella appena chiusa

   double open1  = Open[shift + 1];
   double close1 = Close[shift + 1];
   double open2  = Open[shift];
   double close2 = Close[shift];

   // Engulfing Bullish
   if (close1 < open1 && close2 > open2 && close2 > open1 && open2 < close1)
   {
      if (EnableVerboseLog)
         Print("✅ Pattern engulfing bullish rilevato");
      return true;
   }

   // Engulfing Bearish
   if (close1 > open1 && close2 < open2 && close2 < open1 && open2 > close1)
   {
      if (EnableVerboseLog)
         Print("✅ Pattern engulfing bearish rilevato");
      return true;
   }

   return false;
}
