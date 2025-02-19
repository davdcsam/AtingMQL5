//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+
#include "CalcStop.mqh"
#include "RoundVolume.mqh"
#include "../detect/IDetectEntity.mqh"

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
    * @struct Setting
    * @brief Structure to define trade settings.
    */
   struct Setting
   {
      string symbol;                     /**< Symbol of the asset. */
      double lotSize;                    /**< Lot size for the order. */
      ulong takeProfit;                  /**< Take profit value. */
      ulong stopLoss;                    /**< Stop loss value. */
      ulong deviationTrade;              /**< Deviation trade value. */
      ulong magicNumber;                 /**< Magic number for the order. */
   };

protected:
   Setting setting;                      /**< Trade settings. */

   RoundVolume* roundVolume;             /**< Pointer to RoundVolume class instance. */
   CalcStop* calcStop;                   /**< Pointer to CalcStop class instance. */

public:
   /**
    * @brief Default constructor for the Request class.
    * @param rV Pointer to a RoundVolume instance.
    * @param cS Pointer to a CalcStop instance.
    */
   Request(RoundVolume* rV, CalcStop* cS);

   /**
    * @brief Updates the attributes of the request.
    * @param sym Symbol of the asset.
    * @param lot Lot size.
    * @param tp Take profit value.
    * @param sl Stop loss value.
    * @param dev Deviation trade value.
    * @param magic Magic number for the order.
    */
   void UpdateSetting(string sym, double lot, uint tp, uint sl, uint dev, ulong magic);

   /**
    * @brief Gets the current settings of the request.
    * @param s Reference to a Setting structure where current settings will be stored.
    */
   void GetSetting(Setting& s);

   /**
    * @brief Returns the current settings of the request.
    * @return A Setting structure with the current settings.
    */
   Setting GetSetting(void) const;

   /**
    * @brief Checks the validity of the current settings.
    * @return True if the settings are valid, otherwise false.
    */
   bool CheckSetting() const;

   /**
    * @brief Builds a check position.
    * @param request Trade request structure.
    * @param type Position type.
    * @param filling Order filling type.
    */
   void BuildCheckPosition(MqlTradeRequest& request, ENUM_POSITION_TYPE type, ENUM_ORDER_TYPE_FILLING filling);

   /**
    * @brief Builds a position.
    * @param request Trade request structure.
    * @param type Position type.
    * @param filling Order filling type.
    */
   void BuildPosition(MqlTradeRequest& request, ENUM_POSITION_TYPE type, ENUM_ORDER_TYPE_FILLING filling, string comment = "");

   /**
    * @brief Builds a pending order.
    * @param request Trade request structure.
    * @param type Pending order type.
    * @param filling Order filling type.
    * @param price Price for the pending order.
    * @param expiration Expiration time for the pending order (default is 0).
    */
   void BuildPending(MqlTradeRequest& request, ENUM_ORDER_TYPE_BASE type, ENUM_ORDER_TYPE_FILLING filling, double price, datetime expiration = 0, string comment = "");

   /**
    * @brief Builds a pending order or position.
    * @param request Trade request structure.
    * @param type Pending order type.
    * @param filling Order filling type.
    * @param price Price for the pending order.
    * @param expiration Expiration time for the pending order (default is 0).
    */
   void BuildPendingOrPosition(MqlTradeRequest& request, ENUM_ORDER_TYPE_AVAILABLE type, ENUM_ORDER_TYPE_FILLING filling, double price, datetime expiration = 0, string comment = "");
};
