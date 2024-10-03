//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+
#include "RemPositionByType.mqh"

//+------------------------------------------------------------------+
RemPositionByType::RemPositionByType(IDetectEntity* dOrders, IDetectEntity* dPositions, ENUM_MODES mode_arg = MODE_REMOVE_SAME_TYPE)
   : Remove(dOrders, dPositions), mode(mode_arg)
  {
  }

//+------------------------------------------------------------------+
void RemPositionByType::UpdatePositions()
  {
   buyTickets.Shutdown();
   sellTickets.Shutdown();

   int positions_total = PositionsTotal();
   if(positions_total == 0)
      return;

// Loop through each position
   for(int i = 0; i < positions_total; i++)
     {
      // Get the ticket for the position
      ulong ticket = PositionGetTicket(i);

      // If the position is not valid, skip it
      if(!detectPositions.IsValid(ticket))
         continue;

      // Filter the positions to buys and sells
      switch((int)PositionGetInteger(POSITION_TYPE))
        {
         case POSITION_TYPE_BUY:
            buyTickets.Add(ticket);
            break;
         case POSITION_TYPE_SELL:
            sellTickets.Add(ticket);
            break;
        }

      // Set the internal flags
      internalFlagBuy = true;
      internalFlagSell = true;
     }
  }

//+------------------------------------------------------------------+
void RemPositionByType::ProcessPosition(ulong &ticket)
  {
   if(sellTickets.SearchLinear(ticket) != -1)
     {
      if(mode == MODE_REMOVE_SAME_TYPE)
        {
         HandlerPosition(ticket, "sellTickets", sellTickets, buyTickets);
         internalFlagSell = false;
         return;
        }

      HandlerPosition(ticket, "buyTickets", sellTickets, buyTickets);
      internalFlagSell = false;
     }

   if(buyTickets.SearchLinear(ticket) != -1)
     {
      if(mode == MODE_REMOVE_SAME_TYPE)
        {
         HandlerPosition(ticket, "buyTickets", buyTickets, sellTickets);
         internalFlagBuy = false;
         return;
        }

      HandlerPosition(ticket, "sellTickets", buyTickets, sellTickets);
      internalFlagBuy = false;
     }
  }

//+------------------------------------------------------------------+
void RemPositionByType::HandlerPosition(ulong ticket, string positionType, CArrayLong &primaryTickets, CArrayLong &secondaryTickets)
  {
   UpdatePositions();

   if(!this.RemovePositionsFromArray(mode == MODE_REMOVE_SAME_TYPE ? primaryTickets : secondaryTickets))
     {
      PrintFormat("Failed removing positions in %s. Err: %d", positionType, GetLastError());
      return;
     }

   PrintFormat("Removed positions in %s.", positionType);
  }

//+------------------------------------------------------------------+
void RemPositionByType::TriggerPositionNotInArray()
  {
// If neither internal flag is set, return
   if(!internalFlagBuy && !internalFlagSell)
      return;

   int positions_total = PositionsTotal();
   if(positions_total == 0)
      return;

// Loop through each position
   for(int i = 0; i < positions_total; i++)
     {
      ulong ticket = PositionGetTicket(i);

      // If the position is not valid, skip it
      if(!detectPositions.IsValid(ticket))
         continue;

      ProcessPosition(ticket);
     }
  }

//+------------------------------------------------------------------+
void RemPositionByType::Run(ENUM_POSITION_TYPE type)
  {
   UpdatePositions();

   if(this.RemovePositionsFromArray(type == POSITION_TYPE_BUY ? buyTickets : sellTickets))
      PrintFormat("Removing position type %s", EnumToString(type));
  }
//+------------------------------------------------------------------+
