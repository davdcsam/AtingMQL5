//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+

#include "Remove.mqh"

//+------------------------------------------------------------------+
//| RemoveByOrderType                                                |
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
