//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021-2021, Anael Medeiros."
#property link "http://github.com/anaelj"
#property version "1.00"

#include <Trade\Trade.mqh>
#include "utils\candlePatter.mqh";
#include "utils\orders.mqh";
#include "utils\lib.mqh";
#include "utils\customIndicators.mqh";


CTrade ExtTrade;

//---
int ExtHandle = 0;
bool ExtHedging = false;

#define MA_MAGIC 1234501

input int MovingPeriod = 14; // Moving Average period
input int MovingShift = 6;   // Moving Average shift

double iMABuffer7[];
double iMABuffer21[];
double iMABuffer80[];
double iMABuffer200[];

int handleIma7;
int handleIma21;
int handleIma80;
int handleIma200;

double iMFIBuffer[];
int handleMFI;

bool trading = false;

datetime lastTradeTime = 0;
double currentStopLoss = 0;
double maxCandleSize = 0.002; // alterar isso depois, dar um jeito porque pode mudar conforme o papel

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

  SetIndexBuffer(0, iMABuffer7, INDICATOR_DATA);
  handleIma7 = iMA(_Symbol, PERIOD_CURRENT, 7, 1, MODE_SMA, PRICE_CLOSE);

  SetIndexBuffer(0, iMABuffer21, INDICATOR_DATA);
  handleIma21 = iMA(_Symbol, PERIOD_CURRENT, 21, 1, MODE_SMA, PRICE_CLOSE);

  SetIndexBuffer(0, iMABuffer80, INDICATOR_DATA);
  handleIma80 = iMA(_Symbol, PERIOD_CURRENT, 80, 1, MODE_SMA, PRICE_CLOSE);

  SetIndexBuffer(0, iMABuffer200, INDICATOR_DATA);
  handleIma200 = iMA(_Symbol, PERIOD_CURRENT, 200, 1, MODE_SMA, PRICE_CLOSE);

  SetIndexBuffer(1, iMFIBuffer, INDICATOR_DATA);

  handleMFI = iMFI(_Symbol, PERIOD_D1, 80, VOLUME_TICK);

  return (INIT_SUCCEEDED);
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
  if (PositionSelect(_Symbol))
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
  return iClose(_Symbol, PERIOD_CURRENT, index);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Open(const int index)
{
  return iOpen(_Symbol, PERIOD_CURRENT, index);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getMoveAverageValue(EnumMoveAverage value)
{

  switch (value)
  {
  case MA200:
    CopyBuffer(handleIma200, 0, 0, ArraySize(iMABuffer200) + 1, iMABuffer200);
    return iMABuffer200[ArraySize(iMABuffer200) - 1];
    break;
  case MA80:
    CopyBuffer(handleIma80, 0, 0, ArraySize(iMABuffer80) + 1, iMABuffer80);
    return iMABuffer80[ArraySize(iMABuffer80) - 1];
    break;
  case MA21:
    CopyBuffer(handleIma21, 0, 0, ArraySize(iMABuffer21) + 1, iMABuffer21);
    return iMABuffer21[ArraySize(iMABuffer21) - 1];
    break;
  case MA7:
    CopyBuffer(handleIma7, 0, 0, ArraySize(iMABuffer7) + 1, iMABuffer7);
    return iMABuffer7[ArraySize(iMABuffer7) -1];
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
void OnTick(void)
{
  int shift = 0;
  int doubleDigits = 7;
  long volume = NormalizeDouble(iVolume(_Symbol, PERIOD_CURRENT, 1) , 7);
  double close = NormalizeDouble(iClose(_Symbol, PERIOD_CURRENT, shift), doubleDigits);
  double open = NormalizeDouble(iOpen(_Symbol, PERIOD_CURRENT, shift), doubleDigits);
  
  double close1 = iClose(_Symbol, PERIOD_CURRENT, 1);
  double close2 = iClose(_Symbol, PERIOD_CURRENT, 2);
  double close3 = iClose(_Symbol, PERIOD_CURRENT, 3);
  double close4 = iClose(_Symbol, PERIOD_CURRENT, 4);
  double ma200value = getMoveAverageValue(MA200);
  double ma21value = getMoveAverageValue(MA21);
  double ma80value = getMoveAverageValue(MA80);
  double ma7value = getMoveAverageValue(MA7);

  //  Print("move-distance:", ma21value - ma200value);
  double moveAverageDistance = ma21value - ma200value;

  double maxMoveAverageDistance = 1.7;
  double symbolPoint = 0;
  double takeProfit = SymbolInfoDouble(_Symbol, SYMBOL_BID) + (450 * SymbolInfoDouble(_Symbol, SYMBOL_POINT));
  double maxTake = ma200value + (1000 * SymbolInfoDouble(_Symbol, SYMBOL_POINT));
   double volumeAverage = getVolumeAverage();

  // Print("CandleShadow:",CandleShadow(1));

  if (PositionSelect(_Symbol))
  {

    double modeAverageValue = NormalizeDouble(getMoveAverageValue(MA7), doubleDigits);
    double orderPriceOpen = OrderGetDouble(ORDER_PRICE_OPEN);
   
//&& (close1 > modeAverageValue || close2 > modeAverageValue || close3 > modeAverageValue || close4 > modeAverageValue)
       if ( modeAverageValue > close1 && CanOpenTrade() && bearCandle(1) && CandleShadow(1) < 50)
       {
         CloseMyOrder(ExtTrade);
         Print(" modeAverageValue:",modeAverageValue, " close1:", close1);
         Print(" volume when close:", volume );
         // ModifyStopLoss(ExtTrade,0);
       }
   }

    double low1 = iLow(_Symbol, PERIOD_CURRENT, 1);
    double low2 = iLow(_Symbol, PERIOD_CURRENT, 2);
    double low3 = iLow(_Symbol, PERIOD_CURRENT, 3);
    double candlesize = CandleSize(2);

    if ( maxCandleSize > candlesize && CandleShadow(1) < 50 && CandleShadow(2) > 90 && low2 < low1 && low2 < low3 && bullCandle(1) && close3 < close4 && volume > volumeAverage)
    {

      // if ( CanOpenTrade() && close1 < ma21value && bullCandle(1) && CandleShadow(1) < 80 && moveAverageDistance < 0.006 && ma21value > ma80value && ma80value > ma200value && (!PositionSelect(_Symbol))) {

      if (CanOpenTrade() && (!PositionSelect(_Symbol)))
      {
        //  Print("CandleShadow:",CandleShadow(1));

        // double stopLoss = SymbolInfoDouble(_Symbol, SYMBOL_BID) - (200 * SymbolInfoDouble(_Symbol, SYMBOL_POINT));
        // double stopLoss = min( iLow(_Symbol,PERIOD_CURRENT,1), iLow(_Symbol,PERIOD_CURRENT,2));
        double stopLoss = min(iLow(_Symbol, PERIOD_CURRENT, 1), iLow(_Symbol, PERIOD_CURRENT, 2)) - (200 * SymbolInfoDouble(_Symbol, SYMBOL_POINT));
        string comment = "btl vl:" + StringSubstr(DoubleToString(volume),0,6) +" vla: " + StringSubstr(DoubleToString(volumeAverage),0,6);

        ExtTrade.Buy(0.10, _Symbol, SymbolInfoDouble(_Symbol, SYMBOL_ASK), stopLoss, 0, comment);
        currentStopLoss = NormalizeDouble(stopLoss, 5);
        lastTradeTime = TimeCurrent();
        Print(" candle size:", candlesize, " point size:",SymbolInfoDouble(_Symbol, SYMBOL_POINT) );
        
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
