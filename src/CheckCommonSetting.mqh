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
#include "AtingErr.mqh"

/*
      Verify Zero Values
      ---------------------------------------------------------
*/

//+------------------------------------------------------------------+
template <typename numbers>
bool ZeroValue(numbers &value)
  {
   return (!value) ? true : false;
  }

//+------------------------------------------------------------------+
template <typename numbers>
bool ZeroValues(numbers &values[], numbers &result[], bool returnIndex = false)
  {
   ArrayFree(result);
   if(!ArraySize(values))
      return;

   for(int i=0;i<ArraySize(values);i++)
     {
      if(!values[i])
        {
         ArrayResize(result, ArraySize(result) + 1);
         result[ArraySize(result) - 1] = (returnIndex ? i : values[i]);
        }
     }
  }

//+------------------------------------------------------------------+
template <typename CArrNumbers>
bool ZeroValues(CArrNumbers &values, CArrNumbers &result, bool returnIndex = false)
  {
   switch(values.Type())
     {
      case  TYPE_CHAR:
         break;
      case TYPE_SHORT:
         break;
      case TYPE_INT;
         break;
      case TYPE_LONG:
         break;
      case TYPE_DATETIME;
         break;
      case TYPE_FLOAT:
         break;
      case TYPE_DOUBLE:
         break;
      default:
         SetLastAtingErr(ATING_ERR_INVALID_TYPE_VALUE);
         return false;
     }
   switch(result.Type())
     {
      case  TYPE_CHAR:
         break;
      case TYPE_SHORT:
         break;
      case TYPE_INT;
         break;
      case TYPE_LONG:
         break;
      case TYPE_DATETIME;
         break;
      case TYPE_FLOAT:
         break;
      case TYPE_DOUBLE:
         break;
      default:
         SetLastAtingErr(ATING_ERR_INVALID_TYPE_VALUE);
         return false;
     }
   result.Shutdown();
   if(!values.Total())
      return;

   for(int i=0; i<values.Total(); i++)
     {
      if(!values.At(i))
         result.Add((returnIndex) ? i : values.At(i));
     }
  }


/*
      Verify Negative Values
      ---------------------------------------------------------
*/

//+------------------------------------------------------------------+
template <typename numbers>
bool NegativeValue(numbers &value)
  { return (value < 0) ? true : false; }


//+------------------------------------------------------------------+
template <typename numbers>
void NegativeValues(numbers &values[], numbers &result[], bool returnIndex = false)
  {
   ArrayFree(result);
   if(!ArraySize(values))
      return;

   for(int i = 0; i < ArraySize(values); i++)
     {
      if(values[i] < 0)
        {
         ArrayResize(result, ArraySize(result) + 1);
         result[ArraySize(result) - 1] = (returnIndex ? i : values[i]);
        }
     }
  }

//+------------------------------------------------------------------+
template <typename CArrNumbers>
bool NegativeValuesCArray(CArrNumbers &values, CArrNumbers &result, bool returnIndex = false)
  {
   switch(values.Type())
     {
      case  TYPE_CHAR:
         break;
      case TYPE_SHORT:
         break;
      case TYPE_INT;
         break;
      case TYPE_LONG:
         break;
      case TYPE_DATETIME;
         break;
      case TYPE_FLOAT:
         break;
      case TYPE_DOUBLE:
         break;
      default:
         SetLastAtingErr(ATING_ERR_INVALID_TYPE_VALUE);
         return false;
     }
   switch(result.Type())
     {
      case  TYPE_CHAR:
         break;
      case TYPE_SHORT:
         break;
      case TYPE_INT;
         break;
      case TYPE_LONG:
         break;
      case TYPE_DATETIME;
         break;
      case TYPE_FLOAT:
         break;
      case TYPE_DOUBLE:
         break;
      default:
         SetLastAtingErr(ATING_ERR_INVALID_TYPE_VALUE);
         return false;
     }
   result.Shutdown();
   if(!values.Total())
      return false;

   for(int i = 0; i < values.Total(); i++)
     {
      if(values.At(i) < 0)
         result.Add((returnIndex) ? i : values.At(i));
     }

   return result.Total() > 0 ? true : false;
  }
//+------------------------------------------------------------------+
