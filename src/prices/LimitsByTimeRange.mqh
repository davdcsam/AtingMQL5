//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
/**
 * @class LimitsByTimeRange
 * @brief Class to calculate price limits within a specific time range for a given symbol and timeframe.
 */
class LimitsByTimeRange
  {
public:
   /**
    * @enum ENUM_CHECK
    * @brief Enumeration for different check results.
    */
   enum ENUM_CHECK
     {
      PASSED, ///< Check for section time passed
      START_EQUAL_END, ///< Error: Start time is equal to end time
      START_OVER_END, ///< Error: Start time is over end time
      INCORRECT_FORMATTING, ///< Error: Incorrect formatting of time
      RATES_NO_FOUND ///< Error: No rates found for the given time range
     };

   /**
    * @struct TimeRange
    * @brief Structure to store the start and end datetime for the time range.
    */
   struct TimeRange
     {
      datetime       start; ///< Start datetime
      datetime       end; ///< End datetime
     };

   /**
    * @struct Prices
    * @brief Structure to store the upper and lower price limits along with their datetimes.
    */
   struct Prices
     {
      double         upper; ///< Upper price limit
      datetime       upperDatetime; ///< Datetime of the upper price limit
      double         lower; ///< Lower price limit
      datetime       lowerDatetime; ///< Datetime of the lower price limit
     };

protected:
   uchar             previous_start_hour; ///< Previous start hour
   uchar             previous_start_min; ///< Previous start minute
   uchar             previous_start_sec; ///< Previous start second
   uchar             previous_end_hour; ///< Previous end hour
   uchar             previous_end_min; ///< Previous end minute
   uchar             previous_end_sec; ///< Previous end second
   ENUM_TIMEFRAMES   timeframes; ///< Timeframe for the symbol
   string            symbol; ///< Trading symbol

   MqlDateTime       start_datetime; ///< Start datetime for the calculation
   MqlDateTime       end_datetime; ///< End datetime for the calculation
   MqlDateTime       dt; ///< Current datetime
   MqlRates          rates_limits[]; ///< Array to store rates within the time range
   TimeRange         time_range; ///< Time range for the calculation
   Prices            prices; ///< Prices structure to hold calculated limits

   /**
    * @brief Updates the start and end datetimes based on the previously set time parameters.
    */
   void              Update();

public:
   /**
    * @brief Default constructor for the LimitsByTimeRange class.
    */
                     LimitsByTimeRange() {}

   /**
    * @brief Updates the attributes of the class.
    * @param prev_start_hour Previous start hour
    * @param prev_start_min Previous start minute
    * @param prev_start_sec Previous start second
    * @param prev_end_hour Previous end hour
    * @param prev_end_min Previous end minute
    * @param prev_end_sec Previous end second
    * @param timeframes_arg Timeframe for the symbol
    * @param symbol_arg Trading symbol
    */
   void              UpdateAtr(
      uchar prev_start_hour,
      uchar prev_start_min,
      uchar prev_start_sec,
      uchar prev_end_hour,
      uchar prev_end_min,
      uchar prev_end_sec,
      ENUM_TIMEFRAMES timeframes_arg,
      string symbol_arg
   );

   /**
    * @brief Retrieves the structure containing calculated price limits.
    * @return Prices structure with the calculated limits
    */
   Prices            GetPricesStruct() { return prices; }

   /**
    * @brief Retrieves the structure containing the time range used for calculations.
    * @return TimeRange structure with the start and end times
    */
   TimeRange         GetTimeRangeStruct() { return time_range; }

   /**
    * @brief Checks the validity of the arguments for time range calculations.
    * @return ENUM_CHECK result indicating the outcome of the check
    */
   ENUM_CHECK        CheckArg();

   /**
    * @brief Converts the ENUM_CHECK result to a human-readable string.
    * @param enum_result ENUM_CHECK result
    * @return String representation of the ENUM_CHECK result
    */
   string            EnumCheckToString(ENUM_CHECK enum_result);

   /**
    * @brief Calculates the time range based on the current and previous datetime settings.
    * @return TimeRange structure with the adjusted start and end times
    */
   TimeRange         GetTimeRange();

   /**
    * @brief Retrieves the price limits within the specified time range.
    * @return Prices structure with the calculated upper and lower limits
    */
   Prices            Get();
  };
