//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+
#include "InstitutionalArithmeticPrices.mqh"
#include "../../CheckCommonSetting.mqh"

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
bool InstitutionalArithmeticPrices::CheckSetting()
{
    return (
        !ZeroProcessor::Run(setting.step, true)
    );
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
      default:
         result = "\n Invalid Lines \n";
         break;
     }

   return result;
  }
//+------------------------------------------------------------------+
