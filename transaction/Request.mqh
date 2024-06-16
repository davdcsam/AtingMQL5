//+------------------------------------------------------------------+
//|                                                          Request |
//|                                         Copyright 2024, DavdCsam |
//|                                      https://github.com/davdcsam |
//+------------------------------------------------------------------+
#include <Arrays/ArrayDouble.mqh>


// ENUM_ORDER_PENDING_TYPE: Enum to handle different types of pending orders
enum ENUM_ORDER_PENDING_TYPE
  {
   ORDER_PENDING_TYPE_BUY = POSITION_TYPE_BUY, // Buy
   ORDER_PENDING_TYPE_SELL = POSITION_TYPE_SELL // Sell
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class RoundVolume
  {
public:
   string            symbol;

                     RoundVolume() {}
   void              SetSymbol(string& symbol_arg) {symbol = symbol_arg; }

   // Function to round the volume to the nearest step
   double            Run(double volume)
     {
      // Get the volume step for the symbol
      double volume_step = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);

      // Return the rounded volume
      return MathRound(volume / volume_step) * volume_step;
     }
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CalcStop
  {
protected:
   enum ENUM_STOP_TYPE
     {
      TAKE_PROFIT,
      STOP_LOSS
     };

   double            internal(double price, ulong stop, ENUM_POSITION_TYPE type, ENUM_STOP_TYPE stop_type)
     {
      return (type == POSITION_TYPE_BUY) ?
             (
                (stop_type == TAKE_PROFIT) ?
                NormalizeDouble(price + stop * SymbolInfoDouble(symbol, SYMBOL_POINT), (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS)):
                NormalizeDouble(price - stop * SymbolInfoDouble(symbol, SYMBOL_POINT), (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS))
             ):
             (
                (stop_type == TAKE_PROFIT) ?
                NormalizeDouble(price - stop * SymbolInfoDouble(symbol, SYMBOL_POINT), (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS)):
                NormalizeDouble(price + stop * SymbolInfoDouble(symbol, SYMBOL_POINT), (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS))
             );
     }

public:
   string            symbol;

                     CalcStop() {}
   void              SetSymbol(string& symbol_arg) {symbol = symbol_arg; }

   double            Run(double price, long stop, ENUM_ORDER_PENDING_TYPE type, ENUM_STOP_TYPE stop_type) { return internal(price, stop, ENUM_POSITION_TYPE(type), stop_type); }

   double            Run(double price, long stop, ENUM_POSITION_TYPE type, ENUM_STOP_TYPE stop_type) { return internal(price, stop, type, stop_type); }

   static bool              VerifyNoNegative(double price) { return price > 0 ? true : false; }

   static bool              VerifyNoNegative(double &prices[])
     {
      int size = (int)prices.Size();

      if(!size)
         return false;

      for(int i=0;i<size;i++)
        {
         if(prices[i] <= 0)
            return false;
        }
      return true;
     }

   static bool              VerifyNoNegative(CArrayDouble &prices)
     {
      int size = (int)prices.Total();

      if(!size)
         return false;

      for(int i=0;i<size;i++)
        {
         if(prices.At(i) <= 0)
            return false;
        }
      return true;
     }

  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

// Request: Class to handle request operations
class Request
  {
protected:
   enum ENUM_PRIVATE_ATR_STRING
     {
      SYMBOL,
     };

   enum ENUM_PRIVATE_ATR_DOUBLE
     {
      LOT_SIZE,
     };

   enum ENUM_PRIVATE_ATR_ULONG
     {
      TAKE_PROFIT,
      STOP_LOSS,
      DEVIATION_TRADE,
      MAGIC_NUMBER
     };

   string            symbol; // Symbol for the request
   double            lotSize; // Lot size for the request
   ulong              takeProfit; // Take profit for the request
   ulong              stopLoss; // Stop loss for the request
   ulong              deviationTrade; // Deviation trade for the request
   ulong             magicNumber; // Magic number for the request
   RoundVolume       roundVolume;
   CalcStop          calcStop;

   // BuildCheckPosition: Function to build a check position
   void              BuildCheckPosition(
      MqlTradeRequest& request, // Request to build
      ENUM_POSITION_TYPE type, // Order type for the request
      ENUM_ORDER_TYPE_FILLING filling_mode, // Filling mode for the request
      double& price_ask, // Ask price for the request
      double& price_bid // Bid price for the request
   )
     {
      ZeroMemory(request); // Clear the memory for the request

      long spread = SymbolInfoInteger(symbol, SYMBOL_SPREAD) * 2; // Calculate the spread

      request.action = TRADE_ACTION_DEAL; // Set the action for the request
      request.symbol = symbol; // Set the symbol for the request
      request.type = ENUM_ORDER_TYPE(type); // Set the order type for the request
      request.volume = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN); // Set the volume for the request
      request.deviation = spread; // Set the deviation for the request
      request.magic = magicNumber; // Set the magic number for the request
      request.type_filling = filling_mode; // Set the filling mode for the request

      // If the order type is POSITION_TYPE_BUY
      if(type == POSITION_TYPE_BUY)
        {
         request.price = price_ask; // Set the price for the request
         request.tp = NormalizeDouble(request.price + spread * SymbolInfoDouble(symbol, SYMBOL_POINT), (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS)); // Set the take profit for the request
         request.sl = NormalizeDouble(request.price - spread  * SymbolInfoDouble(symbol, SYMBOL_POINT), (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS)); // Set the stop loss for the request
         return;
        }

      // If the order type is not POSITION_TYPE_BUY
      request.price = price_bid; // Set the price for the request
      request.tp = NormalizeDouble(request.price - spread * SymbolInfoDouble(symbol, SYMBOL_POINT), (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS)); // Set the take profit for the request
      request.sl = NormalizeDouble(request.price + spread * SymbolInfoDouble(symbol, SYMBOL_POINT), (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS)); // Set the stop loss for the request
     }

   // BuildPosition: Function to build a position
   void              BuildPosition(
      MqlTradeRequest& request, // Request to build
      ENUM_POSITION_TYPE type, // Position type for the request
      ENUM_ORDER_TYPE_FILLING filling_mode // Filling mode for the request
   )
     {
      ZeroMemory(request); // Clear the memory for the request

      request.action = TRADE_ACTION_DEAL; // Set the action for the request
      request.symbol = symbol; // Set the symbol for the request
      request.type = ENUM_ORDER_TYPE(type); // Set the order type for the request
      request.volume = roundVolume.Run(lotSize); // Set the volume for the request
      request.deviation = deviationTrade; // Set the deviation for the request
      request.magic = magicNumber; // Set the magic number for the request
      request.type_filling = filling_mode; // Set the filling mode for the request

      // If the order type is POSITION_TYPE_BUY
      if(type == POSITION_TYPE_BUY)
        {
         request.price = SymbolInfoDouble(symbol, SYMBOL_ASK); // Set the price for the request
         request.tp = calcStop.Run(request.price, takeProfit, type, CalcStop::TAKE_PROFIT); // Set the take profit for the request
         request.sl = calcStop.Run(request.price, stopLoss, type, CalcStop::STOP_LOSS); // Set the stop loss for the request
         return;
        }

      // If the order type is not POSITION_TYPE_BUY
      request.price = SymbolInfoDouble(symbol, SYMBOL_BID); // Set the price for the request
      request.tp = calcStop.Run(request.price, takeProfit, type, CalcStop::TAKE_PROFIT); // Set the take profit for the request
      request.sl = calcStop.Run(request.price, stopLoss, type, CalcStop::STOP_LOSS); // Set the stop loss for the request

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
      request.volume = roundVolume.Run(lotSize);
      request.price = open_price;
      request.deviation = deviationTrade;
      request.magic = magicNumber;
      request.type_filling = filling_mode;

      // If the pending order type is ORDER_PENDING_TYPE_BUY
      if(order_pending_type == ORDER_PENDING_TYPE_BUY)
        {
         // Set the stop loss and take profit for the request
         request.tp = calcStop.Run(request.price, takeProfit, ORDER_PENDING_TYPE_BUY, CalcStop::TAKE_PROFIT); // Set the take profit for the request
         request.sl = calcStop.Run(request.price, stopLoss, ORDER_PENDING_TYPE_BUY, CalcStop::STOP_LOSS); // Set the stop loss for the request

         // Set the buy pending order action type for the request
         setBuyPendingOrderActionType(request, price_ask);

         return;
        }

      // If the pending order type is not ORDER_PENDING_TYPE_BUY

      // Set the stop loss and take profit for the request
      request.tp = calcStop.Run(request.price, takeProfit, ORDER_PENDING_TYPE_SELL, CalcStop::TAKE_PROFIT); // Set the take profit for the request
      request.sl = calcStop.Run(request.price, stopLoss, ORDER_PENDING_TYPE_SELL, CalcStop::STOP_LOSS); // Set the stop loss for the request

      // Set the sell pending order action type for the request
      setSellPendingOrderActionType(request, price_bid);

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

      BuildPosition(request, ENUM_POSITION_TYPE(order_pending_type), filling_mode);
     }

private:

   // Private methods and variables

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
                     Request() {}
   void              UpdateAtr(
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
      lotSize = lot_size_arg;
      takeProfit = take_profit_arg;
      stopLoss = stop_loss_arg;
      deviationTrade = deviation_trade_arg;
      magicNumber = magic_number_arg;

      roundVolume.SetSymbol(symbol);
      calcStop.SetSymbol(symbol);
     }

   string            GetPrivateAtr(ENUM_PRIVATE_ATR_STRING atr)
     {
      switch(atr)
        {
         case SYMBOL:
            return symbol;
            break;
        }

      return "";
     }

   double            GetPrivateAtr(ENUM_PRIVATE_ATR_DOUBLE atr)
     {
      switch(atr)
        {
         case LOT_SIZE:
            return lotSize;
            break;
        }

      return 0;
     }

   ulong             GetPrivateAtr(ENUM_PRIVATE_ATR_ULONG atr)
     {
      ulong result;

      switch(atr)
        {
         case TAKE_PROFIT:
            result = takeProfit;
            break;
         case STOP_LOSS:
            result = stopLoss;
            break;
         case DEVIATION_TRADE:
            result = deviationTrade;
            break;
         case MAGIC_NUMBER:
            result = magicNumber;
            break;
         default:
            result = 0;
            break;
        }

      return result;
     }

  };
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
