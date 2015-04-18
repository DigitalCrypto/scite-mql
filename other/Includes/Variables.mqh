//+------------------------------------------------------------------+
//|                                                    Variables.mqh |
//|                                  Aurora Capital Management Group |
//|                                         http://www.auroracap.com |
//+------------------------------------------------------------------+
#property copyright "Aurora Capital Management Group"
#property link      "http://www.auroracap.com"


extern string  gen                  =  "====General Inputs====";
extern int     MagicNumberMain      =  0;
bool           TradesHalted         =  false;
int            MagicNumber;
int            MagicNumberArr[NumMagicNumber];
extern int     slippage          =2;
extern bool    UseFixedLot       =true;
extern double  FixedLot          =0.01;
extern double  Risk_percent      =1.0;
extern double  StopLoss          = 5;
extern double  TakeProfit        = 15;
extern bool    CriminalIsECN     =false;
extern double  RequiredMarginPercentile=1000;
extern bool    TradeLong         =true;
extern bool    TradeShort        =true;
extern bool    EveryTickMode     =false;
extern int     TradingTimeFrame=0;//Time frame for reading of indicators and running trading functions
extern int     MinTradeTimeSec=3500;
string         TradeComment      = SOFTWARE;
datetime       OldBarsTime,OldDailyBarsTime;
double         LotStep,MinLot,MaxLot;

//for output of results

extern string     gen0a="====Automated Loss Recovery Settings====";
extern bool   useAutomatedLossRecovery =  true;
extern double UseMaxAccount=200;  // Maximum amount of cash to use for ALR.
extern double ALR_ZonePips             =  7;
extern double ALR_TargetPips_SameDir   =  15;
extern double ALR_TargetPips_OppDir    =  15;
extern double ALR_TargetPercentProfit  =  0.1;
extern double ALR_CommissionPips       =  2;
extern int    ALR_MaxTrades            =  10;
extern double ALR_MaxLots              =  1.0;
extern double ALR_MaxPercentLoss       =  20;
extern double ALR_SpreadPips           =  0;
int               ErrorConfirmTimeInSeconds=5;
bool              ALR_Active=false;
double            ALR_ZonePips_Pts,ALR_TargetPips_SameDir_Pts,ALR_TargetPips_OppDir_Pts,ALR_CommissionPips_Pts;
double            ALR_BuyEntryPrice,ALR_BuyTargetPrice,ALR_SellEntryPrice,ALR_SellTargetPrice;
int               ALR_ActiveTrades;
int               ALR_MaxAllowedTrades=2;
double            ALR_Lots[30];
double            ALR_TargetPrice[30];
double            ALR_TargetPoints[30];
int               ALR_Dir[30];

extern string  gen0b                   =  "====Stop Loss Management====";
extern bool    useStopLossManagement   =  true;
extern double  TrailingStopPips        =  15;
extern double  TrailingStopStep        =  5;
//this is to prevent stop loss adjustment on every pip.
//adjust on every TrailingStopStep move in pip points
extern double  BreakEvenTargetPips     =  28;
extern double  BreakEvenProfitPips     =  0.0;
extern bool    UseCloseFriday          =  false;
extern int     FridayCloseHour         =  18;
bool           FlagCloseFriday         =  false;
double         dbTrailingStop_Pt,dbBreakEvenTarget_Pt,dbBreakEvenProfit_Pt,dbTrailingStopStep_Pt;

extern string   gen1          =  "==== Basic EA Settings ====";
extern bool     CheckTrend    =  true;

extern string   gen2          =  "==== Trend Settings ====";
extern int      H1MA          =  60;
extern int      H1MAMode      =  MODE_EMA;
extern int      H1MAPrice     =  PRICE_CLOSE;
extern int      H1MA0         =  0; //Shift 0
extern int      H1MA5         =  5; // Shift 5
extern int      H4MA          =  240;
extern int      H4MAMode      =  MODE_EMA;
extern int      H4MAPrice     =  PRICE_CLOSE;
extern int      H4MA0         =  0; // Shift 0
extern int      H4MA5         =  5; // Shift 5
extern int      D1MA          =  1440;
extern int      D1MAMode      =  MODE_EMA;
extern int      D1MAPrice     =  PRICE_CLOSE;
extern int      D1MA0         =  0; // Shift 0
extern int      D1MA5         =  5; // Shift 5
string   h1ma0,h1ma5,H1TREND,h4ma0,h4ma5,H4TREND,d1ma0,d1ma5,D1TREND;
extern int      TrendPips=20;
bool            TRENDDNBUY,TRENDUPSELL; // Allow Buying if more than X pips from trend line
bool            H1TrendUp, H1TrendDn; 

////////////////////////////////////////////////////////////////////////////////////////

extern string  gen4              = "Set Display update time, 0 seconds to update everytick";
extern int     secondsToUpdate   =  15;
extern int     DisplayGapSize    =  30;
datetime nextUpdate;

extern string  gen5                    =  "==== Spread detect settings====";
extern int     TicksToCount            =  200;
extern double  AllowedSpreadMultiplier =  1.4;
extern double  MaxSpreadAllowed        =  3;
double         CurrentSpread           =  0;
double         AverageSpread           =  0;
string         SpreadGvName;
bool           BrokerHasSundayCandle   =  false;
int            CountedTicks            =  0;


extern string     sep1c                =  "================================================================";
extern string     Stoch_Settings       =  "==== Stochastic Inputs ====";
extern int        KPeriod              =  2;
extern int        DPeriod              =  1;
extern int        Slowing              =  1;
extern int        StochMethod          =  MODE_SMA;
extern int        StochPrice           =  PRICE_CLOSE;
extern int        StochMode            =  MODE_SIGNAL;
int               stoch0,stoch1;
string            STOCHSIGNAL;
bool              STOCHUP,STOCHDN;



////////////////////////////////////////////////////////////////////////////////////////

// NB 10.7/10.9 Stuff
int             HigherTF_Used=1440;  //D1
int             HigherTF2_Used=10080;//WK1
double          D1StochMain[2],dStochMain[2],DailyStochMain,WeeklyStochMain;//Blue, yellow and red stoch lines. dStochMain[1] will hold the value up tp 5 minutes ago; dStochMain[0] the current val.
string          StoCrossStatus;//Will be one of the cross status constants declared at the top of the code
bool            BuyStoCross,SellStoCross,CloseBuyStoCross,CloseSellStoCross;

/////////////For Read indicators
bool            TradingSameTf=false;
int             indicator_shift;

extern string  sepvzo                  =  "================================================================";
extern string  vzoex                   =  "===== VZO Settings =====";
extern int     VZOPeriod               =  6;
extern int     OverBought              =  40;
extern int     OverSold                =  -40;
string         VZOSTATUS               =  "Calculating...";
double         VZO0,VZO1,VZO2,VZO3,VZO4;
double         VZO[5]; // VZO Buffer
bool           VZOBuy,VZOSell,VZOBuyClose,VZOSellClose;

extern string  sepadx                  =  "================================================================";
extern string  adxex                   =  "======= ADX Settings ======";
extern int     ADXTimeframe            =  0;
extern int     ADXPeriod               =  14;
extern int     ADXPrice                =  PRICE_CLOSE;
extern int     ADXMode                 =  MODE_MAIN;
extern int     ADX0                    =  0; // Shift
extern int     ADX1                    =  1; // Shift
extern int     ADX2                    =  2; // Shift
double         adx0,adx1,adx2;
string         ADXTREND;
bool           ADXUP,ADXDN;

extern string  sep7="================================================================";
//CheckTradingTimes. Baluda has provided all the code for this. Mny thanks Paul; you are a star.
extern string   trh            =  "====Trading hours====";
extern string   tr1            =  "tradingHours is a comma delimited list";
extern string   tr1a="of start and stop times.";
extern string   tr2="Prefix start with '+', stop with '-'";
extern string   tr2a="Use 24H format, local time.";
extern string   tr3="Example: '+07.00,-10.30,+14.15,-16.00'";
extern string   tr3a="Do not leave spaces";
extern string   tr4            =  "Blank input means 24 hour trading.";
extern string   tradingHours   =  "";
extern int      MondayStartHour=  15;//Do not allow trading on Mondsay before this time
extern int      FridayStopHour =  1; //Do not allow trading on Friday after this hour 
                                     ////////////////////////////////////////////////////////////////////////////////////////
double         TradeTimeOn[];
double         TradeTimeOff[];
// trading hours variables
int             tradeHours[];
string         tradingHoursDisplay;//tradingHours is reduced to "" on initTradingHours, so this variable saves it for screen display.
bool           TradeTimeOk;
////////////////////////////////////////////////////////////////////////////////////////

extern string   sep9="================================================================";
extern string   pts="====Swap filter====";
extern bool     CadPairsPositiveOnly=false;
extern bool     AudPairsPositiveOnly=false;
extern bool     NzdPairsPositiveOnly=false;
extern bool     OnlyTradePositiveSwap=false;
////////////////////////////////////////////////////////////////////////////////////////
double          LongSwap,ShortSwap;
////////////////////////////////////////////////////////////////////////////////////////

//Calculating the factor needed to turn pip values into their correct points value to accommodate different Digit size.
//Thanks to Lifesys for providing this code. Coders, you need to briefly turn of Wrap and turn on a mono-spaced font to view this properly and see how easy it is to make changes.
string          pipFactor[]  = {"JPY","XAG","SILVER","BRENT","WTI","XAU","GOLD","SP500","S&P","UK100","WS30","DAX30","DJ30","NAS100","CAC400"};
double          pipFactors[] = { 100,  100,  100,     100,    100,  10,   10,    10,     10,   1,      1,     1,      1,     1,       1};
double          point2Pip,pip2Point;//For pips/points stuff. Set up in int init()
                                    ////////////////////////////////////////////////////////////////////////////////////////

//Steve shell mandatory variables
int            O_R_Setting_max_retries=10;
double         O_R_Setting_sleep_time=4.0; /* seconds */
double         O_R_Setting_sleep_max=15.0; /* seconds */
int            RetryCount=10;//Will make this number of attempts to get around the trade context busy error.
bool           TakingEmergencyAction;
int            TicketNo=-1,OpenTrades;

//end of Steve shell mandatory variables

bool  SignalBuy=false;
bool  SignalSell=false;
double lot;
double   spread=0;
