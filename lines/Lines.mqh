//+------------------------------------------------------------------+
//|                                                            Lines |
//|                                         Copyright 2024, davdcsam |
//|                                      https://github.com/davdcsam |
//+------------------------------------------------------------------+

// Include the ArrayDouble class from the Arrays library
#include <Arrays/ArrayDouble.mqh>

// ENUM_CHECK_LINE_GENERATOR: Enum to handle different types of errors and checks in line generation
enum ENUM_CHECK_LINE_GENERATOR
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


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

// Lines: Class to handle line operations
class Lines
  {
protected:

   enum ENUM_PRIVATE_ATR_DOUBLE
     {
      START,
      START_ADD,
      END,
      STEP,
      ADD,
      CURRENT
     };

   double               start; // Start of the line
   double               start_add; // Addition to the start of the line
   double               end; // End of the line
   double               step; // Step size for the line
   double               add; // Addition to the line
   double               current; // Current position on the line
   bool                 is_add; // Boolean to check if addition is needed


public:
   // Constructor for the Lines class
                     Lines(double start_line,double start_add_line,double end_line,double step_line, double add_line)
     {
      // Swap start and end if start is greater than end
      if(start_line > end_line)
        {
         start = end_line;
         end = start_line + step_line;
        }
      else
        {
         start = start_line;
         end = end_line + step_line;
        }

      start_add = start_add_line;
      step = step_line;
      add = add_line;
      current = start + start_add;
      is_add = false;
     }

   CArrayDouble         lines; // Array to store the lines
   double              upper_buy; // Upper limit for buy
   double              upper_sell; // Upper limit for sell
   double              lower_buy; // Lower limit for buy
   double              lower_sell; // Lower limit for sell
   ENUM_TYPE_NEAR_LINES type_near_lines; // Type of near lines

   double            GetPrivateAtr(ENUM_PRIVATE_ATR_DOUBLE atr)
     {
      double result = 0;

      switch(atr)
        {
         case START:
            result = start;
            break;
         case START_ADD:
            result = start_add;
            break;
         case END:
            result = end;
            break;
         case STEP:
            result = step;
            break;
         case ADD:
            result = add;
            break;
         case CURRENT:
            result = current;
            break;
         default:
            result = 0;
            break;
        }

      return result;
     }

   // CheckArg: Function to check the arguments for line generation
   ENUM_CHECK_LINE_GENERATOR              CheckArg()
     {
      // Check if the price is out of lines
      if(iClose(_Symbol, PERIOD_CURRENT, 0) < start || iClose(_Symbol, PERIOD_CURRENT, 0) >= end + step)
         return(ERR_PRICE_OUT_LINES);

      // Check if there are not enough steps
      if(step > end - start)
         return(ERR_NO_ENOUGH_STEP);

      // Check if start is greater than end
      if(start > end)
         return(ERR_START_OVER_END);

      // Check if addition is greater than step
      if(add > step)
         return(ERR_ADD_OVER_STEP);

      // If all checks pass, return CHECK_ARG_LINE_GENERATOR_PASSED
      return(CHECK_ARG_LINE_GENERATOR_PASSED);
     }


   // CheckToString: Method to generate a comment based on the result of the line check
   string            EnumCheckLinesGeneratorToString(ENUM_CHECK_LINE_GENERATOR enum_result)
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
         case ERR_NO_ENOUGH_STEP:
            result = StringFormat(
                        "%s: Step %s is bigger than difference between start %s and end %s.",
                        EnumToString(enum_result),
                        DoubleToString(step, _Digits),
                        DoubleToString(start, _Digits),
                        DoubleToString(end, _Digits)
                     );
            break;
         case ERR_START_OVER_END:
            result = StringFormat(
                        "%s: Start value %s is greater than end value %s.",
                        EnumToString(enum_result),
                        DoubleToString(start, _Digits),
                        DoubleToString(end, _Digits)
                     );
            break;
         case ERR_ADD_OVER_STEP:
            result = StringFormat(
                        "%s: Add value %s is greater than step value %s.",
                        EnumToString(enum_result),
                        DoubleToString(add, _Digits),
                        DoubleToString(step, _Digits)
                     );
            break;
         case ERR_PRICE_OUT_LINES:
            result = StringFormat(
                        "%s: Price %s is out inputs %s to %s",
                        EnumToString(enum_result),
                        DoubleToString(iClose(_Symbol, PERIOD_CURRENT, 0), _Digits),
                        DoubleToString(start, _Digits),
                        DoubleToString(end, _Digits)
                     );
            break;
         default:
            result = "Unknown error.";
            break;
        }

      return(result);
     }

   // Generate: Function to generate the lines
   void              Generate()
     {
      // While the current position is less than or equal to the end
      while(current <= end)
        {
         // Add the current position to the lines array
         lines.Add(current);

         // If is_add is false, add step - add to current
         if(!is_add)
           {
            current += step - add;
           }
         // If is_add is true, add step + add to current
         else
           {
            current += step + add;
           }

         // Toggle the is_add flag
         is_add = !is_add;
        }
     }

   // GetNearLines: Function to get the near lines based on the close price

   /*
   Option #1: Modifcar uns busqueda binaria, donde eneotnre que encuentre mas a la izquieda a la mado mayor, y el derecha mas al derecha que menor.

   Option #2: Investigar en un arbol banario de busqueda o arbol de segmento.
   */

   //
   ENUM_TYPE_NEAR_LINES              GetNearLines(double close_price)
     {
      // If there are no lines, return ERR_INVALID_LINES
      if(!lines.Total())
        {
         type_near_lines = ERR_INVALID_LINES;
         return(type_near_lines);
        }

      // For each line in the lines array
      for(int i=0; i<lines.Total() - 1; i++)
        {
         // If the close price is between two lines
         if(close_price > lines.At(i) && close_price < lines.At(i+1))
           {
            // If the close price is less than the current line + add
            if(close_price < lines.At(i) + add)
              {
               upper_buy = lines.At(i+1);

               upper_sell = lines.At(i) + add;
               lower_buy = lines.At(i);

               lower_sell = lines.At(i-1) + add;

               // Set the type of near lines to TYPE_INSIDE_PARALLEL
               type_near_lines = TYPE_INSIDE_PARALLEL;
               return(type_near_lines);
              }

            // Set the upper and lower buy and sell points
            upper_sell = lines.At(i+1) + add;
            upper_buy = lines.At(i+1);

            lower_sell = lines.At(i) + add;
            lower_buy = lines.At(i);

            // Set the type of near lines to TYPE_BETWEEN_PARALLELS
            type_near_lines = TYPE_BETWEEN_PARALLELS;
            return(type_near_lines);
           }
        }

      // If no near lines are found, return ERR_INVALID_LINES
      type_near_lines = ERR_INVALID_LINES;
      return(type_near_lines);
     }

   // ConvertMqlArray: Function to convert the lines array to an MQL array
   void                 ConvertMqlArray(double& array[])
     {
      // If there are no lines, print an error message
      if(!lines.Total())
        {
         Print("Lines no generated yet");
         return;
        }

      // Resize the MQL array to the size of the lines array
      ArrayResize(array, lines.Total());

      // For each line in the lines array, add it to the MQL array
      for(int i=0; i<lines.Total(); i++)
        {
         array[i] = lines.At(i);
        }
     }

   // Function to update the comment for the line handler
   string              CommentToShow()
     {
      string result;

      // Get the type of near lines based on the current close price
      ENUM_TYPE_NEAR_LINES temp = GetNearLines(
                                     iClose(_Symbol, PERIOD_CURRENT, 0)
                                  );

      // Switch case to handle different types of near lines
      switch(temp)
        {
         // If the type of near lines is TYPE_BETWEEN_PARALLELS
         case TYPE_BETWEEN_PARALLELS:
            // Set the comment for the line handler to show the upper and lower buy and sell points
            result = StringFormat(
                        "\n Upper Sell %s, Upper Buy %s\n Lower Sell %s, Lower Buy %s\n",
                        DoubleToString(upper_sell, _Digits),
                        DoubleToString(upper_buy, _Digits),
                        DoubleToString(lower_sell, _Digits),
                        DoubleToString(lower_buy, _Digits)
                     );
            break;
         // If the type of near lines is TYPE_INSIDE_PARALLEL
         case TYPE_INSIDE_PARALLEL:
            // Set the comment for the line handler to show the middle buy and sell points
            result = StringFormat(
                        "\n Upper Buy %s\n Upper Sell %s, Lower Buy %s\n Lower Sell %s\n",
                        DoubleToString(upper_buy, _Digits),
                        DoubleToString(upper_sell, _Digits),
                        DoubleToString(lower_buy, _Digits),
                        DoubleToString(lower_sell, _Digits)
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
//|                                                                  |
//+------------------------------------------------------------------+
class InstitutionalArithmeticPrices
  {
public:

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
   ENUM_CHECK_LINE_GENERATOR              CheckArg()
     {
      // Check if addition is greater than step
      if(setting.add > setting.step)
         return(ERR_ADD_OVER_STEP);

      // If all checks pass, return CHECK_ARG_LINE_GENERATOR_PASSED
      return(CHECK_ARG_LINE_GENERATOR_PASSED);
     }


   // CheckToString: Method to generate a comment based on the result of the line check
   string            EnumCheckLinesGeneratorToString(ENUM_CHECK_LINE_GENERATOR enum_result)
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
