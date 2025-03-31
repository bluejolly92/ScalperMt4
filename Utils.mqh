//+------------------------------------------------------------------+
//| Utils.mqh - Funzioni ausiliarie                                 |
//+------------------------------------------------------------------+
#ifndef __UTILS_MQH__
#define __UTILS_MQH__

#include <ScalperMt4/Inputs.mqh>
#include <ScalperMt4/Logger.mqh>

bool IsTradingHour()
{
   int hour = TimeHour(TimeCurrent());
   return (hour >= StartHour && hour < EndHour);
}

bool IsVolatilitySufficient()
{
   double atr = iATR(NULL, PERIOD_M15, ATR_Period, 0);
   LogDebug("Volatilità attuale (ATR): " + DoubleToString(atr, 5));

   if (atr < MinATR)
   {
      LogDebug("❌ Volatilità insufficiente: ATR < MinATR");
      return false;
   }

   LogDebug("✅ Volatilità sufficiente");
   return true;
}

#endif
