//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+

/**
 * @class LimitsByIndex
 * @brief Class for calculating and retrieving upper and lower price limits based on index for a specified symbol and time frame.
 */
class LimitsByIndex
  {
public:
   /**
    * @struct Prices
    * @brief Structure to store the upper and lower price limits along with their respective indices.
    */
   struct Prices
     {
      double         upper;    ///< Upper price limit
      uint           upperIndex; ///< Index corresponding to the upper price limit
      double         lower;    ///< Lower price limit
      uint           lowerIndex; ///< Index corresponding to the lower price limit
     };

   /**
    * @struct Setting
    * @brief Structure to store the settings for the calculation, including symbol, time frame, number of periods, and index shift.
    */
   struct Setting
     {
      string         sym;                ///< Trading symbol (e.g., "EURUSD").
      ENUM_TIMEFRAMES timeFrame; ///< Time frame for the symbol (e.g., PERIOD_M1, PERIOD_D1).
      uint           counter;              ///< Number of periods to consider for the limit calculation.
      uint           shifter;              ///< Shift applied to the index (for offsetting data).
     };

protected:
   Prices            prices;   ///< Prices structure to hold the calculated limits.
   Setting           setting; ///< Current settings for the limit calculation.

public:
   /**
    * @brief Default constructor for the LimitsByIndex class.
    */
                     LimitsByIndex(void);

   /**
    * @brief Destructor for the LimitsByIndex class.
    */
                    ~LimitsByIndex(void);

   /**
    * @brief Updates the settings for the price limit calculation.
    * @param sym The symbol for which limits are calculated (e.g., "EURUSD").
    * @param timeFrame The time frame to use (e.g., PERIOD_M5).
    * @param counter Number of periods to consider for the limit calculation.
    * @param shifter Index shift value to adjust the reference point for limits.
    */
   void              UpdateSetting(
      string sym,
      ENUM_TIMEFRAMES timeFrame,
      uint counter,
      uint shifter);

   /**
    * @brief Retrieves the current settings by reference.
    * @param s Reference to a Setting structure where the current settings will be stored.
    */
   void              GetSetting(Setting &s);

   /**
    * @brief Retrieves the current settings.
    * @return A Setting structure containing the symbol, time frame, counter, and shifter values.
    */
   Setting           GetSetting(void);

   /**
    * @brief Checks whether the current settings are valid.
    * @return True if the settings are valid, otherwise false.
    */
   bool              CheckSetting(void);

   /**
    * @brief Converts the current settings to a readable string format.
    * @return A string representing the current settings (symbol, time frame, etc.).
    */
   string            SettingToString(void);

   /**
    * @brief Retrieves the calculated price limits by reference.
    * @param p Reference to a Prices structure where the calculated limits will be stored.
    */
   void              GetPrices(Prices &p);

   /**
    * @brief Retrieves the calculated price limits.
    * @return A Prices structure containing the upper and lower price limits and their respective indices.
    */
   Prices            GetPrices(void);

   /**
    * @brief Converts the calculated price limits to a readable string format.
    * @return A string representing the upper and lower limits and their respective indices.
    */
   string            PricesToString(void);

   /**
    * @brief Calculates the upper and lower price limits based on index for the current settings (symbol, time frame, etc.).
    * @return A Prices structure containing the newly calculated upper and lower price limits along with their indices.
    */
   Prices            Run(void);
  };
//+------------------------------------------------------------------+
