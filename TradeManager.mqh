//+------------------------------------------------------------------+
//| File: TradeManager.mqh                                           |
//| Descrizione: Gestione ordini, trailing, break-even              |
//+------------------------------------------------------------------+

#include <ScalperMt4/Inputs.mqh>
#include <ScalperMt4/RiskManager.mqh>
#include <ScalperMt4/TrendFilter.mqh>

extern datetime lastNoSignalLogTime;
extern datetime lastSignalLogTime;

// Verifica se esiste già una posizione o ordine pendente
bool IsTradeOpen()
{
   for (int i = 0; i < OrdersTotal(); i++)
   {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if (OrderMagicNumber() != MagicNumber || OrderSymbol() != Symbol())
            continue;

         int type = OrderType();
         if (type == OP_BUY || type == OP_SELL || type == OP_BUYLIMIT || type == OP_SELLLIMIT || type == OP_BUYSTOP || type == OP_SELLSTOP)
            return true;
      }
   }
   return false;
}

// Esegue un nuovo trade se non ce ne sono già aperti
void ExecuteTrade(double lot)
{
   static bool logTradeOpen = false;
   static bool logPending = false;
   static bool logMaxReached = false;
   
   // Filtro spread massimo
   int spreadPoints = MarketInfo(Symbol(), MODE_SPREAD);
   if (spreadPoints > MaxSpreadPoints)
   {
      if (EnableVerboseLog)
         Print("🚫 Spread troppo alto (", spreadPoints, " punti), max consentito: ", MaxSpreadPoints);
      return;
   }
   
   if (CountPendingOrders() > 0)
   {
      if (!logPending && EnableVerboseLog)
      {
         Print("⚠️ Ordine pendente già presente per ", Symbol(), ", nessuna nuova operazione.");
         logPending = true;
      }
      return;
   }
   logPending = false;

   if (IsTradeOpen())
   {
      if (!logTradeOpen && EnableVerboseLog)
      {
         Print("⚠️ Trade già aperto per ", Symbol(), ", operazione ignorata.");
         logTradeOpen = true;
      }
      return;
   }
   logTradeOpen = false;

   if (CountOpenTrades() >= MaxOpenTrades)
   {
      if (!logMaxReached && EnableVerboseLog)
      {
         Print("🚫 Numero massimo di trade aperti raggiunto (", MaxOpenTrades, ")");
         logMaxReached = true;
      }
      return;
   }
   logMaxReached = false;

   double outSL, outTP;
   GetDynamicSLTP(outSL, outTP);

   int ticket;
   if (IsTradeDirectionShort())
      ticket = OrderSend(Symbol(), OP_SELL, lot, Bid, 3, outSL, outTP, "Sell", MagicNumber, 0, clrRed);
   else
      ticket = OrderSend(Symbol(), OP_BUY, lot, Ask, 3, outSL, outTP, "Buy", MagicNumber, 0, clrBlue);
      
      bool shortTrade = IsTradeDirectionShort();

   if (EnableTrendFilter)
   {
      if (shortTrade && !IsTrendBearish())
      {
         if (EnableVerboseLog)
            Print("📛 Trade SHORT bloccato: trend non ribassista");
         return;
      }
   
      if (!shortTrade && !IsTrendBullish())
      {
         if (EnableVerboseLog)
            Print("📛 Trade LONG bloccato: trend non rialzista");
         return;
      }
   }

   if (ticket < 0)
      Print("❌ Errore invio ordine: ", GetLastError());
   else if (EnableVerboseLog)
      Print("✅ Ordine inviato con successo. Ticket: ", ticket);
}

// Gestione trailing stop e break-even (con logica dinamica avanzata)
void ManageOpenTrades()
{
   for (int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if (OrderMagicNumber() != MagicNumber || OrderSymbol() != Symbol()) continue;

         double price = MarketInfo(Symbol(), OrderType() == OP_BUY ? MODE_BID : MODE_ASK);
         double open = OrderOpenPrice();
         double atr = iATR(NULL, 0, ATRPeriod, 0);
         double trailTrigger = atr * 2; // inizia trailing dopo 2x ATR
         double trailStep = atr;        // passo del trailing dinamico

         // Trailing dinamico
         if (EnableTrailing)
         {
            double newSL = 0;
            if (OrderType() == OP_BUY && price - open > trailTrigger)
            {
               newSL = NormalizeDouble(price - trailStep, Digits);
               if (newSL > OrderStopLoss())
                  SafeOrderModify(OrderTicket(), OrderOpenPrice(), newSL, OrderTakeProfit(), 0, clrGreen);
            }
            else if (OrderType() == OP_SELL && open - price > trailTrigger)
            {
               newSL = NormalizeDouble(price + trailStep, Digits);
               if (newSL < OrderStopLoss())
                  SafeOrderModify(OrderTicket(), OrderOpenPrice(), newSL, OrderTakeProfit(), 0, clrOrange);
            }
         }

         // Break-even dinamico
         if (EnableBreakEven)
         {
            double breakDistance = atr * 1.5;
            if (OrderType() == OP_BUY && price - open > breakDistance && OrderStopLoss() < open)
               SafeOrderModify(OrderTicket(), OrderOpenPrice(), open, OrderTakeProfit(), 0, clrYellow);

            if (OrderType() == OP_SELL && open - price > breakDistance && OrderStopLoss() > open)
               SafeOrderModify(OrderTicket(), OrderOpenPrice(), open, OrderTakeProfit(), 0, clrYellow);
         }
      }
   }
}

// Chiude tutte le posizioni aperte per simbolo e MagicNumber
void CloseAllTrades()
{
   for (int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if (OrderMagicNumber() != MagicNumber || OrderSymbol() != Symbol()) continue;

         if (OrderType() == OP_BUY)
            SafeOrderClose(OrderTicket(), OrderLots(), Bid, 3, clrRed);
         else if (OrderType() == OP_SELL)
            SafeOrderClose(OrderTicket(), OrderLots(), Ask, 3, clrBlue);
      }
   }
}

// Wrapper sicuro per OrderModify
bool SafeOrderModify(int ticket, double price, double sl, double tp, datetime expiration = 0, color arrow_color = clrNONE)
{
   if (!OrderModify(ticket, price, sl, tp, expiration, arrow_color))
   {
      int err = GetLastError();
      Print("❌ OrderModify fallito (ticket ", ticket, "): errore ", err);
      return false;
   }
   return true;
}

// Wrapper sicuro per OrderClose
bool SafeOrderClose(int ticket, double lots, double price, int slippage, color arrow_color = clrNONE)
{
   if (!OrderClose(ticket, lots, price, slippage, arrow_color))
   {
      int err = GetLastError();
      Print("❌ OrderClose fallito (ticket ", ticket, "): errore ", err);
      return false;
   }
   return true;
}

// Conta le posizioni aperte per simbolo e MagicNumber
int CountOpenTrades()
{
   int count = 0;
   for (int i = 0; i < OrdersTotal(); i++)
   {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
         {
            int type = OrderType();
            if (type == OP_BUY || type == OP_SELL)
               count++;
         }
      }
   }
   return count;
}

int CountPendingOrders()
{
   int count = 0;
   for (int i = 0; i < OrdersTotal(); i++)
   {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber)
            continue;

         int type = OrderType();
         if (type == OP_BUYLIMIT || type == OP_BUYSTOP || type == OP_SELLLIMIT || type == OP_SELLSTOP)
            count++;
      }
   }
   return count;
}
