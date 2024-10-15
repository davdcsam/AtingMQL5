//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+
#include "../../time/TimeHelper.mqh"
#include "../../CheckCommonSetting.mqh"
#include "../../SystemRequirements.mqh"

//+------------------------------------------------------------------+
/**
 * @class LimitsByTimeRange
 * @brief Class to calculate upper and lower price limits within a specific time range for a given symbol and timeframe.
 */
class LimitsByTimeRange
  {
public:
   /**
    * @struct TimeRange
    * @brief Structure to store the start and end datetime for the specified time range.
    */
   struct TimeRange
     {
      datetime       start; ///< Start datetime of the range.
      datetime       end;   ///< End datetime of the range.
     };

   /**
    * @struct Prices
    * @brief Structure to store the calculated upper and lower price limits along with their corresponding datetimes.
    */
   struct Prices
     {
      double         upper;          ///< Upper price limit within the time range.
      datetime       upperDatetime;  ///< Datetime when the upper price limit occurred.
      double         lower;          ///< Lower price limit within the time range.
      datetime       lowerDatetime;  ///< Datetime when the lower price limit occurred.
     };

   /**
    * @struct Setting
    * @brief Structure to store the symbol and time frame for the calculation.
    */
   struct Setting
     {
      string            sym;        ///< Trading symbol (e.g., "EURUSD").
      ENUM_TIMEFRAMES   timeFrame;  ///< Timeframe for the symbol (e.g., PERIOD_M5, PERIOD_D1).
     };

protected:
   MqlDateTime       start;       ///< Start datetime for the price limit calculation.
   MqlDateTime       end;         ///< End datetime for the price limit calculation.
   MqlDateTime       dt;          ///< Current datetime used for reference.
   MqlRates          rates[];     ///< Array to store rates within the specified time range.
   TimeRange         timeRange;   ///< TimeRange structure to define the start and end times.
   Prices            prices;      ///< Prices structure to hold the calculated limits.
   Setting           setting;     ///< Current settings for symbol and timeframe.

public:
   /**
    * @brief Default constructor for the LimitsByTimeRange class.
    */
                     LimitsByTimeRange(void);
   
   /**
    * @brief Destructor for the LimitsByTimeRange class.
    */
                    ~LimitsByTimeRange(void);

   /**
    * @brief Updates the settings for the time range price limit calculation.
    * @param sym The symbol for which limits are calculated (e.g., "EURUSD").
    * @param timeFrame The timeframe to use for the price calculation (e.g., PERIOD_M5).
    * @param startHour Starting hour of the time range.
    * @param startMin Starting minute of the time range.
    * @param startSec Starting second of the time range.
    * @param endHour Ending hour of the time range.
    * @param endMin Ending minute of the time range.
    * @param endSec Ending second of the time range.
    */
   void              UpdateSetting(
      string sym,
      ENUM_TIMEFRAMES timeFrame,
      uchar startHour,
      uchar startMin,
      uchar startSec,
      uchar endHour,
      uchar endMin,
      uchar endSec
   );

   /**
    * @brief Retrieves the current settings for the limit calculation.
    * @return A Setting structure containing the symbol and timeframe values.
    */
   Setting           GetSetting(void);

   /**
    * @brief Retrieves the current settings by reference.
    * @param s Reference to a Setting structure where the current settings will be stored.
    */
   void              GetSetting(Setting& s);

   /**
    * @brief Checks if the current settings are valid.
    * @return True if the settings are valid, otherwise false.
    */
   bool              CheckSetting(void);

   /**
    * @brief Retrieves the calculated price limits by reference.
    * @param p Reference to a Prices structure where the calculated limits will be stored.
    */
   void              GetPrices(Prices &p);

   /**
    * @brief Retrieves the calculated price limits.
    * @return A Prices structure containing the upper and lower price limits and their respective datetimes.
    */
   Prices            GetPrices(void);

   /**
    * @brief Calculates the time range based on the current datetime settings.
    * @return A TimeRange structure with the adjusted start and end times.
    */
   TimeRange         GetTimeRange(void);

   /**
    * @brief Retrieves the time range based on the current datetime settings by reference.
    * @param p Reference to a TimeRange structure where the calculated start and end times will be stored.
    */
   void              GetTimeRange(TimeRange &p);

   /**
    * @brief Retrieves the price limits within the specified time range.
    * @return A Prices structure containing the upper and lower price limits, along with their datetimes.
    */
   Prices            Run();
  };
//+------------------------------------------------------------------+
