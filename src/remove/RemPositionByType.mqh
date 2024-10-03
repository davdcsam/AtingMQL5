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
                     RemPositionByType(IDetectEntity* dOrders, IDetectEntity* dPositions, ENUM_MODES mode_arg = MODE_REMOVE_SAME_TYPE);

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
