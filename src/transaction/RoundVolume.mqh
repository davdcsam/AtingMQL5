//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
/**
 * @class RoundVolume
 * @brief Class to round volumes to the nearest step size.
 */
class RoundVolume
  {
public:
   /**
    * @brief Symbol of the asset for which volume is rounded.
    */
   string            symbol;

   /**
    * @brief Default constructor for RoundVolume.
    */
                     RoundVolume() {}

   /**
    * @brief Sets the symbol for volume rounding.
    * @param symbol_arg The symbol to set.
    */
   void              SetSymbol(string& symbol_arg) { symbol = symbol_arg; }

   /**
    * @brief Rounds the given volume to the nearest volume step.
    * @param volume The volume to round.
    * @return The rounded volume.
    */
   double            Run(double volume);
  };

//+------------------------------------------------------------------+
double RoundVolume::Run(double volume)
  {
// Get the volume step for the symbol
   double volume_step = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);

// Return the rounded volume
   return MathRound(volume / volume_step) * volume_step;
  }
//+------------------------------------------------------------------+
