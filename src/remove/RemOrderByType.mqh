//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+
#include "Remove.mqh"
#include "../detect/IDetectEntity.mqh"

//+------------------------------------------------------------------+
/**
 * @class RemOrderByType
 * @brief Class to handle the removal of orders based on their type relative to positions.
 */
class RemOrderByType : public Remove
  {
public:
   /**
    * @enum ENUM_MODES
    * @brief Enumeration to specify the mode of removal.
    */
   enum ENUM_MODES
     {
      MODE_REMOVE_SAME_TYPE,   /**< Remove orders of the same type as the position. */
      MODE_REMOVE_OPPOSITE_TYPE /**< Remove orders of the opposite type of the position. */
     };

private:
   /**
    * @brief Flags to indicate whether there are orders of a specific type to be removed.
    */
   bool              internalFlagBuy;
   bool              internalFlagSell;

   /**
    * @brief Mode of removal.
    */
   ENUM_MODES        modeRemoval;

protected:
   /**
    * @brief Processes an order based on its ticket and mode.
    * @param ticket Ticket number of the order.
    */
   void              ProcessOrder(ulong &ticket);

   /**
    * @brief Handles the removal of orders based on the specified type.
    * @param ticket Ticket number of the order to be handled.
    * @param orderType Type of order to be removed.
    * @param primaryTickets Array containing primary tickets for removal.
    * @param secondaryTickets Array containing secondary tickets.
    */
   void              HandleOrder(ulong ticket, string orderType, CArrayLong &primaryTickets, CArrayLong &secondaryTickets);

public:

   /**
    * @brief Default Constructor
    */
                     RemOrderByType(void);

   /**
    * @brief Constructor for the RemOrderByType class.
    * @param mode_arg Mode of removal.
    */
                     RemOrderByType(ENUM_MODES mode_arg, IDetectEntity* dOrders, IDetectEntity* dPositions);

   /**
    * @brief Arrays to store order tickets for buy and sell orders.
    */
   CArrayLong        buyTickets;
   CArrayLong        sellTickets;

   /**
    * @brief Updates the order arrays based on their types.
    */
   void              UpdateOrders();

   /**
    * @brief Verifies positions and removes orders based on their type.
    */
   void              TriggerPositionNotInArray();


   /**
    * @brief Remove order by type
    */
   void              Run(ENUM_POSITION_TYPE type);
  };
//+------------------------------------------------------------------+
