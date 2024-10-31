//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+
#include "SessionTradeTree.mqh"

/*
    ____        _     _ _        __  __      _   _               _
   |  _ \ _   _| |__ | (_) ___  |  \/  | ___| |_| |__   ___   __| |___
   | |_) | | | | '_ \| | |/ __| | |\/| |/ _ \ __| '_ \ / _ \ / _` / __|
   |  __/| |_| | |_) | | | (__  | |  | |  __/ |_| | | | (_) | (_| \__ \
   |_|    \__,_|_.__/|_|_|\___| |_|  |_|\___|\__|_| |_|\___/ \__,_|___/

*/

//+------------------------------------------------------------------+
SessionTradeTree::SessionTradeTree(void) {};

//+------------------------------------------------------------------+
SessionTradeTree::~SessionTradeTree(void) {};

/*
    _  _         _
   | \| |___  __| |___ ___
   | .` / _ \/ _` / -_|_-<
   |_|\_\___/\__,_\___/__/
*/
//+------------------------------------------------------------------+
void              SessionTradeTree::Insert(datetime date,
      datetime timeStart,
      datetime timeEnd)
  {
   this.root = this.InsertNode(this.root, this.DateTimeToDate(date), timeStart, timeEnd);
  }

/*
     ___     _
    / __|___| |_
   | (_ / -_)  _|
    \___\___|\__|

*/
//+------------------------------------------------------------------+
int               SessionTradeTree::GetFromTicksRange(datetime start,
      datetime end)
  {
   MqlTick tickArr[];
   int totalTickArr = CopyTicksRange(_Symbol, tickArr, COPY_TICKS_ALL, start*1000, end*1000);

   if(totalTickArr == -1)
     {
      Print("Error code %s.", GetLastError());
      return -1;
     }
   else
      if(ArraySize(tickArr) < 1)
        {
         PrintFormat("There are no quotes between %s & %s", TimeToString(start), TimeToString(end));
         return 0;
        }

   this.ExtractFirstAndLastTicks(tickArr);
   return 1;
  }

/*
    ___ _ _
   | __(_) |___
   | _|| | / -_)
   |_| |_|_\___|

*/
//+------------------------------------------------------------------+
bool              SessionTradeTree::LoadCSV(string fileName)
  {
   if(!StringFind(fileName, ".csv", -1))
     {
      Alert("Extension file invalid");
      return false;
     }
   ushort delimiter = 44; // default "," character
   if(!this.DetectDelimiter(fileName, delimiter))
      return false;
   int fileHandle = FileOpen(fileName, FILE_ANSI | FILE_READ | FILE_CSV | FILE_COMMON);
   return this.LoadCommonMethod(fileHandle, fileName, delimiter);
  }

//+------------------------------------------------------------------+
bool              SessionTradeTree::LoadTXT(string fileName)
  {
   if(!StringFind(fileName, ".txt", -1))
     {
      Alert("Extension file invalid");
      return false;
     }
   ushort delimiter = 44; // default "," character
   if(!this.DetectDelimiter(fileName, delimiter))
      return false;
   int fileHandle = FileOpen(fileName, FILE_ANSI | FILE_READ | FILE_TXT | FILE_COMMON);
   return this.LoadCommonMethod(fileHandle, fileName, delimiter);
  }

//+------------------------------------------------------------------+
bool              SessionTradeTree::SaveTXT(string fileName = NULL)
  {
   if(!StringFind(fileName, ".txt", -1))
     {
      Alert("Extension file invalid");
      return false;
     }

   CArrayObj arr;
   this.ToCArrayObjs(arr);
   if(arr.Total() < 1)
      return false;

   if(fileName == NULL || StringLen(fileName) == 0)
     {
      SessionDayNode *first = arr.At(0);
      SessionDayNode *last = arr.At(arr.Total() -1);
      fileName = StringFormat(
                    "sessionTrade_%s_to_%s.txt",
                    TimeToString(first.dt, TIME_DATE),
                    TimeToString(last.dt, TIME_DATE)
                 );
     }

   int fileHandle = FileOpen(fileName, FILE_WRITE | FILE_TXT | FILE_COMMON);
   return this.SaveCommonMethod(fileHandle, fileName, arr);
  }

//+------------------------------------------------------------------+
bool              SessionTradeTree::SaveCSV(string fileName = NULL)
  {
   if(!StringFind(fileName, ".csv", -1))
     {
      Alert("Extension file invalid");
      return false;
     }

   CArrayObj arr;
   this.ToCArrayObjs(arr);
   if(arr.Total() < 1)
      return false;

   if(fileName == NULL || StringLen(fileName) == 0)
     {
      SessionDayNode *first = arr.At(0);
      SessionDayNode *last = arr.At(arr.Total() -1);
      fileName = StringFormat(
                    "sessionTrade_%s_to_%s.csv",
                    TimeToString(first.dt, TIME_DATE),
                    TimeToString(last.dt, TIME_DATE)
                 );
     }

   int fileHandle = FileOpen(fileName, FILE_WRITE | FILE_CSV | FILE_COMMON);
   return this.SaveCommonMethod(fileHandle, fileName, arr);
  }

/*
    ____            _            _           _
   |  _ \ _ __ ___ | |_ ___  ___| |_ ___  __| |
   | |_) | '__/ _ \| __/ _ \/ __| __/ _ \/ _` |
   |  __/| | | (_) | ||  __/ (__| ||  __/ (_| |
   |_|  _|_|  \___/ \__\___|\___|\__\___|\__,_|
   |  \/  | ___| |_| |__   ___   __| |___
   | |\/| |/ _ \ __| '_ \ / _ \ / _` / __|
   | |  | |  __/ |_| | | | (_) | (_| \__ \
   |_|  |_|\___|\__|_| |_|\___/ \__,_|___/

*/

/*
    _  _         _
   | \| |___  __| |___ ___
   | .` / _ \/ _` / -_|_-<
   |_|\_\___/\__,_\___/__/
*/
//+------------------------------------------------------------------+
SessionDayNode*   SessionTradeTree::InsertNode(SessionDayNode* node,
      datetime d,
      datetime s,
      datetime e)
  {
   if(node == NULL)
      return new SessionDayNode(d, s, e);

   if(d < node.dt)
     {
      node.left = this.InsertNode(node.left, d, s, e);
     }
   else
      if(d > node.dt)
        {
         node.right = this.InsertNode(node.right, d, s, e);
        }
      else
        {
         return node;
        }

   this.UpdateHeight(node);
   return this.BalanceNode(node);
  }

/*
     ___     _
    / __|___| |_
   | (_ / -_)  _|
    \___\___|\__|

*/
//+------------------------------------------------------------------+
void              SessionTradeTree::ExtractFirstAndLastTicks(MqlTick &ticks[])
  {
   if(ArraySize(ticks) == 0)
      return;

   MqlDateTime currentDateTime;
   TimeToStruct(ticks[0].time, currentDateTime);
   datetime startTick = ticks[0].time;
   datetime endTick = ticks[0].time;
   int count = 0;

   for(int i = 1; i < ArraySize(ticks); i++)
     {
      MqlDateTime tickDateTime;
      TimeToStruct(ticks[i].time, tickDateTime);

      // Check if the day has changed
      if(tickDateTime.year != currentDateTime.year || tickDateTime.mon != currentDateTime.mon || tickDateTime.day != currentDateTime.day)
        {
         datetime current = StructToTime(currentDateTime);
         this.Insert(this.DateTimeToDate(current), startTick, endTick);

         // Update for the new day
         currentDateTime = tickDateTime;
         startTick = ticks[i].time;
        }
      endTick = ticks[i].time;  // Updates the last tick of the current day
     }

// Saves the last TimeRange if there are ticks on the last day
   if(ArraySize(ticks) > 0)
     {
      datetime current = StructToTime(currentDateTime);
      this.Insert(this.DateTimeToDate(current), startTick, endTick);
     }
  }

/*
    ___ _ _
   | __(_) |___
   | _|| | / -_)
   |_| |_|_\___|

*/
//+------------------------------------------------------------------+
bool              SessionTradeTree::DetectDelimiter(string filename, ushort delimiter)
  {
   int fileHandle = FileOpen(filename, FILE_READ | FILE_TXT | FILE_CSV | FILE_COMMON);
   if(fileHandle == INVALID_HANDLE)
     {
      Alert(StringFormat(
               "Failed to open %s. Err code: %d",
               TerminalInfoString(TERMINAL_COMMONDATA_PATH) + "\\Files\\" + filename,
               GetLastError()
            ));
      return false;
     }
   string firstLine = FileReadString(fileHandle);
   FileClose(fileHandle);

   int commaCount = StringFind(firstLine, ",");
   int semicolonCount = StringFind(firstLine, ";");
   int tabCount = StringFind(firstLine, "\t");

   if(commaCount > semicolonCount && commaCount > tabCount)
     {
      delimiter = 44;
      return true;
     }
   else
      if(semicolonCount > commaCount && semicolonCount > tabCount)
        {
         delimiter = 59;
         return true;
        }
      else
        {
         delimiter = 9;
         return true;
        }
  }

//+------------------------------------------------------------------+
bool              SessionTradeTree::SaveCommonMethod(int fileHandle, string fileName, CArrayObj &arr)
  {
   if(fileHandle == INVALID_HANDLE)
     {
      Alert(StringFormat(
               "Failed to open %s for writing. Err code: %d",
               TerminalInfoString(TERMINAL_COMMONDATA_PATH) + "\\Files\\" + fileName,
               GetLastError()
            ));
      return false;
     }

   PrintFormat("File %s opened for saving data", fileName);

   for(int i = 0; i < arr.Total(); i++)
     {
      SessionDayNode *node = arr.At(i);
      if(node != NULL)
        {
         FileWriteString(
            fileHandle,
            StringFormat(
               "%s,%s,%s\n",
               TimeToString(node.dt, TIME_DATE | TIME_MINUTES | TIME_SECONDS),
               TimeToString(node.start, TIME_DATE | TIME_MINUTES | TIME_SECONDS),
               TimeToString(node.end, TIME_DATE | TIME_MINUTES | TIME_SECONDS)));
        }
     }

   FileClose(fileHandle);
   PrintFormat("Data successfully saved to %s", fileName);
   return            true;
  }

//+------------------------------------------------------------------+
bool              SessionTradeTree::LoadCommonMethod(int fileHandle, string fileName, ushort delimiter)
  {
   if(fileHandle == INVALID_HANDLE)
     {
      Alert(StringFormat(
               "Failed to open %s. Err code: %d",
               TerminalInfoString(TERMINAL_COMMONDATA_PATH) + "\\Files\\" + fileName,
               GetLastError()
            ));
      return false;
     }

   PrintFormat("File %s found", fileName);

   while(!FileIsEnding(fileHandle))
     {
      string line = FileReadString(fileHandle);
      string columns[];
      StringSplit(line, delimiter, columns);

      int columnsNumbers = (int)columns.Size();

      this.Insert(
         columnsNumbers > 0 ? (
            DateTimeStringFormat::IsValidDateTime(columns[0]) ? StringToTime(columns[0]) : StringToTime("0")
         ) : (datetime)0,
         columnsNumbers > 1 ? (
            DateTimeStringFormat::IsValidDateTime(columns[1]) ? StringToTime(columns[1]) : StringToTime("0")
         ) : (datetime)0,
         columnsNumbers > 2 ? (
            DateTimeStringFormat::IsValidDateTime(columns[2]) ? StringToTime(columns[2]) : StringToTime("0")
         ) : (datetime)0
      );
     }

   FileClose(fileHandle);
   return true;
  }
//+------------------------------------------------------------------+
