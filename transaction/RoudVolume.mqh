//+------------------------------------------------------------------+
//|                                                 AutomatedTrading |
//|                                         Copyright 2024, davdcsam |
//|                                      https://github.com/davdcsam |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| RoundVolume                                                      |
//+------------------------------------------------------------------+
class RoundVolume
  {
public:
   string            symbol;

                     RoundVolume() {}
   void              SetSymbol(string& symbol_arg) {symbol = symbol_arg; }

   // Function to round the volume to the nearest step
   double            Run(double volume)
     {
      // Get the volume step for the symbol
      double volume_step = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);

      // Return the rounded volume
      return MathRound(volume / volume_step) * volume_step;
     }
  };
//+------------------------------------------------------------------+
