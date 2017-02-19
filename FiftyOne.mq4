//+------------------------------------------------------------------+
//|                                                     FiftyOne.mq4 |
//|                                           Copyright 2017, VBApps |
//|                                     https://dax-trading-group.de |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, VBApps"
#property link      "https://dax-trading-group.de"
#property version   "1.00"
#property strict

//--- input parameters
input double   LotSize=0.01;
input bool     AutoLotSize=false;
input int      AutoLotSizeRisk=5;

extern int RSI_Period=13;         //8-25
extern int RSI_Price=MODE_CLOSE;           //0-6
extern int Volatility_Band=34;    //20-40
extern int RSI_Price_Line = 2;
extern int RSI_Price_Type=MODE_SMA;      //0-3
extern int Trade_Signal_Line =7;
extern int Trade_Signal_Type=MODE_SMA;   //0-3
extern bool UseAlerts=false;

double RSIBuf[],UpZone[],MdZone[],DnZone[],MaBuf[],MbBuf[];

int AlertPlayedonBar=0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
/* double val0=iCustom(Symbol(),0,"TradersDynamicIndex",0,0);
   Print(val0);
   double val1=iCustom(Symbol(),0,"TradersDynamicIndex",1,0);
   Print(val1);
   double val2=iCustom(Symbol(),0,"TradersDynamicIndex",2,0);
   Print(val2);
   double val3=iCustom(Symbol(),0,"TradersDynamicIndex",3,0);
   Print(val3);
   double val4=iCustom(Symbol(),0,"TradersDynamicIndex",4,0);
   Print(val4);
   double val5=iCustom(Symbol(),0,"TradersDynamicIndex",5,0);
   Print(val5);
   */
   double MA,RSI[];
   static int IndCounted;
   int limit,MaxBar,i,counted_bars=IndCounted;
   ArrayResize(RSI,Volatility_Band);
   int IBARS=iBars(Symbol(),Period());
   IndCounted=IBARS-1;

   if(ArraySize(RSIBuf)<IBARS)
     {
      ArraySetAsSeries(RSIBuf,false);
      ArraySetAsSeries(UpZone,false);
      ArraySetAsSeries(MdZone,false);
      ArraySetAsSeries(DnZone,false);
      ArraySetAsSeries(MaBuf,false);
      ArraySetAsSeries(MbBuf,false);
      //----  
      ArrayResize(RSIBuf,IBARS);
      ArrayResize(UpZone,IBARS);
      ArrayResize(MdZone,IBARS);
      ArrayResize(DnZone,IBARS);
      ArrayResize(MaBuf,IBARS);
      ArrayResize(MbBuf,IBARS);
      //----
      ArraySetAsSeries(RSIBuf,true);
      ArraySetAsSeries(UpZone,true);
      ArraySetAsSeries(MdZone,true);
      ArraySetAsSeries(DnZone,true);
      ArraySetAsSeries(MaBuf,true);
      ArraySetAsSeries(MbBuf,true);
     }

   limit=IBARS-counted_bars-1;
   MaxBar=IBARS-1;

   if(limit>MaxBar)
     {
      limit=MaxBar;
      for(i=limit; i>0; i--)
        {
         RSIBuf[i]=iRSI(NULL,0,RSI_Period,RSI_Price,i);
         MA=0;
         for(int x=i; x<i+Volatility_Band; x++)
           {
            RSI[x-i]=RSIBuf[x];
            MA+=RSIBuf[x]/Volatility_Band;
           }
         UpZone[i] = (MA + (1.6185 * StDev(RSI,Volatility_Band)));
         DnZone[i] = (MA - (1.6185 * StDev(RSI,Volatility_Band)));
         MdZone[i] = ((UpZone[i] + DnZone[i])/2);
        }
      for(int j=limit-1;j>=0;j--)
        {
         MaBuf[j] = (iMAOnArray(RSIBuf,0,RSI_Price_Line,0,RSI_Price_Type,j));
         MbBuf[j] = (iMAOnArray(RSIBuf,0,Trade_Signal_Line,0,Trade_Signal_Type,j));
        }
      if((MbBuf[0]>MdZone[0]) && (MbBuf[1]<=MdZone[1]) && (UseAlerts==true) && (AlertPlayedonBar!=Bars))
        {
         Alert("Bullish cross");
         PlaySound("alert.wav");
         AlertPlayedonBar=Bars;
        }
      if((MbBuf[0]<MdZone[0]) && (MbBuf[1]>=MdZone[1]) && (UseAlerts==true) && (AlertPlayedonBar!=Bars))
        {
         Alert("Bearish cross");
         PlaySound("alert.wav");
         AlertPlayedonBar=Bars;
        }
     }

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   ObjectsDeleteAll();
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
//---
   double ret=0.0;
//---

//---
   return(ret);
  }
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
   double sum=0.0,ssum=0.0;
   for(int i=0; i<Per; i++)
     {
      sum+=Data[i];
      ssum+=MathPow(Data[i],2);
     }
   return((ssum*Per - sum*sum)/(Per*(Per-1)));
  }
//+------------------------------------------------------------------+
