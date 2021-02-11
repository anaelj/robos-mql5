#property copyright "Copyright 2009-2017, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

#include <Trade\Trade.mqh>

 double quantidadeReferenciaON     = 0;   
 double quantidadeReferenciaPN     = 0;      
 input double capitalInicial       = 200;
 string mySymbol                   = "OIBR3"; 
 CTrade  trade;
 
//---
int    ExtHandle=0;
bool   ExtHedging=false;

#define MA_MAGIC 1234501

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(void)
  {
   if (quantidadeReferenciaON == 0) {
      quantidadeReferenciaON = capitalInicial / SymbolInfoDouble("OIBR3",SYMBOL_BID) ;
   }
   if (quantidadeReferenciaPN == 0) {
      quantidadeReferenciaPN = capitalInicial / SymbolInfoDouble("OIBR4",SYMBOL_BID) ;
   }
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
    double quantityToSell = 0;
    double quantityToSellRest = 0;
    double quantityToBy = 0;
    double quantityToByRest = 0;
    

    if (mySymbol == "OIBR3") {
      ask = SymbolInfoDouble("OIBR4",SYMBOL_ASK); 
      valorTotalAtual = SymbolInfoDouble("OIBR3",SYMBOL_BID) * quantidadeReferenciaON;
      quantidadeSimulada = round(valorTotalAtual / ask);

      if (quantidadeSimulada > quantidadeReferenciaPN) {
      
         quantityToSellRest = MathMod(quantidadeReferenciaON,100);
         quantityToSell = quantidadeReferenciaON - quantityToSellRest;
         quantityToSellRest = round(quantityToSellRest);

         quantityToByRest = MathMod(quantidadeSimulada,100);
         quantityToBy = quantidadeSimulada - quantityToByRest;
         quantityToByRest = round(quantityToByRest);
      
      if ( trade.Sell(quantityToSell, "OIBR3", SymbolInfoDouble("OIBR3",SYMBOL_BID),0,0,"troca oibr3 por oibr4")) {

         quantidadeReferenciaON = round(valorTotalAtual / SymbolInfoDouble("OIBR3",SYMBOL_BID));
         quantidadeReferenciaPN = round(valorTotalAtual / SymbolInfoDouble("OIBR4",SYMBOL_BID));
            
            trade.Sell(quantityToSellRest, "OIBR3F", SymbolInfoDouble("OIBR3F",SYMBOL_BID),0,0,"troca oibr3 por oibr4");
            trade.Buy(quantityToBy, "OIBR4", SymbolInfoDouble("OIBR4",SYMBOL_ASK),0,0,"troca oibr3 por oibr4");
            trade.Buy(quantityToByRest, "OIBR4F", SymbolInfoDouble("OIBR4F",SYMBOL_ASK),0,0,"troca oibr3 por oibr4");
   
            mySymbol = "OIBR4";
            printf("sell OIBR3======================================== " + quantityToSell);
            printf("sellRest OIBR3F=================================== " + quantityToSellRest);
            printf("by OIBR4========================================== " + quantityToBy);
            printf("byRest OIBR4F===================================== " + quantityToByRest);
         }

//         printf("quantidadeON======================================== " + quantidadeReferenciaON);
//         printf("quantidadePN======================================== " + quantidadeReferenciaPN);
      }
    } 
    else if (mySymbol == "OIBR4") {
      ask = SymbolInfoDouble("OIBR3",SYMBOL_ASK); 
      valorTotalAtual = SymbolInfoDouble("OIBR4",SYMBOL_BID) * quantidadeReferenciaPN;
      quantidadeSimulada = round(valorTotalAtual / ask);

      if (quantidadeSimulada > quantidadeReferenciaON) {

         quantityToSellRest = MathMod(quantidadeReferenciaPN,100);
         quantityToSell = quantidadeReferenciaPN - quantityToSellRest;
         quantityToSellRest = round(quantityToSellRest);

         quantityToByRest = MathMod(quantidadeSimulada,100);
         quantityToBy = quantidadeSimulada - quantityToByRest;
         quantityToByRest = round(quantityToByRest);

         if (trade.Sell(quantityToSell, "OIBR4", SymbolInfoDouble("OIBR4",SYMBOL_BID),0,0,"troca oibr4 por oibr3")){
            quantidadeReferenciaON = round(valorTotalAtual / SymbolInfoDouble("OIBR3",SYMBOL_BID));
            quantidadeReferenciaPN = round(valorTotalAtual / SymbolInfoDouble("OIBR4",SYMBOL_BID));
            
            trade.Sell(quantityToSellRest, "OIBR4F", SymbolInfoDouble("OIBR4F",SYMBOL_BID),0,0,"troca oibr4 por oibr3");
   
            trade.Buy(quantityToBy, "OIBR3", SymbolInfoDouble("OIBR3",SYMBOL_ASK),0,0,"troca oibr4 por oibr3");
            trade.Buy(quantityToByRest, "OIBR3F", SymbolInfoDouble("OIBR3F",SYMBOL_ASK),0,0,"troca oibr4 por oibr3");
   
   
            mySymbol = "OIBR3";
            printf("sell OIBR4======================================== " + quantityToSell);
            printf("sellRest OIBR4F=================================== " + quantityToSellRest);
            printf("by OIBR3========================================== " + quantityToBy);
            printf("byRest OIBR3F===================================== " + quantityToByRest);
            }

//         printf("quantidadeON======================================== " + quantidadeReferenciaON);
//         printf("quantidadePN======================================== " + quantidadeReferenciaPN);
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
