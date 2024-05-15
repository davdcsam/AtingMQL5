//+------------------------------------------------------------------+
//|                                                    FilterOD.mqh |
//|                                         Copyright 2024, davdcsam |
//|                                      https://github.com/davdcsam |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, davdcsam"
#property link      "https://github.com/davdcsam"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class FilterByDayWeek
  {
public:
   struct Frame
     {
      bool           sunday;
      bool           monday;
      bool           tuesday;
      bool           wednesday;
      bool           thursday;
      bool           friday;
      bool           saturday;
     };

private:
   Frame             frame;
   MqlDateTime       today;
public:
                     FilterByDayWeek(void) {};

   void              UpdateAtr(Frame &no_operation_days) { frame = no_operation_days; }

   bool              IsOperativeDay(void)
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
  };
//+------------------------------------------------------------------+
