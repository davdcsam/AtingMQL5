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
   void Run(ENUM_POSITION_TYPE type);
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
      if(!detectOrders.IsValidOrder(ticket))
         continue;

      // Add the ticket to the order tickets array
      detectOrders.orderTickets.Add(ticket);

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
      internal_flag_buy = true;
      internal_flag_sell = true;
     }
  }

//+------------------------------------------------------------------+
void RemOrderByType::ProcessOrder(ulong &ticket)
  {
   if(sellTickets.SearchLinear(ticket) != -1)
     {
      if(mode == MODE_REMOVE_SAME_TYPE)
        {
         HandleOrder(ticket, "sellTickets", sellTickets, buyTickets);
         internal_flag_sell = false;
         return;
        }

      HandleOrder(ticket, "buyTickets", sellTickets, buyTickets);
      internal_flag_sell = false;
     }

   if(buyTickets.SearchLinear(ticket) != -1)
     {
      if(mode == MODE_REMOVE_SAME_TYPE)
        {
         HandleOrder(ticket, "buyTickets", buyTickets, sellTickets);
         internal_flag_buy = false;
         return;
        }

      HandleOrder(ticket, "sellTickets", buyTickets, sellTickets);
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
void RemOrderByType::Run(ENUM_POSITION_TYPE type)
  {
   UpdateOrders();

   if(RemoveOrdersFromCArray(type == POSITION_TYPE_BUY ? buyTickets : sellTickets))
      PrintFormat("Removing orders type %s", EnumToString(type));
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| RemoveByOrderType Legacy                                         |
//+------------------------------------------------------------------+
class RemoveByOrderType : public Remove
  {
public:
   enum ENUM_MODES
     {
      MODE_REMOVE_SAME_TYPE, // Remove the same type
      MODE_REMOVE_OPPOSITE_TYPE//
     };
private:
   // Use to disable VerifyPositionAndRemoveOppositeArray method
   bool              internal_flag_buy;
   bool              internal_flag_sell;
   ENUM_MODES        mode;

protected:
   void              ProcessOrder(ulong &ticket)
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
         internal_flag_sell = false;
        }
     }

   void              HandleOrder(ulong ticket, string orderType, CArrayLong &primaryTickets, CArrayLong &secondaryTickets)
     {
      UpdateOrders();

      if(!RemoveOrdersFromCArray(mode == MODE_REMOVE_SAME_TYPE ? primaryTickets : secondaryTickets))
        {
         PrintFormat("Failed removing orders in %s. Err: %d", GetLastError(), orderType);
         return;
        }

      PrintFormat("Removed orders in %s.", orderType);
     }

public:
                     RemoveByOrderType(ENUM_MODES mode_arg = NULL): Remove()
     {
      mode = mode_arg == NULL ? MODE_REMOVE_SAME_TYPE : mode_arg;
     };

   // Arrays to store order tickets
   CArrayLong        buy_order_tickets;
   CArrayLong        sell_order_tickets;

   // Function to update orders by order type
   void              UpdateOrders()
     {
      // Shutdown the order tickets arrays
      detectOrders.orderTickets.Shutdown();
      buy_order_tickets.Shutdown();
      sell_order_tickets.Shutdown();

      int orders_total = OrdersTotal();
      if(!orders_total)
        {
         return;
        }


      // Loop through each order
      for(int i=0; i < orders_total; i++)
        {
         // Get the ticket for the order
         ulong ticket = OrderGetTicket(i);

         // If the order is not valid, continue to the next order
         if(!detectOrders.IsValidOrder(ticket))
            continue;

         // Add the ticket to the order tickets array
         detectOrders.orderTickets.Add(ticket);

         // Filter the orders to buys and sells
         switch((int)OrderGetInteger(ORDER_TYPE))
           {
            case ORDER_TYPE_BUY_STOP:
               buy_order_tickets.Add(ticket);
               break;
            case ORDER_TYPE_SELL_LIMIT:
               sell_order_tickets.Add(ticket);
               break;
            case ORDER_TYPE_BUY_LIMIT:
               buy_order_tickets.Add(ticket);
               break;
            case ORDER_TYPE_SELL_STOP:
               sell_order_tickets.Add(ticket);
               break;
           }

         // Set the internal flag to true
         internal_flag_buy = true;
         internal_flag_sell = true;
        }
     }

   // Function to verify position and remove the same extra orders type
   void              VerifyPositionAndRemove()
     {
      // If neither internal flag is set, return early
      if(!internal_flag_buy && !internal_flag_sell)
         return;

      int positions_total = PositionsTotal();
      if(positions_total == 0)
         return;

      // Loop through each position
      for(int i = 0; i < positions_total; i++)
        {
         ulong ticket = PositionGetTicket(i);

         // If the position is not valid, continue to the next position
         if(!detectPositions.IsValidPosition(ticket))
            continue;

         ProcessOrder(ticket);
        }
     }
  };
//+------------------------------------------------------------------+
