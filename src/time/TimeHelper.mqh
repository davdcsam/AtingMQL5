//+------------------------------------------------------------------+
//|                                                 AutomatedTrading |
//|                                         Copyright 2024, davdcsam |
//|                                      https://github.com/davdcsam |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| TimeHelper                                                       |
//+------------------------------------------------------------------+
class TimeHelper
  {
private:
   static void       UpdateDateHelper(MqlDateTime &date, MqlDateTime &s, MqlDateTime &e)
     {
      s.day = date.day;
      s.mon = date.mon;
      s.year = date.year;
      
      e.day = date.day;
      e.mon = date.mon;
      e.year = date.year;
     }

   static void       UpdateDateHelper(datetime &date, datetime &s, datetime &e)
     {
      MqlDateTime temp, tempS, tempE;
      TimeToStruct(date, temp);

      UpdateDateHelper(temp, tempS, tempE);
      s = StructToTime(tempS);
      e = StructToTime(tempE);
     }

public:
   static bool       Sort(datetime &start, datetime &end);
   static bool       IsIn(datetime &date, datetime &s, datetime &e);

   static void       UpdateDate(MqlDateTime &date, MqlDateTime &s, MqlDateTime &e);
   static void       UpdateDate(datetime &date, datetime &s, datetime &e);
   static void       UpdateDate(MqlDateTime &s, MqlDateTime &e);
   static void       UpdateDate(datetime &s, datetime &e);
  };

//+------------------------------------------------------------------+
//| TimeHelper::Sort                                                 |
//+------------------------------------------------------------------+
bool TimeHelper::Sort(datetime &start, datetime &end)
  {
   if(start == end)
      return false;
   if(start > end)
     {
      datetime temp = start;
      start = end;
      end = temp;
      return true;
     }
   return true;
  }

//+------------------------------------------------------------------+
//| TimeHelper::IsIn                                                 |
//+------------------------------------------------------------------+
bool TimeHelper::IsIn(datetime &date, datetime &s, datetime &e)
  { return date >= s && date <= e; }

//+------------------------------------------------------------------+
//| TimeHelper::UpdateDate                                           |
//+------------------------------------------------------------------+
void TimeHelper::UpdateDate(MqlDateTime &date, MqlDateTime &s, MqlDateTime &e)
  { UpdateDateHelper(date, s, e); }

//+------------------------------------------------------------------+
//| TimeHelper::UpdateDate                                           |
//+------------------------------------------------------------------+
void TimeHelper::UpdateDate(datetime &date, datetime &s, datetime &e)
  { UpdateDateHelper(date, s, e); }

//+------------------------------------------------------------------+
//| TimeHelper::UpdateDate                                           |
//+------------------------------------------------------------------+
void TimeHelper::UpdateDate(MqlDateTime &s, MqlDateTime &e)
  {
   MqlDateTime temp;
   TimeToStruct(TimeCurrent(), temp);
   UpdateDateHelper(temp, s, e);
  }

//+------------------------------------------------------------------+
//| TimeHelper::UpdateDate                                           |
//+------------------------------------------------------------------+
void TimeHelper::UpdateDate(datetime &s, datetime &e)
  {
   datetime temp = TimeCurrent();
   UpdateDateHelper(temp, s, e);
  }
//+------------------------------------------------------------------+
