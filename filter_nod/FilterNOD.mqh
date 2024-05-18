//+------------------------------------------------------------------+
//|                                                    FilterOD.mqh |
//|                                         Copyright 2024, davdcsam |
//|                                      https://github.com/davdcsam |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, davdcsam"
#property link      "https://github.com/davdcsam"

#include <Arrays/ArrayString.mqh>

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

   void              UpdateAtr(Frame &noOperationDays) { frame = noOperationDays; }

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
//|                                                                  |
//+------------------------------------------------------------------+
class FilterByCSVFile
  {

private:
   string            privateFileName;
   CArrayString      datesString;
   MqlDateTime       today;
   MqlDateTime       next_date;
public:
                     FilterByCSVFile(void) {};

   bool              UpdateAtr(const string fileName)
     {
      if(!StringFind(fileName, ".csv", -1))
        {
         Print("Extention file invalid");
         return false;
        }

      privateFileName = fileName;
      return true;
     }

   bool                 Read()
     {
      int fileHandle = FileOpen(privateFileName,FILE_ANSI|FILE_READ|FILE_CSV|FILE_COMMON, "\t");
      if(fileHandle == INVALID_HANDLE)
        {
         PrintFormat("Failed to open %s file. Err code: %d", privateFileName, GetLastError());
         return false;
        };

      PrintFormat("File %s found", privateFileName);

      datesString.Clear();
      while(!FileIsEnding(fileHandle))
        {
         datesString.Add(FileReadString(fileHandle));
        }

      FileClose(fileHandle);
      return true;
     }

   bool              IsOperativeDay(void)
     {
      if(!datesString.Total())
         return true;

      PrintFormat("Evaluating %s", datesString.At(0));

      TimeCurrent(today);

      TimeToStruct(StringToTime(datesString.At(0)), next_date);

      if(next_date.year < today.year)
        {
         datesString.Delete(0);
         return IsOperativeDay();
        }
      else
         if(next_date.year > today.year)
            return true;

      if(next_date.day_of_year < today.day_of_year)
        {
         datesString.Delete(0);
         return IsOperativeDay();
        }

      if(next_date.day_of_year > today.day_of_year)
         return  true;

      // Implicit case if(next_date.day_of_year == today.day_of_year)
      datesString.Delete(0);
      return false;
     }
  };

//+------------------------------------------------------------------+
