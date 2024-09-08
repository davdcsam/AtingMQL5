/*
      Custom Error
      ---------------------------------------------------------
*/

enum ENUM_ATING_ERR
  {
// Setting
   ATING_ERR_SETTING_ZERO_VALUE,
   ATING_ERR_SETTING_NEGATIVE_VALUE,

// Param Function
   ATING_ERR_INVALID_TYPE_VALUE,

// Terminal
   ATING_ERR_TERMINAL_PROHIBITED_TRADE,
   ATING_ERR_TERMINAL_MQL_PROHIBITED_TRADE,

// Account
   ATING_ERR_ACCOUNT_INVALID_TRADE_MODE,
   ATING_ERR_ACCOUNT_INVALID_LIMIT_ORDERS,
   ATING_ERR_ACCOUNT_PROHIBITED_BOT,
   ATING_ERR_ACCOUNT_PROHIBITED_TRADE,
   ATING_ERR_ACCOUNT_PROHIBITED_HEGDE,

// Symbol
   ATING_ERR_SYMBOL_INVALID_EXPIRATION,
   ATING_ERR_SYMBOL_INVALID_FILLING,
   ATING_ERR_SYMBOL_INVALID_ORDER_MODE,
   ATING_ERR_SYMBOL_INVALID_TRADE_EXECUTION,
   ATING_ERR_SYMBOL_INVALID_TRADE_MODE,
   ATING_ERR_SYMBOL_INVALID_STOPS,
   ATING_ERR_SYMBOL_PROHIBITED_TRADE,
   ATING_ERR_SYMBOL_NO_EXIST,

// Non
   ATING_ERR_NO_REPORTED = 0
  };

//+------------------------------------------------------------------+
string DescriptionLastAtingError()
  {
   string result = "Err code: ";
   switch(_LastAtingErr)
     {
      case ATING_ERR_SETTING_ZERO_VALUE:
         result += "Setting value cannot be zero";
         break;
      case ATING_ERR_SETTING_NEGATIVE_VALUE:
         result += "Setting value cannot be negative";
         break;
      case ATING_ERR_INVALID_TYPE_VALUE:
         result += "Invalid type value provided";
         break;
      case ATING_ERR_TERMINAL_PROHIBITED_TRADE:
         result += "Terminal prohibits trade operations";
         break;
      case ATING_ERR_TERMINAL_MQL_PROHIBITED_TRADE:
         result += "MQL prohibits trade operations in the terminal";
         break;
      case ATING_ERR_ACCOUNT_INVALID_TRADE_MODE:
         result += "Invalid trade mode for the account";
         break;
      case ATING_ERR_ACCOUNT_INVALID_LIMIT_ORDERS:
         result += "Invalid limit orders value for the account";
         break;
      case ATING_ERR_ACCOUNT_PROHIBITED_BOT:
         result += "Automated trading is prohibited for this account";
         break;
      case ATING_ERR_ACCOUNT_PROHIBITED_TRADE:
         result += "Trade operations are prohibited for this account";
         break;
      case ATING_ERR_ACCOUNT_PROHIBITED_HEGDE:
         result += "Hedging is prohibited for this account";
         break;
      case ATING_ERR_SYMBOL_INVALID_EXPIRATION:
         result += "Invalid expiration setting for the symbol";
         break;
      case ATING_ERR_SYMBOL_INVALID_FILLING:
         result += "Invalid filling policy for the symbol";
         break;
      case ATING_ERR_SYMBOL_INVALID_ORDER_MODE:
         result += "Invalid order mode for the symbol";
         break;
      case ATING_ERR_SYMBOL_INVALID_TRADE_EXECUTION:
         result += "Invalid trade execution type for the symbol";
         break;
      case ATING_ERR_SYMBOL_INVALID_TRADE_MODE:
         result += "Invalid trade mode for the symbol";
         break;
      case ATING_ERR_SYMBOL_INVALID_STOPS:
         result += "Invalid stop levels for the symbol";
         break;
      case ATING_ERR_SYMBOL_PROHIBITED_TRADE:
         result += "Trade operations are prohibited for this symbol";
         break;
      case ATING_ERR_SYMBOL_NO_EXIST:
         result += "The symbol does not exist";
         break;
      default:
         result += "No error reported";
         break;
     }
   return result;
  }

//+------------------------------------------------------------------+
static int _LastAtingErr = 0;

//+------------------------------------------------------------------+
void SetLastAtingErr(ENUM_ATING_ERR customErr)
  { _LastAtingErr = customErr; }

//+------------------------------------------------------------------+
int GetLastAtingError()
  { return _LastAtingErr; }

//+------------------------------------------------------------------+
void GetLastAtingError(int &param)
  { param = _LastAtingErr; }

//+------------------------------------------------------------------+
void ResetLastAtingErr()
  { _LastAtingErr = 0; }

//+------------------------------------------------------------------+
void PrintLastAtingError()
  { Print(DescriptionLastAtingError()); }
//+------------------------------------------------------------------+
