//+------------------------------------------------------------------+
//| File: GUI.mqh                                                    |
//| Descrizione: Dashboard grafica MT4 per EA ScalperMt4             |
//+------------------------------------------------------------------+

#include <ScalperMt4/Inputs.mqh>
#include <ScalperMt4/TradeManager.mqh>  // per CloseAllTrades()

string guiPrefix = "ScalperGUI_";

// Inizializza la dashboard
void InitGUI()
{
   if (!EnableGUI) return;
   if (EnableLogging) Print("🟢 InitGUI: Dashboard abilitata");

   DrawLabel("status", "📊 Scalper MT4 Attivo", 10);
   DrawLabel("equity", "Equity: " + DoubleToString(AccountEquity(), 2), 25);
   DrawLabel("profit", "Profitto: " + DoubleToString(AccountProfit(), 2), 40);
   DrawEmergencyButton();
}

// Aggiorna i valori dinamici della dashboard
void UpdateDashboard()
{
   if (!EnableGUI) return;
   DrawLabel("equity", "Equity: " + DoubleToString(AccountEquity(), 2), 25);
   DrawLabel("profit", "Profitto: " + DoubleToString(AccountProfit(), 2), 40);
   CheckEmergencyButtonClick();
}

// Crea una label testuale
void DrawLabel(string name, string text, int yOffset)
{
   string fullName = guiPrefix + name;
   int corner = 1; // Top Right (TR)
   if (GuiCorner == "TL") corner = 0;
   else if (GuiCorner == "BL") corner = 2;
   else if (GuiCorner == "BR") corner = 3;

   if (!ObjectCreate(0, fullName, OBJ_LABEL, 0, 0, 0))
      ObjectSetInteger(0, fullName, OBJPROP_CORNER, corner);

   ObjectSetInteger(0, fullName, OBJPROP_CORNER, corner);
   ObjectSetInteger(0, fullName, OBJPROP_XDISTANCE, 10);
   ObjectSetInteger(0, fullName, OBJPROP_YDISTANCE, yOffset);
   ObjectSetInteger(0, fullName, OBJPROP_FONTSIZE, 12);
   ObjectSetInteger(0, fullName, OBJPROP_COLOR, GuiTextColor);
   ObjectSetInteger(0, fullName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, fullName, OBJPROP_HIDDEN, true);
   ObjectSetString(0, fullName, OBJPROP_TEXT, text);
   ObjectSetInteger(0, fullName, OBJPROP_BACK, true);
   ObjectSetInteger(0, fullName, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(0, fullName, OBJPROP_WIDTH, 1);
}

// Disegna il pulsante d’emergenza per chiudere tutti i trade
void DrawEmergencyButton()
{
   string rectName = guiPrefix + "btn_close_all_rect";
   string textName = guiPrefix + "btn_close_all_text";
   int corner = 1; // Top Right
   if (GuiCorner == "TL") corner = 0;
   else if (GuiCorner == "BL") corner = 2;
   else if (GuiCorner == "BR") corner = 3;

   // Rettangolo cliccabile
   ObjectCreate(rectName, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, rectName, OBJPROP_CORNER, corner);
   ObjectSetInteger(0, rectName, OBJPROP_XDISTANCE, 10);
   ObjectSetInteger(0, rectName, OBJPROP_YDISTANCE, 60);
   ObjectSetInteger(0, rectName, OBJPROP_XSIZE, 140);
   ObjectSetInteger(0, rectName, OBJPROP_YSIZE, 20);
   ObjectSetInteger(0, rectName, OBJPROP_COLOR, clrRed);
   ObjectSetInteger(0, rectName, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(0, rectName, OBJPROP_WIDTH, 1);
   ObjectSetInteger(0, rectName, OBJPROP_BACK, true);
   ObjectSetInteger(0, rectName, OBJPROP_SELECTABLE, true);
   ObjectSetInteger(0, rectName, OBJPROP_HIDDEN, true);

   // Etichetta sopra il rettangolo
   ObjectCreate(textName, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, textName, OBJPROP_CORNER, corner);
   ObjectSetInteger(0, textName, OBJPROP_XDISTANCE, 15);
   ObjectSetInteger(0, textName, OBJPROP_YDISTANCE, 63);
   ObjectSetInteger(0, textName, OBJPROP_FONTSIZE, 11);
   ObjectSetInteger(0, textName, OBJPROP_COLOR, clrWhite);
   ObjectSetString(0, textName, OBJPROP_TEXT, "❌ CHIUDI TUTTO");
   ObjectSetInteger(0, textName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, textName, OBJPROP_HIDDEN, true);
}

// Controlla se il pulsante è stato cliccato
void CheckEmergencyButtonClick()
{
   string rectName = guiPrefix + "btn_close_all_rect";

   if (ObjectGetInteger(0, rectName, OBJPROP_SELECTED))
   {
      if (EnableLogging) Print("🚨 Pulsante di emergenza premuto! Chiusura di tutte le operazioni.");
      CloseAllTrades();
      ObjectSetInteger(0, rectName, OBJPROP_SELECTED, false); // reset selezione
   }
}

// Rimuove tutti gli oggetti GUI
void CleanupGUI()
{
   if (!EnableGUI) return;
   if (EnableLogging) Print("🔴 CleanupGUI: rimozione elementi GUI");
   ObjectsDeleteAll(0, OBJ_LABEL);
   ObjectsDeleteAll(0, OBJ_RECTANGLE_LABEL);
}

void AddGuiMessage(string msg, color textColor)
{
   string label = "GuiMsg_" + IntegerToString(TimeLocal());
   int x = 10, y = 20;

   if (GuiCorner == "TR") { x = 10; y = 20; }
   else if (GuiCorner == "TL") { x = 10; y = 20; }
   else if (GuiCorner == "BR") { x = 10; y = 100; }
   else if (GuiCorner == "BL") { x = 10; y = 100; }

   ObjectCreate(0, label, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, label, OBJPROP_CORNER, 1);
   ObjectSetInteger(0, label, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, label, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, label, OBJPROP_FONTSIZE, 10);
   ObjectSetInteger(0, label, OBJPROP_COLOR, textColor);
   ObjectSetInteger(0, label, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, label, OBJPROP_SELECTED, false);
   ObjectSetInteger(0, label, OBJPROP_HIDDEN, true);
   ObjectSetString(0, label, OBJPROP_TEXT, msg);

   // Rimuove automaticamente dopo 10 secondi
   EventSetTimer(10);
}
