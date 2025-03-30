//+------------------------------------------------------------------+
//| File: Logger.mqh                                                 |
//| Logging con sistema di throttling per evitare spam nel log      |
//+------------------------------------------------------------------+

#include <ScalperMt4/Inputs.mqh>

datetime lastLogTime = 0;
string lastLogMessage = "";

void LogThrottled(string message)
{
   datetime now = TimeCurrent();
   if (message != lastLogMessage || (now - lastLogTime) >= LogThrottleSeconds)
   {
      Print(message);
      lastLogTime = now;
      lastLogMessage = message;
   }
}

void InitLogger()
{
   Print("🟢 Logger inizializzato");
}

void CleanupLogger()
{
   Print("🔴 Logger terminato");
}
