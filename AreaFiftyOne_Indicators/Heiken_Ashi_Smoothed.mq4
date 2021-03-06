//+------------------------------------------------------------------+
//|                                         Heiken Ashi Smoothed.mq4 |
//|                                                                  |
//|                                                      mod by Raff |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Forex-TSD.com "
#property link      "http://www.forex-tsd.com/"
//----
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Red
#property indicator_color2 Lime
#property indicator_color3 Red
#property indicator_color4 Lime
//---- parameters
extern int MaMetod =1;
extern int MaPeriod=18;
extern int MaMetod2 =1;
extern int MaPeriod2=20;
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
double ExtMapBuffer5[];
double ExtMapBuffer6[];
double ExtMapBuffer7[];
double ExtMapBuffer8[];
//----
int ExtCountedBars=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//|------------------------------------------------------------------|
int init()
  {
//---- indicators
   IndicatorBuffers(8);
   SetIndexStyle(0,DRAW_HISTOGRAM,0,1,Red);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(1,DRAW_HISTOGRAM,0,1,Aqua);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexStyle(2,DRAW_HISTOGRAM,0,3,Red);
   SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexStyle(3,DRAW_HISTOGRAM,0,3,Blue);
   SetIndexBuffer(3,ExtMapBuffer4);
//----
   SetIndexDrawBegin(0,5);
//---- indicator buffers mapping
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexBuffer(3,ExtMapBuffer4);
   SetIndexBuffer(4,ExtMapBuffer5);
   SetIndexBuffer(5,ExtMapBuffer6);
   SetIndexBuffer(6,ExtMapBuffer7);
   SetIndexBuffer(7,ExtMapBuffer8);
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- TODO: add your code here
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   double maOpen,maClose,maLow,maHigh;
   double haOpen,haHigh,haLow,haClose;
   if(Bars<=10) return(0);

   int counted_bars=IndicatorCounted();
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS)); 
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   if(counted_bars==0) limit-=1+MathMax(1,MathMax(MaPeriod,MaPeriod2));

   int pos=limit;
   while(pos>=0)
     {
      maOpen=NormalizeDouble(iMA(NULL,0,MaPeriod,0,MaMetod,PRICE_OPEN,pos),MarketInfo(NULL,MODE_DIGITS));
      maClose=NormalizeDouble(iMA(NULL,0,MaPeriod,0,MaMetod,PRICE_CLOSE,pos),MarketInfo(NULL,MODE_DIGITS));
      maLow=NormalizeDouble(iMA(NULL,0,MaPeriod,0,MaMetod,PRICE_LOW,pos),MarketInfo(NULL,MODE_DIGITS));
      maHigh=NormalizeDouble(iMA(NULL,0,MaPeriod,0,MaMetod,PRICE_HIGH,pos),MarketInfo(NULL,MODE_DIGITS));
      //----
      haOpen=(ExtMapBuffer5[pos+1]+ExtMapBuffer6[pos+1])/2;
      haClose=(maOpen+maHigh+maLow+maClose)/4;
      haHigh=MathMax(maHigh,MathMax(haOpen,haClose));
      haLow=MathMin(maLow,MathMin(haOpen,haClose));
      if(haOpen<haClose)
        {
         ExtMapBuffer7[pos]=haLow;
         ExtMapBuffer8[pos]=haHigh;
        }
      else
        {
         ExtMapBuffer7[pos]=haHigh;
         ExtMapBuffer8[pos]=haLow;
        }
      ExtMapBuffer5[pos]=haOpen;
      ExtMapBuffer6[pos]=haClose;
      pos--;
     }
   int i;
   for(i=0; i<limit; i++) 
     {
      ExtMapBuffer1[i]=NormalizeDouble(iMAOnArray(ExtMapBuffer7,0,MaPeriod2,0,MaMetod2,i),MarketInfo(NULL,MODE_DIGITS));
      ExtMapBuffer2[i]=NormalizeDouble(iMAOnArray(ExtMapBuffer8,0,MaPeriod2,0,MaMetod2,i),MarketInfo(NULL,MODE_DIGITS));
      ExtMapBuffer3[i]=NormalizeDouble(iMAOnArray(ExtMapBuffer5,0,MaPeriod2,0,MaMetod2,i),MarketInfo(NULL,MODE_DIGITS));
      ExtMapBuffer4[i]=NormalizeDouble(iMAOnArray(ExtMapBuffer6,0,MaPeriod2,0,MaMetod2,i),MarketInfo(NULL,MODE_DIGITS));
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+

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
