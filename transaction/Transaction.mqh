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
   ENUM_ORDER_TRANSACTION SendPending(double open_price, ENUM_ORDER_PENDING_TYPE order_type)
     {
      // Build a pending order for the transaction
      BuildPending(trade_request, order_type, type_filliing_mode, open_price);

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
  };
//+------------------------------------------------------------------+
