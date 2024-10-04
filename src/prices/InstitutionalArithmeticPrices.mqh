//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+
#include <Arrays/ArrayDouble.mqh>

//+------------------------------------------------------------------+
/**
 * @class InstitutionalArithmeticPrices
 * @brief Class to handle arithmetic price calculations and validations for institutional trading.
 */
class InstitutionalArithmeticPrices
  {
public:
   /**
    * @enum ENUM_TYPE_NEAR_LINES
    * @brief Enum for handling different types of near lines.
    */
   enum ENUM_TYPE_NEAR_LINES
     {
      TYPE_BETWEEN_PARALLELS, ///< Type: Between parallels
      TYPE_INSIDE_PARALLEL, ///< Type: Inside parallel
     };

   /**
    * @struct Prices
    * @brief Structure to store computed prices and line type.
    */
   struct Prices
     {
      double         upperBuy; ///< Upper buy price
      double         upperSell; ///< Upper sell price
      double         lowerBuy; ///< Lower buy price
      double         lowerSell; ///< Lower sell price
      ENUM_TYPE_NEAR_LINES typeNearLines; ///< Type of near lines
     };

   /**
    * @struct Setting
    * @brief Structure to store arithmetic sequence settings.
    */
   struct Setting
     {
      double         init; ///< Start value for addition
      double         step; ///< Step size for arithmetic sequence
      double         add; ///< Additional value for adjustment
     };

private:
   Prices            prices; ///< Prices structure for results
   Setting           setting; ///< Settings for arithmetic sequence

   /**
    * @brief Calculates the term of an arithmetic sequence.
    * @param n The term index
    * @return The calculated term value
    */
   template<typename T>
   T                 calcArithmeticSequenceTerm(T n);

public:
   /**
    * @brief Default constructor for the InstitutionalArithmeticPrices class.
    */
                     InstitutionalArithmeticPrices(void) {}

   /**
    * @brief Updates the settings for arithmetic sequence.
    * @param init Start value for addition
    * @param step Step size for arithmetic sequence
    * @param add Additional value for adjustment
    */
   void              UpdateSetting(double init, double step, double add);

   /**
    * @brief Retrieves the current settings.
    * @return The current settings
    */
   Setting           GetSetting();

   /**
    * @brief Retrieves the current settings by reference.
    * @param param Reference to a Setting structure to store the settings
    */
   void              GetSetting(Setting &param);

   /**
    * @brief Checks if the current settings are valid.
    * @return True if the settings are valid; false otherwise.
    */
   bool CheckSetting(void);   

   /**
    * @brief Generates price levels based on the given close price.
    * @param closePrice The close price to use for generation
    * @return The computed Prices structure
    */
   Prices             Generate(double closePrice);

   /**
    * @brief Returns a formatted comment with line information.
    * @return A string with the line details
    */
   string              CommentToShow();
  };
//+------------------------------------------------------------------+
