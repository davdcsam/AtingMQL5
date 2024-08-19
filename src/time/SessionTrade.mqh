//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
/**
 * @struct SessionDay
 * @brief Structure to hold session information for a day.
 */
struct SessionDay
  {
   ENUM_DAY_OF_WEEK  dayWeek;   /**< Day of the week */
   datetime          start;     /**< Start time of the session */
   datetime          end;       /**< End time of the session */
   bool              available; /**< Availability of the session */
  };

//+------------------------------------------------------------------+
/**
 * @class SessionTrade
 * @brief Class to handle trading sessions for different days of the week.
 */
class SessionTrade
  {
private:
   SessionDay        SessionWeek[6]; /**< Array to hold session data for the week */

   /**
    * @brief Converts a SessionDay object to a string.
    * @param day Reference to a SessionDay object.
    * @return A string representation of the session day.
    */
   string            SessionDayToString(SessionDay &day);

   /**
    * @brief Gets the session information for a specific day and symbol.
    * @param sym The symbol to get the session information for.
    * @param dayWeek The day of the week to get the session information for.
    * @return A SessionDay object with the session information.
    */
   SessionDay        GetSymbolInfoSessionTrade(const string &sym, const ENUM_DAY_OF_WEEK dayWeek);

public:
   /**
    * @brief Constructor for the SessionTrade class.
    */
                     SessionTrade(void) {};

   /**
    * @brief Destructor for the SessionTrade class.
    */
                    ~SessionTrade(void) {};

   /**
    * @brief Populates the SessionWeek array with the session information for the week.
    */
   void              GetSessionWeek();

   /**
    * @brief Prints the session information for the week.
    */
   void              PrintSessionWeek();

   /**
    * @brief Gets the session information for a specific day.
    * @param dayW The day of the week to get the session information for.
    * @return A SessionDay object with the session information.
    */
   SessionDay        GetDay(ENUM_DAY_OF_WEEK dayW);
  };

//+------------------------------------------------------------------+
string SessionTrade::SessionDayToString(SessionDay &day)
  {
   return day.available ?
          StringFormat("%s: From %s to %s", EnumToString(day.dayWeek), TimeToString(day.start, TIME_DATE | TIME_MINUTES), TimeToString(day.end, TIME_DATE | TIME_MINUTES)) :
          StringFormat("%s isn't available", EnumToString(day.dayWeek));
  }

//+------------------------------------------------------------------+
SessionDay SessionTrade::GetSymbolInfoSessionTrade(const string &sym, const ENUM_DAY_OF_WEEK dayWeek)
  {
   SessionDay day;
   day.dayWeek = dayWeek;
   day.available = SymbolInfoSessionTrade(sym, dayWeek, 0, day.start, day.end);

   if(!day.available)
      PrintFormat("SymbolInfoSessionTrade() failed. Error %d Day %s", GetLastError(), EnumToString(dayWeek));

   return day;
  }

//+------------------------------------------------------------------+
void SessionTrade::GetSessionWeek()
  {
   MqlDateTime currentTime;
   TimeTradeServer(currentTime);
// Set hour, min & sec to only update the date
   currentTime.hour = 0;
   currentTime.min = 0;
   currentTime.sec = 0;
   datetime currentDateTime = StructToTime(currentTime);
   for(ENUM_DAY_OF_WEEK i=MONDAY; i<=SATURDAY; i++)
     {
      //Print("\nBefore ", SessionDayToString(SessionWeek[i-1]));
      SessionWeek[i - 1] = GetSymbolInfoSessionTrade(_Symbol, i);
      //Print("Pre Offset ", SessionDayToString(SessionWeek[i-1]));
      datetime sessionOffset = currentDateTime + PeriodSeconds(PERIOD_D1) * (i - currentTime.day_of_week);
      SessionWeek[i - 1].start += sessionOffset;
      SessionWeek[i - 1].end += sessionOffset;
      //Print("After ", SessionDayToString(SessionWeek[i-1]));
     }
  }

//+------------------------------------------------------------------+
void SessionTrade::PrintSessionWeek()
  {
   for(int i=0;i<ArraySize(SessionWeek);i++)
     { Print(SessionDayToString(SessionWeek[i])); }
  }

//+------------------------------------------------------------------+
SessionDay SessionTrade::GetDay(ENUM_DAY_OF_WEEK dayW)
  {
   SessionDay day;

   for(int i=0;i<ArraySize(SessionWeek);i++)
     {
      if(SessionWeek[i].dayWeek == dayW)
        {
         day = SessionWeek[i];
         break;
        }
     }
   return day;
  }
//+------------------------------------------------------------------+
