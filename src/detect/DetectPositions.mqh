//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+
#include <Arrays/ArrayLong.mqh>

//+------------------------------------------------------------------+
/**
 * @class DetectPositions
 * @brief Class to detect and manage positions.
 */
class DetectPositions
  {
private:
   /**
    * @brief Symbol for the position.
    */
   string            symbol;

   /**
    * @brief Magic number for the position.
    */
   ulong             magic;

public:
   /**
    * @brief Array to store the position tickets.
    */
   CArrayLong        positionsTickets;

   /**
    * @brief Default constructor for the DetectPositions class.
    */
                     DetectPositions(void) {};

   /**
    * @brief Updates the symbol and magic number for the position.
    * @param symbol_arg Symbol for the position.
    * @param magic_arg Magic number for the position.
    */
   void              UpdateAtr(string symbol_arg, ulong magic_arg);

   /**
    * @brief Checks if a position is valid.
    * @param ticket Ticket number of the position.
    * @return True if the position is selected and the magic number and symbol match; otherwise, false.
    */
   bool              IsValidPosition(ulong ticket);

   /**
    * @brief Updates the positions by collecting valid position tickets.
    * @return True if at least one valid position ticket is found; otherwise, false.
    */
   bool              UpdatePositions();
  };

//+------------------------------------------------------------------+
void DetectPositions::UpdateAtr(string symbol_arg, ulong magic_arg)
  {
   symbol = symbol_arg;
   magic = magic_arg;
  }

//+------------------------------------------------------------------+
bool DetectPositions::IsValidPosition(ulong ticket)
  {
   return(
            PositionSelectByTicket(ticket) &&
            PositionGetInteger(POSITION_MAGIC) == magic &&
            PositionGetString(POSITION_SYMBOL) == symbol
         );
  }

//+------------------------------------------------------------------+
bool DetectPositions::UpdatePositions()
  {
// Shutdown the positions tickets array
   positionsTickets.Shutdown();

// Get the total number of positions
   int totalPositions = PositionsTotal();

// If there are no positions, return false
   if(!totalPositions)
      return(false);

// Loop through each position
   for(int i = 0; i < totalPositions; i++)
     {
      // Get the ticket for the position
      ulong ticket = PositionGetTicket(i);

      // If the position is not selected or not valid, continue to the next position
      if(!PositionSelectByTicket(ticket) || !IsValidPosition(ticket))
         continue;

      // Add the ticket to the positions tickets array
      positionsTickets.Add(ticket);
     }

// Return true if at least one valid position ticket is found; otherwise, false
   return(positionsTickets.Total() > 0);
  }
//+------------------------------------------------------------------+
