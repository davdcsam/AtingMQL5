//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+
#include "../Remove.mqh"

//+------------------------------------------------------------------+
/**
 * @class RemOrderByLocationPrice
 * @brief Class to handle the removal of orders based on their location relative to a middle value.
 */
class RemOrderByLocationPrice : public Remove
  {
private:
   CArrayLong        upperTickets; ///< Stores tickets for orders above the reference price
   CArrayLong        lowerTickets; ///< Stores tickets for orders below the reference price
   double            referencePrice;   ///< Reference price for comparing order positions
   bool              internalFlag;       ///< Flag to indicate if verification and removal should be performed

public:
   /**
    * @brief Constructor for RemOrderByLocationPrice
    * @param dOrders Pointer to IDetectEntity for order detection
    * @param dPositions Pointer to IDetectEntity for position detection
    */
                     RemOrderByLocationPrice(IDetectEntity* dOrders, IDetectEntity* dPositions);

   /**
    * @brief Updates the settings for the class
    * @param sym Symbol string
    * @param magic Magic number
    * @param reference Reference price
    */
   void              UpdateSetting(string sym, ulong magic, double reference);

   /**
    * @brief Gets the current reference price
    * @return Current reference price
    */
   double            GetReferencePrice() const;

   /**
    * @brief Checks if the current settings are valid
    * @return True if settings are valid, false otherwise
    */
   bool              CheckSetting() const;

   /**
    * @brief Updates the list of orders based on the reference price
    */
   void              UpdateOrders();

   /**
    * @brief Triggers removal of orders based on position not being in the array
    */
   void              TriggerPositionNotInArray();
  };
//+------------------------------------------------------------------+
