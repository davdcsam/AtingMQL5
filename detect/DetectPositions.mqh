//+------------------------------------------------------------------+
//|                                                  DetectPositions |
//|                                         Copyright 2024, davdcsam |
//|                                              github.com/davdcsam |
//+------------------------------------------------------------------+
// Include the ArrayLong library from the Arrays directory
#include <Arrays/ArrayLong.mqh>

// Class to detect positions
class DetectPositions
  {
private:
   // Symbol for the position
   string            symbol;

   // Magic number for the position
   ulong             magic;

public:
   // Array to store the position tickets
   CArrayLong        positions_tickets;

   // Default constructor for the DetectPositions class
                     DetectPositions(void) {};

   // Function to update the symbol and magic number for the position
   void              UpdateAtr(string symbol_arg, ulong magic_arg)
     {
      // Set the symbol and magic number for the position
      symbol = symbol_arg;
      magic = magic_arg;
     };

   // Function to check if a position is valid
   bool              IsValidPosition(ulong ticket)
     {
      // Return true if the position is selected and the magic number and symbol match, otherwise return false
      return(
               PositionSelectByTicket(ticket) &&
               PositionGetInteger(POSITION_MAGIC) == magic &&
               PositionGetString(POSITION_SYMBOL) == symbol
            );
     }

   // Function to update the positions
   bool              UpdatePositions()
     {
      // Shutdown the positions tickets array
      positions_tickets.Shutdown();

      // Get the total number of positions
      int total_positions = PositionsTotal();

      // If there are no positions, return false
      if(!total_positions)
         return(false);

      // Loop through each position
      for(int i=0; i<total_positions; i++)
        {
         // Get the ticket for the position
         ulong ticket = PositionGetTicket(i);

         // If the position is not selected, continue to the next position
         if(!PositionSelectByTicket(ticket))
            continue;

         // If the position is not valid, continue to the next position
         if(!IsValidPosition(ticket))
            continue;

         // Add the ticket to the positions tickets array
         positions_tickets.Add(ticket);
        }

      // If there are no positions tickets, return false
      if(!positions_tickets.Total())
         return(false);

      // If there are positions tickets, return true
      return(true);
     }
  };
//+------------------------------------------------------------------+
