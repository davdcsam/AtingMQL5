//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+

// Reference
#include "src//BooleanEnums.mqh"
#include "src//CheckCommonSetting.mqh"
#include "src//SystemRequirements.mqh"

#include "src//baseOnTask//TaskManager.mqh"

#include "src//detect//DetectOrders.mqh"
#include "src//detect//DetectPositions.mqh"

#include "src//filterOperativeDays//FilterByCSVFile.mqh"
#include "src//filterOperativeDays//FilterByDayWeek.mqh"

#include "src//prices//InstitutionalArithmeticPrices.mq5"
#include "src//prices//LimitsByIndex.mq5"
#include "src//prices//LimitsByTimeRange.mq5"

#include "src//profitProtection//BreakEven.mqh"
#include "src//profitProtection//TrailingStop.mqh"

#include "src/remove/Remove.mq5"
#include "src//remove//RemOrderByLocationPrice.mq5"
#include "src//remove//RemOrderByType.mq5"
#include "src//remove//RemPositionByType.mq5"

#include "src//thirdParty//MarketOpenHours.mqh"

#include "src//time//SectionTime.mqh"
#include "src//time//SessionTrade.mqh"
#include "src//time//TimeHelper.mqh"
#include "src//time//TimeLapseTree.mqh"

#include "src//transaction//Transaction.mq5"

// Testing
#include "test/TimeExecution.mqh"
#include "test/src.CheckCommonSetting.mqh"
#include "test/src.SystemRequirements.mqh"

//+------------------------------------------------------------------+
