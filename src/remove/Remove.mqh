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
public:
   /**
    * @struct Setting
    * @brief Inherits settings from IDetectEntity.
    */
   struct Setting : public IDetectEntity::Setting { };

protected:

   /**
    * @brief Settings object to store configuration for symbol and magic number.
    */
   Setting           setting;

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

public:
   /**
    * @brief Default constructor for the Remove class.
    */
                     Remove() {}

   /**
    * @brief Updates settings for the Remove class with a symbol and magic number.
    * @param sym Trading symbol.
    * @param magic Magic number.
    */
   void              UpdateSetting(string sym, ulong magic);

   /**
    * @brief Updates settings for the Remove class with a symbol, magic number, and specific DetectOrders and DetectPositions objects.
    * @param sym Trading symbol.
    * @param magic Magic number.
    * @param dO DetectOrders object.
    * @param dP DetectPositions object.
    */
   void              UpdateSetting(string sym, ulong magic, DetectOrders &dO, DetectPositions &dP);

   /**
    * @brief Returns the current settings of the Remove class.
    * @return Setting object containing the symbol and magic number.
    */
   Setting           GetSetting(void);

   /**
    * @brief Checks if the current settings are valid.
    * @return True if settings are valid, otherwise false.
    */
   bool              CheckSetting(void);

   /**
    * @brief Removes all pending orders detected by the DetectOrders object.
    * @return True if all pending orders were removed successfully, otherwise false.
    */
   bool              RemovePendingOrders();

   /**
    * @brief Removes all positions detected by the DetectPositions object.
    * @return True if all positions were removed successfully, otherwise false.
    */
   bool              RemovePositions();

   /**
    * @brief Removes orders from an array of order tickets.
    * @param tickets Array of order tickets to remove.
    * @return True if all orders were removed successfully, otherwise false.
    */
   bool              RemoveOrdersFromCArray(CArrayLong& tickets);

   /**
    * @brief Removes positions from an array of position tickets.
    * @param tickets Array of position tickets to remove.
    * @return True if all positions were removed successfully, otherwise false.
    */
   bool              RemovePositionsFromCArray(CArrayLong& tickets);
  };

//+------------------------------------------------------------------+
void Remove::UpdateSetting(string sym, ulong magic)
  {
   this.setting.identifierString = sym;
   this.setting.identifierLong = magic;
   detectOrders.UpdateSetting(this.setting.identifierString, this.setting.identifierLong);
   detectPositions.UpdateSetting(this.setting.identifierString, this.setting.identifierLong);
  }

//+------------------------------------------------------------------+
void Remove::UpdateSetting(string sym, ulong magic, DetectOrders &dO, DetectPositions &dP)
  {
   this.setting.identifierString = sym;
   this.setting.identifierLong = magic;
   detectOrders = dO;
   detectPositions = dP;
  }

//+------------------------------------------------------------------+
Remove::Setting Remove::GetSetting(void)
  { return this.setting; }

//+------------------------------------------------------------------+
bool Remove::CheckSetting(void)
  {
   return (
             !ZeroProcessor::Run(this.setting.identifierLong, true) &&
             SystemRequirements::SymbolCommon(this.setting.identifierString)
          );
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
bool Remove::RemoveOrdersFromCArray(CArrayLong& tickets)
  {
   bool result = true;

   if(tickets.Total() == 0)
      return false;

   for(int i = 0; i < tickets.Total(); i++)
     {
      if(!detectOrders.IsValid(tickets.At(i)))
         continue;

      if(!trade.OrderDelete(tickets.At(i)))
         result = false;
     }
   return result;
  }

//+------------------------------------------------------------------+
bool Remove::RemovePositionsFromCArray(CArrayLong& tickets)
  {
   bool result = true;

   if(tickets.Total() == 0)
      return false;

   for(int i = 0; i < tickets.Total(); i++)
     {
      if(!detectPositions.IsValid(tickets.At(i)))
         continue;

      if(!trade.PositionClose(tickets.At(i)))
         result = false;
     }

   return result;
  }
//+------------------------------------------------------------------+
