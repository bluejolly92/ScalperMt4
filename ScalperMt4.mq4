#property strict
#property copyright "Andrea Pitzianti"
#property link      "https://github.com/bluejolly92/ScalperMt4"
#property version   "1.00"

// === INCLUDE DEI MODULI ===
#include <ScalperMt4/Inputs.mqh>
#include <ScalperMt4/BreakoutEngine.mqh>
#include <ScalperMt4/PatternRecognizer.mqh>
#include <ScalperMt4/RiskManager.mqh>
#include <ScalperMt4/TradeManager.mqh>
#include <ScalperMt4/NewsFilter.mqh>
#include <ScalperMt4/GUI.mqh>
#include <ScalperMt4/Logger.mqh>
#include <ScalperMt4/TrendFilter.mqh>

// === FUNZIONE DI INIZIALIZZAZIONE ===
int OnInit()
{
   InitLogger();
   InitGUI();
   Print("EA inizializzato");
   return INIT_SUCCEEDED;
}

// === FUNZIONE PRINCIPALE DI ESECUZIONE ===
void OnTick()
{
   static datetime lastTick = 0;
   if (TimeCurrent() == lastTick)
      return;
   lastTick = TimeCurrent();

   UpdateGUI();

   if (!IsTradingHour() || IsNewsActive())
   {
      LogThrottled("Trading bloccato per orario o notizia");
      return;
   }

   double lotSize = CalculateLotSize();
   double sl = 0, tp = 0;

   if (EnableBreakout && CheckBreakoutSignal(sl, tp))
   {
      LogThrottled("Segnale breakout rilevato");
      ExecuteTrade(OP_BUY, lotSize, sl, tp);
   }
   else if (EnableEngulfing && CheckEngulfingSignal(sl, tp))
   {
      LogThrottled("Pattern engulfing rilevato");
      ExecuteTrade(OP_SELL, lotSize, sl, tp);
   }
   else
   {
      LogThrottled("Nessun segnale valido");
   }
}

// === FUNZIONE DI DEINIZIALIZZAZIONE ===
void OnDeinit()
{
   CleanupLogger();
   CleanupGUI();
}
