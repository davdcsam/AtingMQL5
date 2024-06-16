//+------------------------------------------------------------------+
//|                                                  SectionTime.mqh |
//|                                         Copyright 2024, davdcsam |
//|                                      https://github.com/davdcsam |
//+------------------------------------------------------------------+

// Cadena de responsabilidades
// O array de funciones lambdas

// Class to handle section times
class SectionTime
  {
public:
   // Enum to handle different types of section time checks
   enum ENUM_CHECK_SECTION_TIME
     {
      CHECK_ARG_SECTION_TIME_PASSED, // Check for section time passed
      ERR_START_EQUAL_END, // Error: Start time is equal to end time
      ERR_CURRENT_OVER_END // Error: Current time is over end time
     };

private:
   // Start and end times for the section
   uchar             startHour, startMin, startSeg, endHour, endMin, endSeg;

public:
   // Constructor for the SectionTime class
                     SectionTime(void) {}

   void              UpdateAtr(
      uchar start_time_hour,
      uchar start_time_min,
      uchar start_time_seg,
      uchar end_time_hour,
      uchar end_time_min,
      uchar end_time_seg
   )
     {
      // Set the start and end times for the section
      startHour = start_time_hour;
      startMin = start_time_min;
      startSeg = start_time_seg;
      endHour = end_time_hour;
      endMin = end_time_min;
      endSeg = end_time_seg;
     }

   // Datetime for the start, end, and broker times
   MqlDateTime       startDateTime, endDateTime, brokerDateTime;

   // Function to check the arguments for the section time
   ENUM_CHECK_SECTION_TIME CheckArg()
     {
      // Update the times
      Update();

      // If the start time is equal to the end time, return an error
      if(StructToTime(startDateTime) == StructToTime(endDateTime))
         return(ERR_START_EQUAL_END);

      // If the current time is over the end time, return an error
      if(StructToTime(brokerDateTime) >= StructToTime(endDateTime))
         return(ERR_CURRENT_OVER_END);

      // If the checks pass, return CHECK_ARG_SECTION_TIME_PASSED
      return(CHECK_ARG_SECTION_TIME_PASSED);
     }

   // Function to update the times
   void              Update()
     {
      // Get the current time
      TimeToStruct(TimeCurrent(), brokerDateTime);

      // Set the start and end times
      startDateTime.year = brokerDateTime.year;
      startDateTime.mon = brokerDateTime.mon;
      startDateTime.day = brokerDateTime.day;
      startDateTime.hour = startHour;
      startDateTime.min = startMin;
      startDateTime.sec = startSeg;

      endDateTime.year = brokerDateTime.year;
      endDateTime.mon = brokerDateTime.mon;
      endDateTime.day = brokerDateTime.day;
      endDateTime.hour = endHour;
      endDateTime.min = endMin;
      endDateTime.sec = endSeg;

      // If the start time is greater than the end time, swap them
      if(StructToTime(startDateTime) > StructToTime(endDateTime))
        {
         MqlDateTime temp = startDateTime;
         startDateTime = endDateTime;
         endDateTime = temp;
        }
     }

   // Function to verify if the current time is inside the section
   bool              VerifyInsideSection()
     {
      // Return true if the current time is between the start and end times, otherwise return false
      return(StructToTime(startDateTime) <= StructToTime(brokerDateTime) && StructToTime(brokerDateTime) <= StructToTime(endDateTime));
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
            result = StringFormat(
                        "%s: Start Time %s is equal to End Time %s.",
                        EnumToString(enum_result),
                        StringFormat("%02d:%02d:%02d", startDateTime.hour, startDateTime.min, startDateTime.sec), StringFormat("%02d:%02d:%02d", endDateTime.hour, endDateTime.min, endDateTime.sec)
                     );
            break;

         // Case when the current time is over the end time
         case ERR_CURRENT_OVER_END:
            result = StringFormat(
                        "%s: Broker DateTime %s is over End Time %s.",
                        EnumToString(enum_result),
                        StringFormat("%02d-%02d %02d:%02d:%02d", brokerDateTime.mon, brokerDateTime.day, brokerDateTime.hour, brokerDateTime.min, brokerDateTime.sec),
                        StringFormat("%02d:%02d:%02d", endDateTime.hour, endDateTime.min, endDateTime.sec)
                     );
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
                StringFormat("%02d:%02d:%02d", startDateTime.hour, startDateTime.min, startDateTime.sec),
                StringFormat("%02d:%02d:%02d", endDateTime.hour, endDateTime.min, endDateTime.sec),
                EnumToString(ENUM_DAY_OF_WEEK(brokerDateTime.day_of_week)),
                StringFormat("%02d-%02d %02d:%02d:%02d", brokerDateTime.mon, brokerDateTime.day, brokerDateTime.hour, brokerDateTime.min, brokerDateTime.sec)
             );
     }

  };
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
