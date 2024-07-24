//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+
#include <Arrays/ArrayDouble.mqh>

//+------------------------------------------------------------------+
/**
 * @class CalcStop
 * @brief Class to calculate stop loss and take profit prices.
 */
class CalcStop
  {
protected:
   /**
    * @enum ENUM_STOP_TYPE
    * @brief Enumeration to specify the type of stop (Take Profit or Stop Loss).
    */
   enum ENUM_STOP_TYPE
     {
      TAKE_PROFIT, /**< Take profit type. */
      STOP_LOSS    /**< Stop loss type. */
     };

   /**
    * @brief Internal function to calculate stop loss or take profit prices.
    * @param price Base price.
    * @param stop Distance of the stop in points.
    * @param type Position type (buy/sell).
    * @param stop_type Type of stop (Take Profit or Stop Loss).
    * @return Calculated stop price.
    */
   double            internal(double price, ulong stop, ENUM_POSITION_TYPE type, ENUM_STOP_TYPE stop_type);

public:
   /**
    * @brief Symbol of the asset for which stops are calculated.
    */
   string            symbol;

   /**
    * @brief Default constructor for CalcStop.
    */
                     CalcStop() {}

   /**
    * @brief Sets the symbol for stop calculation.
    * @param symbol_arg The symbol to set.
    */
   void              SetSymbol(string& symbol_arg) { symbol = symbol_arg; }

   /**
    * @brief Calculates the stop price based on provided parameters.
    * @param price Base price.
    * @param stop Distance of the stop in points.
    * @param type Position type (buy/sell).
    * @param stop_type Type of stop (Take Profit or Stop Loss).
    * @return Calculated stop price.
    */
   double            Run(double price, long stop, ENUM_POSITION_TYPE type, ENUM_STOP_TYPE stop_type);

   /**
    * @brief Verifies that a single price is not negative.
    * @param price The price to check.
    * @return True if the price is non-negative, false otherwise.
    */
   static bool       VerifyNoNegative(double price);

   /**
    * @brief Verifies that all prices in an array are not negative.
    * @param prices Array of prices to check.
    * @return True if all prices are non-negative, false otherwise.
    */
   static bool       VerifyNoNegative(double &prices[]);

   /**
    * @brief Verifies that all prices in a CArrayDouble are not negative.
    * @param prices Array of prices to check.
    * @return True if all prices are non-negative, false otherwise.
    */
   static bool       VerifyNoNegative(CArrayDouble &prices);
  };

//+------------------------------------------------------------------+
double CalcStop::internal(double price, ulong stop, ENUM_POSITION_TYPE type, ENUM_STOP_TYPE stop_type)
  {
   return (type == POSITION_TYPE_BUY) ?
          (
             (stop_type == TAKE_PROFIT) ?
             NormalizeDouble(price + stop * SymbolInfoDouble(symbol, SYMBOL_POINT), (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS)) :
             NormalizeDouble(price - stop * SymbolInfoDouble(symbol, SYMBOL_POINT), (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS))
          ) :
          (
             (stop_type == TAKE_PROFIT) ?
             NormalizeDouble(price - stop * SymbolInfoDouble(symbol, SYMBOL_POINT), (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS)) :
             NormalizeDouble(price + stop * SymbolInfoDouble(symbol, SYMBOL_POINT), (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS))
          );
  }

//+------------------------------------------------------------------+
double CalcStop::Run(double price, long stop, ENUM_POSITION_TYPE type, ENUM_STOP_TYPE stop_type)
  {
   return internal(price, stop, type, stop_type);
  }

//+------------------------------------------------------------------+
bool CalcStop::VerifyNoNegative(double price)
  {
   return price >= 0;
  }

//+------------------------------------------------------------------+
bool CalcStop::VerifyNoNegative(double &prices[])
  {
   int size = (int)ArraySize(prices);
   if(size == 0)
      return false;

   for(int i = 0; i < size; i++)
     {
      if(prices[i] < 0)
         return false;
     }
   return true;
  }

//+------------------------------------------------------------------+
bool CalcStop::VerifyNoNegative(CArrayDouble &prices)
  {
   int size = (int)prices.Total();
   if(size == 0)
      return false;

   for(int i = 0; i < size; i++)
     {
      if(prices.At(i) < 0)
         return false;
     }
   return true;
  }
//+------------------------------------------------------------------+
