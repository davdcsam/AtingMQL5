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

   struct Setting
     {
      string            symbol; /**< Symbol of the asset */
      double            lotSize; /**< Lot size for the order */
      ulong             takeProfit, stopLoss, deviationTrade, magicNumber; /**< Order parameters */
     };

protected:
   Setting           setting;

   RoundVolume*       roundVolume; /**< Instance of RoundVolume class */
   CalcStop*          calcStop; /**< Instance of CalcStop class */

public:

   /**
    * @brief Default constructor for the Request class.
    */
                     Request(RoundVolume* rV, CalcStop* cS);

   /**
    * @brief Updates the attributes of the request.
    * @param symbolArg Symbol of the asset.
    * @param lotSizeArg Lot size.
    * @param takeProfitArg Take profit value.
    * @param stopLossArg Stop loss value.
    * @param deviationTradeArg Deviation trade value.
    * @param magicNumberArg Magic number for the order.
    */
   void              UpdateSetting(string sym, double lot, uint tp, uint sl, uint dev, ulong magic);

   void              GetSetting(Setting& s);
   Setting           GetSetting(void) const;

   bool              CheckSetting();

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
void Request::UpdateSetting(string sym, double lot, uint tp, uint sl, uint dev, ulong magic)
  {
   this.setting.symbol = sym;
   this.setting.lotSize = lot;
   this.setting.magicNumber = magic;
   this.setting.takeProfit = tp;
   this.setting.stopLoss = sl;
   this.setting.deviationTrade = dev;
  }

//+------------------------------------------------------------------+
void Request::GetSetting(Request::Setting& s)
  { s = this.setting; }

//+------------------------------------------------------------------+
Request::Setting Request::GetSetting(void) const
  { return this.setting; }

//+------------------------------------------------------------------+
void Request::BuildCheckPosition(MqlTradeRequest& request, ENUM_POSITION_TYPE type, ENUM_ORDER_TYPE_FILLING filling)
  {
   ZeroMemory(request);

   request.action = TRADE_ACTION_DEAL;
   request.symbol = this.setting.symbol;
   request.type = ENUM_ORDER_TYPE(type);
   request.volume = SymbolInfoDouble(this.setting.symbol, SYMBOL_VOLUME_MIN);
   request.deviation = SymbolInfoInteger(this.setting.symbol, SYMBOL_SPREAD) * 2;
   request.magic = this.setting.magicNumber;
   request.type_filling = filling;
   request.price = (type == POSITION_TYPE_BUY) ? SymbolInfoDouble(this.setting.symbol, SYMBOL_ASK) : SymbolInfoDouble(this.setting.symbol, SYMBOL_BID);
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
   request.symbol = this.setting.symbol;
   request.type = ENUM_ORDER_TYPE(type);
   request.volume = roundVolume.Run(this.setting.lotSize);
   request.deviation = this.setting.deviationTrade;
   request.magic = this.setting.magicNumber;
   request.type_filling = filling;
   request.price = (type == POSITION_TYPE_BUY) ? SymbolInfoDouble(this.setting.symbol, SYMBOL_ASK) : SymbolInfoDouble(this.setting.symbol, SYMBOL_BID);
   if(this.setting.takeProfit != 0)
      request.tp = calcStop.Run(request.price, this.setting.takeProfit, type, CalcStop::TAKE_PROFIT);
   if(this.setting.stopLoss != 0)
      request.sl = calcStop.Run(request.price, this.setting.stopLoss, type, CalcStop::STOP_LOSS);
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
   request.symbol = this.setting.symbol;
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
   request.volume = roundVolume.Run(this.setting.lotSize);
   request.deviation = this.setting.deviationTrade;
   request.magic = this.setting.magicNumber;
   request.type_filling = filling;
   request.price = price;
   if(expiration != 0 && TimeTradeServer() < expiration)
     {
      request.type_time = ORDER_TIME_SPECIFIED;
      request.expiration = expiration;
     }
   if(this.setting.takeProfit != 0)
      request.tp = calcStop.Run(request.price, this.setting.takeProfit, (ENUM_POSITION_TYPE)type, CalcStop::TAKE_PROFIT);
   if(this.setting.stopLoss != 0)
      request.sl = calcStop.Run(request.price, this.setting.stopLoss, (ENUM_POSITION_TYPE)type, CalcStop::STOP_LOSS);
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
   request.symbol = this.setting.symbol;
   request.type = (ENUM_ORDER_TYPE)type;
   request.volume = roundVolume.Run(this.setting.lotSize);
   request.deviation = this.setting.deviationTrade;
   request.magic = this.setting.magicNumber;
   request.type_filling = filling;
   request.price = price;
   if(expiration != 0 && TimeTradeServer() < expiration)
     {
      request.type_time = ORDER_TIME_SPECIFIED;
      request.expiration = expiration;
     }
   if(this.setting.takeProfit != 0)
      request.tp = calcStop.Run(
                      request.price,
                      this.setting.takeProfit,
                      (type == ENUM_ORDER_TYPE_AVAILABLE::ORDER_TYPE_BUY_LIMIT || type == ENUM_ORDER_TYPE_AVAILABLE::ORDER_TYPE_BUY_STOP ? POSITION_TYPE_BUY : POSITION_TYPE_SELL),
                      CalcStop::TAKE_PROFIT
                   );
   if(this.setting.stopLoss != 0)
      request.sl = calcStop.Run(
                      request.price,
                      this.setting.stopLoss,
                      (type == ENUM_ORDER_TYPE_AVAILABLE::ORDER_TYPE_BUY_LIMIT || type == ENUM_ORDER_TYPE_AVAILABLE::ORDER_TYPE_BUY_STOP ? POSITION_TYPE_BUY : POSITION_TYPE_SELL),
                      CalcStop::STOP_LOSS
                   );
  }
//+------------------------------------------------------------------+
