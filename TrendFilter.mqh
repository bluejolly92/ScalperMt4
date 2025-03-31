//+------------------------------------------------------------------+
//| TrendFilter.mqh - Filtro MA e ADX per confermare il trend       |
//+------------------------------------------------------------------+
#ifndef __TREND_FILTER_MQH__
#define __TREND_FILTER_MQH__

#include <ScalperMt4/Inputs.mqh>
#include <ScalperMt4/Logger.mqh>

bool IsTrendConfirmed()
{
   if (!EnableTrendFilter)
      return true;

   bool maOk = true;
   bool adxOk = true;

   if (EnableMAFilter)
   {
      double ma = iMA(NULL, TrendTimeframe, MA_Period, 0, MODE_EMA, PRICE_CLOSE, 0);
      double price = iClose(NULL, TrendTimeframe, 0);

      LogDebug("MA(" + IntegerToString(MA_Period) + ") = " + DoubleToString(ma, Digits) +
               " | Prezzo = " + DoubleToString(price, Digits));

      if (MA_Direction == 1 && price <= ma) maOk = false;       // Solo long
      else if (MA_Direction == -1 && price >= ma) maOk = false; // Solo short
   }

   if (EnableADXFilter)
   {
      double adx = iADX(NULL, TrendTimeframe, ADX_Period, PRICE_CLOSE, MODE_MAIN, 0);
      LogDebug("ADX(" + IntegerToString(ADX_Period) + ") = " + DoubleToString(adx, 2));

      if (adx < ADX_Threshold)
         adxOk = false;
   }

   if (!maOk || !adxOk)
   {
      LogDebug("❌ Trend non confermato");
      return false;
   }

   LogDebug("✅ Trend confermato");
   return true;
}

#endif
