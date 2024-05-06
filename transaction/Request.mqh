//+------------------------------------------------------------------+
//|                                                          Request |
//|                                         Copyright 2024, DavdCsam |
//|                                      https://github.com/davdcsam |
//+------------------------------------------------------------------+

// ENUM_ORDER_PENDING_TYPE: Enum to handle different types of pending orders
enum ENUM_ORDER_PENDING_TYPE
  {
   ORDER_PENDING_TYPE_BUY = POSITION_TYPE_BUY, // Pending order type: Buy
   ORDER_PENDING_TYPE_SELL = POSITION_TYPE_SELL // Pending order type: Sell
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

// Request: Class to handle request operations
class Request
  {
protected:
   string            symbol; // Symbol for the request
   double            lot_size; // Lot size for the request
   uint              take_profit; // Take profit for the request
   uint              stop_loss; // Stop loss for the request
   uint              deviation_trade; // Deviation trade for the request
   ulong             magic_number; // Magic number for the request

   // BuildCheckPosition: Function to build a check position
   void              BuildCheckPosition(
      MqlTradeRequest& request, // Request to build
      ENUM_POSITION_TYPE order_type, // Order type for the request
      ENUM_ORDER_TYPE_FILLING filling_mode, // Filling mode for the request
      double& price_ask, // Ask price for the request
      double& price_bid // Bid price for the request
   )
     {
      ZeroMemory(request); // Clear the memory for the request

      long spread = SymbolInfoInteger(symbol, SYMBOL_SPREAD) * 2; // Calculate the spread

      request.action = TRADE_ACTION_DEAL; // Set the action for the request
      request.symbol = symbol; // Set the symbol for the request
      request.type = ENUM_ORDER_TYPE(order_type); // Set the order type for the request
      request.volume = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN); // Set the volume for the request
      request.deviation = spread; // Set the deviation for the request
      request.magic = magic_number; // Set the magic number for the request
      request.type_filling = filling_mode; // Set the filling mode for the request

      // If the order type is POSITION_TYPE_BUY
      if(order_type == POSITION_TYPE_BUY)
        {
         request.price = price_ask; // Set the price for the request
         request.tp = NormalizeDouble(request.price + spread * SymbolInfoDouble(symbol, SYMBOL_POINT), (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS)); // Set the take profit for the request
         request.sl = NormalizeDouble(request.price - spread  * SymbolInfoDouble(symbol, SYMBOL_POINT), (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS)); // Set the stop loss for the request
        }
      // If the order type is not POSITION_TYPE_BUY
      else
        {
         request.price = price_bid; // Set the price for the request
         request.tp = NormalizeDouble(request.price - spread * SymbolInfoDouble(symbol, SYMBOL_POINT), (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS)); // Set the take profit for the request
         request.sl = NormalizeDouble(request.price + spread * SymbolInfoDouble(symbol, SYMBOL_POINT), (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS)); // Set the stop loss for the request
        }
     }

   // BuildPosition: Function to build a position
   void              BuildPosition(
      MqlTradeRequest& request, // Request to build
      ENUM_POSITION_TYPE order_type, // Order type for the request
      ENUM_ORDER_TYPE_FILLING filling_mode, // Filling mode for the request
      double price_ask, // Ask price for the request
      double price_bid // Bid price for the request
   )
     {
      ZeroMemory(request); // Clear the memory for the request

      request.action = TRADE_ACTION_DEAL; // Set the action for the request
      request.symbol = symbol; // Set the symbol for the request
      request.type = ENUM_ORDER_TYPE(order_type); // Set the order type for the request
      request.volume = roundVolume(lot_size); // Set the volume for the request
      request.deviation = deviation_trade; // Set the deviation for the request
      request.magic = magic_number; // Set the magic number for the request
      request.type_filling = filling_mode; // Set the filling mode for the request

      // If the order type is POSITION_TYPE_BUY
      if(order_type == POSITION_TYPE_BUY)
        {
         request.price = price_ask; // Set the price for the request
         request.tp = NormalizeDouble(request.price + take_profit * SymbolInfoDouble(symbol, SYMBOL_POINT), (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS)); // Set the take profit for the request
         request.sl = NormalizeDouble(request.price - stop_loss * SymbolInfoDouble(symbol, SYMBOL_POINT), (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS)); // Set the stop loss for the request
        }
      // If the order type is not POSITION_TYPE_BUY
      else
        {
         request.price = price_bid; // Set the price for the request
         request.tp = NormalizeDouble(request.price - take_profit * SymbolInfoDouble(symbol, SYMBOL_POINT), (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS)); // Set the take profit for the request
         request.sl = NormalizeDouble(request.price + stop_loss * SymbolInfoDouble(symbol, SYMBOL_POINT), (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS)); // Set the stop loss for the request
        }
     }

   // Function to build a pending order
   void              BuildPending(
      MqlTradeRequest& request, // Request to build
      ENUM_ORDER_PENDING_TYPE order_pending_type, // Pending order type for the request
      ENUM_ORDER_TYPE_FILLING filling_mode, // Filling mode for the request
      double open_price, // Open price for the request
      double price_ask, // Ask price for the request
      double price_bid // Bid price for the request
   )
     {
      ZeroMemory(request); // Clear the memory for the request

      // Set the properties for the request
      request.symbol = symbol;
      request.volume = roundVolume(lot_size);
      request.price = open_price;
      request.deviation = deviation_trade;
      request.magic = magic_number;
      request.type_filling = filling_mode;

      // If the pending order type is ORDER_PENDING_TYPE_BUY
      if(order_pending_type == ORDER_PENDING_TYPE_BUY)
        {
         // Set the stop loss and take profit for the request
         request.sl = NormalizeDouble(request.price - stop_loss * SymbolInfoDouble(symbol, SYMBOL_POINT), (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS));
         request.tp = NormalizeDouble(request.price + take_profit * SymbolInfoDouble(symbol, SYMBOL_POINT), (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS));

         // Set the buy pending order action type for the request
         setBuyPendingOrderActionType(request, price_ask);
        }
      else // If the pending order type is not ORDER_PENDING_TYPE_BUY
        {
         // Set the stop loss and take profit for the request
         request.sl = NormalizeDouble(request.price + stop_loss * SymbolInfoDouble(symbol, SYMBOL_POINT), (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS));
         request.tp = NormalizeDouble(request.price - take_profit * SymbolInfoDouble(symbol, SYMBOL_POINT), (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS));
         
         // Set the sell pending order action type for the request
         setSellPendingOrderActionType(request, price_bid);
        }
     }

   // Function to build a pending or position order
   void              BuildPendingOrPosition(
      MqlTradeRequest& request, // Request to build
      ENUM_ORDER_PENDING_TYPE order_pending_type, // Pending order type for the request
      ENUM_ORDER_TYPE_FILLING filling_mode, // Filling mode for the request
      double open_price, // Open price for the request
      double comparative_price
   )
     {
      BuildPending(request, order_pending_type, filling_mode, open_price, comparative_price, comparative_price);

      MqlTradeCheckResult check_result;

      if(OrderCheck(request, check_result))
         return;

      if(check_result.retcode != TRADE_RETCODE_INVALID_PRICE)
         return;

      BuildPosition(request, ENUM_POSITION_TYPE(order_pending_type), filling_mode, SymbolInfoDouble(symbol, SYMBOL_ASK), SymbolInfoDouble(symbol, SYMBOL_BID));
     }

private:

   // Private methods and variables

   // Function to round the volume to the nearest step
   double            roundVolume(double volume)
     {
      // Get the volume step for the symbol
      double volume_step = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);

      // Return the rounded volume
      return MathRound(volume / volume_step) * volume_step;
     }

   // Function to set the action type for a buy pending order
   void              setBuyPendingOrderActionType(MqlTradeRequest& request, double& current_price)
     {
      // Set the action for the request to TRADE_ACTION_PENDING
      request.action = TRADE_ACTION_PENDING;

      // If the current price is greater than the request price
      if(current_price > request.price)
         // Set the type for the request to ORDER_TYPE_BUY_LIMIT
         request.type = ORDER_TYPE_BUY_LIMIT;
      else
         // Set the type for the request to ORDER_TYPE_BUY_STOP
         request.type = ORDER_TYPE_BUY_STOP;
     }

   // Function to set the action type for a sell pending order
   void              setSellPendingOrderActionType(MqlTradeRequest& request, double& current_price)
     {
      // Set the action for the request to TRADE_ACTION_PENDING
      request.action = TRADE_ACTION_PENDING;

      // If the current price is greater than the request price
      if(current_price > request.price)
         // Set the type for the request to ORDER_TYPE_SELL_STOP
         request.type = ORDER_TYPE_SELL_STOP;
      else
         // Set the type for the request to ORDER_TYPE_SELL_LIMIT
         request.type = ORDER_TYPE_SELL_LIMIT;
     }

public:

   // Constructor for the Request class
                     Request(
      string symbol_arg, // Symbol for the request
      double lot_size_arg, // Lot size for the request
      uint take_profit_arg, // Take profit for the request
      uint stop_loss_arg, // Stop loss for the request
      uint deviation_trade_arg, // Deviation trade for the request
      ulong magic_number_arg // Magic number for the request
   )
     {
      // Set the properties for the request
      symbol = symbol_arg;
      lot_size = lot_size_arg;
      take_profit = take_profit_arg;
      stop_loss = stop_loss_arg;
      deviation_trade = deviation_trade_arg;
      magic_number = magic_number_arg;
     }
  };
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
