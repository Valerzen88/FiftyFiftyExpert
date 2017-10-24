#property copyright "Shahrooz Sadeghi"
#property link      "sh.sadeghi.me@gmail.com"

#property indicator_separate_window
#property indicator_minimum 0.0
#property indicator_maximum 10.0
#property indicator_buffers 3
#property indicator_color1 Lime
#property indicator_width1 2
#property indicator_color2 Red
#property indicator_width2 2
#property indicator_color3 CLR_NONE

extern int TimeFrame = 0;
int g_period_80 = 4;
int gi_84 = 5;
double g_ibuf_88[];
double g_ibuf_92[];
double g_ibuf_96[];

int OnInit() {
   string ls_unused_0;
   string ls_12;
   switch (TimeFrame) {
   case 1:
      ls_12 = "Period_M1";
      break;
   case 5:
      ls_12 = "Period_M5";
      break;
   case 15:
      ls_12 = "Period_M15";
      break;
   case 30:
      ls_12 = "Period_M30";
      break;
   case 60:
      ls_12 = "Period_H1";
      break;
   case 240:
      ls_12 = "Period_H4";
      break;
   case 1440:
      ls_12 = "Period_D1";
      break;
   case 10080:
      ls_12 = "Period_W1";
      break;
   case 43200:
      ls_12 = "Period_MN1";
      break;
   default:
      ls_12 = "Current Timeframe";
   }
   IndicatorShortName(" MTF_$hah ( " + ls_12 + " ) ");
   IndicatorBuffers(3);
   SetIndexBuffer(0, g_ibuf_88);
   SetIndexStyle(0, DRAW_ARROW);
   SetIndexArrow(0, 172);
   SetIndexLabel(0, "Bullish  [" + TimeFrame + "]");
   SetIndexBuffer(1, g_ibuf_92);
   SetIndexStyle(1, DRAW_ARROW);
   SetIndexArrow(1, 172);
   SetIndexLabel(1, "Bearish  [" + TimeFrame + "]");
   SetIndexBuffer(2, g_ibuf_96);
   SetIndexStyle(2, DRAW_ARROW);
   SetIndexArrow(2, 172);
   SetIndexLabel(2, "Neutral  [" + TimeFrame + "]");
   return (0);
}

int start() {
   int lia_0[];
   int index_16 = 0;
   int ind_counted_20 = IndicatorCounted();
   ArrayCopySeries(lia_0, 5, Symbol(), TimeFrame);
   int li_12 = Bars - ind_counted_20;
   int index_4 = 0;
   for (index_4 = 0; index_4 < li_12; index_4++) {
      if (Time[index_4] < lia_0[index_16]) index_16++;
      if (Close[index_4] > iMA(Symbol(), TimeFrame, g_period_80, 0, MODE_SMA, PRICE_HIGH, index_4 + 1)) {
         g_ibuf_88[index_4] = gi_84;
         g_ibuf_92[index_4] = EMPTY_VALUE;
         g_ibuf_96[index_4] = EMPTY_VALUE;
      } else {
         if (Close[index_4] < iMA(Symbol(), TimeFrame, g_period_80, 0, MODE_SMA, PRICE_LOW, index_4 + 1)) {
            g_ibuf_88[index_4] = EMPTY_VALUE;
            g_ibuf_92[index_4] = gi_84;
            g_ibuf_96[index_4] = EMPTY_VALUE;
         } else {
            g_ibuf_88[index_4] = EMPTY_VALUE;
            g_ibuf_92[index_4] = EMPTY_VALUE;
            g_ibuf_96[index_4] = gi_84;
         }
      }
   }
   return (0);
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
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- The first way to get the uninitialization reason code 
//Print(__FUNCTION__,"_Uninitalization reason code = ",reason);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
//---
   double ret=0.0;
//---
   return(ret);
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
