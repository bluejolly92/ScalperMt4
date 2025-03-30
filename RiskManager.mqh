//+------------------------------------------------------------------+
//| File: RiskManager.mqh                                            |
//| Calcolo del lotto dinamico in base al rischio percentuale        |
//+------------------------------------------------------------------+

#include <ScalperMt4/Inputs.mqh>

double CalculateLotSize()
{
   double riskCapital = AccountBalance() * RiskPercent / 100.0;
   double lotStep = MarketInfo(Symbol(), MODE_LOTSTEP);
   double minLot = MarketInfo(Symbol(), MODE_MINLOT);
   double maxLot = MarketInfo(Symbol(), MODE_MAXLOT);

   // SL stimato in punti per il calcolo (fallback = ATR)
   double atr = iATR(Symbol(), PERIOD_H1, 14, 0);
   double stopLossPoints = NormalizeDouble(atr / Point, 0);
   if (stopLossPoints < 10) stopLossPoints = 50;

   double tickValue = MarketInfo(Symbol(), MODE_TICKVALUE);
   double contractSize = MarketInfo(Symbol(), MODE_LOTSIZE);

   double lotSize = (riskCapital / (stopLossPoints * Point)) / (contractSize / 100000.0);
   lotSize = MathMax(lotSize, minLot);
   lotSize = MathMin(lotSize, maxLot);

   // Arrotondamento al passo minimo
   lotSize = MathFloor(lotSize / lotStep) * lotStep;

   return NormalizeDouble(lotSize, 2);
}
