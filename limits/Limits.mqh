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
//|                                                                  |
//+------------------------------------------------------------------+
class LimitsByTimeRange
  {
public: // Custom
   enum ENUM_CHECK
     {
      PASSED, // Check for section time passed
      START_EQUAL_END, // Error: Start time is equal to end time
      START_OVER_END, // Error: Start Time is over end time
      INCORRECT_FORMATTING, // Error: Incorrect formating time
      RATES_NO_FOUND // Error: CopyRates no found the range time
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

protected:
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

   MqlDateTime       start_datetime, end_datetime, dt;
   MqlRates          rates_limits[];
   TimeRange              time_range;
   Prices            prices;

public:
                     LimitsByTimeRange(void) {}

   void              UpdateAtr(
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

   Prices            GetPricesStruct() { return prices; }
   
   TimeRange GetTimeRangeStruct() { return time_range; }

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
         return(INCORRECT_FORMATTING);

      if(StructToTime(start_datetime) == StructToTime(end_datetime))
         return(START_EQUAL_END);

      if(StructToTime(start_datetime) > StructToTime(end_datetime))
         return(START_OVER_END);

      if(prices.lower == 0 && prices.upper == 0)
         return(RATES_NO_FOUND);

      return(PASSED);
     }

   string            EnumCheckToString(ENUM_CHECK enum_result)
     {
      string result;
      switch(enum_result)
        {
         case  PASSED:
            result = StringFormat(
                        "%s: Arguments passed the check.",
                        EnumToString(enum_result)
                     );
            break;
         case START_EQUAL_END:
            result = StringFormat(
                        "%s: Start DateTime %s equals to End DateTime %s.",
                        EnumToString(enum_result),
                        TimeToString(time_range.start),
                        TimeToString(time_range.end)
                     );
            break;
         case START_OVER_END:
            result = StringFormat(
                        "%s: Start DateTime %s is over End DateTime %s.",
                        EnumToString(enum_result),
                        TimeToString(time_range.start),
                        TimeToString(time_range.end)
                     );
            break;
         case INCORRECT_FORMATTING:
            result = StringFormat(
                        "%s: Incorrect Formmating Inputs.",
                        EnumToString(enum_result)
                     );
            break;
         case RATES_NO_FOUND:
            result = StringFormat(
                        "%s: CopyRates no found the range time.",
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

      if(!rates_limits.Size())
         return prices;

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
