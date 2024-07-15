//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+

// Include the ArrayLong library from the Arrays directory
#include <Arrays/ArrayLong.mqh>

// Class to detect orders
class DetectOrders
  {
private:
   // Symbol for the order
   string            symbol;

   // Magic number for the order
   ulong             magic;

public:
   // Array to store the order tickets
   CArrayLong        orderTickets;

   // Default constructor for the DetectOrders class
                     DetectOrders(void) {};

   // Function to update the symbol and magic number for the order
   void              UpdateAtr(string symbol_arg, ulong magic_arg)
     {
      // Set the symbol and magic number for the order
      symbol = symbol_arg;
      magic = magic_arg;
     };

   // Function to check if an order is valid
   bool              IsValidOrder(ulong ticket)
     {
      // Return true if the order is selected and the magic number and symbol match, otherwise return false
      return(
               OrderSelect(ticket) &&
               OrderGetInteger(ORDER_MAGIC) == magic &&
               OrderGetString(ORDER_SYMBOL) == symbol
            );
     }

   // Function to update the orders
   bool              UpdateOrders()
     {
      // Shutdown the order tickets array
      orderTickets.Shutdown();

      // Get the total number of orders
      int totalOrders = OrdersTotal();

      // If there are no orders, return false
      if(!totalOrders)
         return(false);

      // Loop through each order
      for(int i=0; i<totalOrders; i++)
        {
         // Get the ticket for the order
         ulong ticket = OrderGetTicket(i);

         // If the order is not selected, continue to the next order
         if(!OrderSelect(ticket))
            continue;

         // If the order is not valid, continue to the next order
         if(!IsValidOrder(ticket))
            continue;

         // Add the ticket to the order tickets array
         orderTickets.Add(ticket);
        }

      // If there are no order tickets, return false
      if(!orderTickets.Total())
         return(false);

      // If there are order tickets, return true
      return(true);
     }
  };
//+------------------------------------------------------------------+
