//+------------------------------------------------------------------+
//| Logger.mqh - Logging con gestione per tipo                      |
//+------------------------------------------------------------------+
#ifndef __LOGGER_MQH__
#define __LOGGER_MQH__

#include <ScalperMt4/Inputs.mqh>

string lastLogMsg = "";
datetime lastLogTime = 0;

// === Logging con throttling ===
void LogThrottled(string message)
{
   datetime now = TimeCurrent();
   if (message != lastLogMsg || (now - lastLogTime) >= LogThrottleSeconds)
   {
      Print(message);
      lastLogMsg = message;
      lastLogTime = now;
   }
}

// === Log generale operativo ===
void LogInfo(string message)
{
   LogThrottled("[INFO] " + message);
}

// === Log errori e criticità ===
void LogError(string message)
{
   LogThrottled("[ERROR] " + message);
}

// === Log diagnostico avanzato (solo se verbose attivo) ===
void LogDebug(string message)
{
   if (EnableVerboseLog)
      LogThrottled("[DEBUG] " + message);
}

#endif
