//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+
#include <Generic/HashMap.mqh>

interface BaseTask
  {
public:
   virtual void      Run() {};

  };

//+------------------------------------------------------------------+
//| TaskManager                                                      |
//+------------------------------------------------------------------+
class TaskManager
  {
private:
   datetime          nextTask;
   int arrKeys[];
   BaseTask*         arrValues[];

public:
                     TaskManager(void) {};

   CHashMap<int, BaseTask*> Tasks;

   void              RunAllTasks(void)
     {
      Tasks.CopyTo(arrKeys, arrValues, 0);

      for(int i=0;i<ArraySize(arrValues);i++)
        {
         arrValues[i].Run();
        }
     }
  };
//+------------------------------------------------------------------+
