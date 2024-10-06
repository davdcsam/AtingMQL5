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
 * @brief Class to handle profit protection mechanisms such as trailing stops and break-even adjustments.
 */
class ProfitProtection
{
public:
   struct Setting
   {
      double activationPercent; ///< Activation percentage for profit protection
      double deviationPercent;  ///< Deviation percentage for profit protection
   };

   /**
    * @enum ENUM_PROFIT_PROTECTION_TYPE
    * @brief Enumeration of different profit protection types.
    */
   enum ENUM_PROFIT_PROTECTION_TYPE
   {
      TRAILING_STOP, /// Trailing Stop
      BREAK_EVEN     /// Break Even
   };

protected:
   Setting setting;
   CTrade trade;                     ///< Trade object for performing trade operations
   DetectPositions *detectPositions; ///< Object for detecting positions
public:
   /**
    * @brief Default constructor for the ProfitProtection class.
    * @param Pointer of a DetectPositions instance.
    */
   ProfitProtection(DetectPositions *dP);

   ~ProfitProtection(void);

   /**
    * @brief Updates the attributes of the ProfitProtection class.
    * @param activationPercent Activation percentage for profit protection
    * @param deviationPercent Deviation percentage for profit protection
    */
   void UpdateSetting(
       double activationPercent, ///< Activation percentage argument
       double deviationPercent   ///< Deviation percentage argument
   );

   void GetSetting(Setting &s);

   Setting GetSetting(void);

   bool CheckSetting(void);

   string SettingToString(void);

   /**
    * @brief Modifies the stop loss for a buy position.
    * @param ticket Position ticket number
    * @param newStopLoss New stop loss value
    * @return True if stop loss was successfully modified, otherwise false
    */
   bool ModifyStopLossFromPositionBuy(ulong ticket, double newStopLoss);

   /**
    * @brief Modifies the stop loss for a sell position.
    * @param ticket Position ticket number
    * @param newStopLoss New stop loss value
    * @return True if stop loss was successfully modified, otherwise false
    */
   bool ModifyStopLossFromPositionSell(ulong ticket, double newStopLoss);

   /**
    * @brief Calculates the activation price for a given position based on the activation percentage.
    * @param positionTicket Position ticket number
    * @return The activation price for the position, or 0 if the position cannot be selected
    */
   double GetActivationPrice(ulong positionTicket);

   double GetDeviationPriceFromCurrent(ulong positionTicket);

   double GetDeviationPriceFromOpen(ulong positionTicket);
};
