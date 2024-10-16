//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
class DateTimeStringFormat
  {
public:
   static bool              IsValidDateTime(string dt)
     {
      // Separate date and time if necessary
      string datePart, timePart;
      long spaceIndex = StringFind(dt, " ");

      if(spaceIndex != -1)
        {
         datePart = StringSubstr(dt, 0, (int)spaceIndex);
         timePart = StringSubstr(dt, (int)spaceIndex + 1);
        }
      else
        {
         datePart = dt;
         timePart = "";
        }

      // If the date is valid, check the time part if it is present.
      if(IsDateValid(datePart))
        {
         if(timePart != "")
            return IsTimeValid(timePart);
         return true;
        }
      return false; // None of the formats are valid
     }

   static bool              IsDateValid(string date)
     {
      if(StringLen(date) == 8) // yyyymmdd
         return IsDateValid(StringSubstr(date, 0, 4), StringSubstr(date, 4, 2), StringSubstr(date, 6, 2));

      if(
         StringLen(date) == 10 && (
            StringFind(date, ".") == 4 || StringFind(date, "/") == 4 || StringFind(date, "-") == 4
         ) // yyyy.mm.dd || yyyy/mm/dd || // yyyy-mm-dd
      )
         return IsDateValid(StringSubstr(date, 0, 4), StringSubstr(date, 5, 2), StringSubstr(date, 8, 2));
      return false; // None of the formats are valid
     }

   static bool              IsTimeValid(string time)
     {
      if(StringLen(time) == 5 &&
         StringFind(time, ":") == 2) // hh:mi
         return IsTimeValid(StringSubstr(time, 0, 2),
                            StringSubstr(time, 3, 2),
                            "0");

      if(StringLen(time) == 6) // hhmiss
         return IsTimeValid(StringSubstr(time, 0, 2),
                            StringSubstr(time, 2, 2),
                            StringSubstr(time, 4, 2));

      if(StringLen(time) == 8 &&
         StringFind(time, ":") == 2 &&
         StringFind(time, ":", 3) == 5) // hh:mi:ss
         return IsTimeValid(StringSubstr(time, 0, 2),
                            StringSubstr(time, 3, 2),
                            StringSubstr(time, 6, 2));
      return false;
     }


private:
   static bool                 IsTimeValid(
      string hour,
      string minute,
      string second)
     {
      long h = StringToInteger(hour);
      long m = StringToInteger(minute);
      long s = (StringLen(second) > 0) ? StringToInteger(second) : 0; // Default  0 if not provided

      return (h >= 0 && h < 24 && m >= 0 && m < 60 && s >= 0 && s < 60);
     }

   static bool              IsDateValid(
      string year,
      string month,
      string day)
     {
      long y = StringToInteger(year);
      long m = StringToInteger(month);
      long d = StringToInteger(day);

      // Validate year, month and day
      if(y < 1 || m < 1 || m > 12 || d < 1 || d > 31)
         return false;

      // Adjustment for days of the month
      if(m == 2)  // February
        {
         if((y % 4 == 0 && y % 100 != 0) || (y % 400 == 0))
            return d <= 29; // Leap year
         else
            return d <= 28; // Non leap
        }
      if((m == 4 || m == 6 || m == 9 || m == 11) && d > 30)
         return false; // 30-day months

      return true;
     }
  };
//+------------------------------------------------------------------+
