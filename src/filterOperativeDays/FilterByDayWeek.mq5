//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+
#include "FilterByDayWeek.mqh"

// Constructor
//+------------------------------------------------------------------+
FilterByDayWeek::FilterByDayWeek(void) {};
FilterByDayWeek::~FilterByDayWeek(void) {};

// Frame
//+------------------------------------------------------------------+
void FilterByDayWeek::UpdateFrame(Frame &noOperationDays)
{
    this.frame = noOperationDays;
}

//+------------------------------------------------------------------+
FilterByDayWeek::Frame FilterByDayWeek::GetFrame(void)
{
    return this.frame;
}

//+------------------------------------------------------------------+
void FilterByDayWeek::GetFrame(Frame &f)
{
    f = this.frame;
}

// Is Operative Day
//+------------------------------------------------------------------+
bool FilterByDayWeek::IsOperativeDay(void)
{
    TimeTradeServer(today);
    return this.IsOperativeDay(today);
}

//+------------------------------------------------------------------+
bool FilterByDayWeek::IsOperativeDay(MqlDateTime &mDT)
{
    switch (mDT.day_of_week)
    {
    case SUNDAY:
        return this.frame.sunday;
    case MONDAY:
        return this.frame.monday;
    case TUESDAY:
        return this.frame.tuesday;
    case WEDNESDAY:
        return this.frame.wednesday;
    case THURSDAY:
        return this.frame.thursday;
    case FRIDAY:
        return this.frame.friday;
    case SATURDAY:
        return this.frame.saturday;
    default:
        return false;
    }
}
//+------------------------------------------------------------------+
