//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+
#include "LimitsByTimeRange.mqh"

// Constructor
//+------------------------------------------------------------------+
LimitsByTimeRange::LimitsByTimeRange(void) {}
LimitsByTimeRange::~LimitsByTimeRange(void) {}

// Setting
//+------------------------------------------------------------------+
void LimitsByTimeRange::UpdateSetting(
   string sym,
   ENUM_TIMEFRAMES timeFrames,
   uchar startHour,
   uchar startMin,
   uchar startSec,
   uchar endHour,
   uchar endMin,
   uchar endSec)
  {
   this.setting.sym = sym;
   this.setting.timeFrame = timeFrames;

   this.start.hour = startHour;
   this.start.min = startMin;
   this.start.sec = startSec;

   this.end.hour = endHour;
   this.end.min = endMin;
   this.end.sec = endSec;

   ArraySetAsSeries(this.rates, true);
  }

//+------------------------------------------------------------------+
LimitsByTimeRange::Setting LimitsByTimeRange::GetSetting(void)
  {
   return this.setting;
  }

//+------------------------------------------------------------------+
void LimitsByTimeRange::GetSetting(Setting &s)
  {
   s = this.setting;
  }

//+------------------------------------------------------------------+
bool LimitsByTimeRange::CheckSetting(void)
  {
   return SystemRequirements::SymbolCommon(this.setting.sym);
  }

// Prices
//+------------------------------------------------------------------+
LimitsByTimeRange::Prices LimitsByTimeRange::GetPrices(void)
  {
   return this.prices;
  }

//+------------------------------------------------------------------+
void LimitsByTimeRange::GetPrices(Prices &p)
  {
   p = this.prices;
  }

// TimeRange
//+------------------------------------------------------------------+
LimitsByTimeRange::TimeRange LimitsByTimeRange::GetTimeRange(void)
  {
   return this.timeRange;
  }

//+------------------------------------------------------------------+
void LimitsByTimeRange::GetTimeRange(TimeRange &p)
  {
   p = this.timeRange;
  }

// Run
//+------------------------------------------------------------------+
LimitsByTimeRange::Prices LimitsByTimeRange::Run(void)
  {
   TimeHelper::UpdateDate(this.start, this.end);
   int multiplier = ((ENUM_DAY_OF_WEEK)dt.day_of_week == MONDAY) ? 3 : 1;
   this.timeRange.start = StructToTime(this.start) - PeriodSeconds(PERIOD_D1) * multiplier;
   this.timeRange.end = StructToTime(this.end) - PeriodSeconds(PERIOD_D1) * multiplier;

   CopyRates(
      this.setting.sym,
      this.setting.timeFrame,
      this.timeRange.start,
      this.timeRange.end,
      this.rates
   );
   if(!this.rates.Size())
      return prices;

   this.prices.lower = this.rates[0].low;
   this.prices.lowerDatetime = this.rates[0].time;
   this.prices.upper = this.rates[0].high;
   this.prices.upperDatetime  = this.rates[0].time;

   for(int i=0; i<ArraySize(this.rates); i++)
     {
      if(this.rates[i].low < this.prices.lower)
        {
         this.prices.lower = this.rates[i].low;
         this.prices.lowerDatetime = this.rates[i].time;
        }
      if(this.rates[i].high > this.prices.upper)
        {
         this.prices.upper = this.rates[i].high;
         this.prices.upperDatetime = this.rates[i].time;
        }
     }
   return(this.prices);
  }
//+----------------------------------------------------------------
