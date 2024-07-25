//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+
#include "Request.mqh"

//+------------------------------------------------------------------+
/**
 * @class Transaction
 * @brief Class to handle trading transactions, inheriting from Request.
 */
class Transaction : public Request
  {
protected:
   double            priceAsk, priceBid, tickSize; /**< Ask price, Bid price, and Tick size for the transaction */
   ENUM_ORDER_TYPE_FILLING typeFilliingMode; /**< Filling mode for the transaction */

   /**
    * @brief Returns a formatted string describing the failure of sending an order.
    * @return A string with details of the failed order.
    */
   string            failSendingOrder();

public:
   /**
    * @brief Constructor for the Transaction class.
    */
                     Transaction(void) {}

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
    * @param order_type The type of position order.
    * @return The result of sending the order as ENUM_ORDER_TRANSACTION.
    */
   ENUM_ORDER_TRANSACTION SendPosition(ENUM_POSITION_TYPE order_type);

   /**
    * @brief Sends a pending order with default parameters for the transaction.
    * @param open_price The price at which the pending order will open.
    * @param order_type The type of pending order.
    * @return The result of sending the order as ENUM_ORDER_TRANSACTION.
    */
   ENUM_ORDER_TRANSACTION SendPendingDefault(double open_price, ENUM_ORDER_PENDING_TYPE order_type);

   /**
    * @brief Sends a pending or position order for the transaction.
    * @param open_price The price at which the order will open.
    * @param comparative_price The comparative price for the order.
    * @param order_type The type of pending order.
    * @return The result of sending the order as ENUM_ORDER_TRANSACTION.
    */
   ENUM_ORDER_TRANSACTION SendPendingOrPosition(double open_price, double comparative_price, ENUM_ORDER_PENDING_TYPE order_type);

   /**
    * @brief Converts the check transaction result to a string.
    * @param enum_result The result of the check transaction.
    * @return A string representing the check transaction result.
    */
   string            EnumCheckTransactionToString(ENUM_CHECK enum_result);

   /**
    * @brief Converts the order transaction result to a string.
    * @param enum_result The result of the order transaction.
    * @return A string representing the order transaction result.
    */
   string            EnumOrderTransactionToString(ENUM_ORDER_TRANSACTION enum_result);

   /**
    * @brief Converts the fix filling mode result to a string.
    * @param enum_result The result of the fix filling mode.
    * @return A string representing the fix filling mode result.
    */
   string            EnumFixFillingModeToString(ENUM_FIX_FILLING_MODE enum_result);

   /**
    * @brief Returns a formatted string with details of the transaction.
    * @return A string with details of the transaction.
    */
   string            CommentToShow();
  };

//+------------------------------------------------------------------+
string Transaction::failSendingOrder()
  {
   return StringFormat("Fail with order Type s%, Lot %s, Sl %s, Tp %s, Op %s",
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
   if(!SymbolExist(symbol, isCustom))
      return ERR_SYMBOL_NOT_AVAILABLE;

   if(SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN) >= lotSize && SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX) <= lotSize)
      return ERR_INVALID_LOT_SIZE;

   if(deviationTrade < takeProfit * 0.001 || deviationTrade < stopLoss * 0.001)
     {
      return ERR_DEVIATION_INSUFFICIENT;
     }

   return CHECK_ARG_TRANSACTION_PASSED;
  }

//+------------------------------------------------------------------+
void Transaction::Update()
  {
   tickSize = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
   priceAsk = round(SymbolInfoDouble(symbol, SYMBOL_ASK) / tickSize) * tickSize;
   priceBid = round(SymbolInfoDouble(symbol, SYMBOL_BID) / tickSize) * tickSize;
  }

//+------------------------------------------------------------------+
Transaction::ENUM_FIX_FILLING_MODE Transaction::FixFillingMode()
  {
   ENUM_ORDER_TYPE_FILLING list_order_type_filling[] = {ORDER_FILLING_FOK, ORDER_FILLING_IOC, ORDER_FILLING_RETURN, ORDER_FILLING_BOC};

   for(int i = 0; i < ArraySize(list_order_type_filling); i++)
     {
      Update();
      BuildCheckPosition(tradeRequest, POSITION_TYPE_BUY, list_order_type_filling[i]);

      if(!OrderCheck(tradeRequest, tradeCheckResult) && tradeCheckResult.retcode != TRADE_RETCODE_INVALID_FILL)
        {
         PrintFormat("Error Checking Request: %d %s", GetLastError(), tradeCheckResult.comment);
         return ERR_INVALID_REQUEST;
        }

      if(tradeCheckResult.retcode == 0)
        {
         typeFilliingMode = tradeRequest.type_filling;
         return FILLING_MODE_FOUND;
        }
     }

   return ERR_FILLING_MODE_NO_FOUND;
  }

//+------------------------------------------------------------------+
Transaction::ENUM_ORDER_TRANSACTION Transaction::SendPosition(ENUM_POSITION_TYPE order_type)
  {
   BuildPosition(tradeRequest, order_type, typeFilliingMode);

   double stops[] = {tradeRequest.sl, tradeRequest.tp, tradeRequest.price};

   if(!calcStop.VerifyNoNegative(stops) || !OrderSendAsync(tradeRequest, tradeResult))
     {
      Print(failSendingOrder());
      return ERR_SEND_FAILED;
     }

   return ORDER_PLACED_SUCCESSFULLY;
  }

//+------------------------------------------------------------------+
Transaction::ENUM_ORDER_TRANSACTION Transaction::SendPendingDefault(double open_price, ENUM_ORDER_PENDING_TYPE order_type)
  {
   BuildPending(tradeRequest, order_type, typeFilliingMode, open_price);

   double stops[] = {tradeRequest.sl, tradeRequest.tp, tradeRequest.price};

   if(!calcStop.VerifyNoNegative(stops) || !OrderSend(tradeRequest, tradeResult))
     {
      Print(failSendingOrder());
      return ERR_SEND_FAILED;
     }

   return ORDER_PLACED_SUCCESSFULLY;
  }

//+------------------------------------------------------------------+
Transaction::ENUM_ORDER_TRANSACTION Transaction::SendPendingOrPosition(double open_price, double comparative_price, ENUM_ORDER_PENDING_TYPE order_type)
  {
   BuildPendingOrPosition(tradeRequest, order_type, typeFilliingMode, open_price);

   double stops[] = {tradeRequest.sl, tradeRequest.tp, tradeRequest.price};

   if(!calcStop.VerifyNoNegative(stops) || !OrderSend(tradeRequest, tradeResult))
     {
      Print(failSendingOrder());
      return ERR_SEND_FAILED;
     }

   return ORDER_PLACED_SUCCESSFULLY;
  }

//+------------------------------------------------------------------+
string Transaction::EnumCheckTransactionToString(ENUM_CHECK enum_result)
  {
   string result;
   switch(enum_result)
     {
      case CHECK_ARG_TRANSACTION_PASSED:
         result = StringFormat("%s: Arguments passed the check.", EnumToString(enum_result));
         break;
      case ERR_SYMBOL_NOT_AVAILABLE:
         result = StringFormat("%s: Symbol %s not available.", EnumToString(enum_result), _Symbol);
         break;
      case ERR_INVALID_LOT_SIZE:
         result = StringFormat("%s: Lot Size %.2f invalied.", EnumToString(enum_result), lotSize);
         break;
      case ERR_DEVIATION_INSUFFICIENT:
         result = StringFormat("%s: Deviation %d may not sufficient. Position couldn't place.", EnumToString(enum_result), deviationTrade);
         break;
      default:
         result = "Unknown error.";
         break;
     }
   return result;
  }

//+------------------------------------------------------------------+
string Transaction::EnumOrderTransactionToString(ENUM_ORDER_TRANSACTION enum_result)
  {
   string result;
   switch(enum_result)
     {
      case ORDER_PLACED_SUCCESSFULLY:
         result = StringFormat("%s: Pending order placed successfully", EnumToString(enum_result));
         break;
      case ERR_SEND_FAILED:
         result = StringFormat("%s: Send Failed. Err: %d %s", EnumToString(enum_result), tradeResult.retcode, tradeResult.comment);
         break;
      default:
         result = "Unknown error.";
         break;
     }
   return result;
  }

//+------------------------------------------------------------------+
string Transaction::EnumFixFillingModeToString(ENUM_FIX_FILLING_MODE enum_result)
  {
   string result;
   switch(enum_result)
     {
      case FILLING_MODE_FOUND:
         result = StringFormat("%s: Filling mode %s found and setted.", EnumToString(enum_result), EnumToString(tradeRequest.type_filling));
         break;
      case ERR_FILLING_MODE_NO_FOUND:
         result = StringFormat("%s: Filling mode no found.", EnumToString(enum_result));
         break;
      case ERR_INVALID_REQUEST:
         result = StringFormat("%s: Imposible find filling mode with the current request.", EnumToString(enum_result));
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
   return StringFormat("\n Lot Size: %.2f \n Stop Loss: %d\n Take Profit: %d\n Devation: %d\n Magic: %d\n Correct Filling: %s\n",
                       lotSize, stopLoss, takeProfit, deviationTrade, magicNumber, EnumToString(tradeRequest.type_filling));
  }
//+------------------------------------------------------------------+
