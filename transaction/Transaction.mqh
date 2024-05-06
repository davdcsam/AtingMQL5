//+------------------------------------------------------------------+
//|                                                       Trasaction |
//|                                         Copyright 2024, DavdCsam |
//|                                      https://github.com/davdcsam |
//+------------------------------------------------------------------+

// Include the Request class from the Request library
#include "Request.mqh";

// ENUM_CHECK_TRANSACTION: Enum to handle different types of check transactions
enum ENUM_CHECK_TRANSACTION
  {
   CHECK_ARG_TRANSACTION_PASSED, // Check transaction passed
   ERR_SYMBOL_NOT_AVAILABLE, // Error: Symbol not available
   ERR_INVALID_LOT_SIZE, // Error: Invalid lot size
   ERR_DEVIATION_INSUFFICIENT // Error: Insufficient deviation
  };

// ENUM_ORDER_TRANSACTION: Enum to handle different types of order transactions
enum ENUM_ORDER_TRANSACTION
  {
   ORDER_PLACED_SUCCESSFULLY, // Order placed successfully
   ERR_SEND_FAILED // Error: Send failed
  };

// ENUM_FIX_FILLING_MODE: Enum to handle different types of fix filling modes
enum ENUM_FIX_FILLING_MODE
  {
   FILLING_MODE_FOUND, // Filling mode found
   ERR_FILLING_MODE_NO_FOUND, // Error: Filling mode not found
   ERR_INVALID_REQUEST // Error: Invalid request
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
// Transaction: Class to handle transaction operations
class Transaction : public Request
  {
private:
   // Ask price for the transaction
   double            price_ask;

   // Bid price for the transaction
   double            price_bid;

   // Tick size for the transaction
   double            tick_size;

   // Filling mode for the transaction
   ENUM_ORDER_TYPE_FILLING type_filliing_mode;

public:
   // Constructor for the Transaction class
                     Transaction(
      string symbol_arg, // Symbol for the transaction
      double lot_size_arg, // Lot size for the transaction
      uint take_profit_arg, // Take profit for the transaction
      uint stop_loss_arg, // Stop loss for the transaction
      uint deviation_trade_arg, // Deviation trade for the transaction
      ulong magic_number_arg // Magic number for the transaction
   ) :               Request(
         symbol_arg,
         lot_size_arg,
         take_profit_arg,
         stop_loss_arg,
         deviation_trade_arg,
         magic_number_arg
      ) {}

   // Trade request for the transaction
   MqlTradeRequest   trade_request;

   // Trade result for the transaction
   MqlTradeResult    trade_result;

   // Trade check result for the transaction
   MqlTradeCheckResult trade_check_result;

   // Function to check the arguments for the transaction
   ENUM_CHECK_TRANSACTION CheckArg()
     {
      // Check if the symbol exists
      bool is_custom;
      if(!SymbolExist(symbol, is_custom))
         return(ERR_SYMBOL_NOT_AVAILABLE);

      // Check if the lot size is within the valid range
      if(
         SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN) >= lot_size
         && SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX) <= lot_size
      )
         return(ERR_INVALID_LOT_SIZE);

      // Check if the deviation trade is within the valid range
      if(
         deviation_trade < take_profit * 0.005
         || deviation_trade < stop_loss * 0.005
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
      tick_size = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);

      // Round the ask price to the nearest tick size
      price_ask = round(SymbolInfoDouble(symbol, SYMBOL_ASK) / tick_size) * tick_size;

      // Round the bid price to the nearest tick size
      price_bid = round(SymbolInfoDouble(symbol, SYMBOL_BID) / tick_size) * tick_size;
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
         BuildCheckPosition(trade_request, POSITION_TYPE_BUY, list_order_type_filling[i], price_ask, price_bid);

         // Check if the order is valid
         if(!OrderCheck(trade_request, trade_check_result) && trade_check_result.retcode != TRADE_RETCODE_INVALID_FILL)
           {
            // If the order is not valid, print an error message and return ERR_INVALID_REQUEST
            PrintFormat("Error Checking Request: %d %s", GetLastError(), trade_check_result.comment);
            return(ERR_INVALID_REQUEST);
           }

         // If the order is valid, set the filling mode and return FILLING_MODE_FOUND
         if(trade_check_result.retcode == 0)
           {
            type_filliing_mode = trade_request.type_filling;
            return(FILLING_MODE_FOUND);
           }
        }

      // If no filling mode is found, return ERR_FILLING_MODE_NO_FOUND
      return(ERR_FILLING_MODE_NO_FOUND);
     }

   // Function to send a pending order for the transaction
   ENUM_ORDER_TRANSACTION SendPendingDefault(double open_price, ENUM_ORDER_PENDING_TYPE order_type)
     {
      // Build a pending order for the transaction
      BuildPending(trade_request, order_type, type_filliing_mode, open_price, SymbolInfoDouble(symbol, SYMBOL_ASK), SymbolInfoDouble(symbol, SYMBOL_BID));

      // Send the order
      if(!OrderSend(trade_request, trade_result))
        {
         // If the order cannot be sent, print an error message and return ERR_SEND_FAILED
         PrintFormat(
            "Type %s, Lot %s, Sl %s, Tp %s, Op %s",
            EnumToString(trade_request.type),
            DoubleToString(trade_request.volume, _Digits),
            DoubleToString(trade_request.sl,_Digits),
            DoubleToString(trade_request.tp,_Digits),
            DoubleToString(trade_request.price, _Digits)
         );
         return(ERR_SEND_FAILED);
        }

      // If the order is sent successfully, return ORDER_PLACED_SUCCESSFULLY
      return(ORDER_PLACED_SUCCESSFULLY);
     }

   ENUM_ORDER_TRANSACTION SendPendingOrPosition(double open_price, double comparative_price, ENUM_ORDER_PENDING_TYPE order_type)
     {
      BuildPendingOrPosition(trade_request, order_type, type_filliing_mode, open_price, comparative_price);
      
      if(!OrderSend(trade_request, trade_result))
        {
         PrintFormat(
            "Type s%, Lot %s, Sl %s, Tp %s, Op %s",
            EnumToString(trade_request.type),
            DoubleToString(trade_request.volume, _Digits),
            DoubleToString(trade_request.sl, _Digits),
            DoubleToString(trade_request.tp, _Digits),
            DoubleToString(trade_request.price, _Digits)
         );

         return(ERR_SEND_FAILED);         
        }
      
      return(ORDER_PLACED_SUCCESSFULLY);
     }
   // Function to return a string comment based on the result of the check transaction
   string            EnumCheckTransactionToString(ENUM_CHECK_TRANSACTION enum_result)
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
                        lot_size
                     );
            break;

         // Case when the deviation is insufficient
         case ERR_DEVIATION_INSUFFICIENT:
            result = StringFormat(
                        "%s: Deviation %d may not sufficient. Position couldn't place.",
                        EnumToString(enum_result),
                        deviation_trade
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
                        trade_result.retcode,
                        trade_result.comment
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
                        EnumToString(trade_request.type_filling)
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
                lot_size,
                stop_loss,
                take_profit,
                deviation_trade,
                magic_number,
                EnumToString(trade_request.type_filling)
             );
     }
  };
//+------------------------------------------------------------------+
