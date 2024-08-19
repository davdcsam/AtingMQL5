//+------------------------------------------------------------------+
//|                                              MarketOpenHours.mqh |
//|                                        Wolfgang Melz, wm1@gmx.de |
//|                               https://www.mql5.com/en/code/46597 |
//|                                    No license has been published |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
bool MarketOpenHours(string sym)
  {
   bool isOpen = false;                           // by default market is closed
   MqlDateTime mdtServerTime;                     // declare server time structure variable
   datetime dtServerDateTime = TimeTradeServer(); // store server time
   if(!TimeToStruct(dtServerDateTime,             // is servertime correctly converted to struct?
                    mdtServerTime))
     {
      return (false); // no, return market is closed
     }

   ENUM_DAY_OF_WEEK today = (ENUM_DAY_OF_WEEK) // get actual day and cast to enum
                            mdtServerTime.day_of_week;

   if(today > 0 || today < 6)  // is today in monday to friday?
     {
      datetime dtF;                                     // store trading session begin and end time
      datetime dtT;                                     // date component is 1970.01.01 (0)
      datetime dtServerTime = dtServerDateTime % 86400; // set date to 1970.01.01 (0)
      if(!SymbolInfoSessionTrade(sym, today,            // do we have values for dtFrom and dtTo?
                                 0, dtF, dtT))
        {
         return (false); // no, return market is closed
        }
      switch(today)  // check for different trading sessions
        {
         case 1:
            if(dtServerTime >= dtF && dtServerTime <= dtT)  // is server time in 00:05 (300) - 00:00 (86400)
               isOpen = true;                               // yes, set market is open
            break;
         case 5:
            if(dtServerTime >= dtF && dtServerTime <= dtT)  // is server time in 00:04 (240) - 23:55 (86100)
               isOpen = true;                               // yes, set market is open
            break;
         default:
            if(dtServerTime >= dtF && dtServerTime <= dtT)  // is server time in 00:04 (240) - 00:00 (86400)
               isOpen = true;                               // yes, set market is open
            break;
        }
     }
   return (isOpen);
  }
//+------------------------------------------------------------------+
