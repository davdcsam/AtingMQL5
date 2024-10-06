//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+
#include "ProfitProtection.mq5"

//+------------------------------------------------------------------+
/**
 * @class TrailingStop
 * @brief Class to handle trailing stop for positions.
 */
class TrailingStop : public ProfitProtection
  {
public:

                     TrailingStop(DetectPositions* dP) : ProfitProtection(dP) {}

                    ~TrailingStop(void) {};

   /**
    * @brief Verifies and updates stop loss for all current positions based on trailing stop logic.
    */
   void              Run()
     {
      // Get the total number of positions valid
      this.detectPositions.UpdateEntities();
      CArrayLong entities = this.detectPositions.GetEntities();
      // If there are no positions, return
      if(entities.Total() == 0)
         return;

      // Loop through all positions
      for(int i = 0; i < entities.Total(); i++)
        {
         // Get the ticket number for the position
         ulong ticket = entities.At(i);

         // If the position is not valid, continue to the next position
         if(!detectPositions.IsValid(ticket))
            continue;

         if(!PositionSelectByTicket(ticket))
            continue;

         double priceActivation = this.GetActivationPrice(ticket);
         double newStopLoss = this.GetDeviationPriceFromCurrent(ticket);

         // If the position is a buy position and the current price is greater than or equal to the price activation, modify the stop loss
         if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY && PositionGetDouble(POSITION_PRICE_CURRENT) >= priceActivation)
           {
            ModifyStopLossFromPositionBuy(ticket, newStopLoss);
            continue;
           }

         // If the position is a sell position and the current price is less than or equal to the price activation, modify the stop loss
         if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL && PositionGetDouble(POSITION_PRICE_CURRENT) <= priceActivation)
           {
            ModifyStopLossFromPositionSell(ticket, newStopLoss);
            continue;
           }
        }
     }
  };
