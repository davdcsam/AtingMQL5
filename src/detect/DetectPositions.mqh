//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+
#include "IDetectEntity.mqh"

/**
 * @class DetectPositions
 * @brief Class for detecting and managing positions, implements IDetectEntity interface.
 */
class DetectPositions : public IDetectEntity
  {
private:
   Setting           setting; ///< Current settings for the position.
   CArrayLong        positionTickets; ///< Array to store position tickets.

public:
   // Constructor
                     DetectPositions(void) {};

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
                PositionSelectByTicket(ticket) &&
                PositionGetInteger(POSITION_MAGIC) == setting.magic &&
                PositionGetString(POSITION_SYMBOL) == setting.symbol
             );
     }

   virtual bool      UpdateEntities() override
     {
      positionTickets.Shutdown();
      int totalPositions = PositionsTotal();

      if(totalPositions == 0)
         return false;

      for(int i = 0; i < totalPositions; i++)
        {
         ulong ticket = PositionGetTicket(i);
         if(!IsValid(ticket))
            continue;
         positionTickets.Add(ticket);
        }
      return positionTickets.Total() > 0;
     }
  };
//+------------------------------------------------------------------+
