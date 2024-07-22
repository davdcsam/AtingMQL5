//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+

// Include the Request class from the Request library
#include "Request.mqh";

//+------------------------------------------------------------------+
//| Transaction                                                      |
//+------------------------------------------------------------------+
class Transaction : public Request
  {
protected:
   // Ask price for the transaction
   double            priceAsk, priceBid, tickSize;

   // Filling mode for the transaction
   ENUM_ORDER_TYPE_FILLING typeFilliingMode;

   string            failSendingOrder()
     {
      return StringFormat("Fail with order Type s%, Lot %s, Sl %s, Tp %s, Op %s",
                          EnumToString(tradeRequest.type),
                          DoubleToString(tradeRequest.volume, _Digits),
                          DoubleToString(tradeRequest.sl, _Digits),
                          DoubleToString(tradeRequest.tp, _Digits),
                          DoubleToString(tradeRequest.price, _Digits)
                         );
     };

public:
   // Constructor for the Transaction class
                     Transaction(void) {}


   // ENUM_CHECK: Enum to handle different types of check transactions
   enum ENUM_CHECK
     {
      CHECK_ARG_TRANSACTION_PASSED, // Check transaction passed
      ERR_SYMBOL_NOT_AVAILABLE, // Error: Symbol not available
      ERR_INVALID_LOT_SIZE, // Error: Invalid lot size
      ERR_DEVIATION_INSUFFICIENT // Error: Insufficient deviation
     };

   // ENUM_ORDER_TRANSACTION: Enum to handle different types of order transactions
   enum ENUM_ORDER_TRANSACTION
     {
      ORDER_PLACED_SUCCESSFULLY = 1, // Order placed successfully
      ERR_SEND_FAILED = 0// Error: Send failed
     };

   // ENUM_FIX_FILLING_MODE: Enum to handle different types of fix filling modes
   enum ENUM_FIX_FILLING_MODE
     {
      FILLING_MODE_FOUND, // Filling mode found
      ERR_FILLING_MODE_NO_FOUND, // Error: Filling mode not found
      ERR_INVALID_REQUEST // Error: Invalid request
     };

   // Trade request for the transaction
   MqlTradeRequest   tradeRequest;

   // Trade result for the transaction
   MqlTradeResult    tradeResult;

   // Trade check result for the transaction
   MqlTradeCheckResult tradeCheckResult;

   // Function to check the arguments for the transaction
   ENUM_CHECK        CheckArg()
     {
      // Check if the symbol exists
      bool isCustom;
      if(!SymbolExist(symbol, isCustom))
         return(ERR_SYMBOL_NOT_AVAILABLE);

      // Check if the lot size is within the valid range
      if(
         SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN) >= lotSize
         && SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX) <= lotSize
      )
         return(ERR_INVALID_LOT_SIZE);

      // Check if the deviation trade is within the valid range
      if(
         deviationTrade < takeProfit * 0.001
         || deviationTrade < stopLoss * 0.001
      )
        {
         return(ERR_DEVIATION_INSUFFICIENT);
        }

      // If all checks pass, return CHECK_ARG_TRANSACTION_PASSED
      return(CHECK_ARG_TRANSACTION_PASSED);
     }

   // Function to update the transaction
   void              Update()
     {
      // Get the tick size for the symbol
      tickSize = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);

      // Round the ask price to the nearest tick size
      priceAsk = round(SymbolInfoDouble(symbol, SYMBOL_ASK) / tickSize) * tickSize;

      // Round the bid price to the nearest tick size
      priceBid = round(SymbolInfoDouble(symbol, SYMBOL_BID) / tickSize) * tickSize;
     }

   // Function to fix the filling mode for the transaction
   ENUM_FIX_FILLING_MODE FixFillingMode()
     {
      // List of possible filling modes
      ENUM_ORDER_TYPE_FILLING list_order_type_filling[] =
        {
         ORDER_FILLING_FOK,
         ORDER_FILLING_IOC,
         ORDER_FILLING_RETURN,
         ORDER_FILLING_BOC
        };

      // Loop through each filling mode
      for(int i=0; i<ArraySize(list_order_type_filling); i++)
        {
         // Update the transaction
         Update();

         // Build a check position for the transaction
         BuildCheckPosition(tradeRequest, POSITION_TYPE_BUY, list_order_type_filling[i], priceAsk, priceBid);

         // Check if the order is valid
         if(!OrderCheck(tradeRequest, tradeCheckResult) && tradeCheckResult.retcode != TRADE_RETCODE_INVALID_FILL)
           {
            // If the order is not valid, print an error message and return ERR_INVALID_REQUEST
            PrintFormat("Error Checking Request: %d %s", GetLastError(), tradeCheckResult.comment);
            return(ERR_INVALID_REQUEST);
           }

         // If the order is valid, set the filling mode and return FILLING_MODE_FOUND
         if(tradeCheckResult.retcode == 0)
           {
            typeFilliingMode = tradeRequest.type_filling;
            return(FILLING_MODE_FOUND);
           }
        }

      // If no filling mode is found, return ERR_FILLING_MODE_NO_FOUND
      return(ERR_FILLING_MODE_NO_FOUND);
     }

   ENUM_ORDER_TRANSACTION SendPosition(ENUM_POSITION_TYPE order_type)
     {
      BuildPosition(tradeRequest, order_type, typeFilliingMode);

      double stops[] = {tradeRequest.sl, tradeRequest.tp, tradeRequest.price};

      if(
         !calcStop.VerifyNoNegative(stops) ||
         !OrderSendAsync(tradeRequest, tradeResult)
      )
        {
         Print(failSendingOrder());
         return(ERR_SEND_FAILED);
        }

      // If the order is sent successfully, return ORDER_PLACED_SUCCESSFULLY
      return(ORDER_PLACED_SUCCESSFULLY);
     }

   // Function to send a pending order for the transaction
   ENUM_ORDER_TRANSACTION SendPendingDefault(double open_price, ENUM_ORDER_PENDING_TYPE order_type)
     {
      // Build a pending order for the transaction
      BuildPending(tradeRequest, order_type, typeFilliingMode, open_price, SymbolInfoDouble(symbol, SYMBOL_ASK), SymbolInfoDouble(symbol, SYMBOL_BID));

      double stops[] = {tradeRequest.sl, tradeRequest.tp, tradeRequest.price};

      if(
         !calcStop.VerifyNoNegative(stops) ||
         !OrderSend(tradeRequest, tradeResult)
      )
        {
         // If the order cannot be sent, print an error message and return ERR_SEND_FAILED
         Print(failSendingOrder());
         return(ERR_SEND_FAILED);
        }

      // If the order is sent successfully, return ORDER_PLACED_SUCCESSFULLY
      return(ORDER_PLACED_SUCCESSFULLY);
     }

   ENUM_ORDER_TRANSACTION SendPendingOrPosition(double open_price, double comparative_price, ENUM_ORDER_PENDING_TYPE order_type)
     {
      BuildPendingOrPosition(tradeRequest, order_type, typeFilliingMode, open_price, comparative_price);

      double stops[] = {tradeRequest.sl, tradeRequest.tp, tradeRequest.price};

      if(
         !calcStop.VerifyNoNegative(stops) ||
         !OrderSend(tradeRequest, tradeResult)
      )
        {
         Print(failSendingOrder());
         return(ERR_SEND_FAILED);
        }

      return(ORDER_PLACED_SUCCESSFULLY);
     }
   // Function to return a string comment based on the result of the check transaction
   string            EnumCheckTransactionToString(ENUM_CHECK enum_result)
     {
      string result;

      // Switch case based on the result of the check transaction
      switch(enum_result)
        {
         // Case when the arguments passed the check
         case CHECK_ARG_TRANSACTION_PASSED:
            result = StringFormat(
                        "%s: Arguments passed the check.",
                        EnumToString(enum_result)
                     );
            break;

         // Case when the symbol is not available
         case ERR_SYMBOL_NOT_AVAILABLE:
            result = StringFormat(
                        "%s: Symbol %s not available.",
                        EnumToString(enum_result),
                        _Symbol
                     );
            break;

         // Case when the lot size is invalid
         case ERR_INVALID_LOT_SIZE:
            result = StringFormat(
                        "%s: Lot Size %.2f invalied.",
                        EnumToString(enum_result),
                        lotSize
                     );
            break;

         // Case when the deviation is insufficient
         case ERR_DEVIATION_INSUFFICIENT:
            result = StringFormat(
                        "%s: Deviation %d may not sufficient. Position couldn't place.",
                        EnumToString(enum_result),
                        deviationTrade
                     );
            break;

         // Default case when an unknown error occurred
         default:
            result = "Unknown error.";
            break;
        }

      // Return the result
      return(result);
     }

   string            EnumOrderTransactionToString(ENUM_ORDER_TRANSACTION enum_result)
     {
      string result;

      // Switch case based on the result of the order transaction
      switch(enum_result)
        {
         // Case when the order was placed successfully
         case ORDER_PLACED_SUCCESSFULLY:
            result = StringFormat(
                        "%s: Pending order placed successfully",
                        EnumToString(enum_result)
                     );
            break;

         // Case when the order failed to send
         case ERR_SEND_FAILED:
            result = StringFormat(
                        "%s: Send Failed. Err: %d %s",
                        EnumToString(enum_result),
                        tradeResult.retcode,
                        tradeResult.comment
                     );
            break;

         // Default case when an unknown error occurred
         default:
            result = "Unknown error.";
            break;
        }

      // Return the result
      return(result);
     }

   string            EnumFixFillingModeToString(ENUM_FIX_FILLING_MODE enum_result)
     {
      string result;

      // Switch case based on the result of the fix filling mode
      switch(enum_result)
        {
         // Case when the filling mode was found and set
         case FILLING_MODE_FOUND:
            result = StringFormat(
                        "%s: Filling mode %s found and setted.",
                        EnumToString(enum_result),
                        EnumToString(tradeRequest.type_filling)
                     );
            break;

         // Case when the filling mode was not found
         case ERR_FILLING_MODE_NO_FOUND:
            result = StringFormat(
                        "%s: Filling mode no found.",
                        EnumToString(enum_result)
                     );
            break;

         // Case when it was impossible to find the filling mode with the current request
         case ERR_INVALID_REQUEST:
            result = StringFormat(
                        "%s: Imposible find filling mode with the current request.",
                        EnumToString(enum_result)
                     );
            break;

         // Default case when an unknown error occurred
         default:
            result = "Unknown error.";
            break;
        }

      // Return the result
      return(result);
     }

   // Function to update the comment for the transaction
   string              CommentToShow()
     {
      return StringFormat(
                "\n Lot Size: %.2f \n Stop Loss: %d\n Take Profit: %d\n Devation: %d\n Magic: %d\n Correct Filling: %s\n",
                lotSize,
                stopLoss,
                takeProfit,
                deviationTrade,
                magicNumber,
                EnumToString(tradeRequest.type_filling)
             );
     }
  };
//+------------------------------------------------------------------+
