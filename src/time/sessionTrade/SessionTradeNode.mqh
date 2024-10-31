//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+
#include "../../filterOperativeDays/daysFilter/DaysFilterNode.mqh"

//+------------------------------------------------------------------+
class SessionDayNode : public DaysFilterNode
  {
public:
   datetime          start;
   datetime          end;

                     SessionDayNode(datetime date,
                  datetime timeStart,
                  datetime timeEnd);

   string            ToString(void);
  };


// Constructor
//+------------------------------------------------------------------+
SessionDayNode::SessionDayNode(
   datetime date,
   datetime timeStart,
   datetime timeEnd
) :               DaysFilterNode(date)
  {
   MqlDateTime current;
   TimeToStruct(date, current);
   current.hour = current.min = current.sec = 0;
   this.start = this.end = StructToTime(current);
   this.start = timeStart;
   this.end = timeEnd;
  }

// To String
//+------------------------------------------------------------------+
string            SessionDayNode::ToString(void)
  {
   return StringFormat(
             "Date: %s [ %s to %s ], Hight: %d",
             TimeToString(this.dt, TIME_DATE),
             TimeToString(this.start, TIME_MINUTES | TIME_SECONDS),
             TimeToString(this.end, TIME_MINUTES | TIME_SECONDS),
             this.height);
  }
//+------------------------------------------------------------------+
