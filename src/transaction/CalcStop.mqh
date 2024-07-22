//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+

#include <Arrays/ArrayDouble.mqh>

//+------------------------------------------------------------------+
//| CalcStop                                                         |
//+------------------------------------------------------------------+
class CalcStop
  {
protected:
   enum ENUM_STOP_TYPE
     {
      TAKE_PROFIT,
      STOP_LOSS
     };

   double            internal(double price, ulong stop, ENUM_POSITION_TYPE type, ENUM_STOP_TYPE stop_type)
     {
      return (type == POSITION_TYPE_BUY) ?
             (
                (stop_type == TAKE_PROFIT) ?
                NormalizeDouble(price + stop * SymbolInfoDouble(symbol, SYMBOL_POINT), (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS)):
                NormalizeDouble(price - stop * SymbolInfoDouble(symbol, SYMBOL_POINT), (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS))
             ):
             (
                (stop_type == TAKE_PROFIT) ?
                NormalizeDouble(price - stop * SymbolInfoDouble(symbol, SYMBOL_POINT), (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS)):
                NormalizeDouble(price + stop * SymbolInfoDouble(symbol, SYMBOL_POINT), (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS))
             );
     }

public:
   string            symbol;

                     CalcStop() {}
   void              SetSymbol(string& symbol_arg) {symbol = symbol_arg; }

   double            Run(double price, long stop, ENUM_POSITION_TYPE type, ENUM_STOP_TYPE stop_type) { return internal(price, stop, type, stop_type); }

   static bool              VerifyNoNegative(double price) { return price >= 0 ? true : false; }

   static bool              VerifyNoNegative(double &prices[])
     {
      int size = (int)prices.Size();

      if(!size)
         return false;

      for(int i=0;i<size;i++)
        {
         if(prices[i] < 0)
            return false;
        }
      return true;
     }

   static bool              VerifyNoNegative(CArrayDouble &prices)
     {
      int size = (int)prices.Total();

      if(!size)
         return false;

      for(int i=0;i<size;i++)
        {
         if(prices.At(i) < 0)
            return false;
        }
      return true;
     }

  };
//+------------------------------------------------------------------+
