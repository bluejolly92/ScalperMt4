//+------------------------------------------------------------------+
//| ScalperMt4.mq4 - Expert Advisor principale                      |
//+------------------------------------------------------------------+
#property strict
#property copyright "Andrea Pitzianti"
#property link      "https://github.com/bluejolly92/ScalperMt4"
#property version   "1.00"

// === INCLUDES ===
#include <ScalperMt4/Inputs.mqh>
#include <ScalperMt4/BreakoutEngine.mqh>
#include <ScalperMt4/PatternRecognizer.mqh>
#include <ScalperMt4/RiskManager.mqh>
#include <ScalperMt4/TradeManager.mqh>
#include <ScalperMt4/NewsFilter.mqh>
#include <ScalperMt4/GUI.mqh>
#include <ScalperMt4/Logger.mqh>
#include <ScalperMt4/TrendFilter.mqh>
#include <ScalperMt4/Utils.mqh>

//+------------------------------------------------------------------+
//| Funzione di inizializzazione                                     |
//+------------------------------------------------------------------+
int OnInit()
{
   if (EnableLogging)
      Print("✅ EA inizializzato correttamente");

   if (EnableGUI)
      InitGUI();

   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Funzione principale di esecuzione su ogni tick                   |
//+------------------------------------------------------------------+
void OnTick()
{
   double sl = 0.0;
   double tp = 0.0;
   
   if (EnableTradingHours && !IsTradingHour())
   {
      LogInfo("⏰ Orario non operativo. Trading disattivato.");
      return;
   }
   
   if (IsNewsTime())
   {
      LogInfo("📢 Blocco operatività per news.");
      return;
   }

   if (!IsVolatilitySufficient())
   {
      LogInfo("Operazione bloccata: volatilità insufficiente");
      return;
   }

   if (EnableBreakout && CheckBreakoutSignal(sl, tp))
   {
      LogThrottled("🚨 Segnale Breakout rilevato. SL: " + DoubleToString(sl, Digits) + " | TP: " + DoubleToString(tp, Digits));
   
      bool isBuy = iClose(Symbol(), Period(), 0) > iHigh(Symbol(), Period(), 1);
      if (!OpenTrade(isBuy, sl, tp))
         LogError("❌ Errore apertura trade dopo segnale breakout");
   }

   ManageOpenTrades(); // Gestione dinamica delle posizioni aperte
   UpdateGUI();
}


//+------------------------------------------------------------------+
//| Funzione di deinizializzazione                                   |
//+------------------------------------------------------------------+
void OnDeinit()
{
   if (EnableGUI)
      CleanupGUI();

   if (EnableLogging)
      Print("🛑 EA terminato");
}
