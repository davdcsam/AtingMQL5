//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
/**
 * @class LimitsByIndex
 * @brief Class to calculate and retrieve price limits based on index for a given symbol and timeframe.
 */
class LimitsByIndex
  {
public:
   /**
    * @struct Prices
    * @brief Structure to store upper and lower price limits along with their indices.
    */
   struct Prices
     {
      double         upper; ///< Upper price limit
      uint           upperIndex; ///< Index of the upper price limit
      double         lower; ///< Lower price limit
      uint           lowerIndex; ///< Index of the lower price limit
     };

protected:
   string            symbol; ///< Trading symbol
   ENUM_TIMEFRAMES   timeframe; ///< Timeframe for the symbol
   uint              counter; ///< Number of periods to consider
   uint              shifter; ///< Shifting value for the index
   Prices            prices; ///< Prices structure to hold calculated limits

public:
   /**
    * @brief Default constructor for the LimitsByIndex class.
    */
                     LimitsByIndex() {}

   /**
    * @brief Updates the parameters for the class.
    * @param symbol_arg Trading symbol
    * @param timeframe_atr Timeframe for the symbol
    * @param counter_arg Number of periods to consider
    * @param shifter_arg Shifting value for the index
    */
   void              UpdateAtr(string symbol_arg, ENUM_TIMEFRAMES timeframe_atr, uint counter_arg, uint shifter_arg);

   /**
    * @brief Retrieves the structure containing calculated price limits.
    * @return Prices structure with the calculated limits
    */
   Prices            GetPricesStruct() { return prices; }

   /**
    * @brief Calculates the upper and lower price limits based on index for the given symbol and timeframe.
    */
   void              Get();
  };

//+------------------------------------------------------------------+
void LimitsByIndex::UpdateAtr(string symbol_arg, ENUM_TIMEFRAMES timeframe_atr, uint counter_arg, uint shifter_arg)
  {
   symbol = symbol_arg;
   timeframe = timeframe_atr;
   counter = counter_arg;
   shifter = shifter_arg;
  }
//+------------------------------------------------------------------+
void LimitsByIndex::Get()
  {
// Find the highest value for the given symbol and timeframe.
   prices.upperIndex = iHighest(symbol, timeframe, MODE_HIGH, counter, shifter);
// Find the lowest value for the given symbol and timeframe.
   prices.lowerIndex = iLowest(symbol, timeframe, MODE_LOW, counter, shifter);

// Get the high value at the upper limit index.
   prices.upper = iHigh(symbol, timeframe, prices.upperIndex);
// Get the low value at the lower limit index.
   prices.lower = iLow(symbol, timeframe, prices.lowerIndex);
  }
//+------------------------------------------------------------------+
