
/****** BEGIN IMPORTS */ 
#property strict

#import "fxlabsnet.dll"
/************************************************************************************************************
 * The following are imported functions from the fxlabsnet.dll, and are not intended to be used directly. 
 * 
 * See the public methods listed below the import section. 
 ************************************************************************************************************/ 

void InitAccount(int val); 
  
/**** timestamp conversion utilities **/
void InitTimeZoneInfo(string& err); 

int ToOANDAServerTime(int mt4Timestamp, string &err);

int ToMT4ClientTime(int unixTimestamp, string &err); 
  
/************************* Calendar functions ****************************************/ 
int Calendar(string instrument, int period, string &err);

int CalendarMerge(int &refs[], int arrSz, string &err);

int Calendar_Sz(int refnum, string &err); 

int Calendar_TS(int refnum, int idx, string &err); 

void Calendar_Headline(int refnum, int idx, string &headline, string &err); 

void Calendar_Currency(int refnum, int idx, string &currency, string &err); 

void Calendar_Free(int refnum); 

/************************* Historical Position Ratio functions ****************************************/ 
int HPR(string instrument, int period, string &err);

int HPRMerge(int &refs[], int arrSz, string &err);

int HPR_Sz(int refnum, string &err); 

void HPR_Data(int refnum, int& ts[], double& perc[], int arrSz, string &err); 

int HPR_TS(int refnum, int idx, string &err);

double HPR_Percentage(int refnum, int idx, string &err); 

void HPR_Free(int refnum); 

/************************* Orderbook functions ****************************************/ 
int Orderbook(string instrument, int period, string &err);

int OrderbookMerge(int &refs[], int arrSz, string &err);

int Orderbook_Sz(int refnum, string &err); 

int Orderbook_Timestamp(int refnum, int idx, string &err);

void Orderbook_Timestamps(int refnum, int& timestamps[], int arrSz, string &err);

int Orderbook_Price_Points_Sz(int refnum, int timestamp, string &err); 

void Orderbook_Price_Points(int refnum, int timestamp, double& pricepoints[], double& ps[], double& pl[], double& os[], double& ol[], int arrSz, string &err); 

void Orderbook_Free(int refnum); 

/************************* Spread functions *****************************************/ 

int Spreads(string instrument, int period, int unique, int real_time, string &err);

int SpreadsMerge(int &refs[], int arrSz, string &err);

void Spreads_Sz(int refnum, int& sizes[3], string &err);

/** mode = 0 - min, 1 - max, 2 - avg **/ 
void Spreads_Data(int refnum, int& timestamps[], double& spreads[], int arrSz, int mode, string &err); 

void Spreads_Free(int refnum); 

/************************* Commitments of Traders functions *****************************************/ 

int Commitments(string instrument, string &err);

int Commitments_Sz(int refnum, string &err);

void Commitments_Data(int refnum, int& timestamps[], int& ncl[], int& ncs[], int& oi[], double& price[], int arrSz, string &err); 

void Commitments_Free(int refnum); 
#import

/****** END IMPORTS */ 

// number of minutes between each update of data on the fxlabs server (in minutes) 
// (orderbook and historical position ratio data)
int FXLABS_UPDATE_INTERVAL_HPR = 21;

// number of minutes between each update of data on the fxlabs server (in minutes) 
// (spreads data)
int FXLABS_UPDATE_INTERVAL_SPR = 61; 

// number of minutes between each update of data on the fxlabs server (in minutes)
// (Commitments of traders data) 10080 = 7*24*60
int FXLABS_UPDATE_INTERVAL_COT = 10080; 


// dummy string for allocating space for messages from the DLL. 
string alloc_space = "1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890"; 
int alloc_len = 100; 

void init_fxlabs()
{
   MathSrand((int)TimeLocal()); 
   string err; 
   err = alloc_string(); 
   InitTimeZoneInfo(err);
   if (err != "") 
   {
      Print("Error occurred initializing time zone info -- timestamp conversions will be done using ad-hoc method"); 
      Print(err); 
   }  
   InitAccount(AccountNumber()); 
}

string alloc_string()
{
   // We need to allocate space for a string before calling out to the DLL. MQL4 has no way of creating a "new String()"
   // and if we simply use a string constant, it will reuse the same memory, which we don't want. To get around this 
   // limitation, we use the following trick which should ensure new memory is allocated at runtime each time we need 
   // a new string. 
   int rval = MathRand() % alloc_len;    
   return(StringSubstr(alloc_space, 0, rval) + StringSubstr(alloc_space, rval));   
   
}   

/*
 * Convert an MT4 timestamp into a "correct" unix timestamp
 * 
 * mt4_timestamp - timestamp (DateTime instance) from MT4
 * 
 * returns a 'correct' unix timestamp that corresponds to the time that MT4 intended the timestamp to represent.
 */ 
int convert_to_server_time(int mt4_timestamp)
{
   string err; 
   err = alloc_string(); 
   int retval = ToOANDAServerTime(mt4_timestamp,err); 
   if (err != "")
   {
      Print(err); 
   }
   return(retval); 
}

/*
 * Convert "correct" unix timestamp into an "incorrect" MT4 timestamp. 
 * 
 * unixtime - the unix timestamp to be converted
 * 
 * returns an 'incorrect' mt4 timestamp that Mt4 will understand as representing the given unix time. 
 */ 
int convert_to_mt4_time(int unixtime)
{
   string err; 
   err = alloc_string(); 
   int retval = ToMT4ClientTime(unixtime, err); 
   if (err != "")
   {
      Print(err); 
   }
   return(retval);    
}

/*
 * Convert array of "correct" unix timestamps into array of "incorrect" MT4 timestamps. 
 * 
 * unixtime - the unix timestamps to be converted
 */ 

void convert_to_mt4_time_arr(int& unixtime[])
{
   int sz = ArraySize(unixtime); 
   for (int i = 0; i < sz; i++)
   {
      unixtime[i] = convert_to_mt4_time(unixtime[i]);
   }
}

/* valid periods for the various fxlabs APIs */ 
int cal_periods[] = {3600,43200,86400,604800,86400*30,86400*30*3,86400*30*6,86400*365};
int hpr_periods[] = {86400,172800,604800,86400*30,86400*30*3,86400*30*6,86400*365};
int spread_periods[] = {3600,43200,86400,604800,86400*30,86400*30*3,86400*30*6,86400*365};
int ordbk_periods[] = {3600,21600,86400,604800,86400*30,86400*365};

/*
 * Return the first valid period >= p
 */ 
int get_period(int& periods[], int p)
{

   int sz = ArraySize(periods); 
   int idx = 0;    
  
   for (; idx < sz && p > periods[idx]; idx++) ; 
     
   if (idx >= sz) return periods[sz-1]; 
   return periods[idx];           
}

/****** BEGIN PUBLIC METHODS */ 

/****************************************************** CALENDAR ****************************************/ 
/* Calendar data contains information about news events associated with instruments. Each news event
/* has an associated headline, currency and timestamp. 
/* 
/* To retrieve data, use the calendar() function. This function will return a reference number to the
/* data retrieved. 
/*
/* To determine how many events were retrieved, pass the reference number to calendar_sz(). 
/* 
/* To extract headline, timestamp, and currency information for an individual event, use the reference
/* number with the calendar_headline(), calendar_currency(), and calendar_ts() functions. 
/* 
/********************************************************************************************************/ 

/* 
 * instrument - currency pair (e.g., "EUR_USD") for which to retrieve calendar data
 * period - duration of time (in seconds) for which to retrieve data. (I.e., data is from [now-period, now])
 * 
 * Returns an integer reference to the data retrieved. Use
 * the functions below for retrieving data associated with this reference. 
 * -1 is returned if an error occurs. 
 */ 
int calendar(string instrument, int period)
{   
   period = get_period(cal_periods, period); 
   
   string errstr;
   errstr = alloc_string(); 
   int ref = Calendar(instrument,period,errstr);
   if (errstr != "") Print("calendar error: ",errstr); 
   return(ref); 
}  

/*
 * refs - array of references returned by calendar() that should be 
 *        merged into one new reference
 * sz - the number of elements in refs (could be fewer than ArraySize(refs)
 *      if only some of the refs are to be merged)
 * 
 * Returns an integer reference to the combined data represented
 * by the passed in references. References are merged in the order
 * given in the array. 
 */ 
int calendar_merge(int &refs[], int sz)
{
   string errstr;
   errstr = alloc_string();
   int ref = CalendarMerge(refs, sz, errstr);
   if (errstr != "") Print(errstr); 
   return(ref); 
}



/*
 * ref - the integer reference returned by calendar()
 *
 * Returns the number of different news events available. 
 * -1 is returned if an error occurs. 
 */ 
int calendar_sz(int ref) 
{
   string errstr;
   errstr = alloc_string(); 
   
   int sizeval = Calendar_Sz(ref, errstr); 
   if (errstr != "") Print("calendar_sz error: ",errstr); 
   return(sizeval); 
}


/*
 * ref - the integer reference returned by calendar()
 * 
 * idx - Zero-based index of the news event to retrieve. 
 * (Should be less than value reported by calendar_sz())
 *
 * returns the calendar headline for the news event at the given index. 
 * if an error occurs, the empty string is returned. 
 */ 
string calendar_headline(int ref, int idx)
{
   string errstr;
   string headline;
   errstr = alloc_string(); 
   headline = alloc_string(); 
   Calendar_Headline(ref, idx, headline, errstr);
   if (errstr != "") Print(errstr); 
   return(headline); 
}

/*
 * ref - the integer reference returned by calendar()
 * 
 * idx - Zero-based index of the news event to retrieve. 
 * (Should be less than value reported by calendar_sz())
 *
 * returns the timestamp of the news event at the given index. 
 * -1 is returned if an error occurs. 
 */ 
int calendar_ts(int ref, int idx)
{
   string errstr;
   errstr = alloc_string(); 
   int ts = Calendar_TS(ref, idx, errstr); 
   if (errstr != "") Print(errstr); 
   return(ts); 
}

/*
 * ref - the integer reference returned by calendar()
 * 
 * idx - Zero-based index of the news event to retrieve.
 * (Should be less than the value reported by calendar_sz())
 *
 * returns the currency of the news event at the given index
 * if an error occurs, the empty string is returned. 
 */ 
string calendar_currency(int ref, int idx)
{
   string errstr;
   string currency;
   errstr = alloc_string(); 
   currency = alloc_string();
   Calendar_Currency(ref,idx,currency,errstr); 
   if (errstr != "") Print(errstr); 
   return(currency); 
}

/*
 * ref - the integer reference returned by calendar()
 * 
 * Free the internal memory associated with ref. Should always be
 * called after the news event associated with the reference is
 * no longer needed. 
 */ 
void calendar_free(int ref)
{
   Calendar_Free(ref);
}

/****************************************************** HISTORICAL POSITION RATIO (HPR) ************************/ 
/* Historical position ratios (HPRs) provide information about what percentage of customers had long positions
/* at given points in the past. A value of 50 for percentage long means all clients are even long/short. A 
/* value of 30 means 30% of customers are long, 70% are short. 
/*
/* To retrieve HPR data, use the hpr() function specifying the instrument and start and end times that are
/* of interest. hpr() returns a reference number to the data retrieved. 
/*
/* To get the number of different HPRs retrieved, pass the reference number to hpr_sz(). 
/*
/* To extract the timestamp and percentage long an instance of HPR data, use the hpr_ts() and hpr_perc()
/* functions. 
/*
/* To extract all HPR data into parallel arrays, use the hpr_data() function. 
/*********************************************************************************************************/ 

/* 
 * instrument - currency pair (e.g., "EUR_USD") for which to retrieve HPR data
 * period - duration of time (in seconds) for which to retrieve data. (I.e., data is from [now-period, now])
 * 
 * Returns an integer reference to the data retrieved. Use
 * the functions below for retrieving data associated with this reference. 
 * -1 is returned if an error occurs. 
 */ 
int hpr(string instrument, int period)
{
   period = get_period(hpr_periods, period); 

   string errstr;
   errstr = alloc_string(); 
   int ref = HPR(instrument, period, errstr); 
   if (errstr != "") Print(errstr); 
   return(ref);  
}

/*
 * refs - array of references returned by hpr() that should be 
 *        merged into one new reference
 * sz - the number of elements in refs (could be fewer than ArraySize(refs)
 *      if only some of the refs are to be merged)
 * 
 * Returns an integer reference to the combined data represented
 * by the passed in references. References are merged in the order
 * given in the array. 
 */ 
int hpr_merge(int &refs[], int sz)
{
   string errstr;
   errstr = alloc_string();
   int ref = HPRMerge(refs, sz, errstr);
   if (errstr != "") Print(errstr); 
   return(ref); 
}

/*
 * ref - the integer reference returned by hpr()
 *
 * Returns the number of different HPRs available. 
 * -1 is returned if an error occurs. 
 */ 
int hpr_sz(int ref) 
{
   string errstr; 
   errstr = alloc_string(); 
   int sz = HPR_Sz(ref, errstr); 
   if (errstr != "") Print(errstr); 
   return(sz); 
}

/*
 * Populate HPR data into parallel arrays. 
 *
 * refnum - the integer reference returned by hpr()
 * 
 * ts - array of integers where timestamps are to be populated. The array should have at least as many
 * elements as reported by hpr_sz(). If it has more elements than hpr_sz(), then the array 
 * will be filled starting at index 0 up to the number of HPRs. If it has less elements, then 
 * it will only be filled up to the number of elements available (no error will be reported in this case). 
 * 
 * perc - array of double where long percentages are to be populated. Must be the same size as ts array.
 *
 * return true if arrays were populated successfully, false otherwise. 
 */
bool hpr_data(int refnum, int& ts[], double& perc[])
{   
   if (ArraySize(ts) != ArraySize(perc))
   {
      Print("error: hpr_data - array sizes not equal");
      return(false);
   }
   
   string errstr;
   errstr = alloc_string(); 
   HPR_Data(refnum, ts, perc, ArraySize(ts), errstr); 
   if (errstr != "") 
   {
      Print(errstr);
      return(false);
   }
   return(true);
}

/*
 * ref - the integer reference returned by hpr()
 * 
 * idx - Zero-based index of the HPR to retrieve. 
 * (Should be less than value reported by hpr_sz())
 *
 * returns the timestamp of the HPR at the given index. 
 * -1 is returned if an error occurs. 
 */ 
int hpr_ts(int ref, int idx)
{
   string errstr; 
   errstr = alloc_string(); 
   int ts = HPR_TS(ref, idx, errstr); 
   if (errstr != "") Print(errstr); 
   return(ts);  
}

/*
 * ref - the integer reference returned by hpr()
 * 
 * idx - Zero-based index of the HPR to retrieve. 
 * (Should be less than value reported by hpr_sz())
 *
 * returns the percentage of customers long at the given index. 
 * -1 is returned if an error occurs. 
 */ 
double hpr_percentage(int ref, int idx)
{
   string errstr; 
   errstr = alloc_string(); 
   double perc = HPR_Percentage(ref,idx,errstr); 
   if (errstr != "") Print(errstr);
   return(perc); 
}

/*
 * ref - the integer reference returned by calendar()
 * 
 * Free the internal memory associated with ref. Should always be
 * called after the HPR associated with the reference is
 * no longer needed. 
 */ 
void hpr_free(int ref)
{
   HPR_Free(ref);
}


/****************************************************** ORDERBOOK ****************************************/ 
/* Orderbook data contains detailed historical information about the percentage of limit (pending) orders 
/* that were long/short and the percentage of positions that were long/short. Orderbook data is more
/* fine-grained than HPR data, since it contains the percentage of positions that are short/long at 
/* different price points. 
/*
/* To retrieve orderbook data, use the orderbook() function, specifying the instrument, period. 
/* This function will return a reference number to the data retrieved. 
/*
/* To retrieve the number of orderbook entries associated with a reference number, use the orderbook_sz() 
/* function. 
/*
/* An orderbook entry consists of a timestamp, and associated price point data. Each price point contains
/* four pieces of data: ps (percentage of short positions), pl (percentage of long positions), 
/* os (percentage of short limit orders), ol (percentage of long limit orders). 
/*
/* To extract the timestamps of all available orderbook entries into an array, use orderbook_timestamps().
/*
/* To retrieve the number of different price points in an orderbook entry, use orderbook_price_points_sz(). 
/*
/* To extract all price point data of an orderbook entry into parallel arrays, use orderbook_price_points(). 
/* 
/* 
/*********************************************************************************************************/ 

/* 
 * instrument - currency pair (e.g., "EUR_USD") for which to retrieve orderbook data
 * period - duration of time (in seconds) for which to retrieve data. (I.e., data is from [now-period, now])
 * 
 * Returns an integer reference to the data retrieved. Use
 * the functions below for retrieving data associated with this reference. 
 */ 
int orderbook(string instrument, int period)
{
   period = get_period(ordbk_periods, period); 
   
   string errstr;
   errstr = alloc_string(); 
   int ref = Orderbook(instrument, period, errstr); 
   if (errstr != "") Print(errstr); 
   return(ref); 
}

/*
 * refs - array of references returned by orderbook() that should be 
 *        merged into one new reference
 * sz - the number of elements in refs (could be fewer than ArraySize(refs)
 *      if only some of the refs are to be merged)
 * 
 * Returns an integer reference to the combined data represented
 * by the passed in references. References are merged in the order
 * given in the array. 
 */ 
int orderbook_merge(int &refs[], int sz)
{
   string errstr;
   errstr = alloc_string();
   int ref = OrderbookMerge(refs, sz, errstr);
   if (errstr != "") Print(errstr); 
   return(ref); 
}


/*
 * ref - the integer reference returned by orderbook()
 *
 * Returns the number of different orderbook entries available. 
 */ 
int orderbook_sz(int refnum)
{
   string errstr;
   errstr = alloc_string(); 
   int sz = Orderbook_Sz(refnum, errstr); 
   if (errstr != "") Print(errstr); 
   return(sz); 
}

/*
 * ref - the integer reference returned by orderbook()
 * 
 * idx - Zero-based index of the orderbook entry to retrieve. 
 * (Should be less than value reported by orderbook_sz())
 *
 * returns the timestamp of the orderbook entry at the given index. 
 * -1 is returned if an error occurs. 
 *
 * NOTE: For efficiency, it's recommended that if all
 * timestamps are required, the orderbook_timestamps
 * function be used to populate an entire MT4 array, 
 * instead of getting each one individually from this
 * function. 
 */ 
int orderbook_timestamp(int refnum, int idx)
{
   string errstr; 
   errstr = alloc_string(); 
   int ts = Orderbook_Timestamp(refnum, idx, errstr); 
   if (errstr != "") Print(errstr); 
   return(ts);  
}

/*
 * Fills the timestamps array with the timestamps of orderbook entries. 
 * 
 * refnum - the integer reference returned by orderbook()
 * 
 * timestamps - array with which orderbook timestamps should
 * be filled. Should have at least as many entries as
 * orderbook_sz(). 
 *
 * returns True if filling the timestamps array is successful, false otherwise. 
 */ 
bool orderbook_timestamps(int refnum, int& timestamps[])
{
   string errstr;
   errstr = alloc_string(); 
   Orderbook_Timestamps(refnum, timestamps, ArraySize(timestamps), errstr); 
   if (errstr != "") 
   {
      Print(errstr); 
      return(false);
   }
   return(true);
}

/*
 * refnum - the integer reference returned by orderbook()
 *
 * timestamp - the timestamp for the orderbook entry of interest.
 *
 * Returns the number of different price points in the given orderbook entry. 
 * -1 is returned if an error occurs. 
 */ 
int orderbook_price_points_sz(int refnum, int timestamp)
{
   string errstr;
   errstr = alloc_string(); 
   int sz = Orderbook_Price_Points_Sz(refnum, timestamp, errstr); 
   if (errstr != "") Print(errstr); 
   return(sz); 
}

/*
 * refnum - integer reference returned by orderbook()
 *
 * timestamp - the timestamp for the orderbook entry of interest
 * 
 * pricepoints - array to be filled with the price points of the given orderbook entry. 
 * (Should contain at least as many elements as reported by orderbook_price_points_sz)
 *
 * ps - array to be filled with percentage of short positions. Must be same size as pricepoints array. 
 *
 * pl - array to be filled with percentage of long positions. Must be same size as pricepoints array. 
 *
 * os - array to be filled with percentage of short (limit) orders. Must be same size as pricepoints array. 
 *
 * ol - array to be filled with percentage of long (limit) orders. Must be same size as pricepoints array. 
 *
 * returns true if filling arrays is successful, false otherwise. 
 */ 
bool orderbook_price_points(int refnum, int timestamp, double& pricepoints[], double& ps[], double& pl[], double& os[], double& ol[])
{
   int arrSz1 = ArraySize(pricepoints);
   int arrSz2 = ArraySize(ps); 
   int arrSz3 = ArraySize(pl); 
   int arrSz4 = ArraySize(os);
   int arrSz5 = ArraySize(ol);
   if (arrSz1 != arrSz2 || arrSz1 != arrSz3 || arrSz1 != arrSz4 || arrSz1 != arrSz5)
   {
      Print("error: orderbook_price_points - array sizes not equal");
      return(false);
   }
   
   string errstr;
   errstr = alloc_string(); 
   Orderbook_Price_Points(refnum, timestamp, pricepoints, ps, pl, os, ol, arrSz1, errstr); 
   if (errstr != "") 
   {
      Print(errstr); 
      return(false);
   }
   
   return(true);
}

/*
 * ref - the integer reference returned by calendar()
 * 
 * Free the internal memory associated with ref. Should always be
 * called after the orderbook associated with the reference is
 * no longer needed. 
 */ 
void orderbook_free(int refnum)
{
   Orderbook_Free(refnum);
}


/****************************************************** SPREADS ****************************************/ 
/* Spread data contains historical information about the min, max, and average OANDA spreads. 
/*
/* To retrieve spread data, use the spreads() function. This function returns an integer reference
/* to the data retrieved. 
/*
/* To retrieve the number of {min,max,avg} spread entries, use spreads_{min,max,avg}_sz(). 
/*
/* To extract {min,max,avg} spreads and timestamps into parallel arrays, use spreads_{min,max,avg}(). 
/*
/******************************************************************************************************/ 

/* 
 * instrument - currency pair (e.g., "EUR_USD") for which to retrieve spread data
 * period - duration of time (in seconds) for which to retrieve data. (I.e., data is from [now-period, now])
 * unique - whether to return unique data set (only send changes), or send all data points (true|false)
 * real_time: real time data or limit to midnight to midnight. If true, then data returned will contain 
 * the latest data possible, if false, data will be up to the last midnight
 * 
 * Returns an integer reference to the data retrieved. Use
 * the functions below for retrieving data associated with this reference. 
 * -1 is returned if an error occurs. 
 */ 
int spreads(string instrument, int period, bool unique, bool real_time)
{
   period = get_period(spread_periods, period); 

   string errstr;
   errstr = alloc_string(); 
   int ref = Spreads(instrument, period, unique, real_time, errstr); 
   if (errstr != "") Print(errstr); 
   return(ref); 
}

/*
 * refs - array of references returned by spreads() that should be 
 *        merged into one new reference
 * sz - the number of elements in refs (could be fewer than ArraySize(refs)
 *      if only some of the refs are to be merged)
 * 
 * Returns an integer reference to the combined data represented
 * by the passed in references. References are merged in the order
 * given in the array. 
 */ 
int spreads_merge(int &refs[], int sz)
{
   string errstr;
   errstr = alloc_string();
   int ref = SpreadsMerge(refs, sz, errstr);
   if (errstr != "") Print(errstr); 
   return(ref); 
}


/*** helper function ***/ 
void get_spreads_sizes(int refnum, int& sizes[3])
{
   string errstr;
   errstr = alloc_string(); 
   Spreads_Sz(refnum, sizes, errstr); 
   if (errstr != "") Print(errstr); 
}

/*
 * refnum - reference number returned by spreads().
 * 
 * returns the number of data points in the minimum spread array. 
 * -1 is returned if an error occurs. 
 */ 
int spreads_min_sz(int refnum)
{
   int sizes[3]; 
   get_spreads_sizes(refnum, sizes); 
   return(sizes[0]); 
}

/*
 * refnum - reference number returned by spreads().
 * 
 * returns the number of data points in the maximum spread array. 
 * -1 is returned if an error occurs. 
 */ 
int spreads_max_sz(int refnum)
{
   int sizes[3]; 
   get_spreads_sizes(refnum, sizes); 
   return(sizes[1]); 
}

/*
 * refnum - reference number returned by spreads().
 * 
 * returns the number of data points in the average spread array. 
 * -1 is returned if an error occurs. 
 */ 
int spreads_avg_sz(int refnum)
{
   int sizes[3]; 
   get_spreads_sizes(refnum, sizes); 
   return(sizes[2]); 
}

/*** helper function ***/ 
bool get_spreads(int refnum, int& timestamps[], double& spreads[], int mode)
{
   if (ArraySize(timestamps) != ArraySize(spreads))
   {
      Print("error: retrieving spreads - array sizes not equal"); 
      return(false);
   }
   string errstr;
   errstr = alloc_string(); 
   Spreads_Data(refnum, timestamps, spreads, ArraySize(timestamps), mode, errstr); 
   if (errstr != "") {
      Print(errstr); 
      return(false);
   }
   return(true);
}

/*
 * Fills parallel arrays with the minimum spread data. 
 *
 * refnum - reference number returned by spreads(). 
 *
 * timestamps - the array to be filled with timestamps. (Should be
 * at least as large as the value reported by spreads_min_sz()). 
 *
 * spreads - the array to be filled with the spread data. 
 * Must be the same size as the timestamps array. 
 *
 * Return true if filling the arrays was successful, false otherwise. 
 */ 
bool spreads_min(int refnum, int& timestamps[], double& spreads[])
{
   return(get_spreads(refnum, timestamps, spreads, 0));
}

/*
 * Fills parallel arrays with the maximum spread data. 
 *
 * refnum - reference number returned by spreads(). 
 *
 * timestamps - the array to be filled with timestamps. (Should be
 * at least as large as the value reported by spreads_max_sz()). 
 *
 * spreads - the array to be filled with the spread data. 
 * Must be the same size as the timestamps array. 
 *
 * Return true if filling the arrays was successful, false otherwise. 
 */ 
bool spreads_max(int refnum, int& timestamps[], double& spreads[])
{
   return(get_spreads(refnum, timestamps, spreads, 1)); 
}

/*
 * Fills parallel arrays with the average spread data. 
 *
 * refnum - reference number returned by spreads(). 
 *
 * timestamps - the array to be filled with timestamps. (Should be
 * at least as large as the value reported by spreads_avg_sz()). 
 *
 * spreads - the array to be filled with the spread data. 
 * Must be the same size as the timestamps array. 
 *
 * Return true if filling the arrays was successful, false otherwise. 
 */ 
bool spreads_avg(int refnum, int& timestamps[], double& spreads[])
{
   return(get_spreads(refnum, timestamps, spreads, 2)); 
}

/*
 * ref - the integer reference returned by calendar()
 * 
 * Free the internal memory associated with ref. Should always be
 * called after the spread data associated with the reference is
 * no longer needed. 
 */ 
void spreads_free(int refnum)
{
   Spreads_Free(refnum); 
}

/***************************************************** COMMITMENTS OF TRADERS (COT) ***********************/ 
/* 4 years of COT data from the CFTC
/* 
/* To retrieve COT data, use commitments(). This function returns an integer reference to the data 
/* retrieved. 
/* 
/* To retrieve the number of COT entries available, use commitments_sz(). 
/*
/* Each COT entry contains the following data: timestamp, ncl (number of non-commercial long positions),
/* ncs (non-commercial short positions), oi (open interest, total number of contracts), price (exchange
/* rate price), unit (string describing the unit of measurement). 
/*
/* To extract COT entries into parallel arrays, use commitments_data(). 
/**********************************************************************************************************/

/* 
 * instrument - currency pair (e.g., "EUR_USD") for which to retrieve orderbook data
 * 
 * Returns an integer reference to the data retrieved. Use
 * the functions below for retrieving data associated with this reference. 
 */ 
int commitments(string instrument)
{
   string errstr;
   errstr = alloc_string(); 
   int ref = Commitments(instrument,errstr);
   if (errstr != "") Print(errstr); 
   return(ref); 
}  

/*
 * ref - the integer reference returned by commitments()
 *
 * Returns the number of different COT entries available
 */ 
int commitments_sz(int ref) 
{
   string errstr;
   errstr = alloc_string(); 
   int sizeval = Commitments_Sz(ref, errstr); 
   if (errstr != "") Print(errstr); 
   return(sizeval); 
}

/*
 * Populate COT data into parallel arrays. 
 *
 * refnum - the integer reference returned by commitments()
 * 
 * ts - array of integers where timestamps are to be populated. The array should have at least as many
 * elements as reported by commitements_sz(). If it has more elements than commitements_sz(), then the array 
 * will be filled starting at index 0 up to the number of COT entries. If it has less elements, then 
 * it will only be filled up to the number of elements available (no error will be reported in this case). 
 * 
 * ncl - array to be filled with number of non-commercial long positions. Must be the same size as ts. 
 *
 * ncs - array to be filled with number of non-commercial short positions. Must be the same size as ts. 
 * 
 * oi - array to be filled with number of open interest contracts. Must be the same size as ts. 
 *
 * price - array to be filled with exchange rates. Must be the same size as ts. 
 *
 * unit - array to be filled with strings describing units of measurement. Must be the same size as ts. 
 *
 * return true if arrays were populated successfully, false otherwise. 
 */
 
bool commitments_data(int refnum, int& ts[], int& ncl[], int& ncs[], int& oi[], double& price[])
{
   int arrSz1 = ArraySize(ts);
   int arrSz2 = ArraySize(ncl);
   int arrSz3 = ArraySize(ncs);
   int arrSz4 = ArraySize(oi); 
   int arrSz5 = ArraySize(price);
   
   if (arrSz1 != arrSz2 || arrSz1 != arrSz3 || arrSz1 != arrSz4 || arrSz1 != arrSz5) 
   {
      Print("error: commitments_data - array sizes not equal");
      return(false);
   }
   
   string errstr;
   errstr = alloc_string(); 
   Commitments_Data(refnum, ts, ncl,ncs,oi,price, arrSz1, errstr); 
   if (errstr != "") 
   {
      Print(errstr);
      return(false);
   }
   return(true);
} 

/*
 * ref - the integer reference returned by calendar()
 * 
 * Free the internal memory associated with ref. Should always be
 * called after the commitments data associated with the reference is
 * no longer needed. 
 */ 
void commitments_free(int refnum)
{
   Commitments_Free(refnum);
}

/****** END PUBLIC METHODS */ 

