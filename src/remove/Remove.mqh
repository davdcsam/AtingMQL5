//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+
#include <Trade/Trade.mqh>
#include "../detect/IDetectEntity.mqh"

/**
 * @class Remove
 * @brief Class to handle the removal of orders and positions.
 */
class Remove
  {
public:

   /**
    * @struct Setting
    * @brief Structure to store settings for symbol and magic number.
    */
   struct Setting
     {
      string         identifierString; ///< Trading symbol
      ulong          identifierLong; ///< Magic number
     };

protected:

   IDetectEntity*    detectOrders; ///< Pointer to IDetectEntity for order detection
   IDetectEntity*    detectPositions; ///< Pointer to IDetectEntity for position detection
   CTrade            trade; ///< Trade object for performing trade operations setting;
   Setting           setting; ///< Setting object

public:

   /**
    * @brief Default Constructor
    */
                     Remove();

   /**
    * @brief Constructor
    * @param oDetector Pointer to IDetectEntity for order detection
    * @param pDetector Pointer to IDetectEntity for position detection
    */
                     Remove(IDetectEntity* dOrders, IDetectEntity* dPositions);

   /**
    * @brief Updates the settings for the Remove class
    * @param sym Trading symbol
    * @param magic Magic number
    */
   void              UpdateSetting(string sym, ulong magic);

   /**
    * @brief Gets the current settings of the Remove class
    * @return Setting object containing the symbol and magic number
    */
   Setting           GetSetting() const;

   /**
    * @brief Checks if the current settings are valid
    * @return True if settings are valid, false otherwise
    */
   bool              CheckSetting() const;

   /**
    * @brief Removes all pending orders detected by the DetectOrders object
    * @return True if all pending orders were removed successfully, false otherwise
    */
   bool              RemovePendingOrders();

   /**
    * @brief Removes all positions detected by the DetectPositions object
    * @return True if all positions were removed successfully, false otherwise
    */
   bool              RemovePositions();

   /**
    * @brief Removes orders from an array of order tickets
    * @param tickets Array of order tickets to remove
    * @return True if all orders were removed successfully, false otherwise
    */
   bool              RemoveOrdersFromArray(CArrayLong& tickets);

   /**
    * @brief Removes positions from an array of position tickets
    * @param tickets Array of position tickets to remove
    * @return True if all positions were removed successfully, false otherwise
    */
   bool              RemovePositionsFromArray(CArrayLong& tickets);
  };
//+------------------------------------------------------------------+
