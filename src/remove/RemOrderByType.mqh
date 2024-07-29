//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+
#include "Remove.mqh"

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
   bool              internal_flag_buy;
   bool              internal_flag_sell;

   /**
    * @brief Mode of removal.
    */
   ENUM_MODES        mode;

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
    * @brief Constructor for the RemOrderByType class.
    * @param mode_arg Mode of removal.
    */
                     RemOrderByType(ENUM_MODES mode_arg = MODE_REMOVE_SAME_TYPE);

   /**
    * @brief Arrays to store order tickets for buy and sell orders.
    */
   CArrayLong        buy_order_tickets;
   CArrayLong        sell_order_tickets;

   /**
    * @brief Updates the order arrays based on their types.
    */
   void              UpdateOrders();

   /**
    * @brief Verifies positions and removes orders based on their type.
    */
   void              TriggerPositionNotInArray();
  };

//+------------------------------------------------------------------+
RemOrderByType::RemOrderByType(ENUM_MODES mode_arg)
   : Remove(), mode(mode_arg)
  {
  }

//+------------------------------------------------------------------+
void RemOrderByType::UpdateOrders()
  {
// Clear the order tickets arrays
   detectOrders.orderTickets.Shutdown();
   buy_order_tickets.Shutdown();
   sell_order_tickets.Shutdown();

   int orders_total = OrdersTotal();
   if(orders_total == 0)
      return;

// Loop through each order
   for(int i = 0; i < orders_total; i++)
     {
      // Get the ticket for the order
      ulong ticket = OrderGetTicket(i);

      // If the order is not valid, skip it
      if(!detectOrders.IsValidOrder(ticket))
         continue;

      // Add the ticket to the order tickets array
      detectOrders.orderTickets.Add(ticket);

      // Filter the orders to buys and sells
      switch((int)OrderGetInteger(ORDER_TYPE))
        {
         case ORDER_TYPE_BUY_STOP:
         case ORDER_TYPE_BUY_LIMIT:
            buy_order_tickets.Add(ticket);
            break;
         case ORDER_TYPE_SELL_LIMIT:
         case ORDER_TYPE_SELL_STOP:
            sell_order_tickets.Add(ticket);
            break;
        }

      // Set the internal flags
      internal_flag_buy = true;
      internal_flag_sell = true;
     }
  }

//+------------------------------------------------------------------+
void RemOrderByType::ProcessOrder(ulong &ticket)
  {
   if(sell_order_tickets.SearchLinear(ticket) != -1)
     {
      if(mode == MODE_REMOVE_SAME_TYPE)
        {
         HandleOrder(ticket, "sell_order_tickets", sell_order_tickets, buy_order_tickets);
         internal_flag_sell = false;
         return;
        }

      HandleOrder(ticket, "buy_order_tickets", sell_order_tickets, buy_order_tickets);
      internal_flag_sell = false;
     }

   if(buy_order_tickets.SearchLinear(ticket) != -1)
     {
      if(mode == MODE_REMOVE_SAME_TYPE)
        {
         HandleOrder(ticket, "buy_order_tickets", buy_order_tickets, sell_order_tickets);
         internal_flag_buy = false;
         return;
        }

      HandleOrder(ticket, "sell_order_tickets", buy_order_tickets, sell_order_tickets);
      internal_flag_buy = false;
     }
  }

//+------------------------------------------------------------------+
void RemOrderByType::HandleOrder(ulong ticket, string orderType, CArrayLong &primaryTickets, CArrayLong &secondaryTickets)
  {
   UpdateOrders();

   if(!RemoveOrdersFromCArray(mode == MODE_REMOVE_SAME_TYPE ? primaryTickets : secondaryTickets))
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
   if(!internal_flag_buy && !internal_flag_sell)
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

      ProcessOrder(ticket);
     }
  }
//+------------------------------------------------------------------+
