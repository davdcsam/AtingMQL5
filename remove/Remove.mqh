//+------------------------------------------------------------------+
//|                                                 AutomatedTrading |
//|                                         Copyright 2024, davdcsam |
//|                                      https://github.com/davdcsam |
//+------------------------------------------------------------------+

#include <Arrays/ArrayLong.mqh>
#include <Trade/Trade.mqh>
#include "..//detect//DetectOrders.mqh";
#include "..//detect//DetectPositions.mqh";

//+------------------------------------------------------------------+
//| Remove                                                           |
//+------------------------------------------------------------------+
// Class to handle removal of orders and positions
class Remove
  {
protected:
   // Trade object
   CTrade            trade;

   // DetectOrders and Detect Positions objects
   DetectOrders      detectOrders;
   DetectPositions   detectPositions;

   // Variables to store magic number, symbol
   ulong             magic;
   string            symbol;

   // Function to remove orders from an array
   bool              RemoveOrdersFromCArray(CArrayLong& orders_to_delete)
     {
      bool result = true;

      if(!orders_to_delete.Total())
         return false;

      for(int i=0; i < orders_to_delete.Total(); i++)
        {
         if(!detectOrders.IsValidOrder(orders_to_delete.At(i)))
            continue;

         if(!trade.OrderDelete(orders_to_delete.At(i)))
            result = false;
        }
      return(result);
     }

   // Function to remove positions from an array
   bool              RemovePositionsFromCArray(CArrayLong& positions_to_delete)
     {
      bool result = true;

      if(!positions_to_delete.Total())
         return false;

      for(int i=0; i < positions_to_delete.Total(); i++)
        {
         if(!detectPositions.IsValidPosition(positions_to_delete.At(i)))
            continue;

         if(!trade.PositionClose(positions_to_delete.At(i)))
            result = false;
        }

      return(result);
     }

   // Function to update attributes for DetectOrders and DetectPositions objects
   void              UpdateAtrToDetect(ulong magic_arg, string symbol_arg)
     {
      detectOrders.UpdateAtr(symbol_arg, magic_arg);
      detectPositions.UpdateAtr(symbol_arg, magic_arg);
     }

public:
   // Constructor for the Remove class
                     Remove() {}

   // Function to update attributes
   void              UpdateAtr(ulong magic_arg, string symbol_arg)
     {
      magic = magic_arg;
      symbol = symbol_arg;
      UpdateAtrToDetect(magic_arg, symbol_arg);
     }

   // Function to remove pending orders
   bool              RemovePendingOrders()
     {
      // If there are no orders, return
      if(!OrdersTotal())
         return false;

      // Update the orders
      detectOrders.UpdateOrders();

      // Remove the orders from the array
      return RemoveOrdersFromCArray(detectOrders.orderTickets);
     }

   // Function to remove positions
   bool              RemovePositions()
     {
      // If there are no positions, return
      if(!PositionsTotal())
         return false;

      // Update the positions
      detectPositions.UpdatePositions();

      // Remove the positions from the array
      return RemovePositionsFromCArray(detectPositions.positionsTickets);
     }

  };
//+------------------------------------------------------------------+
