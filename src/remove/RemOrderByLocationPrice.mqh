//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+
#include "Remove.mqh"

//+------------------------------------------------------------------+
/**
 * @class RemOrderByLocationPrice
 * @brief Class to handle the removal of orders based on their location relative to a middle value.
 */
class RemOrderByLocationPrice : Remove
  {
public:
   /**
    * @struct Setting
    * @brief Extends Remove::Setting to include a reference price.
    */
   struct Setting : public Remove::Setting
     {
      double         referencePrice;     ///< Reference price for comparing order positions.
      
      /**
       * @brief Default constructor to initialize settings.
       */
                     RemOrderByLocationPrice::Setting() : Setting(), referencePrice(0.0) {}
     };

private:
   /**
    * @brief Arrays to store order tickets for orders above and below the referencePrice value.
    */
   CArrayLong        upperTickets;       ///< Stores tickets for orders above the referencePrice.
   CArrayLong        lowerTickets;       ///< Stores tickets for orders below the referencePrice.

   RemOrderByLocationPrice::Setting settingROBLP;  ///< Custom settings for this class.

   /**
    * @brief Flag to indicate whether the verification and removal should be performed.
    */
   bool              internalFlag;       ///< Indicates if the internal process should run.

public:
   /**
    * @brief Default constructor for the RemOrderByLocationPrice class.
    */
                     RemOrderByLocationPrice(void) : Remove(), internalFlag(false) {}

   /**
    * @brief Updates the settings for the RemOrderByLocationPrice class.
    * @param sym Symbol string to identify the asset.
    * @param magic Magic number to identify trades.
    * @param referencePrice Price used as the threshold for categorizing orders.
    */
   void              UpdateSetting(string sym, ulong magic, double referencePrice);

   /**
    * @brief Returns the current settings of the class.
    * @return RemOrderByLocationPrice::Setting structure with current settings.
    */
   RemOrderByLocationPrice::Setting GetSetting(void);

   /**
    * @brief Validates the settings of the class.
    * @return True if the settings are valid, otherwise false.
    */
   bool              CheckSetting(void);

   /**
    * @brief Updates the order arrays based on their open prices relative to the reference price.
    */
   void              UpdateOrders();

   /**
    * @brief Verifies positions and removes orders from the opposite array based on the position location.
    */
   void              TriggerPositionNotInArray();
  };

//+------------------------------------------------------------------+
void RemOrderByLocationPrice::UpdateSetting(string sym, ulong magic, double referencePrice)
  {
   this.settingROBLP.identifierString = sym;
   this.settingROBLP.identifierLong = magic;
   this.settingROBLP.referencePrice = referencePrice;

   // Update base class settings as well
   this.setting.identifierString = sym;
   this.setting.identifierLong = magic;
  }

//+------------------------------------------------------------------+
RemOrderByLocationPrice::Setting RemOrderByLocationPrice::GetSetting(void)
  { 
    return this.settingROBLP; 
  }

//+------------------------------------------------------------------+
bool              RemOrderByLocationPrice::CheckSetting(void)
  {
   // Check if identifierLong, referencePrice, and identifierString are valid
   return (
             !ZeroProcessor::Run(this.settingROBLP.identifierLong, true) &&    // Checks if identifierLong is not zero
             !ZeroProcessor::Run(this.settingROBLP.referencePrice, true) &&    // Checks if referencePrice is not zero
             !SystemRequirements::SymbolCommon(this.settingROBLP.identifierString)  // Validates the symbol string
          );
  }

//+------------------------------------------------------------------+
void RemOrderByLocationPrice::UpdateOrders()
  {
   // Clear the order tickets arrays
   this.detectOrders.DeleteEntities();
   this.upperTickets.Shutdown();
   this.lowerTickets.Shutdown();

   // Update the list of orders
   if(!this.detectOrders.UpdateEntities())
      return;

   CArrayLong entities;
   this.detectOrders.GetEntities(entities);

   // Loop through each order
   for(int i = 0; i < entities.Total(); i++)
     {
      // Get the ticket for the order
      ulong ticket = entities.At(i);

      // If unable to select the order, return
      if(!OrderSelect(ticket))
         return;

      // Categorize the order based on its open price relative to the referencePrice
      if(OrderGetDouble(ORDER_PRICE_OPEN) > this.settingROBLP.referencePrice)
         this.upperTickets.Add(ticket);  // Add to upperTickets if price is above reference
      else
         this.lowerTickets.Add(ticket);  // Add to lowerTickets if price is below reference

      // Set the internal flag to true
      this.internalFlag = true;
     }
  }

//+------------------------------------------------------------------+
void RemOrderByLocationPrice::TriggerPositionNotInArray()
  {
   // If the internal flag is not set, return
   if(!internalFlag)
      return;

   // Update the list of positions
   if(!this.detectPositions.UpdateEntities())
      return;

   CArrayLong entities = this.detectPositions.GetEntities();

   // Loop through each position
   for(int i = 0; i < entities.Total(); i++)
     {
      // Get the ticket for the position
      long ticket = entities.At(i);

      // Check if the position ticket is in the upper or lower order tickets array
      if(upperTickets.SearchLinear(ticket) != -1)
        {
         // Remove orders from the lower order tickets
         if(RemoveOrdersFromCArray(this.lowerTickets))
            PrintFormat("Removed orders in lowerTickets for position ticket: %d", ticket);
         else
            PrintFormat("Failed removing orders in lowerTickets for position ticket: %d. Err: %d", ticket, GetLastError());

         // Reset the internal flag
         this.internalFlag = false;
        }

      // Same process for orders in the lower array
      if(lowerTickets.SearchLinear(ticket) != -1)
        {
         // Remove orders from the upper order tickets
         if(RemoveOrdersFromCArray(this.upperTickets))
            PrintFormat("Removed orders in upperTickets for position ticket: %d", ticket);
         else
            PrintFormat("Failed removing orders in upperTickets for position ticket: %d. Err: %d", ticket, GetLastError());

         // Reset the internal flag
         this.internalFlag = false;
        }
     }
  }
//+------------------------------------------------------------------+
