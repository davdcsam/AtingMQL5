//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+

#include <Arrays/ArrayString.mqh>

//+------------------------------------------------------------------+
//| FilterByCSVFile                                                  |
//+------------------------------------------------------------------+
class FilterByCSVFile
  {

private:
   string            privateFileName;
   CArrayString      datesString;
   MqlDateTime       today;
   MqlDateTime       nextDate;
public:
                     FilterByCSVFile(void) {};

   bool              UpdateAtr(const string fileName)
     {
      if(!StringFind(fileName, ".csv", -1))
        {
         Alert("Extention file invalid");
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
         Alert(StringFormat(
                  "Failed to open %s. Err code: %d",
                  TerminalInfoString(TERMINAL_COMMONDATA_PATH) + "\\Files\\" + privateFileName,
                  GetLastError()
               ));
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

      TimeToStruct(StringToTime(datesString.At(0)), nextDate);

      if(nextDate.year < today.year)
        {
         datesString.Delete(0);
         return IsOperativeDay();
        }
      else
         if(nextDate.year > today.year)
            return true;

      if(nextDate.day_of_year < today.day_of_year)
        {
         datesString.Delete(0);
         return IsOperativeDay();
        }

      if(nextDate.day_of_year > today.day_of_year)
         return  true;

      // Implicit case if(nextDate.day_of_year == today.day_of_year)
      datesString.Delete(0);
      return false;
     }
  };
