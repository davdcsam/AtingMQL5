//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+
#include <Generic/HashMap.mqh>

//+------------------------------------------------------------------+
/**
 * @interface BaseTask
 * @brief Base interface for tasks.
 */
interface BaseTask
{
public:
   /**
    * @brief Executes the task.
    */
   virtual void Run() {};
};

//+------------------------------------------------------------------+
/**
 * @class TaskManager
 * @brief Manages and executes a collection of tasks.
 */
class TaskManager
{
private:
   datetime          nextTask; ///< Time for the next scheduled task
   int               arrKeys[]; ///< Array to hold task keys
   BaseTask*         arrValues[]; ///< Array to hold task values

public:
   /**
    * @brief Default constructor for TaskManager.
    */
                     TaskManager(void) {};

   /**
    * @brief A map of tasks where keys are integers and values are task pointers.
    */
   CHashMap<int, BaseTask*> Tasks;

   /**
    * @brief Executes all the tasks currently in the task manager.
    */
   void              RunAllTasks(void);
};

//+------------------------------------------------------------------+
void TaskManager::RunAllTasks(void)
{
   Tasks.CopyTo(arrKeys, arrValues, 0);

   for(int i = 0; i < ArraySize(arrValues); i++)
   {
      arrValues[i].Run();
   }
}
//+------------------------------------------------------------------+
