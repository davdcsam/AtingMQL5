//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+

#include "CalcStop.mqh"
#include "RoudVolume.mqh"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Request
  {
protected:
   enum ENUM_ORDER_PENDING_TYPE
     {
      ORDER_PENDING_TYPE_BUY = POSITION_TYPE_BUY,
      ORDER_PENDING_TYPE_SELL = POSITION_TYPE_SELL
     };

   enum ENUM_PRIVATE_ATR_STRING { SYMBOL };
   enum ENUM_PRIVATE_ATR_DOUBLE { LOT_SIZE };
   enum ENUM_PRIVATE_ATR_ULONG { TAKE_PROFIT, STOP_LOSS, DEVIATION_TRADE, MAGIC_NUMBER };

   string            symbol;
   double            lotSize;
   ulong             takeProfit, stopLoss, deviationTrade, magicNumber;
   RoundVolume       roundVolume;
   CalcStop          calcStop;

   // Function to build a check position
   void              BuildCheckPosition(MqlTradeRequest& request, ENUM_POSITION_TYPE type, ENUM_ORDER_TYPE_FILLING filling_mode, double price_ask, double price_bid)
     {
      ZeroMemory(request);
      long spread = SymbolInfoInteger(symbol, SYMBOL_SPREAD) * 2;

      request.action = TRADE_ACTION_DEAL;
      request.symbol = symbol;
      request.type = ENUM_ORDER_TYPE(type);
      request.volume = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
      request.deviation = spread;
      request.magic = magicNumber;
      request.type_filling = filling_mode;

      if(type == POSITION_TYPE_BUY)
        {
         request.price = price_ask;
         request.tp = NormalizeDouble(request.price + spread * SymbolInfoDouble(symbol, SYMBOL_POINT), (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS));
         request.sl = NormalizeDouble(request.price - spread * SymbolInfoDouble(symbol, SYMBOL_POINT), (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS));
        }
      else
        {
         request.price = price_bid;
         request.tp = NormalizeDouble(request.price - spread * SymbolInfoDouble(symbol, SYMBOL_POINT), (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS));
         request.sl = NormalizeDouble(request.price + spread * SymbolInfoDouble(symbol, SYMBOL_POINT), (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS));
        }
     }

   // Function to build a position
   void              BuildPosition(MqlTradeRequest& request, ENUM_POSITION_TYPE type, ENUM_ORDER_TYPE_FILLING filling_mode)
     {
      ZeroMemory(request);

      request.action = TRADE_ACTION_DEAL;
      request.symbol = symbol;
      request.type = ENUM_ORDER_TYPE(type);
      request.volume = roundVolume.Run(lotSize);
      request.deviation = deviationTrade;
      request.magic = magicNumber;
      request.type_filling = filling_mode;

      double current_price = (type == POSITION_TYPE_BUY) ? SymbolInfoDouble(symbol, SYMBOL_ASK) : SymbolInfoDouble(symbol, SYMBOL_BID);

      request.price = current_price;
      if(takeProfit != 0)
         request.tp = calcStop.Run(current_price, takeProfit, type, CalcStop::TAKE_PROFIT);
      if(stopLoss != 0)
         request.sl = calcStop.Run(current_price, stopLoss, type, CalcStop::STOP_LOSS);
     }

   // Function to build a pending order
   void              BuildPending(MqlTradeRequest& request, ENUM_ORDER_PENDING_TYPE order_pending_type, ENUM_ORDER_TYPE_FILLING filling_mode, double open_price, double current_price)
     {
      ZeroMemory(request);

      request.action = TRADE_ACTION_PENDING;
      request.symbol = symbol;
      request.volume = roundVolume.Run(lotSize);
      request.price = open_price;
      request.deviation = deviationTrade;
      request.magic = magicNumber;
      request.type_filling = filling_mode;

      ENUM_POSITION_TYPE position_type = (order_pending_type == ORDER_PENDING_TYPE_BUY) ? POSITION_TYPE_BUY : POSITION_TYPE_SELL;

      if(takeProfit != 0)
         request.tp = calcStop.Run(open_price, takeProfit, position_type, CalcStop::TAKE_PROFIT);
      if(stopLoss != 0)
         request.sl = calcStop.Run(open_price, stopLoss, position_type, CalcStop::STOP_LOSS);

      if(order_pending_type == ORDER_PENDING_TYPE_BUY)
         request.type = (current_price > open_price) ? ORDER_TYPE_BUY_LIMIT : ORDER_TYPE_BUY_STOP;
      else
         request.type = (current_price > open_price) ? ORDER_TYPE_SELL_STOP : ORDER_TYPE_SELL_LIMIT;

     }

   void              BuildPendingOrPosition(MqlTradeRequest& request, ENUM_ORDER_PENDING_TYPE order_pending_type, ENUM_ORDER_TYPE_FILLING filling_mode, double open_price, double comparative_price)
     {
      BuildPending(request, order_pending_type, filling_mode, open_price, comparative_price);

      MqlTradeCheckResult check_result;
      if(OrderCheck(request, check_result) && check_result.retcode == TRADE_RETCODE_INVALID_PRICE)
         BuildPosition(request, ENUM_POSITION_TYPE(order_pending_type), filling_mode);
     }

public:
   // Constructor for the Request class
                     Request() {}

   void              UpdateAtr(string symbol_arg, double lot_size_arg, uint take_profit_arg, uint stop_loss_arg, uint deviation_trade_arg, ulong magic_number_arg)
     {
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
      if(atr == SYMBOL)
         return symbol;
      return "";
     }

   double            GetPrivateAtr(ENUM_PRIVATE_ATR_DOUBLE atr)
     {
      if(atr == LOT_SIZE)
         return lotSize;
      return 0;
     }

   ulong             GetPrivateAtr(ENUM_PRIVATE_ATR_ULONG atr)
     {
      switch(atr)
        {
         case TAKE_PROFIT:
            return takeProfit;
         case STOP_LOSS:
            return stopLoss;
         case DEVIATION_TRADE:
            return deviationTrade;
         case MAGIC_NUMBER:
            return magicNumber;
         default:
            return 0;
        }
     }
  };
//+------------------------------------------------------------------+
