//+------------------------------------------------------------------+
//| PatternRecognizer.mqh - Pattern Engulfing                       |
//+------------------------------------------------------------------+
#ifndef __PATTERN_RECOGNIZER_MQH__
#define __PATTERN_RECOGNIZER_MQH__

#include <ScalperMt4/Inputs.mqh>
#include <ScalperMt4/Logger.mqh>

bool IsEngulfingSignal()
{
   if (!EnableEngulfing)
      return false;

   double atrH1 = iATR(NULL, PERIOD_H1, ATR_Period, 0);
   if (atrH1 < MinATR)
   {
      LogDebug("ATR H1 troppo basso per pattern: " + DoubleToString(atrH1, 5));
      return false;
   }

   int shift = 1;
   double open1  = Open[shift + 1];
   double close1 = Close[shift + 1];
   double open2  = Open[shift];
   double close2 = Close[shift];

   if (close1 < open1 && close2 > open2 && close2 > open1 && open2 < close1)
   {
      LogInfo("✅ Engulfing bullish rilevato");
      return true;
   }

   if (close1 > open1 && close2 < open2 && close2 < open1 && open2 > close1)
   {
      LogInfo("✅ Engulfing bearish rilevato");
      return true;
   }

   LogDebug("Nessun pattern engulfing rilevato");
   return false;
}

#endif
