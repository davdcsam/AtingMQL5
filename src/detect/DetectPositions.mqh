//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+
#include "IDetectEntity.mqh"

/**
 * @class DetectPositions
 * @brief Class for detecting and managing trading positions. Implements the IDetectEntity interface to handle position-related operations.
 */
class DetectPositions : public IDetectEntity
  {
protected:
   Setting           setting;   ///< Current settings for the position, including symbol and magic number.
   CArrayLong        positions; ///< Array to store valid position tickets.

public:
   /**
    * @brief Default constructor for the DetectPositions class.
    */
                     DetectPositions(void) {};

   // Implementation of the IDetectEntity interface methods

   /**
    * @brief Updates the symbol and magic number for the current position setting.
    * @param sym The symbol associated with the position (e.g., "EURUSD").
    * @param magic The magic number used to identify the position.
    */
   virtual void      UpdateSetting(string sym, ulong magic) override
     {
      this.setting.identifierString = sym;
      this.setting.identifierLong = magic;
     }

   /**
    * @brief Retrieves the current position settings, including symbol and magic number.
    * @return The current Setting structure containing the position details.
    */
   virtual Setting   GetSetting() override
     { return this.setting; }

   /**
    * @brief Validates if the current position settings meet the necessary requirements.
    * @return True if the symbol and magic number are valid; otherwise, false.
    */
   virtual bool      CheckSetting() override
     {
      return (
                !ZeroProcessor::Run(this.setting.identifierLong, true) &&
                SystemRequirements::SymbolCommon(this.setting.identifierString)
             );
     }

   /**
    * @brief Checks whether a specific position is valid based on its ticket number.
    * @param ticket The ticket number of the position.
    * @return True if the position is valid (i.e., the magic number and symbol match the current settings); otherwise, false.
    */
   virtual bool      IsValid(ulong ticket) override
     {
      return (
                PositionSelectByTicket(ticket) &&
                PositionGetInteger(POSITION_MAGIC) == this.setting.identifierLong &&
                PositionGetString(POSITION_SYMBOL) == this.setting.identifierString
             );
     }

   /**
    * @brief Updates the internal collection of valid positions based on current settings.
    * @return True if at least one valid position ticket is found and stored; otherwise, false.
    */
   virtual bool      UpdateEntities() override
     {
      this.positions.Shutdown();
      int totalPositions = PositionsTotal();

      if(totalPositions == 0)
         return false;

      // Iterate over all positions and add valid ones to the array
      for(int i = 0; i < totalPositions; i++)
        {
         ulong ticket = PositionGetTicket(i);
         if(!IsValid(ticket))
            continue;
         this.positions.Add(ticket);
        }

      return this.positions.Total() > 0;
     }

   /**
    * @brief Updates the internal position collection with a provided set of position tickets.
    * @param entities The array of position tickets to update the internal collection with.
    * @return True if the entities were successfully updated.
    */
   virtual bool      UpdateEntities(CArrayLong &entities) override
     {
      this.positions = entities;
      return true;
     }

   /**
    * @brief Deletes all stored position tickets by clearing the internal collection.
    * @return True if the position tickets were successfully deleted; otherwise, false.
    */
   virtual bool      DeleteEntities(void) override
     { return        this.positions.Shutdown(); }

   /**
    * @brief Retrieves the internal collection of stored position tickets.
    * @param entities Reference to an array where the valid position tickets will be copied.
    * @return True if there are valid position tickets in the internal collection; otherwise, false.
    */
   virtual bool      GetEntities(CArrayLong &entities) override
     {
      entities = this.positions;
      return entities.Total() > 0;
     }

   /**
    * @brief Retrieves a pointer to the internal array of position tickets.
    * @return A pointer to the internal CArrayLong object containing valid position tickets.
    */
   CArrayLong*       GetEntities(void)
     { return &this.positions; }
  };
//+------------------------------------------------------------------+
