//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+
#include "RemOrderByLocationPrice.mqh"

//+------------------------------------------------------------------+
RemOrderByLocationPrice::RemOrderByLocationPrice(IDetectEntity* dOrders, IDetectEntity* dPositions)
   : Remove(dOrders, dPositions), internalFlag(false) {}

//+------------------------------------------------------------------+
void RemOrderByLocationPrice::UpdateSetting(string sym, ulong magic, double reference)
  {
   this.setting.identifierString = sym;
   this.setting.identifierLong = magic;
   this.referencePrice = reference;
   Remove::UpdateSetting(sym, magic);
  }

//+------------------------------------------------------------------+
double RemOrderByLocationPrice::GetReferencePrice() const
  {
   return this.referencePrice;
  }

//+------------------------------------------------------------------+
bool RemOrderByLocationPrice::CheckSetting() const
  {
   return (
             !ZeroProcessor::Run(this.setting.identifierLong, true) && // Checks if identifierLong is not zero
             !ZeroProcessor::Run(this.referencePrice, true) && // Checks if referencePrice is not zero
             SystemRequirements::SymbolCommon(this.setting.identifierString) // Validates the symbol string
          );
  }

//+------------------------------------------------------------------+
void RemOrderByLocationPrice::UpdateOrders()
  {
   this.upperTickets.Shutdown();
   this.lowerTickets.Shutdown();

// Update the list of orders
   if(!this.detectOrders.UpdateEntities())
      return;

   CArrayLong entities = this.detectOrders.GetEntities();

// Loop through each order
   for(int i = 0; i < entities.Total(); i++)
     {
      ulong ticket = entities.At(i);

      // If unable to select the order, return
      if(!OrderSelect(ticket))
         return;

      // Categorize the order based on its open price relative to the referencePrice
      if(OrderGetDouble(ORDER_PRICE_OPEN) > this.referencePrice)
         this.upperTickets.Add(ticket); // Add to upperTickets if price is above reference
      else
         this.lowerTickets.Add(ticket); // Add to lowerTickets if price is below reference

      this.internalFlag = true;
     }
  }

//+------------------------------------------------------------------+
void RemOrderByLocationPrice::TriggerPositionNotInArray()
  {
   if(!this.internalFlag)
      return;

   if(!this.detectPositions.UpdateEntities())
      return;

   CArrayLong entities = this.detectPositions.GetEntities();

// Loop through each position
   for(int i = 0; i < entities.Total(); i++)
     {
      long ticket = entities.At(i);

      // Check if the position ticket is in the upper or lower order tickets array
      if(this.upperTickets.SearchLinear(ticket) != -1)
        {
         // Remove orders from the lower order tickets
         if(this.RemoveOrdersFromArray(this.lowerTickets))
            PrintFormat("Removed orders in lowerTickets for position ticket: %d", ticket);
         else
            PrintFormat("Failed removing orders in lowerTickets for position ticket: %d. Err: %d", ticket, GetLastError());

         this.internalFlag = false;
        }

      if(this.lowerTickets.SearchLinear(ticket) != -1)
        {
         // Remove orders from the upper order tickets
         if(this.RemoveOrdersFromArray(this.upperTickets))
            PrintFormat("Removed orders in upperTickets for position ticket: %d", ticket);
         else
            PrintFormat("Failed removing orders in upperTickets for position ticket: %d. Err: %d", ticket, GetLastError());

         this.internalFlag = false;
        }
     }
  }
//+------------------------------------------------------------------+
