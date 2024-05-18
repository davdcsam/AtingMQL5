//+------------------------------------------------------------------+
//|                                                       Limits.mqh |
//|                                         Copyright 2024, davdcsam |
//|                                      https://github.com/davdcsam |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class LimitsByIndex
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
                     LimitsByIndex(string symbol_arg, ENUM_TIMEFRAMES timeframe_atr, uint counter_arg, uint shifter_arg)
     {
      symbol = symbol_arg;
      timeframe = timeframe_atr;
      counter = counter_arg;
      shifter = shifter_arg;
     };

   // The calculated upper limit.
   double            upper;
   // The calculated lower limit.
   double            lower;
   // The index of the upper limit.
   uint              index_upper;
   // The index of the lower limit.
   uint              index_lower;

   // Method to calculate the near upper and lower limits.
   void              Get()
     {
      // Find the highest value for the given symbol and timeframe.
      index_upper = iHighest(symbol, timeframe, MODE_HIGH, counter, shifter);
      // Find the lowest value for the given symbol and timeframe.
      index_lower = iLowest(symbol, timeframe, MODE_LOW, counter, shifter);

      // Get the high value at the upper limit index.
      upper = iHigh(symbol, timeframe, index_upper);
      // Get the low value at the lower limit index.
      lower = iLow(symbol, timeframe, index_lower);
     }
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class LimitsByTimeRange
  {
public: // Custom
   enum ENUM_CHECK
     {
      CHECK_ARG_LIMITS_BY_TIME_RANGE_PASSED, // Check for section time passed
      ERR_LIMITS_BY_TIME_RANGE_START_EQUAL_END, // Error: Start time is equal to end time
      ERR_LIMITS_BY_TIME_RANGE_START_OVER_END, // Error: Start Time is over end time
      ERR_LIMITS_BY_TIME_RANGE_INCORRECT_FORMATTING // Error: Incorrect formating time
     };

   struct TimeRange
     {
      datetime       start;
      datetime       end;
     };

   struct Prices
     {
      double         upper;
      datetime       upper_datetime;
      double         lower;
      datetime       lower_datetime;
     };

private:
   uchar             previous_start_hour, previous_start_min, previous_start_sec, previous_end_hour, previous_end_min, previous_end_sec;
   ENUM_TIMEFRAMES   timeframes;
   string            symbol;

   void              Update()
     {
      TimeCurrent(dt);

      start_datetime.year = dt.year;
      start_datetime.mon = dt.mon;
      start_datetime.day = dt.day;
      start_datetime.hour = previous_start_hour;
      start_datetime.min = previous_start_min;
      start_datetime.sec = previous_start_sec;

      end_datetime.year = dt.year;
      end_datetime.mon = dt.mon;
      end_datetime.day = dt.day;
      end_datetime.hour = previous_end_hour;
      end_datetime.min = previous_end_min;
      end_datetime.sec = previous_end_sec;
     };

public:
                     LimitsByTimeRange(
      uchar prev_start_hour,
      uchar prev_start_min,
      uchar prev_start_sec,
      uchar prev_end_hour,
      uchar prev_end_min,
      uchar prev_end_sec,
      ENUM_TIMEFRAMES timeframes_arg,
      string symbol_arg
   )
     {
      previous_start_hour = prev_start_hour;
      previous_start_min = prev_start_min;
      previous_start_sec = prev_start_sec;
      previous_end_hour = prev_end_hour;
      previous_end_min = prev_end_min;
      previous_end_sec = prev_end_sec;
      timeframes = timeframes_arg;
      symbol = symbol_arg;
      ArraySetAsSeries(rates_limits, true);
     };

   MqlDateTime       start_datetime, end_datetime, dt;
   MqlRates          rates_limits[];
   TimeRange              time_range;
   Prices            prices;

   ENUM_CHECK        CheckArg()
     {
      Update();

      if(
         previous_start_hour >= 24 ||
         previous_end_hour >= 24 ||
         previous_start_min >= 60 ||
         previous_end_min >= 60 ||
         previous_start_sec >= 60 ||
         previous_end_sec >= 60
      )
         return(ERR_LIMITS_BY_TIME_RANGE_INCORRECT_FORMATTING);

      if(StructToTime(start_datetime) == StructToTime(end_datetime))
         return(ERR_LIMITS_BY_TIME_RANGE_START_EQUAL_END);

      if(StructToTime(start_datetime) > StructToTime(end_datetime))
         return(ERR_LIMITS_BY_TIME_RANGE_START_OVER_END);

      return(CHECK_ARG_LIMITS_BY_TIME_RANGE_PASSED);
     }

   string            EnumCheckToString(ENUM_CHECK enum_result)
     {
      string result;
      switch(enum_result)
        {
         case  CHECK_ARG_LIMITS_BY_TIME_RANGE_PASSED:
            result = StringFormat(
                        "%s: Arguments passed the check.",
                        EnumToString(enum_result)
                     );
            break;
         case ERR_LIMITS_BY_TIME_RANGE_START_EQUAL_END:
            result = StringFormat(
                        "%s: Start DateTime %s equals to End DateTime %s.",
                        EnumToString(enum_result),
                        TimeToString(time_range.start),
                        TimeToString(time_range.end)
                     );
            break;
         case ERR_LIMITS_BY_TIME_RANGE_START_OVER_END:
            result = StringFormat(
                        "%s: Start DateTime %s is over End DateTime %s.",
                        EnumToString(enum_result),
                        TimeToString(time_range.start),
                        TimeToString(time_range.end)
                     );
            break;
         case ERR_LIMITS_BY_TIME_RANGE_INCORRECT_FORMATTING:
            result = StringFormat(
                        "%s: Incorrect Formmating Inputs.",
                        EnumToString(enum_result)
                     );
            break;
         default:
            result = "Unknown error.";
            break;
        }
      return(result);
     }

   TimeRange            GetTimeRange()
     {
      Update();

      int multiplier = ((ENUM_DAY_OF_WEEK)dt.day_of_week == MONDAY) ? 3 : 1;

      time_range.start = StructToTime(start_datetime) - PeriodSeconds(PERIOD_D1) * multiplier;
      time_range.end = StructToTime(end_datetime) - PeriodSeconds(PERIOD_D1) * multiplier;

      return(time_range);
     };

   Prices            Get()
     {
      GetTimeRange();
      CopyRates(
         symbol,
         timeframes,
         time_range.start,
         time_range.end,
         rates_limits
      );

      prices.lower = rates_limits[0].low;
      prices.upper = rates_limits[0].high;

      for(int i=0; i<ArraySize(rates_limits); i++)
        {
         if(rates_limits[i].low < prices.lower)
           {
            prices.lower = rates_limits[i].low;
            prices.lower_datetime = rates_limits[i].time;
           }
         if(rates_limits[i].high > prices.upper)
           {
            prices.upper = rates_limits[i].high;
            prices.upper_datetime = rates_limits[i].time;
           }
        }

      return(prices);
     };
  };
//+------------------------------------------------------------------+