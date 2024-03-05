#property copyright "Copyright 2021-2021, Anael Medeiros."
#property link      "http://github.com/anaelj"
#property version   "1.00"

#include <Trade\Trade.mqh>


 CTrade  ExtTrade;
 
//---
int    ExtHandle=0;
bool   ExtHedging=false;

#define MA_MAGIC 1234501

input int    MovingPeriod       = 14;      // Moving Average period
input int    MovingShift        = 6;       // Moving Average shift


double         iMABuffer[];  
int            handleIma; 

double         iMFIBuffer[];  
int            handleMFI; 

datetime lastTradeTime = 0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(void)
   {

   SetIndexBuffer(0,iMABuffer,INDICATOR_DATA);
   
   handleIma=iMA(_Symbol, PERIOD_CURRENT, 200, 1 , MODE_SMA, PRICE_CLOSE);
   
   SetIndexBuffer(1,iMFIBuffer,INDICATOR_DATA);
   
   handleMFI=iMFI(_Symbol, PERIOD_D1,80, VOLUME_TICK );
   
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+

bool CanOpenTrade() {
    datetime currentTime = TimeCurrent();
    return (currentTime - lastTradeTime) > PeriodSeconds(); 
}

double CandleBodySize(int shift) {
    double openPrice = iOpen(_Symbol, PERIOD_CURRENT, shift);
    double closePrice = iClose(_Symbol, PERIOD_CURRENT, shift);
    return MathAbs(closePrice - openPrice) * SymbolInfoDouble(_Symbol, SYMBOL_POINT);
}

bool bullCandle(const int index) {
    if (Close[index] > Open[index]) {
        return true;
    } else {
        return false;
    }
}

bool bearCandle(const int index) {
    if (Close[index] < Open[index]) {
        return true;
    } else {
        return false;
    }
}

void OnTick(void)
  {
     int shift = 0;
     long     volume= iVolume( _Symbol,PERIOD_CURRENT,shift);
     double   close1 = iClose(_Symbol,PERIOD_CURRENT,shift);
     double   open2 = iOpen(_Symbol,PERIOD_CURRENT,shift+1);
     double   close2 = iClose(_Symbol,PERIOD_CURRENT,shift+1);
     double   lowPricel1 = iLow(_Symbol,PERIOD_CURRENT,shift);
     
 //    Print("Values:", volume, " close:", close);
 
      Print("BodySize:", CandleBodySize(1)  );
      
      CopyBuffer(handleIma,0,0,ArraySize(iMABuffer)+1,iMABuffer);
      CopyBuffer(handleMFI,0,0,ArraySize(iMFIBuffer)+1,iMFIBuffer);
      
      if (ArraySize(iMABuffer) > 10) {
      
         double ma_value = iMABuffer[ArraySize(iMABuffer)-1];
         double mfi_value1 = iMFIBuffer[ArraySize(iMFIBuffer)-1];
         double mfi_value2 = iMFIBuffer[ArraySize(iMFIBuffer)-2];
         
         double currentPrice =SymbolInfoDouble(_Symbol, SYMBOL_ASK);
         
   
         
         if ( close2 > open2 && mfi_value1 > mfi_value2 && currentPrice < ma_value && (!PositionSelect(_Symbol)) && CanOpenTrade() && CandleBodySize(1) > 2) {
                
            Print(" trading:", mfi_value1, " mfi_value2:", mfi_value2, " close1:",close1, " ma_value:",ma_value); 
            double stopLoss = SymbolInfoDouble(_Symbol, SYMBOL_BID) - (150 * SymbolInfoDouble(_Symbol, SYMBOL_POINT)); 
           // double stopLoss = lowPricel1;
            double takeProfit = SymbolInfoDouble(_Symbol, SYMBOL_BID) + (400 * SymbolInfoDouble(_Symbol, SYMBOL_POINT)); 
            
            if (takeProfit < ma_value) {
            
               ExtTrade.Buy(0.20, _Symbol, SymbolInfoDouble(_Symbol, SYMBOL_ASK), stopLoss, takeProfit, "by average return");
               lastTradeTime = TimeCurrent();
               Print("ma_value:", " hasTrading "); 
            
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


