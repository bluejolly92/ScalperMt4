//+------------------------------------------------------------------+
//| File: NewsFilter.mqh                                             |
//| Descrizione: Filtro news, rollover e orari operativi             |
//+------------------------------------------------------------------+

#include <ScalperMt4/Inputs.mqh>

bool IsTradingAllowed()
{
   if (!IsTradingHour())
   {
      if (EnableVerboseLog) Print("⏰ Fuori orario operativo.");
      return false;
   }

   if (EnableNewsFilter && IsNewsTime())
   {
      if (EnableLogging) Print("📛 Blocco per notizie economiche.");
      return false;
   }

   if (IsRolloverTime())
   {
      if (EnableVerboseLog) Print("🌙 Fascia oraria rollover.");
      return false;
   }

   double atr = iATR(NULL, PERIOD_H1, ATRPeriod, 0);
   if (atr < MinATR)
   {
      if (EnableVerboseLog) Print("🚫 ATR troppo basso (H1): ", atr);
      return false;
   }

   return true;
}

void InitNewsFilter()
{
   if (EnableVerboseLog) Print("🟡 InitNewsFilter() attivato (placeholder)");
}

bool IsNewsTime()
{
   // Questo modulo è predisposto per leggere un CSV in futuro
   // Per ora simula che non ci siano news bloccanti
   return false;
}

bool IsRolloverTime()
{
   int hour = TimeHour(TimeCurrent());
   if (RolloverHourStart > RolloverHourEnd)
      return (hour >= RolloverHourStart || hour < RolloverHourEnd);
   else
      return (hour >= RolloverHourStart && hour < RolloverHourEnd);
}

bool IsTradingHour()
{
   int hour = TimeHour(TimeCurrent());
   if (TradingStartHour > TradingEndHour)
      return (hour >= TradingStartHour || hour < TradingEndHour);
   else
      return (hour >= TradingStartHour && hour < TradingEndHour);
}
