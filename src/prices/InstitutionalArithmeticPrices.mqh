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
    * @enum ENUM_CHECK
    * @brief Enum for handling different types of errors and checks in line generation.
    */
   enum ENUM_CHECK
     {
      CHECK_ARG_LINE_GENERATOR_PASSED, ///< Check passed
      ERR_NO_ENOUGH_STEP, ///< Error: Not enough steps
      ERR_START_OVER_END, ///< Error: Start is greater than end
      ERR_ADD_OVER_STEP, ///< Error: Addition is greater than step
      ERR_PRICE_OUT_LINES ///< Error: Price is out of lines
     };

   /**
    * @enum ENUM_TYPE_NEAR_LINES
    * @brief Enum for handling different types of near lines.
    */
   enum ENUM_TYPE_NEAR_LINES
     {
      TYPE_BETWEEN_PARALLELS, ///< Type: Between parallels
      TYPE_INSIDE_PARALLEL, ///< Type: Inside parallel
      ERR_INVALID_LINES ///< Error: Invalid lines
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
    * @brief Checks the arguments for line generation.
    * @return The result of the check as ENUM_CHECK
    */
   ENUM_CHECK        CheckArg();

   /**
    * @brief Converts the ENUM_CHECK result to a string.
    * @param enum_result The ENUM_CHECK result to convert
    * @return A string representation of the enum result
    */
   string            EnumCheckToString(ENUM_CHECK enum_result);

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
template<typename T>
T InstitutionalArithmeticPrices::calcArithmeticSequenceTerm(T n)
  {
   return setting.init + (n) * setting.step - (MathMod(n, 2) == 0 ? 0 : setting.add);
  }

//+------------------------------------------------------------------+
void InstitutionalArithmeticPrices::UpdateSetting(double init, double step, double add)
  {
   setting.init = init;
   setting.step = step;
   setting.add = add;
  }

//+------------------------------------------------------------------+
InstitutionalArithmeticPrices::Setting InstitutionalArithmeticPrices::GetSetting()
  {
   return setting;
  }

//+------------------------------------------------------------------+
void InstitutionalArithmeticPrices::GetSetting(Setting &param)
  {
   param = setting;
  }

//+------------------------------------------------------------------+
InstitutionalArithmeticPrices::ENUM_CHECK InstitutionalArithmeticPrices::CheckArg()
  {
   if(setting.add > setting.step)
      return ERR_ADD_OVER_STEP;

   return CHECK_ARG_LINE_GENERATOR_PASSED;
  }

//+------------------------------------------------------------------+
string InstitutionalArithmeticPrices::EnumCheckToString(ENUM_CHECK enum_result)
  {
   string result;

   switch(enum_result)
     {
      case CHECK_ARG_LINE_GENERATOR_PASSED:
         result = StringFormat(
                     "%s: Arguments passed the check.",
                     EnumToString(enum_result)
                  );
         break;
      case ERR_ADD_OVER_STEP:
         result = StringFormat(
                     "%s: Add value %s is greater than step value %s.",
                     EnumToString(enum_result),
                     DoubleToString(setting.add, _Digits),
                     DoubleToString(setting.step, _Digits)
                  );
         break;
      default:
         result = "Unknown error.";
         break;
     }

   return result;
  }

//+------------------------------------------------------------------+
InstitutionalArithmeticPrices::Prices InstitutionalArithmeticPrices::Generate(double closePrice)
  {
   double n = MathFloor((closePrice - setting.init) / setting.step) + 1;

   if(closePrice >= calcArithmeticSequenceTerm(n))
     {
      if(closePrice > calcArithmeticSequenceTerm(n) && closePrice < calcArithmeticSequenceTerm(n) + setting.add)
        {
         prices.upperBuy = calcArithmeticSequenceTerm(n + 1);
         prices.upperSell = calcArithmeticSequenceTerm(n) + setting.add;
         prices.lowerBuy = calcArithmeticSequenceTerm(n);
         prices.lowerSell = calcArithmeticSequenceTerm(n - 1) + setting.add;
         prices.typeNearLines = TYPE_INSIDE_PARALLEL;
         return prices;
        }
     }
   else
     {
      if(closePrice > calcArithmeticSequenceTerm(n - 1) && closePrice < calcArithmeticSequenceTerm(n - 1) + setting.add)
        {
         prices.upperBuy = calcArithmeticSequenceTerm(n);
         prices.upperSell = calcArithmeticSequenceTerm(n - 1) + setting.add;
         prices.lowerBuy = calcArithmeticSequenceTerm(n - 1);
         prices.lowerSell = calcArithmeticSequenceTerm(n - 2) + setting.add;
         prices.typeNearLines = TYPE_INSIDE_PARALLEL;
         return prices;
        }
     }

   prices.upperSell = calcArithmeticSequenceTerm(n) + setting.add;
   prices.upperBuy = calcArithmeticSequenceTerm(n);
   prices.lowerSell = calcArithmeticSequenceTerm(n - 1) + setting.add;
   prices.lowerBuy = calcArithmeticSequenceTerm(n - 1);
   prices.typeNearLines = TYPE_BETWEEN_PARALLELS;
   return prices;
  }

//+------------------------------------------------------------------+
string InstitutionalArithmeticPrices::CommentToShow()
  {
   string result;

   switch(prices.typeNearLines)
     {
      case TYPE_BETWEEN_PARALLELS:
         result = StringFormat(
                     "\n Upper Sell %s, Upper Buy %s\n Lower Sell %s, Lower Buy %s\n",
                     DoubleToString(prices.upperSell, _Digits),
                     DoubleToString(prices.upperBuy, _Digits),
                     DoubleToString(prices.lowerSell, _Digits),
                     DoubleToString(prices.lowerBuy, _Digits)
                  );
         break;
      case TYPE_INSIDE_PARALLEL:
         result = StringFormat(
                     "\n Upper Buy %s\n Upper Sell %s, Lower Buy %s\n Lower Sell %s\n",
                     DoubleToString(prices.upperBuy, _Digits),
                     DoubleToString(prices.upperSell, _Digits),
                     DoubleToString(prices.lowerBuy, _Digits),
                     DoubleToString(prices.lowerSell, _Digits)
                  );
         break;
      case ERR_INVALID_LINES:
         result = "\n Invalid Lines \n";
         break;
     }

   return result;
  }
//+------------------------------------------------------------------+
