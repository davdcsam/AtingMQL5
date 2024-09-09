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
   CArrayLong        orderTickets; ///< Array to store order tickets.

public:
   // Constructor
                     DetectOrders(void) {};

   // Implementation of the IDetectEntity methods

   virtual void      UpdateSetting(string symbol, ulong magic) override
     {
      setting.symbol = symbol;
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
      orderTickets.Shutdown();
      int totalOrders = OrdersTotal();

      if(totalOrders == 0)
         return false;

      for(int i = 0; i < totalOrders; i++)
        {
         ulong ticket = OrderGetTicket(i);
         if(!IsValid(ticket))
            continue;
         orderTickets.Add(ticket);
        }
      return orderTickets.Total() > 0;
     }
  };
//+------------------------------------------------------------------+
