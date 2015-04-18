//+------------------------------------------------------------------+
//|                                               ReadIndicators.mqh |
//|                                  Aurora Capital Management Group |
//|                                         http://www.auroracap.com |
//+------------------------------------------------------------------+
#property copyright "Aurora Capital Management Group"
#property link      "http://www.auroracap.com"
//#property strict
//======= All Indicator Parameters go here.
//
// Uncomment any you would like to use. Leave the rest commented
// to avoid extra CPU cycles.

   // Moving averages

   double fast_ma = iMA(Symbol(), 0, FastMA, 0, FastMAMode, FastMAPrice, Shift);
   double slow_ma = iMA(Symbol(), 0, SlowMA, 0, SlowMAMode, SlowMAPrice, Shift);
   double fast_ma1 = iMA(Symbol(), 0, FastMA, 0, FastMAMode, FastMAPrice, Shift+1);
   double slow_ma1 = iMA(Symbol(), 0, SlowMA, 0, SlowMAMode, SlowMAPrice, Shift+1);
   
   
   // Trades opened
   int l_TotalTrades_buy = GetTotalTrades(OP_BUY, MagicNumber);
   int l_TotalTrades_sell = GetTotalTrades(OP_SELL, MagicNumber);
  
   // Bars
   double CLOSE = iClose(Symbol(),0, Shift);
   double HIGH  = iHigh(Symbol(), 0, Shift);
   double LOW   = iLow(Symbol(), 0, Shift);