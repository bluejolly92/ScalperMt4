//+------------------------------------------------------------------+
//| TrendFilter.mqh                                                  |
//+------------------------------------------------------------------+

#include <ScalperMt4/Inputs.mqh>

bool IsTrendConfirmed()
{
   if (!EnableTrendFilter) return true;

   bool maOk = true;
   bool adxOk = true;

   // === Filtro Media Mobile ===
   if (EnableMAFilter)
   {
      double ma = iMA(NULL, TrendTimeframe, MA_Period, 0, MODE_EMA, PRICE_CLOSE, 0);
      double price = iClose(NULL, TrendTimeframe, 0);

      if (MA_Direction == 1 && price <= ma)      maOk = false;
      else if (MA_Direction == -1 && price >= ma) maOk = false;
   }

   // === Filtro ADX ===
   if (EnableADXFilter)
   {
      double adx = iADX(NULL, TrendTimeframe, ADX_Period, PRICE_CLOSE, MODE_MAIN, 0);
      if (adx < ADX_Threshold) adxOk = false;
   }

   return (maOk && adxOk);
}
