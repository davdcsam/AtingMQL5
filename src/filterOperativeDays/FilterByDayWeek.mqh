//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+
#include <Arrays/ArrayString.mqh>

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
//+------------------------------------------------------------------+
