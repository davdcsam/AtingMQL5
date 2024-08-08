//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+
#include <Arrays/ArrayString.mqh>

//+------------------------------------------------------------------+
/**
 * @class FilterByCSVFile
 * @brief Class to handle filtering based on CSV file data.
 */
class FilterByCSVFile
  {
private:
   /**
    * @brief Name of the CSV file.
    */
   string            privateFileName;

   /**
    * @brief Array to store dates read from the CSV file.
    */
   CArrayString      datesString;

   /**
    * @brief Date and time structure for the current date.
    */
   MqlDateTime       today;

   /**
    * @brief Date and time structure for the next date read from the CSV file.
    */
   MqlDateTime       nextDate;

public:
   /**
    * @brief Default constructor for the FilterByCSVFile class.
    */
                     FilterByCSVFile(void) {};

   /**
    * @brief Updates the file name for the CSV file.
    * @param fileName Name of the CSV file.
    * @return True if the file name has a valid ".csv" extension, otherwise false.
    */
   bool              UpdateAtr(const string fileName);

   /**
    * @brief Reads dates from the CSV file and stores them in the `datesString` array.
    * @return True if the file is successfully read, otherwise false.
    */
   bool              Read();

   /**
    * @brief Checks if today is an operative day based on the dates read from the CSV file.
    * @return True if today is an operative day or if the CSV file is empty, otherwise false.
    */
   bool              IsOperativeDay(void);
  };

//+------------------------------------------------------------------+
bool FilterByCSVFile::UpdateAtr(const string fileName)
  {
   if(!StringFind(fileName, ".csv", -1))
     {
      Alert("Extension file invalid");
      return false;
     }

   privateFileName = fileName;
   return true;
  }

//+------------------------------------------------------------------+
bool FilterByCSVFile::Read()
  {
   int fileHandle = FileOpen(privateFileName, FILE_ANSI | FILE_READ | FILE_CSV | FILE_COMMON, "\t");
   if(fileHandle == INVALID_HANDLE)
     {
      Alert(StringFormat(
               "Failed to open %s. Err code: %d",
               TerminalInfoString(TERMINAL_COMMONDATA_PATH) + "\\Files\\" + privateFileName,
               GetLastError()
            ));
      return false;
     }

   PrintFormat("File %s found", privateFileName);

   datesString.Clear();
   while(!FileIsEnding(fileHandle))
     {
      datesString.Add(FileReadString(fileHandle));
     }

   FileClose(fileHandle);
   return true;
  }

//+------------------------------------------------------------------+
bool FilterByCSVFile::IsOperativeDay(void)
  {
   if(!datesString.Total())
      return true;

   PrintFormat("Evaluating %s", datesString.At(0));

   TimeTradeServer(today);

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
      return true;

// Implicit case if(nextDate.day_of_year == today.day_of_year)
   datesString.Delete(0);
   return false;
  }
//+------------------------------------------------------------------+
