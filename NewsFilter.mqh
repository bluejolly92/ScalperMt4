//+------------------------------------------------------------------+
//| NewsFilter.mqh - Blocco operatività in orari sensibili          |
//+------------------------------------------------------------------+
#ifndef __NEWS_FILTER_MQH__
#define __NEWS_FILTER_MQH__

#include <ScalperMt4/Inputs.mqh>
#include <ScalperMt4/Logger.mqh>

// === Rilevamento orario di blocco per simulazione eventi macro ===
bool IsNewsTime()
{
   if (!EnableNewsFilter)
   {
      LogDebug("🛑 Filtro news disattivato.");
      return false;
   }

   datetime now = TimeCurrent();
   int minute = TimeMinute(now);

   if (minute >= 0 && minute < NewsBlockMinutes)
   {
      LogInfo("📰 NewsTime → Blocco attivo nei primi " + IntegerToString(NewsBlockMinutes) + 
              " min dell'ora. Ora corrente: " + TimeToString(now, TIME_MINUTES));
      return true;
   }

   return false;
}

#endif
