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
public:
   static bool       Sort(int &start, int &end);

   static bool       IsIn(int &currentTimeStamp, int &s, int &e);

   static bool       UpdateDate(int &currentTimeStamp, MqlDateTime &s, MqlDateTime &e);
   static bool       UpdateDate(int &currentTimeStamp, int &s, int &e);
   static bool       UpdateDate(MqlDateTime &s, MqlDateTime &e);
   static bool       UpdateDate(int &s, int &e);

  };

//+------------------------------------------------------------------+
//| TimeHelper::Sort                                                 |
//+------------------------------------------------------------------+
bool TimeHelper::Sort(int &start, int &end)
  {
   if(start == end)
      return false;
   if(start > end)
     {
      int temp = start;
      start = end;
      end = temp;
      return true;
     }
   return true;
  }

//+------------------------------------------------------------------+
//| TimeHelper::IsIn                                                 |
//+------------------------------------------------------------------+
bool TimeHelper::IsIn(int &currentTimeStamp, int &s, int &e)
  {
   if(currentTimeStamp >= s && currentTimeStamp <= e)
      return true;
   return false;
  }

//+------------------------------------------------------------------+
//| TimeHelper::UpdateDate                                           |
//+------------------------------------------------------------------+
bool TimeHelper::UpdateDate(int &currentTimeStamp, MqlDateTime &s, MqlDateTime &e)
  {
   MqlDateTime tempC;
   TimeToStruct(currentTimeStamp, tempC);

   s.day_of_year = tempC.day_of_year;
   s.year = tempC.year;
   e.day_of_year = tempC.day_of_year;
   e.year = tempC.year;
   return true;
  }

//+------------------------------------------------------------------+
//| TimeHelper::UpdateDate                                           |
//+------------------------------------------------------------------+
bool TimeHelper::UpdateDate(int &currentTimeStamp, int &s, int &e)
  {
   MqlDateTime tempC, tempS, tempE;
   TimeToStruct(currentTimeStamp, tempC);
   TimeToStruct(s, tempS);
   TimeToStruct(e, tempE);

   tempS.day_of_year = tempC.day_of_year;
   tempS.year = tempC.year;
   tempE.day_of_year = tempC.day_of_year;
   tempE.year = tempC.year;
   
   s = (int) StructToTime(tempS);
   e = (int) StructToTime(tempE);
   return true;
  }

//+------------------------------------------------------------------+
//| TimeHelper::UpdateDate                                           |
//+------------------------------------------------------------------+
bool TimeHelper::UpdateDate(MqlDateTime &s, MqlDateTime &e)
  {
   MqlDateTime tempC;
   TimeToStruct(TimeCurrent(), tempC);

   s.day_of_year = tempC.day_of_year;
   s.year = tempC.year;
   e.day_of_year = tempC.day_of_year;
   e.year = tempC.year;
   return true;
  }

//+------------------------------------------------------------------+
//| TimeHelper::UpdateDate                                           |
//+------------------------------------------------------------------+
bool TimeHelper::UpdateDate(int &s, int &e)
  {
   MqlDateTime tempC, tempS, tempE;
   TimeToStruct(TimeCurrent(), tempC);
   TimeToStruct(s, tempS);
   TimeToStruct(e, tempE);   

   tempS.day_of_year = tempC.day_of_year;
   tempS.year = tempC.year;
   tempE.day_of_year = tempC.day_of_year;
   tempE.year = tempC.year;

   s = (int) StructToTime(tempS);
   e = (int) StructToTime(tempE);
   return true;
  }
//+------------------------------------------------------------------+
