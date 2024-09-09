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
   CArrayLong        entities; ///< Array to store order tickets.

public:
   // Constructor
                     DetectOrders(void) {};

   // Implementation of the IDetectEntity methods

   virtual void      UpdateSetting(string sym, ulong magic) override
     {
      setting.symbol = sym;
      setting.magic = magic;
     }

   virtual Setting   GetSetting() override
     {
      return setting;
     }

   virtual bool      CheckSetting() override
     {
      return (ZeroProcessor::Run(setting.magic) &&
              SystemRequirements::SymbolCommon(setting.symbol));
     }

   virtual bool      IsValid(ulong ticket) override
     {
      return (
                OrderSelect(ticket) &&
                OrderGetInteger(ORDER_MAGIC) == setting.magic &&
                OrderGetString(ORDER_SYMBOL) == setting.symbol
             );
     }

   virtual bool      UpdateEntities() override
     {
      entities.Shutdown();
      int totalOrders = OrdersTotal();

      if(totalOrders == 0)
         return false;

      for(int i = 0; i < totalOrders; i++)
        {
         ulong ticket = OrderGetTicket(i);
         if(!IsValid(ticket))
            continue;
         entities.Add(ticket);
        }
      return entities.Total() > 0;
     }

   virtual bool      UpdateEntities(CObject &param) override
     {
      if(param.Type() != entities.Type())
         return false;

      entities = param;
      return true;
     }

   virtual bool      DeleteEntities(void) override
     { return        entities.Shutdown(); }

   virtual bool      GetEntities(CObject &param) override
     {
      if(entities.Total())
        {
         param = entities;
         return true;
        }
      else
         return false;
     }

   virtual CObject*   GetEntities(void) override
     { return &entities; }
  };
//+------------------------------------------------------------------+
