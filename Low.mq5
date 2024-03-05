//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
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

double         iMABuffer7[];
double         iMABuffer21[];
double         iMABuffer80[];
double         iMABuffer200[];

int            handleIma7;
int            handleIma21;
int            handleIma80;
int            handleIma200;

double         iMFIBuffer[];
int            handleMFI;

bool trading = false;

datetime lastTradeTime = 0;
double currentStopLoss =0;

enum EnumMoveAverage
  {
   MA200 = 200,
   MA80 = 80,
   MA21 = 21,
   MA7 = 7
  };

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(void)
  {

   SetIndexBuffer(0,iMABuffer7,INDICATOR_DATA);
   handleIma7=iMA(_Symbol, PERIOD_CURRENT, 7, 1, MODE_SMA, PRICE_CLOSE);
   
   SetIndexBuffer(0,iMABuffer21,INDICATOR_DATA);
   handleIma21=iMA(_Symbol, PERIOD_CURRENT, 21, 1, MODE_SMA, PRICE_CLOSE);

   SetIndexBuffer(0,iMABuffer80,INDICATOR_DATA);
   handleIma80=iMA(_Symbol, PERIOD_CURRENT, 80, 1, MODE_SMA, PRICE_CLOSE);

   SetIndexBuffer(0,iMABuffer200,INDICATOR_DATA);
   handleIma200=iMA(_Symbol, PERIOD_CURRENT, 200, 1, MODE_SMA, PRICE_CLOSE);

   SetIndexBuffer(1,iMFIBuffer,INDICATOR_DATA);

   handleMFI=iMFI(_Symbol, PERIOD_D1,80, VOLUME_TICK);

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool HasOpenTrades()
  {
   int total = PositionsTotal();
   if(PositionSelect(_Symbol))
     {
      Print(" Has position..........");
     }


   return trading;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Close(const int index)
  {
   return iClose(_Symbol,PERIOD_CURRENT,index);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Open(const int index)
  {
   return iOpen(_Symbol,PERIOD_CURRENT,index);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool bullCandle(const int index)
  {
   if(Close(index) > Open(index))
     {
      return true;
     }
   else
     {
      return false;
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool bearCandle(const int index)
  {
   if(Close(index) < Open(index))
     {
      return true;
     }
   else
     {
      return false;
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getMoveAverageValue(EnumMoveAverage value)
  {


   switch(value)
     {
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
      case MA7:
         CopyBuffer(handleIma7,0,0,ArraySize(iMABuffer7)+1,iMABuffer7);
         return iMABuffer7[ArraySize(iMABuffer7)-1];
         break;
      default:
         return 0;
         break;
     }


  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CanOpenTrade()
  {
   datetime currentTime = TimeCurrent();
   return (currentTime - lastTradeTime) > PeriodSeconds();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CandleBodySize(int shift)
  {
   double openPrice = iOpen(_Symbol, PERIOD_CURRENT, shift);
   double closePrice = iClose(_Symbol, PERIOD_CURRENT, shift);
   return MathAbs(closePrice - openPrice) * SymbolInfoDouble(_Symbol, SYMBOL_POINT);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CandleShadow(int shift)
  {
   double openPrice = iOpen(_Symbol, PERIOD_CURRENT, shift);
   double closePrice = iClose(_Symbol, PERIOD_CURRENT, shift);
   double shadowTop = 0;
   double shadowDown = 0;

   if(openPrice < closePrice)
     {
      shadowTop = iHigh(_Symbol, PERIOD_CURRENT, shift) - closePrice;
      shadowDown = openPrice - iLow(_Symbol, PERIOD_CURRENT, shift) ;
     }
   else
     {
      shadowTop = iHigh(_Symbol, PERIOD_CURRENT, shift) - openPrice;
      shadowDown = closePrice - iLow(_Symbol, PERIOD_CURRENT, shift) ;
     }

   double candleTotal = iHigh(_Symbol, PERIOD_CURRENT, shift) - iLow(_Symbol, PERIOD_CURRENT, shift);
   double totalShadow = shadowTop + shadowDown;
//Print(" candleTotal: ", candleTotal," totalShadow:", totalShadow);

   return (totalShadow * 100) / candleTotal;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double min(double a, double b)
  {
   return (NormalizeDouble(a,4) < NormalizeDouble(b,4)) ? a : b;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ModifyStopLoss() {
    
    double low1 = NormalizeDouble(iLow(_Symbol, PERIOD_CURRENT, 1),5);
    double low2 = NormalizeDouble(iLow(_Symbol, PERIOD_CURRENT, 2),5);
    double low3 = NormalizeDouble(iLow(_Symbol, PERIOD_CURRENT, 3),5);
    double low4 = NormalizeDouble(iLow(_Symbol, PERIOD_CURRENT, 4),5);
    
    Print(" ---------------------- low1:", low1, " low2:", low2, " low3:", low3, " low4:", low4);

    double previousLow = min(min(min(low1, low2),low3),low3) ;
    
     Print ("previousLow > currentStopLoss:", previousLow , " currentStopLoss:",  currentStopLoss );
    
    if ( bullCandle(1) && previousLow > currentStopLoss) {
        //Print ("previousLow > currentStopLoss:", previousLow , " currentStopLoss:",  currentStopLoss );
        
        ulong ticket = PositionGetInteger(POSITION_IDENTIFIER);
        bool modifyResult = ExtTrade.PositionModify(ticket, previousLow, 0);
        
        
        if (modifyResult) {
            currentStopLoss = previousLow;
            Print("Stop Loss modificado para ", previousLow);
        } else {
            Print("Erro ao modificar Stop Loss: ", ExtTrade.ResultRetcode());
        }
    }
}

void CloseMyOrder() {
        
        ulong ticket = PositionGetInteger(POSITION_IDENTIFIER);
        double   modeAverageValue = getMoveAverageValue(MA21);
        double   close1 = iClose(_Symbol,PERIOD_CURRENT,1);
        
        if (close1 < modeAverageValue) {
        
        bool modifyResult = ExtTrade.PositionClose(ticket);
                
           if (modifyResult) {
               Print("Ordem fechada ");
           } else {
               Print("Erro ao modificar Stop Loss: ", ExtTrade.ResultRetcode());
           }
        }
    
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick(void)
  {
   int shift = 0;
   long     volume= iVolume(_Symbol,0,shift);
   double   close = iClose(_Symbol,PERIOD_CURRENT,shift);
   double   close1 = iClose(_Symbol,PERIOD_CURRENT,1);
   double   ma200value = getMoveAverageValue(MA200);
   double   ma21value = getMoveAverageValue(MA21);
   double   ma80value = getMoveAverageValue(MA80);
   double   ma7value = getMoveAverageValue(MA7);


//  Print("move-distance:", ma21value - ma200value);
   double moveAverageDistance = ma21value - ma200value;

   double maxMoveAverageDistance = 1.7;
   double symbolPoint = 0;
   double takeProfit = SymbolInfoDouble(_Symbol, SYMBOL_BID) + (450 * SymbolInfoDouble(_Symbol, SYMBOL_POINT));
   double maxTake = ma200value + (1000 * SymbolInfoDouble(_Symbol, SYMBOL_POINT));

// Print("CandleShadow:",CandleShadow(1));

   if(PositionSelect(_Symbol))
     {
      lastTradeTime = TimeCurrent();
      CloseMyOrder();
      //ModifyStopLoss();
     }

   double low1 = iLow(_Symbol,PERIOD_CURRENT,1);
   double low2 = iLow(_Symbol,PERIOD_CURRENT,2);
   double low3 = iLow(_Symbol,PERIOD_CURRENT,3);
   
   

   if(CandleShadow(2) > 95  && low2 < low1 && low2 < low3 && bullCandle(1))
     {

      //if ( CanOpenTrade() && close1 < ma21value && bullCandle(1) && CandleShadow(1) < 80 && moveAverageDistance < 0.006 && ma21value > ma80value && ma80value > ma200value && (!PositionSelect(_Symbol))) {


      if(CanOpenTrade() && (!PositionSelect(_Symbol)))
        {
         //  Print("CandleShadow:",CandleShadow(1));

         //double stopLoss = SymbolInfoDouble(_Symbol, SYMBOL_BID) - (200 * SymbolInfoDouble(_Symbol, SYMBOL_POINT));
         //double stopLoss = min( iLow(_Symbol,PERIOD_CURRENT,1), iLow(_Symbol,PERIOD_CURRENT,2));
         double stopLoss = min(iLow(_Symbol,PERIOD_CURRENT,1), iLow(_Symbol,PERIOD_CURRENT,2)) - (100 * SymbolInfoDouble(_Symbol, SYMBOL_POINT));

         ExtTrade.Buy(0.10, _Symbol, SymbolInfoDouble(_Symbol, SYMBOL_ASK), stopLoss, 0, "low");
         currentStopLoss = NormalizeDouble(stopLoss, 5);

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


//+------------------------------------------------------------------+
