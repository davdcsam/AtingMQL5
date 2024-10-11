//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+
#include "LimitsByIndex.mqh"
#include "../CheckCommonSetting.mqh"
#include "../SystemRequirements.mqh"

// Constructor
//+------------------------------------------------------------------+
LimitsByIndex::LimitsByIndex() {};

LimitsByIndex::~LimitsByIndex() {};



// Setting
//+------------------------------------------------------------------+
void LimitsByIndex::UpdateSetting(string sym, ENUM_TIMEFRAMES timeFrame, uint counter, uint shifter)
  {
   this.setting.sym = sym;
   this.setting.timeFrame = timeFrame;
   this.setting.counter = counter;
   this.setting.shifter = shifter;
  }


//+------------------------------------------------------------------+
void LimitsByIndex::GetSetting(LimitsByIndex::Setting& s) { s = this.setting; }

//+------------------------------------------------------------------+
LimitsByIndex::Setting LimitsByIndex::GetSetting(void) { return this.setting; }

//+------------------------------------------------------------------+
bool LimitsByIndex::CheckSetting(void)
  {
   return (
             SystemRequirements::SymbolCommon(this.setting.sym) &&
             !ZeroProcessor::Run(this.setting.counter) &&
             !NegativeProcessor::IsNegative(this.setting.shifter, true) &&
             !NegativeProcessor::IsNegative(this.setting.shifter, true)
          );
  }

//+------------------------------------------------------------------+
string LimitsByIndex::SettingToString(void)
  {
   return StringFormat(
             "Setting:\n   Symbol: %s\n   Time Frame: %s\n Counter: %u\n Shifter: %u",
             this.setting.sym,
             EnumToString(this.setting.timeFrame),
             this.setting.counter,
             this.setting.shifter
          );
  }



// Prices
//+------------------------------------------------------------------+
void LimitsByIndex::GetPrices(LimitsByIndex::Prices& p) { p = this.prices; }

//+------------------------------------------------------------------+
LimitsByIndex::Prices            LimitsByIndex::GetPrices() { return this.prices; }

//+------------------------------------------------------------------+
LimitsByIndex::Prices LimitsByIndex::Run()
  {
// Find the highest value for the given symbol and timeFrame.
   this.prices.upperIndex = iHighest(this.setting.sym, this.setting.timeFrame, MODE_HIGH, this.setting.counter, this.setting.shifter);
// Find the lowest value for the given symbol and timeFrame.
   this.prices.lowerIndex = iLowest(this.setting.sym, this.setting.timeFrame, MODE_LOW, this.setting.counter, this.setting.shifter);

// Get the high value at the upper limit index.
   this.prices.upper = iHigh(this.setting.sym, this.setting.timeFrame, this.prices.upperIndex);
// Get the low value at the lower limit index.
   this.prices.lower = iLow(this.setting.sym, this.setting.timeFrame, this.prices.lowerIndex);

   return this.prices;
  }

//+------------------------------------------------------------------+
string LimitsByIndex::PricesToString(void)
  {
   return StringFormat(
             "Prices:\n   Upper Price Limit %f at index %u\n   Lower Price Limit %f at index %u",
             this.prices.upper,
             this.prices.upperIndex,
             this.prices.lower,
             this.prices.lowerIndex
          );
  }
//+------------------------------------------------------------------+
