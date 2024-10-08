//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+
#include <Trade/Trade.mqh>
#include "../detect/DetectPositions.mqh"
#include "../CheckCommonSetting.mqh"

//+------------------------------------------------------------------+
/**
 * @class ProfitProtection
 * @brief Handles profit protection mechanisms such as trailing stops and break-even adjustments.
 */
class ProfitProtection
{
public:
   /**
    * @struct Setting
    * @brief Contains the configuration parameters for profit protection.
    */
   struct Setting
   {
      double activationPercent; ///< Percentage at which profit protection activates.
      double deviationPercent;  ///< Percentage deviation used to adjust stop losses.
   };

   /**
    * @enum ENUM_PROFIT_PROTECTION_TYPE
    * @brief Types of profit protection strategies.
    */
   enum ENUM_PROFIT_PROTECTION_TYPE
   {
      TRAILING_STOP, // Trailing Stop
      BREAK_EVEN // Break Even
   };

protected:
   Setting setting;                  ///< Current profit protection settings.
   CTrade trade;                     ///< Trade object to execute trade operations.
   DetectPositions *detectPositions; ///< Pointer to an instance of DetectPositions for managing positions.

public:
   /**
    * @brief Constructor for the ProfitProtection class.
    * @param dP Pointer to a DetectPositions instance to manage positions.
    */
   ProfitProtection(DetectPositions *dP);

   /**
    * @brief Destructor for the ProfitProtection class.
    */
   ~ProfitProtection(void);

   /**
    * @brief Updates the profit protection settings.
    * @param activationPercent The percentage at which profit protection should activate.
    * @param deviationPercent The percentage deviation used for stop loss adjustments.
    */
   void UpdateSetting(
       double activationPercent, ///< Activation percentage for profit protection.
       double deviationPercent   ///< Deviation percentage for profit protection.
   );

   /**
    * @brief Retrieves the current settings.
    * @param s Reference to a Setting structure where the settings will be stored.
    */
   void GetSetting(Setting &s);

   /**
    * @brief Returns the current profit protection settings.
    * @return A Setting structure containing the current configuration.
    */
   Setting GetSetting(void);

   /**
    * @brief Verifies the validity of the current settings.
    * @return True if the settings are valid, otherwise false.
    */
   bool CheckSetting(void);

   /**
    * @brief Converts the current settings to a string representation.
    * @return A string containing the settings information.
    */
   string SettingToString(void);

   /**
    * @brief Modifies the stop loss for a buy position.
    * @param ticket The ticket number of the position.
    * @param newStopLoss The new stop loss price.
    * @return True if the stop loss was successfully modified, otherwise false.
    */
   bool ModifyStopLossFromPositionBuy(ulong ticket, double newStopLoss);

   /**
    * @brief Modifies the stop loss for a sell position.
    * @param ticket The ticket number of the position.
    * @param newStopLoss The new stop loss price.
    * @return True if the stop loss was successfully modified, otherwise false.
    */
   bool ModifyStopLossFromPositionSell(ulong ticket, double newStopLoss);

   /**
    * @brief Calculates the activation price based on the activation percentage for a given position.
    * @param positionTicket The ticket number of the position.
    * @return The activation price or 0 if the position cannot be selected.
    */
   double GetActivationPrice(ulong positionTicket);

   /**
    * @brief Calculates the price deviation from the current price based on the deviation percentage.
    * @param positionTicket The ticket number of the position.
    * @return The deviation price from the current price.
    */
   double GetDeviationPriceFromCurrent(ulong positionTicket);

   /**
    * @brief Calculates the price deviation from the opening price based on the deviation percentage.
    * @param positionTicket The ticket number of the position.
    * @return The deviation price from the opening price.
    */
   double GetDeviationPriceFromOpen(ulong positionTicket);
};
