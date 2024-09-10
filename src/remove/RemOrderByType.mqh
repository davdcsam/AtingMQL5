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
RemOrderByType::RemOrderByType(void)
   : Remove(), modeRemoval(MODE_REMOVE_OPPOSITE_TYPE)
  {
  }

//+------------------------------------------------------------------+
RemOrderByType::RemOrderByType(ENUM_MODES mode_arg, IDetectEntity* dOrders, IDetectEntity* dPositions)
   : Remove(dOrders, dPositions), modeRemoval(mode_arg)
  {
  }

//+------------------------------------------------------------------+
void RemOrderByType::UpdateOrders()
  {
   buyTickets.Shutdown();
   sellTickets.Shutdown();

   int orders_total = OrdersTotal();
   if(orders_total == 0)
      return;

// Loop through each order
   for(int i = 0; i < orders_total; i++)
     {
      // Get the ticket for the order
      ulong ticket = OrderGetTicket(i);

      // If the order is not valid, skip it
      if(!detectOrders.IsValid(ticket))
         continue;

      // Filter the orders to buys and sells
      switch((int)OrderGetInteger(ORDER_TYPE))
        {
         case ORDER_TYPE_BUY_STOP:
         case ORDER_TYPE_BUY_LIMIT:
            buyTickets.Add(ticket);
            break;
         case ORDER_TYPE_SELL_LIMIT:
         case ORDER_TYPE_SELL_STOP:
            sellTickets.Add(ticket);
            break;
        }

      // Set the internal flags
      internalFlagBuy = true;
      internalFlagSell = true;
     }
  }

//+------------------------------------------------------------------+
void RemOrderByType::ProcessOrder(ulong &ticket)
  {
   if(sellTickets.SearchLinear(ticket) != -1)
     {
      if(modeRemoval == MODE_REMOVE_SAME_TYPE)
        {
         HandleOrder(ticket, "sellTickets", sellTickets, buyTickets);
         internalFlagSell = false;
         return;
        }

      HandleOrder(ticket, "buyTickets", sellTickets, buyTickets);
      internalFlagSell = false;
     }

   if(buyTickets.SearchLinear(ticket) != -1)
     {
      if(modeRemoval == MODE_REMOVE_SAME_TYPE)
        {
         HandleOrder(ticket, "buyTickets", buyTickets, sellTickets);
         internalFlagBuy = false;
         return;
        }

      HandleOrder(ticket, "sellTickets", buyTickets, sellTickets);
      internalFlagBuy = false;
     }
  }

//+------------------------------------------------------------------+
void RemOrderByType::HandleOrder(ulong ticket, string orderType, CArrayLong &primaryTickets, CArrayLong &secondaryTickets)
  {
   UpdateOrders();

   for(int i=0;i<primaryTickets.Total();i++)
     {
     }

   if(!this.RemoveOrdersFromArray(modeRemoval == MODE_REMOVE_SAME_TYPE ? primaryTickets : secondaryTickets))
     {
      PrintFormat("Failed removing orders in %s. Err: %d", orderType, GetLastError());
      return;
     }

   PrintFormat("Removed orders in %s.", orderType);
  }

//+------------------------------------------------------------------+
void RemOrderByType::TriggerPositionNotInArray()
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
      if(!detectPositions.IsValid(ticket))
         continue;

      ProcessOrder(ticket);
     }
  }

//+------------------------------------------------------------------+
void RemOrderByType::Run(ENUM_POSITION_TYPE type)
  {
   this.UpdateOrders();

   if(this.RemoveOrdersFromArray(type == POSITION_TYPE_BUY ? buyTickets : sellTickets))
      PrintFormat("Removing orders type %s", EnumToString(type));
  }
//+------------------------------------------------------------------+
