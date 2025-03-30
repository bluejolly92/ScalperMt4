//+------------------------------------------------------------------+
//| File: Inputs.mqh                                                 |
//| Descrizione: Parametri esterni configurabili per ScalperMt4      |
//+------------------------------------------------------------------+

//==============================//
// ⚙️ IMPOSTAZIONI GENERALI     //
//==============================//
extern bool   EnableLogging       = true;
input  bool   EnableVerboseLog    = false;
input  int    THROTTLE_INTERVAL   = 240;
extern bool   EnableGUI           = true;
extern int    MagicNumber         = 202504;

//==============================//
// 📋 LOGGING AVANZATO          //
//==============================//
extern bool LogInfoEnabled        = true;
extern bool LogWarnEnabled        = true;
extern bool LogErrorEnabled       = true;
extern bool LogSignalEnabled      = true;
extern bool LogStatusEnabled      = true;
extern bool LogDebugEnabled       = true;
extern bool ShowLogWarningsGUI    = false;
extern bool ShowLogErrorsGUI      = true;
extern bool ShowLogSignalsGUI     = true;

//==============================//
// 💰 MONEY MANAGEMENT          //
//==============================//
extern double RiskPercent         = 1.0;
extern double LotSizeMin          = 0.01;
extern double LotSizeMax          = 5.0;
extern int    MaxOpenTrades       = 1;

//==============================//
// 📈 STRATEGIA: BREAKOUT       //
//==============================//
extern bool   EnableBreakout      = true;
extern int    BreakoutPeriod      = 10;
extern int    ATRPeriod           = 14;
extern double ATRMultiplier       = 1.5;
extern double ATR_SL_Multiplier   = 2.0;
extern double ATR_TP_Multiplier   = 3.0;

//==============================//
// 📊 FILTRI DI TREND           //
//==============================//
extern bool   EnableTrendFilter   = true;
extern bool   EnableMAFilter      = true;
extern bool   EnableADXFilter     = true;
extern string TrendMethod         = "MA";
extern int    TrendTimeframe      = PERIOD_H1;
extern int    TrendMAPeriod       = 50;
extern int    TrendADXPeriod      = 14;
extern int    TrendADXThreshold   = 20;

//==============================//
// 🧠 STRATEGIA: ENGULFING       //
//==============================//
extern bool EnableEngulfing       = true;

//==============================//
// 🔎 FILTRI OPERATIVI          //
//==============================//
extern double MinATR              = 0.0005;
extern int    MaxSpreadPoints     = 30;

//==============================//
// 🔁 TRAILING & BREAKEVEN      //
//==============================//
extern bool   EnableBreakEven     = true;
extern double BreakEvenPips       = 10;
extern bool   EnableTrailing      = true;
extern double TrailingStart       = 15;
extern double TrailingStep        = 5;

//==============================//
// 📰 NEWS E ROLLOVER           //
//==============================//
extern bool EnableNewsFilter      = false;
extern int  MinutesBeforeNews     = 30;
extern int  RolloverHourStart     = 23;
extern int  RolloverHourEnd       = 0;

//==============================//
// 🖥️ DASHBOARD E GUI           //
//==============================//
extern string GuiCorner           = "TR";
extern color  GuiTextColor        = clrWhite;
extern color  GuiBackground       = clrBlack;

//==============================//
// ⏰ FASCE ORARIE OPERATIVE     //
//==============================//
extern int TradingStartHour       = 8;
extern int TradingEndHour         = 20;
