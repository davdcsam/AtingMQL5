//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+

// Include the ArrayDouble class from the Arrays library
#include <Arrays/ArrayDouble.mqh>

//+------------------------------------------------------------------+
//| InstitutionalArithmeticPrices                                    |
//+------------------------------------------------------------------+
class InstitutionalArithmeticPrices
  {
public:

   // ENUM_CHECK: Enum to handle different types of errors and checks in line generation
   enum ENUM_CHECK
     {
      CHECK_ARG_LINE_GENERATOR_PASSED, // Check passed
      ERR_NO_ENOUGH_STEP, // Error: Not enough steps
      ERR_START_OVER_END, // Error: Start is greater than end
      ERR_ADD_OVER_STEP, // Error: Addition is greater than step
      ERR_PRICE_OUT_LINES // Error: Price is out of lines
     };

   // ENUM_TYPE_NEAR_LINES: Enum to handle different types of near lines
   enum ENUM_TYPE_NEAR_LINES
     {
      TYPE_BETWEEN_PARALLELS, // Type: Between parallels
      TYPE_INSIDE_PARALLEL, // Type: Inside parallel
      ERR_INVALID_LINES // Error: Invalid lines
     };

   struct Prices
     {
      double         upperBuy, upperSell, lowerBuy, lowerSell;
      ENUM_TYPE_NEAR_LINES typeNearLines;
     };

   struct Setting
     {
      double         startAdd, step, add;
     };

private:
   Prices            prices;
   Setting           setting;
   template<typename T>
   T                 calcArithmeticSequenceTerm(T n) { return setting.startAdd + (n) * setting.step - (MathMod(n, 2) == 0 ? 0 : setting.add); }

public:

                     InstitutionalArithmeticPrices(void) {}

   void              UpdateSetting(double startAdd, double step, double add)
     {
      setting.startAdd = startAdd;
      setting.step = step;
      setting.add = add;
     }
   Setting           GetSetting() { return setting; }
   void              GetSetting(Setting &param) { param = setting; }

   // CheckArg: Function to check the arguments for line generation
   ENUM_CHECK        CheckArg()
     {
      // Check if addition is greater than step
      if(setting.add > setting.step)
         return(ERR_ADD_OVER_STEP);

      // If all checks pass, return CHECK_ARG_LINE_GENERATOR_PASSED
      return(CHECK_ARG_LINE_GENERATOR_PASSED);
     }


   // CheckToString: Method to generate a comment based on the result of the line check
   string            EnumCheckLinesGeneratorToString(ENUM_CHECK enum_result)
     {
      string result;

      // Switch case to handle different types of results
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

   // Function to update the comment for the line handler
   string              CommentToShow()
     {
      string result;

      // Switch case to handle different types of near lines
      switch(prices.typeNearLines)
        {
         // If the type of near lines is TYPE_BETWEEN_PARALLELS
         case TYPE_BETWEEN_PARALLELS:
            // Set the comment for the line handler to show the upper and lower buy and sell points
            result = StringFormat(
                        "\n Upper Sell %s, Upper Buy %s\n Lower Sell %s, Lower Buy %s\n",
                        DoubleToString(prices.upperSell, _Digits),
                        DoubleToString(prices.upperBuy, _Digits),
                        DoubleToString(prices.lowerSell, _Digits),
                        DoubleToString(prices.lowerBuy, _Digits)
                     );
            break;
         // If the type of near lines is TYPE_INSIDE_PARALLEL
         case TYPE_INSIDE_PARALLEL:
            // Set the comment for the line handler to show the middle buy and sell points
            result = StringFormat(
                        "\n Upper Buy %s\n Upper Sell %s, Lower Buy %s\n Lower Sell %s\n",
                        DoubleToString(prices.upperBuy, _Digits),
                        DoubleToString(prices.upperSell, _Digits),
                        DoubleToString(prices.lowerBuy, _Digits),
                        DoubleToString(prices.lowerSell, _Digits)
                     );
            break;
         // If the type of near lines is ERR_INVALID_LINES
         case ERR_INVALID_LINES:
            // Set the comment for the line handler to show an error message
            result = "\n Invalid Lines \n";
            break;
        }

      return result;
     }

  };
//+------------------------------------------------------------------+
