//+------------------------------------------------------------------+
//|                                                  MyFunctions.mqh |
//|                                  Aurora Capital Management Group |
//|                                         http://www.auroracap.com |
//+------------------------------------------------------------------+
#property copyright "Aurora Capital Management Group"
#property link      "http://www.auroracap.com"
//#property strict

//+------------------------------------------------------------------+
//| My functions
//+------------------------------------------------------------------+

/**
* Returns total opened trades
* @param    int   Type
* @param    int   Magic
* @return   int
*/
int GetTotalTrades(int Type, int Magic)
{
   int counter = 0;
   for (int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
        Print(ShortName +" (OrderSelect Error) "+ ErrorDescription(GetLastError()));
      } else if(OrderSymbol() == Symbol() && (OrderType() == Type || Type == EMPTY_VALUE) && OrderMagicNumber() == Magic) {
            counter++;
      }
   }
   return(counter);
}


/**
* Closes desired orders 
* @param    int   Type
*/
void CloseOrder(int Type, int Magic = EMPTY_VALUE)
{
   int l_type;
	if(Magic == EMPTY_VALUE) Magic = MagicNumber;
	for(int i = OrdersTotal()-1; i >= 0; i--)
	{
		if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)==true); l_type = OrderType();
		if(OrderSymbol() == Symbol() && OrderMagicNumber() == Magic && Type == l_type)
		{ 
	      if(Type == OP_BUY || Type == OP_SELL)  
	      {
            if(!OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), Slippage, Gold))
               Print(ShortName +" (OrderClose Error) "+ ErrorDescription(GetLastError()));
         }
      }
   }
}

/**
* Places an order
* @param    int      Type
* @param    double   Lotz
* @param    double   PendingPrice
*/
void PlaceOrder(int Type, double Lotz, int Magic = EMPTY_VALUE)
{
   int err;
   color  l_color;
   double l_price, l_stoploss = 0;
   string action;
   RefreshRates();
   
   // Magic adaptation
   if(Magic == EMPTY_VALUE) Magic = MagicNumber;
   
   // Price and color for the trade type
   if(Type == OP_BUY){ l_price = Ask;  l_color = Blue; action = "Buy"; }
   if(Type == OP_SELL){ l_price = Bid; l_color = Red; action = "Sell"; } 
   
   // Avoid collusions
   while (IsTradeContextBusy()) Sleep(1000);
   int l_datetime = TimeCurrent();
   
   // Send order
   int l_ticket = OrderSend(Symbol(), Type, Lotz, l_price, Slippage, 0, 0, "", Magic, 0, l_color);
   
   // Rety if failure
   if (l_ticket == -1)
   {
      while(l_ticket == -1 && TimeCurrent() - l_datetime < 60 && !IsTesting())
      {
         err = GetLastError();
         if (err == 148) return;
         Sleep(1000);
         while (IsTradeContextBusy()) Sleep(1000);
         RefreshRates();
         l_ticket = OrderSend(Symbol(), Type, Lotz, l_price, Slippage, 0, 0, "", Magic, 0, l_color);
      }
      if (l_ticket == -1)
         Print(ShortName +" (OrderSend Error) "+ ErrorDescription(GetLastError()));
   }
   if (l_ticket != -1)
   {        
      // Store data
      LastOrderTime[Type]     = iTime(Symbol(), PERIOD_D1, 0);
      LastOrderTicket[Type]   = l_ticket;
      LastOrderLots[Type]     = Lotz;
      
      // Update positions
      if(OrderSelect(l_ticket, SELECT_BY_TICKET, MODE_TRADES))
      {
         l_stoploss = MyNormalizeDouble(GetStopLoss(Type));
         if(!OrderModify(l_ticket, OrderOpenPrice(), l_stoploss, 0, 0, Green))
            Print(ShortName +" (OrderModify Error) "+ ErrorDescription(GetLastError())); 
      }
   }
}

/**
* Calculates lot size according to risk and the weight of this trade
* @return   double
*/
double GetLotSize(int Type)
{
   // Lots
   double l_lotz = LotSize;
   
   // Lotsize and restrictions 
   double l_minlot = MarketInfo(Symbol(), MODE_MINLOT);
   double l_maxlot = MarketInfo(Symbol(), MODE_MAXLOT);
   double l_lotstep = MarketInfo(Symbol(), MODE_LOTSTEP);
   int vp = 0; if(l_lotstep == 0.01) vp = 2; else vp = 1;
   
   // Apply money management
   if(MoneyManagement == true)
      l_lotz = MathFloor(AccountBalance() * RiskPercent / 100.0) / 1000.0;
   
   // Are we piramyding?
   l_lotz = NormalizeDouble(l_lotz, vp);
   
   // Check max/minlot here
   if (l_lotz < l_minlot) l_lotz = l_minlot;
   if(l_lotz > l_maxlot) l_lotz = l_maxlot; 
   
   // Bye!
   return (l_lotz);
}

/**
* Returns decimal pip value
* @return   double
*/
double GetDecimalPip()
{
   switch(Digits)
   {
      case 5: return(0.0001);
      case 4: return(0.0001);
      case 3: return(0.001);
      default: return(0.01);
   }
}


/**
* Returns initial stoploss
* @return   int   Type
* @return   double
*/
double GetStopLoss(int Type)
{
   double l_sl = 0;
   double l_risk = GetStopLossRange(Type);
   if(Type == OP_BUY)  l_sl = Ask - l_risk - (Ask - Bid);
   if(Type == OP_SELL) l_sl = Bid + l_risk + (Ask - Bid);
   return (l_sl);
}

/**
* Get stoploss in range
* @return   double
*/
double GetStopLossRange(int Type)
{
   if(Type == OP_BUY) return(iATR(Symbol(), 0, ATRPeriod, Shift)*ATRMultiplier);
   if(Type == OP_SELL) return(iATR(Symbol(), 0, ATRPeriod, Shift)*ATRMultiplier);
   return(0);
}

/**
* Normalizes price
* @param    double   price 
* @return   double
*/
double MyNormalizeDouble(double price)
{
   return (NormalizeDouble(price, Digits));
}

/**
* Checks if the bar has closed
*/
bool IsBarClosed(int timeframe,bool reset)
{
    static datetime lastbartime;
    if(timeframe==-1)
    {
        if(reset)
            lastbartime=0;
        else
            lastbartime=iTime(NULL,timeframe,0);
        return(true);
    }
    if(iTime(NULL,timeframe,0)==lastbartime) // wait for new bar
        return(false);
    if(reset)
        lastbartime=iTime(NULL,timeframe,0);
    return(true);
}

/**
* Get baseline plus deviation
* @return   double
*/
double getStopLevelInPips()
{
   double s = MarketInfo(Symbol(), MODE_STOPLEVEL) + 1.0;
   if(Digits == 5) s = s / 10;
   return(s);
}


/**
* Breaks even all trades
*/
void BreakEvenTrades()
{  
   // Lotstep
   double l_lotstep = MarketInfo(Symbol(), MODE_LOTSTEP);
   int vp = 0; if(l_lotstep == 0.01) vp = 2; else vp = 1;
   
   // Iterate all trades
   for(int cnt=0; cnt < OrdersTotal(); cnt++)
   {
      if(OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES)==true); int l_type = OrderType();
      if((l_type == OP_BUY || l_type == OP_SELL) && OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol())
      {
         // Pips gained for now
         double PipProfit, PipStopLoss;
         
         // Calculate pips for stoploss
         if(l_type == OP_BUY)
         {
            // If this trade is losing or free
            if(Bid < OrderOpenPrice()) continue;
            
            // Profit and so forth
            PipProfit = Bid - OrderOpenPrice();
            PipStopLoss = (OrderOpenPrice() - OrderStopLoss()) / StopDivisor;
            
         } else if(l_type == OP_SELL) {
         
            // If this trade is losing or free
            if(Ask > OrderOpenPrice()) continue;
         
            // Profit and so forth
            PipProfit = OrderOpenPrice() - Ask;
            PipStopLoss = (OrderStopLoss() - OrderOpenPrice()) / StopDivisor;
         }
         
         // Read comment from trade
         string Com = OrderComment();
         double LOTS = OrderLots();
       
         // Partial close
         if(PartialClosing &&
            PipProfit > PipStopLoss && 
            StringFind(Com, "from #", 0) == -1)
         {
            // Close
            double halflots = NormalizeDouble(LOTS * PercentageToClose, vp);
            
            // Close half position
            if(halflots > MarketInfo(Symbol(), MODE_MINLOT))
            {
               if(!OrderClose(OrderTicket(), halflots, OrderClosePrice(), 6, Gold))
                  Print(ShortName +" (OrderModify Error) "+ ErrorDescription(GetLastError()));
            }
         }
      }
   }
}


/**
* Trails the stop-loss for all trades
*/
void TrailStops()
{
   int Type;
   double TS_price; 
   double stoplevel = getStopLevelInPips();
	for(int i = OrdersTotal()-1; i >= 0; i--)
	{
		if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)==true);
		if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
		{
         // Proceed to trailing
         Type = OrderType();
         
         if(Type == OP_BUY)
         {
            TS_price = Bid - iATR(Symbol(), 0, TSATRPeriod, Shift)*TSATRMultiplier;
            if(TS_price > OrderStopLoss()+stoplevel*DecimalPip)
            {
               if(!OrderModify(OrderTicket(), OrderOpenPrice(), TS_price, OrderTakeProfit(), 0, Pink))
                  Print(ShortName +" (OrderModify Error) "+ ErrorDescription(GetLastError()));
            }
            
         } else if(Type == OP_SELL) {
             
             TS_price = Ask + iATR(Symbol(), 0, TSATRPeriod, Shift)*TSATRMultiplier;
             if(TS_price < OrderStopLoss()-stoplevel*DecimalPip)
            {
               if(!OrderModify(OrderTicket(), OrderOpenPrice(), TS_price, OrderTakeProfit(), 0, Pink))
                    Print(ShortName +" (OrderModify Error) "+ ErrorDescription(GetLastError()));
            }
         }
      }
   }
}