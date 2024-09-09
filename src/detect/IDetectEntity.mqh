//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+

// Module possibly included
#include <Arrays/ArrayLong.mqh>
#include "../CheckCommonSetting.mqh"
#include "../SystemRequirements.mqh"

/**
 * @interface IDetectEntity
 * @brief Interface for detecting and managing trading entities (orders, positions, etc.).
 */
class IDetectEntity
  {
public:
   /**
    * @struct Setting
    * @brief Structure to hold the entity's settings such as commonString and commonLong.
    */
   struct Setting
     {
      string         identifierString; ///< The identifierString associated with the entity.
      ulong          identifierLong;  ///< The identifierLong used to identify the entity.
     };

   /**
    * @brief Updates the commonString and commonLong number for the entity.
    * @param sym The commonString for the entity.
    * @param commonLong The commonLong number for the entity.
    */
   virtual void      UpdateSetting(string identifierString, ulong identifierLong) = 0;

   /**
    * @brief Gets the current settings (identifierString and identifierLong) for the entity.
    * @return The current Setting structure.
    */
   virtual Setting   GetSetting(void) = 0;

   /**
    * @brief Checks if the current settings are valid.
    * @return True if the settings are valid, false otherwise.
    */
   virtual bool      CheckSetting(void) = 0;

   /**
    * @brief Checks if the entity is valid based on a ticket number.
    * @param ticket Ticket number of the entity.
    * @return True if the entity is valid; false otherwise.
    */
   virtual bool      IsValid(ulong ticket) = 0;

   /**
    * @brief Updates the entity collection by gathering valid tickets.
    * @return True if at least one valid ticket is found; otherwise, false.
    */

   virtual bool      UpdateEntities(void) = 0;

   virtual bool      UpdateEntities(CArrayLong &entities) = 0;

   /**
    * @brief Deletes all entities from the collection.
    * @details This method is used to clear or remove all entities currently stored in the collection.
    */
   virtual bool      DeleteEntities(void) = 0;

   virtual bool      GetEntities(CArrayLong &entities) = 0;

   virtual CArrayLong*   GetEntities(void) = 0;

   /**
    * @brief Destructor for the interface.
    */
   virtual          ~IDetectEntity(void) {};
  };
//+------------------------------------------------------------------+
