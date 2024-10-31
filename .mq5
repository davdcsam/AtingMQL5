//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+

// Reference Headers
//+------------------------------------------------------------------+

// baseOnTask
#include "src/baseOnTask/TaskManager.mqh"

// Detect
#include "src/detect/DetectOrders.mqh"
#include "src/detect/DetectPositions.mqh"
#include "src/detect/IDetectEntity.mqh"

// Filter Operative Days
#include "src/filterOperativeDays/daysFilter/DaysFilterNode.mqh"
#include "src/filterOperativeDays/daysFilter/DaysFilterTree.mqh"
#include "src/filterOperativeDays/DateTimeStringFormat.mqh"
#include "src/filterOperativeDays/FilterByCSVFile.mqh"
#include "src/filterOperativeDays/FilterByDayWeek.mqh"

// Prices
#include "src/prices/institutionalArithmeticPrices/InstitutionalArithmeticPrices.mqh"
#include "src/prices/limitsByIndex/LimitsByIndex.mqh"
#include "src/prices/limitsByTimeRange/LimitsByTimeRange.mqh"

// Profit Protection
#include "src/profitProtection/breakEven/BreakEven.mqh"
#include "src/profitProtection/trailingStop/TrailingStop.mqh"
#include "src/profitProtection/ProfitProtection.mqh"

// Remove
#include "src/remove/remOrder/RemOrderByLocationPrice.mqh"
#include "src/remove/remOrder/RemOrderByType.mqh"
#include "src/remove/remPosition/RemPositionByType.mqh"
#include "src/remove/Remove.mqh"

// ThirdParty
#include "src/thirdParty/MarketOpenHours.mqh"

// Time
#include "src/time/sectionTime/SectionTime.mqh"
#include "src/time/sessionTrade/SessionTrade.mqh"
#include "src/time/sessionTrade/SessionTradeNode.mqh"
#include "src/time/sessionTrade/SessionTradeTree.mqh"
#include "src/time/timeLapse/TimeLapseNode.mqh"
#include "src/time/timeLapse/TimeLapseTree.mqh"
#include "src/time/TimeHelper.mqh"

// Transaction
#include "src/transaction/CalcStop.mqh"
#include "src/transaction/Request.mqh"
#include "src/transaction/RoundVolume.mqh"
#include "src/transaction/Transaction.mqh"

// None
#include "src/AtingErr.mqh"
#include "src/BooleanEnums.mqh"
#include "src/CheckCommonSetting.mqh"
#include "src/SystemRequirements.mqh"

// Sources
//+------------------------------------------------------------------+

// Filter Operative Days
#include "src/filterOperativeDays/daysFilter/DaysFilterTree.mq5"
#include "src/filterOperativeDays/FilterByDayWeek.mq5"

// Prices
#include "src/prices/institutionalArithmeticPrices/InstitutionalArithmeticPrices.mq5"
#include "src/prices/limitsByIndex/LimitsByIndex.mq5"
#include "src/prices/limitsByTimeRange/LimitsByTimeRange.mq5"

// Profti Protection
#include "src/profitProtection/ProfitProtection.mq5"

// Remove
#include "src/remove/remOrder/RemOrderByLocationPrice.mq5"
#include "src/remove/remOrder/RemOrderByType.mq5"
#include "src/remove/remPosition/RemPositionByType.mq5"
#include "src/remove/Remove.mq5"

// Time
#include "src/time/sessionTrade/SessionTradeTree.mq5"
#include "src/time/timeLapse/TimeLapseTree.mq5"

// Transaction
#include "src/transaction/Request.mq5"
#include "src/transaction/Transaction.mq5"

// Test
//+------------------------------------------------------------------+
#include "test/src.CheckCommonSetting.mqh"
#include "test/src.SystemRequirements.mqh"
#include "test/TimeExecution.mqh"
//+------------------------------------------------------------------+
