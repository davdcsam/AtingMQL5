//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+
#include "DaysFilterTree.mqh"

/*
    ____        _     _ _        __  __      _   _               _
   |  _ \ _   _| |__ | (_) ___  |  \/  | ___| |_| |__   ___   __| |___
   | |_) | | | | '_ \| | |/ __| | |\/| |/ _ \ __| '_ \ / _ \ / _` / __|
   |  __/| |_| | |_) | | | (__  | |  | |  __/ |_| | | | (_) | (_| \__ \
   |_|    \__,_|_.__/|_|_|\___| |_|  |_|\___|\__|_| |_|\___/ \__,_|___/

*/
//+------------------------------------------------------------------+
DaysFilterTree::DaysFilterTree()
  {
   this.root = NULL;
  }

//+------------------------------------------------------------------+
DaysFilterTree::~DaysFilterTree()
  {
   delete this.root;
  }

//+------------------------------------------------------------------+
void              DaysFilterTree::Insert(datetime date)
  {
   this.root = this.InsertNode(this.root, this.DateTimeToDate(date));
  }

//+------------------------------------------------------------------+
void              DaysFilterTree::Delete(datetime date)
  {
   this.root = this.DeleteNode(this.root, this.DateTimeToDate(date));
  }

//+------------------------------------------------------------------+
bool              DaysFilterTree::Exist(datetime date)
  {
   return this.ExistNode(this.root, this.DateTimeToDate(date));
  }

//+------------------------------------------------------------------+
bool              DaysFilterTree::Find(datetime date, DaysFilterNode* nodeReturned)
  {
   nodeReturned = this.FindNode(this.root, this.DateTimeToDate(date));
   return nodeReturned != NULL;
  }

//+------------------------------------------------------------------+
void              DaysFilterTree::FilterByRangeTime(datetime start, datetime end, DaysFilterTree& saveIn)
  {
   this.InsertInRange(this.root, start, end, saveIn);
  }

//+------------------------------------------------------------------+
bool              DaysFilterTree::ToCArrayObjs(CArrayObj &array)
  {
   this.AddToCArrayObj(this.root, array);
   return array.Total() > 0;
  }

//+------------------------------------------------------------------+
bool              DaysFilterTree::IsBalanced(void)
  {
   return this.IsBalanced(this.root);
  }

//+------------------------------------------------------------------+
void DaysFilterTree::Clear(void)
  {
   this.ClearNode(this.root);
   this.root = NULL;
  }

//+------------------------------------------------------------------+
bool DaysFilterTree::LoadCSV(string fileName)
  {
   if(!StringFind(fileName, ".csv", -1))
     {
      Alert("Extension file invalid");
      return false;
     }

   int fileHandle = FileOpen(fileName, FILE_ANSI | FILE_READ | FILE_CSV | FILE_COMMON, "\t");
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
      string dt = FileReadString(fileHandle);
      if(DateTimeStringFormat::IsValidDateTime(dt))
         this.Insert(StringToTime(dt));
     }

   FileClose(fileHandle);
   return true;
  }

//+------------------------------------------------------------------+
bool DaysFilterTree::LoadTXT(string fileName)
  {
   if(!StringFind(fileName, ".txt", -1))
     {
      Alert("Extension file invalid");
      return false;
     }

   int fileHandle = FileOpen(fileName, FILE_ANSI | FILE_READ | FILE_TXT | FILE_COMMON, "\t");
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
      string dt = FileReadString(fileHandle);
      if(DateTimeStringFormat::IsValidDateTime(dt))
         this.Insert(StringToTime(dt));
     }

   FileClose(fileHandle);
   return true;
  }


/*
    ____       _            _         __  __      _   _               _
   |  _ \ _ __(_)_   ____ _| |_ ___  |  \/  | ___| |_| |__   ___   __| |___
   | |_) | '__| \ \ / / _` | __/ _ \ | |\/| |/ _ \ __| '_ \ / _ \ / _` / __|
   |  __/| |  | |\ V / (_| | ||  __/ | |  | |  __/ |_| | | | (_) | (_| \__ \
   |_|   |_|  |_| \_/ \__,_|\__\___| |_|  |_|\___|\__|_| |_|\___/ \__,_|___/

*/


/*
      ___   ___      _  _     _
     /_\ \ / / |    | || |___| |_ __  ___ _ _
    / _ \ V /| |__  | __ / -_) | '_ \/ -_) '_|
   /_/ \_\_/ |____| |_||_\___|_| .__/\___|_|
                               |_|
*/
//+------------------------------------------------------------------+
void              DaysFilterTree::UpdateHeight(DaysFilterNode *node)
  {
   if(node != NULL)
     {
      int leftHeight = (node.left != NULL) ? node.left.height : 0;
      int rightHeight = (node.right != NULL) ? node.right.height : 0;
      node.height = MathMax(leftHeight, rightHeight) + 1;
     }
  }

//+------------------------------------------------------------------+
int               DaysFilterTree::GetBalanceFactor(DaysFilterNode *node)
  {
   if(node == NULL)
      return 0;
   return (node.left != NULL ? node.left.height : 0) - (node.right != NULL ? node.right.height : 0);
  }

//+------------------------------------------------------------------+
DaysFilterNode*   DaysFilterTree::RightRotate(DaysFilterNode *y)
  {
   DaysFilterNode *x = y.left;
   DaysFilterNode *T2 = x.right;
   x.right = y;
   y.left = T2;
   this.UpdateHeight(y);
   this.UpdateHeight(x);
   return x;
  }

//+------------------------------------------------------------------+
DaysFilterNode*   DaysFilterTree::LeftRotate(DaysFilterNode *x)
  {
   DaysFilterNode *y = x.right;
   DaysFilterNode *T2 = y.left;
   y.left = x;
   x.right = T2;
   this.UpdateHeight(x);
   this.UpdateHeight(y);
   return y;
  }

//+------------------------------------------------------------------+
DaysFilterNode*   DaysFilterTree::BalanceNode(DaysFilterNode *node)
  {
   int balance = this.GetBalanceFactor(node);

   if(balance > 1)
     {
      if(this.GetBalanceFactor(node.left) < 0)
        {
         node.left = this.LeftRotate(node.left);
        }
      return this.RightRotate(node);
     }

   if(balance < -1)
     {
      if(this.GetBalanceFactor(node.right) > 0)
        {
         node.right = this.RightRotate(node.right);
        }
      return this.LeftRotate(node);
     }

   return node;
  }

//+------------------------------------------------------------------+
bool              DaysFilterTree::IsBalanced(DaysFilterNode *node)
  {
   if(node == NULL)
      return true;

   int leftHeight = (node.left != NULL) ? node.left.height : 0;
   int rightHeight = (node.right != NULL) ? node.right.height : 0;

   if(MathAbs(leftHeight - rightHeight) > 1)
      return false;
   return this.IsBalanced(node.left) && this.IsBalanced(node.right);
  }

/*
    _  _         _
   | \| |___  __| |___ ___
   | .` / _ \/ _` / -_|_-<
   |_|\_\___/\__,_\___/__/
*/
//+------------------------------------------------------------------+
DaysFilterNode*   DaysFilterTree::InsertNode(DaysFilterNode *node, datetime d)
  {
   if(node == NULL)
      return new DaysFilterNode(d);

   if(d < node.dt)
     {
      node.left = this.InsertNode(node.left, d);
     }
   else
      if(d > node.dt)
        {
         node.right = this.InsertNode(node.right, d);
        }
      else
        {
         return node;
        }

   this.UpdateHeight(node);
   return this.BalanceNode(node);
  }

//+------------------------------------------------------------------+
DaysFilterNode*   DaysFilterTree::FindMin(DaysFilterNode *node)
  {
   if(node == NULL || node.left == NULL)
      return node;
   return this.FindMin(node.left);
  }

//+------------------------------------------------------------------+
DaysFilterNode*   DaysFilterTree::DeleteNode(DaysFilterNode *node, datetime d)
  {
   if(node == NULL)
      return node;

   if(d < node.dt)
     {
      node.left = this.DeleteNode(node.left, d);
     }
   else
      if(d > node.dt)
        {
         node.right = this.DeleteNode(node.right, d);
        }
      else
        {
         if((node.left == NULL) || (node.right == NULL))
           {
            DaysFilterNode *temp = (node.left) ? node.left : node.right;
            if(temp == NULL)
              {
               temp = node;
               node = NULL;
              }
            else
              {
               *node = *temp;
              }
            delete temp;
           }
         else
           {
            DaysFilterNode *temp = this.FindMin(node.right);
            node.dt = temp.dt;
            node.right = this.DeleteNode(node.right, temp.dt);
           }
        }

   if(node == NULL)
      return node;

   this.UpdateHeight(node);
   return this.BalanceNode(node);
  }

//+------------------------------------------------------------------+
bool              DaysFilterTree::ExistNode(DaysFilterNode *node, datetime d)
  {
   if(node == NULL)
      return false;

   if(d < node.dt)
     {
      return this.ExistNode(node.left, d);
     }
   else
      if(d > node.dt)
        {
         return this.ExistNode(node.right, d);
        }
      else
        {
         return true;
        }
  }

//+------------------------------------------------------------------+
DaysFilterNode*   DaysFilterTree::FindNode(DaysFilterNode *node, datetime d)
  {
   if(node == NULL)
      return NULL;

   if(d < node.dt)
     {
      return this.FindNode(node.left, d);
     }
   else
      if(d > node.dt)
        {
         return this.FindNode(node.right, d);
        }
      else
        {
         return node;
        }
  }

//+------------------------------------------------------------------+
datetime          DaysFilterTree::DateTimeToDate(datetime &dt)
  {
   MqlDateTime mdt;
   TimeToStruct(dt, mdt);
   mdt.hour = 0;
   mdt.min = 0;
   mdt.sec = 0;
   return StructToTime(mdt);
  }

//+------------------------------------------------------------------+
void DaysFilterTree::ClearNode(DaysFilterNode *node)
  {
   if(node == NULL)
      return;

   this.ClearNode(node.left);
   this.ClearNode(node.right);

   delete node;
  }

/*
    ___ _ _ _
   | __(_) | |_ ___ _ _
   | _|| | |  _/ -_) '_|
   |_| |_|_|\__\___|_|

*/
//+------------------------------------------------------------------+
void              DaysFilterTree::InsertInRange(DaysFilterNode *node, datetime start, datetime end, DaysFilterTree &tree)
  {
   if(node == NULL)
      return;

   if(node.dt >= start && node.dt <= end)
     {
      tree.Insert(node.dt);
     }

   if(node.dt > start)
     {
      this.InsertInRange(node.left, start, end, tree);
     }
   if(node.dt < end)
     {
      this.InsertInRange(node.right, start, end, tree);
     }
  }

/*
  ___   _                      ___  _     _       _  _     _
 / __| /_\  _ _ _ _ __ _ _  _ / _ \| |__ (_)___  | || |___| |_ __  ___ _ _
| (__ / _ \| '_| '_/ _` | || | (_) | '_ \| (_-<  | __ / -_) | '_ \/ -_) '_|
 \___/_/ \_\_| |_| \__,_|\_, |\___/|_.__// /__/  |_||_\___|_| .__/\___|_|
                         |__/          |__/                 |_|
*/
//+------------------------------------------------------------------+
void              DaysFilterTree::AddToCArrayObj(DaysFilterNode *node, CArrayObj &array)
  {
   if(node == NULL)
      return;
   array.Add(node);
   this.AddToCArrayObj((node.left != NULL) ? node.left : NULL, array);
   this.AddToCArrayObj((node.right != NULL) ? node.right : NULL, array);
  }
//+------------------------------------------------------------------+
