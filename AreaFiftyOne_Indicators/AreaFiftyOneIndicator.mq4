//+------------------------------------------------------------------+
//|                                    AreaFiftyOneIndicator.mq4     |
//|                                    Copyright © 2006, Dean Malone | 
//|                                    Edit: 2017, Valeri Balachnnin |
//|                                    www.compassfx.com             |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//|                     Traders Dynamic Index                        |
//|                                                                  |
//|  This hybrid indicator is developed to assist traders in their   |
//|  ability to decipher and monitor market conditions related to    |
//|  trend direction, market strength, and market volatility.        |
//|                                                                  | 
//|  Even though comprehensive, the T.D.I. is easy to read and use.  |
//|                                                                  |
//|  Green line = RSI Price line                                     |
//|  Red line = Trade Signal line                                    |
//|  Blue lines = Volatility Band                                    | 
//|  Yellow line = Market Base Line                                  |  
//|                                                                  |
//|  Trend Direction - Immediate and Overall                         |
//|   Immediate = Green over Red...price action is moving up.        |
//|               Red over Green...price action is moving down.      |
//|                                                                  |   
//|   Overall = Yellow line trends up and down generally between the |
//|             lines 32 & 68. Watch for Yellow line to bounces off  |
//|             these lines for market reversal. Trade long when     |
//|             price is above the Yellow line, and trade short when |
//|             price is below.                                      |        
//|                                                                  |
//|  Market Strength & Volatility - Immediate and Overall            |
//|   Immediate = Green Line - Strong = Steep slope up or down.      | 
//|                            Weak = Moderate to Flat slope.        |
//|                                                                  |               
//|   Overall = Blue Lines - When expanding, market is strong and    |
//|             trending. When constricting, market is weak and      |
//|             in a range. When the Blue lines are extremely tight  |                                                       
//|             in a narrow range, expect an economic announcement   | 
//|             or other market condition to spike the market.       |
//|                                                                  |               
//|                                                                  |
//|  Entry conditions                                                |
//|   Scalping  - Long = Green over Red, Short = Red over Green      |
//|   Active - Long = Green over Red & Yellow lines                  |
//|            Short = Red over Green & Yellow lines                 |    
//|   Moderate - Long = Green over Red, Yellow, & 50 lines           |
//|              Short= Red over Green, Green below Yellow & 50 line |
//|                                                                  |
//|  Exit conditions*                                                |   
//|   Long = Green crosses below Red                                 |
//|   Short = Green crosses above Red                                |
//|   * If Green crosses either Blue lines, consider exiting when    |
//|     when the Green line crosses back over the Blue line.         |
//|                                                                  |
//|                                                                  |
//|  IMPORTANT: The default settings are well tested and proven.     |
//|             But, you can change the settings to fit your         |
//|             trading style.                                       |
//|                                                                  |
//|                                                                  |
//|  Price & Line Type settings:                           |                
//|   RSI Price settings                                             |               
//|   0 = Close price     [DEFAULT]                                  |               
//|   1 = Open price.                                                |               
//|   2 = High price.                                                |               
//|   3 = Low price.                                                 |               
//|   4 = Median price, (high+low)/2.                                |               
//|   5 = Typical price, (high+low+close)/3.                         |               
//|   6 = Weighted close price, (high+low+close+close)/4.            |               
//|                                                                  |               
//|   RSI Price Line & Signal Line Type settings                                   |               
//|   0 = Simple moving average       [DEFAULT]                      |               
//|   1 = Exponential moving average                                 |               
//|   2 = Smoothed moving average                                    |               
//|   3 = Linear weighted moving average                             |               
//|                                                                  |
//|   Good trading,                                                  |   
//|                                                                  |
//|   Dean                                                           |                              
//+------------------------------------------------------------------+

#property indicator_buffers 7
#property indicator_color1 Black
#property indicator_color2 MediumBlue
#property indicator_color3 Yellow
#property indicator_color4 MediumBlue
#property indicator_color5 Green
#property indicator_color6 Red
#property indicator_color7 Aqua
#property indicator_separate_window

extern int RSI_Period=13;         //8-25
extern int RSI_Price=MODE_SMA;           //0-6
extern int Volatility_Band=34;    //20-40
extern int RSI_Price_Line = 2;
extern int RSI_Price_Type=MODE_SMA;      //0-3
extern int Trade_Signal_Line=7;
extern int Trade_Signal_Type=MODE_SMA;   //0-3
extern int Trade_Signal_Line2=0;
extern bool UseAlerts=true;
extern double LotSize=0.05;
extern int CentMultiplicator=9;
extern int IndicatorBars=200;

double RSIBuf[],UpZone[],MdZone[],DnZone[],MaBuf[],MbBuf[],McBuf[];
double CrossPosStart,CrossPosEnd;
int CountPoints=0;

int AlertPlayedonBar=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   IndicatorShortName("AreaFiftyOneIndicator");
   SetIndexBuffer(0,RSIBuf);
   SetIndexBuffer(1,UpZone);
   SetIndexBuffer(2,MdZone);
   SetIndexBuffer(3,DnZone);
   SetIndexBuffer(4,MaBuf);
   SetIndexBuffer(5,MbBuf);
   SetIndexBuffer(6,McBuf);

   SetIndexStyle(0,DRAW_NONE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_LINE,0,2);
   SetIndexStyle(3,DRAW_LINE);
   SetIndexStyle(4,DRAW_LINE,0,2);
   SetIndexStyle(5,DRAW_LINE,0,2);
   SetIndexStyle(6,DRAW_LINE,2,0);

   SetIndexLabel(0,NULL);
   SetIndexLabel(1,"VB High");
   SetIndexLabel(2,"Market Base Line");
   SetIndexLabel(3,"VB Low");
   SetIndexLabel(4,"RSI Price Line");
   SetIndexLabel(5,"Trade Signal Line");
   SetIndexLabel(6,"Trade Signal2 Line");

   SetLevelValue(0,50);
   SetLevelValue(1,68);
   SetLevelValue(2,32);
   SetLevelStyle(STYLE_DOT,1,DimGray);

   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   double MA,RSI[];
   ArrayResize(RSI,Volatility_Band);
   int counted_bars=0;
   int bars=0;
   if(IndicatorBars>100){counted_bars=IndicatorBars;}else
   {counted_bars=IndicatorCounted();}
   if(Bars>1000&&IndicatorBars>100){bars=1000;}else{bars=Bars;}
   int limit=bars-counted_bars-1;
   for(int i=limit; i>=0; i--)
     {
      RSIBuf[i]=(iRSI(NULL,0,RSI_Period,RSI_Price,i));
      MA=0;
      for(int x=i; x<i+Volatility_Band; x++)
        {
         if(x<ArraySize(RSIBuf) && x-i<ArraySize(RSI))
           {
            RSI[x-i]=RSIBuf[x];
            MA+=RSIBuf[x]/Volatility_Band;
           }
        }
      UpZone[i] = (MA + (1.6185 * StDev(RSI,Volatility_Band)));
      DnZone[i] = (MA - (1.6185 * StDev(RSI,Volatility_Band)));
      MdZone[i] = ((UpZone[i] + DnZone[i])/2);
     }
   for(i=limit-1;i>=0;i--)
     {
      MaBuf[i] = iMAOnArray(RSIBuf,0,RSI_Price_Line,0,RSI_Price_Type,i);
      MbBuf[i] = iMAOnArray(RSIBuf,0,Trade_Signal_Line,0,Trade_Signal_Type,i);
      McBuf[i] = iMAOnArray(RSIBuf,0,Trade_Signal_Line2,0,Trade_Signal_Type,i);
     }

 /*  string currBid=DoubleToString(Bid,Digits);
   string currAsk=DoubleToString(Ask,Digits);
   string CrossPosStartStr=DoubleToString(CrossPosStart,Digits);

   if((MbBuf[0]>MdZone[0]) && (MbBuf[1]<=MdZone[1]) && (UseAlerts==true) && (AlertPlayedonBar!=Bars))
     {
      StringReplace(currAsk,".","");
      StringReplace(CrossPosStartStr,".","");
      Alert("Bullish cross to BUY ("+Symbol()+") at "+DoubleToStr(StringToDouble(currAsk)/MathPow(10.0,Digits))+" from SELL "+DoubleToStr(StringToDouble(CrossPosStartStr)/(MathPow(10.0,Digits))));
      if(CrossPosStart>0) CountPoints=CountPoints+(StringToInteger(currAsk)-StringToInteger(CrossPosStartStr));

      if(Digits>2)
        {
         Print("CountPoints: "+CountPoints+";Sum: "+CountPoints*LotSize*100*CentMultiplicator/100/10+"€");
        }
      else
        {
         Print("CountPoints: "+DoubleToStr(StringToDouble(CountPoints)/MathPow(10.0,Digits))+";Sum: "+StringToDouble(CountPoints)/(MathPow(10.0,Digits))*LotSize*100*CentMultiplicator/100/10+"€");
        }

      CrossPosEnd=CrossPosStart;
      CrossPosStart=Ask;
      AlertPlayedonBar=Bars;
     }
   if((MbBuf[0]<MdZone[0]) && (MbBuf[1]>=MdZone[1]) && (UseAlerts==true) && (AlertPlayedonBar!=Bars))
     {
      StringReplace(currBid,".","");
      StringReplace(CrossPosStartStr,".","");
      Alert("Bearish cross to SELL ("+Symbol()+") at "+DoubleToStr(StringToDouble(currBid)/(MathPow(10.0,Digits)))+" from BUY "+DoubleToStr(StringToDouble(CrossPosStartStr)/(MathPow(10.0,Digits))));
      if(CrossPosStart>0) CountPoints=CountPoints+(StringToInteger(CrossPosStartStr)-StringToInteger(currBid));
      if(Digits>2)
        {
         Print("CountPoints: "+CountPoints+";Sum: "+CountPoints*LotSize*100*CentMultiplicator/100/10+"€");
        }
      else
        {
         Print("CountPoints: "+DoubleToStr(StringToDouble(CountPoints)/MathPow(10.0,Digits))+";Sum: "+StringToDouble(CountPoints)/(MathPow(10.0,Digits))*LotSize*100*CentMultiplicator/100/10+"€");
        }

      CrossPosEnd=CrossPosStart;
      CrossPosStart=Bid;
      AlertPlayedonBar=Bars;
     }
*/
//----
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- The first way to get the uninitialization reason code 
   Print(__FUNCTION__,"_Uninitalization reason code = ",reason);
   if(UseAlerts)
     {
      if(Digits>2)
        {
         Print("CountPoints: "+CountPoints);
        }
      else
        {
         Print("CountPoints: "+DoubleToStr(StringToDouble(CountPoints)/(MathPow(10.0,Digits))));
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
//---
   double ret=0.0;
   Print("CountPoints: "+DoubleToStr(StringToDouble(CountPoints)/(MathPow(10.0,Digits))));
//---

//---
   return(ret);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double StDev(double &Data[],int Per)
  {
   return(MathSqrt(Variance(Data,Per)));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Variance(double &Data[],int Per)
  {
   double sum,ssum;
   for(int i=0; i<Per; i++)
     {
      sum+=Data[i];
      ssum+=MathPow(Data[i],2);
     }
   return((ssum*Per - sum*sum)/(Per*(Per-1)));
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
