#property copyright "Copyright 2021-2021, Anael Medeiros."
#property link      "http://github.com/anaelj"
#property version   "1.00"

#include <Trade\Trade.mqh>

 double quantidadeReferenciaON     = 0;   
 double quantidadeReferenciaPN     = 0;      
 
 input double capitalInicial       = 200;
 
 input string SymbolON       = "BBDC3";
 input string SymbolPN       = "BBDC4";
 input string SymbolStart    = "BBDC3";
 
 string currentSymbol             = ""; 
 
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
   
   currentSymbol == "" ? currentSymbol = SymbolStart : currentSymbol; 
 
   if (quantidadeReferenciaON == 0) {
      quantidadeReferenciaON = capitalInicial / SymbolInfoDouble(SymbolON,SYMBOL_BID) ;
   }
   if (quantidadeReferenciaPN == 0) {
      quantidadeReferenciaPN = capitalInicial / SymbolInfoDouble(SymbolPN,SYMBOL_BID) ;
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
    

    if (currentSymbol == SymbolON) {
      ask = SymbolInfoDouble(SymbolPN,SYMBOL_ASK); 
      valorTotalAtual = SymbolInfoDouble(SymbolON,SYMBOL_BID) * quantidadeReferenciaON;
      quantidadeSimulada = round(valorTotalAtual / ask);

      if (quantidadeSimulada > quantidadeReferenciaPN) {
      
         quantityToSellRest = MathMod(quantidadeReferenciaON,100);
         quantityToSell = quantidadeReferenciaON - quantityToSellRest;
         quantityToSellRest = round(quantityToSellRest);

         quantityToByRest = MathMod(quantidadeSimulada,100);
         quantityToBy = quantidadeSimulada - quantityToByRest;
         quantityToByRest = round(quantityToByRest);
      
      if ( trade.Sell(quantityToSell, SymbolON, 0,0,0, "troca "+SymbolON+" por "+SymbolPN )) {

         quantidadeReferenciaON = round(valorTotalAtual / SymbolInfoDouble(SymbolON,SYMBOL_BID));
         quantidadeReferenciaPN = round(valorTotalAtual / SymbolInfoDouble(SymbolPN,SYMBOL_BID));
            
            trade.Sell(quantityToSellRest, SymbolON+"F" , 0,0,0, "troca "+SymbolON+" por "+SymbolPN);
            
            trade.Buy(quantityToByRest, SymbolPN+"F", 0,0,0, "troca "+SymbolON+" por "+SymbolPN);
            trade.Buy(quantityToBy, SymbolPN, 0,0,0, "troca "+SymbolON+" por "+SymbolPN);
   
            currentSymbol = SymbolPN;
//            printf("sell OIBR3======================================== " + quantityToSell);
//            printf("sellRest OIBR3F=================================== " + quantityToSellRest);
//            printf("by OIBR4========================================== " + quantityToBy);
//            printf("byRest OIBR4F===================================== " + quantityToByRest);
         }

//         printf("quantidadeON======================================== " + quantidadeReferenciaON);
//         printf("quantidadePN======================================== " + quantidadeReferenciaPN);
      }
    } 
    else if (currentSymbol == SymbolPN) {
      ask = SymbolInfoDouble(SymbolON,SYMBOL_ASK); 
      valorTotalAtual = SymbolInfoDouble(SymbolPN,SYMBOL_BID) * quantidadeReferenciaPN;
      quantidadeSimulada = round(valorTotalAtual / ask);

      if (quantidadeSimulada > quantidadeReferenciaON) {

         quantityToSellRest = MathMod(quantidadeReferenciaPN,100);
         quantityToSell = quantidadeReferenciaPN - quantityToSellRest;
         quantityToSellRest = round(quantityToSellRest);

         quantityToByRest = MathMod(quantidadeSimulada,100);
         quantityToBy = quantidadeSimulada - quantityToByRest;
         quantityToByRest = round(quantityToByRest);

         if (trade.Sell(quantityToSell, SymbolPN, 0,0,0, "troca "+SymbolPN+" por "+SymbolON)){
            quantidadeReferenciaON = round(valorTotalAtual / SymbolInfoDouble(SymbolON,SYMBOL_BID));
            quantidadeReferenciaPN = round(valorTotalAtual / SymbolInfoDouble(SymbolPN,SYMBOL_BID));
            
            trade.Sell(quantityToSellRest, SymbolPN+"F", 0,0,0,"troca "+SymbolPN+" por "+SymbolON);
   
            trade.Buy(quantityToByRest, SymbolON+"F", 0,0,0,"troca "+SymbolPN+" por "+SymbolON);
            trade.Buy(quantityToBy, SymbolON, SymbolInfoDouble(SymbolON,SYMBOL_ASK),0,0,"troca "+SymbolPN+" por "+SymbolON);
   
            currentSymbol = SymbolON;
//            printf("sell OIBR4======================================== " + quantityToSell);
//            printf("sellRest OIBR4F=================================== " + quantityToSellRest);
//            printf("by OIBR3========================================== " + quantityToBy);
//            printf("byRest OIBR3F===================================== " + quantityToByRest);
            }
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
