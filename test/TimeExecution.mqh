//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| TestTime                                                         |
//+------------------------------------------------------------------+
class TestTime
  {
public:
   uint              start;
   uint              end;

                     TestTime(void) {};

   void              Start()
     { start =       GetTickCount(); }

   void              End()
     {
      end = GetTickCount() - start;
      PrintFormat(
         "\nCalculating backtest took %d ms or %s\n",
         end,
         TimeToString(datetime(end) / 1000, TIME_SECONDS)
      );
     }

                    ~TestTime(void) {};
  };
//+------------------------------------------------------------------+
