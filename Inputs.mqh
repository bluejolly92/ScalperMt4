//+------------------------------------------------------------------+
//| Inputs.mqh                                                       |
//+------------------------------------------------------------------+

// === Generali ===
extern bool EnableLogging     = true;
extern bool EnableGUI         = true;
extern int MagicNumber        = 123456;

// === Rischio ===
extern double RiskPercent     = 2.0;
extern double LotSizeMin      = 0.01;
extern double LotSizeMax      = 5.0;
extern int MaxOpenTrades      = 3;

// === Strategia Breakout ===
extern bool EnableBreakout    = true;
extern int ATR_Period         = 14;
extern double SL_ATR_Mult     = 1.5;
extern double TP_ATR_Mult     = 2.0;

// === Pattern Engulfing ===
extern bool EnableEngulfing   = true;

// === Filtri Trend ===
extern bool EnableTrendFilter = true;
extern bool EnableMAFilter    = true;
extern int MA_Period          = 50;
extern int MA_Direction       = 1;      // 1 = long only, -1 = short only, 0 = entrambi
extern bool EnableADXFilter   = true;
extern int ADX_Period         = 14;
extern double ADX_Threshold   = 20.0;
extern int TrendTimeframe     = 60;     // MQL4 usa PERIOD_XXX come int (es. 60 = H1)

// === Volatilità ===
extern double MinATR          = 0.0005;

// === News e Orari ===
extern bool EnableNewsFilter  = false;
extern int StartHour          = 8;
extern int EndHour            = 20;

// === Trailing e Break-even ===
extern bool EnableTrailing    = true;
extern bool EnableBreakEven   = true;

// === Logging ===
extern int LogThrottleSeconds = 10;
extern bool EnableVerboseLog  = false;
