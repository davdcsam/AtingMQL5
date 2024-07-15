//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
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
   static bool       Sort(MqlDateTime &start, MqlDateTime &end);
   static bool       Sort(datetime &start, datetime &end);

   static bool       IsIn(MqlDateTime &date, MqlDateTime &start, MqlDateTime &end);
   static bool       IsIn(datetime &date, datetime &start, datetime &end);

   static void       UpdateDate(MqlDateTime &date, MqlDateTime &start, MqlDateTime &end);
   static void       UpdateDate(datetime &date, datetime &start, datetime &end);
   static void       UpdateDate(MqlDateTime &start, MqlDateTime &end);
   static void       UpdateDate(datetime &start, datetime &end);
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
//| TimeHelper::Sort                                                 |
//+------------------------------------------------------------------+
bool TimeHelper::Sort(MqlDateTime &start, MqlDateTime &end)
  {
   datetime tempS = StructToTime(start);
   datetime tempE = StructToTime(end);
   bool r = Sort(tempS, tempE);
   TimeToStruct(tempS, start);
   TimeToStruct(tempE, end);
   return r;
  }

//+------------------------------------------------------------------+
//| TimeHelper::IsIn                                                 |
//+------------------------------------------------------------------+
bool TimeHelper::IsIn(datetime &date, datetime &start, datetime &end)
  { return date >= start && date <= end; }

//+------------------------------------------------------------------+
//| TimeHelper::IsIn                                                 |
//+------------------------------------------------------------------+
bool TimeHelper::IsIn(MqlDateTime &date, MqlDateTime &start, MqlDateTime &end)
  { return StructToTime(date) >= StructToTime(start) && StructToTime(date) <= StructToTime(end); }

//+------------------------------------------------------------------+
//| TimeHelper::UpdateDate                                           |
//+------------------------------------------------------------------+
void TimeHelper::UpdateDate(MqlDateTime &date, MqlDateTime &start, MqlDateTime &end)
  { UpdateDateHelper(date, start, end); }

//+------------------------------------------------------------------+
//| TimeHelper::UpdateDate                                           |
//+------------------------------------------------------------------+
void TimeHelper::UpdateDate(datetime &date, datetime &start, datetime &end)
  { UpdateDateHelper(date, start, end); }

//+------------------------------------------------------------------+
//| TimeHelper::UpdateDate                                           |
//+------------------------------------------------------------------+
void TimeHelper::UpdateDate(MqlDateTime &start, MqlDateTime &end)
  {
   MqlDateTime temp;
   TimeToStruct(TimeCurrent(), temp);
   UpdateDateHelper(temp, start, end);
  }

//+------------------------------------------------------------------+
//| TimeHelper::UpdateDate                                           |
//+------------------------------------------------------------------+
void TimeHelper::UpdateDate(datetime &start, datetime &end)
  {
   datetime temp = TimeCurrent();
   UpdateDateHelper(temp, start, end);
  }
//+------------------------------------------------------------------+
