//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+
#include "IDetectEntity.mqh"

/**
 * @class DetectOrders
 * @brief Class for detecting and managing orders. Implements the IDetectEntity interface to handle order-related operations.
 */
class DetectOrders : public IDetectEntity
  {
private:
   Setting           setting;   ///< Current settings for the order, including symbol and magic number.
   CArrayLong        orders; ///< Array to store valid order tickets.

public:
   /**
    * @brief Default constructor for the DetectOrders class.
    */
                     DetectOrders(void) {};

   // Implementation of the IDetectEntity interface methods

   /**
    * @brief Updates the symbol and magic number for the current order setting.
    * @param sym The symbol associated with the order (e.g., "EURUSD").
    * @param magic The magic number used to identify the order.
    */
   virtual void      UpdateSetting(string sym, ulong magic) override
     {
      this.setting.identifierString = sym;
      this.setting.identifierLong = magic;
     }

   /**
    * @brief Retrieves the current order settings, including symbol and magic number.
    * @return The current Setting structure containing the order details.
    */
   virtual Setting   GetSetting() override
     {
      return this.setting;
     }

   /**
    * @brief Validates if the current order settings meet the necessary requirements.
    * @return True if the symbol and magic number are valid; otherwise, false.
    */
   virtual bool      CheckSetting() override
     {
      return (
                !ZeroProcessor::Run(this.setting.identifierLong, true) &&
                SystemRequirements::SymbolCommon(this.setting.identifierString));
     }

   /**
    * @brief Checks whether a specific order is valid based on its ticket number.
    * @param ticket The ticket number of the order.
    * @return True if the order is valid (i.e., the magic number and symbol match the current settings); otherwise, false.
    */
   virtual bool      IsValid(ulong ticket) override
     {
      return (
                OrderSelect(ticket) &&
                OrderGetInteger(ORDER_MAGIC) == this.setting.identifierLong &&
                OrderGetString(ORDER_SYMBOL) == this.setting.identifierString);
     }

   /**
    * @brief Updates the internal collection of valid orders based on current settings.
    * @return True if at least one valid order ticket is found and stored; otherwise, false.
    */
   virtual bool      UpdateEntities() override
     {
      this.orders.Shutdown();
      int totalOrders = OrdersTotal();

      if(totalOrders == 0)
         return false;

      // Iterate over all orders and add valid ones to the array
      for(int i = 0; i < totalOrders; i++)
        {
         ulong ticket = OrderGetTicket(i);
         if(!IsValid(ticket))
            continue;
         this.orders.Add(ticket);
        }

      return this.orders.Total() > 0;
     }

   /**
    * @brief Updates the internal order collection with a provided set of order tickets.
    * @param entities The array of order tickets to update the internal collection with.
    * @return True if the entities were successfully updated.
    */
   virtual bool      UpdateEntities(CArrayLong &entities) override
     {
      this.orders = entities;
      return true;
     }

   /**
    * @brief Deletes all stored order tickets by clearing the internal collection.
    * @return True if the order tickets were successfully deleted; otherwise, false.
    */
   virtual bool      DeleteEntities(void) override
     {
      return this.orders.Shutdown();
     }

   /**
    * @brief Retrieves the internal collection of stored order tickets.
    * @param entities Reference to an array where the valid order tickets will be copied.
    * @return True if there are valid order tickets in the internal collection; otherwise, false.
    */
   virtual bool      GetEntities(CArrayLong &entities) override
     {
      entities = this.orders;
      return entities.Total() > 0;
     }

   /**
    * @brief Retrieves a pointer to the internal array of order tickets.
    * @return A pointer to the internal CArrayLong object containing valid order tickets.
    */
   CArrayLong        *GetEntities(void)
     {
      return &this.orders;
     }
  };
//+------------------------------------------------------------------+
