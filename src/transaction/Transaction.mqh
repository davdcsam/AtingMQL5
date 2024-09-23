//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+
#include "Request.mq5"

//+------------------------------------------------------------------+
/**
 * @class Transaction
 * @brief Class to handle trading transactions, inheriting from Request.
 */
class Transaction : public Request
  {
protected:
   double            priceAsk, priceBid, tickSize; /**< Ask price, Bid price, and Tick size for the transaction */

   /**
    * @brief Returns a formatted string describing the failure of sending an order.
    * @return A string with details of the failed order.
    */
   string            failSendingOrder();

public:
   /**
    * @brief Constructor for the Transaction class.
    */
                     Transaction(RoundVolume* rV, CalcStop* cS) : Request(rV, cS) {}

   /**
    * @enum ENUM_CHECK
    * @brief Enum to handle different types of check transactions.
    */
   enum ENUM_CHECK
     {
      CHECK_ARG_TRANSACTION_PASSED, /**< Check transaction passed */
      ERR_SYMBOL_NOT_AVAILABLE, /**< Error: Symbol not available */
      ERR_INVALID_LOT_SIZE, /**< Error: Invalid lot size */
      ERR_DEVIATION_INSUFFICIENT /**< Error: Insufficient deviation */
     };

   /**
    * @enum ENUM_ORDER_TRANSACTION
    * @brief Enum to handle different types of order transactions.
    */
   enum ENUM_ORDER_TRANSACTION
     {
      POSITION_EXECUTED_SUCCESSFULLY = 2, /**< Position executed successfully */
      ORDER_PLACED_SUCCESSFULLY = 1, /**< Order placed successfully */
      ERR_SEND_FAILED = 0 /**< Error: Send failed */
     };

   /**
    * @enum ENUM_FIX_FILLING_MODE
    * @brief Enum to handle different types of fix filling modes.
    */
   enum ENUM_FIX_FILLING_MODE
     {
      FILLING_MODE_FOUND, /**< Filling mode found */
      ERR_FILLING_MODE_NO_FOUND, /**< Error: Filling mode not found */
      ERR_INVALID_REQUEST /**< Error: Invalid request */
     };

   MqlTradeRequest   tradeRequest; /**< Trade request for the transaction */
   MqlTradeResult    tradeResult; /**< Trade result for the transaction */
   MqlTradeCheckResult tradeCheckResult; /**< Trade check result for the transaction */
   ENUM_ORDER_TYPE_FILLING typeFillingMode; /**< Filling mode for the transaction */

   /**
    * @brief Checks the arguments for the transaction.
    * @return The result of the check as ENUM_CHECK.
    */
   ENUM_CHECK        CheckArg();

   /**
    * @brief Updates the transaction parameters.
    */
   void              Update();

   /**
    * @brief Fixes the filling mode for the transaction.
    * @return The result of fixing the filling mode as ENUM_FIX_FILLING_MODE.
    */
   ENUM_FIX_FILLING_MODE FixFillingMode();

   /**
    * @brief Sends a position order for the transaction.
    * @param type The type of position order.
    * @return The result of sending the order as ENUM_ORDER_TRANSACTION.
    */
   ENUM_ORDER_TRANSACTION SendPosition(ENUM_POSITION_TYPE type);

   /**
    * @brief Sends a pending order with default parameters for the transaction.
    * @param price The price at which the pending order will open.
    * @param type The type of pending order.
    * @param expiration The expiration order.
    * @return The result of sending the order as ENUM_ORDER_TRANSACTION.
    */
   ENUM_ORDER_TRANSACTION SendPendingDefault(double price, ENUM_ORDER_TYPE_BASE type, datetime expiration);

   /**
    * @brief Sends a pending or position order for the transaction.
    * @param price The price at which the order will open.
    * @param type The type of pending order.
    * @param expiration The expiration order.
    * @return The result of sending the order as ENUM_ORDER_TRANSACTION.
    */
   ENUM_ORDER_TRANSACTION SendPendingOrPosition(double price, ENUM_ORDER_TYPE_AVAILABLE type, datetime expiration);

   /**
    * @brief Converts the check transaction result to a string.
    * @param enumResult The result of the check transaction.
    * @return A string representing the check transaction result.
    */
   string            EnumCheckTransactionToString(ENUM_CHECK enumResult);

   /**
    * @brief Converts the order transaction result to a string.
    * @param enumResult The result of the order transaction.
    * @return A string representing the order transaction result.
    */
   string            EnumOrderTransactionToString(ENUM_ORDER_TRANSACTION enumResult);

   /**
    * @brief Converts the fix filling mode result to a string.
    * @param enumResult The result of the fix filling mode.
    * @return A string representing the fix filling mode result.
    */
   string            EnumFixFillingModeToString(ENUM_FIX_FILLING_MODE enumResult);

   /**
    * @brief Returns a formatted string with details of the transaction.
    * @return A string with details of the transaction.
    */
   string            CommentToShow();
  };

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
void Transaction::Update()
  {
   tickSize = SymbolInfoDouble(this.setting.symbol, SYMBOL_TRADE_TICK_SIZE);
   priceAsk = round(SymbolInfoDouble(this.setting.symbol, SYMBOL_ASK) / tickSize) * tickSize;
   priceBid = round(SymbolInfoDouble(this.setting.symbol, SYMBOL_BID) / tickSize) * tickSize;
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

   bool noNegativeStop = calcStop.VerifyNoNegative(stops);
   bool sendSuccessfully = OrderSend(tradeRequest, tradeResult);

   if(noNegativeStop && sendSuccessfully)
     {
      if(
         tradeRequest.action == TRADE_ACTION_DEAL &&
         PositionSelectByTicket(tradeResult.deal)
      )
         return POSITION_EXECUTED_SUCCESSFULLY;

      if(tradeRequest.action == TRADE_ACTION_PENDING)
        {
         if(PositionSelectByTicket(tradeResult.order))
            return POSITION_EXECUTED_SUCCESSFULLY;
         if(OrderSelect(tradeResult.order))
            return ORDER_PLACED_SUCCESSFULLY;
        }
     }

   Print(failSendingOrder());
   return ERR_SEND_FAILED;
  }

//+------------------------------------------------------------------+
Transaction::ENUM_ORDER_TRANSACTION Transaction::SendPendingOrPosition(double price, ENUM_ORDER_TYPE_AVAILABLE type, datetime expiration = 0)
  {
   BuildPendingOrPosition(tradeRequest, type, typeFillingMode, price, expiration);

   double stops[] = {tradeRequest.sl, tradeRequest.tp, tradeRequest.price};

   bool noNegativeStop = calcStop.VerifyNoNegative(stops);
   bool sendSuccessfully = OrderSend(tradeRequest, tradeResult);

   if(noNegativeStop && sendSuccessfully)
     {
      if(
         tradeRequest.action == TRADE_ACTION_DEAL &&
         PositionSelectByTicket(tradeResult.deal)
      )
         return POSITION_EXECUTED_SUCCESSFULLY;

      if(tradeRequest.action == TRADE_ACTION_PENDING)
        {
         if(PositionSelectByTicket(tradeResult.order))
            return POSITION_EXECUTED_SUCCESSFULLY;
         if(OrderSelect(tradeResult.order))
            return ORDER_PLACED_SUCCESSFULLY;
        }
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
//+------------------------------------------------------------------+
