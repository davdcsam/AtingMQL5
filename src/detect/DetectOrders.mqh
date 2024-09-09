//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+
#include "IDetectEntity.mqh"

/**
 * @class DetectOrders
 * @brief Class for detecting and managing orders, implements IDetectEntity interface.
 */
class DetectOrders : public IDetectEntity
  {
private:
   Setting           setting; ///< Current settings for the order.
   CArrayLong        orders; ///< Array to store order tickets.

public:
   // Constructor
                     DetectOrders(void) {};

   // Implementation of the IDetectEntity methods

   virtual void      UpdateSetting(string sym, ulong magic) override
     {
      this.setting.identifierString = sym;
      this.setting.identifierLong = magic;
     }

   virtual Setting   GetSetting() override
     { return this.setting; }

   virtual bool      CheckSetting() override
     {
      return (
                ZeroProcessor::Run(this.setting.identifierLong) &&
                SystemRequirements::SymbolCommon(this.setting.identifierString)
             );
     }

   virtual bool      IsValid(ulong ticket) override
     {
      return (
                OrderSelect(ticket) &&
                OrderGetInteger(ORDER_MAGIC) == this.setting.identifierLong &&
                OrderGetString(ORDER_SYMBOL) == this.setting.identifierString
             );
     }

   virtual bool      UpdateEntities() override
     {
      this.orders.Shutdown();
      int totalOrders = OrdersTotal();

      if(totalOrders == 0)
         return false;

      for(int i = 0; i < totalOrders; i++)
        {
         ulong ticket = OrderGetTicket(i);
         if(!IsValid(ticket))
            continue;
         this.orders.Add(ticket);
        }
      return this.orders.Total() > 0;
     }

   virtual bool      UpdateEntities(CArrayLong &entities) override
     {
      this.orders = entities;
      return true;
     }

   virtual bool      DeleteEntities(void) override
     { return        this.orders.Shutdown(); }

   virtual bool              GetEntities(CArrayLong &entities) override
     {
      entities = this.orders;
      return entities.Total() > 0;
     }

   CArrayLong*        GetEntities(void)
     { return &this.orders; }
  };
//+------------------------------------------------------------------+
