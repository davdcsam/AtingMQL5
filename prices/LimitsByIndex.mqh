//+------------------------------------------------------------------+
//|                                                 AutomatedTrading |
//|                                         Copyright 2024, davdcsam |
//|                                      https://github.com/davdcsam |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| LimitsByIndex                                                    |
//+------------------------------------------------------------------+
class LimitsByIndex
  {
public:
   struct Prices
     {
      double         upper;
      uint           upperIndex;
      double         lower;
      uint           lowerIndex;
     };

protected:
   string            symbol;
   ENUM_TIMEFRAMES   timeframe;
   uint              counter;
   uint              shifter;
   Prices            prices;

public:
   // Constructor for the class. Initializes the symbol, timeframe, counter and shifter.
                     LimitsByIndex() {}

   void              UpdateAtr(string symbol_arg, ENUM_TIMEFRAMES timeframe_atr, uint counter_arg, uint shifter_arg)
     {
      symbol = symbol_arg;
      timeframe = timeframe_atr;
      counter = counter_arg;
      shifter = shifter_arg;
     };

   Prices            GetPricesStruct() { return prices; }

   // Method to calculate the near upper and lower limits.
   void              Get()
     {
      // Find the highest value for the given symbol and timeframe.
      prices.upperIndex = iHighest(symbol, timeframe, MODE_HIGH, counter, shifter);
      // Find the lowest value for the given symbol and timeframe.
      prices.lowerIndex = iLowest(symbol, timeframe, MODE_LOW, counter, shifter);

      // Get the high value at the upper limit index.
      prices.upper =    iHigh(symbol, timeframe, prices.upperIndex);
      // Get the low value at the lower limit index.
      prices.lower =    iLow(symbol, timeframe, prices.lowerIndex);
     }
  };
//+------------------------------------------------------------------+
