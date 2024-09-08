/*
      Custom Error
      ---------------------------------------------------------
*/

enum ENUM_ATING_ERR
  {
   ATING_ERR_NO_REPORTED,
   ATING_ERR_SETTING_ZERO_VALUE,
   ATING_ERR_SETTING_NEGATIVE_VALUE,
   ATING_ERR_INVALID_TYPE_VALUE
  };

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
string DescriptionLastAtingError()
  {
   string result = "Err code: ";
   switch(_LastAtingErr)
     {
      case ATING_ERR_SETTING_ZERO_VALUE:
         result += " Cannot be zero";
         break;
      case ATING_ERR_SETTING_NEGATIVE_VALUE:
         result += " Cannot be negative";
         break;
      case ATING_ERR_INVALID_TYPE_VALUE:
         result += " Invalid type value";
         break;
      default:
         result += " No reported";
         break;
     }
   return result;
  }

//+------------------------------------------------------------------+
void PrintLastAtingError()
  { Print(DescriptionLastAtingError()); }
//+------------------------------------------------------------------+
