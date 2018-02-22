
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 Yellow
#property indicator_color2 Lime
#property indicator_color3 Lime
#property indicator_color4 Red
#property indicator_color5 Red
#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 2
#property indicator_width4 2
#property indicator_width5 2

extern int HMA_Period = 20;
extern int HMA_PriceType = 0;
extern int HMA_Method = 3;
extern bool NormalizeValues = TRUE;
extern int NormalizeDigitsPlus = 2;
extern int VerticalShift = 0;
int gi_100;
double g_ibuf_104[];
double g_ibuf_108[];
double g_ibuf_112[];
double g_ibuf_116[];
double g_ibuf_120[];
double g_ibuf_124[];

int init() {
   gi_100 = MarketInfo(Symbol(), MODE_DIGITS) + NormalizeDigitsPlus;
   IndicatorShortName("HMA(" + HMA_Period + ")");
   IndicatorDigits(gi_100);
   IndicatorBuffers(6);
   SetIndexBuffer(0, g_ibuf_104);
   SetIndexBuffer(1, g_ibuf_108);
   SetIndexBuffer(2, g_ibuf_112);
   SetIndexBuffer(3, g_ibuf_116);
   SetIndexBuffer(4, g_ibuf_120);
   SetIndexBuffer(5, g_ibuf_124);
   int li_0 = HMA_Period + MathFloor(MathSqrt(HMA_Period));
   for (int li_4 = 0; li_4 < 5; li_4++) {
      SetIndexDrawBegin(li_4, li_0);
      SetIndexLabel(li_4, "Hull Moving Average");
   }
   return (0);
}

int start() {
   int l_period_0 = MathFloor(HMA_Period / 2);
   int l_period_4 = MathFloor(MathSqrt(HMA_Period));
   int li_8 = IndicatorCounted();
   if (li_8 < 0) return (-1);
   if (li_8 > 0) li_8--;
   int li_12 = Bars - li_8;
   if (g_ibuf_104[li_12] > g_ibuf_104[li_12 + 1]) CleanPoint(li_12, g_ibuf_108, g_ibuf_112);
   if (g_ibuf_104[li_12] < g_ibuf_104[li_12 + 1]) CleanPoint(li_12, g_ibuf_116, g_ibuf_120);
   for (int li_16 = li_12; li_16 >= 0; li_16--) g_ibuf_124[li_16] = 2.0 * iMA(NULL, 0, l_period_0, 0, HMA_Method, HMA_PriceType, li_16) - iMA(NULL, 0, HMA_Period, 0, HMA_Method, HMA_PriceType, li_16);
   for (li_16 = li_12; li_16 >= 0; li_16--) {
      if (NormalizeValues) g_ibuf_104[li_16] = NormalizeDouble(iMAOnArray(g_ibuf_124, 0, l_period_4, 0, HMA_Method, li_16), gi_100) + VerticalShift * Point;
      else g_ibuf_104[li_16] = iMAOnArray(g_ibuf_124, 0, l_period_4, 0, HMA_Method, li_16) + VerticalShift * Point;
      g_ibuf_108[li_16] = EMPTY_VALUE;
      g_ibuf_112[li_16] = EMPTY_VALUE;
      g_ibuf_116[li_16] = EMPTY_VALUE;
      g_ibuf_120[li_16] = EMPTY_VALUE;
      if (g_ibuf_104[li_16] > g_ibuf_104[li_16 + 1]) PlotPoint(li_16, g_ibuf_108, g_ibuf_112, g_ibuf_104);
      if (g_ibuf_104[li_16] < g_ibuf_104[li_16 + 1]) PlotPoint(li_16, g_ibuf_116, g_ibuf_120, g_ibuf_104);
   }
   return (0);
}

void CleanPoint(int ai_0, double &ada_4[], double &ada_8[]) {
   if (ada_8[ai_0] != EMPTY_VALUE && ada_8[ai_0 + 1] != EMPTY_VALUE) {
      ada_8[ai_0 + 1] = EMPTY_VALUE;
      return;
   }
   if (ada_4[ai_0] != EMPTY_VALUE && ada_4[ai_0 + 1] != EMPTY_VALUE && ada_4[ai_0 + 2] == EMPTY_VALUE) ada_4[ai_0 + 1] = EMPTY_VALUE;
}

void PlotPoint(int ai_0, double &ada_4[], double &ada_8[], double ada_12[]) {
   if (ada_4[ai_0 + 1] == EMPTY_VALUE) {
      if (ada_4[ai_0 + 2] == EMPTY_VALUE) {
         ada_4[ai_0] = ada_12[ai_0];
         ada_4[ai_0 + 1] = ada_12[ai_0 + 1];
         ada_8[ai_0] = EMPTY_VALUE;
         return;
      }
      ada_8[ai_0] = ada_12[ai_0];
      ada_8[ai_0 + 1] = ada_12[ai_0 + 1];
      ada_4[ai_0] = EMPTY_VALUE;
      return;
   }
   ada_4[ai_0] = ada_12[ai_0];
   ada_8[ai_0] = EMPTY_VALUE;
}
//+------------------------------------------------------------------+
//| GetRelativeProgramPath                                           |
//+------------------------------------------------------------------+
string GetRelativeProgramPath()
  {
   int pos2;
//--- get the absolute path to the application
   string path=MQLInfoString(MQL_PROGRAM_PATH);
//--- find the position of "\MQL4\" substring
   int    pos=StringFind(path,"\\MQL4\\");
//--- substring not found - error
   if(pos<0)
      return(NULL);
//--- skip "\MQL4" directory
   pos+=5;
//--- skip extra '\' symbols
   while(StringGetCharacter(path,pos+1)=='\\')
      pos++;
//--- if this is a resource, return the path relative to MQL4 directory
   if(StringFind(path,"::",pos)>=0)
      return(StringSubstr(path,pos));
//--- find a separator for the first MQL4 subdirectory (for example, MQL4\Indicators)
//--- if not found, return the path relative to MQL4 directory
   if((pos2=StringFind(path,"\\",pos+1))<0)
      return(StringSubstr(path,pos));
//--- return the path relative to the subdirectory (for example, MQL4\Indicators)
   return(StringSubstr(path,pos2+1));
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
  {
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
