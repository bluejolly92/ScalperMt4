//+------------------------------------------------------------------+
//| Logger.mqh - Logging con throttling                             |
//+------------------------------------------------------------------+
#ifndef __LOGGER_MQH__
#define __LOGGER_MQH__

#include <ScalperMt4/Inputs.mqh>

string lastLogMsg = "";
datetime lastLogTime = 0;

void LogThrottled(string message)
{
   datetime now = TimeCurrent();

   // Log solo se il messaggio è diverso o è passato abbastanza tempo
   if (message != lastLogMsg || (now - lastLogTime) >= LogThrottleSeconds)
   {
      Print(message);
      lastLogMsg = message;
      lastLogTime = now;
   }
}

#endif
