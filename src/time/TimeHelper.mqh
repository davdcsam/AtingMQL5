//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
/**
 * @brief A utility class for handling date and time operations.
 */
class TimeHelper
  {
private:
   /**
    * @brief Helper function to update date components.
    * @param date Source date to copy from
    * @param s Start date to update
    * @param e End date to update
    */
   static void       UpdateDateHelper(MqlDateTime &date, MqlDateTime &s, MqlDateTime &e);

   /**
    * @brief Helper function to update date components.
    * @param date Source date to copy from
    * @param s Start date to update
    * @param e End date to update
    */
   static void       UpdateDateHelper(datetime &date, datetime &s, datetime &e);

public:
   /**
    * @brief Sorts the start and end dates in ascending order.
    * @param start Start date to sort
    * @param end End date to sort
    * @return True if the dates were sorted, false if they are equal
    */
   static bool       Sort(MqlDateTime &start, MqlDateTime &end);

   /**
    * @brief Sorts the start and end dates in ascending order.
    * @param start Start date to sort
    * @param end End date to sort
    * @return True if the dates were sorted, false if they are equal
    */
   static bool       Sort(datetime &start, datetime &end);

   /**
    * @brief Checks if a date is within a specified range.
    * @param date Date to check
    * @param start Start date of the range
    * @param end End date of the range
    * @return True if the date is within the range, false otherwise
    */
   static bool       IsIn(MqlDateTime &date, MqlDateTime &start, MqlDateTime &end);

   /**
    * @brief Checks if a date is within a specified range.
    * @param date Date to check
    * @param start Start date of the range
    * @param end End date of the range
    * @return True if the date is within the range, false otherwise
    */
   static bool       IsIn(datetime &date, datetime &start, datetime &end);

   /**
    * @brief Updates the start and end dates to match the given date.
    * @param date Source date to copy from
    * @param start Start date to update
    * @param end End date to update
    */
   static void       UpdateDate(MqlDateTime &date, MqlDateTime &start, MqlDateTime &end);

   /**
    * @brief Updates the start and end dates to match the given date.
    * @param date Source date to copy from
    * @param start Start date to update
    * @param end End date to update
    */
   static void       UpdateDate(datetime &date, datetime &start, datetime &end);

   /**
    * @brief Updates the start and end dates to match the current time.
    * @param start Start date to update
    * @param end End date to update
    */
   static void       UpdateDate(MqlDateTime &start, MqlDateTime &end);

   /**
    * @brief Updates the start and end dates to match the current time.
    * @param start Start date to update
    * @param end End date to update
    */
   static void       UpdateDate(datetime &start, datetime &end);
  };

//+------------------------------------------------------------------+
void TimeHelper::UpdateDateHelper(MqlDateTime &date, MqlDateTime &s, MqlDateTime &e)
  {
   s.day = date.day;
   s.mon = date.mon;
   s.year = date.year;

   e.day = date.day;
   e.mon = date.mon;
   e.year = date.year;
  }

//+------------------------------------------------------------------+
void TimeHelper::UpdateDateHelper(datetime &date, datetime &s, datetime &e)
  {
   MqlDateTime temp, tempS, tempE;
   TimeToStruct(date, temp);

   UpdateDateHelper(temp, tempS, tempE);
   s = StructToTime(tempS);
   e = StructToTime(tempE);
  }

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
bool TimeHelper::IsIn(datetime &date, datetime &start, datetime &end)
  { return date >= start && date <= end; }

//+------------------------------------------------------------------+
bool TimeHelper::IsIn(MqlDateTime &date, MqlDateTime &start, MqlDateTime &end)
  { return StructToTime(date) >= StructToTime(start) && StructToTime(date) <= StructToTime(end); }

//+------------------------------------------------------------------+
void TimeHelper::UpdateDate(MqlDateTime &date, MqlDateTime &start, MqlDateTime &end)
  { UpdateDateHelper(date, start, end); }

//+------------------------------------------------------------------+
void TimeHelper::UpdateDate(datetime &date, datetime &start, datetime &end)
  { UpdateDateHelper(date, start, end); }

//+------------------------------------------------------------------+
void TimeHelper::UpdateDate(MqlDateTime &start, MqlDateTime &end)
  {
   MqlDateTime temp;
   TimeToStruct(TimeCurrent(), temp);
   UpdateDateHelper(temp, start, end);
  }

//+------------------------------------------------------------------+
void TimeHelper::UpdateDate(datetime &start, datetime &end)
  {
   datetime temp = TimeCurrent();
   UpdateDateHelper(temp, start, end);
  }
//+------------------------------------------------------------------+
