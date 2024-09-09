//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+
#include <Arrays/ArrayLong.mqh>
#include "../CheckCommonSetting.mqh"
#include "../SystemRequirements.mqh"

//+------------------------------------------------------------------+
/**
 * @class DetectPositions
 * @brief Class to detect and manage positions.
 */
class DetectPositions
  {
public:
   /**
    * @struct Setting
    * @brief Structure to hold the order's settings such as symbol and magic number.
    */
   struct Setting
     {
      string         symbol; ///< The symbol associated with the order.
      ulong          magic;  ///< The magic number used to identify the order.
     };

private:
   Setting           setting; ///< Current setting containing symbol and magic number.

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
    * @brief Updates the symbol and magic number for the order.
    * @param sym Symbol for the order.
    * @param magic Magic number for the order.
    */
   void              UpdateSetting(string sym, ulong magic);

   /**
    * @brief Returns the current settings (symbol and magic number).
    * @return The current Setting structure.
    */
   Setting           GetSetting(void);

   /**
    * @brief Retrieves the current settings and stores them in the provided parameter.
    * @param param Reference to a Setting object where the current setting will be copied.
    */
   void              GetSetting(Setting &param);

   /**
    * @brief Checks if the current setting (symbol and magic number) meets the necessary conditions.
    * @return True if the setting is valid; otherwise, false.
    */
   bool              CheckSetting(void);

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
void DetectPositions::UpdateSetting(string sym, ulong magic)
  {
   setting.magic = magic;
   setting.symbol = sym;
  }

//+------------------------------------------------------------------+
void DetectPositions::GetSetting(Setting &param)
  { param = setting; }

//+------------------------------------------------------------------+
DetectPositions::Setting DetectPositions::GetSetting(void)
  {  return setting; }

//+------------------------------------------------------------------+
bool DetectPositions::CheckSetting(void)
  {
   if(
      ZeroProcessor::Run(setting.magic) &&
      SystemRequirements::SymbolCommon(setting.symbol)
   )
      return false;
   return true;
  }

//+------------------------------------------------------------------+
bool DetectPositions::IsValidPosition(ulong ticket)
  {
   return(
            PositionSelectByTicket(ticket) &&
            PositionGetInteger(POSITION_MAGIC) == setting.magic &&
            PositionGetString(POSITION_SYMBOL) == setting.symbol
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
