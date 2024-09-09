//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+
#include <Arrays/ArrayLong.mqh>
#include "../CheckCommonSetting.mqh"
#include "../SystemRequirements.mqh"

//+------------------------------------------------------------------+
/**
 * @class DetectOrders
 * @brief Class to detect and manage orders.
 */
class DetectOrders
  {
public:
   /**
    * @struct Setting
    * @brief Structure to hold the order's settings such as symbol and magic number.
    */
   struct Setting
     {
      string         symbol; ///< The symbol associated with the order.
      ulong          magic;  ///< The magic number used to identify the order.
     };

private:
   Setting           setting; ///< Current setting containing symbol and magic number.

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
    * @param sym Symbol for the order.
    * @param magic Magic number for the order.
    */
   void              UpdateSetting(string sym, ulong magic);

   /**
    * @brief Returns the current settings (symbol and magic number).
    * @return The current Setting structure.
    */
   Setting           GetSetting(void);

   /**
    * @brief Retrieves the current settings and stores them in the provided parameter.
    * @param param Reference to a Setting object where the current setting will be copied.
    */
   void              GetSetting(Setting &param);

   /**
    * @brief Checks if the current setting (symbol and magic number) meets the necessary conditions.
    * @return True if the setting is valid; otherwise, false.
    */
   bool              CheckSetting(void);

   /**
    * @brief Checks if an order is valid based on the ticket.
    * @param ticket Ticket number of the order.
    * @return True if the order is selected, and the magic number and symbol match; otherwise, false.
    */
   bool              IsValidOrder(ulong ticket);

   /**
    * @brief Updates the orders by collecting valid order tickets.
    * @return True if at least one valid order ticket is found; otherwise, false.
    */
   bool              UpdateOrders(void);
  };

//+------------------------------------------------------------------+
void DetectOrders::UpdateSetting(string sym, ulong magic)
  {
   setting.magic = magic;
   setting.symbol = sym;
  }

//+------------------------------------------------------------------+
void DetectOrders::GetSetting(Setting &param)
  { param = setting; }

//+------------------------------------------------------------------+
DetectOrders::Setting DetectOrders::GetSetting(void)
  {  return setting; }

//+------------------------------------------------------------------+
bool DetectOrders::CheckSetting(void)
  {
   if(
      ZeroProcessor::Run(setting.magic) &&
      SystemRequirements::SymbolCommon(setting.symbol)
   )
      return false;
   return true;
  }

//+------------------------------------------------------------------+
bool DetectOrders::IsValidOrder(ulong ticket)
  {
   return(
            OrderSelect(ticket) &&
            OrderGetInteger(ORDER_MAGIC) == setting.magic &&
            OrderGetString(ORDER_SYMBOL) == setting.symbol
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
