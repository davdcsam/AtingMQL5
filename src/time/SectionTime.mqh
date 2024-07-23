//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+
#include "TimeHelper.mqh"

//+------------------------------------------------------------------+
class SectionTime
  {
private:
   //--- Start and end times for the section
   uchar             startHour, startMin, startSeg, endHour, endMin, endSeg;

public:
                     SectionTime(void) {};
                    ~SectionTime(void) {};

   //--- Enum to handle different types of section time checks
   enum ENUM_CHECK_SECTION_TIME
     {
      CHECK_ARG_SECTION_TIME_PASSED, //--- Check for section time passed
      ERR_START_EQUAL_END, //--- Error: Start time is equal to end time
      ERR_CURRENT_OVER_END //--- Error: Current time is over end time
     };

   void              UpdateAtr(
      uchar start_time_hour,
      uchar start_time_min,
      uchar start_time_seg,
      uchar end_time_hour,
      uchar end_time_min,
      uchar end_time_seg
   );

   MqlDateTime       startDateTime, endDateTime, brokerDateTime;

   ENUM_CHECK_SECTION_TIME CheckArg();
   void              Update();
   bool              VerifyInsideSection();
   string            EnumCheckSectionTimeToString(ENUM_CHECK_SECTION_TIME enum_result);
   string              CommentToShow();

  };

//+------------------------------------------------------------------+
void              SectionTime::UpdateAtr(
   uchar start_time_hour,
   uchar start_time_min,
   uchar start_time_seg,
   uchar end_time_hour,
   uchar end_time_min,
   uchar end_time_seg
)
  {
   startHour = start_time_hour;
   startMin = start_time_min;
   startSeg = start_time_seg;
   endHour = end_time_hour;
   endMin = end_time_min;
   endSeg = end_time_seg;
  }

//+------------------------------------------------------------------+
SectionTime::ENUM_CHECK_SECTION_TIME SectionTime::CheckArg()
  {
   Update();

   if(StructToTime(startDateTime) == StructToTime(endDateTime))
      return(ERR_START_EQUAL_END);

   if(StructToTime(brokerDateTime) >= StructToTime(endDateTime))
      return(ERR_CURRENT_OVER_END);

   return(CHECK_ARG_SECTION_TIME_PASSED);
  }

//+------------------------------------------------------------------+
void              SectionTime::Update()
  {
   TimeToStruct(TimeCurrent(), brokerDateTime);

   TimeHelper::UpdateDate(brokerDateTime, startDateTime, endDateTime);
   startDateTime.hour = startHour;
   startDateTime.min = startMin;
   startDateTime.sec = startSeg;
   endDateTime.hour = endHour;
   endDateTime.min = endMin;
   endDateTime.sec = endSeg;

   TimeHelper::Sort(startDateTime, endDateTime);
  }

//--- Verify if the current time is inside the section
//+------------------------------------------------------------------+
bool              SectionTime::VerifyInsideSection()
  {
//--- Return true if the current time is between the start and end times, otherwise return false
   return TimeHelper::IsIn(brokerDateTime, startDateTime, endDateTime);
  }

//--- Function to return a string comment based on the result of the section time check
//+------------------------------------------------------------------+
string            SectionTime::EnumCheckSectionTimeToString(ENUM_CHECK_SECTION_TIME enum_result)
  {
   string result;

//--- Switch case based on the result of the section time check
   switch(enum_result)
     {
      case CHECK_ARG_SECTION_TIME_PASSED:
         result = StringFormat("%s: Arguments passed the check.", EnumToString(enum_result));
         break;
      case ERR_START_EQUAL_END:
         result = StringFormat(
                     "%s: Start Time %s is equal to End Time %s.",
                     EnumToString(enum_result),
                     StringFormat("%02d:%02d:%02d", startDateTime.hour, startDateTime.min, startDateTime.sec), StringFormat("%02d:%02d:%02d", endDateTime.hour, endDateTime.min, endDateTime.sec)
                  );
         break;
      case ERR_CURRENT_OVER_END:
         result = StringFormat(
                     "%s: Broker DateTime %s is over End Time %s.",
                     EnumToString(enum_result),
                     StringFormat("%02d-%02d %02d:%02d:%02d", brokerDateTime.mon, brokerDateTime.day, brokerDateTime.hour, brokerDateTime.min, brokerDateTime.sec),
                     StringFormat("%02d:%02d:%02d", endDateTime.hour, endDateTime.min, endDateTime.sec)
                  );
         break;
      //--- Default case when an unknown error occurred
      default:
         result = "Unknown error.";
         break;
     }

   return(result);
  }

//--- Return formated comment
//+------------------------------------------------------------------+
string              SectionTime::CommentToShow()
  {
   return StringFormat(
             "\n Section Time from %s to %s - BrokerDateTime %s %s\n",
             StringFormat("%02d:%02d:%02d", startDateTime.hour, startDateTime.min, startDateTime.sec),
             StringFormat("%02d:%02d:%02d", endDateTime.hour, endDateTime.min, endDateTime.sec),
             EnumToString(ENUM_DAY_OF_WEEK(brokerDateTime.day_of_week)),
             StringFormat("%02d-%02d %02d:%02d:%02d", brokerDateTime.mon, brokerDateTime.day, brokerDateTime.hour, brokerDateTime.min, brokerDateTime.sec)
          );
  }
//+------------------------------------------------------------------+
