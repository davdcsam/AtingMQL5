//+------------------------------------------------------------------+
//|                                                 AutomatedTrading |
//|                                         Copyright 2024, davdcsam |
//|                                      https://github.com/davdcsam |
//+------------------------------------------------------------------+

// Reference

#include "common//BooleanEnums.mqh"

#include "src//baseOnTask//TaskManager.mqh"

#include "src//detect//DetectOrders.mqh"
#include "src//detect//DetectPositions.mqh"

#include "src//filterOperativeDays//FilterByCSVFile.mqh"
#include "src//filterOperativeDays//FilterByDayWeek.mqh"

#include "src//prices//InstitutionalArithmeticPrices.mqh"
#include "src//prices//LimitsByIndex.mqh"
#include "src//prices//LimitsByTimeRange.mqh"

#include "src//profitProtection//BreakEven.mqh"
#include "src//profitProtection//TrailingStop.mqh"

#include "src//remove//RemoveByLocationPrice.mqh"
#include "src//remove//RemoveByOrderType.mqh"

#include "src//time//SectionTime.mqh"
#include "src//time//TimeLapseTree.mqh"

#include "src//transaction//Transaction.mqh"
