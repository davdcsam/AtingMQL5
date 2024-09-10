//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+
#include "Remove.mqh"

//+------------------------------------------------------------------+
Remove::Remove(IDetectEntity* dOrders, IDetectEntity* dPositions)
   : detectOrders(dOrders), detectPositions(dPositions) {}

//+------------------------------------------------------------------+
void Remove::UpdateSetting(string sym, ulong magic)
  {
   this.setting.identifierString = sym;
   this.setting.identifierLong = magic;
   this.detectOrders.UpdateEntities();
   this.detectPositions.UpdateEntities();
  }

//+------------------------------------------------------------------+
Remove::Setting Remove::GetSetting() const
  {
   return this.setting;
  }

//+------------------------------------------------------------------+
bool Remove::CheckSetting() const
  {
   return (
             !ZeroProcessor::Run(this.setting.identifierLong, true) &&
             SystemRequirements::SymbolCommon(this.setting.identifierString)
          );
  }

//+------------------------------------------------------------------+
bool Remove::RemovePendingOrders()
  {
   if(!this.detectOrders.UpdateEntities())
      return false;
   CArrayLong entities = this.detectOrders.GetEntities();
   return RemoveOrdersFromArray(entities);
  }

//+------------------------------------------------------------------+
bool Remove::RemovePositions()
  {
   if(!this.detectPositions.UpdateEntities())
      return false;
   CArrayLong entities = this.detectPositions.GetEntities();
   return RemovePositionsFromArray(entities);
  }

//+------------------------------------------------------------------+
bool Remove::RemoveOrdersFromArray(CArrayLong& tickets)
  {
   bool result = true;
   for(int i = 0; i < tickets.Total(); i++)
     {
      ulong ticket = tickets.At(i);
      if(!this.trade.OrderDelete(ticket))
        {
         result = false;
        }
     }
   return result;
  }

//+------------------------------------------------------------------+
bool Remove::RemovePositionsFromArray(CArrayLong& tickets)
  {
   bool result = true;
   for(int i = 0; i < tickets.Total(); i++)
     {
      ulong ticket = tickets.At(i);
      if(!this.trade.PositionClose(ticket))
        {
         result = false;
        }
     }
   return result;
  }
//+------------------------------------------------------------------+
