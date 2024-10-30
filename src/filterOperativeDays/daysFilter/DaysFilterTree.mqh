//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+
#include <Arrays/ArrayObj.mqh>
#include "DaysFilterNode.mqh"
#include "../DateTimeStringFormat.mqh"

//+------------------------------------------------------------------+
class DaysFilterTree
  {

public:
                     DaysFilterTree(void);
                    ~DaysFilterTree(void);

   void              Insert(datetime date);
   void              Delete(datetime date);
   bool              Exist(datetime date);
   bool              Find(datetime date, DaysFilterNode* nodeReturned);

   void              FilterByRangeTime(datetime start, datetime end, DaysFilterTree& saveIn);

   bool              ToCArrayObjs(CArrayObj &array);

   bool              IsBalanced(void);

   void              Clear(void);

   bool              LoadCSV(string fileName);
   bool              LoadTXT(string fileName);
protected:
   DaysFilterNode    *root;

   void              UpdateHeight(DaysFilterNode *node);

   int               GetBalanceFactor(DaysFilterNode *node);

   DaysFilterNode*   RightRotate(DaysFilterNode *y);
   DaysFilterNode*   LeftRotate(DaysFilterNode *x);

   DaysFilterNode*   BalanceNode(DaysFilterNode *node);
   bool              IsBalanced(DaysFilterNode *node);

   DaysFilterNode*   InsertNode(DaysFilterNode *node,
                                datetime d);
   DaysFilterNode*   FindMin(DaysFilterNode *node);
   DaysFilterNode*   DeleteNode(DaysFilterNode *node,
                                datetime d);
   bool              ExistNode(DaysFilterNode *node,
                               datetime d);
   DaysFilterNode*   FindNode(DaysFilterNode *node,
                              datetime d);
   void              ClearNode(DaysFilterNode *node);

   datetime          DateTimeToDate(datetime &dt);
   void              InsertInRange(DaysFilterNode *node,
                                   datetime start,
                                   datetime end,
                                   DaysFilterTree &tree);
   void              AddToCArrayObj(DaysFilterNode *node,
                                    CArrayObj &array);
  };
//+------------------------------------------------------------------+
