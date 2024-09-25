//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+
#include "Transaction.mqh"

//+------------------------------------------------------------------+
string Transaction::failSendingOrder()
  {
   return StringFormat("Fail with order Type %s, Lot %s, Sl %s, Tp %s, Op %s",
                       EnumToString(tradeRequest.type),
                       DoubleToString(tradeRequest.volume, _Digits),
                       DoubleToString(tradeRequest.sl, _Digits),
                       DoubleToString(tradeRequest.tp, _Digits),
                       DoubleToString(tradeRequest.price, _Digits));
  }

//+------------------------------------------------------------------+
void Transaction::Update()
  {
   tickSize = SymbolInfoDouble(this.setting.symbol, SYMBOL_TRADE_TICK_SIZE);
   priceAsk = round(SymbolInfoDouble(this.setting.symbol, SYMBOL_ASK) / tickSize) * tickSize;
   priceBid = round(SymbolInfoDouble(this.setting.symbol, SYMBOL_BID) / tickSize) * tickSize;
  }

//+------------------------------------------------------------------+
Transaction::ENUM_CHECK Transaction::CheckArg()
  {
   bool isCustom;
   if(!SymbolExist(this.setting.symbol, isCustom))
      return ERR_SYMBOL_NOT_AVAILABLE;

   if(SymbolInfoDouble(this.setting.symbol, SYMBOL_VOLUME_MIN) >= this.setting.lotSize && SymbolInfoDouble(this.setting.symbol, SYMBOL_VOLUME_MAX) <= this.setting.lotSize)
      return ERR_INVALID_LOT_SIZE;

   if(this.setting.deviationTrade < this.setting.takeProfit * 0.001 || this.setting.deviationTrade < this.setting.stopLoss * 0.001)
     {
      return ERR_DEVIATION_INSUFFICIENT;
     }

   return CHECK_ARG_TRANSACTION_PASSED;
  }

//+------------------------------------------------------------------+
Transaction::ENUM_FIX_FILLING_MODE Transaction::FixFillingMode()
  {
   ENUM_ORDER_TYPE_FILLING list_type_filling[] = {ORDER_FILLING_FOK, ORDER_FILLING_IOC, ORDER_FILLING_RETURN, ORDER_FILLING_BOC};

   for(int i = 0; i < ArraySize(list_type_filling); i++)
     {
      Update();
      BuildCheckPosition(tradeRequest, POSITION_TYPE_BUY, list_type_filling[i]);

      if(!OrderCheck(tradeRequest, tradeCheckResult) && tradeCheckResult.retcode != TRADE_RETCODE_INVALID_FILL)
        {
         PrintFormat("Error Checking Request: %d %s", GetLastError(), tradeCheckResult.comment);
         return ERR_INVALID_REQUEST;
        }

      if(tradeCheckResult.retcode == 0)
        {
         typeFillingMode = tradeRequest.type_filling;
         return FILLING_MODE_FOUND;
        }
     }

   return ERR_FILLING_MODE_NO_FOUND;
  }

//+------------------------------------------------------------------+
Transaction::ENUM_ORDER_TRANSACTION Transaction::SendPosition(ENUM_POSITION_TYPE type)
  {
   BuildPosition(tradeRequest, type, typeFillingMode);

   double stops[] = {tradeRequest.sl, tradeRequest.tp, tradeRequest.price};

   if(!calcStop.VerifyNoNegative(stops) || !OrderSendAsync(tradeRequest, tradeResult))
     {
      Print(failSendingOrder());
      return ERR_SEND_FAILED;
     }
   return POSITION_EXECUTED_SUCCESSFULLY;
  }

//+------------------------------------------------------------------+
Transaction::ENUM_ORDER_TRANSACTION Transaction::SendPendingDefault(double price, ENUM_ORDER_TYPE_BASE type, datetime expiration = 0)
  {
   BuildPending(tradeRequest, type, typeFillingMode, price, expiration);

   double stops[] = {tradeRequest.sl, tradeRequest.tp, tradeRequest.price};

   if(calcStop.VerifyNoNegative(stops) && OrderSend(tradeRequest, tradeResult) && OrderSelect(tradeResult.order))
     {
      Print(OrderGetInteger(ORDER_TICKET));
      return ORDER_PLACED_SUCCESSFULLY;
     }

   Print(failSendingOrder());
   return ERR_SEND_FAILED;
  }

//+------------------------------------------------------------------+
Transaction::ENUM_ORDER_TRANSACTION Transaction::SendPendingOrPosition(double price, ENUM_ORDER_TYPE_AVAILABLE type, datetime expiration = 0)
  {
   BuildPendingOrPosition(tradeRequest, type, typeFillingMode, price, expiration);

   double stops[] = {tradeRequest.sl, tradeRequest.tp, tradeRequest.price};

   if(calcStop.VerifyNoNegative(stops) && OrderSend(tradeRequest, tradeResult))
     {
      if(tradeRequest.action == TRADE_ACTION_DEAL && PositionSelectByTicket(tradeResult.order))
         return POSITION_EXECUTED_SUCCESSFULLY;

      if(tradeRequest.action == TRADE_ACTION_PENDING && OrderSelect(tradeResult.order))
         return ORDER_PLACED_SUCCESSFULLY;
     }

   Print(failSendingOrder());
   return ERR_SEND_FAILED;
  }

//+------------------------------------------------------------------+
string Transaction::EnumCheckTransactionToString(ENUM_CHECK enumResult)
  {
   string result;
   switch(enumResult)
     {
      case CHECK_ARG_TRANSACTION_PASSED:
         result = StringFormat("%s: Arguments passed the check.", EnumToString(enumResult));
         break;
      case ERR_SYMBOL_NOT_AVAILABLE:
         result = StringFormat("%s: Symbol %s not available.", EnumToString(enumResult), _Symbol);
         break;
      case ERR_INVALID_LOT_SIZE:
         result = StringFormat("%s: Lot Size %.2f invalid.", EnumToString(enumResult), this.setting.lotSize);
         break;
      case ERR_DEVIATION_INSUFFICIENT:
         result = StringFormat("%s: Deviation %d may not sufficient. Position couldn't place.", EnumToString(enumResult), this.setting.deviationTrade);
         break;
      default:
         result = "Unknown error.";
         break;
     }
   return result;
  }

//+------------------------------------------------------------------+
string Transaction::EnumOrderTransactionToString(ENUM_ORDER_TRANSACTION enumResult)
  {
   string result;
   switch(enumResult)
     {
      case POSITION_EXECUTED_SUCCESSFULLY:
         result = StringFormat("%s: Position executed successfully", EnumToString(enumResult));
         break;
      case ORDER_PLACED_SUCCESSFULLY:
         result = StringFormat("%s: Pending order placed successfully", EnumToString(enumResult));
         break;
      case ERR_SEND_FAILED:
         result = StringFormat("%s: Send Failed. Err: %d %s", EnumToString(enumResult), tradeResult.retcode, tradeResult.comment);
         break;
      default:
         result = "Unknown error.";
         break;
     }
   return result;
  }

//+------------------------------------------------------------------+
string Transaction::EnumFixFillingModeToString(ENUM_FIX_FILLING_MODE enumResult)
  {
   string result;
   switch(enumResult)
     {
      case FILLING_MODE_FOUND:
         result = StringFormat("%s: Filling mode %s found and setted.", EnumToString(enumResult), EnumToString(tradeRequest.type_filling));
         break;
      case ERR_FILLING_MODE_NO_FOUND:
         result = StringFormat("%s: Filling mode no found.", EnumToString(enumResult));
         break;
      case ERR_INVALID_REQUEST:
         result = StringFormat("%s: Impossible find filling mode with the current request.", EnumToString(enumResult));
         break;
      default:
         result = "Unknown error.";
         break;
     }
   return result;
  }

//+------------------------------------------------------------------+
string Transaction::CommentToShow()
  {
   return StringFormat("\n Lot Size: %.2f \n Stop Loss: %d\n Take Profit: %d\n Deviation: %d\n Magic: %d\n Correct Filling: %s\n",
                       this.setting.lotSize, this.setting.stopLoss, this.setting.takeProfit, this.setting.deviationTrade, this.setting.magicNumber, EnumToString(tradeRequest.type_filling));
  }
//+------------------------------------------------------------------+
