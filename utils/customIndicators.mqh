//+------------------------------------------------------------------+
//|                                                 candlePatter.mqh |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link "https://www.mql5.com"
#property version "1.00"
//+------------------------------------------------------------------+

double getVolumeAverage()
{
   long volumeSum = 0.0;

   for(int i = 1; i < 50; i++) {

      long volume = iVolume(_Symbol, PERIOD_CURRENT, i);
      
      volumeSum += volume;
   }
   
   
   return NormalizeDouble( volumeSum / 50, 7);
}