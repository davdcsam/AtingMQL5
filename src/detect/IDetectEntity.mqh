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
    * @brief Structure to hold the entity's settings such as symbol and magic number.
    */
   struct Setting
     {
      string symbol; ///< The symbol associated with the entity.
      ulong  magic;  ///< The magic number used to identify the entity.
     };

   /**
    * @brief Updates the symbol and magic number for the entity.
    * @param symbol The symbol for the entity.
    * @param magic The magic number for the entity.
    */
   virtual void UpdateSetting(string symbol, ulong magic) = 0;

   /**
    * @brief Gets the current settings (symbol and magic number) for the entity.
    * @return The current Setting structure.
    */
   virtual Setting GetSetting() = 0;

   /**
    * @brief Checks if the current settings are valid.
    * @return True if the settings are valid, false otherwise.
    */
   virtual bool CheckSetting() = 0;

   /**
    * @brief Checks if the entity is valid based on a ticket number.
    * @param ticket Ticket number of the entity.
    * @return True if the entity is valid; false otherwise.
    */
   virtual bool IsValid(ulong ticket) = 0;

   /**
    * @brief Updates the entity collection by gathering valid tickets.
    * @return True if at least one valid ticket is found; otherwise, false.
    */
   virtual bool UpdateEntities() = 0;

   /**
    * @brief Destructor for the interface.
    */
   virtual ~IDetectEntity() {};
  };
