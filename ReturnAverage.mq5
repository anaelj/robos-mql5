#property copyright "Copyright 2021-2021, Anael Medeiros."
#property link      "http://github.com/anaelj"
#property version   "1.00"

#include <Trade\Trade.mqh>

 double quantidadeReferenciaON     = 0;   
 double quantidadeReferenciaPN     = 0;      
 input double capitalInicial       = 0.1;

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
    


      
      if ( trade.Sell(quantityToSell, _Symbol, SymbolInfoDouble(_Symbol,SYMBOL_BID),0,0,"troca oibr3 por oibr4")) {}

      


         if trade.Buy(quantityToBy, _Symbol, SymbolInfoDouble(_Symbol,SYMBOL_ASK),0,0,"troca oibr4 por oibr3") {}
           
  }


//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  }
//+------------------------------------------------------------------+
