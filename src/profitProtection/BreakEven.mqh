//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+
#include "ProfitProtection.mq5"

//+------------------------------------------------------------------+
/**
 * @class BreakEvenStages
 * @brief Class to handle the stages of moving stop loss to break-even for multiple positions.
 */
class BreakEvenStages : ProfitProtection
  {
public:
                     BreakEvenStages(DetectPositions* dP) : ProfitProtection(dP) {}

   /**
    * @brief Destructor for the BreakEvenStages class.
    */
                    ~BreakEvenStages(void);

   /**
    * @brief Updates the array of position tickets based on the current positions.
    * @return True if tickets are successfully updated, otherwise false.
    */
   bool              UpdateTickets()
     {   return      this.detectPositions.UpdateEntities(); }

   /**
    * @brief Verifies and updates stop loss for all tracked positions.
    */
   void              Run()
     {
      CArrayLong entities = this.detectPositions.GetEntities();
      if(entities.Total() == 0)
         return;

      for(int i = 0; i < entities.Total(); i++)
        {
         ulong ticket = entities.At(i);

         if(!PositionSelectByTicket(ticket))
            continue;

         double priceActivation = this.GetActivationPrice(ticket);
         double newStopLoss = this.GetDeviationPriceFromOpen(ticket);

         // If the position is a buy position and the current price is greater than or equal to the price activation, modify the stop loss
         if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY && PositionGetDouble(POSITION_PRICE_CURRENT) > priceActivation)
           {
            this.ModifyStopLossFromPositionBuy(ticket, newStopLoss);
            continue;
           }

         // If the position is a sell position and the current price is less than or equal to the price activation, modify the stop loss
         if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL && PositionGetDouble(POSITION_PRICE_CURRENT) < priceActivation)
           {
            this.ModifyStopLossFromPositionSell(ticket, newStopLoss);
            continue;
           }
        }
     }
  };

//+------------------------------------------------------------------+
/**
 * @class BreakEven
 * @brief Class to handle the break-even adjustment of stop loss for positions.
 */
class BreakEven : public ProfitProtection
  {
public:
                     BreakEven(DetectPositions* dP) : ProfitProtection(dP) {}

   /**
    * @brief Destructor for the BreakEven class.
    */
                    ~BreakEven(void) {}

   /**
    * @brief Verifies and updates stop loss for all current positions.
    */
   void              Run()
     {
      this.detectPositions.UpdateEntities();
      CArrayLong entities = this.detectPositions.GetEntities();
      if(entities.Total() == 0)
         return;

      // Loop through all positions
      for(int i = 0; i < entities.Total(); i++)
        {
         ulong ticket = entities.At(i);

         if(!PositionSelectByTicket(ticket))
            continue;

         double priceActivation = this.GetActivationPrice(ticket);
         double newStopLoss = this.GetDeviationPriceFromOpen(ticket);

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
//+------------------------------------------------------------------+
