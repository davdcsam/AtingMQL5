//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+
#include <Arrays/ArrayInt.mqh>

//+------------------------------------------------------------------+
/**
 * @class FilterByDayWeek
 * @brief Class to determine if today is an operative day based on weekdays.
 */
class FilterByDayWeek
  {
public:
   /**
    * @struct Frame
    * @brief Structure to hold boolean values for each day of the week.
    */
   struct Frame
     {
      bool           sunday;    ///< Indicates if Sunday is an operative day
      bool           monday;    ///< Indicates if Monday is an operative day
      bool           tuesday;   ///< Indicates if Tuesday is an operative day
      bool           wednesday; ///< Indicates if Wednesday is an operative day
      bool           thursday;  ///< Indicates if Thursday is an operative day
      bool           friday;    ///< Indicates if Friday is an operative day
      bool           saturday;  ///< Indicates if Saturday is an operative day
     };

private:
   /**
    * @brief Frame to store the operation status for each day of the week.
    */
   Frame             frame;

   /**
    * @brief Date and time structure for the current date.
    */
   MqlDateTime       today;

public:
   /**
    * @brief Default constructor for the FilterByDayWeek class.
    */
                     FilterByDayWeek(void) {};

   /**
    * @brief Updates the frame with the provided operation days.
    * @param noOperationDays Structure containing operation status for each day of the week.
    */
   void              UpdateAtr(Frame &noOperationDays);

   /**
    * @brief Determines if today is an operative day based on the frame.
    * @return True if today is an operative day according to the frame; otherwise, false.
    */
   bool              IsOperativeDay(void);
  };

//+------------------------------------------------------------------+
void FilterByDayWeek::UpdateAtr(Frame &noOperationDays)
  {
   frame = noOperationDays;
  }

//+------------------------------------------------------------------+
bool FilterByDayWeek::IsOperativeDay(void)
  {
   TimeCurrent(today);

   switch(today.day_of_week)
     {
      case SUNDAY:
         return frame.sunday;
      case MONDAY:
         return frame.monday;
      case TUESDAY:
         return frame.tuesday;
      case WEDNESDAY:
         return frame.wednesday;
      case THURSDAY:
         return frame.thursday;
      case FRIDAY:
         return frame.friday;
      case SATURDAY:
         return frame.saturday;
      default:
         return false;
     }
  }

/**
 * @struct Week
 * @brief Structure to hold boolean values for each day of the week.
 */
struct Week
  {
   bool              sunday;    ///< Indicates if Sunday is an operative day
   bool              monday;    ///< Indicates if Monday is an operative day
   bool              tuesday;   ///< Indicates if Tuesday is an operative day
   bool              wednesday; ///< Indicates if Wednesday is an operative day
   bool              thursday;  ///< Indicates if Thursday is an operative day
   bool              friday;    ///< Indicates if Friday is an operative day
   bool              saturday;  ///< Indicates if Saturday is an operative day
  };

//+------------------------------------------------------------------+
/**
 * @class FilterByDayWeek1
 * @brief Class to determine if today is an operative day based on weekdays.
 */
class FilterByDayWeek1
  {
private:
   /**
    * @brief Save the days available to trade.
    */
   CArrayInt         weekOp;

   /**
    * @brief Date and time structure for the current date.
    */
   MqlDateTime       today;

public:
   /**
    * @brief Default constructor for the FilterByDayWeek1 class.
    */
                     FilterByDayWeek1(void) {};

   /**
    * @brief Updates the frame with the provided operation days.
    * @param OperationDays Structure containing operation status for each day of the week.
    */
   void              UpdateAtr(Week &OperationDays);

   /**
    * @brief Determines if today is an operative day based on the array.
    * @return True if today is an operative day according to the array; otherwise, false.
    */
   bool              IsOperativeDay(void);
  };

//+------------------------------------------------------------------+
void FilterByDayWeek1::UpdateAtr(Week &nonDays)
  {
   weekOp.Shutdown();
   if(nonDays.sunday)
      weekOp.Add(SUNDAY);
   if(nonDays.monday)
      weekOp.Add(MONDAY);
   if(nonDays.tuesday)
      weekOp.Add(TUESDAY);
   if(nonDays.wednesday)
      weekOp.Add(WEDNESDAY);
   if(nonDays.thursday)
      weekOp.Add(THURSDAY);
   if(nonDays.friday)
      weekOp.Add(FRIDAY);
   if(nonDays.saturday)
      weekOp.Add(SATURDAY);
  }

//+------------------------------------------------------------------+
bool FilterByDayWeek1::IsOperativeDay(void)
  {
   TimeTradeServer(today);
   return (weekOp.SearchLinear(today.day_of_week) < 0) ? false : true;
  }
//+------------------------------------------------------------------+
