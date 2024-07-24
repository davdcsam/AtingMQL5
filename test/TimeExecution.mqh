//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
/**
 * @class TestTime
 * @brief Class for measuring and printing the execution time of code.
 *
 * This class provides methods to start and end time measurements and print
 * the elapsed time. It is useful for profiling and debugging performance
 * in backtests.
 *
 * @callgraph
 * @callergraph
 */
class TestTime
  {
public:
   /**
    * @brief Start time of the measurement.
    */
   uint              start;

   /**
    * @brief End time of the measurement.
    */
   uint              end;

   /**
    * @brief Default constructor for TestTime.
    */
                     TestTime(void) {};

   /**
    * @brief Starts the time measurement.
    */
   void              Start();

   /**
    * @brief Ends the time measurement and prints the elapsed time.
    */
   void              End();

   /**
    * @brief Default destructor for TestTime.
    */
                    ~TestTime(void) {};
  };

//+------------------------------------------------------------------+
void TestTime::Start()
  {
   start = GetTickCount();
  }

//+------------------------------------------------------------------+
void TestTime::End()
  {
   end = GetTickCount() - start;
   PrintFormat(
      "\nCalculating backtest took %d ms or %s\n",
      end,
      TimeToString(datetime(end) / 1000, TIME_SECONDS)
   );
  }

//+------------------------------------------------------------------+
