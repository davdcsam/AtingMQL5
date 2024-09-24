//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+
#include "Request.mqh"

//+------------------------------------------------------------------+
void Request::Request(RoundVolume* rV, CalcStop* cS)
  {
   roundVolume = rV;
   calcStop = cS;
  }

//+------------------------------------------------------------------+
void Request::UpdateSetting(string sym, double lot, uint tp, uint sl, uint dev, ulong magic)
  {
   this.setting.symbol = sym;
   this.setting.lotSize = lot;
   this.setting.magicNumber = magic;
   this.setting.takeProfit = tp;
   this.setting.stopLoss = sl;
   this.setting.deviationTrade = dev;

   this.roundVolume.SetSymbol(this.setting.symbol);
   this.calcStop.SetSymbol(this.setting.symbol);
  }

//+------------------------------------------------------------------+
void Request::GetSetting(Request::Setting& s)
  { s = this.setting; }

//+------------------------------------------------------------------+
Request::Setting Request::GetSetting(void) const
  { return this.setting; }

//+------------------------------------------------------------------+
bool Request::CheckSetting(void) const
  {
   return (
             !ZeroProcessor::Run(this.setting.lotSize, true)&&
             !NegativeProcessor::IsNegative(this.setting.magicNumber, true) &&
             !NegativeProcessor::IsNegative(this.setting.takeProfit, true) &&
             !NegativeProcessor::IsNegative(this.setting.stopLoss, true) &&
             !NegativeProcessor::IsNegative(this.setting.deviationTrade, true) &&
             SystemRequirements::SymbolCommon(this.setting.symbol)
          );
  }

//+------------------------------------------------------------------+
void Request::BuildCheckPosition(MqlTradeRequest& request, ENUM_POSITION_TYPE type, ENUM_ORDER_TYPE_FILLING filling)
  {
   ZeroMemory(request);

   request.action = TRADE_ACTION_DEAL;
   request.symbol = this.setting.symbol;
   request.type = ENUM_ORDER_TYPE(type);
   request.volume = SymbolInfoDouble(this.setting.symbol, SYMBOL_VOLUME_MIN);
   request.deviation = SymbolInfoInteger(this.setting.symbol, SYMBOL_SPREAD) * 2;
   request.magic = this.setting.magicNumber;
   request.type_filling = filling;
   request.price = (type == POSITION_TYPE_BUY) ? SymbolInfoDouble(this.setting.symbol, SYMBOL_ASK) : SymbolInfoDouble(this.setting.symbol, SYMBOL_BID);
   if(request.deviation != 0)
     {
      request.tp = calcStop.Run(request.price, request.deviation, type, CalcStop::TAKE_PROFIT);
      request.sl = calcStop.Run(request.price, request.deviation, type, CalcStop::STOP_LOSS);
     }
  }

//+------------------------------------------------------------------+
void Request::BuildPosition(MqlTradeRequest& request, ENUM_POSITION_TYPE type, ENUM_ORDER_TYPE_FILLING filling)
  {
   ZeroMemory(request);

   request.action = TRADE_ACTION_DEAL;
   request.symbol = this.setting.symbol;
   request.type = ENUM_ORDER_TYPE(type);
   request.volume = roundVolume.Run(this.setting.lotSize);
   request.deviation = this.setting.deviationTrade;
   request.magic = this.setting.magicNumber;
   request.type_filling = filling;
   request.price = (type == POSITION_TYPE_BUY) ? SymbolInfoDouble(this.setting.symbol, SYMBOL_ASK) : SymbolInfoDouble(this.setting.symbol, SYMBOL_BID);
   if(this.setting.takeProfit != 0)
      request.tp = calcStop.Run(request.price, this.setting.takeProfit, type, CalcStop::TAKE_PROFIT);
   if(this.setting.stopLoss != 0)
      request.sl = calcStop.Run(request.price, this.setting.stopLoss, type, CalcStop::STOP_LOSS);
  }

//+------------------------------------------------------------------+
void Request::BuildPending(MqlTradeRequest& request, ENUM_ORDER_TYPE_BASE type, ENUM_ORDER_TYPE_FILLING filling, double price, datetime expiration = 0)
  {
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   /*
   If price filled order
   */
   if(
      (type == ENUM_ORDER_TYPE_BASE::ORDER_TYPE_BUY && price == ask)
      ||
      (type == ENUM_ORDER_TYPE_BASE::ORDER_TYPE_SELL && price == bid)
   )
     {
      BuildPosition(request, ENUM_POSITION_TYPE(type), filling);
      return;
     }

   ZeroMemory(request);
   request.action = TRADE_ACTION_PENDING;
   request.symbol = this.setting.symbol;
   switch(type)
     {
      case ORDER_TYPE_BUY:
         request.type = ask > price ?
                        ENUM_ORDER_TYPE::ORDER_TYPE_BUY_LIMIT :
                        ENUM_ORDER_TYPE::ORDER_TYPE_BUY_STOP;
         break;
      case ORDER_TYPE_SELL:
         request.type = bid > price ?
                        ENUM_ORDER_TYPE::ORDER_TYPE_SELL_STOP :
                        ENUM_ORDER_TYPE::ORDER_TYPE_SELL_LIMIT;
         break;
     }
   request.volume = roundVolume.Run(this.setting.lotSize);
   request.deviation = this.setting.deviationTrade;
   request.magic = this.setting.magicNumber;
   request.type_filling = filling;
   request.price = price;
   if(expiration != 0 && TimeTradeServer() < expiration)
     {
      request.type_time = ORDER_TIME_SPECIFIED;
      request.expiration = expiration;
     }
   if(this.setting.takeProfit != 0)
      request.tp = calcStop.Run(request.price, this.setting.takeProfit, (ENUM_POSITION_TYPE)type, CalcStop::TAKE_PROFIT);
   if(this.setting.stopLoss != 0)
      request.sl = calcStop.Run(request.price, this.setting.stopLoss, (ENUM_POSITION_TYPE)type, CalcStop::STOP_LOSS);
  }

//+------------------------------------------------------------------+
void Request::BuildPendingOrPosition(MqlTradeRequest& request, ENUM_ORDER_TYPE_AVAILABLE type, ENUM_ORDER_TYPE_FILLING filling, double price, datetime expiration = 0)
  {
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   /*
   Current price passed type on any order type
   It seems illogical as all the following statements should be false,
   but in a higher delay could cause param type was assign an incorrect type.
   */
   if(
      (type == ENUM_ORDER_TYPE_AVAILABLE::ORDER_TYPE_SELL_LIMIT && bid >= price)
      ||
      (type == ENUM_ORDER_TYPE_AVAILABLE::ORDER_TYPE_BUY_STOP && ask >= price)
      ||
      (type == ENUM_ORDER_TYPE_AVAILABLE::ORDER_TYPE_BUY_LIMIT && ask <= price)
      ||
      (type == ENUM_ORDER_TYPE_AVAILABLE::ORDER_TYPE_SELL_STOP && bid <= price)
   )
     {
      BuildPosition(request, (type == ENUM_ORDER_TYPE_AVAILABLE::ORDER_TYPE_BUY_LIMIT || type == ENUM_ORDER_TYPE_AVAILABLE::ORDER_TYPE_BUY_STOP ? POSITION_TYPE_BUY : POSITION_TYPE_SELL), filling);
      return;
     }

   ZeroMemory(request);
   request.action = TRADE_ACTION_PENDING;
   request.symbol = this.setting.symbol;
   request.type = (ENUM_ORDER_TYPE)type;
   request.volume = roundVolume.Run(this.setting.lotSize);
   request.deviation = this.setting.deviationTrade;
   request.magic = this.setting.magicNumber;
   request.type_filling = filling;
   request.price = price;
   if(expiration != 0 && TimeTradeServer() < expiration)
     {
      request.type_time = ORDER_TIME_SPECIFIED;
      request.expiration = expiration;
     }
   if(this.setting.takeProfit != 0)
      request.tp = calcStop.Run(
                      request.price,
                      this.setting.takeProfit,
                      (type == ENUM_ORDER_TYPE_AVAILABLE::ORDER_TYPE_BUY_LIMIT || type == ENUM_ORDER_TYPE_AVAILABLE::ORDER_TYPE_BUY_STOP ? POSITION_TYPE_BUY : POSITION_TYPE_SELL),
                      CalcStop::TAKE_PROFIT
                   );
   if(this.setting.stopLoss != 0)
      request.sl = calcStop.Run(
                      request.price,
                      this.setting.stopLoss,
                      (type == ENUM_ORDER_TYPE_AVAILABLE::ORDER_TYPE_BUY_LIMIT || type == ENUM_ORDER_TYPE_AVAILABLE::ORDER_TYPE_BUY_STOP ? POSITION_TYPE_BUY : POSITION_TYPE_SELL),
                      CalcStop::STOP_LOSS
                   );
  }
//+------------------------------------------------------------------+
