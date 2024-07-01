//+------------------------------------------------------------------+
//|                                                 AutomatedTrading |
//|                                         Copyright 2024, davdcsam |
//|                                      https://github.com/davdcsam |
//+------------------------------------------------------------------+

#include "ProfitProtection.mqh"

//+------------------------------------------------------------------+
//| BreakEven Stages                                                 |
//+------------------------------------------------------------------+
class BreakEvenStages : public ProfitProtection
  {
private:
   CArrayLong        positionTickets;
public:
                     BreakEvenStages(void) {};
                    ~BreakEvenStages(void) {};

   bool              UpdateTickets()
     {
      // Get the total number of positions
      int totalPositions = PositionsTotal();

      // If there are no positions, return
      if(!totalPositions)
         return false;

      // Loop through all positions
      for(int i=0; i<totalPositions; i++)
        {
         // Get the ticket number for the position
         ulong ticket = PositionGetTicket(i);

         // If the position is not valid, continue to the next position
         if(!detectPositions.IsValidPosition(ticket))
            continue;

         positionTickets.Add(ticket);
        }

      if(!positionTickets.Total())
         return false;

      return true;
     }

   void              Verify()
     {

      if(!positionTickets.Total())
         return;

      for(int i=0;i<positionTickets.Total();i++)
        {
         ulong positionTicket = positionTickets.At(i);

         if(!PositionSelectByTicket(positionTicket))
            continue;

         double priceActivation = GetActivationPrice(positionTicket);
         double newStopLoss = NormalizeDouble(
                                 PositionGetDouble(POSITION_PRICE_OPEN) - (PositionGetDouble(POSITION_PRICE_OPEN) - PositionGetDouble(POSITION_TP)) * (deviationPercent / 100),
                                 (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS)
                              );

         if(
            NormalizeDouble(PositionGetDouble(POSITION_PRICE_CURRENT), _Digits) == NormalizeDouble(priceActivation, _Digits)
         )
           {
            positionTickets.Delete(positionTickets.SearchLinear(positionTicket));
            continue;
           }

         // If the position is a buy position and the current price is greater than or equal to the price activation, modify the stop loss
         if(
            PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY &&
            PositionGetDouble(POSITION_PRICE_CURRENT) > priceActivation
         )
           {
            ModifyStopLossFromPositionBuy(positionTicket, newStopLoss);
            continue;
           }

         // If the position is a sell position and the current price is less than or equal to the price activation, modify the stop loss
         if(
            PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL &&
            PositionGetDouble(POSITION_PRICE_CURRENT) < priceActivation
         )
           {
            ModifyStopLossFromPositionSell(positionTicket, newStopLoss);
            continue;
           }
        }
     }

  };

//+------------------------------------------------------------------+
//| BreakEven                                                        |
//+------------------------------------------------------------------+
class BreakEven : public ProfitProtection
  {
public:
   // Constructor for BreakEven class
                     BreakEven(void) {}

   // Method to verify the positions
   void              Verify()
     {
      // Get the total number of positions
      int totalPositions = PositionsTotal();

      // If there are no positions, return
      if(!totalPositions)
         return;

      // Loop through all positions
      for(int i=0; i<totalPositions; i++)
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
                                 PositionGetDouble(POSITION_PRICE_OPEN) - (PositionGetDouble(POSITION_PRICE_OPEN) - PositionGetDouble(POSITION_TP)) * (deviationPercent / 100),
                                 (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS)
                              );

         // If the position is a buy position and the current price is greater than or equal to the price activation, modify the stop loss
         if(
            PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY &&
            PositionGetDouble(POSITION_PRICE_CURRENT) >= priceActivation
         )
           {
            ModifyStopLossFromPositionBuy(ticket, newStopLoss);
           }

         // If the position is a sell position and the current price is less than or equal to the price activation, modify the stop loss
         if(
            PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL &&
            PositionGetDouble(POSITION_PRICE_CURRENT) <= priceActivation
         )
           {
            ModifyStopLossFromPositionSell(ticket, newStopLoss);
           }
        }
     }
  };
//+------------------------------------------------------------------+
