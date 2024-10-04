//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
/**
 * @class LimitsByIndex
 * @brief Class to calculate and retrieve price limits based on index for a given symbol and time frame.
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

   struct Setting
     {
      string            sym; ///< Trading symbol
      ENUM_TIMEFRAMES   timeFrame; ///< Time frame for the symbol
      uint              counter; ///< Number of periods to consider
      uint              shifter; ///< Shifting value for the index
     };


protected:
   Prices            prices; ///< Prices structure to hold calculated limits
   Setting           setting; ///< Setting structure

public:
   /**
    * @brief Default constructor for the LimitsByIndex class.
    */
                     LimitsByIndex(void);
                    ~LimitsByIndex(void);

   void              UpdateSetting(
      string sym,
      ENUM_TIMEFRAMES timeFrame,
      uint counter,
      uint shifter
   );

   void              GetSetting(Setting& s);

   Setting           GetSetting(void);

   bool              CheckSetting(void);

   string            SettingToString(void);

   /**
    * @brief Retrieves the structure containing calculated price limits.
    * @return Prices structure with the calculated limits
    */

   void              GetPrices(Prices& p);

   Prices            GetPrices(void);

   string            PricesToString(void);

   /**
    * @brief Calculates the upper and lower price limits based on index for the given symbol and time frame.
    */
   Prices              Run(void);

  };
//+------------------------------------------------------------------+
