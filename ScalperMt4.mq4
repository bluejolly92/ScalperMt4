//+------------------------------------------------------------------+
//| Expert Advisor: ScalperMt4                                       |
//| Descrizione: Scalper modulare con breakout, engulfing, GUI       |
//+------------------------------------------------------------------+

#include <ScalperMt4/Inputs.mqh>
#include <ScalperMt4/BreakoutEngine.mqh>
#include <ScalperMt4/PatternRecognizer.mqh>
#include <ScalperMt4/RiskManager.mqh>
#include <ScalperMt4/TradeManager.mqh>
#include <ScalperMt4/NewsFilter.mqh>
#include <ScalperMt4/GUI.mqh>
#include <ScalperMt4/Logger.mqh>
#include <ScalperMt4/TrendFilter.mqh>

datetime lastNoTradeLogTime = 0;

int OnInit()
{
   InitLogger();
   InitGUI();
   InitNewsFilter();
   LogStatus("🟢 EA inizializzato");
   return INIT_SUCCEEDED;
}

void OnTick()
{
   // Blocco pre-news
   if (EnableNewsFilter && IsNewsTime())
   {
      LogThrottled("🛑 Trading bloccato per notizie imminenti", lastNoTradeLogTime, LOG_WARN);
      return;
   }

   // Blocco orario
   int hour = TimeHour(TimeCurrent());
   if (hour < TradingStartHour || hour >= TradingEndHour)
   {
      LogThrottled("⏰ Fuori orario operativo (ora: " + IntegerToString(hour) + ")", lastNoTradeLogTime, LOG_WARN);
      return;
   }

   if (!IsTradingAllowed())
   {
      LogThrottled("🛑 Trading non consentito in questo momento.", lastNoTradeLogTime, LOG_WARN);
      return;
   }

   UpdateDashboard();

   bool useBreakout   = EnableBreakout && IsBreakoutSignal();
   bool useEngulfing  = EnableEngulfing && IsEngulfingSignal();

   if (!useBreakout && !useEngulfing)
   {
      string noSignalMsg = "⚠️ Nessun segnale valido (Breakout: " + useBreakout + ", Engulfing: " + useEngulfing + ")";
      LogThrottled(noSignalMsg, lastNoSignalLogTime, LOG_INFO);
      return;
   }

   double lot = CalculateLotSize();
   double sl, tp;
   GetDynamicSLTP(sl, tp);
   ExecuteTrade(lot);

   string sigMsg = "📈 Segnale attivo (" + (useBreakout ? "Breakout" : "Engulfing") + ") - Lotti: " + DoubleToString(lot, 2);
   LogThrottled(sigMsg, lastSignalLogTime, LOG_SIGNAL);
   LogStatus("ℹ️ Stato dopo segnale attivo");
}

void OnTimer()
{
   datetime now = TimeLocal();
   for (int i = ObjectsTotal() - 1; i >= 0; i--)
   {
      string name = ObjectName(i);
      if (StringFind(name, "GuiMsg_") == 0)
         ObjectDelete(name);
   }

   EventKillTimer(); // Disattiva il timer fino alla prossima AddGuiMessage
}


void OnDeinit(const int reason)
{
   CleanupGUI();
   LogStatus("🔴 EA disattivato");
}
