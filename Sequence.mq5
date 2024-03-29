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


double         iMABuffer21[];  
double         iMABuffer80[]; 
double         iMABuffer200[]; 

int            handleIma21; 
int            handleIma80; 
int            handleIma200; 

double         iMFIBuffer[];  
int            handleMFI; 

bool trading = false;

datetime lastTradeTime = 0;

enum EnumMoveAverage {
    MA200 = 200,
    MA80 = 80,
    MA21 = 21
};

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(void)
   {

   SetIndexBuffer(0,iMABuffer21,INDICATOR_DATA);
   handleIma21=iMA(_Symbol, PERIOD_CURRENT, 21, 1 , MODE_SMA, PRICE_CLOSE);

   SetIndexBuffer(0,iMABuffer80,INDICATOR_DATA);
   handleIma80=iMA(_Symbol, PERIOD_CURRENT, 80, 1 , MODE_SMA, PRICE_CLOSE);

   SetIndexBuffer(0,iMABuffer200,INDICATOR_DATA);
   handleIma200=iMA(_Symbol, PERIOD_CURRENT, 200, 1 , MODE_SMA, PRICE_CLOSE);
   
   SetIndexBuffer(1,iMFIBuffer,INDICATOR_DATA);
   
   handleMFI=iMFI(_Symbol, PERIOD_D1,80, VOLUME_TICK );
   
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+

bool HasOpenTrades() {
    int total = PositionsTotal();
      if(PositionSelect(_Symbol)) {
         Print (" Has position.........." );
      }
    

    return trading;
}

double Close(const int index) {
 return iClose(_Symbol,PERIOD_CURRENT,index);
}

double Open(const int index) {
 return iOpen(_Symbol,PERIOD_CURRENT,index);
}

bool bullCandle(const int index) {
    if (Close(index) > Open(index)) {
        return true;
    } else {
        return false;
    }
}

bool bearCandle(const int index) {
    if (Close(index) < Open(index)) {
        return true;
    } else {
        return false;
    }
}

double getMoveAverageValue (EnumMoveAverage value) {
 

   switch (value) {
        case MA200:
            CopyBuffer(handleIma200,0,0,ArraySize(iMABuffer200)+1,iMABuffer200);
            return iMABuffer200[ArraySize(iMABuffer200)-1];
            break;
        case MA80:
            CopyBuffer(handleIma80,0,0,ArraySize(iMABuffer80)+1,iMABuffer80);
            return iMABuffer80[ArraySize(iMABuffer80)-1];
            break;
        case MA21:
            CopyBuffer(handleIma21,0,0,ArraySize(iMABuffer21)+1,iMABuffer21);
            return iMABuffer21[ArraySize(iMABuffer21)-1];
            break;
        default:
            return 0;
            break;
    }
    

}

bool CanOpenTrade() {
    datetime currentTime = TimeCurrent();
    return (currentTime - lastTradeTime) > PeriodSeconds(); 
}
double CandleBodySize(int shift) {
    double openPrice = iOpen(_Symbol, PERIOD_CURRENT, shift);
    double closePrice = iClose(_Symbol, PERIOD_CURRENT, shift);
    return MathAbs(closePrice - openPrice) * SymbolInfoDouble(_Symbol, SYMBOL_POINT);
}

double CandleShadow(int shift) {
    double openPrice = iOpen(_Symbol, PERIOD_CURRENT, shift);
    double closePrice = iClose(_Symbol, PERIOD_CURRENT, shift);
    double shadowTop = 0;
    double shadowDown = 0;
    
    if (openPrice < closePrice) {
      shadowTop = iHigh(_Symbol, PERIOD_CURRENT, shift) - closePrice;
      shadowDown = openPrice - iLow(_Symbol, PERIOD_CURRENT, shift) ;
    } else {
      shadowTop = iHigh(_Symbol, PERIOD_CURRENT, shift) - openPrice;
      shadowDown = closePrice - iLow(_Symbol, PERIOD_CURRENT, shift) ;
    }
    
    double candleTotal = iHigh(_Symbol, PERIOD_CURRENT, shift) - iLow(_Symbol, PERIOD_CURRENT, shift);
    double totalShadow = shadowTop + shadowDown;
    //Print(" candleTotal: ", candleTotal," totalShadow:", totalShadow);
    
    return (totalShadow * 100) / candleTotal;
}

double min(double a, double b) {
    return (a < b) ? a : b;
}

void OnTick(void)
  {
     int shift = 0;
     long     volume= iVolume( _Symbol,0,shift);
     double   close = iClose(_Symbol,PERIOD_CURRENT,shift);
     double   close1 = iClose(_Symbol,PERIOD_CURRENT,1);
     double   ma200value = getMoveAverageValue(MA200); 
     double   ma21value = getMoveAverageValue(MA21);
     double   ma80value = getMoveAverageValue(MA80);
     
     
  //  Print("move-distance:", ma21value - ma200value);
    double moveAverageDistance = ma21value - ma200value;
    
    double maxMoveAverageDistance = 1.7;
    double symbolPoint = 0;
    double takeProfit = SymbolInfoDouble(_Symbol, SYMBOL_BID) + (250 * SymbolInfoDouble(_Symbol, SYMBOL_POINT)); 
    double maxTake = ma200value + (1000 * SymbolInfoDouble(_Symbol, SYMBOL_POINT)); 
    
   // Print("CandleShadow:",CandleShadow(1));
    
      if (PositionSelect(_Symbol)) {
         lastTradeTime = TimeCurrent();
      }
    
     if ( CanOpenTrade() && close1 < ma21value && bullCandle(1) && CandleShadow(1) < 80 && moveAverageDistance < 0.006 && ma21value > ma80value && ma80value > ma200value && (!PositionSelect(_Symbol))) {
        
            //  Print("CandleShadow:",CandleShadow(1));
                        
             //double stopLoss = SymbolInfoDouble(_Symbol, SYMBOL_BID) - (200 * SymbolInfoDouble(_Symbol, SYMBOL_POINT)); 
             //double stopLoss = min( iLow(_Symbol,PERIOD_CURRENT,1), iLow(_Symbol,PERIOD_CURRENT,2));
             double stopLoss = min( iLow(_Symbol,PERIOD_CURRENT,1), iLow(_Symbol,PERIOD_CURRENT,2)) - (100 * SymbolInfoDouble(_Symbol, SYMBOL_POINT)); 
            
             ExtTrade.Buy(0.10, _Symbol, SymbolInfoDouble(_Symbol, SYMBOL_ASK), stopLoss, takeProfit, "by tendence");
            
            
         }
      
  }


//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  }
//+------------------------------------------------------------------+


