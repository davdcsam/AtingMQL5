//+------------------------------------------------------------------+
//|                                               SectionTimeHandler |
//|                                         Copyright 2024, DavdCsam |
//|                                      https://github.com/davdcsam |
//+------------------------------------------------------------------+
// Include the SectionTime class from the SectionTime library
#include "SectionTime.mqh";

// Group of inputs related to section time
input group "Section Time"

// Inputs for the start and end times
input uchar input_start_time_hour = 15; // Start Hour
input uchar input_start_time_min = 0; // Start Min
input uchar input_start_time_seg = 6; // Start Seg
input uchar input_end_time_hour = 17; // End Hour
input uchar input_end_time_min = 0; // End Min
input uchar input_end_time_seg = 0; // End Seg

// Input to show the section time handler comment
input bool input_show_section_time_handler_comment = true; // Show Comment

// String to store the section time handler comment
string comment_section_time_handler;

// Create a new SectionTime object
SectionTime section_time(input_start_time_hour, input_start_time_min, input_start_time_seg, input_end_time_hour, input_end_time_min, input_end_time_seg);

// Function to return a string comment based on the result of the section time check
string comment_enum_section_time(ENUM_CHECK_SECTION_TIME enum_result)
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
         result = StringFormat("%s: Start Time %s is equal to End Time %s.", EnumToString(enum_result), section_time.start_time_str, section_time.end_time_str);
         break;

      // Case when the current time is over the end time
      case ERR_CURRENT_OVER_END:
         result = StringFormat("%s: Broker DateTime %s is over End Time %s.", EnumToString(enum_result), section_time.broker_datetime_str, section_time.end_time_str);
         break;

      // Default case when an unknown error occurred
      default:
         result = "Unknown error.";
         break;
     }

   return(result);
  }

// Function to update the section time comment
void update_comment_section_time()
  {
// If the input is set to show the section time handler comment
   if(input_show_section_time_handler_comment)
      // Format the section time handler comment
      comment_section_time_handler =  StringFormat(
                                         "\n Section Time from %s to %s - BrokerDateTime %s\n",
                                         section_time.start_time_str,
                                         section_time.end_time_str,
                                         section_time.broker_datetime_str
                                      );
   else
      // If the input is not set to show the section time handler comment, set the comment to an empty string
      comment_section_time_handler= "";
  }
//+------------------------------------------------------------------+
