//+------------------------------------------------------------------+
//|                                                 AutomatedTrading |
//|                                         Copyright 2024, davdcsam |
//|                                      https://github.com/davdcsam |
//+------------------------------------------------------------------+

// Reference

#include "baseOnTask//TaskManager.mqh"

#include "common//BooleanEnums.mqh"

#include "detect//DetectOrders.mqh"
#include "detect//DetectPositions.mqh"

#include "filterOperativeDays//FilterByCSVFile.mqh"
#include "filterOperativeDays//FilterByDayWeek.mqh"

#include "prices//InstitutionalArithmeticPrices.mqh"
#include "prices//LimitsByIndex.mqh"
#include "prices//LimitsByTimeRange.mqh"

#include "profitProtection//BreakEven.mqh"
#include "profitProtection//TrailingStop.mqh"

#include "remove//RemoveByLocationPrice.mqh"
#include "remove//RemoveByOrderType.mqh"

#include "time//SectionTime.mqh"
#include "time//TimeLapseTree.mqh"

#include "transaction//Transaction.mqh"
