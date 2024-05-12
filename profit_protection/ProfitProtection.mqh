//+------------------------------------------------------------------+
//|                                                 ProfitProtection |
//|                                         Copyright 2024, davdcsam |
//|                                      https://github.com/davdcsam |
//+------------------------------------------------------------------+

#include <Trade/Trade.mqh>
#include "..//detect//DetectPositions.mqh";

enum ENUM_PROFIT_PROTECTION_TYPE
  {
   TRAILING_STOP,
   BREAK_EVEN
  };

// Class definition for ProfitProtection
class ProfitProtection
  {
protected:
   // Member variables
   double             activation_percent; // Activation percentage for profit protection
   double             deviation_percent; // Deviation percentage for profit protection
   ulong             magic; // Magic number for trade operations
   string            symbol; // Trading symbol
   CTrade            trade; // Trade object for performing trade operations
   DetectPositions   detect_positions; // Object for detecting positions

   // Method to modify stop loss for a buy position
   void              ModifyStopLossFromPositionBuy(ulong ticket, double new_stop_loss)
     {
      // If the position is not selected or the new stop loss is less than the current stop loss or greater than the current price, return
      if(
         !PositionSelectByTicket(ticket) ||
         new_stop_loss <= PositionGetDouble(POSITION_SL) ||
         new_stop_loss >= PositionGetDouble(POSITION_PRICE_CURRENT)
      )
         return;

      // Modify the position with the new stop loss
      trade.PositionModify(ticket, new_stop_loss, PositionGetDouble(POSITION_TP));
     }

   // Method to modify stop loss for a sell position
   void              ModifyStopLossFromPositionSell(ulong ticket, double new_stop_loss)
     {
      // If the position is not selected or the new stop loss is greater than the current stop loss or less than the current price, return
      if(
         !PositionSelectByTicket(ticket) ||
         new_stop_loss >= PositionGetDouble(POSITION_SL) ||
         new_stop_loss <= PositionGetDouble(POSITION_PRICE_CURRENT)
      )
         return;

      // Modify the position with the new stop loss
      trade.PositionModify(ticket, new_stop_loss, PositionGetDouble(POSITION_TP));
     }

public:
   // Constructor for ProfitProtection class
                     ProfitProtection(
      double activation_percent_arg, // Activation percentage argument
      double deviation_percent_arg // Deviation percentage argument
   )
     {
      // Initialize member variables
      activation_percent = activation_percent_arg;
      deviation_percent = deviation_percent_arg;
     }

   // Method to update required ATR
   void              UpdateRequiredAtr(
      ulong magic_arg, // Magic number argument
      string symbol_arg // Symbol argument
   )
     {
      // Update member variables
      magic = magic_arg;
      symbol = symbol_arg;
      // Update ATR for the given symbol and magic number
      detect_positions.UpdateAtr(symbol_arg, magic_arg);
     }
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

// Class definition for BreakEven
class BreakEven : public ProfitProtection
  {
public:
   // Constructor for BreakEven class
                     BreakEven(
      uchar activation_percent_arg, // Activation percentage argument
      uchar deviation_percent_arg // Deviation percentage argument
   )
      :              ProfitProtection(activation_percent_arg, deviation_percent_arg) {} // Call the base class constructor

   // Method to verify the positions
   void              Verify()
     {
      // Get the total number of positions
      int total_position = PositionsTotal();

      // If there are no positions, return
      if(!total_position)
         return;

      // Loop through all positions
      for(int i=0; i<total_position; i++)
        {
         // Get the ticket number for the position
         ulong ticket = PositionGetTicket(i);

         // If the position is not valid, continue to the next position
         if(!detect_positions.IsValidPosition(ticket))
            continue;

         // If the position cannot be selected, continue to the next position
         if(!PositionSelectByTicket(ticket))
            continue;

         // Calculate the price activation and the new stop loss
         double price_activation = (PositionGetDouble(POSITION_PRICE_OPEN) + (PositionGetDouble(POSITION_TP) - PositionGetDouble(POSITION_PRICE_OPEN)) * (activation_percent / 100));
         double new_stop_loss = NormalizeDouble(
                                   PositionGetDouble(POSITION_PRICE_OPEN) - (PositionGetDouble(POSITION_PRICE_OPEN) - PositionGetDouble(POSITION_TP)) * (deviation_percent / 100),
                                   (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS)
                                );

         // If the position is a buy position and the current price is greater than or equal to the price activation, modify the stop loss
         if(
            PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY &&
            PositionGetDouble(POSITION_PRICE_CURRENT) >= price_activation
         )
           {
            ModifyStopLossFromPositionBuy(ticket, new_stop_loss);
           }

         // If the position is a sell position and the current price is less than or equal to the price activation, modify the stop loss
         if(
            PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL &&
            PositionGetDouble(POSITION_PRICE_CURRENT) <= price_activation
         )
           {
            ModifyStopLossFromPositionSell(ticket, new_stop_loss);
           }
        }
     }
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

// Class definition for TrailingStop
class TrailingStop : public ProfitProtection
  {
public:
   // Constructor for TrailingStop class
                     TrailingStop(
      uchar activation_percent_arg, // Activation percentage argument
      uchar deviation_percent_arg // Deviation percentage argument
   )
      :              ProfitProtection(activation_percent_arg, deviation_percent_arg) {} // Call the base class constructor

   // Method to verify the positions
   void              Verify()
     {
      // Get the total number of positions
      int total_positions = PositionsTotal();

      // If there are no positions, return
      if(!total_positions)
         return;

      // Loop through all positions
      for(int i=0; i<total_positions; i++)
        {
         // Get the ticket number for the position
         ulong ticket = PositionGetTicket(i);

         // If the position is not valid, continue to the next position
         if(!detect_positions.IsValidPosition(ticket))
            continue;

         // If the position cannot be selected, continue to the next position
         if(!PositionSelectByTicket(ticket))
            continue;

         // Calculate the price activation and the new stop loss
         double price_activation = (PositionGetDouble(POSITION_PRICE_OPEN) + (PositionGetDouble(POSITION_TP) - PositionGetDouble(POSITION_PRICE_OPEN)) * (activation_percent / 100));
         double new_stop_loss = NormalizeDouble(
                                   PositionGetDouble(POSITION_PRICE_CURRENT) + (PositionGetDouble(POSITION_PRICE_OPEN) - PositionGetDouble(POSITION_TP)) * (deviation_percent / 100),
                                   (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS)
                                );

         // If the position is a buy position and the current price is greater than or equal to the price activation, modify the stop loss
         if(
            PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY &&
            PositionGetDouble(POSITION_PRICE_CURRENT) >= price_activation
         )
            ModifyStopLossFromPositionBuy(ticket, new_stop_loss);

         // If the position is a sell position and the current price is less than or equal to the price activation, modify the stop loss
         if(
            PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL &&
            PositionGetDouble(POSITION_PRICE_CURRENT) <= price_activation
         )
            ModifyStopLossFromPositionSell(ticket, new_stop_loss);
        }
     }
  };
//+------------------------------------------------------------------+
