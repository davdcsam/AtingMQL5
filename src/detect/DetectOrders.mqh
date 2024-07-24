//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+
#include <Arrays/ArrayLong.mqh>

//+------------------------------------------------------------------+
/**
 * @class DetectOrders
 * @brief Class to detect and manage orders.
 */
class DetectOrders
  {
private:
   /**
    * @brief Symbol for the order.
    */
   string            symbol;

   /**
    * @brief Magic number for the order.
    */
   ulong             magic;

public:
   /**
    * @brief Array to store the order tickets.
    */
   CArrayLong        orderTickets;

   /**
    * @brief Default constructor for the DetectOrders class.
    */
                     DetectOrders(void) {};

   /**
    * @brief Updates the symbol and magic number for the order.
    * @param symbol_arg Symbol for the order.
    * @param magic_arg Magic number for the order.
    */
   void              UpdateAtr(string symbol_arg, ulong magic_arg);

   /**
    * @brief Checks if an order is valid.
    * @param ticket Ticket number of the order.
    * @return True if the order is selected, and the magic number and symbol match; otherwise, false.
    */
   bool              IsValidOrder(ulong ticket);

   /**
    * @brief Updates the orders by collecting valid order tickets.
    * @return True if at least one valid order ticket is found; otherwise, false.
    */
   bool              UpdateOrders();
  };

//+------------------------------------------------------------------+
void DetectOrders::UpdateAtr(string symbol_arg, ulong magic_arg)
  {
   symbol = symbol_arg;
   magic = magic_arg;
  }

//+------------------------------------------------------------------+
bool DetectOrders::IsValidOrder(ulong ticket)
  {
   return(
            OrderSelect(ticket) &&
            OrderGetInteger(ORDER_MAGIC) == magic &&
            OrderGetString(ORDER_SYMBOL) == symbol
         );
  }

//+------------------------------------------------------------------+
bool DetectOrders::UpdateOrders()
  {
// Shutdown the order tickets array
   orderTickets.Shutdown();

// Get the total number of orders
   int totalOrders = OrdersTotal();

// If there are no orders, return false
   if(!totalOrders)
      return(false);

// Loop through each order
   for(int i = 0; i < totalOrders; i++)
     {
      // Get the ticket for the order
      ulong ticket = OrderGetTicket(i);

      // If the order is not selected or not valid, continue to the next order
      if(!OrderSelect(ticket) || !IsValidOrder(ticket))
         continue;

      // Add the ticket to the order tickets array
      orderTickets.Add(ticket);
     }

// Return true if at least one valid order ticket is found; otherwise, false
   return(orderTickets.Total() > 0);
  }
//+------------------------------------------------------------------+
