//+------------------------------------------------------------------+
//| File: GUI.mqh                                                    |
//| Dashboard visiva base su chart                                   |
//+------------------------------------------------------------------+

#include <ScalperMt4/Inputs.mqh>

void InitGUI()
{
   if (!EnableGUI) return;

   // Esempio: label di stato semplice
   string name = "ScalperLabel";
   ObjectCreate(name, OBJ_LABEL, 0, 0, 0);
   ObjectSet(name, OBJPROP_CORNER, 0);
   ObjectSet(name, OBJPROP_XDISTANCE, 10);
   ObjectSet(name, OBJPROP_YDISTANCE, 10);
   ObjectSetText(name, "📈 ScalperMt4 attivo", 12, "Arial", clrLimeGreen);
}

void UpdateGUI()
{
   if (!EnableGUI) return;

   string name = "ScalperLabel";
   if (ObjectFind(name) < 0) return;

   double equity = AccountEquity();
   double balance = AccountBalance();

   string txt = StringFormat("Equity: %.2f\nBalance: %.2f", equity, balance);
   ObjectSetText(name, txt, 12, "Arial", clrWhite);
}

void CleanupGUI()
{
   ObjectDelete("ScalperLabel");
}
