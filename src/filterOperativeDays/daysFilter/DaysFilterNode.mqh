//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+
#include <Arrays/ArrayObj.mqh>

//+------------------------------------------------------------------+
class DaysFilterNode : public CObject
  {
public:
   datetime          dt;
   int               height;
   DaysFilterNode    *left;
   DaysFilterNode    *right;

                     DaysFilterNode(datetime date);
                    ~DaysFilterNode(void);

   string            ToString(void);
   void              ToString(string &s);
  };

// Constructor
//+------------------------------------------------------------------+
DaysFilterNode::DaysFilterNode(datetime date)
  {
   this.dt = date;
   this.height = 1;
   this.left = this.right = NULL;
  }

//+------------------------------------------------------------------+
DaysFilterNode::~DaysFilterNode(void)
  {
   delete this.left;
   delete this.right;
  }

// To String
//+------------------------------------------------------------------+
string            DaysFilterNode::ToString()
  {
   return StringFormat("Date: %s, Hight: %d", TimeToString(this.dt, TIME_DATE),this.height);
  }

//+------------------------------------------------------------------+
void              DaysFilterNode::ToString(string &s)
  {
   s = this.ToString();
  }
//+------------------------------------------------------------------+
