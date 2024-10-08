//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+
#include "../time/TimeHelper.mqh"
#include "../CheckCommonSetting.mqh"
#include "../SystemRequirements.mqh"

//+------------------------------------------------------------------+
/**
 * @class LimitsByTimeRange
 * @brief Class to calculate price limits within a specific time range for a given symbol and timeframe.
 */
class LimitsByTimeRange
  {
public:
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

   struct Setting
     {
      string            sym; ///< Trading symbol
      ENUM_TIMEFRAMES   timeFrame; ///< Time frame for the symbol
     };

protected:
   MqlDateTime       start; ///< Start datetime for the calculation
   MqlDateTime       end; ///< End datetime for the calculation
   MqlDateTime       dt; ///< Current datetime
   MqlRates          rates[]; ///< Array to store rates within the time range
   TimeRange         timeRange; ///< Time range for the calculation
   Prices            prices; ///< Prices structure to hold calculated limits
   Setting           setting; ///< Setting structure
   
public:
   /**
    * @brief Default constructor for the LimitsByTimeRange class.
    */
                     LimitsByTimeRange(void);
                    ~LimitsByTimeRange(void);

   void              UpdateSetting(
      string sym,
      ENUM_TIMEFRAMES timeFrames,
      uchar startHour,
      uchar startMin,
      uchar startSec,
      uchar endHour,
      uchar endMin,
      uchar endSec
   );
   Setting           GetSetting(void);
   void              GetSetting(Setting& s);
   bool              CheckSetting(void);

   Prices            GetPrices(void);
   void              GetPrices(Prices &p);

   /**
    * @brief Calculates the time range based on the current and previous datetime settings.
    * @return TimeRange structure with the adjusted start and end times
    */
   TimeRange         GetTimeRange(void);

   /**
    * @brief Calculates the time range based on the current and previous datetime settings.
    * @param TimeRange structure with the adjusted start and end times
    */
   void              GetTimeRange(TimeRange &p);

   /**
    * @brief Retrieves the price limits within the specified time range.
    * @return Prices structure with the calculated upper and lower limits
    */
   Prices            Run();
  };
//+------------------------------------------------------------------+
