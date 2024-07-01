//+------------------------------------------------------------------+
//|                                                 ProfitProtection |
//|                                         Copyright 2024, davdcsam |
//|                                      https://github.com/davdcsam |
//+------------------------------------------------------------------+

#include <Trade/Trade.mqh>
#include "..//detect//DetectPositions.mqh";

enum ENUM_PROFIT_PROTECTION_TYPE
  {
   TRAILING_STOP, // Trailing Stop
   BREAK_EVEN // Break Even
  };

// Class definition for ProfitProtection
class ProfitProtection
  {
protected:
   // Member variables
   double             activationPercent; // Activation percentage for profit protection
   double             deviationPercent; // Deviation percentage for profit protection
   ulong             magic; // Magic number for trade operations
   string            symbol; // Trading symbol
   CTrade            trade; // Trade object for performing trade operations
   DetectPositions   detectPositions; // Object for detecting positions

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

public:
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
  };


//+------------------------------------------------------------------+
//| Class definition for BreakEven Stages                            |
//+------------------------------------------------------------------+
class BreakEvenStages : public ProfitProtection
  {
private:
   CArrayLong        positionTickets;
public:
                     BreakEvenStages(void) {};
                    ~BreakEvenStages(void) {};

   bool              UpdateTickets()
     {
      // Get the total number of positions
      int totalPositions = PositionsTotal();

      // If there are no positions, return
      if(!totalPositions)
         return false;

      // Loop through all positions
      for(int i=0; i<totalPositions; i++)
        {
         // Get the ticket number for the position
         ulong ticket = PositionGetTicket(i);

         // If the position is not valid, continue to the next position
         if(!detectPositions.IsValidPosition(ticket))
            continue;

         positionTickets.Add(ticket);
        }

      if(!positionTickets.Total())
         return false;

      return true;
     }

   void              Verify()
     {

      if(!positionTickets.Total())
         return;

      for(int i=0;i<positionTickets.Total();i++)
        {
         ulong positionTicket = positionTickets.At(i);

         if(!PositionSelectByTicket(positionTicket))
            continue;

         double priceActivation = GetActivationPrice(positionTicket);
         double newStopLoss = NormalizeDouble(
                                 PositionGetDouble(POSITION_PRICE_OPEN) - (PositionGetDouble(POSITION_PRICE_OPEN) - PositionGetDouble(POSITION_TP)) * (deviationPercent / 100),
                                 (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS)
                              );

         if(
            NormalizeDouble(PositionGetDouble(POSITION_PRICE_CURRENT), _Digits) == NormalizeDouble(priceActivation, _Digits)
         )
           {
            positionTickets.Delete(positionTickets.SearchLinear(positionTicket));
            continue;
           }

         // If the position is a buy position and the current price is greater than or equal to the price activation, modify the stop loss
         if(
            PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY &&
            PositionGetDouble(POSITION_PRICE_CURRENT) > priceActivation
         )
           {
            ModifyStopLossFromPositionBuy(positionTicket, newStopLoss);
            continue;
           }

         // If the position is a sell position and the current price is less than or equal to the price activation, modify the stop loss
         if(
            PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL &&
            PositionGetDouble(POSITION_PRICE_CURRENT) < priceActivation
         )
           {
            ModifyStopLossFromPositionSell(positionTicket, newStopLoss);
            continue;
           }
        }
     }

  };

//+------------------------------------------------------------------+
//| Class definition for BreakEven                                   |
//+------------------------------------------------------------------+
class BreakEven : public ProfitProtection
  {
public:
   // Constructor for BreakEven class
                     BreakEven(void) {}

   // Method to verify the positions
   void              Verify()
     {
      // Get the total number of positions
      int totalPositions = PositionsTotal();

      // If there are no positions, return
      if(!totalPositions)
         return;

      // Loop through all positions
      for(int i=0; i<totalPositions; i++)
        {
         // Get the ticket number for the position
         ulong ticket = PositionGetTicket(i);

         // If the position is not valid, continue to the next position
         if(!detectPositions.IsValidPosition(ticket))
            continue;

         // If the position cannot be selected, continue to the next position
         if(!PositionSelectByTicket(ticket))
            continue;

         // Calculate the price activation and the new stop loss
         double priceActivation = (PositionGetDouble(POSITION_PRICE_OPEN) + (PositionGetDouble(POSITION_TP) - PositionGetDouble(POSITION_PRICE_OPEN)) * (activationPercent / 100));
         double newStopLoss = NormalizeDouble(
                                 PositionGetDouble(POSITION_PRICE_OPEN) - (PositionGetDouble(POSITION_PRICE_OPEN) - PositionGetDouble(POSITION_TP)) * (deviationPercent / 100),
                                 (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS)
                              );

         // If the position is a buy position and the current price is greater than or equal to the price activation, modify the stop loss
         if(
            PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY &&
            PositionGetDouble(POSITION_PRICE_CURRENT) >= priceActivation
         )
           {
            ModifyStopLossFromPositionBuy(ticket, newStopLoss);
           }

         // If the position is a sell position and the current price is less than or equal to the price activation, modify the stop loss
         if(
            PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL &&
            PositionGetDouble(POSITION_PRICE_CURRENT) <= priceActivation
         )
           {
            ModifyStopLossFromPositionSell(ticket, newStopLoss);
           }
        }
     }
  };

//+------------------------------------------------------------------+
//| Class definition for TrailingStop                                |
//+------------------------------------------------------------------+
class TrailingStop : public ProfitProtection
  {
public:
   // Constructor for TrailingStop class
                     TrailingStop(void) {}

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
         if(!detectPositions.IsValidPosition(ticket))
            continue;

         // If the position cannot be selected, continue to the next position
         if(!PositionSelectByTicket(ticket))
            continue;

         // Calculate the price activation and the new stop loss
         double priceActivation = (PositionGetDouble(POSITION_PRICE_OPEN) + (PositionGetDouble(POSITION_TP) - PositionGetDouble(POSITION_PRICE_OPEN)) * (activationPercent / 100));
         double newStopLoss = NormalizeDouble(
                                 PositionGetDouble(POSITION_PRICE_CURRENT) + (PositionGetDouble(POSITION_PRICE_OPEN) - PositionGetDouble(POSITION_TP)) * (deviationPercent / 100),
                                 (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS)
                              );

         // If the position is a buy position and the current price is greater than or equal to the price activation, modify the stop loss
         if(
            PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY &&
            PositionGetDouble(POSITION_PRICE_CURRENT) >= priceActivation
         )
            ModifyStopLossFromPositionBuy(ticket, newStopLoss);

         // If the position is a sell position and the current price is less than or equal to the price activation, modify the stop loss
         if(
            PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL &&
            PositionGetDouble(POSITION_PRICE_CURRENT) <= priceActivation
         )
            ModifyStopLossFromPositionSell(ticket, newStopLoss);
        }
     }
  };
//+------------------------------------------------------------------+
