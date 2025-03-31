//+------------------------------------------------------------------+
//| NewsFilter.mqh - Blocco operatività in orari sensibili          |
//+------------------------------------------------------------------+
#ifndef __NEWS_FILTER_MQH__
#define __NEWS_FILTER_MQH__

#include <ScalperMt4/Inputs.mqh>
#include <ScalperMt4/Logger.mqh>

bool IsNewsTime()
{
   if (!EnableNewsFilter)
      return false;

   // Simulazione: blocchiamo operatività nei primi 5 minuti di ogni ora
   int minute = TimeMinute(TimeCurrent());
   if (minute >= 0 && minute < NewsBlockMinutes)
   {
      LogInfo("📰 Filtro news attivo: attesa per possibile evento");
      return true;
   }

   return false;
}

#endif
