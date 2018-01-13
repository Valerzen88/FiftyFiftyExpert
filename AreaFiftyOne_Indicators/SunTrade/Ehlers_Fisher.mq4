//+----------------------------------------------------------+
//|                              Ehlers fisher transform.mq4 |
//|                                                   mladen |
//+----------------------------------------------------------+
#property  copyright "mladen"
#property  link      "mladenfx@gmail.com"

#property  indicator_separate_window
#property  indicator_buffers 8
#property  indicator_color1  clrDeepSkyBlue
#property  indicator_color2  clrDeepSkyBlue
#property  indicator_color3  clrSandyBrown
#property  indicator_color4  clrSandyBrown
#property  indicator_color5  clrDeepSkyBlue
#property  indicator_color6  clrSandyBrown
#property  indicator_color7  clrSandyBrown
#property  indicator_color8  clrSilver
#property  indicator_width1  2
#property  indicator_width3  2
#property  indicator_width5  3
#property  indicator_width6  3
#property  indicator_width7  3
#property  indicator_style8  STYLE_DOT
#property  strict

enum enPrices
{
   pr_close,      // Close
   pr_open,       // Open
   pr_high,       // High
   pr_low,        // Low
   pr_median,     // Median
   pr_typical,    // Typical
   pr_weighted,   // Weighted
   pr_average,    // Average (high+low+open+close)/4
   pr_medianb,    // Average median body (open+close)/2
   pr_tbiased,    // Trend biased price
   pr_haclose,    // Heiken ashi close
   pr_haopen ,    // Heiken ashi open
   pr_hahigh,     // Heiken ashi high
   pr_halow,      // Heiken ashi low
   pr_hamedian,   // Heiken ashi median
   pr_hatypical,  // Heiken ashi typical
   pr_haweighted, // Heiken ashi weighted
   pr_haaverage,  // Heiken ashi average
   pr_hamedianb,  // Heiken ashi median body
   pr_hatbiased   // Heiken ashi trend biased price
};
enum enFilterWhat
{
   flt_prc,  // Filter the price
   flt_val,  // Filter the fisher transform value
   flt_both  // Filter both
};

extern int          period       = 25;             // Transform period
extern enPrices     PriceType    = pr_median;      // Price to use
extern double       Weight       = 2;              // Smoothing weight
extern double       Filter       = 0;              // Filter to use for filtering (<=0 - no filtering)
extern int          FilterPeriod = 0;              // Filter period (0<= to use transform period)
extern enFilterWhat FilterOn     = flt_val;        // Apply filter to :
extern bool         alertsOn        = false;        // Turn alerts on?
extern bool         alertsOnCurrent = false;       // Alerts on current (still opened) bar?
extern bool         alertsMessage   = false;        // Alerts should show pop-up message?
extern bool         alertsSound     = false;       // Alerts should play alert sound?
extern bool         alertsPushNotif = false;       // Alerts should send push notification?
extern bool         alertsEmail     = false;       // Alerts should send email?

double buffer1[],histouu[],histoud[],histodd[],histodu[];
double buffer2[];
double buffer3[];
double buffer4[];
double Prices[];
double Values[];
double Cross[],slope[];

//+----------------------------------------------------------+
//|                                                          |
//+----------------------------------------------------------+
int init()
{
   IndicatorBuffers(12);
      SetIndexBuffer(0,histouu); SetIndexStyle(0,DRAW_HISTOGRAM);
      SetIndexBuffer(1,histoud); SetIndexStyle(1,DRAW_HISTOGRAM);
      SetIndexBuffer(2,histodd); SetIndexStyle(2,DRAW_HISTOGRAM);
      SetIndexBuffer(3,histodu); SetIndexStyle(3,DRAW_HISTOGRAM);
      SetIndexBuffer(4,buffer1);
      SetIndexBuffer(5,buffer2);
      SetIndexBuffer(6,buffer3);
      SetIndexBuffer(7,buffer4);
      SetIndexBuffer(8,Prices);
      SetIndexBuffer(9,Values);
      SetIndexBuffer(10,Cross);
      SetIndexBuffer(11,slope);
   IndicatorShortName("Ehlers\' Fisher transform ("+(string)period+","+(string)Filter+")");
   return(0);
}


//----------------------------------------------------------
//
//----------------------------------------------------------
int start()
{
   static int previousCounted=0; int counted_bars=IndicatorCounted();
      if(counted_bars < 0) return(-1);
      if(counted_bars > 0) counted_bars--;
           int limit = MathMin(Bars-counted_bars,Bars-1);
   if(limit>500)limit=500;        
   int    tperiod = FilterPeriod; if (tperiod<=0) tperiod = period;
   double pfilter = Filter;       if (FilterOn==flt_val) pfilter=0;
   double vfilter = Filter;       if (FilterOn==flt_prc) vfilter=0;
   double alpha = 2.0/(1.0+Weight);         
   if (Cross[limit]==-1) CleanPoint(limit,buffer2,buffer3);
   for(int i=limit; i>=0; i--)
   {  
      Prices[i] = iFilter(getPrice(PriceType,Open,Close,High,Low,i),pfilter,tperiod,i,0);
                  
         double MaxH = Prices[ArrayMaximum(Prices,period,i)];
         double MinL = Prices[ArrayMinimum(Prices,period,i)];
         if (MaxH!=MinL && i<Bars-1)
               Values[i] = alpha*((Prices[i]-MinL)/(MaxH-MinL)-0.5+Values[i+1]);
         else  Values[i] = 0.00;
               Values[i] = MathMin(MathMax(Values[i],-0.999),0.999); 
      if (i<Bars-1)
      {
         buffer1[i] = iFilter(0.5*MathLog((1+Values[i])/(1-Values[i]))+0.5*buffer1[i+1],vfilter,tperiod,i,1);
         buffer2[i] = EMPTY_VALUE;
         buffer3[i] = EMPTY_VALUE;
         histouu[i] = EMPTY_VALUE;
         histoud[i] = EMPTY_VALUE;
         histodd[i] = EMPTY_VALUE;
         histodu[i] = EMPTY_VALUE;
         buffer4[i] = buffer1[i+1];
         Cross[i]   = Cross[i+1];
         slope[i]   = slope[i+1];
            if (buffer1[i]>buffer1[i+1]) slope[i]=  1;
            if (buffer1[i]<buffer1[i+1]) slope[i]= -1;
            if (buffer1[i]>buffer4[i])   Cross[i]=  1;
            if (buffer1[i]<buffer4[i])   Cross[i]= -1;
            if (Cross[i]==-1) PlotPoint(i,buffer2,buffer3,buffer1);
            if (buffer1[i]>0)
               if (slope[i]==1)
                     histouu[i] = buffer1[i];
               else  histoud[i] = buffer1[i];
            if (buffer1[i]<0)
               if (slope[i]==1)
                     histodu[i] = buffer1[i];
               else  histodd[i] = buffer1[i];
      }
      else buffer1[i] = 0;               
   }
      if (alertsOn)
      {
        int whichBar = 1; if (alertsOnCurrent) whichBar = 0;
        if (Cross[whichBar] != Cross[whichBar+1])
        {
           if (Cross[whichBar] ==  1) doAlert(whichBar,"up");
           if (Cross[whichBar] == -1) doAlert(whichBar,"down");
        }
      }        
   return(0);
}


//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
void doAlert(int forBar, string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
   if (previousAlert != doWhat || previousTime != Time[forBar]) {
       previousAlert  = doWhat;
       previousTime   = Time[forBar];

       message =  Symbol()+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+" Ahlers fisher transform trend changed to "+doWhat;
          if (alertsMessage)   Alert(message);
          if (alertsEmail)     SendMail(Symbol()+" Ahlers fisher transform",message);
          if (alertsPushNotif) SendNotification(message);
          if (alertsSound)     PlaySound("alert2.wav");
   }
}


//-------------------------------------------------------------------
//                                                                  
//-------------------------------------------------------------------

#define filterInstances 2
double workFil[][filterInstances*3];

#define _fchange 0
#define _fachang 1
#define _fprice  2

double iFilter(double tprice, double filter, int tperiod, int i, int instanceNo=0)
{
   if (filter<=0) return(tprice);
   if (ArrayRange(workFil,0)!= Bars) ArrayResize(workFil,Bars); i = Bars-i-1; instanceNo*=3;
   
   workFil[i][instanceNo+_fprice]  = tprice; if (i<1) return(tprice);
   workFil[i][instanceNo+_fchange] = MathAbs(workFil[i][instanceNo+_fprice]-workFil[i-1][instanceNo+_fprice]);
   workFil[i][instanceNo+_fachang] = workFil[i][instanceNo+_fchange];

   for (int k=1; k<tperiod && (i-k)>=0; k++) workFil[i][instanceNo+_fachang] += workFil[i-k][instanceNo+_fchange];
                                            workFil[i][instanceNo+_fachang] /= tperiod;
    
   double stddev = 0; for (int k=0;  k<tperiod && (i-k)>=0; k++) stddev += MathPow(workFil[i-k][instanceNo+_fchange]-workFil[i-k][instanceNo+_fachang],2);
          stddev = MathSqrt(stddev/(double)tperiod); 
   double filtev = filter * stddev;
   if( MathAbs(workFil[i][instanceNo+_fprice]-workFil[i-1][instanceNo+_fprice]) < filtev ) workFil[i][instanceNo+_fprice]=workFil[i-1][instanceNo+_fprice];
        return(workFil[i][instanceNo+_fprice]);
}

//-------------------------------------------------------------------
//                                                                  
//-------------------------------------------------------------------
void CleanPoint(int i,double& first[],double& second[])
{
   if (i>=Bars-3) return;
   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
        second[i+1] = EMPTY_VALUE;
   else
      if ((first[i] != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE))
          first[i+1] = EMPTY_VALUE;
}

void PlotPoint(int i,double& first[],double& second[],double& from[])
{
   if (i>=Bars-2) return;
   if (first[i+1] == EMPTY_VALUE)
      if (first[i+2] == EMPTY_VALUE) 
            { first[i]  = from[i];  first[i+1]  = from[i+1]; second[i] = EMPTY_VALUE; }
      else  { second[i] =  from[i]; second[i+1] = from[i+1]; first[i]  = EMPTY_VALUE; }
   else     { first[i]  = from[i];                           second[i] = EMPTY_VALUE; }
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
#define priceInstances 1
double workHa[][priceInstances*4];
double getPrice(int price, const double& open[], const double& close[], const double& high[], const double& low[], int i, int instanceNo=0)
{
  if (price>=pr_haclose && price<=pr_hatbiased)
   {
      if (ArrayRange(workHa,0)!= Bars) ArrayResize(workHa,Bars); instanceNo*=4; int r = Bars-i-1;
         
         //
         //
         //
         //
         //
         
         double haOpen;
         if (r>0)
                haOpen  = (workHa[r-1][instanceNo+2] + workHa[r-1][instanceNo+3])/2.0;
         else   haOpen  = (open[i]+close[i])/2;
         double haClose = (open[i] + high[i] + low[i] + close[i]) / 4.0;
         double haHigh  = MathMax(high[i], MathMax(haOpen,haClose));
         double haLow   = MathMin(low[i] , MathMin(haOpen,haClose));

         if(haOpen  <haClose) { workHa[r][instanceNo+0] = haLow;  workHa[r][instanceNo+1] = haHigh; } 
         else                 { workHa[r][instanceNo+0] = haHigh; workHa[r][instanceNo+1] = haLow;  } 
                                workHa[r][instanceNo+2] = haOpen;
                                workHa[r][instanceNo+3] = haClose;
         //
         //
         //
         //
         //
         
         switch (price)
         {
            case pr_haclose:     return(haClose);
            case pr_haopen:      return(haOpen);
            case pr_hahigh:      return(haHigh);
            case pr_halow:       return(haLow);
            case pr_hamedian:    return((haHigh+haLow)/2.0);
            case pr_hamedianb:   return((haOpen+haClose)/2.0);
            case pr_hatypical:   return((haHigh+haLow+haClose)/3.0);
            case pr_haweighted:  return((haHigh+haLow+haClose+haClose)/4.0);
            case pr_haaverage:   return((haHigh+haLow+haClose+haOpen)/4.0);
            case pr_hatbiased:
               if (haClose>haOpen)
                     return((haHigh+haClose)/2.0);
               else  return((haLow+haClose)/2.0);        
         }
   }
   
   switch (price)
   {
      case pr_close:     return(close[i]);
      case pr_open:      return(open[i]);
      case pr_high:      return(high[i]);
      case pr_low:       return(low[i]);
      case pr_median:    return((high[i]+low[i])/2.0);
      case pr_medianb:   return((open[i]+close[i])/2.0);
      case pr_typical:   return((high[i]+low[i]+close[i])/3.0);
      case pr_weighted:  return((high[i]+low[i]+close[i]+close[i])/4.0);
      case pr_average:   return((high[i]+low[i]+close[i]+open[i])/4.0);
      case pr_tbiased:   
               if (close[i]>open[i])
                     return((high[i]+close[i])/2.0);
               else  return((low[i]+close[i])/2.0);        
   }
   return(0);
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
