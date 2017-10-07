//+------------------------------------------------------------------+
//|                                                 CrossingEMAs.mq4 |
//|                                           Copyright 2017, VBApps |
//|                                      http://dax-trading-group.de |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, VBApps"
#property link      "http://dax-trading-group.de"
#property version   "1.00"
#property strict
//--- input parameters
extern double   LotSize=0.01;
extern bool     LotAutoSize=false;
extern int      RiskPercent=5;

bool OrderBUYOpened=false;
bool OrderSELLOpened=false;
double TempBid=0;
double TempAsk=0;
string TempBid0=0;
string TempAsk0=0;
double CountedPoints=0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

   double MA50=iMA(Symbol(),NULL,50,0,MODE_SMA,PRICE_MEDIAN,0);
   double MA100 = iMA(Symbol(),NULL,100,0,MODE_SMA,PRICE_MEDIAN,0);
   double MA200 = iMA(Symbol(),NULL,200,0,MODE_SMA,PRICE_MEDIAN,0);

//risk management
   if(LotAutoSize)
     {
      if(RiskPercent<0.1 || RiskPercent>100){Comment("Invalid Risk Value.");}
      else
        {
         LotSize=MathFloor((AccountFreeMargin()*AccountLeverage()*RiskPercent*Point*100)/(Ask*MarketInfo(Symbol(),MODE_LOTSIZE)*
                           MarketInfo(Symbol(),MODE_MINLOT)))*MarketInfo(Symbol(),MODE_MINLOT);
        }
     }
   if(LotAutoSize==false){LotSize=LotSize;}

   if(OrderBUYOpened==false && OrderSELLOpened==false)
     {
      if(MA50<MA100)
        {
         OrderSELLOpened=true;
         TempBid=Bid;
           } else if(MA50>MA100) {
         OrderBUYOpened=true;
         TempAsk=Ask;
        }
     }

   if(MA50<MA100 && OrderSELLOpened)
     {
      TempAsk=Ask;
      TempBid0=TempBid;
      TempAsk0=TempAsk;
      StringReplace(TempBid0,".","");
      StringReplace(TempAsk0,".","");
      CountedPoints=CountedPoints+(StringToInteger(TempBid0)-StringToInteger(TempAsk0));
      Print("Open BUY Order! @"+MA100+";Ask="+DoubleToString(Ask)+";CurrPoints="+(StringToInteger(TempBid0)-StringToInteger(TempAsk0)));
      OrderBUYOpened=true;
      OrderSELLOpened=false;
     }

   if(MA50>MA100 && OrderBUYOpened)
     {
      TempBid=Bid;
      TempBid0=TempBid;
      TempAsk0=TempAsk;
      StringReplace(TempBid0,".","");
      StringReplace(TempAsk0,".","");
      CountedPoints=CountedPoints+(StringToInteger(TempAsk0)-StringToInteger(TempBid0));
      Print("Open SELL Order! @"+MA50+";Bid="+DoubleToString(Bid)+";CurrPoints="+(StringToInteger(TempBid0)-StringToInteger(TempAsk0)));
      OrderSELLOpened= true;
      OrderBUYOpened = false;
     }

  }
//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
//---
   Print("***CountedPoints="+CountedPoints);
   double ret=0.0;
//---

//---
   return(ret);
  }
//+------------------------------------------------------------------+
