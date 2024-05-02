//+------------------------------------------------------------------+
//|                                               TransactionHandler |
//|                                         Copyright 2024, DavdCsam |
//|                                      https://github.com/davdcsam |
//+------------------------------------------------------------------+

// Include the Transaction class from the Transaction library
#include "Transaction.mqh";

// Group of inputs related to trade
input group "Trade"

// Input to allow sending extra orders
input bool input_allow_extra_orders = false; // Allow extra orders

// Input for the lot size
input double input_lot_size = 1; // Lot Size

// Input for the take profit
input uint input_take_profit = 10000; // Take Profit

// Input for the stop loss
input uint input_stop_loss = 2500; // Stop Loss

// Input for the deviation trade
input uint input_deviation_trade  = 100; // Deviation

// Input for the magic number
input ulong input_magic_number = 420; // Magic Number

// Input to show the transaction handler comment
input bool input_show_transaction_handler_comment = true; // Show Comment

// String to store the transaction handler comment
string comment_transaction_handler;

// Create a new Transaction object
Transaction transaction(_Symbol, MathAbs(input_lot_size), input_take_profit, input_stop_loss, input_deviation_trade, input_magic_number);

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

// Function to return a string comment based on the result of the check transaction
string comment_enum_check_transaction(ENUM_CHECK_TRANSACTION enum_result)
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
                     input_lot_size
                  );
         break;

      // Case when the deviation is insufficient
      case ERR_DEVIATION_INSUFFICIENT:
         result = StringFormat(
                     "%s: Deviation %d may not sufficient. Position couldn't place.",
                     EnumToString(enum_result),
                     input_deviation_trade
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

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

// Function to return a string comment based on the result of the order transaction
string comment_enum_order_transaction(ENUM_ORDER_TRANSACTION enum_result)
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
                     transaction.trade_result.retcode,
                     transaction.trade_result.comment
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

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

// Function to return a string comment based on the result of the fix filling mode
string comment_enum_fix_filling_mode(ENUM_FIX_FILLING_MODE enum_result)
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
                     EnumToString(transaction.trade_request.type_filling)
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



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
// Function to update the comment for the transaction
void update_comment_transaction()
  {
   // If the input is set to show the transaction handler comment
   if(input_show_transaction_handler_comment)
      // Format the comment for the transaction handler
      comment_transaction_handler =  StringFormat(
                                        "\n Send Extra Orders: %s\n Lot Size: %.2f \n Stop Loss: %d\n Take Profit: %d\n Devation: %d\n Magic: %d\n Correct Filling: %s\n",
                                        input_allow_extra_orders ? "Allowed" : "Prohibited",
                                        input_lot_size,
                                        input_stop_loss,
                                        input_take_profit,
                                        input_deviation_trade,
                                        input_magic_number,
                                        EnumToString(transaction.trade_request.type_filling)
                                     );
   else
      // If the input is not set to show the transaction handler comment, set the comment to an empty string
      comment_transaction_handler = "";
  }
//+------------------------------------------------------------------+
