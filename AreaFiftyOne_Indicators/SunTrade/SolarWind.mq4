//+------------------------------------------------------------------+
//|                                SolarWind with FlatMarketDetector |
//|                                      Copyright © 2018, vbapps.co |
//|                                 Copyright © 2005, Yura Prokofiev |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, Yura Prokofiev, 2018 vbapps.co"

#property indicator_separate_window
#property indicator_buffers 7
#property indicator_color2 Lime
#property indicator_color3 Red
#property indicator_color4 Blue
#property indicator_color5 Blue
#property indicator_width1 1
#property indicator_width2 2
#property indicator_width3 2
#property indicator_width4 1
#property indicator_width5 1
#property indicator_style4 STYLE_DOT
#property indicator_style5 STYLE_DOT

extern int      period=15;
extern double   Gamma=0.4;
extern int      AvPeriod=500;
extern bool     CalculateOnBarClose=true;
extern bool     ShowAlert=false;
extern bool     SendEMail=false;
extern bool     SendNotificationToPhone=false;
extern bool     ShowAlertBox=false;
extern bool     DebugTrace=false;
extern int      CentMultiplicator=9;
extern double   LotSize=0.01;

double         ExtBuffer0[];
double         ExtBuffer1[];
double         ExtBuffer2[];
double         ExtBuffer3[];
double         ExtBuffer4[];
double         ExtBuffer5[];
double         ExtBuffer6[];

int numBars;

int countBuySignals=0;
int countSellSignals=0;

bool SellOpened=false;
bool BuyOpened=false;

int CountPoints=0;
double CrossPosStart,CrossPosEnd;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {

   SetIndexStyle(0,DRAW_NONE);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexStyle(3,DRAW_LINE);
   SetIndexStyle(4,DRAW_LINE);

   IndicatorDigits(Digits+1);

   SetIndexBuffer(0,ExtBuffer0);
   SetIndexBuffer(1,ExtBuffer1);
   SetIndexBuffer(2,ExtBuffer2);
   SetIndexBuffer(3,ExtBuffer3);
   SetIndexBuffer(4,ExtBuffer4);

// Internal  
   SetIndexBuffer(5,ExtBuffer5);
   SetIndexBuffer(6,ExtBuffer6);

   IndicatorShortName("SOLAR WIND with FlatMarketDetector");
   SetIndexLabel(1,"Bull");
   SetIndexLabel(2,"Bear");
   SetIndexLabel(3,"FlatBull");
   SetIndexLabel(4,"FlatBear");

   numBars=Bars;

   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   int    limit;
   int    counted_bars=IndicatorCounted();
   double prev,current;
   double Value=0,Value1=0,Value2=0,Fish=0,Fish1=0,Fish2=0;
   double price;
   double MinL=0;
   double MaxH=0;
   int begin=0;

// Check if ignore bar 0
   if(CalculateOnBarClose==true) { begin=1; }

// nothing else to do?
   if(counted_bars<0)
      return(-1);

   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;

   for(int i=limit-1; i>=begin; i--)
     {
      MaxH=High[iHighest(Symbol(),0,MODE_HIGH,period,i)];
      MinL= Low[iLowest(Symbol(),0,MODE_LOW,period,i)];
      price = (High[i]+Low[i])/2;
      Value = 0.33*2*((price-MinL)/(MaxH-MinL)-0.5) + 0.67*Value1;
      Value=MathMin(MathMax(Value,-0.999),0.999);
      ExtBuffer0[i]=0.5*MathLog((1+Value)/(1-Value))+0.5*Fish1;
      Value1=Value;
      Fish1=ExtBuffer0[i];
     }

   bool up=true;
   for(i=limit-1; i>=0; i--)
     {
      current=ExtBuffer0[i];
      prev=ExtBuffer0[i+1];

      if(((current<0)&&(prev>0))||(current<0))   up= false;
      if(((current>0)&&(prev<0))||(current>0))   up= true;

      if(!up)
        {
         ExtBuffer2[i]=current;
         ExtBuffer1[i]=0.0;
         // Save current absolute value
         ExtBuffer5[i]=MathAbs(ExtBuffer2[i]);
        }
      else
        {
         ExtBuffer1[i]=current;
         ExtBuffer2[i]=0.0;
         // Save current absolute value
         ExtBuffer5[i]=MathAbs(ExtBuffer1[i]);
        }

     }

   for(int pos=limit-1; pos>=begin; pos--)
     {
      // Flat lines
      double flat=iMAOnArray(ExtBuffer5,Bars,AvPeriod,0,MODE_EMA,pos);
      ExtBuffer3[pos] = (flat * Gamma);
      ExtBuffer4[pos] = 0 - (flat * Gamma);
/*
      //---- Deceleration
      if(ExtBuffer6[pos]<ExtBuffer6[pos+1])
        {
         // This is a red line
         ExtBuffer2[pos] = ExtBuffer6[pos];
         ExtBuffer1[pos] = 0.0;

         //---- Acceleration
           } else if(ExtBuffer6[pos]>ExtBuffer6[pos+1]){

         // This is a blue line
         ExtBuffer1[pos] = ExtBuffer6[pos];
         ExtBuffer2[pos] = 0.0;
        }
*/
     }

   showAlert();

   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void showAlert()
  {
// wenn vorherige kerze größer oder gleich dem mittelwert ist,
// dann eröffne an der aktuellen kerze eine position in die jeweilige richtung
// wenn vorherige kerze kleiner oder gleich dem mittelwert ist,
// prüfe, ob eine position bereits eröffnet wurde
// schließe die position
   double greenHistoLast,redHistoLast,greenFlatValueLast,redFlatValueLast;
   double greenHistoPrev,redHistoPrev,greenFlatValuePrev,redFlatValuePrev;

   greenHistoLast=ExtBuffer1[1];
   redHistoLast=ExtBuffer2[1];
   greenFlatValueLast=ExtBuffer3[1];
   redFlatValueLast=ExtBuffer4[1];

   greenHistoPrev=ExtBuffer1[2];
   redHistoPrev=ExtBuffer2[2];
   greenFlatValuePrev=ExtBuffer3[2];
   redFlatValuePrev=ExtBuffer4[2];

   string currBid=DoubleToString(Bid,Digits);
   string currAsk=DoubleToString(Ask,Digits);
   string CrossPosStartStr=DoubleToString(CrossPosStart,Digits);

   StringReplace(currBid,".","");
   StringReplace(currAsk,".","");
   StringReplace(CrossPosStartStr,".","");

   if((greenHistoPrev<greenFlatValuePrev || greenFlatValuePrev==greenHistoPrev)
      && 
      (greenHistoLast>greenFlatValueLast || greenHistoLast==greenFlatValueLast)
      && IsNewBar())
     {

      if(CrossPosStart>0) CountPoints=CountPoints+(StringToInteger(currAsk)-StringToInteger(CrossPosStartStr));


      Print("-----------");
      Print("greenHistoPrev="+greenHistoPrev);
      Print("greenFlatValuePrev="+greenFlatValuePrev);
      Print("greenHistoLast="+greenHistoLast);
      Print("greenFlatValueLast="+greenFlatValueLast);
      

      countBuySignals++;

      createNotifications(Symbol(),"BUY",Period(),"","SolarWind");
      BuyOpened=true;
      CrossPosStart=Ask;
     }

   if((greenHistoPrev>greenFlatValuePrev || greenFlatValuePrev==greenHistoPrev)
      && 
      (greenHistoLast<greenFlatValueLast || greenHistoLast==greenFlatValueLast)
      && IsNewBar() && BuyOpened)
     {

      if(CrossPosStart>0) CountPoints=CountPoints+(StringToInteger(CrossPosStartStr)-StringToInteger(currBid));


      Print("-----------");
      Print("greenHistoPrev="+greenHistoPrev);
      Print("greenFlatValuePrev="+greenFlatValuePrev);
      Print("greenHistoLast="+greenHistoLast);
      Print("greenFlatValueLast="+greenFlatValueLast);
      

      createNotifications(Symbol(),"CLOSE_BUY",Period(),"","SolarWind");
      BuyOpened=false;
      CrossPosEnd=Bid;
     }

   if((redHistoPrev>redFlatValuePrev || redHistoPrev==redFlatValuePrev)
      && 
      (redHistoLast<redFlatValueLast || redHistoLast==redFlatValueLast)
      && IsNewBar())
     {

      Print("-----------");
      Print("redHistoPrev="+redHistoPrev);
      Print("redFlatValuePrev="+redFlatValuePrev);
      Print("redHistoLast="+redHistoLast);
      Print("redFlatValueLast="+redFlatValueLast);
      

      countSellSignals++;

      createNotifications(Symbol(),"SELL",Period(),"","SolarWind");
      SellOpened=true;
      CrossPosStart=Bid;
     }

   if((redHistoPrev<redFlatValuePrev || redHistoPrev==redFlatValuePrev)
      && 
      (redHistoLast>redFlatValueLast || redHistoLast==redFlatValueLast)
      && IsNewBar() && SellOpened)
     {

      Print("-----------");
      Print("redHistoPrev="+redHistoPrev);
      Print("redFlatValuePrev="+redFlatValuePrev);
      Print("redHistoLast="+redHistoLast);
      Print("redFlatValueLast="+redFlatValueLast);
      

      createNotifications(Symbol(),"CLOSE_SELL",Period(),"","SolarWind");
      SellOpened=false;
      CrossPosEnd=Ask;
     }
  }
//+------------------------------------------------------------------+  
bool IsNewBar()
  {
   if(numBars!=Bars)
     {
      numBars=Bars;
      return(true);
     }
   return(false);
  }
//+------------------------------------------------------------------+
void createNotifications(string symbolName,string direction,int chartPeriod,string additionalText,string strategyName)
  {
   if(DebugTrace){Print("Area51 on "+symbolName+"("+getTimeframeFromMinutes(chartPeriod)+") -> "+strategyName+" strategy: "+direction+" signal at "+DoubleToStr(iClose(symbolName,0,0),(int)MarketInfo(symbolName,MODE_DIGITS)));}
   if(ShowAlertBox) {Alert("Area51 on "+symbolName+"("+getTimeframeFromMinutes(chartPeriod)+") -> ",strategyName+" strategy: "+direction+" signal at "+DoubleToStr(iClose(symbolName,0,0),(int)MarketInfo(symbolName,MODE_DIGITS)));}
   if(SendEMail){SendMail("Area51 on "+symbolName+"("+getTimeframeFromMinutes(chartPeriod)+") -> ",strategyName+" strategy: "+direction+" signal at "+DoubleToStr(iClose(symbolName,0,0),(int)MarketInfo(symbolName,MODE_DIGITS)));}
   if(SendNotificationToPhone){SendNotification(direction+" signal at "+DoubleToStr(iClose(symbolName,0,0),(int)MarketInfo(symbolName,MODE_DIGITS))+" -> Area51 on "+symbolName+"("+getTimeframeFromMinutes(chartPeriod)+") with "+strategyName+" strategy");}
  }
//+------------------------------------------------------------------+
string getTimeframeFromMinutes(int ai_0)
  {
   string timeFrame;
   switch(ai_0)
     {
      case 1:
         timeFrame="M1";
         break;
      case 5:
         timeFrame="M5";
         break;
      case 15:
         timeFrame="M15";
         break;
      case 30:
         timeFrame="M30";
         break;
      case 60:
         timeFrame="H1";
         break;
      case 240:
         timeFrame="H4";
         break;
      case 1440:
         timeFrame="D1";
         break;
      case 10080:
         timeFrame="W1";
         break;
      case 43200:
         timeFrame="MN";
     }
   return (timeFrame);
  }
//+------------------------------------------------------------------+

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
   Print("countBuySignals="+countBuySignals);
   Print("countSellSignals="+countSellSignals);
   if(Digits>2)
     {
      Print("CountPoints: "+CountPoints+";Sum: "+DoubleToString(CountPoints*LotSize*100*CentMultiplicator/100/10,2)+"€");
     }
   else
     {
      Print("CountPoints: "+DoubleToStr(StringToDouble(CountPoints)/MathPow(10.0,Digits))+";Sum: "
            +StringToDouble(CountPoints)/(MathPow(10.0,Digits))*LotSize*100*CentMultiplicator/100/10+"€");
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
//---
   double ret=0.0;
   Print("countBuySignals="+countBuySignals);
   Print("countSellSignals="+countSellSignals);
   if(Digits>2)
     {
      Print("CountPoints: "+CountPoints+";Sum: "+DoubleToString(CountPoints*LotSize*100*CentMultiplicator/100/10,2)+"€");
     }
   else
     {
      Print("CountPoints: "+DoubleToStr(StringToDouble(CountPoints)/MathPow(10.0,Digits))+";Sum: "
            +StringToDouble(CountPoints)/(MathPow(10.0,Digits))*LotSize*100*CentMultiplicator/100/10+"€");
     }
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
