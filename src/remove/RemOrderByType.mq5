//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+
#include "RemOrderByType.mqh"

//+------------------------------------------------------------------+
RemOrderByType::RemOrderByType(void)
   : Remove(), modeRemoval(MODE_REMOVE_OPPOSITE_TYPE)
  {
  }

//+------------------------------------------------------------------+
RemOrderByType::RemOrderByType(ENUM_MODES mode_arg, IDetectEntity* dOrders, IDetectEntity* dPositions)
   : Remove(dOrders, dPositions), modeRemoval(mode_arg)
  {
  }

//+------------------------------------------------------------------+
void RemOrderByType::UpdateOrders()
  {
   buyTickets.Shutdown();
   sellTickets.Shutdown();

   int orders_total = OrdersTotal();
   if(orders_total == 0)
      return;

// Loop through each order
   for(int i = 0; i < orders_total; i++)
     {
      // Get the ticket for the order
      ulong ticket = OrderGetTicket(i);

      // If the order is not valid, skip it
      if(!detectOrders.IsValid(ticket))
         continue;

      // Filter the orders to buys and sells
      switch((int)OrderGetInteger(ORDER_TYPE))
        {
         case ORDER_TYPE_BUY_STOP:
         case ORDER_TYPE_BUY_LIMIT:
            buyTickets.Add(ticket);
            break;
         case ORDER_TYPE_SELL_LIMIT:
         case ORDER_TYPE_SELL_STOP:
            sellTickets.Add(ticket);
            break;
        }

      // Set the internal flags
      internalFlagBuy = true;
      internalFlagSell = true;
     }
  }

//+------------------------------------------------------------------+
void RemOrderByType::ProcessOrder(ulong &ticket)
  {
   if(sellTickets.SearchLinear(ticket) != -1)
     {
      if(modeRemoval == MODE_REMOVE_SAME_TYPE)
        {
         HandleOrder(ticket, "sellTickets", sellTickets, buyTickets);
         internalFlagSell = false;
         return;
        }

      HandleOrder(ticket, "buyTickets", sellTickets, buyTickets);
      internalFlagSell = false;
     }

   if(buyTickets.SearchLinear(ticket) != -1)
     {
      if(modeRemoval == MODE_REMOVE_SAME_TYPE)
        {
         HandleOrder(ticket, "buyTickets", buyTickets, sellTickets);
         internalFlagBuy = false;
         return;
        }

      HandleOrder(ticket, "sellTickets", buyTickets, sellTickets);
      internalFlagBuy = false;
     }
  }

//+------------------------------------------------------------------+
void RemOrderByType::HandleOrder(ulong ticket, string orderType, CArrayLong &primaryTickets, CArrayLong &secondaryTickets)
  {
   UpdateOrders();

   for(int i=0;i<primaryTickets.Total();i++)
     {
     }

   if(!this.RemoveOrdersFromArray(modeRemoval == MODE_REMOVE_SAME_TYPE ? primaryTickets : secondaryTickets))
     {
      PrintFormat("Failed removing orders in %s. Err: %d", orderType, GetLastError());
      return;
     }

   PrintFormat("Removed orders in %s.", orderType);
  }

//+------------------------------------------------------------------+
void RemOrderByType::TriggerPositionNotInArray()
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

      ProcessOrder(ticket);
     }
  }

//+------------------------------------------------------------------+
void RemOrderByType::Run(ENUM_POSITION_TYPE type)
  {
   this.UpdateOrders();

   if(this.RemoveOrdersFromArray(type == POSITION_TYPE_BUY ? buyTickets : sellTickets))
      PrintFormat("Removing orders type %s", EnumToString(type));
  }
//+------------------------------------------------------------------+
