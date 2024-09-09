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
protected:
   Setting           setting; ///< Current settings for the position.
   CArrayLong        entities; ///< Array to store position tickets.

public:
   // Constructor
                     DetectPositions(void) {};

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
                PositionSelectByTicket(ticket) &&
                PositionGetInteger(POSITION_MAGIC) == setting.magic &&
                PositionGetString(POSITION_SYMBOL) == setting.symbol
             );
     }

   virtual bool      UpdateEntities() override
     {
      entities.Shutdown();
      int totalPositions = PositionsTotal();

      if(totalPositions == 0)
         return false;

      for(int i = 0; i < totalPositions; i++)
        {
         ulong ticket = PositionGetTicket(i);
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

   virtual CObject*  GetEntities(void) override
     { return &entities; }
  };
//+------------------------------------------------------------------+
