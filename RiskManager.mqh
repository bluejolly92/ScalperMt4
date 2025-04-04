//+------------------------------------------------------------------+
//| RiskManager.mqh - Calcolo SL/TP e Lotto Dinamico                |
//+------------------------------------------------------------------+
#ifndef __RISK_MANAGER_MQH__
#define __RISK_MANAGER_MQH__

#include <ScalperMt4/Inputs.mqh>
#include <ScalperMt4/Logger.mqh>

// === Calcolo SL/TP dinamici ===
bool CalculateDynamicSLTP(bool isBuy, double &sl, double &tp)
{
   double atr = iATR(Symbol(), PERIOD_M15, ATR_Period, 0);
   if (atr <= 0.0 || atr < MinATR)
   {
      LogDebug("❌ ATR troppo basso o nullo per SL/TP: " + DoubleToString(atr, 5));
      return false;
   }

   double price = isBuy ? Bid : Ask;
   double slOffset = atr * SL_ATR_Mult;
   double tpOffset = atr * TP_ATR_Mult;

   if (isBuy)
   {
      sl = NormalizeDouble(price - slOffset, Digits);
      tp = NormalizeDouble(price + tpOffset, Digits);
   }
   else
   {
      sl = NormalizeDouble(price + slOffset, Digits);
      tp = NormalizeDouble(price - tpOffset, Digits);
   }

   LogDebug("📐 SL/TP calcolati → SL: " + DoubleToString(sl, Digits) + " | TP: " + DoubleToString(tp, Digits));
   return true;
}

// === Calcolo lotto dinamico in base a RiskPercent e SL ===
double CalculateLotSize(double stopLossPrice, bool isBuy, double riskPercent)
{
   double price        = isBuy ? Ask : Bid;
   double slDistance   = MathAbs(price - stopLossPrice);

   // PATCH 1: Protezione SL minimo (es. 1 pip)
   double minSLDistance = Point * 10;
   if (slDistance < minSLDistance)
   {
      slDistance = minSLDistance;
      Print("[WARNING] SL troppo stretto. Usato minimo: ", DoubleToString(slDistance, Digits));
   }

   // Valore del tick e size del lotto
   double tickValue    = MarketInfo(Symbol(), MODE_TICKVALUE);
   double lotSize      = MarketInfo(Symbol(), MODE_LOTSIZE);
   double riskAmount   = AccountBalance() * riskPercent / 100.0;

   // Calcolo lotto grezzo
   double lot = (riskAmount / (slDistance / Point * tickValue));

   // PATCH 2: Limite al lotto massimo
   double maxLot = 100.0;
   if (lot > maxLot)
   {
      Print("[WARNING] Lotto calcolato troppo alto (", DoubleToString(lot, 2), "), limitato a ", DoubleToString(maxLot, 2));
      lot = maxLot;
   }

   // Arrotondamento al minimo consentito
   double minLot  = MarketInfo(Symbol(), MODE_MINLOT);
   double lotStep = MarketInfo(Symbol(), MODE_LOTSTEP);
   lot = MathFloor(lot / lotStep) * lotStep;
   if (lot < minLot)
   {
      Print("[WARNING] Lotto troppo basso, impostato a minimo: ", minLot);
      lot = minLot;
   }

   // PATCH 3: Controllo margine disponibile
   double marginRequiredPerLot = MarketInfo(Symbol(), MODE_MARGINREQUIRED);
   double requiredMargin = lot * marginRequiredPerLot;

   if (AccountFreeMargin() < requiredMargin)
   {
      Print("[ERROR] Margine insufficiente. Riduzione lotto...");
      lot = AccountFreeMargin() / marginRequiredPerLot;
      lot = MathFloor(lot / lotStep) * lotStep;

      // Dopo la riduzione, nuovo controllo per lotto minimo
      if (lot < minLot)
      {
         Print("[FATAL] Lotto minimo non raggiungibile. Lotto finale: ", lot);
         return 0.0;
      }
   }

   return NormalizeDouble(lot, 2);
}

// === Verifica se si può aprire un nuovo ordine ===
bool CanOpenNewTrade()
{
   int count = 0;
   for (int i = 0; i < OrdersTotal(); i++)
   {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) &&
          OrderSymbol() == Symbol() &&
          OrderMagicNumber() == MagicNumber)
      {
         count++;
      }
   }

   if (count >= MaxOpenTrades)
   {
      LogInfo("🚫 MaxOpenTrades raggiunto per " + Symbol() + ": " + IntegerToString(count));
      return false;
   }

   return true;
}

#endif
