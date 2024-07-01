//+------------------------------------------------------------------+
//|                                                 AutomatedTrading |
//|                                         Copyright 2024, davdcsam |
//|                                      https://github.com/davdcsam |
//+------------------------------------------------------------------+

#include "ProfitProtection.mqh"

//+------------------------------------------------------------------+
//| TrailingStop                                                     |
//+------------------------------------------------------------------+
class TrailingStop : public ProfitProtection
  {
public:
   // Constructor for TrailingStop class
                     TrailingStop(void) {}

   // Method to verify the positions
   void              Verify()
     {
      // Get the total number of positions
      int total_positions = PositionsTotal();

      // If there are no positions, return
      if(!total_positions)
         return;

      // Loop through all positions
      for(int i=0; i<total_positions; i++)
        {
         // Get the ticket number for the position
         ulong ticket = PositionGetTicket(i);

         // If the position is not valid, continue to the next position
         if(!detectPositions.IsValidPosition(ticket))
            continue;

         // If the position cannot be selected, continue to the next position
         if(!PositionSelectByTicket(ticket))
            continue;

         // Calculate the price activation and the new stop loss
         double priceActivation = (PositionGetDouble(POSITION_PRICE_OPEN) + (PositionGetDouble(POSITION_TP) - PositionGetDouble(POSITION_PRICE_OPEN)) * (activationPercent / 100));
         double newStopLoss = NormalizeDouble(
                                 PositionGetDouble(POSITION_PRICE_CURRENT) + (PositionGetDouble(POSITION_PRICE_OPEN) - PositionGetDouble(POSITION_TP)) * (deviationPercent / 100),
                                 (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS)
                              );

         // If the position is a buy position and the current price is greater than or equal to the price activation, modify the stop loss
         if(
            PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY &&
            PositionGetDouble(POSITION_PRICE_CURRENT) >= priceActivation
         )
            ModifyStopLossFromPositionBuy(ticket, newStopLoss);

         // If the position is a sell position and the current price is less than or equal to the price activation, modify the stop loss
         if(
            PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL &&
            PositionGetDouble(POSITION_PRICE_CURRENT) <= priceActivation
         )
            ModifyStopLossFromPositionSell(ticket, newStopLoss);
        }
     }
  };
//+------------------------------------------------------------------+
