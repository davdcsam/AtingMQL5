//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+

// Reference
//+------------------------------------------------------------------+
#include "src/baseOnTask/TaskManager.mqh"

#include "src/detect/DetectOrders.mqh"
#include "src/detect/DetectPositions.mqh"
#include "src/detect/IDetectEntity.mqh"

#include "src/filterOperativeDays/daysFilter/DaysFilterTree.mq5"
#include "src/filterOperativeDays/FilterByCSVFile.mqh"
#include "src/filterOperativeDays/FilterByDayWeek.mq5"

#include "src/prices/institutionalArithmeticPrices/InstitutionalArithmeticPrices.mq5"
#include "src/prices/limitsByIndex/LimitsByIndex.mq5"
#include "src/prices/limitsByTimeRange/LimitsByTimeRange.mq5"

#include "src/profitProtection/breakEven/BreakEven.mqh"
#include "src/profitProtection/trailingStop/TrailingStop.mqh"
#include "src/profitProtection/ProfitProtection.mq5"

#include "src/remove/remOrder/RemOrderByLocationPrice.mq5"
#include "src/remove/remOrder/RemOrderByType.mq5"
#include "src/remove/remPosition/RemPositionByType.mq5"
#include "src/remove/Remove.mq5"

#include "src/thirdParty/MarketOpenHours.mqh"

#include "src/time/sectionTime/SectionTime.mqh"
#include "src/time/sessionTrade/SessionTrade.mqh"
#include "src/time/timeLapse/TimeLapseTree.mq5"
#include "src/time/TimeHelper.mqh"

#include "src/transaction/CalcStop.mqh"
#include "src/transaction/Request.mq5"
#include "src/transaction/RoundVolume.mqh"
#include "src/transaction/Transaction.mq5"

#include "src/AtingErr.mqh"
#include "src/BooleanEnums.mqh"
#include "src/CheckCommonSetting.mqh"
#include "src/SystemRequirements.mqh"

// Testing
//+------------------------------------------------------------------+
#include "test/src.CheckCommonSetting.mqh"
#include "test/src.SystemRequirements.mqh"
#include "test/TimeExecution.mqh"
//+------------------------------------------------------------------+
