//+------------------------------------------------------------------+
//|                                                 AutomatedTrading |
//|                                         Copyright 2024, davdcsam |
//|                                      https://github.com/davdcsam |
//+------------------------------------------------------------------+

#include "Remove.mqh"

//+------------------------------------------------------------------+
//| RemoveByLocationPrice                                            |
//+------------------------------------------------------------------+
class RemoveByLocationPrice : public Remove
  {
private:
   // Arrays to store order tickets
   CArrayLong        upper_order_tickets;
   CArrayLong        lower_order_tickets;

   // Variable to store middle value
   double            middle;

   // Use to activate VerifyPositionAndRemoveOppositeArray method
   bool              internal_flag;
public:
                     RemoveByLocationPrice(void) : Remove() {};

   // Function to update attributes
   void              UpdateAtr(double upper_line_arg, double lower_line_arg, ulong magic_arg, string symbol_arg)
     {
      middle = (upper_line_arg + lower_line_arg) / 2;
      magic = magic_arg;
      symbol = symbol_arg;
      UpdateAtrToDetect(magic_arg, symbol_arg);
     }

   // Function to update orders
   void              UpdateOrders()
     {
      // Shutdown the order tickets arrays
      detectOrders.orderTickets.Shutdown();
      upper_order_tickets.Shutdown();
      lower_order_tickets.Shutdown();

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

         // If the open price of the order is greater than the middle value, add the ticket to the upper order tickets array
         // Otherwise, add the ticket to the lower order tickets array
         if(OrderGetDouble(ORDER_PRICE_OPEN) > middle)
            upper_order_tickets.Add(ticket);
         else
            lower_order_tickets.Add(ticket);

         // Set the internal flag to true
         internal_flag = true;
        }
     }

   // Function to verify position and remove opposite array
   void              VerifyPositionAndRemove()
     {
      // If the internal flag is not set, return
      if(!internal_flag)
         return;

      int positions_total = PositionsTotal();
      if(!positions_total)
        {
         return;
        }

      // Loop through each position
      for(int i = 0; i < positions_total; i++)
        {
         // Get the ticket for the position
         ulong ticket = PositionGetTicket(i);

         // If the position is not valid, continue to the next position
         if(!detectPositions.IsValidPosition(ticket))
            continue;

         // If the ticket is found in the upper order tickets
         if(upper_order_tickets.SearchLinear(ticket) != -1)
           {
            // If the orders are removed from the lower order tickets, print that they were removed
            if(RemoveOrdersFromCArray(lower_order_tickets))
               PrintFormat("Removed orders in lower_order_tickets.", ticket);
            else
               // If the orders are not removed, print that the removal failed
               PrintFormat("Failed removing orders in lower_order_tickers. Err: ", GetLastError());

            // Set the internal flag to false
            internal_flag = false;
           }

         // If the ticket is found in the lower order tickets
         if(lower_order_tickets.SearchLinear(ticket) != -1)
           {
            // If the orders are removed from the upper order tickets, print that they were removed
            if(RemoveOrdersFromCArray(upper_order_tickets))
               PrintFormat("Removed orders in upper_order_tickets.", ticket);
            else
               // If the orders are not removed, print that the removal failed
               PrintFormat("Failed removing orders in upper_order_tickets. Err: ", GetLastError());

            // Set the internal flag to false
            internal_flag = false;
           }
        }
     }
  };
//+------------------------------------------------------------------+
