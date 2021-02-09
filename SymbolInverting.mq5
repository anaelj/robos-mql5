#property copyright "Copyright 2009-2017, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

#include <Trade\Trade.mqh>

 double quantidadeReferenciaON     = 190;   
 double quantidadeReferenciaPN     = 190;      
input double valorReferenciaON          = 966;
input double valorReferenciaPN          = 966;
 string mySymbol                   = "SAPR3"; 
//---
int    ExtHandle=0;
bool   ExtHedging=false;
CTrade ExtTrade;

#define MA_MAGIC 1234501

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(void)
  {
//--- prepare trade class to control positions if hedging mode is active
/*   ExtHedging=((ENUM_ACCOUNT_MARGIN_MODE)AccountInfoInteger(ACCOUNT_MARGIN_MODE)==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING);
   ExtTrade.SetExpertMagicNumber(MA_MAGIC);
   ExtTrade.SetMarginMode();
   ExtTrade.SetTypeFillingBySymbol(Symbol());
*/
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(void)
  {
    double ask = 0;
    double quantidadeSimulada = 0;
    double valorTotalAtual = 0;

    if (mySymbol == "SAPR3") {
      ask = SymbolInfoDouble("SAPR4",SYMBOL_ASK); 
      valorTotalAtual = SymbolInfoDouble("SAPR3",SYMBOL_BID) * quantidadeReferenciaON;
      quantidadeSimulada = round(valorTotalAtual / ask);

      if (quantidadeSimulada > quantidadeReferenciaPN) {
         quantidadeReferenciaON = round(valorTotalAtual / SymbolInfoDouble("SAPR3",SYMBOL_BID));
         quantidadeReferenciaPN = round(valorTotalAtual / SymbolInfoDouble("SAPR4",SYMBOL_BID));
         mySymbol = "SAPR4";
         printf("comprei======================================== sap4");
         printf("quantidadeON======================================== " + quantidadeReferenciaON);
         printf("quantidadePN======================================== " + quantidadeReferenciaPN);
      }
    } 
    else if (mySymbol == "SAPR4") {
      ask = SymbolInfoDouble("SAPR3",SYMBOL_ASK); 
      valorTotalAtual = SymbolInfoDouble("SAPR4",SYMBOL_BID) * quantidadeReferenciaPN;
      quantidadeSimulada = round(valorTotalAtual / ask);

      if (quantidadeSimulada > quantidadeReferenciaON) {
         quantidadeReferenciaON = round(valorTotalAtual / SymbolInfoDouble("SAPR3",SYMBOL_BID));
         quantidadeReferenciaPN = round(valorTotalAtual / SymbolInfoDouble("SAPR4",SYMBOL_BID));
         mySymbol = "SAPR3";
         printf("comprei ======================================== sap3");
         printf("quantidadeON======================================== " + quantidadeReferenciaON);
         printf("quantidadePN======================================== " + quantidadeReferenciaPN);
      }
    }
  }


//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  }
//+------------------------------------------------------------------+
