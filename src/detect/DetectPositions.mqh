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
   CArrayLong        positions; ///< Array to store position tickets.

public:
   // Constructor
                     DetectPositions(void) {};

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
                !ZeroProcessor::Run(this.setting.identifierLong, true) &&
                SystemRequirements::SymbolCommon(this.setting.identifierString)
             );
     }

   virtual bool      IsValid(ulong ticket) override
     {
      return (
                PositionSelectByTicket(ticket) &&
                PositionGetInteger(POSITION_MAGIC) == this.setting.identifierLong &&
                PositionGetString(POSITION_SYMBOL) == this.setting.identifierString
             );
     }

   virtual bool      UpdateEntities() override
     {
      this.positions.Shutdown();
      int totalPositions = PositionsTotal();

      if(totalPositions == 0)
         return false;

      for(int i = 0; i < totalPositions; i++)
        {
         ulong ticket = PositionGetTicket(i);
         if(!IsValid(ticket))
            continue;
         this.positions.Add(ticket);
        }
      return this.positions.Total() > 0;
     }

   virtual bool      UpdateEntities(CArrayLong &entities) override
     {
      this.positions = entities;
      return true;
     }

   virtual bool      DeleteEntities(void) override
     { return        this.positions.Shutdown(); }

   virtual bool              GetEntities(CArrayLong &entities) override
     {
      entities = this.positions;
      return entities.Total() > 0;
     }

   CArrayLong*       GetEntities(void)
     { return &this.positions; }
  };
//+------------------------------------------------------------------+
