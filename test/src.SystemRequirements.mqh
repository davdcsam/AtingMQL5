//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+
#include <AtingMQL5/.mqh>

//+------------------------------------------------------------------+
void src_SystemRequirements()
  {
   TestTime tt;
   tt.Start();

   bool passAccountTradeMode = Test_AccountTradeMode();
   bool passAccountLimitOrders = Test_AccountLimitOrders();
   bool passAccountCommon = Test_AccountCommon();
   bool passTerminalCommon = Test_TerminalCommon();
   string symbol = _Symbol;
   bool passSymbolExpiration = Test_SymbolExpiration(symbol);
   bool passSymbolFilling = Test_SymbolFilling(symbol);
   bool passSymbolOrderMode = Test_SymbolOrderMode(symbol);
   bool passSymbolTradeExecution = Test_SymbolTradeExecution(symbol);
   bool passSymbolTradeMode = Test_SymbolTradeMode(symbol);
   bool passSymbolStops = Test_SymbolStops(symbol, 1, 1, POSITION_TYPE_BUY);
   bool passSymbolCommon = Test_SymbolCommon(symbol);

   bool allPassed = passAccountTradeMode && passAccountLimitOrders && passAccountCommon &&
                    passTerminalCommon && passSymbolExpiration && passSymbolFilling &&
                    passSymbolOrderMode && passSymbolTradeExecution && passSymbolTradeMode &&
                    passSymbolStops && passSymbolCommon;

   Print("Overall Test Result - All Tests Passed: ", allPassed);

   tt.End();
  }

//+------------------------------------------------------------------+
void PrintTestResultSystemRequirements(string testName, bool result)
  {
   Print(testName, " - Passed: ", result, "\n");
  }

//+------------------------------------------------------------------+
bool Test_AccountTradeMode()
  {
   ENUM_ACCOUNT_TRADE_MODE currentMode = (ENUM_ACCOUNT_TRADE_MODE)AccountInfoInteger(ACCOUNT_TRADE_MODE);

   if(currentMode == ACCOUNT_TRADE_MODE_DEMO)
      return SystemRequirements::AccountTradeMode();

   bool result = !SystemRequirements::AccountTradeMode(ACCOUNT_TRADE_MODE_REAL);
   if(!result)
      PrintLastAtingError();
   PrintTestResultSystemRequirements("Test_AccountTradeMode", result);
   return result;
  }

//+------------------------------------------------------------------+
bool Test_AccountLimitOrders()
  {
   int currentLimitOrders = (int)AccountInfoInteger(ACCOUNT_LIMIT_ORDERS);
   bool result = (currentLimitOrders <= 100)
                 ? SystemRequirements::AccountLimitOrders(100)
                 : !SystemRequirements::AccountLimitOrders(50);
   PrintTestResultSystemRequirements("Test_AccountLimitOrders", result);
   return result;
  }

//+------------------------------------------------------------------+
bool Test_AccountCommon()
  {
   bool result = SystemRequirements::AccountCommon();
   if(!result)
      PrintLastAtingError();
   PrintTestResultSystemRequirements("Test_AccountCommon", result);
   return result;
  }

//+------------------------------------------------------------------+
bool Test_TerminalCommon()
  {
   bool result = SystemRequirements::TerminalCommon();
   if(!result)
      PrintLastAtingError();
   PrintTestResultSystemRequirements("Test_TerminalCommon", result);
   return result;
  }

//+------------------------------------------------------------------+
bool Test_SymbolExpiration(string symbol)
  {
   int testType = SYMBOL_EXPIRATION_DAY;
   bool result = SystemRequirements::SymbolExpiration(symbol, testType);
   if(!result)
      PrintLastAtingError();
   PrintTestResultSystemRequirements("Test_SymbolExpiration", result);
   return result;
  }

//+------------------------------------------------------------------+
bool Test_SymbolFilling(string symbol)
  {
   int testType = SYMBOL_FILLING_IOC;
   bool result = SystemRequirements::SymbolFilling(symbol, testType);
   if(!result)
      PrintLastAtingError();
   PrintTestResultSystemRequirements("Test_SymbolFilling", result);
   return result;
  }

//+------------------------------------------------------------------+
bool Test_SymbolOrderMode(string symbol)
  {
   int testMode = SYMBOL_ORDER_MARKET;
   bool result = SystemRequirements::SymbolOrderMode(symbol, testMode);
   if(!result)
      PrintLastAtingError();
   PrintTestResultSystemRequirements("Test_SymbolOrderMode", result);
   return result;
  }

//+------------------------------------------------------------------+
bool Test_SymbolTradeExecution(string symbol)
  {
   int testMode = SYMBOL_TRADE_EXECUTION_MARKET;
   bool result = SystemRequirements::SymbolTradeExecution(symbol, testMode);
   if(!result)
      PrintLastAtingError();
   PrintTestResultSystemRequirements("Test_SymbolTradeExecution", result);
   return result;
  }

//+------------------------------------------------------------------+
bool Test_SymbolTradeMode(string symbol)
  {
   int testMode = SYMBOL_TRADE_MODE_FULL;
   bool result = SystemRequirements::SymbolTradeMode(symbol, testMode);
   if(!result)
      PrintLastAtingError();
   PrintTestResultSystemRequirements("Test_SymbolTradeMode", result);
   return result;
  }

//+------------------------------------------------------------------+
bool Test_SymbolStops(string symbol, double sl, double tp, ENUM_POSITION_TYPE type)
  {
   bool result = SystemRequirements::SymbolStops(symbol, sl, tp, type);
   if(!result)
      PrintLastAtingError();
   PrintTestResultSystemRequirements("Test_SymbolStops", result);
   return result;
  }

//+------------------------------------------------------------------+
bool Test_SymbolCommon(string symbol)
  {
   bool result = SystemRequirements::SymbolCommon(symbol);
   if(!result)
      PrintLastAtingError();
   PrintTestResultSystemRequirements("Test_SymbolCommon", result);
   return result;
  }
//+------------------------------------------------------------------+
