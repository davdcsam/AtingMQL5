//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+
#include "Remove.mqh"

//+------------------------------------------------------------------+
/**
 * @class RemOrderByLocationPrice
 * @brief Class to handle the removal of orders based on their location relative to a middle value.
 */
class RemOrderByLocationPrice : public Remove
  {
private:
   /**
    * @brief Arrays to store order tickets for orders above and below the middle value.
    */
   CArrayLong        upper_order_tickets;
   CArrayLong        lower_order_tickets;

   /**
    * @brief Middle value used to categorize orders.
    */
   double            middle;

   /**
    * @brief Flag to indicate whether the verification and removal should be performed.
    */
   bool              internal_flag;

public:
   /**
    * @brief Default constructor for the RemOrderByLocationPrice class.
    */
                     RemOrderByLocationPrice(void) : Remove() {};

   /**
    * @brief Updates attributes for the RemOrderByLocationPrice class.
    * @param upper_line_arg Upper boundary for categorizing orders.
    * @param lower_line_arg Lower boundary for categorizing orders.
    * @param magic_arg Magic number for trade operations.
    * @param symbol_arg Trading symbol.
    */
   void              UpdateAtr(double upper_line_arg, double lower_line_arg, ulong magic_arg, string symbol_arg);

   /**
    * @brief Updates the order arrays based on their open prices relative to the middle value.
    */
   void              UpdateOrders();

   /**
    * @brief Verifies positions and removes orders from the opposite array based on the position location.
    */
   void              TriggerPositionNotInArray();
  };

//+------------------------------------------------------------------+
void RemOrderByLocationPrice::UpdateAtr(double upper_line_arg, double lower_line_arg, ulong magic_arg, string symbol_arg)
  {
   middle = (upper_line_arg + lower_line_arg) / 2;
   magic = magic_arg;
   symbol = symbol_arg;
   UpdateAtrToDetect(magic_arg, symbol_arg);
  }

//+------------------------------------------------------------------+
void RemOrderByLocationPrice::UpdateOrders()
  {
// Clear the order tickets arrays
   detectOrders.DeleteEntities();
   upper_order_tickets.Shutdown();
   lower_order_tickets.Shutdown();

   if(!detectOrders.UpdateEntities())
      return;

   CArrayLong entities;
   detectOrders.GetEntities(entities);

// Loop through each order
   for(int i = 0; i < entities.Total(); i++)
     {
      // Get the ticket for the order
      ulong ticket = entities.At(i);

      if(!OrderSelect(ticket))
         return;

      // Categorize the order based on its open price
      if(OrderGetDouble(ORDER_PRICE_OPEN) > middle)
         upper_order_tickets.Add(ticket);
      else
         lower_order_tickets.Add(ticket);

      // Set the internal flag to true
      internal_flag = true;
     }
  }

//+------------------------------------------------------------------+
void RemOrderByLocationPrice::TriggerPositionNotInArray()
  {
// If the internal flag is not set, return
   if(!internal_flag)
      return;

   int positions_total = PositionsTotal();
   if(positions_total == 0)
      return;

// Loop through each position
   for(int i = 0; i < positions_total; i++)
     {
      // Get the ticket for the position
      ulong ticket = PositionGetTicket(i);

      // If the position is not valid, skip it
      if(!detectPositions.IsValid(ticket))
         continue;

      // Check if the position ticket is in the upper or lower order tickets array
      if(upper_order_tickets.SearchLinear(ticket) != -1)
        {
         // Remove orders from the lower order tickets
         if(RemoveOrdersFromCArray(lower_order_tickets))
            PrintFormat("Removed orders in lower_order_tickets for position ticket: %I64d", ticket);
         else
            PrintFormat("Failed removing orders in lower_order_tickets for position ticket: %I64d. Err: %d", ticket, GetLastError());

         // Reset the internal flag
         internal_flag = false;
        }

      if(lower_order_tickets.SearchLinear(ticket) != -1)
        {
         // Remove orders from the upper order tickets
         if(RemoveOrdersFromCArray(upper_order_tickets))
            PrintFormat("Removed orders in upper_order_tickets for position ticket: %I64d", ticket);
         else
            PrintFormat("Failed removing orders in upper_order_tickets for position ticket: %I64d. Err: %d", ticket, GetLastError());

         // Reset the internal flag
         internal_flag = false;
        }
     }
  }
//+------------------------------------------------------------------+
