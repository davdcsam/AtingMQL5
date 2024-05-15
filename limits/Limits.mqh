//+------------------------------------------------------------------+
//|                                                       Limits.mqh |
//|                                         Copyright 2024, davdcsam |
//|                                      https://github.com/davdcsam |
//+------------------------------------------------------------------+

class Limits
  {
private:
   // The symbol for which the limits are calculated.
   string            symbol;
   // The timeframe for which the limits are calculated.
   ENUM_TIMEFRAMES   timeframe;
   // The counter used in the calculation of the limits.
   uint              counter;
   // The shifter
   uint              shifter;

public:
   // Constructor for the class. Initializes the symbol, timeframe, counter and shifter.
                     Limits(string symbol_arg, ENUM_TIMEFRAMES timeframe_atr, uint counter_arg, uint shifter_arg)
     {
      symbol = symbol_arg;
      timeframe = timeframe_atr;
      counter = counter_arg;
      shifter = shifter_arg;
     };

   // The calculated upper limit.
   double            limit_upper;
   // The calculated lower limit.
   double            limit_lower;
   // The index of the upper limit.
   uint              index_limit_upper;
   // The index of the lower limit.
   uint              index_limit_lower;

   // Method to calculate the near upper and lower limits.
   void              GetNearLimits()
     {
      // Find the highest value for the given symbol and timeframe.
      index_limit_upper = iHighest(symbol, timeframe, MODE_HIGH, counter, shifter);
      // Find the lowest value for the given symbol and timeframe.
      index_limit_lower = iLowest(symbol, timeframe, MODE_LOW, counter, shifter);

      // Get the high value at the upper limit index.
      limit_upper = iHigh(symbol, timeframe, index_limit_upper);
      // Get the low value at the lower limit index.
      limit_lower = iLow(symbol, timeframe, index_limit_lower);
     }
  };
//+------------------------------------------------------------------+
  