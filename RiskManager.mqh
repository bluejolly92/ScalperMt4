//+------------------------------------------------------------------+
//| File: RiskManager.mqh                                            |
//| Descrizione: Gestione rischio, calcolo lotti e SL/TP dinamici   |
//+------------------------------------------------------------------+

#include <ScalperMt4/Inputs.mqh>

// Calcolo lotto basato sul rischio in percentuale
double CalculateLotSize()
{
   double balance = AccountBalance();
   double riskAmount = balance * RiskPercent / 100.0;

   double atr = iATR(NULL, 0, ATRPeriod, 0);
   if (atr <= 0)
   {
      if (EnableVerboseLog) Print("⚠️ ATR nullo o non valido, ritorno LotSizeMin");
      return LotSizeMin;
   }

   double stopLossInPoints = atr / Point;
   double tickValue = MarketInfo(Symbol(), MODE_TICKVALUE);

   double lot = riskAmount / (stopLossInPoints * tickValue);
   lot = MathMax(LotSizeMin, MathMin(LotSizeMax, lot));

   if (EnableVerboseLog)
      Print("📊 Lotto calcolato: ", DoubleToString(lot, 2), " | RiskAmount=", riskAmount, ", ATR=", atr);

   return NormalizeDouble(lot, 2);
}

// Calcolo SL e TP dinamico basato su ATR
void GetDynamicSLTP(double &outSL, double &outTP)
{
   double atr = iATR(NULL, 0, ATRPeriod, 0);
   if (atr <= 0)
   {
      atr = Point * 10; // fallback di sicurezza
      if (EnableVerboseLog) Print("⚠️ ATR non valido, uso fallback: ", atr);
   }

   double price = Ask;
   if (IsTradeDirectionShort())
      price = Bid;

   double distanceSL = atr * ATR_SL_Multiplier;
   double distanceTP = atr * ATR_TP_Multiplier;
   
   if (IsTradeDirectionShort())
   {
      outSL = NormalizeDouble(price + distanceSL, Digits);
      outTP = NormalizeDouble(price - distanceTP, Digits);
   }
   else
   {
      outSL = NormalizeDouble(price - distanceSL, Digits);
      outTP = NormalizeDouble(price + distanceTP, Digits);
   }

   if (EnableVerboseLog)
      Print("🎯 SL/TP calcolati: SL=", DoubleToString(outSL, Digits), ", TP=", DoubleToString(outTP, Digits), ", ATR=", atr);
}

// Direzione del prossimo trade (basata su breakout o pattern)
bool IsTradeDirectionShort()
{
   double highestHigh = High[iHighest(NULL, 0, MODE_HIGH, BreakoutPeriod, 1)];
   double lowestLow   = Low[iLowest(NULL, 0, MODE_LOW, BreakoutPeriod, 1)];
   double ask = MarketInfo(Symbol(), MODE_ASK);
   double bid = MarketInfo(Symbol(), MODE_BID);

   if (bid < lowestLow)
   {
      if (EnableVerboseLog) Print("📉 Direzione SHORT confermata da breakout");
      return true;
   }
   if (ask > highestHigh)
   {
      if (EnableVerboseLog) Print("📈 Direzione LONG confermata da breakout");
      return false;
   }

   // Fallback pattern engulfing
   int shift = 1;
   double open1 = Open[shift + 1];
   double close1 = Close[shift + 1];
   double open2 = Open[shift];
   double close2 = Close[shift];

   if (close1 > open1 && close2 < open2)
   {
      if (EnableVerboseLog) Print("📉 Direzione SHORT da pattern engulfing");
      return true;
   }

   if (close1 < open1 && close2 > open2)
   {
      if (EnableVerboseLog) Print("📈 Direzione LONG da pattern engulfing");
      return false;
   }

   if (EnableVerboseLog) Print("🟡 Direzione default: LONG");
   return false;
}
