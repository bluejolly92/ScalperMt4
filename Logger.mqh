
#ifndef LOGGER_MQH
#define LOGGER_MQH

void LogStatus()
{
   double equity = AccountEquity();
   double balance = AccountBalance();
   double profit = AccountProfit();
   int totalOrders = OrdersTotal();

   Print("[STATUS] Equity: ", DoubleToString(equity, 2),
         " | Balance: ", DoubleToString(balance, 2),
         " | Profit: ", DoubleToString(profit, 2),
         " | Orders: ", totalOrders);
}

#endif // LOGGER_MQH
