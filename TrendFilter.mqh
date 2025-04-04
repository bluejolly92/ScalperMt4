//+------------------------------------------------------------------+
//| TrendFilter.mqh - Filtro MA e ADX per confermare il trend       |
//+------------------------------------------------------------------+
#ifndef __TREND_FILTER_MQH__
#define __TREND_FILTER_MQH__

#include <ScalperMt4/Inputs.mqh>
#include <ScalperMt4/Logger.mqh>

// === Verifica se il trend è confermato da MA e/o ADX ===
bool IsTrendConfirmed()
{
   if (!EnableTrendFilter)
   {
      LogDebug("ℹ️ Filtro Trend disattivato.");
      return true;
   }

   bool maOk = true;
   bool adxOk = true;

   // --- Filtro MA ---
   if (EnableMAFilter)
   {
      double ma = iMA(Symbol(), TrendTimeframe, MA_Period, 0, MODE_EMA, PRICE_CLOSE, 0);
      double price = iClose(Symbol(), TrendTimeframe, 0);

      LogDebug("📊 MA(" + IntegerToString(MA_Period) + ", TF: " + IntegerToString(TrendTimeframe) + ") = " + 
               DoubleToString(ma, Digits) + " | Prezzo = " + DoubleToString(price, Digits));

      if (MA_Direction == 1 && price <= ma)
         maOk = false;  // Solo segnali long
      else if (MA_Direction == -1 && price >= ma)
         maOk = false;  // Solo segnali short
   }

   // --- Filtro ADX ---
   if (EnableADXFilter)
   {
      double adx = iADX(Symbol(), TrendTimeframe, ADX_Period, PRICE_CLOSE, MODE_MAIN, 0);
      LogDebug("📈 ADX(" + IntegerToString(ADX_Period) + ", TF: " + IntegerToString(TrendTimeframe) + ") = " + 
               DoubleToString(adx, 2));

      if (adx < ADX_Threshold)
         adxOk = false;
   }

   if (!maOk || !adxOk)
   {
      LogDebug("⛔️ Trend non confermato → MA: " + (maOk ? "✅" : "❌") + " | ADX: " + (adxOk ? "✅" : "❌"));
      return false;
   }

   LogDebug("✅ Trend confermato da filtri attivi.");
   return true;
}

#endif
