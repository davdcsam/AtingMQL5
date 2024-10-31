//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+
#include "../../filterOperativeDays/daysFilter/DaysFilterTree.mqh"

//+------------------------------------------------------------------+
class SessionTradeTree : public DaysFilterTree
  {
public:
                     SessionTradeTree(void);
                    ~SessionTradeTree(void);

   void              Insert(datetime date,
                            datetime timeStart,
                            datetime timeEnd);

   int               GetFromTicksRange(datetime start,
                                       datetime end);

   bool              LoadCSV(string fileName);
   bool              LoadTXT(string fileName);

   bool              SaveTXT(string fileName = NULL);
   bool              SaveCSV(string fileName = NULL);

protected:

   SessionDayNode*   InsertNode(SessionDayNode* node,
                                datetime d,
                                datetime s,
                                datetime e);

   void              ExtractFirstAndLastTicks(MqlTick &ticks[]);

   bool              DetectDelimiter(string filename, ushort delimiter);

   bool              SaveCommonMethod(int fileHandle, string fileName, CArrayObj &arr);

   bool              LoadCommonMethod(int fileHandle, string fileName, ushort delimiter);
  };
//+------------------------------------------------------------------+
