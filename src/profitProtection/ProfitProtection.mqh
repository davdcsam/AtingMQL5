//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+
#include <Trade/Trade.mqh>
#include "..//detect//DetectPositions.mqh";

//+------------------------------------------------------------------+
/**
 * @class ProfitProtection
 * @brief Class to handle profit protection mechanisms such as trailing stops and break-even adjustments.
 */
class ProfitProtection
  {
public:
   /**
    * @enum ENUM_PROFIT_PROTECTION_TYPE
    * @brief Enumeration of different profit protection types.
    */
   enum ENUM_PROFIT_PROTECTION_TYPE
     {
      TRAILING_STOP, ///< Trailing Stop protection
      BREAK_EVEN ///< Break Even protection
     };

   double            activationPercent; ///< Activation percentage for profit protection
   double            deviationPercent; ///< Deviation percentage for profit protection
   ulong             magic; ///< Magic number for trade operations
   string            symbol; ///< Trading symbol
   CTrade            trade; ///< Trade object for performing trade operations
   DetectPositions   detectPositions; ///< Object for detecting positions

   /**
    * @brief Default constructor for the ProfitProtection class.
    */
                     ProfitProtection(void) {}

   /**
    * @brief Updates the attributes of the ProfitProtection class.
    * @param magic_arg Magic number for trade operations
    * @param symbol_arg Trading symbol
    * @param activation_percent_arg Activation percentage for profit protection
    * @param deviation_percent_arg Deviation percentage for profit protection
    */
   void              UpdateAtr(
      ulong magic_arg, ///< Magic number argument
      string symbol_arg, ///< Symbol argument
      double activation_percent_arg, ///< Activation percentage argument
      double deviation_percent_arg ///< Deviation percentage argument
   );

   /**
    * @brief Modifies the stop loss for a buy position.
    * @param ticket Position ticket number
    * @param newStopLoss New stop loss value
    * @return True if stop loss was successfully modified, otherwise false
    */
   bool              ModifyStopLossFromPositionBuy(ulong ticket, double newStopLoss);

   /**
    * @brief Modifies the stop loss for a sell position.
    * @param ticket Position ticket number
    * @param newStopLoss New stop loss value
    * @return True if stop loss was successfully modified, otherwise false
    */
   bool              ModifyStopLossFromPositionSell(ulong ticket, double newStopLoss);

   /**
    * @brief Calculates the activation price for a given position based on the activation percentage.
    * @param positionTicket Position ticket number
    * @return The activation price for the position, or 0 if the position cannot be selected
    */
   double            GetActivationPrice(ulong positionTicket);
  };

//+------------------------------------------------------------------+
void ProfitProtection::UpdateAtr(
   ulong magic_arg,
   string symbol_arg,
   double activation_percent_arg,
   double deviation_percent_arg
)
  {
   activationPercent = activation_percent_arg;
   deviationPercent = deviation_percent_arg;
   magic = magic_arg;
   symbol = symbol_arg;
   detectPositions.UpdateAtr(symbol_arg, magic_arg);
  }

//+------------------------------------------------------------------+
bool ProfitProtection::ModifyStopLossFromPositionBuy(ulong ticket, double newStopLoss)
  {
   if(
      !PositionSelectByTicket(ticket) ||
      newStopLoss <= PositionGetDouble(POSITION_SL) ||
      newStopLoss >= PositionGetDouble(POSITION_PRICE_CURRENT)
   )
      return false;

   return trade.PositionModify(ticket, newStopLoss, PositionGetDouble(POSITION_TP));
  }

//+------------------------------------------------------------------+
bool ProfitProtection::ModifyStopLossFromPositionSell(ulong ticket, double newStopLoss)
  {
   if(
      !PositionSelectByTicket(ticket) ||
      newStopLoss >= PositionGetDouble(POSITION_SL) ||
      newStopLoss <= PositionGetDouble(POSITION_PRICE_CURRENT)
   )
      return false;

   return trade.PositionModify(ticket, newStopLoss, PositionGetDouble(POSITION_TP));
  }

//+------------------------------------------------------------------+
double ProfitProtection::GetActivationPrice(ulong positionTicket)
  {
   if(!PositionSelectByTicket(positionTicket))
      return 0;

   return (PositionGetDouble(POSITION_PRICE_OPEN) + (PositionGetDouble(POSITION_TP) - PositionGetDouble(POSITION_PRICE_OPEN)) * (activationPercent / 100));
  }
//+------------------------------------------------------------------+
