//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+
#include "CalcStop.mqh"
#include "RoudVolume.mqh"

//+------------------------------------------------------------------+
class Request
  {

public:

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

   // Function to build a check position
   void              BuildCheckPosition(MqlTradeRequest& request, ENUM_POSITION_TYPE type, ENUM_ORDER_TYPE_FILLING filling)
     {
      ZeroMemory(request);

      request.action = TRADE_ACTION_DEAL;
      request.symbol = symbol;
      request.type = ENUM_ORDER_TYPE(type);
      request.volume = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
      request.deviation = SymbolInfoInteger(symbol, SYMBOL_SPREAD) * 2;
      request.magic = magicNumber;
      request.type_filling = filling;
      request.price = (type == POSITION_TYPE_BUY) ? SymbolInfoDouble(symbol, SYMBOL_ASK) : SymbolInfoDouble(symbol, SYMBOL_BID);
      if(request.deviation != 0)
        {
         request.tp = calcStop.Run(request.price, request.deviation, type, CalcStop::TAKE_PROFIT);
         request.sl = calcStop.Run(request.price, request.deviation, type, CalcStop::STOP_LOSS);
        }

     }

   // Function to build a position
   void              BuildPosition(MqlTradeRequest& request, ENUM_POSITION_TYPE type, ENUM_ORDER_TYPE_FILLING filling)
     {
      ZeroMemory(request);

      request.action = TRADE_ACTION_DEAL;
      request.symbol = symbol;
      request.type = ENUM_ORDER_TYPE(type);
      request.volume = roundVolume.Run(lotSize);
      request.deviation = deviationTrade;
      request.magic = magicNumber;
      request.type_filling = filling;
      request.price = (type == POSITION_TYPE_BUY) ? SymbolInfoDouble(symbol, SYMBOL_ASK) : SymbolInfoDouble(symbol, SYMBOL_BID);
      if(takeProfit != 0)
         request.tp = calcStop.Run(request.price, takeProfit, type, CalcStop::TAKE_PROFIT);
      if(stopLoss != 0)
         request.sl = calcStop.Run(request.price, stopLoss, type, CalcStop::STOP_LOSS);
     }

   // Function to build a pending order
   void              BuildPending(MqlTradeRequest& request, ENUM_ORDER_PENDING_TYPE type, ENUM_ORDER_TYPE_FILLING filling, double price)
     {
      ZeroMemory(request);

      request.action = TRADE_ACTION_PENDING;
      request.symbol = symbol;
      request.type = (type == ORDER_PENDING_TYPE_BUY) ?
                     ((SymbolInfoDouble(symbol, SYMBOL_ASK) > price) ? ORDER_TYPE_BUY_LIMIT : ORDER_TYPE_BUY_STOP) :
                     ((SymbolInfoDouble(symbol, SYMBOL_BID) > price) ? ORDER_TYPE_SELL_STOP : ORDER_TYPE_SELL_LIMIT);
      request.volume = roundVolume.Run(lotSize);
      request.deviation = deviationTrade;
      request.magic = magicNumber;
      request.type_filling = filling;
      request.price = price;
      if(takeProfit != 0)
         request.tp = calcStop.Run(request.price, takeProfit, (ENUM_POSITION_TYPE)type, CalcStop::TAKE_PROFIT);
      if(stopLoss != 0)
         request.sl = calcStop.Run(request.price, stopLoss, (ENUM_POSITION_TYPE)type, CalcStop::STOP_LOSS);

     }

   void              BuildPendingOrPosition(MqlTradeRequest& request, ENUM_ORDER_PENDING_TYPE type, ENUM_ORDER_TYPE_FILLING filling, double price)
     {
      BuildPending(request, type, filling, price);

      MqlTradeCheckResult check_result;
      if(OrderCheck(request, check_result) && check_result.retcode == TRADE_RETCODE_INVALID_PRICE)
         BuildPosition(request, ENUM_POSITION_TYPE(type), filling);
     }
  };
//+------------------------------------------------------------------+
