//+------------------------------------------------------------------+
//|                                        iChartPatternDetector.mqh |
//|                Copyright: Andriy Moraru, www.earnforex.com, 2014 |
//|                                         http://www.earnforex.com |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Class CChartPatternDetector                                      |
//| Detects chart patterns.                                          |
//| TO BE USED WITH INDICATOR                                        |
//+------------------------------------------------------------------+

class CChartPatternDetector
{
private:
   double PairMatchingRatio;
   int LookBack;
   string NamePrefix;
   color ColorSupportUp;
   color ColorSupportDown;
   color ColorResistanceUp;
   color ColorResistanceDown;
   bool EmailAlert;
   bool SoundAlert;
   bool VisualAlert;

   int count;
   double HL_diff;
   datetime LastAlert;

   void FindLowerMatches(string);
   void HideUnmarkedLines();
   double FindPipsAngle(string);
   void DoAlert();
   void HideUnmarkedLowerLines();
   void CreateLine(datetime, double, datetime, double, string, color);
   string PeriodToString(int);
   
public:
         CChartPatternDetector(void);
         CChartPatternDetector(double, int, string, color, color, color, color, bool, bool, bool);
        ~CChartPatternDetector(void);
   void  FindLines(double, int, int, double, int);
   void  FilterPairs();
   void  FilterChannels(double);
   void  DeleteObjects();

protected:
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CChartPatternDetector::CChartPatternDetector(void)
{
   PairMatchingRatio = 0.66;
   LookBack = 150;
   NamePrefix = "LF-";
   ColorSupportUp = clrLimeGreen;
   ColorSupportDown = clrRed;
   ColorResistanceUp = clrGreen;
   ColorResistanceDown = clrMagenta;
   EmailAlert = false;
   SoundAlert = false;
   VisualAlert = false;
   
   count = 0;
   LastAlert = D'01.01.1970';
}

//+------------------------------------------------------------------+
//| Constructor with parameter                                       |
//+------------------------------------------------------------------+
CChartPatternDetector::CChartPatternDetector(double pmr, int lb, string np, color csu, color csd, color cru, color crd, bool ea, bool sa, bool va)
{
   PairMatchingRatio = pmr;
   LookBack = lb;
   NamePrefix = np;
   ColorSupportUp = csu;
   ColorSupportDown = csd;
   ColorResistanceUp = cru;
   ColorResistanceDown = crd;
   EmailAlert = ea;
   SoundAlert = sa;
   VisualAlert = va;
   
   count = 0;
   LastAlert = D'01.01.1970';
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CChartPatternDetector::~CChartPatternDetector(void)
{
}

// Deletes all objects created by CPD.
void CChartPatternDetector::DeleteObjects()
{
   int total = ObjectsTotal();
   for (int o = total - 1; o >= 0; o--)
   {
      string name_l = ObjectName(o);
      if (StringSubstr(name_l, 0, StringLen(NamePrefix)) == NamePrefix) ObjectDelete(name_l);
   }
}

// Finds trendlines going through at least 3 points with a given tolerance.
// Lines are named using prefix and a number (count).
void CChartPatternDetector::FindLines(double Threshold, int MinBars, int MaxBars, double Symmetry, int Limit)
{
   if (Limit > LookBack - 4)
   {
      Limit = LookBack - 4;
      DeleteObjects();
   }
  
   HL_diff = High[iHighest(NULL, 0, MODE_HIGH, LookBack, 1)] - Low[iLowest(NULL, 0, MODE_LOW, LookBack, 1)];
   // * 3 because of 3 points
   double adjusted_Threshold = MathPow(Threshold * HL_diff, 2) * 3;
   // i - newest point
   for (int i = 1; i <= Limit; i++)
   {
      // k - oldest point
      for (int k = i + 4; k <= LookBack; k++)
      {
         bool middle_too_low = false;
         bool middle_too_high = false;
         // Minimum length of line
         if (k - i + 1 < MinBars) continue;
         // Maximum length of line
         if (k - i + 1 > MaxBars) continue;

         // j - middle point
         for (int j = i + 2; j <= k - 2; j++)
         {
            // There should be enough symmetry between three points.
            if ((k - j) * Symmetry > j - i) continue;
            if (k - j < (j - i) * Symmetry) continue;
            
            double SumX = i + j + k;
            double XMean = SumX / 3;
            double YMean_l = (Low[i] + Low[j] + Low[k]) / 3;
            double YMean_h = (High[i] + High[j] + High[k]) / 3;
            double SumX2 = i * i + j * j + k * k;
            double SumXY_l = i * Low[i] + j * Low[j] + k * Low[k];
            double SumXY_h = i * High[i] + j * High[j] + k * High[k];
            double Slope_l = (SumXY_l - SumX * YMean_l) / (SumX2 - SumX * XMean);
            double Slope_h = (SumXY_h - SumX * YMean_h) / (SumX2 - SumX * XMean);
            double YInt_l = YMean_l - Slope_l * XMean;
            double YInt_h = YMean_h - Slope_h * XMean;
            
            double Y1_l = Slope_l * i + YInt_l;
            double Y2_l = Slope_l * j + YInt_l;
            double Y3_l = Slope_l * k + YInt_l;
            double Y1_h = Slope_h * i + YInt_h;
            double Y2_h = Slope_h * j + YInt_h;
            double Y3_h = Slope_h * k + YInt_h;
            
            double middle_point_difference_l = Y2_l - Low[j];
            double middle_point_difference_l_sqr = MathPow(middle_point_difference_l, 2);
            double Error_l = MathPow(Low[i] - Y1_l, 2) + middle_point_difference_l_sqr + MathPow(Low[k] - Y3_l, 2);
            double middle_point_difference_h = High[j] - Y2_h;
            double middle_point_difference_h_sqr = MathPow(middle_point_difference_h, 2);
            double Error_h = MathPow(High[i] - Y1_h, 2) + middle_point_difference_h_sqr + MathPow(High[k] - Y3_h, 2);
            
            // Skip if both high and low cannot be used for line due to errors.
            if ((Error_l > adjusted_Threshold) && (Error_h > adjusted_Threshold)) continue;
            
            // Middle point protrudes too deep below line, we should remember it and skip the whole i/k pair if some middle point is also too high.
            if ((middle_point_difference_l > 0) && (middle_point_difference_l_sqr > adjusted_Threshold))
            {
               middle_too_low = true;
            }
            // Middle point protrudes too high above line, we should remember it and skip the whole i/k pair if some middle point is also too deep.
            if ((middle_point_difference_h > 0) && (middle_point_difference_h_sqr > adjusted_Threshold))
            {
               middle_too_high = true;
            }
            
            if ((middle_too_low) && (middle_too_high)) break;
            
            //Print("Passed. Margin = ", DoubleToString(adjusted_Threshold - Error, 16));
            
            // A cycle to check if any bars in the middle are crossing below the support line.
            // Goes from bar i to bar k, excepting bar j.
            // Adds squares of only low-side errors
            double error_sum_l = 0;
            int error_cnt_l = 0;
            double error_sum_h = 0;
            int error_cnt_h = 0;
            for (int l = i + 1; l < k; l++)
            {
               if (Low[l] < Slope_l * l + YInt_l)
               {
                  error_sum_l += MathPow(Low[i] - Slope_l * l + YInt_l, 2);
                  error_cnt_l++;
               }
               if (High[l] > Slope_h * l + YInt_h)
               {
                  error_sum_h += MathPow(High[i] - Slope_h * l + YInt_h, 2);
                  error_cnt_h++;
               }
            }

            color Color;
            // Do not draw support line if bars are reaching too far below it.
            if ((MathPow(Threshold * HL_diff, 2) * error_cnt_l >= error_sum_l) && (Error_l <= adjusted_Threshold))
            {
               if (Y1_l >= Y3_l) Color = ColorSupportUp;
               else Color = ColorSupportDown;
               CreateLine(Time[k], Y3_l, Time[i], Y1_l, "L", Color);
            }
            // Do not draw resistance line if bars are reaching too far above it.
            if ((MathPow(Threshold * HL_diff, 2) * error_cnt_h >= error_sum_h) && (Error_h <= adjusted_Threshold))
            {
               if (Y1_h >= Y3_h) Color = ColorResistanceUp;
               else Color = ColorResistanceDown;
               CreateLine(Time[k], Y3_h, Time[i], Y1_h, "H", Color);
            }
         }
      }
   }
}

// Draws a line.
void CChartPatternDetector::CreateLine(datetime t1, double p1, datetime t2, double p2, string hl, color c)
{
   string ObjName = NamePrefix + hl + "-" + IntegerToString(count);
   ObjectCreate(ObjName, OBJ_TREND, 0, t1, p1, t2, p2);
   count++;
   ObjectSet(ObjName, OBJPROP_COLOR, c);
   ObjectSet(ObjName, OBJPROP_RAY, false);
}

// Goes through the lines drawn by LineFinder and hides all lines except those that form pairs.
void CChartPatternDetector::FilterPairs()
{
   int total = ObjectsTotal();
   for (int i = total - 1; i >= 0; i--)
   {
      string name = ObjectName(i);
      if (StringSubstr(name, 0, StringLen(NamePrefix) + 1) == NamePrefix + "H")
      {
         // Upper line
         FindLowerMatches(name);
      }
   }
   // Hides all unmarked lines.
   HideUnmarkedLines();
}

// Finds all lower lines, so that they have at least PairMatchingRatio overlap.
// Marks them by setting description.
// Special markings to easily find pairs: 
//       Upper line - set or append description with name of lower end sans prefix.
//       Lower line - set to "*".
// Distinction between higher and lower lines is purely technical - no real difference in treating when considering chart patterns.
void CChartPatternDetector::FindLowerMatches(string name_h)
{
   datetime begin_h = ObjectGet(name_h, OBJPROP_TIME1);
   datetime end_h = ObjectGet(name_h, OBJPROP_TIME2);
   string desc_h = ObjectGetString(0, name_h, OBJPROP_TEXT);

   // Delete old invisible higher lines.
   if (ObjectGet(name_h, OBJPROP_COLOR) == clrNONE)
   {
      if (iBarShift(NULL, 0, end_h) > LookBack - 4)
      {
         ObjectDelete(name_h);
         return;
      }
   }
   // Cycle through lower lines.
   int total = ObjectsTotal();
   for (int i = total - 1; i >= 0; i--)
   {
      string name_l = ObjectName(i);
      if (!name_l) // Possibly trying to access a deleted object??
      {
         Print(GetLastError());
      }
      if (StringSubstr(name_l, 0, StringLen(NamePrefix) + 1) != NamePrefix + "L") continue;

      // Delete old invisible lower lines.
      if (ObjectGet(name_l, OBJPROP_COLOR) == clrNONE)
      {
         if (iBarShift(NULL, 0, ObjectGet(name_l, OBJPROP_TIME2)) > LookBack - 4)
         {
            // Delete any reference to this lower line from upper lines' descriptions
            string desc_of_lower_for_deletion = ObjectGetString(0, name_l, OBJPROP_TEXT);
            if ((desc_of_lower_for_deletion == "*") || (desc_of_lower_for_deletion == "+"))
            {
               // Cycle through all high lines:
               int new_total = ObjectsTotal();
               for (int obj = new_total - 1; obj >= 0; obj--)
               {
                  string name_for_check = ObjectName(obj);
                  if (StringSubstr(name_for_check, 0, StringLen(NamePrefix) + 1) != NamePrefix + "H") continue;
                  string desc_for_check = ObjectGetString(0, name_for_check, OBJPROP_TEXT);
                  if (desc_for_check == "") continue;
                  int pos = 0;
                  int offset = 0;
                  while (pos != -1)
                  {
                     // All line numbers except first one need offset = +1 because of ";".
                     if (pos != 0) offset = 1;
                     int next_pos = StringFind(desc_for_check, ";", pos + 1);
                     int length = 0;
                     if (next_pos != -1) length = next_pos - pos - offset;
                     string number = StringSubstr(desc_for_check, pos + offset, length);
                     string name_lower_from_desc = NamePrefix + "L-" + number;
                     // Delete lower line number from this higher line description
                     if (name_lower_from_desc == name_l)
                     {
                        string new_desc;
                        // The only number in description
                        if ((pos == 0) && (next_pos == -1)) new_desc = "";
                        // First but not last
                        else if ((pos == 0) && (next_pos != -1)) new_desc = StringSubstr(desc_for_check, length + 1);
                        // Last in the list
                        else if ((pos != 0) && (next_pos == -1)) new_desc = StringSubstr(desc_for_check, 0, pos);
                        // Middle of the list
                        else if ((pos != 0) && (next_pos != -1)) new_desc = StringSubstr(desc_for_check, 0, pos) + StringSubstr(desc_for_check, pos + offset + length);
                        ObjectSetString(0, name_for_check, OBJPROP_TEXT, new_desc);
                     }
                     pos = StringFind(desc_for_check, ";", pos + 1);
                  }
               }
            }
            ObjectDelete(name_l);
            continue;
         }
      }

      // Check if they are already forming a pair
      string desc_l = ObjectGetString(0, name_l, OBJPROP_TEXT);
      if ((desc_h != "") && ((desc_l == "*") || (desc_l == "+")))
      {
         pos = 0;
         offset = 0;
         name_lower_from_desc = "";
         while (pos != -1)
         {
            // All line numbers except first one need offset = +1 because of ";".
            if (pos != 0) offset = 1;
            next_pos = StringFind(desc_h, ";", pos + 1);
            length = 0;
            if (next_pos != -1) length = next_pos - pos - offset;
            number = StringSubstr(desc_h, pos + offset, length);
            name_lower_from_desc = NamePrefix + "L-" + number;
            // Delete lower line number from this higher line description
            if (name_lower_from_desc == name_l) break;
            pos = StringFind(desc_h, ";", pos + 1);
         }
         if (name_lower_from_desc == name_l) continue;
      }

      datetime begin_l = ObjectGet(name_l, OBJPROP_TIME1);
      datetime end_l = ObjectGet(name_l, OBJPROP_TIME2);
      
      // It is double because it will be used in division further.
      double match = 0;
      
      // Lines do not match at all.
      if ((begin_h >= end_l) || (end_h <= begin_l)) continue;
      
      // Upper line fits inside lower line.
      if ((begin_h >= begin_l) && (end_h <= end_l)) match = end_h - begin_h;
      // Lower line fits inside higher line.
      else if ((begin_l >= begin_h) && (end_l <= end_h)) match = end_l - begin_l;
      
      // Upper line is located farther than lower.
      else if ((begin_h < end_l) && (begin_h >= begin_l)) match = end_l - begin_h;
      // Lower line is located farther than upper.
      else if ((end_h > begin_l) && (end_h <= end_l)) match = end_h - begin_l;
      
      // Poor matching of higher line.
      if (match / (end_h - begin_h) < PairMatchingRatio) continue;
      // Poor matching of lower line.
      if (match / (end_l - begin_l) < PairMatchingRatio) continue;
      // At least one line should be matched very well
      //if ((match / (end_h - begin_h) < 0.66) && (match / (end_l - begin_l) < 0.66)) continue;
      
      if (end_h > end_l)
      {
         double price_begin = ObjectGet(name_l, OBJPROP_PRICE1);
         double price_end = ObjectGet(name_l, OBJPROP_PRICE2);
         double further_end = ObjectGetShiftByValue(name_h, ObjectGet(name_h, OBJPROP_PRICE2));
         int bar_begin = ObjectGetShiftByValue(name_l, price_begin);
         int bar_end = ObjectGetShiftByValue(name_l, price_end);
         double threshold = (MathAbs(Low[bar_begin] - price_begin) + MathAbs(Low[bar_end] - price_end)) / 2;

         // Slope
         double k;
         if (price_end - price_begin == 0) k = 0; // Horizontal line
         else k = (price_end - price_begin) / (bar_end - bar_begin);
         // Y-intercept
         double b = price_begin - k * bar_begin;

         bool cross = false;
         for (int j = bar_end - 1; j >= further_end; j--)
         {
            double y = k * j + b;
            if (y - Low[j] > threshold)
            {
               cross = true;
               break;
            }
         }
         if (cross) continue;
      }
      else if (end_l > end_h)
      {
         price_begin = ObjectGet(name_h, OBJPROP_PRICE1);
         price_end = ObjectGet(name_h, OBJPROP_PRICE2);
         further_end = ObjectGetShiftByValue(name_l, ObjectGet(name_l, OBJPROP_PRICE2));
         bar_begin = ObjectGetShiftByValue(name_h, price_begin);
         bar_end = ObjectGetShiftByValue(name_h, price_end);
         threshold = (MathAbs(High[bar_begin] - price_begin) + MathAbs(High[bar_end] - price_end)) / 2;

         // Slope
         if (price_end - price_begin == 0) k = 0; // Horizontal line
         else k = (price_end - price_begin) / (bar_end - bar_begin);
         // Y-intercept
         b = price_begin - k * bar_begin;

         cross = false;
         for (j = bar_end - 1; j >= further_end; j--)
         {
            y = k * j + b;
            if (High[j] - y > threshold)
            {
               cross = true;
               break;
            }
         }
         if (cross) continue;
      }
      
      // Upper line - set or append description with name of lower end sans prefix.
      string prev_desc = ObjectGetString(0, name_h, OBJPROP_TEXT);
      string desc = StringSubstr(name_l, StringLen(NamePrefix) + 2, 0);
      if (prev_desc == "") ObjectSetString(0, name_h, OBJPROP_TEXT, desc);
      else ObjectSetString(0, name_h, OBJPROP_TEXT, prev_desc + ";" + desc);
      // Lower line - set to "*".
      if (ObjectGetString(0, name_l, OBJPROP_TEXT) != "+") ObjectSetString(0, name_l, OBJPROP_TEXT, "*");
      // Make objects visible if required
      if (ObjectGet(name_h, OBJPROP_COLOR) == clrNONE)
      {
         if (ObjectGet(name_h, OBJPROP_PRICE2) >= ObjectGet(name_h, OBJPROP_PRICE1)) ObjectSet(name_h, OBJPROP_COLOR, ColorResistanceUp);
         else ObjectSet(name_h, OBJPROP_COLOR, ColorResistanceDown);
         ObjectSet(name_h, OBJPROP_SELECTABLE, true);
      }
      if (ObjectGet(name_l, OBJPROP_COLOR) == clrNONE)
      {
         if (ObjectGet(name_l, OBJPROP_PRICE2) >= ObjectGet(name_l, OBJPROP_PRICE1)) ObjectSet(name_l, OBJPROP_COLOR, ColorSupportUp);
         else ObjectSet(name_l, OBJPROP_COLOR, ColorSupportDown);
         ObjectSet(name_l, OBJPROP_SELECTABLE, true);
      }
   }
}

// Hide all unmarked lines. Finds LF-lines and hides those with empty description field.
void CChartPatternDetector::HideUnmarkedLines()
{
   // Cycle through lower lines.
   int total = ObjectsTotal();
   for (int i = total - 1; i >= 0; i--)
   {
      string name = ObjectName(i);
      if (StringSubstr(name, 0, StringLen(NamePrefix)) != NamePrefix) continue;
      if (ObjectGetString(0, name, OBJPROP_TEXT) == "")
      {
         ObjectSet(name, OBJPROP_COLOR, clrNONE);
         ObjectSet(name, OBJPROP_SELECTABLE, false);
      }
   }   
}

// Goes through the lines filtered by LinePairFilter and hides all pairs except those that form channels.
void CChartPatternDetector::FilterChannels(double AngleDifference)
{
   int total = ObjectsTotal();
   for (int i = total - 1; i >= 0; i--)
   {
      string name = ObjectName(i);
      if (StringSubstr(name, 0, StringLen(NamePrefix) + 1) == NamePrefix + "H")
      {
         if (ObjectGet(name, OBJPROP_COLOR) == clrNONE) continue;
         // Upper line
         double pips_angle = FindPipsAngle(name);
         double lower_line_angle;
         string desc = ObjectGetString(0, name, OBJPROP_TEXT);
         int pos = 0;
         int offset = 0;
         bool preserve_high = false;
         while (pos != -1)
         {
            // All line numbers except first one need offset = +1 because of ";".
            if (pos != 0) offset = 1;
            int next_pos = StringFind(desc, ";", pos + 1);
            int length = 0;
            if (next_pos != -1) length = next_pos - pos - offset;
            string number = StringSubstr(desc, pos + offset, length);
            string name_lower = NamePrefix + "L-" + number;
            //if (ObjectGet(name_lower, OBJPROP_COLOR) == clrNONE) continue;
            lower_line_angle = FindPipsAngle(name_lower);
            pos = StringFind(desc, ";", pos + 1);
            
            // Lines angle difference in pips per bar
            if (MathMax(lower_line_angle, pips_angle) - MathMin(lower_line_angle, pips_angle) <= AngleDifference * HL_diff)
            {
               // Remember that this lower line is a part of an channel.
               ObjectSetString(0, name_lower, OBJPROP_TEXT, "+");
               preserve_high = true;
               // It's a channel. Check alerts.
               if (LastAlert < Time[1])
               {
                  // Check whether the lower line's end is on the latest completed bar.
                  if (iBarShift(NULL, 0, ObjectGet(name_lower, OBJPROP_TIME2)) == 1)
                     DoAlert();
               }
            }
         }
         // Make upper line invisible if it did not form a channel with any of its paired lower lines.
         if (!preserve_high)
         {
            ObjectSet(name, OBJPROP_COLOR, clrNONE);
            ObjectSet(name, OBJPROP_SELECTABLE, false);
         }
         // It's a channel. Check alerts.
         else if (LastAlert < Time[1])
         {
            // Check whether the higher line's end is on the latest completed bar.
            if (iBarShift(NULL, 0, ObjectGet(name, OBJPROP_TIME2)) == 1)
               DoAlert();
         }
      }
   }
   // Hide all unmarked lines.
   HideUnmarkedLowerLines();
}

// Returns angle in pips per bar for a given line.
double CChartPatternDetector::FindPipsAngle(string name)
{
   double price_start = ObjectGet(name, OBJPROP_PRICE1);
   double price_end = ObjectGet(name, OBJPROP_PRICE2);
   
   if (price_start == price_end) return(0);
   
   int bar_start = ObjectGetShiftByValue(name, price_start);
   int bar_end = ObjectGetShiftByValue(name, price_end);
   
   if (bar_start - bar_end == 0) return(0);
   
   return((price_end - price_start) / (bar_start - bar_end));
}

// Hide all unmarked lower lines. Finds LF-lines and hides those without "+" in description field.
void CChartPatternDetector::HideUnmarkedLowerLines()
{
   // Cycle through lower lines
   int total = ObjectsTotal();
   for (int i = total - 1; i >= 0; i--)
   {
      string name = ObjectName(i);
      if (StringSubstr(name, 0, StringLen(NamePrefix) + 1) != NamePrefix + "L") continue;
      if (ObjectGetString(0, name, OBJPROP_TEXT) != "+")
      {
         ObjectSet(name, OBJPROP_COLOR, clrNONE);
         ObjectSet(name, OBJPROP_SELECTABLE, false);
      }
   }   
}

// Issue relevant alerts.
void CChartPatternDetector::DoAlert()
{
   if (VisualAlert) Alert(Symbol() + " " + PeriodToString(Period()) + " at " + TimeToString(TimeCurrent()) + " - new channel.");
   if (SoundAlert) PlaySound("alert.wav");
   if (EmailAlert) SendMail("Channel Alert: " + Symbol() + " " + PeriodToString(Period()), Symbol() + " " + PeriodToString(Period()) + " at " + TimeToString(TimeCurrent()) + " - new channel.");
   LastAlert = Time[1];
}

string CChartPatternDetector::PeriodToString(int period = 0)
{
   if (period == 0) period = Period();
   switch (period)
   {
      case 43200:
         return("MN");
      case 10080:
         return("W1");
      case 1440:
         return("D1");
      case 240:
         return("H4");
      case 60:
         return("H1");
      case 30:
         return("M30");
      case 15:
         return("M15");
      case 5:
         return("M5");
      case 1:
         return("M1");
      default:
         return("");
   }
}  
//+------------------------------------------------------------------+