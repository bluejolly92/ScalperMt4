//+------------------------------------------------------------------+
//| File: TradeManager.mqh                                           |
//| Gestione apertura ordini, trailing stop e break-even            |
//+------------------------------------------------------------------+

#include <ScalperMt4/Inputs.mqh>

bool ExecuteTrade(int orderType, double lotSize, double sl, double tp)
{
   if (OrdersTotal() >= MaxOpenTrades)
   {
      Print("Numero massimo di ordini aperti raggiunto");
      return false;
   }

   double price = (orderType == OP_BUY) ? Ask : Bid;
   int slippage = 3;

   int ticket = OrderSend(Symbol(), orderType, lotSize, price, slippage, sl, tp, "ScalperMt4", MagicNumber, 0, clrBlue);
   if (ticket < 0)
   {
      Print("Errore apertura ordine: ", GetLastError());
      return false;
   }

   return true;
}
