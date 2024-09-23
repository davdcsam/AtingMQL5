//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+
#include "AtingErr.mqh"

//+------------------------------------------------------------------+
class SystemRequirements
  {
public:

   // Account

   static bool       AccountTradeMode(ENUM_ACCOUNT_TRADE_MODE required = ACCOUNT_TRADE_MODE_DEMO)
     {
      if(AccountInfoInteger(ACCOUNT_TRADE_MODE) != required)
        {
         SetLastAtingErr(ATING_ERR_ACCOUNT_INVALID_TRADE_MODE);
         return false;
        }
      return true;
     }

   static bool       AccountLimitOrders(int maxOrders = 100)
     {
      if(AccountInfoInteger(ACCOUNT_LIMIT_ORDERS) > maxOrders)
        {
         SetLastAtingErr(ATING_ERR_ACCOUNT_INVALID_LIMIT_ORDERS);
         return false;
        }
      return true;
     }

   static bool       AccountCommon(void)
     {
      if(!AccountInfoInteger(ACCOUNT_TRADE_EXPERT))
        {
         SetLastAtingErr(ATING_ERR_ACCOUNT_PROHIBITED_BOT);
         return false;
        }

      if(!AccountInfoInteger(ACCOUNT_TRADE_ALLOWED))
        {
         SetLastAtingErr(ATING_ERR_ACCOUNT_PROHIBITED_TRADE);
         return false;
        }

      if(!AccountInfoInteger(ACCOUNT_HEDGE_ALLOWED))
        {
         SetLastAtingErr(ATING_ERR_ACCOUNT_PROHIBITED_HEDGE);
         return false;
        }
      return true;
     }

   // Terminal

   static bool       TerminalCommon(void)
     {
      if(!MQLInfoInteger(MQL_TRADE_ALLOWED))
        {
         SetLastAtingErr(ATING_ERR_TERMINAL_MQL_PROHIBITED_TRADE);
         return false;
        }
      if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
        {
         SetLastAtingErr(ATING_ERR_TERMINAL_PROHIBITED_TRADE);
         return false;
        }
      return true;
     }

   // Symbol

   static bool       SymbolExpiration(string sym, int type)
     {
      int expiration=(int)SymbolInfoInteger(sym, SYMBOL_EXPIRATION_MODE);
      if((expiration&type)!=type)
        {
         SetLastAtingErr(ATING_ERR_SYMBOL_INVALID_EXPIRATION);
         return false;
        }
      return true;
     }

   static bool                 SymbolFilling(string sym, int type = SYMBOL_FILLING_FOK)
     {
      int filling=(int)SymbolInfoInteger(sym, SYMBOL_FILLING_MODE);
      if((filling&type)==type)
        {
         SetLastAtingErr(ATING_ERR_SYMBOL_INVALID_FILLING);
         return false;
        }
      return true;
     }

   static bool       SymbolOrderMode(string sym, int requiredMode = SYMBOL_ORDER_MARKET)
     {
      int orderMode = (int)SymbolInfoInteger(sym, SYMBOL_ORDER_MODE);
      if(orderMode != requiredMode)
        {
         SetLastAtingErr(ATING_ERR_SYMBOL_INVALID_ORDER_MODE);
         return false;
        }
      return true;
     }

   static bool       SymbolTradeExecution(string sym, int requiredMode = SYMBOL_TRADE_EXECUTION_MARKET)
     {
      int executionMode = (int)SymbolInfoInteger(sym, SYMBOL_TRADE_MODE);
      if(executionMode != requiredMode)
        {
         SetLastAtingErr(ATING_ERR_SYMBOL_INVALID_TRADE_EXECUTION);
         return false;
        }
      return true;
     }

   static bool       SymbolTradeMode(string sym, int requiredMode = SYMBOL_TRADE_MODE_FULL)
     {
      int tradeMode = (int)SymbolInfoInteger(sym, SYMBOL_TRADE_MODE);
      if(tradeMode != requiredMode)
        {
         SetLastAtingErr(ATING_ERR_SYMBOL_INVALID_TRADE_MODE);
         return false;
        }
      return true;
     }

   static bool       SymbolStops(string sym, double sl, double tp, ENUM_POSITION_TYPE type)
     {
      int stopsLevel = (int)SymbolInfoInteger(sym, SYMBOL_TRADE_STOPS_LEVEL);
      double point = SymbolInfoDouble(sym, SYMBOL_POINT);

      double slInPoints = sl / point;
      double tpInPoints = tp / point;

      double bid = SymbolInfoDouble(sym, SYMBOL_BID);
      double ask = SymbolInfoDouble(sym, SYMBOL_ASK);

      double bidInPoints = bid / point;
      double askInPoints = ask / point;

      bool slCheck = false, tpCheck = false;

      switch(type)
        {
         case POSITION_TYPE_BUY:
           {
            slCheck = (bidInPoints - slInPoints > stopsLevel);
            if(!slCheck)
              {
               SetLastAtingErr(ATING_ERR_SYMBOL_INVALID_STOPS);
               return false;
              }
            tpCheck = (tpInPoints - bidInPoints > stopsLevel);
            if(!tpCheck)
              {
               SetLastAtingErr(ATING_ERR_SYMBOL_INVALID_STOPS);
               return false;
              }
            return true;
           }

         case POSITION_TYPE_SELL:
           {
            slCheck = (slInPoints - askInPoints > stopsLevel);
            if(!slCheck)
              {
               SetLastAtingErr(ATING_ERR_SYMBOL_INVALID_STOPS);
               return false;
              }
            tpCheck = (askInPoints - tpInPoints > stopsLevel);
            if(!tpCheck)
              {
               SetLastAtingErr(ATING_ERR_SYMBOL_INVALID_STOPS);
               return false;
              }
            return true;
           }
         default:
            return false;
        }
     }


   static bool       SymbolCommon(string sym)
     {
      if(StringLen(sym) <= 0)
        {
         SetLastAtingErr(ATING_ERR_SETTING_EMPTY_VALUE);
         return false;
        }

      if(!SymbolInfoInteger(sym, SYMBOL_EXIST))
        {
         SetLastAtingErr(ATING_ERR_SYMBOL_NO_EXIST);
         return false;
        }

      if(SymbolInfoInteger(sym, SYMBOL_TRADE_MODE) != SYMBOL_TRADE_MODE_FULL)
        {
         SetLastAtingErr(ATING_ERR_SYMBOL_PROHIBITED_TRADE);
         return false;
        }
      return true;
     }
  };
//+------------------------------------------------------------------+
