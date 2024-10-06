//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+
#include "ProfitProtection.mqh"

// Constructor
//+------------------------------------------------------------------+
ProfitProtection::ProfitProtection(DetectPositions *dP)
  {
   this.detectPositions = dP;
  }

ProfitProtection::~ProfitProtection(void) {}

// Setting
//+------------------------------------------------------------------+
void ProfitProtection::UpdateSetting(
   double activationPercent,
   double deviationPercent)
  {
   this.setting.activationPercent = activationPercent;
   this.setting.deviationPercent = deviationPercent;
  }

//+------------------------------------------------------------------+
void ProfitProtection::GetSetting(Setting &s)
  {
   s = this.setting;
  }

//+------------------------------------------------------------------+
ProfitProtection::Setting ProfitProtection::GetSetting(void)
  {
   return this.setting;
  }

//+------------------------------------------------------------------+
bool ProfitProtection::CheckSetting(void)
  {
   double arr[2], result[];
   arr[0] = this.setting.activationPercent;
   arr[1] = this.setting.deviationPercent;
   return (
             !ZeroProcessor::Run(arr, result, true) &&
             !NegativeProcessor::Run(arr, result, true));
  }

//+------------------------------------------------------------------+
string ProfitProtection::SettingToString(void)
  {
   return StringFormat(
             "Setting:\n  Activation %.2f\n  Deviation %.2f",
             this.setting.activationPercent,
             this.setting.deviationPercent
          );
  }

// Modifier Methods
//+------------------------------------------------------------------+
bool ProfitProtection::ModifyStopLossFromPositionBuy(ulong ticket, double newStopLoss)
  {
   if(
      !PositionSelectByTicket(ticket) ||
      newStopLoss <= PositionGetDouble(POSITION_SL) ||
      newStopLoss >= PositionGetDouble(POSITION_PRICE_CURRENT))
      return false;

   return trade.PositionModify(ticket, newStopLoss, PositionGetDouble(POSITION_TP));
  }

//+------------------------------------------------------------------+
bool ProfitProtection::ModifyStopLossFromPositionSell(ulong ticket, double newStopLoss)
  {
   if(
      !PositionSelectByTicket(ticket) ||
      newStopLoss >= PositionGetDouble(POSITION_SL) ||
      newStopLoss <= PositionGetDouble(POSITION_PRICE_CURRENT))
      return false;

   return trade.PositionModify(ticket, newStopLoss, PositionGetDouble(POSITION_TP));
  }

// Price
//+------------------------------------------------------------------+
double ProfitProtection::GetActivationPrice(ulong positionTicket)
  {
   if(!PositionSelectByTicket(positionTicket))
      return -1;

   return (PositionGetDouble(POSITION_PRICE_OPEN) + (PositionGetDouble(POSITION_TP) - PositionGetDouble(POSITION_PRICE_OPEN)) * (this.setting.activationPercent / 100));
  }

//+------------------------------------------------------------------+
double ProfitProtection::GetDeviationPriceFromCurrent(ulong positionTicket)
  {
   if(!PositionSelectByTicket(positionTicket))
      return -1;

   return NormalizeDouble(
             PositionGetDouble(POSITION_PRICE_CURRENT) + (PositionGetDouble(POSITION_PRICE_OPEN) - PositionGetDouble(POSITION_TP)) * (this.setting.deviationPercent / 100),
             (int)SymbolInfoInteger(this.detectPositions.GetSetting().identifierString, SYMBOL_DIGITS)
          );
  }

//+------------------------------------------------------------------+
double ProfitProtection::GetDeviationPriceFromOpen(ulong positionTicket)
  {
   if(!PositionSelectByTicket(positionTicket))
      return -1;

   return NormalizeDouble(
             PositionGetDouble(POSITION_PRICE_OPEN) - (PositionGetDouble(POSITION_PRICE_OPEN) - PositionGetDouble(POSITION_TP)) * (this.setting.deviationPercent / 100),
             (int)SymbolInfoInteger(this.detectPositions.GetSetting().identifierString, SYMBOL_DIGITS)
          );
  }
//+------------------------------------------------------------------+
