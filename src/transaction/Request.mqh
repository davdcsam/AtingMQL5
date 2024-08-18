//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+
#include "CalcStop.mqh"
#include "RoundVolume.mqh"

//+------------------------------------------------------------------+
/**
 * @class Request
 * @brief Class to handle trade requests.
 */
class Request
  {
public:
   /**
    * @enum ENUM_ORDER_TYPE_BASE
    * @brief Enum for base order types.
    */
   enum ENUM_ORDER_TYPE_BASE
     {
      ORDER_TYPE_BUY = POSITION_TYPE_BUY, /**< Buy order type */
      ORDER_TYPE_SELL = POSITION_TYPE_SELL /**< Sell order type */
     };

   /**
    * @enum ENUM_ORDER_TYPE_AVAILABLE
    * @brief Enum for available order types.
    */
   enum ENUM_ORDER_TYPE_AVAILABLE
     {
      ORDER_TYPE_BUY_LIMIT = ENUM_ORDER_TYPE::ORDER_TYPE_BUY_LIMIT, /**< Buy limit order type */
      ORDER_TYPE_BUY_STOP = ENUM_ORDER_TYPE::ORDER_TYPE_BUY_STOP, /**< Buy stop order type */
      ORDER_TYPE_SELL_LIMIT = ENUM_ORDER_TYPE::ORDER_TYPE_SELL_LIMIT, /**< Sell limit order type */
      ORDER_TYPE_SELL_STOP = ENUM_ORDER_TYPE::ORDER_TYPE_SELL_STOP /**< Sell stop order type */
     };

   /**
    * @enum ENUM_PRIVATE_ATR_STRING
    * @brief Enum for private string attributes.
    */
   enum ENUM_PRIVATE_ATR_STRING { SYMBOL }; /**< Symbol attribute */

   /**
    * @enum ENUM_PRIVATE_ATR_DOUBLE
    * @brief Enum for private double attributes.
    */
   enum ENUM_PRIVATE_ATR_DOUBLE { LOT_SIZE }; /**< Lot size attribute */

   /**
    * @enum ENUM_PRIVATE_ATR_ULONG
    * @brief Enum for private ulong attributes.
    */
   enum ENUM_PRIVATE_ATR_ULONG { TAKE_PROFIT, STOP_LOSS, DEVIATION_TRADE, MAGIC_NUMBER }; /**< Various ulong attributes */

   string            symbol; /**< Symbol of the asset */
   double            lotSize; /**< Lot size for the order */
   ulong             takeProfit, stopLoss, deviationTrade, magicNumber; /**< Order parameters */
   RoundVolume       roundVolume; /**< Instance of RoundVolume class */
   CalcStop          calcStop; /**< Instance of CalcStop class */

   /**
    * @brief Default constructor for the Request class.
    */
                     Request() {}

   /**
    * @brief Updates the attributes of the request.
    * @param symbolArg Symbol of the asset.
    * @param lotSizeArg Lot size.
    * @param takeProfitArg Take profit value.
    * @param stopLossArg Stop loss value.
    * @param deviationTradeArg Deviation trade value.
    * @param magicNumberArg Magic number for the order.
    */
   void              UpdateAtr(string symbolArg, double lotSizeArg, uint takeProfitArg, uint stopLossArg, uint deviationTradeArg, ulong magicNumberArg);

   /**
    * @brief Gets the private string attribute.
    * @param atr Attribute to get.
    * @return The requested attribute value.
    */
   string            GetPrivateAtr(ENUM_PRIVATE_ATR_STRING atr);

   /**
    * @brief Gets the private double attribute.
    * @param atr Attribute to get.
    * @return The requested attribute value.
    */
   double            GetPrivateAtr(ENUM_PRIVATE_ATR_DOUBLE atr);

   /**
    * @brief Gets the private ulong attribute.
    * @param atr Attribute to get.
    * @return The requested attribute value.
    */
   ulong             GetPrivateAtr(ENUM_PRIVATE_ATR_ULONG atr);

   /**
    * @brief Builds a check position.
    * @param request Trade request structure.
    * @param type Position type.
    * @param filling Order filling type.
    */
   void              BuildCheckPosition(MqlTradeRequest& request, ENUM_POSITION_TYPE type, ENUM_ORDER_TYPE_FILLING filling);

   /**
    * @brief Builds a position.
    * @param request Trade request structure.
    * @param type Position type.
    * @param filling Order filling type.
    */
   void              BuildPosition(MqlTradeRequest& request, ENUM_POSITION_TYPE type, ENUM_ORDER_TYPE_FILLING filling);

   /**
    * @brief Builds a pending order.
    * @param request Trade request structure.
    * @param type Pending order type.
    * @param filling Order filling type.
    * @param price Price for the pending order.
    * @param expiration Expiration time for the pending order (default is 0).
    */
   void              BuildPending(MqlTradeRequest& request, ENUM_ORDER_TYPE_BASE type, ENUM_ORDER_TYPE_FILLING filling, double price, datetime expiration = 0);

   /**
    * @brief Builds a pending order or position.
    * @param request Trade request structure.
    * @param type Pending order type.
    * @param filling Order filling type.
    * @param price Price for the pending order.
    * @param expiration Expiration time for the pending order (default is 0).
    */
   void              BuildPendingOrPosition(MqlTradeRequest& request, ENUM_ORDER_TYPE_AVAILABLE type, ENUM_ORDER_TYPE_FILLING filling, double price, datetime expiration = 0);
  };

//+------------------------------------------------------------------+
void Request::UpdateAtr(string symbolArg, double lotSizeArg, uint takeProfitArg, uint stopLossArg, uint deviationTradeArg, ulong magicNumberArg)
  {
   symbol = symbolArg;
   lotSize = lotSizeArg;
   takeProfit = takeProfitArg;
   stopLoss = stopLossArg;
   deviationTrade = deviationTradeArg;
   magicNumber = magicNumberArg;

   roundVolume.SetSymbol(symbol);
   calcStop.SetSymbol(symbol);
  }

//+------------------------------------------------------------------+
string Request::GetPrivateAtr(ENUM_PRIVATE_ATR_STRING atr)
  {
   if(atr == SYMBOL)
      return symbol;
   return "";
  }

//+------------------------------------------------------------------+
double Request::GetPrivateAtr(ENUM_PRIVATE_ATR_DOUBLE atr)
  {
   if(atr == LOT_SIZE)
      return lotSize;
   return 0;
  }

//+------------------------------------------------------------------+
ulong Request::GetPrivateAtr(ENUM_PRIVATE_ATR_ULONG atr)
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

//+------------------------------------------------------------------+
void Request::BuildCheckPosition(MqlTradeRequest& request, ENUM_POSITION_TYPE type, ENUM_ORDER_TYPE_FILLING filling)
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

//+------------------------------------------------------------------+
void Request::BuildPosition(MqlTradeRequest& request, ENUM_POSITION_TYPE type, ENUM_ORDER_TYPE_FILLING filling)
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

//+------------------------------------------------------------------+
void Request::BuildPending(MqlTradeRequest& request, ENUM_ORDER_TYPE_BASE type, ENUM_ORDER_TYPE_FILLING filling, double price, datetime expiration = 0)
  {
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   /*
   If price filled order
   */
   if(
      (type == ENUM_ORDER_TYPE_BASE::ORDER_TYPE_BUY && price == ask)
      ||
      (type == ENUM_ORDER_TYPE_BASE::ORDER_TYPE_SELL && price == bid)
   )
     {
      BuildPosition(request, ENUM_POSITION_TYPE(type), filling);
      return;
     }

   ZeroMemory(request);
   request.action = TRADE_ACTION_PENDING;
   request.symbol = symbol;
   switch(type)
     {
      case ORDER_TYPE_BUY:
         request.type = ask > price ?
                        ENUM_ORDER_TYPE::ORDER_TYPE_BUY_LIMIT :
                        ENUM_ORDER_TYPE::ORDER_TYPE_BUY_STOP;
         break;
      case ORDER_TYPE_SELL:
         request.type = bid > price ?
                        ENUM_ORDER_TYPE::ORDER_TYPE_SELL_STOP :
                        ENUM_ORDER_TYPE::ORDER_TYPE_SELL_LIMIT;
         break;
     }
   request.volume = roundVolume.Run(lotSize);
   request.deviation = deviationTrade;
   request.magic = magicNumber;
   request.type_filling = filling;
   request.price = price;
   if(expiration != 0 && TimeTradeServer() < expiration)
     {
      request.type_time = ORDER_TIME_SPECIFIED;
      request.expiration = expiration;
     }
   if(takeProfit != 0)
      request.tp = calcStop.Run(request.price, takeProfit, (ENUM_POSITION_TYPE)type, CalcStop::TAKE_PROFIT);
   if(stopLoss != 0)
      request.sl = calcStop.Run(request.price, stopLoss, (ENUM_POSITION_TYPE)type, CalcStop::STOP_LOSS);
  }

//+------------------------------------------------------------------+
void Request::BuildPendingOrPosition(MqlTradeRequest& request, ENUM_ORDER_TYPE_AVAILABLE type, ENUM_ORDER_TYPE_FILLING filling, double price, datetime expiration = 0)
  {
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   /*
   Current price passed type on any order type
   It seems illogical as all the following statements should be false,
   but in a higher delay could cause param type was assign an incorrect type.
   */
   if(
      (type == ENUM_ORDER_TYPE_AVAILABLE::ORDER_TYPE_SELL_LIMIT && bid >= price)
      ||
      (type == ENUM_ORDER_TYPE_AVAILABLE::ORDER_TYPE_BUY_STOP && ask >= price)
      ||
      (type == ENUM_ORDER_TYPE_AVAILABLE::ORDER_TYPE_BUY_LIMIT && ask <= price)
      ||
      (type == ENUM_ORDER_TYPE_AVAILABLE::ORDER_TYPE_SELL_STOP && bid <= price)
   )
     {
      BuildPosition(request, (type == ENUM_ORDER_TYPE_AVAILABLE::ORDER_TYPE_BUY_LIMIT || type == ENUM_ORDER_TYPE_AVAILABLE::ORDER_TYPE_BUY_STOP ? POSITION_TYPE_BUY : POSITION_TYPE_SELL), filling);
      return;
     }

   ZeroMemory(request);
   request.action = TRADE_ACTION_PENDING;
   request.symbol = symbol;
   request.type = (ENUM_ORDER_TYPE)type;
   request.volume = roundVolume.Run(lotSize);
   request.deviation = deviationTrade;
   request.magic = magicNumber;
   request.type_filling = filling;
   request.price = price;
   if(expiration != 0 && TimeTradeServer() < expiration)
     {
      request.type_time = ORDER_TIME_SPECIFIED;
      request.expiration = expiration;
     }
   if(takeProfit != 0)
      request.tp = calcStop.Run(
                      request.price,
                      takeProfit,
                      (type == ENUM_ORDER_TYPE_AVAILABLE::ORDER_TYPE_BUY_LIMIT || type == ENUM_ORDER_TYPE_AVAILABLE::ORDER_TYPE_BUY_STOP ? POSITION_TYPE_BUY : POSITION_TYPE_SELL),
                      CalcStop::TAKE_PROFIT
                   );
   if(stopLoss != 0)
      request.sl = calcStop.Run(
                      request.price,
                      stopLoss,
                      (type == ENUM_ORDER_TYPE_AVAILABLE::ORDER_TYPE_BUY_LIMIT || type == ENUM_ORDER_TYPE_AVAILABLE::ORDER_TYPE_BUY_STOP ? POSITION_TYPE_BUY : POSITION_TYPE_SELL),
                      CalcStop::STOP_LOSS
                   );
  }
//+------------------------------------------------------------------+
