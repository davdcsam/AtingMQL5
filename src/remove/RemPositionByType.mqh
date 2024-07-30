//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+
#include "Remove.mqh"

//+------------------------------------------------------------------+
/**
 * @class RemPositionByType
 * @brief Class to handle the removal of positions based on their type relative to positions.
 */
class RemPositionByType : public Remove
  {
public:
   /**
    * @enum ENUM_MODES
    * @brief Enumeration to specify the mode of removal.
    */
   enum ENUM_MODES
     {
      MODE_REMOVE_SAME_TYPE,   /**< Remove positions of the same type as the position. */
      MODE_REMOVE_OPPOSITE_TYPE /**< Remove positions of the opposite type of the position. */
     };

private:
   /**
    * @brief Flags to indicate whether there are positions of a specific type to be removed.
    */
   bool              internalFlagBuy;
   bool              internalFlagSell;

   /**
    * @brief Mode of removal.
    */
   ENUM_MODES        mode;

protected:
   /**
    * @brief Processes an position based on its ticket and mode.
    * @param ticket Ticket number of the position.
    */
   void              ProcessPosition(ulong &ticket);

   /**
    * @brief Handles the removal of positions based on the specified type.
    * @param ticket Ticket number of the position to be handled.
    * @param positionType Type of position to be removed.
    * @param primaryTickets Array containing primary tickets for removal.
    * @param secondaryTickets Array containing secondary tickets.
    */
   void              HandlerPosition(ulong ticket, string positionType, CArrayLong &primaryTickets, CArrayLong &secondaryTickets);

public:
   /**
    * @brief Constructor for the RemPositionByType class.
    * @param mode_arg Mode of removal.
    */
                     RemPositionByType(ENUM_MODES mode_arg = MODE_REMOVE_SAME_TYPE);

   /**
    * @brief Arrays to store position tickets for buy and sell positions.
    */
   CArrayLong        buyTickets;
   CArrayLong        sellTickets;

   /**
    * @brief Updates the position arrays based on their types.
    */
   void              UpdatePositions();

   /**
    * @brief Verifies positions and removes positions based on their type.
    */
   void              TriggerPositionNotInArray();

   /**
    * @brief Remove positions by type
    */
   void              Run(ENUM_POSITION_TYPE type);
  };

//+------------------------------------------------------------------+
RemPositionByType::RemPositionByType(ENUM_MODES mode_arg)
   : Remove(), mode(mode_arg)
  {
  }

//+------------------------------------------------------------------+
void RemPositionByType::UpdatePositions()
  {
// Clear the position tickets arrays
   detectPositions.positionsTickets.Shutdown();
   buyTickets.Shutdown();
   sellTickets.Shutdown();

   int positions_total = PositionsTotal();
   if(positions_total == 0)
      return;

// Loop through each position
   for(int i = 0; i < positions_total; i++)
     {
      // Get the ticket for the position
      ulong ticket = PositionGetTicket(i);

      // If the position is not valid, skip it
      if(!detectPositions.IsValidPosition(ticket))
         continue;

      // Add the ticket to the position tickets array
      detectPositions.positionsTickets.Add(ticket);

      // Filter the positions to buys and sells
      switch((int)PositionGetInteger(POSITION_TYPE))
        {
         case POSITION_TYPE_BUY:
            buyTickets.Add(ticket);
            break;
         case POSITION_TYPE_SELL:
            sellTickets.Add(ticket);
            break;
        }

      // Set the internal flags
      internalFlagBuy = true;
      internalFlagSell = true;
     }
  }

//+------------------------------------------------------------------+
void RemPositionByType::ProcessPosition(ulong &ticket)
  {
   if(sellTickets.SearchLinear(ticket) != -1)
     {
      if(mode == MODE_REMOVE_SAME_TYPE)
        {
         HandlerPosition(ticket, "sellTickets", sellTickets, buyTickets);
         internalFlagSell = false;
         return;
        }

      HandlerPosition(ticket, "buyTickets", sellTickets, buyTickets);
      internalFlagSell = false;
     }

   if(buyTickets.SearchLinear(ticket) != -1)
     {
      if(mode == MODE_REMOVE_SAME_TYPE)
        {
         HandlerPosition(ticket, "buyTickets", buyTickets, sellTickets);
         internalFlagBuy = false;
         return;
        }

      HandlerPosition(ticket, "sellTickets", buyTickets, sellTickets);
      internalFlagBuy = false;
     }
  }

//+------------------------------------------------------------------+
void RemPositionByType::HandlerPosition(ulong ticket, string positionType, CArrayLong &primaryTickets, CArrayLong &secondaryTickets)
  {
   UpdatePositions();

   if(!RemovePositionsFromCArray(mode == MODE_REMOVE_SAME_TYPE ? primaryTickets : secondaryTickets))
     {
      PrintFormat("Failed removing positions in %s. Err: %d", positionType, GetLastError());
      return;
     }

   PrintFormat("Removed positions in %s.", positionType);
  }

//+------------------------------------------------------------------+
void RemPositionByType::TriggerPositionNotInArray()
  {
// If neither internal flag is set, return
   if(!internalFlagBuy && !internalFlagSell)
      return;

   int positions_total = PositionsTotal();
   if(positions_total == 0)
      return;

// Loop through each position
   for(int i = 0; i < positions_total; i++)
     {
      ulong ticket = PositionGetTicket(i);

      // If the position is not valid, skip it
      if(!detectPositions.IsValidPosition(ticket))
         continue;

      ProcessPosition(ticket);
     }
  }

//+------------------------------------------------------------------+
void RemPositionByType::Run(ENUM_POSITION_TYPE type)
  {
   UpdatePositions();

   if(RemovePositionsFromCArray(type == POSITION_TYPE_BUY ? buyTickets : sellTickets))
      PrintFormat("Removing position type %s", EnumToString(type));
  }
//+------------------------------------------------------------------+
