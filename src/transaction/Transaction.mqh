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

   /**
    * @brief Updates the transaction parameters.
    */
   void              Update();

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
    * @brief Fixes the filling mode for the transaction.
    * @return The result of fixing the filling mode as ENUM_FIX_FILLING_MODE.
    */
   ENUM_FIX_FILLING_MODE FixFillingMode();

   /**
    * @brief Sends a position order for the transaction.
    * @param type The type of position order.
    * @return The result of sending the order as ENUM_ORDER_TRANSACTION.
    */
   ENUM_ORDER_TRANSACTION SendPosition(ENUM_POSITION_TYPE type, string comment = "");

   /**
    * @brief Sends a pending order with default parameters for the transaction.
    * @param price The price at which the pending order will open.
    * @param type The type of pending order.
    * @param expiration The expiration order.
    * @return The result of sending the order as ENUM_ORDER_TRANSACTION.
    */
   ENUM_ORDER_TRANSACTION SendPendingDefault(double price, ENUM_ORDER_TYPE_BASE type, datetime expiration, string comment = "");

   /**
    * @brief Sends a pending or position order for the transaction.
    * @param price The price at which the order will open.
    * @param type The type of pending order.
    * @param expiration The expiration order.
    * @return The result of sending the order as ENUM_ORDER_TRANSACTION.
    */
   ENUM_ORDER_TRANSACTION SendPendingOrPosition(double price, ENUM_ORDER_TYPE_AVAILABLE type, datetime expiration, string comment = "");

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
