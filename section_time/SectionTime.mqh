//+------------------------------------------------------------------+
//|                                                  SectionTime.mqh |
//|                                         Copyright 2024, davdcsam |
//|                                      https://github.com/davdcsam |
//+------------------------------------------------------------------+

// Enum to handle different types of section time checks
enum ENUM_CHECK_SECTION_TIME
  {
   CHECK_ARG_SECTION_TIME_PASSED, // Check for section time passed
   ERR_START_EQUAL_END, // Error: Start time is equal to end time
   ERR_CURRENT_OVER_END // Error: Current time is over end time
  };


// Class to handle section times
class SectionTime
  {
private:
   // Start and end times for the section
   uchar             start_hour, start_min, start_seg, end_hour, end_min, end_seg;

public:
   // Constructor for the SectionTime class
                     SectionTime(
      uchar start_time_hour,
      uchar start_time_min,
      uchar start_time_seg,
      uchar end_time_hour,
      uchar end_time_min,
      uchar end_time_seg
   )
     {
      // Set the start and end times for the section
      start_hour = start_time_hour;
      start_min = start_time_min;
      start_seg = start_time_seg;
      end_hour = end_time_hour;
      end_min = end_time_min;
      end_seg = end_time_seg;
     }

   // Datetime for the start, end, and broker times
   MqlDateTime       start_datetime, end_datetime, broker_datetime;

   // Strings for the start, end, and broker times
   string            start_time_str, end_time_str, broker_datetime_str;

   // Function to check the arguments for the section time
   ENUM_CHECK_SECTION_TIME CheckArg()
     {
      // Update the times
      Update();

      // If the start time is equal to the end time, return an error
      if(StructToTime(start_datetime) == StructToTime(end_datetime))
         return(ERR_START_EQUAL_END);

      // If the current time is over the end time, return an error
      if(StructToTime(broker_datetime) >= StructToTime(end_datetime))
         return(ERR_CURRENT_OVER_END);

      // If the checks pass, return CHECK_ARG_SECTION_TIME_PASSED
      return(CHECK_ARG_SECTION_TIME_PASSED);
     }

   // Function to update the times
   void              Update()
     {
      // Get the current time
      TimeToStruct(TimeCurrent(), broker_datetime);

      // Set the start and end times
      start_datetime.year = broker_datetime.year;
      start_datetime.mon = broker_datetime.mon;
      start_datetime.day = broker_datetime.day;
      start_datetime.hour = start_hour;
      start_datetime.min = start_min;
      start_datetime.sec = start_seg;

      end_datetime.year = broker_datetime.year;
      end_datetime.mon = broker_datetime.mon;
      end_datetime.day = broker_datetime.day;
      end_datetime.hour = end_hour;
      end_datetime.min = end_min;
      end_datetime.sec = end_seg;

      // If the start time is greater than the end time, swap them
      if(StructToTime(start_datetime) > StructToTime(end_datetime))
        {
         MqlDateTime temp = start_datetime;
         start_datetime = end_datetime;
         end_datetime = temp;
        }

      // Format the start, end, and broker times
      start_time_str = StringFormat("%02d:%02d:%02d", start_datetime.hour, start_datetime.min, start_datetime.sec);
      end_time_str = StringFormat("%02d:%02d:%02d", end_datetime.hour, end_datetime.min, end_datetime.sec);
      broker_datetime_str = StringFormat("%02d-%02d %02d:%02d:%02d", broker_datetime.mon, broker_datetime.day, broker_datetime.hour, broker_datetime.min, broker_datetime.sec);
     }

   // Function to verify if the current time is inside the section
   bool              VerifyInsideSection()
     {
      // Return true if the current time is between the start and end times, otherwise return false
      return(StructToTime(start_datetime) <= StructToTime(broker_datetime) && StructToTime(broker_datetime) <= StructToTime(end_datetime));
     }

   // Function to return a string comment based on the result of the section time check
   string            EnumCheckSectionTimeToString(ENUM_CHECK_SECTION_TIME enum_result)
     {
      string result;

      // Switch case based on the result of the section time check
      switch(enum_result)
        {
         // Case when the arguments passed the check
         case CHECK_ARG_SECTION_TIME_PASSED:
            result = StringFormat("%s: Arguments passed the check.", EnumToString(enum_result));
            break;

         // Case when the start time is equal to the end time
         case ERR_START_EQUAL_END:
            result = StringFormat("%s: Start Time %s is equal to End Time %s.", EnumToString(enum_result), start_time_str, end_time_str);
            break;

         // Case when the current time is over the end time
         case ERR_CURRENT_OVER_END:
            result = StringFormat("%s: Broker DateTime %s is over End Time %s.", EnumToString(enum_result), broker_datetime_str, end_time_str);
            break;

         // Default case when an unknown error occurred
         default:
            result = "Unknown error.";
            break;
        }

      return(result);
     }

   // Function to update the section time comment
   string              CommentToShow()
     {
      // Format the section time handler comment
      return StringFormat(
                "\n Section Time from %s to %s - BrokerDateTime %s %s\n",
                start_time_str,
                end_time_str,
                EnumToString(ENUM_DAY_OF_WEEK(broker_datetime.day_of_week)),
                broker_datetime_str
             );
     }     

  };
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
