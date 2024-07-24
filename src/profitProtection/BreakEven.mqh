//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+
#include "ProfitProtection.mqh"

//+------------------------------------------------------------------+
/**
 * @class BreakEvenStages
 * @brief Class to handle the stages of moving stop loss to break-even for multiple positions.
 */
class BreakEvenStages : public ProfitProtection
  {
private:
   CArrayLong        positionTickets; ///< Array of position tickets

public:
   /**
    * @brief Default constructor for the BreakEvenStages class.
    */
                     BreakEvenStages(void) {}

   /**
    * @brief Destructor for the BreakEvenStages class.
    */
                    ~BreakEvenStages(void) {}

   /**
    * @brief Updates the array of position tickets based on the current positions.
    * @return True if tickets are successfully updated, otherwise false.
    */
   bool              UpdateTickets();

   /**
    * @brief Verifies and updates stop loss for all tracked positions.
    */
   void              Verify();
  };

//+------------------------------------------------------------------+
bool BreakEvenStages::UpdateTickets()
  {
// Get the total number of positions
   int totalPositions = PositionsTotal();

// If there are no positions, return false
   if(totalPositions == 0)
      return false;

// Loop through all positions
   for(int i = 0; i < totalPositions; i++)
     {
      // Get the ticket number for the position
      ulong ticket = PositionGetTicket(i);

      // If the position is not valid, continue to the next position
      if(!detectPositions.IsValidPosition(ticket))
         continue;

      positionTickets.Add(ticket);
     }

   return positionTickets.Total() > 0;
  }
//+------------------------------------------------------------------+
void BreakEvenStages::Verify()
  {
   if(positionTickets.Total() == 0)
      return;

   for(int i = 0; i < positionTickets.Total(); i++)
     {
      ulong positionTicket = positionTickets.At(i);

      if(!PositionSelectByTicket(positionTicket))
         continue;

      double priceActivation = GetActivationPrice(positionTicket);
      double newStopLoss = NormalizeDouble(
                              PositionGetDouble(POSITION_PRICE_OPEN) - (PositionGetDouble(POSITION_PRICE_OPEN) - PositionGetDouble(POSITION_TP)) * (deviationPercent / 100),
                              (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS)
                           );

      if(NormalizeDouble(PositionGetDouble(POSITION_PRICE_CURRENT), _Digits) == NormalizeDouble(priceActivation, _Digits))
        {
         positionTickets.Delete(positionTickets.SearchLinear(positionTicket));
         continue;
        }

      // If the position is a buy position and the current price is greater than or equal to the price activation, modify the stop loss
      if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY && PositionGetDouble(POSITION_PRICE_CURRENT) > priceActivation)
        {
         ModifyStopLossFromPositionBuy(positionTicket, newStopLoss);
         continue;
        }

      // If the position is a sell position and the current price is less than or equal to the price activation, modify the stop loss
      if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL && PositionGetDouble(POSITION_PRICE_CURRENT) < priceActivation)
        {
         ModifyStopLossFromPositionSell(positionTicket, newStopLoss);
         continue;
        }
     }
  }

//+------------------------------------------------------------------+
/**
 * @class BreakEven
 * @brief Class to handle the break-even adjustment of stop loss for positions.
 */
class BreakEven : public ProfitProtection
  {
public:
   /**
    * @brief Default constructor for the BreakEven class.
    */
                     BreakEven(void) {}

   /**
    * @brief Verifies and updates stop loss for all current positions.
    */
   void              Verify();
  };

//+------------------------------------------------------------------+
void BreakEven::Verify()
  {
// Get the total number of positions
   int totalPositions = PositionsTotal();

// If there are no positions, return
   if(totalPositions == 0)
      return;

// Loop through all positions
   for(int i = 0; i < totalPositions; i++)
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
      if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY && PositionGetDouble(POSITION_PRICE_CURRENT) >= priceActivation)
        {
         ModifyStopLossFromPositionBuy(ticket, newStopLoss);
        }

      // If the position is a sell position and the current price is less than or equal to the price activation, modify the stop loss
      if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL && PositionGetDouble(POSITION_PRICE_CURRENT) <= priceActivation)
        {
         ModifyStopLossFromPositionSell(ticket, newStopLoss);
        }
     }
  }
//+------------------------------------------------------------------+
