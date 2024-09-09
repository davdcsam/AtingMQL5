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
    * @brief Structure to hold the entity's settings such as identifierString and identifierLong.
    */
   struct Setting
     {
      string         identifierString; ///< The identifier string associated with the entity.
      ulong          identifierLong;  ///< The identifier long number used to identify the entity.
     };

   /**
    * @brief Updates the identifierString and identifierLong number for the entity.
    * @param identifierString The identifier string for the entity.
    * @param identifierLong The identifier long number for the entity.
    */
   virtual void      UpdateSetting(string identifierString, ulong identifierLong) = 0;

   /**
    * @brief Gets the current settings (identifierString and identifierLong) for the entity.
    * @return The current Setting structure containing identifierString and identifierLong.
    */
   virtual Setting   GetSetting(void) = 0;

   /**
    * @brief Checks if the current settings are valid.
    * @return True if the settings are valid; false otherwise.
    */
   virtual bool      CheckSetting(void) = 0;

   /**
    * @brief Checks if the entity is valid based on a ticket number.
    * @param ticket The ticket number of the entity.
    * @return True if the entity is valid; false otherwise.
    */
   virtual bool      IsValid(ulong ticket) = 0;

   /**
    * @brief Updates the entity collection by gathering valid tickets.
    * @return True if at least one valid ticket is found and added to the collection; otherwise, false.
    */
   virtual bool      UpdateEntities(void) = 0;

   /**
    * @brief Updates the entity collection with the given array of entities.
    * @param entities The array of entities to update.
    * @return True if the update was successful; false otherwise.
    */
   virtual bool      UpdateEntities(CArrayLong &entities) = 0;

   /**
    * @brief Deletes all entities from the collection.
    * @details This method clears or removes all entities currently stored in the collection.
    * @return True if the deletion was successful; false otherwise.
    */
   virtual bool      DeleteEntities(void) = 0;

   /**
    * @brief Gets the collection of entities.
    * @param entities The array to be filled with the current entities.
    * @return True if entities were successfully retrieved; false otherwise.
    */
   virtual bool      GetEntities(CArrayLong &entities) = 0;

   /**
    * @brief Gets a pointer to the collection of entities.
    * @return A pointer to the collection of entities.
    */
   virtual CArrayLong*   GetEntities(void) = 0;

   /**
    * @brief Destructor for the interface.
    */
   virtual          ~IDetectEntity(void) {};
  };
//+------------------------------------------------------------------+
