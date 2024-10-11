//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+
#include <Arrays/ArrayInt.mqh>
#include <Arrays/ArrayChar.mqh>
#include <Arrays/ArrayDouble.mqh>
#include <Arrays/ArrayFloat.mqh>
#include <Arrays/ArrayLong.mqh>
#include <Arrays/ArrayShort.mqh>
#include <Arrays/ArrayString.mqh>
#include "AtingErr.mqh"

//+------------------------------------------------------------------+
class ZeroProcessor
  {
public:
   template <typename Numbers>
   static bool       Run(Numbers value, bool setAtingErr = false)
     {
      if(value == 0)
        {
         if(setAtingErr)
            SetLastAtingErr(ATING_ERR_SETTING_ZERO_VALUE);
         return true;
        }
      return false;
     }

   template <typename Numbers>
   static bool       Run(Numbers &values[], Numbers &result[], bool returnIndex = false)
     {
      ArrayFree(result);
      if(ArraySize(values) == 0)
        {
         SetLastAtingErr(ATING_ERR_PARAM_EMPTY);
         return false;
        }

      for(int i = 0; i < ArraySize(values); i++)
        {
         if(Run(values[i]))
           {
            ArrayResize(result, ArraySize(result) + 1);
            result[ArraySize(result) - 1] = (returnIndex ? i : values[i]);
           }
        }

      if(ArraySize(result) > 0)
        {
         SetLastAtingErr(ATING_ERR_SETTING_ZERO_VALUE);
         return true;
        }
      return false;
     }

   template <typename CArrNumbers>
   static bool       Run(CArrNumbers &values, CArrNumbers &result, bool returnIndex = false)
     {
      switch(values.Type())
        {
         case TYPE_CHAR:
         case TYPE_SHORT:
         case TYPE_INT:
         case TYPE_LONG:
         case TYPE_DATETIME:
         case TYPE_FLOAT:
         case TYPE_DOUBLE:
            break;
         default:
            SetLastAtingErr(ATING_ERR_PARAM_INVALID_TYPE_VALUE);
            return false;
        }

      result.Shutdown();
      if(values.Total() == 0)
        {
         SetLastAtingErr(ATING_ERR_PARAM_EMPTY);
         return false;
        }

      for(int i = 0; i < values.Total(); i++)
        {
         if(Run(values.At(i)))
            result.Add(returnIndex ? i : values.At(i));
        }

      if(result.Total() > 0)
        {
         SetLastAtingErr(ATING_ERR_SETTING_ZERO_VALUE);
         return true;
        }
      return false;
     }
  };

//+------------------------------------------------------------------+
class NegativeProcessor
  {
public:
   template <typename Numbers>
   static bool       IsNegative(Numbers value, bool setAtingErr = false)
     {
      if((double)value < 0)
        {
         if(setAtingErr)
            SetLastAtingErr(ATING_ERR_SETTING_ZERO_VALUE);
         return true;
        }
      return false;
     }

   template <typename Numbers>
   static bool       Run(Numbers &values[], Numbers &result[], bool returnIndex = false)
     {
      ArrayFree(result);
      if(ArraySize(values) == 0)
        {
         SetLastAtingErr(ATING_ERR_PARAM_EMPTY);
         return false;
        }

      for(int i = 0; i < ArraySize(values); i++)
        {
         if(IsNegative(values[i]))
           {
            ArrayResize(result, ArraySize(result) + 1);
            result[ArraySize(result) - 1] = (returnIndex ? i : values[i]);
           }
        }

      if(ArraySize(result) > 0)
        {
         SetLastAtingErr(ATING_ERR_SETTING_NEGATIVE_VALUE);
         return true;
        }
      return false;
     }

   template <typename CArrNumbers>
   static bool       Run(CArrNumbers &values, CArrNumbers &result, bool returnIndex = false)
     {
      switch(values.Type())
        {
         case TYPE_CHAR:
         case TYPE_SHORT:
         case TYPE_INT:
         case TYPE_LONG:
         case TYPE_DATETIME:
         case TYPE_FLOAT:
         case TYPE_DOUBLE:
            break;
         default:
            SetLastAtingErr(ATING_ERR_PARAM_INVALID_TYPE_VALUE);
            return false;
        }

      result.Shutdown();
      if(values.Total() == 0)
        {
         SetLastAtingErr(ATING_ERR_PARAM_EMPTY);
         return false;
        }

      for(int i = 0; i < values.Total(); i++)
        {
         if(IsNegative(values.At(i)))
            result.Add(returnIndex ? i : values.At(i));
        }

      if(result.Total() > 0)
        {
         SetLastAtingErr(ATING_ERR_SETTING_NEGATIVE_VALUE);
         return true;
        }
      return false;
     }
  };

//+------------------------------------------------------------------+
class NoEmptyProcessor
  {
public:
   static bool       Run(string value, bool setAtingErr = false)
     {
      if(StringLen(value) > 0)
         return false;
      else
         if(setAtingErr)
           {
            SetLastAtingErr(ATING_ERR_SETTING_EMPTY_VALUE);
           }
      return true;
     }

   static bool       Run(CObject *obj, bool setAtingErr = false)
     {
      if(obj != NULL)
         return false;
      else
         if(setAtingErr)
           {
            SetLastAtingErr(ATING_ERR_SETTING_EMPTY_VALUE);
           }
      return true;
     }

   static bool       Run(string &values[], string &result[], bool returnIndex = false)
     {
      ArrayFree(result);
      if(ArraySize(values) == 0)
        {
         SetLastAtingErr(ATING_ERR_PARAM_EMPTY);
         return false;
        }

      for(int i = 0; i < ArraySize(values); i++)
        {
         if(Run(values[i]))
           {
            ArrayResize(result, ArraySize(result) + 1);
            result[ArraySize(result) - 1] = (returnIndex ? IntegerToString(i) : values[i]);
           }
        }

      if(ArraySize(result) > 0)
        {
         SetLastAtingErr(ATING_ERR_SETTING_EMPTY_VALUE);
         return false;
        }
      return true;
     }

   static bool       Run(CArrayString &values, CArrayString &result, bool returnIndex = false)
     {
      result.Shutdown();
      if(values.Total() == 0)
        {
         SetLastAtingErr(ATING_ERR_PARAM_EMPTY);
         return false;
        }

      for(int i = 0; i < values.Total(); i++)
        {
         if(Run(values.At(i)))
            result.Add(returnIndex ? IntegerToString(i) : values.At(i));
        }

      if(result.Total() > 0)
        {
         SetLastAtingErr(ATING_ERR_SETTING_EMPTY_VALUE);
         return false;
        }
      return true;
     }

   static bool       Run(CObject *&values[], CObject *&result[], bool returnIndex = false)
     {
      ArrayFree(result);
      if(ArraySize(values) == 0)
        {
         SetLastAtingErr(ATING_ERR_PARAM_EMPTY);
         return false;
        }

      for(int i = 0; i < ArraySize(values); i++)
        {
         if(Run(values[i]))
           {
            ArrayResize(result, ArraySize(result) + 1);
            result[ArraySize(result) - 1] = (returnIndex ? values[i] : values[i]);
           }
        }
      if(ArraySize(result) > 0)
        {
         SetLastAtingErr(ATING_ERR_SETTING_EMPTY_VALUE);
         return false;
        }
      return true;
     }
  };
//+------------------------------------------------------------------+
