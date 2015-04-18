//+------------------------------------------------------------------+
//|                                          DisplayUserFeedback.mqh |
//|                                  Aurora Capital Management Group |
//|                                         http://www.auroracap.com |
//+------------------------------------------------------------------+
#property copyright "Aurora Capital Management Group"
#property link      "http://www.auroracap.com"


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SM(string message)
  {
   ScreenMessage=StringConcatenate(ScreenMessage,Gap,message);
  }//End void SM()
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DisplayUserFeedback()
  {
   if(IsTesting()==true && IsVisualMode()==false) return;

   ScreenMessage="";

//SM("Updates for this EA are to be found at http://www.stevehopwoodforex.com/phpBB3/viewtopic.php?f=12&t=3224"+NL);
   SM(SOFTWARE+" v"+version+NL);
   SM(COPYRIGHT+NL);
   SM(LINK+NL);
   SM(NL);
   SM("Broker time = "+TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS)+": Local time = "+TimeToStr(TimeLocal(),TIME_DATE|TIME_SECONDS)+NL);
   SM(NL);

   if(!TradeTimeOk)
     {
      SM(NL);
      SM("======== OUTSIDE TRADING HOURS. Will continue to monitor open trades.========--"+NL+NL);
     }//if (!TradeTimeOk) 
   
   if(TradesHalted)
     {
      SM(NL);
      SM("======== YOUR TRADING IS HALTED! ========"+NL);
      SM("========= SOMETHING WENT WRONG! ========="+NL);
      SM("=====The BROKER screwed something up====="+NL);
      SM("==Will continue to monitor open trades=="+NL+NL+NL);
     }//if (!TradesHalted)    

   SM("Open Price of last open order="+DoubleToStr(LastOpenTradePrice(Symbol()),Digits)+NL);

   SM("Echo Symbol="+Symbol()+NL);
   SM("Digits="+DoubleToStr(Digits,0)+NL);
   SM("Multiplier="+DoubleToStr(point2Pip,0)+NL);

   SM("Count Historical Trades="+DoubleToStr(CountHisto(Symbol()),0)+NL);
   SM("Trade Allowed Margin="+BoolToString(CheckTradeAllowedMargin())+NL);
   SM(NL);
   if(AverageSpread==0)
     {
      GetAverageSpread();
      int left=TicksToCount-CountedTicks;
      SM("Calculating the average spread. "+DoubleToStr(left,0)+" left to count."+NL);

     }//
   else SM("Allowed Spread: "+DoubleToStr((AverageSpread*AllowedSpreadMultiplier/10),1)+" Actual Spread: "+DoubleToStr((spread/10),1)+NL); //Modified to show spread in pips

                                                                                                                                           //Trading hours
   if(tradingHoursDisplay!="") SM("Trading hours: "+tradingHoursDisplay+NL);
   else SM("24 Hour trading is permitted "+NL);

//Display Magic Number
   SM(NL);
   SM("Magic Number: "+MagicNumber+NL);

//Check Trends
   SM("D1 Trend: "+D1TREND+NL);
   SM("H4 Trend: "+H4TREND+NL);
   SM("H1 Trend: "+H1TREND+NL);
   
//Check Spreads
   SM(NL);
   SM("Fair Spread?");
   if(TradesHalted)
   SM("NO!"+NL);
   else if(!TradesHalted)
   SM("Yes"+NL);
   

//Display Stoch Stats
   SM(NL);
   SM("Stoch Signal: "+STOCHSIGNAL+NL);

//Display VZO
   SM("Visage: ");
   if(VZOBuy)SM("Buy Signal");
   if(VZOSell)SM("Sell Signal");
   if(VZOBuyClose)SM("Buy Close");
   if(VZOSellClose)SM("Sell Close");
   SM(NL);
   SM("Indicators: "+NL);
   SM("V0: "+VZO0+NL);
   SM("V1: "+VZO1+NL);
   SM("V2: "+VZO2+NL);
   SM("V3: "+VZO3+NL);
   SM("V4: "+VZO4+NL);


//SM("Indi: "+VZO0+" "+VZO1+" "+VZO2+" "+VZO3+" "+VZO4+" ");

//Display ADX
   SM(NL);
   SM("ADX Direction: "+ADXTREND+NL);
   if(ADXUP==true)SM("ADX > 18: True"+NL);
   if(ADXDN==true)SM("ADX < 18: True"+NL);


   if(useAutomatedLossRecovery)
     {
      if(ALR_ActiveTrades>=1 && ALR_Active)
        {
         string ALRStatus;
         SM(""+NL);
         SM("Automated Loss Recovery Active"+NL);
         SM("#------ALR Progressions------#"+NL);
         for(int j=0; j<=ALR_MaxAllowedTrades; j++)
           {
            if(j<ALR_ActiveTrades)
               ALRStatus="#Closed";
            else if(j==ALR_ActiveTrades)
               ALRStatus="#Active";
            else if(j==ALR_ActiveTrades+1)
               ALRStatus="#Pending";
            else
               ALRStatus=" ";

            SM(StringConcatenate("Order #",j,"lot size: ",ALR_Lots[j],"  ",ALRStatus,NL));
           }
        }
     }//when useALR option is enabled

   Comment(ScreenMessage);

  }//void DisplayUserFeedback()