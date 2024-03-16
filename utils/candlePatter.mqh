//+------------------------------------------------------------------+
//|                                                 candlePatter.mqh |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
bool bullCandle(const int index)
  {
   if(iClose(_Symbol,PERIOD_CURRENT,index) > iOpen(_Symbol,PERIOD_CURRENT,index))
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
   return !bullCandle(index);
  }
  
  
  double CandleShadow(int shift)
{
  double openPrice = iOpen(_Symbol, PERIOD_CURRENT, shift);
  double closePrice = iClose(_Symbol, PERIOD_CURRENT, shift);
  double shadowTop = 0;
  double shadowDown = 0;

  if (openPrice < closePrice)
  {
    shadowTop = iHigh(_Symbol, PERIOD_CURRENT, shift) - closePrice;
    shadowDown = openPrice - iLow(_Symbol, PERIOD_CURRENT, shift);
  }
  else
  {
    shadowTop = iHigh(_Symbol, PERIOD_CURRENT, shift) - openPrice;
    shadowDown = closePrice - iLow(_Symbol, PERIOD_CURRENT, shift);
  }

  double candleTotal = iHigh(_Symbol, PERIOD_CURRENT, shift) - iLow(_Symbol, PERIOD_CURRENT, shift);
  double totalShadow = shadowTop + shadowDown;
  // Print(" candleTotal: ", candleTotal," totalShadow:", totalShadow);

  return (totalShadow * 100) / candleTotal;
}

double CandleBodySize(int shift)
{
  double openPrice = iOpen(_Symbol, PERIOD_CURRENT, shift);
  double closePrice = iClose(_Symbol, PERIOD_CURRENT, shift);
  return MathAbs(closePrice - openPrice) * SymbolInfoDouble(_Symbol, SYMBOL_POINT);
}

double CandleSize (int shift, int digits= 5) {

   return NormalizeDouble(iHigh(_Symbol, PERIOD_CURRENT, shift) - iLow(_Symbol, PERIOD_CURRENT, shift),digits);

}
