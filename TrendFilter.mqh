//+------------------------------------------------------------------+
//| Rilevamento trend con MA o ADX                                  |
//+------------------------------------------------------------------+
#include <ScalperMt4/Inputs.mqh>

bool IsTrendBullish()
{
   if (!EnableTrendFilter) return true;

   bool bullish = false;

   // Filtro MA
   if (EnableMAFilter && TrendMethod == "MA")
   {
      double ma = iMA(Symbol(), TrendTimeframe, TrendMAPeriod, 0, MODE_SMA, PRICE_CLOSE, 0);
      double price = iClose(Symbol(), TrendTimeframe, 0);
      if (price > ma) 
         bullish = true;
   }

   // Filtro ADX
   if (EnableADXFilter && TrendMethod == "ADX")
   {
      double adx = iADX(Symbol(), TrendTimeframe, TrendADXPeriod, PRICE_CLOSE, MODE_MAIN, 0);
      double plusDI = iADX(Symbol(), TrendTimeframe, TrendADXPeriod, PRICE_CLOSE, MODE_PLUSDI, 0);
      double minusDI = iADX(Symbol(), TrendTimeframe, TrendADXPeriod, PRICE_CLOSE, MODE_MINUSDI, 0);

      if (adx >= TrendADXThreshold)
         bullish = plusDI > minusDI;
      else
         bullish = true; // Trend debole, permette entrambi
   }

   return bullish;  // Se nessun filtro è attivo o entrambi sono veri, ritorna bullish
}

bool IsTrendBearish()
{
   return !IsTrendBullish();  // Un'inversione del trend bullish
}
