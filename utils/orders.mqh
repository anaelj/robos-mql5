//+------------------------------------------------------------------+
//|                                                 candlePatter.mqh |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link "https://www.mql5.com"
#property version "1.00"
//+------------------------------------------------------------------+

#include <Trade\Trade.mqh>


void ModifyStopLoss(CTrade &trade, double newStopLoss)
{

        ulong ticket = PositionGetInteger(POSITION_IDENTIFIER);
        bool modifyResult = trade.PositionModify(ticket, newStopLoss, 0);

        if (modifyResult)
        {
            Print("Stop Loss modificado para ", newStopLoss);
        }
        else
        {
            Print("Erro ao modificar Stop Loss: ", trade.ResultRetcode());
        }
 }

void CloseMyOrder(CTrade &trade)
{

    ulong ticket = PositionGetInteger(POSITION_IDENTIFIER);
    bool modifyResult = trade.PositionClose(ticket);

    if (modifyResult)
    {
        Print("Ordem fechada ");
    }
    else
    {
        Print("Erro ao modificar Stop Loss: ", trade.ResultRetcode());
    }

}