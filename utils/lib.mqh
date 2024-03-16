//+------------------------------------------------------------------+
//|                                                 candlePatter.mqh |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link "https://www.mql5.com"
#property version "1.00"
//+------------------------------------------------------------------+

double min(double a, double b)
{
  return (NormalizeDouble(a, 4) < NormalizeDouble(b, 4)) ? a : b;
}