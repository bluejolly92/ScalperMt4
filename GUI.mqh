//+------------------------------------------------------------------+
//| GUI.mqh - Visualizzazione diagnostica su chart                  |
//+------------------------------------------------------------------+
#ifndef __GUI_MQH__
#define __GUI_MQH__

#include <ScalperMt4/Inputs.mqh>

string guiLabelName = "ScalperMt4_Status";

void InitGUI()
{
   if (!EnableGUI) return;

   ObjectCreate(guiLabelName, OBJ_LABEL, 0, 0, 0);
   ObjectSet(guiLabelName, OBJPROP_CORNER, 0);         // Angolo in alto a sinistra
   ObjectSet(guiLabelName, OBJPROP_XDISTANCE, 10);
   ObjectSet(guiLabelName, OBJPROP_YDISTANCE, 10);
   ObjectSet(guiLabelName, OBJPROP_COLOR, clrWhite);
   ObjectSetText(guiLabelName, "🟢 ScalperMt4 inizializzato", 12, "Arial", clrLimeGreen);
}

void UpdateGUI()
{
   if (!EnableGUI || ObjectFind(guiLabelName) < 0) return;

   string content = "🧠 EA attivo\n";
   content += "Equity: " + DoubleToString(AccountEquity(), 2) + "\n";
   content += "Balance: " + DoubleToString(AccountBalance(), 2) + "\n";
   content += "Time: " + TimeToString(TimeCurrent(), TIME_MINUTES);

   ObjectSetText(guiLabelName, content, 12, "Arial", clrWhite);
}

void CleanupGUI()
{
   ObjectDelete(guiLabelName);
}

#endif
