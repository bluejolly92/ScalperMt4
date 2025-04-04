//+------------------------------------------------------------------+
//| PatternRecognizer.mqh - Pattern Engulfing                        |
//+------------------------------------------------------------------+
#ifndef __PATTERN_RECOGNIZER_MQH__
#define __PATTERN_RECOGNIZER_MQH__

#include <ScalperMt4/Inputs.mqh>
#include <ScalperMt4/Logger.mqh>

// === Rilevamento Pattern Engulfing ===
bool IsEngulfingSignal()
{
   if (!EnableEngulfing)
   {
      LogDebug("ℹ️ Engulfing disabilitato da input.");
      return false;
   }

   double atrH1 = iATR(NULL, PERIOD_H1, ATR_Period, 0);
   if (atrH1 < MinATR)
   {
      LogDebug("📏 ATR H1 troppo basso per pattern Engulfing: " + DoubleToString(atrH1, 5));
      return false;
   }

   int shift = 1;
   double open1  = iOpen(Symbol(), Period(), shift + 1);
   double close1 = iClose(Symbol(), Period(), shift + 1);
   double open2  = iOpen(Symbol(), Period(), shift);
   double close2 = iClose(Symbol(), Period(), shift);

   bool isBullishEngulfing = (close1 < open1 && close2 > open2 && close2 > open1 && open2 < close1);
   bool isBearishEngulfing = (close1 > open1 && close2 < open2 && close2 < open1 && open2 > close1);

   if (isBullishEngulfing)
   {
      LogInfo("✅ Pattern Engulfing Bullish rilevato.");
      return true;
   }

   if (isBearishEngulfing)
   {
      LogInfo("✅ Pattern Engulfing Bearish rilevato.");
      return true;
   }

   LogDebug("📉 Nessun pattern Engulfing rilevato.");
   return false;
}

#endif
