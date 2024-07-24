//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+
#include <Arrays/ArrayDouble.mqh>

//+------------------------------------------------------------------+
/**
 * @class InstitutionalArithmeticPrices
 * @brief Class for handling arithmetic price calculations and line generation.
 */
class InstitutionalArithmeticPrices
{
public:
   /**
    * @enum ENUM_CHECK
    * @brief Enum to handle different types of errors and checks in line generation.
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
    * @brief Enum to handle different types of near lines.
    */
   enum ENUM_TYPE_NEAR_LINES
   {
      TYPE_BETWEEN_PARALLELS, ///< Type: Between parallels
      TYPE_INSIDE_PARALLEL, ///< Type: Inside parallel
      ERR_INVALID_LINES ///< Error: Invalid lines
   };

   /**
    * @struct Prices
    * @brief Structure to hold price levels and line type information.
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
    * @brief Structure to hold settings for arithmetic calculations.
    */
   struct Setting
   {
      double         startAdd; ///< Starting addition value
      double         step; ///< Step value
      double         add; ///< Additional value
   };

private:
   Prices            prices; ///< Structure to store price levels
   Setting           setting; ///< Structure to store settings

   /**
    * @brief Calculates the n-th term of the arithmetic sequence.
    * @param n The term index.
    * @tparam T Type of the term index.
    * @return The calculated term of the sequence.
    */
   template<typename T>
   T                 calcArithmeticSequenceTerm(T n)
   {
      return setting.startAdd + (n) * setting.step - (MathMod(n, 2) == 0 ? 0 : setting.add);
   }

public:
   /**
    * @brief Default constructor for the InstitutionalArithmeticPrices class.
    */
                     InstitutionalArithmeticPrices(void) {}

   /**
    * @brief Updates the arithmetic settings.
    * @param startAdd The starting addition value.
    * @param step The step value.
    * @param add The additional value.
    */
   void              UpdateSetting(double startAdd, double step, double add)
   {
      setting.startAdd = startAdd;
      setting.step = step;
      setting.add = add;
   }

   /**
    * @brief Gets the current arithmetic settings.
    * @return The current settings.
    */
   Setting           GetSetting()
   {
      return setting;
   }

   /**
    * @brief Gets the current arithmetic settings.
    * @param param Structure to store the settings.
    */
   void              GetSetting(Setting &param)
   {
      param = setting;
   }

   /**
    * @brief Checks the arguments for line generation.
    * @return The result of the check as ENUM_CHECK.
    */
   ENUM_CHECK        CheckArg()
   {
      if(setting.add > setting.step)
         return(ERR_ADD_OVER_STEP);

      return(CHECK_ARG_LINE_GENERATOR_PASSED);
   }

   /**
    * @brief Generates a string comment based on the result of the line check.
    * @param enum_result The result of the check.
    * @return A string comment describing the result.
    */
   string            EnumCheckLinesGeneratorToString(ENUM_CHECK enum_result)
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

      return(result);
   }

   /**
    * @brief Generates price levels based on the close price.
    * @param closePrice The close price to base calculations on.
    * @return A Prices structure with the generated price levels.
    */
   Prices              Generate(double closePrice)
   {
      double n = MathFloor((closePrice - setting.startAdd) / setting.step) + 1;

      if(closePrice >= calcArithmeticSequenceTerm(n))
      {
         if(closePrice > calcArithmeticSequenceTerm(n) && closePrice < calcArithmeticSequenceTerm(n) + setting.add)
         {
            prices.upperBuy = calcArithmeticSequenceTerm(n+1);
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
            prices.lowerSell = calcArithmeticSequenceTerm(n- 2) + setting.add;
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

   /**
    * @brief Generates a comment for the current price levels.
    * @return A string comment describing the price levels.
    */
   string              CommentToShow()
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
};
//+------------------------------------------------------------------+
