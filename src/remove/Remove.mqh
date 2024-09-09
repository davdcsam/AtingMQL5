//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+
#include <Arrays/ArrayLong.mqh>
#include <Trade/Trade.mqh>
#include "..//detect//DetectOrders.mqh"
#include "..//detect//DetectPositions.mqh"

//+------------------------------------------------------------------+
/**
 * @class Remove
 * @brief Class to handle the removal of orders and positions.
 */
class Remove
  {
protected:
   /**
    * @brief Trade object for performing trade operations.
    */
   CTrade            trade;

   /**
    * @brief Object for detecting orders.
    */
   DetectOrders      detectOrders;

   /**
    * @brief Object for detecting positions.
    */
   DetectPositions   detectPositions;

   /**
    * @brief Magic number for trade operations.
    */
   ulong             magic;

   /**
    * @brief Trading symbol.
    */
   string            symbol;

   /**
    * @brief Removes orders from an array of order tickets.
    * @param orders_to_delete Array of order tickets to remove.
    * @return True if all orders were removed successfully, otherwise false.
    */
   bool              RemoveOrdersFromCArray(CArrayLong& orders_to_delete);

   /**
    * @brief Removes positions from an array of position tickets.
    * @param positions_to_delete Array of position tickets to remove.
    * @return True if all positions were removed successfully, otherwise false.
    */
   bool              RemovePositionsFromCArray(CArrayLong& positions_to_delete);

   /**
    * @brief Updates attributes for DetectOrders and DetectPositions objects.
    * @param magic_arg Magic number.
    * @param symbol_arg Trading symbol.
    */
   void              UpdateAtrToDetect(ulong magic_arg, string symbol_arg);

public:
   /**
    * @brief Default constructor for the Remove class.
    */
                     Remove() {}

   /**
    * @brief Updates attributes for the Remove class.
    * @param magic_arg Magic number.
    * @param symbol_arg Trading symbol.
    */
   void              UpdateAtr(ulong magic_arg, string symbol_arg);

   /**
    * @brief Removes all pending orders.
    * @return True if all pending orders were removed successfully, otherwise false.
    */
   bool              RemovePendingOrders();

   /**
    * @brief Removes all positions.
    * @return True if all positions were removed successfully, otherwise false.
    */
   bool              RemovePositions();
  };

//+------------------------------------------------------------------+
bool Remove::RemoveOrdersFromCArray(CArrayLong& orders_to_delete)
  {
   bool result = true;

   if(orders_to_delete.Total() == 0)
      return false;

   for(int i = 0; i < orders_to_delete.Total(); i++)
     {
      if(!detectOrders.IsValid(orders_to_delete.At(i)))
         continue;

      if(!trade.OrderDelete(orders_to_delete.At(i)))
         result = false;
     }
   return result;
  }

//+------------------------------------------------------------------+
bool Remove::RemovePositionsFromCArray(CArrayLong& positions_to_delete)
  {
   bool result = true;

   if(positions_to_delete.Total() == 0)
      return false;

   for(int i = 0; i < positions_to_delete.Total(); i++)
     {
      if(!detectPositions.IsValid(positions_to_delete.At(i)))
         continue;

      if(!trade.PositionClose(positions_to_delete.At(i)))
         result = false;
     }

   return result;
  }

//+------------------------------------------------------------------+
void Remove::UpdateAtrToDetect(ulong magic_arg, string symbol_arg)
  {
   detectOrders.UpdateSetting(symbol_arg, magic_arg);
   detectPositions.UpdateSetting(symbol_arg, magic_arg);
  }

//+------------------------------------------------------------------+
void Remove::UpdateAtr(ulong magic_arg, string symbol_arg)
  {
   magic = magic_arg;
   symbol = symbol_arg;
   UpdateAtrToDetect(magic_arg, symbol_arg);
  }

//+------------------------------------------------------------------+
bool Remove::RemovePendingOrders()
  {
   if(!detectOrders.UpdateEntities())
      return false;
   return RemoveOrdersFromCArray(detectOrders.GetEntities());
  }

//+------------------------------------------------------------------+
bool Remove::RemovePositions()
  {
   if(!detectPositions.UpdateEntities())
      return false;
   return RemovePositionsFromCArray(detectPositions.GetEntities());
  }
//+------------------------------------------------------------------+
