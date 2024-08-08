//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+
#include "TimeHelper.mqh"

//+------------------------------------------------------------------+
/**
 * @brief Manages the start and end times for a section.
 */
class SectionTime
  {
private:
   uchar             startHour, startMin, startSeg; ///< Start time components
   uchar             endHour, endMin, endSeg; ///< End time components

public:
                     SectionTime(void) {};
                    ~SectionTime(void) {};

   /**
    * @brief Enum to handle different types of section time checks.
    */
   enum ENUM_CHECK_SECTION_TIME
     {
      CHECK_ARG_SECTION_TIME_PASSED, ///< Check if the section time has passed
      ERR_START_EQUAL_END, ///< Error: Start time is equal to end time
      ERR_CURRENT_OVER_END ///< Error: Current time is over end time
     };

   /**
    * @brief Updates the section's start and end times.
    * @param start_time_hour Start time hour
    * @param start_time_min Start time minute
    * @param start_time_seg Start time second
    * @param end_time_hour End time hour
    * @param end_time_min End time minute
    * @param end_time_seg End time second
    */
   void              UpdateAtr(uchar start_time_hour, uchar start_time_min, uchar start_time_seg, uchar end_time_hour, uchar end_time_min, uchar end_time_seg);

   MqlDateTime       startDateTime, endDateTime, brokerDateTime; ///< DateTime structures for start, end, and broker times

   /**
    * @brief Checks the validity of the section time arguments.
    * @return The result of the check as ENUM_CHECK_SECTION_TIME
    */
   ENUM_CHECK_SECTION_TIME CheckArg();

   /**
    * @brief Updates the section's DateTime structures with current values.
    */
   void              Update();

   /**
    * @brief Verifies if the current time is within the section's start and end times.
    * @return True if the current time is within the section, otherwise false
    */
   bool              VerifyInsideSection();

   /**
    * @brief Converts the ENUM_CHECK_SECTION_TIME result to a string.
    * @param enum_result The ENUM_CHECK_SECTION_TIME result to convert
    * @return A string representation of the enum result
    */
   string            EnumCheckSectionTimeToString(ENUM_CHECK_SECTION_TIME enum_result);

   /**
    * @brief Returns a formatted comment with section time information.
    * @return A string with the section time details
    */
   string            CommentToShow();
  };

//+------------------------------------------------------------------+
void SectionTime::UpdateAtr(
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
void SectionTime::Update()
  {
   TimeToStruct(TimeTradeServer(), brokerDateTime);

   TimeHelper::UpdateDate(brokerDateTime, startDateTime, endDateTime);
   startDateTime.hour = startHour;
   startDateTime.min = startMin;
   startDateTime.sec = startSeg;
   endDateTime.hour = endHour;
   endDateTime.min = endMin;
   endDateTime.sec = endSeg;

   TimeHelper::Sort(startDateTime, endDateTime);
  }

//+------------------------------------------------------------------+
bool SectionTime::VerifyInsideSection()
  {
   return TimeHelper::IsIn(brokerDateTime, startDateTime, endDateTime);
  }

//+------------------------------------------------------------------+
string SectionTime::EnumCheckSectionTimeToString(ENUM_CHECK_SECTION_TIME enum_result)
  {
   string result;

   switch(enum_result)
     {
      case CHECK_ARG_SECTION_TIME_PASSED:
         result = StringFormat("%s: Arguments passed the check.", EnumToString(enum_result));
         break;
      case ERR_START_EQUAL_END:
         result = StringFormat(
                     "%s: Start Time %s is equal to End Time %s.",
                     EnumToString(enum_result),
                     StringFormat("%02d:%02d:%02d", startDateTime.hour, startDateTime.min, startDateTime.sec),
                     StringFormat("%02d:%02d:%02d", endDateTime.hour, endDateTime.min, endDateTime.sec)
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
      default:
         result = "Unknown error.";
         break;
     }

   return(result);
  }

//+------------------------------------------------------------------+
string SectionTime::CommentToShow()
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
