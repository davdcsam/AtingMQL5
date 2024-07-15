//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+

#include <Trade/Trade.mqh>
#include "..//detect//DetectPositions.mqh";

//+------------------------------------------------------------------+
//| ProfitProtection                                                 |
//+------------------------------------------------------------------+
class ProfitProtection
  {
public:
   enum ENUM_PROFIT_PROTECTION_TYPE
     {
      TRAILING_STOP, // Trailing Stop
      BREAK_EVEN // Break Even
     };
   // Member variables
   double             activationPercent; // Activation percentage for profit protection
   double             deviationPercent; // Deviation percentage for profit protection
   ulong             magic; // Magic number for trade operations
   string            symbol; // Trading symbol
   CTrade            trade; // Trade object for performing trade operations
   DetectPositions   detectPositions; // Object for detecting positions

   // Constructor for ProfitProtection class
                     ProfitProtection(void) {}

   void              UpdateAtr(
      ulong magic_arg, // Magic number argument
      string symbol_arg, // Symbol argument
      double activation_percent_arg, // Activation percentage argument
      double deviation_percent_arg // Deviation percentage argument
   )
     {
      // Initialize member variables
      activationPercent = activation_percent_arg;
      deviationPercent = deviation_percent_arg;
      // Update member variables
      magic = magic_arg;
      symbol = symbol_arg;
      // Update ATR for the given symbol and magic number
      detectPositions.UpdateAtr(symbol_arg, magic_arg);
     }


   // Method to modify stop loss for a buy position
   bool              ModifyStopLossFromPositionBuy(ulong ticket, double newStopLoss)
     {
      // If the position is not selected or the new stop loss is less than the current stop loss or greater than the current price, return
      if(
         !PositionSelectByTicket(ticket) ||
         newStopLoss <= PositionGetDouble(POSITION_SL) ||
         newStopLoss >= PositionGetDouble(POSITION_PRICE_CURRENT)
      )
         return false;

      // Modify the position with the new stop loss
      return trade.PositionModify(ticket, newStopLoss, PositionGetDouble(POSITION_TP));
     }

   // Method to modify stop loss for a sell position
   bool              ModifyStopLossFromPositionSell(ulong ticket, double newStopLoss)
     {
      // If the position is not selected or the new stop loss is greater than the current stop loss or less than the current price, return
      if(
         !PositionSelectByTicket(ticket) ||
         newStopLoss >= PositionGetDouble(POSITION_SL) ||
         newStopLoss <= PositionGetDouble(POSITION_PRICE_CURRENT)
      )
         return false;

      // Modify the position with the new stop loss
      return trade.PositionModify(ticket, newStopLoss, PositionGetDouble(POSITION_TP));
     }

   double            GetActivationPrice(ulong positionTicket)
     {
      // If the position cannot be selected, continue to the next position
      if(!PositionSelectByTicket(positionTicket))
         return 0;

      // Calculate the price activation and the new stop loss
      return (PositionGetDouble(POSITION_PRICE_OPEN) + (PositionGetDouble(POSITION_TP) - PositionGetDouble(POSITION_PRICE_OPEN)) * (activationPercent / 100));
     }
  };
//+------------------------------------------------------------------+
