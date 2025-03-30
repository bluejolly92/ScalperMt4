//+------------------------------------------------------------------+
//| File: BreakoutEngine.mqh                                         |
//| Descrizione: Logica breakout range-based con filtro volatilità   |
//+------------------------------------------------------------------+

#include <ScalperMt4/Inputs.mqh>

// Funzione per identificare il segnale di breakout
bool IsBreakoutSignal()
{
   double highestHigh = High[iHighest(NULL, 0, MODE_HIGH, BreakoutPeriod, 1)];
   double lowestLow   = Low[iLowest(NULL, 0, MODE_LOW, BreakoutPeriod, 1)];

   // Controllo volatilità su timeframe H1
   double atrH1 = iATR(NULL, PERIOD_H1, ATRPeriod, 0);

   if (atrH1 < MinATR)
   {
      if (EnableVerboseLog)
         Print("Volatilità insufficiente per breakout. ATR H1 = ", DoubleToString(atrH1, 6));
      return false;
   }

   double ask = MarketInfo(Symbol(), MODE_ASK);
   double bid = MarketInfo(Symbol(), MODE_BID);

   // Breakout LONG
   if (ask > highestHigh)
   {
      if (EnableVerboseLog)
         Print("Breakout LONG rilevato sopra il range: ", DoubleToString(highestHigh, Digits));
      return true;
   }

   // Breakout SHORT
   if (bid < lowestLow)
   {
      if (EnableVerboseLog)
         Print("Breakout SHORT rilevato sotto il range: ", DoubleToString(lowestLow, Digits));
      return true;
   }

   return false;
}
