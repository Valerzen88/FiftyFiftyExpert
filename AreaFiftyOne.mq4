//+------------------------------------------------------------------+
//|                                                 AreaFiftyOne.mq4 |
//|                                                           VBApps |
//|                                                 http://vbapps.co |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2019 VBApps::Valeri Balachnin"
#property version   "5.4"
#property description "Collection of approved strategies with advanced money management, notifications and user positions handling."
#property strict

#define cutStart(_text,_end) StringSubstr(_text,0,StringFind(_text,_end,0))
#define cut(_text,_start,_end) StringSubstr(_text,StringFind(_text,_start,0)+StringLen(_start),StringFind(_text,_end,0)-StringFind(_text,_start,0)-StringLen(_start))
#define cutEnd(_text,_start) StringSubstr(_text,StringFind(_text,_start,0)+StringLen(_start),StringLen(_text)-StringFind(_text,_start,0)-StringLen(_start))
#define ndt(_text,n) ndtDef(_text,n) 
string ndtDef(double _text,int n){string text=(string)NormalizeDouble(_text,n),res=text;int dot=StringFind(text,".",0);if(dot<0)return res+".0";if(dot+n+1<StringLen(text) && StringSubstr(text,StringLen(text)-1,1)=="9"){text=string((double)text+0.1);}res=StringSubstr(text,0,dot+n+1);return res;}
#define ND(_val,_symbol) NormalizeDouble(_val,(int)SymbolInfoInteger(_symbol,SYMBOL_DIGITS))
#define nd(_val)  NormalizeDouble(_val,_Digits)
#define nd5(_val) NormalizeDouble(_val,5)
#define nd3(_val) NormalizeDouble(_val,3)
#define nd2(_val) NormalizeDouble(_val,2)
#define nd1(_val) NormalizeDouble(_val,1)
#define nd0(_val) MathRound(_val)
#define P         " "
#include <Area51_Lib.mqh>
#define INDPATH "Indicators\\"
#resource "\\"+INDPATH+"AreaFiftyOneIndicator.ex4"
#resource "\\"+INDPATH+"AreaFiftyOne_Trend.ex4"
#resource "\\"+INDPATH+"MagicTrend.ex4"
#resource "\\"+INDPATH+"HMA_Color.ex4"
#resource "\\"+INDPATH+"Heiken_Ashi_Smoothed.ex4"
#resource "\\"+INDPATH+"Improved_CCI.ex4"

#define   SIGNAL_BUY          1
#define   SIGNAL_SELL         -1

#define ORDER_TYPE_BUY        OP_BUY
#define ORDER_TYPE_SELL       OP_SELL
#define ORDER_TYPE_BUY_LIMIT  OP_BUYLIMIT
#define ORDER_TYPE_SELL_LIMIT OP_SELLLIMIT
#define ORDER_TYPE_BUY_STOP   OP_BUYSTOP
#define ORDER_TYPE_SELL_STOP  OP_SELLSTOP

//--- input parameters
extern static string Trading="Base trading params";
extern double   LotSize=0.01;
//extern static string LotAutoSize_Comment="Available in the full version!";
//extern static string LotRiskPercent_Comment="Available in the full version!";
//extern static string MoneyRiskInPercent_Comment="Available in the full version!";
extern bool     LotAutoSize=false;
extern double   LotRiskPercent=25;
extern static string MoneyManagement="Set MM settings here";
extern int      MoneyRiskInPercent=0;
extern double   MaxDynamicLotSize=0.0;
extern int      MaxMoneyValueToLose=0;
//extern static string TrailingStep_Comment="Available in the full version!";
//extern static string DistanceStep_Comment="Available in the full version!";
extern static string Positions="Handle positions params";
extern int      TrailingStep=15;
extern int      DistanceStep=15;
extern int      TakeProfit=750;
extern int      StopLoss=0;
extern int      MinAmount=150;
extern int      SetSLToMinAmountUnder=100;
extern int      MaxSpread=25;
extern static string Indicators="Choose strategies";
extern static string TrendIndicatorStrategy="-------------------";
extern bool     UseTrendIndicator=false;
extern double   Smoothing=3.0;
extern bool     UseSMAOnTrendIndicator=true;
extern int      UseOneOrTwoSMAOnTrendIndicator=1;
extern bool     UseSMAsCrossingOnTrendIndicatorData=false;
extern static string RSIBasedStrategy="-------------------";
extern bool     UseRSIBasedIndicator=false;
//extern bool     UseADXWithBaseLine=false;
extern bool     UseCorridorCroosing=false;
extern static string MACD_ADX_MA_Strategy="-------------------";
extern bool     UseSimpleTrendStrategy=false;
extern static string SimpleStochasticCrossingStrategy="-------------------";
extern bool     UseStochasticBasedStrategy=false;
extern static string ADX_RSI_MA_Strategy="-------------------";
extern bool     Use5050Strategy=false;
extern bool     UseMAOn5050Strategy=false;
extern static string StochastiCroosingRSIStrategy="-------------------";
extern bool     UseStochRSICroosingStrategy=true;
extern static string UseNightAsianBlockStrategy="-------------------";;
extern bool     UseNightAsianBlock=false;
extern int      GapFromBlock=60;
extern int      CandleCountInBlock=12;
extern int      MaxBlockSizeInPoints=300;
extern static string IchimokuClouds="-------------------";
extern bool     UseIchimokuClouds=false;
int      Tenkan=24; // Tenkan line period. The fast "moving average".
int      Kijun=48; // Kijun line period. The slow "moving average".
int      Senkou=240;  // Senkou period. Used for Kumo (Cloud) spans.
extern int      IchimokuMAPeriod=12;
extern int      IchimokuMAShift=9;
extern bool     UseIchimokuCrossing=true;
extern bool     UseIchimokuMACrossing=true;
extern bool     UseIchimokuADXMA=false;
extern static string UseADX50PlusStrategy="-------------------";
extern bool     UseADX50Plus=false;
extern int      ADX50PlusPeriod=34;
extern static string MagicTrendStrategy="-------------------";
extern bool     UseMagicTrendStrategy=false;
extern int      CCPeriod=120;
extern static string HMAStrategy="-------------------";
extern bool     UseHMAStrategy=false;
extern static string SmoothedStrategy="-------------------";
extern bool     UseSmoothedStrategy=false;
extern bool     SmoothedWithADX=false;
extern double   DistanceForPending=0.0;
extern static string SimpleMAsStrategy="-------------------";
extern bool     UseSimpleMAsStrategy=false;
extern bool     UseCCIAverageFiltering=false;
extern static string CCIAverageStrategy="-------------------";
extern bool     UseCCIAverageStrategy=false;
extern double   CCISignalValue=150.0;
//do not use this strategy!!! is garbage!
//extern static string LongTermJourneyToSunriseStrategy="-------------------";
bool     UseLongTermJourneyToSunriseStrategy=false;
bool     Use2ndLevelSignals=false;
int      AdditionalSL=250;
bool     MakeCloseTradeAlwaysInProfit=false;
int      MaxCandleAfterSignal=10;
static string MagicSymphonieStrategy="-------------------";
bool     UseMagicSymphonieStrategy=false;
//extern static string SolarWindStrategy="-------------------";
bool     UseSolarWindStrategy=false;
extern static string HandleLostPositionsHint="-------------------";
extern bool     HandleLostPositions=false;
input  int      MaxPendingAmount=5;                
extern int      StepInPoints=500;
extern int      PendingOrderAfter=250;
extern int      PendingOrderExpiry=30;
extern int      PointsToTake=100;
extern static string TradeAllSymbolsFromOneChart="Trade the choosen strategy on all available FX symbols";
extern bool     TradeOnAllSymbols=false;
extern bool     TradeOnlyListOfSelectedSymbols=false;
extern string   ListOfSelectedSymbols="EURUSD;USDJPY;GBPUSD";
extern string   ListOfSelectedTimeframesForSymbols="H4;D1;D1";
extern bool     TradeFromSignalToSignal=false;
extern static string TimeSettings="Trading time";
extern int      StartHour=8;
extern int      EndHour=20;
extern static string OnlyBuyOrSellMarket="-------------------";
extern bool     OnlyBuy=true;
extern bool     OnlySell=true;
extern static string UserPositions="Handle user opened positions as a EA own";
//extern static string HandleUserPositions_Comment="Available in the full version!";
extern bool     HandleUserPositions=false;
bool     HandleUserPositionsOnDifferentCharts=false;
extern int      CountCharsInCommentToEscape=0;
extern static string SignalHandling="Create signals only on new candle or on every tick";
extern bool     HandleOnCandleOpenOnly=true;
//extern int      MaxOpenedPositionsOnCandle=3;
extern static string MaxOrdersSettings="Creates position independently of opened positions";
extern bool     AddPositionsIndependently=false;
extern int      MaxConcurrentOpenedOrders=4;
extern static string Notifications="Send notifications on signals";
extern bool     SendOnlyNotificationsNoTrades=false;
extern bool     SendEMail=false;
extern bool     SendNotificationToPhone=false;
extern bool     ShowAlertBox=false;
extern static string UsingEAOnDifferentTimeframes="-------------------";
extern int      MagicNumber=3537;

bool Debug=false;
bool DebugTrace=false;

/*licence*/
bool trial_lic=false;
datetime expiryDate=D'2018.12.01 00:00';
bool rent_lic=false;
datetime rentExpiryDate=D'2020.01.01 00:00';
int rentAccountNumber=0;
string rentCustomerName="";
/*licence_end*/

int RSI_Period=14;         //8-25
int RSI_Price=3;           //0-6
int Volatility_Band=26;    //20-40
int RSI_Price_Line=6;
int RSI_Price_Type=MODE_SMA;      //0-3
int Trade_Signal_Line=7;
int Trade_Signal_Line2=0;
int Trade_Signal_Type=MODE_SMA;   //0-3
int MAFastPeriod = 7;
int MASlowPeriod = 21;
int KPeriod1=21;
int DPeriod1=7;
int Slowing1=7;
int MAMethod1=0;
int PriceField1=0;
int ma_method=MODE_SMA;
int price_field=0;
int Slippage=3,BreakEven=0;
int TicketNrSell=0,TicketNrBuy=0;
double CurrentLoss=0;
double TP=TakeProfit,SL=StopLoss;
double SunriseSL=0;
double SLI=0,TPI=0;
string EAName="AreaFiftyOne";
string IndicatorName="AreaFiftyOneIndicator";
string IndicatorName2="AreaFiftyOne_Trend";
string IndicatorName7="Heiken_Ashi_Smoothed";
string IndicatorName8="MagicTrend";
string IndicatorName9="HMA_Color";
string IndicatorName10="Improved_CCI";
int handle_ind;
string symbolNameBuffer[];
string symbolTimeframeBuffer[];
bool SellFlag=false;
bool BuyFlag=false;
bool LotSizeIsBiggerThenMaxLot=false;
int countRemainingMaxLots=0;
double MaxLot;
double RemainingLotSize=0.0;
double tradeDoubleVarsValues[150][10];
int tradeIntVarsValues[150][10];
double lotstep;
bool CloseBuyTrade=false;
bool CloseSellTrade=false;
bool BuyOpened=false;
bool SellOpened=false;
int numBars=0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   setAllForTradeAvailableSymbols();
   setTradeVarsValues();

   if(DistanceForPending==0.0)
     {
      switch(Period())
        {
         case PERIOD_M1: DistanceForPending=30;break;
         case PERIOD_M5: DistanceForPending=50;break;
         case PERIOD_M15: DistanceForPending=80;break;
         case PERIOD_M30: DistanceForPending=120;break;
         case PERIOD_H1: DistanceForPending=150;break;
         case PERIOD_H4: DistanceForPending=200;break;
         case PERIOD_D1: DistanceForPending=300;break;
         case PERIOD_W1: DistanceForPending=375;break;
         case PERIOD_MN1: DistanceForPending=450;break;
         default: DistanceForPending=50;break;
        }
     }
   DistanceForPending=DistanceForPending*MarketInfo(Symbol(),MODE_POINT);

   numBars=Bars;

   if(Debug)
     {
      Print("****Main ChartWindowDebugValues*****");
      Print("AccountNumber="+IntegerToString(AccountNumber()));
      Print("AccountCompany="+AccountCompany());
      Print("AccountName=",AccountName());
      Print("AccountServer=",AccountServer());
      Print("MODE_LOTSIZE=",MarketInfo(Symbol(),MODE_LOTSIZE),", Symbol=",Symbol());
      Print("MODE_MINLOT=",MarketInfo(Symbol(),MODE_MINLOT),", Symbol=",Symbol());
      Print("MODE_LOTSTEP=",MarketInfo(Symbol(),MODE_LOTSTEP),", Symbol=",Symbol());
      Print("MODE_MAXLOT=",MarketInfo(Symbol(),MODE_MAXLOT),", Symbol=",Symbol());
     }
   if(trial_lic)
     {
      if(!IsTesting() && TimeCurrent()>expiryDate)
        {
         Alert("Expired copy. Please contact vendor.");
         return(INIT_FAILED);
           } else {
         ObjectCreate("TrialVersion",OBJ_LABEL,0,0,0);
         ObjectSetText("TrialVersion","End of a trial period: "+TimeToStr(expiryDate),11,"Calibri",clrAqua);
         ObjectSet("TrialVersion",OBJPROP_CORNER,1);
         ObjectSet("TrialVersion",OBJPROP_XDISTANCE,5);
         ObjectSet("TrialVersion",OBJPROP_YDISTANCE,15);
        }
     }

   if(rent_lic)
     {
      if(!IsTesting() && AccountName()==rentCustomerName)// && AccountNumber()==rentAccountNumber)
        {
         if(TimeCurrent()>rentExpiryDate)
           {
            Alert("Your license is expired. Please contact us under info@vbapps.co.");
              } else {
            ObjectCreate("RentVersion",OBJ_LABEL,0,0,0);
            ObjectSetText("RentVersion","Your version is valid till: "+TimeToStr(rentExpiryDate),11,"Calibri",clrAqua);
            ObjectSet("RentVersion",OBJPROP_CORNER,1);
            ObjectSet("RentVersion",OBJPROP_XDISTANCE,5);
            ObjectSet("RentVersion",OBJPROP_YDISTANCE,15);

           }
           } else {
         if(!IsTesting())
           {
            Alert("You can use the expert advisor only on accountNumber="+IntegerToString(rentAccountNumber)+" and accountName="+rentCustomerName);
            Alert("Current accountNumber="+IntegerToString(AccountNumber())+" && accountName="+AccountName());
            Alert("Please contact the vendor at info@vbapps.co for more information.");
            return(INIT_FAILED);
           }
        }
     }
//HideTestIndicators(true);
   if(UseRSIBasedIndicator)
     {
      handle_ind=0;
      //handle_ind=(int)iCustom(_Symbol,_Period,"::"+INDPATH+""+IndicatorName+".ex4",0,0);
      //if(handle_ind==INVALID_HANDLE)
      //{
      // Print("Expert: iCustom call: Error code=",GetLastError());
      // return(INIT_FAILED);
      //}
     }
   if(UseTrendIndicator)
     {
      handle_ind=0;
      handle_ind=(int)iCustom(_Symbol,_Period,"::"+INDPATH+""+IndicatorName2+".ex4",7575,Smoothing,0,0);
      if(handle_ind==INVALID_HANDLE)
        {
         Print("Expert: iCustom call_2: Error code=",GetLastError());
         return(INIT_FAILED);
        }
     }
   if(UseMagicTrendStrategy)
     {
      int handle_ind8=0;
      handle_ind8=(int)iCustom(_Symbol,_Period,"::"+INDPATH+""+IndicatorName8+".ex4",0,0);
      if(handle_ind8==INVALID_HANDLE)
        {
         Print("Expert: iCustom call_8: Error code=",GetLastError());
         return(INIT_FAILED);
        }
     }
   if(UseHMAStrategy)
     {
      int handle_ind9=0;
      handle_ind9=(int)iCustom(_Symbol,_Period,"::"+INDPATH+""+IndicatorName9+".ex4",110,0,3,false,0,0);
      if(handle_ind9==INVALID_HANDLE)
        {
         Print("Expert: iCustom call_9: Error code=",GetLastError());
         return(INIT_FAILED);
        }
     }
   if(UseSmoothedStrategy)
     {
      int handle_ind7=0;
      handle_ind7=(int)iCustom(_Symbol,_Period,"::"+INDPATH+""+IndicatorName7+".ex4",0,0);
      if(handle_ind7==INVALID_HANDLE)
        {
         Print("Expert: iCustom call_7: Error code=",GetLastError());
         return(INIT_FAILED);
        }
     }
/*if(UseCCIAverageStrategy)
     {
      int handle_ind10=0;
      handle_ind10=(int)iCustom(_Symbol,_Period,"::"+INDPATH+""+IndicatorName10+".ex4",0,0);
      if(handle_ind10==INVALID_HANDLE)
        {
         Print("Expert: iCustom call_10: Error code=",GetLastError());
         return(INIT_FAILED);
        }
     }*/
   HideTestIndicators(false);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectDelete("CurProfit");
   ObjectDelete("NextLotSize");
   ObjectDelete("CurrentLoss");
   ObjectDelete("CurProfitOfManualPlacedUserPositions");
   ObjectDelete("MagicNumber");
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   uint start=GetTickCount();
   setTradeVarsValues();
   double TempLoss=getTempLoss();

   if(AccountBalance()>0)
     {
      CurrentLoss=NormalizeDouble((TempLoss/AccountBalance())*100,2);
     }
   if((MoneyRiskInPercent>0 && StrToInteger(DoubleToStr(MathAbs(CurrentLoss),0))>MoneyRiskInPercent)
      || (MaxMoneyValueToLose>0 && StrToInteger(DoubleToStr(MathAbs(TempLoss),0))>MaxMoneyValueToLose))
     {
      while(CloseAll()==AT_LEAST_ONE_FAILED)
        {
         Sleep(1000);
         Print("Order close failed - retrying error: #"+IntegerToString(GetLastError()));
        }
     }

   if(HandleLostPositions)
     {
      openPendingsForWrongDirectionTrades(Symbol());
      handleWrongDirectionTrades(Symbol());
     }

   int limit=1,err=0;
   bool BUY=false,SELL=false;
//SellFlag=false;BuyFlag=false;
   bool CheckForSignal=false;
   bool TradingAllowed=tradingAllowed();
//SERIES_LASTBAR_DATE?
   if(HandleOnCandleOpenOnly && Volume[0]==1) {CheckForSignal=true;} else {CheckForSignal=false;}
   if(HandleOnCandleOpenOnly==false && CurrentCandleHasNoOpenedTrades(Symbol())) {CheckForSignal=true;}

//double TempTDIGreen=0,TempTDIRed=0;
   HideTestIndicators(true);
   string strategyName="";
   if(TradingAllowed==true && CheckForSignal==true)
     {
      if(UseRSIBasedIndicator)
        {
         strategyName="tdi";
         if(TradeOnAllSymbols)
           {
            generateSignalsAndPositions("tdi");
              } else {
            string signalStr=getSignalForCurrencyAndStrategy(Symbol(),0,"tdi");
            if(signalStr=="Sell")
              {
               SellFlag=true;
                 } else if(signalStr=="Buy"){
               BuyFlag=true;
              }
           }
        }
      if(UseTrendIndicator)
        {
         strategyName="trendy";
         if(TradeOnAllSymbols)
           {
            generateSignalsAndPositions("trendy");
              } else {
            string signalStr=getSignalForCurrencyAndStrategy(Symbol(),0,"trendy");
            if(signalStr=="Sell")
              {
               SellFlag=true;
                 } else if(signalStr=="Buy"){
               BuyFlag=true;
              }
           }
        }
      if(UseSimpleTrendStrategy)
        {
         strategyName="simpleTrend";
         if(TradeOnAllSymbols)
           {
            generateSignalsAndPositions("simpleTrend");
              } else {
            string signalStr=getSignalForCurrencyAndStrategy(Symbol(),0,"simpleTrend");
            if(signalStr=="Sell")
              {
               SellFlag=true;
                 } else if(signalStr=="Buy"){
               BuyFlag=true;
              }
           }
        }
      if(UseStochasticBasedStrategy)
        {
         strategyName="baseStochi";
         if(TradeOnAllSymbols)
           {
            generateSignalsAndPositions("baseStochi");
              } else {
            string signalStr=getSignalForCurrencyAndStrategy(Symbol(),0,"baseStochi");
            if(signalStr=="Sell")
              {
               SellFlag=true;
                 } else if(signalStr=="Buy"){
               BuyFlag=true;
              }
           }
        }
      if(Use5050Strategy)
        {
         strategyName="5050";
         if(TradeOnAllSymbols)
           {
            generateSignalsAndPositions("5050");
              } else {
            string signalStr=getSignalForCurrencyAndStrategy(Symbol(),0,"5050");
            if(signalStr=="Sell")
              {
               SellFlag=true;
                 } else if(signalStr=="Buy"){
               BuyFlag=true;
              }
           }
        }
      if(UseMAOn5050Strategy)
        {
         strategyName="MAOn5050";
         if(TradeOnAllSymbols)
           {
            generateSignalsAndPositions("MAOn5050");
              } else {
            string signalStr=getSignalForCurrencyAndStrategy(Symbol(),0,"MAOn5050");
            if(signalStr=="Sell")
              {
               SellFlag=true;
                 } else if(signalStr=="Buy"){
               BuyFlag=true;
              }
           }
        }
      if(UseStochRSICroosingStrategy)
        {
         strategyName="stochCroosingRSI";
         if(TradeOnAllSymbols)
           {
            generateSignalsAndPositions("stochCroosingRSI");
              } else {
            string signalStr=getSignalForCurrencyAndStrategy(Symbol(),0,"stochCroosingRSI");
            if(signalStr=="Sell")
              {
               SellFlag=true;
                 } else if(signalStr=="Buy"){
               BuyFlag=true;
              }
           }
        }
      if(UseLongTermJourneyToSunriseStrategy)
        {
         strategyName="sunTrade";
         if(TradeOnAllSymbols)
           {
            generateSignalsAndPositions("sunTrade");
              } else {
            string signalStr=getSignalForCurrencyAndStrategy(Symbol(),0,"sunTrade");
            if(signalStr=="Sell")
              {
               SellFlag=true;
                 } else if(signalStr=="Buy"){
               BuyFlag=true;
              }
           }
        }
      if(UseSolarWindStrategy)
        {
         strategyName="solarWind";
         if(TradeOnAllSymbols)
           {
            generateSignalsAndPositions("solarWind");
              } else {
            string signalStr=getSignalForCurrencyAndStrategy(Symbol(),0,"solarWind");
            if(signalStr=="Sell")
              {
               SellFlag=true;
                 } else if(signalStr=="Buy"){
               BuyFlag=true;
              }
           }
        }
      if(UseMagicTrendStrategy)
        {
         strategyName="magicTrend";
         if(TradeOnAllSymbols)
           {
            generateSignalsAndPositions("magicTrend");
              } else {
            string signalStr=getSignalForCurrencyAndStrategy(Symbol(),0,"magicTrend");
            if(signalStr=="Sell")
              {
               SellFlag=true;
                 } else if(signalStr=="Buy"){
               BuyFlag=true;
              }
           }
        }
      if(UseNightAsianBlock)
        {
         strategyName="nightAsianBlock";
         if(TradeOnAllSymbols)
           {
            generateSignalsAndPositions("nightAsianBlock");
              } else {
            string signalStr=getSignalForCurrencyAndStrategy(Symbol(),0,"nightAsianBlock");
            if(signalStr=="Sell")
              {
               SellFlag=true;
                 } else if(signalStr=="Buy"){
               BuyFlag=true;
              }
           }
        }
      if(UseIchimokuClouds)
        {
         strategyName="ichimoku";
         if(TradeOnAllSymbols)
           {
            generateSignalsAndPositions("ichimoku");
              } else {
            string signalStr=getSignalForCurrencyAndStrategy(Symbol(),0,"ichimoku");
            if(signalStr=="Sell")
              {
               SellFlag=true;
                 } else if(signalStr=="Buy"){
               BuyFlag=true;
              }
           }
        }
      if(UseADX50Plus)
        {
         strategyName="adx50";
         if(TradeOnAllSymbols)
           {
            generateSignalsAndPositions("adx50");
              } else {
            string signalStr=getSignalForCurrencyAndStrategy(Symbol(),0,"adx50");
            if(signalStr=="Sell")
              {
               SellFlag=true;
                 } else if(signalStr=="Buy"){
               BuyFlag=true;
              }
           }
        }
      if(UseHMAStrategy)
        {
         strategyName="hmaColor";
         if(TradeOnAllSymbols)
           {
            generateSignalsAndPositions("hmaColor");
              } else {
            string signalStr=getSignalForCurrencyAndStrategy(Symbol(),0,"hmaColor");
            if(signalStr=="Sell")
              {
               SellFlag=true;
                 } else if(signalStr=="Buy"){
               BuyFlag=true;
              }
           }
        }
      if(UseSmoothedStrategy)
        {
         strategyName="smoothed";
         if(TradeOnAllSymbols)
           {
            generateSignalsAndPositions("smoothed");
              } else {
            string signalStr=getSignalForCurrencyAndStrategy(Symbol(),0,"smoothed");
            if(signalStr=="Sell")
              {
               SellFlag=true;
                 } else if(signalStr=="Buy"){
               BuyFlag=true;
              }
           }
        }
      if(UseSimpleMAsStrategy)
        {
         strategyName="simpleMAs";
         if(TradeOnAllSymbols)
           {
            generateSignalsAndPositions("simpleMAs");
              } else {
            string signalStr=getSignalForCurrencyAndStrategy(Symbol(),0,"simpleMAs");
            if(signalStr=="Sell")
              {
               SellFlag=true;
                 } else if(signalStr=="Buy"){
               BuyFlag=true;
              }
           }
        }
      if(UseCCIAverageStrategy)
        {
         strategyName="cciaverage";
         if(TradeOnAllSymbols)
           {
            generateSignalsAndPositions("cciaverage");
              } else {
            string signalStr=getSignalForCurrencyAndStrategy(Symbol(),0,"cciaverage");
            if(signalStr=="Sell")
              {
               SellFlag=true;
                 } else if(signalStr=="Buy"){
               BuyFlag=true;
              }
           }
        }
      if(UseMagicSymphonieStrategy)
        {
         strategyName="magicSymphonie";
         if(TradeOnAllSymbols)
           {
            generateSignalsAndPositions("magicSymphonie");
              } else {
            string signalStr=getSignalForCurrencyAndStrategy(Symbol(),0,"magicSymphonie");
            if(signalStr=="Sell")
              {
               SellFlag=true;
                 } else if(signalStr=="Buy"){
               BuyFlag=true;
              }
           }
        }
     }
//HideTestIndicators(false);
   if(HandleUserPositions && !TradeOnAllSymbols){HandleUserPositionsFun();}

//conditions to close positions
/* if(SellFlag>0){CloseBuy=1;}
   if(BuyFlag>0){CloseSell=1;}
*/
   if(TradeOnAllSymbols==false)
     {
      //positions initialization
      int cnt=0,OP=0,OS=0,OB=0,CloseSell=0,OSC=0,OBC=0,CloseBuy=0;OP=0;
      for(cnt=0;cnt<OrdersTotal();cnt++)
        {
         if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES)==true)
           {
            if((OrderType()==OP_SELL || OrderType()==OP_BUY) && OrderSymbol()==Symbol() && ((OrderMagicNumber()==MagicNumber)))
              {
               OP=OP+1;
               if(OrderType()==OP_SELL)OSC=OSC+1;
               if(OrderType()==OP_BUY)OBC=OBC+1;
              }
           }
        }
      if(OP>=1){OS=0;OB=0;}OB=0;OS=0;CloseBuy=0;CloseSell=0;
      //entry conditions verification
      if(SellFlag==true){OS=1;OB=0;SellFlag=false;}if(BuyFlag==true){OB=1;OS=0;BuyFlag=false;}
      LotSizeIsBiggerThenMaxLot=tradeIntVarsValues[0][4];
      RemainingLotSize=tradeDoubleVarsValues[0][4];
      countRemainingMaxLots=(int)tradeDoubleVarsValues[0][3];
      MaxLot=tradeDoubleVarsValues[0][2];
      if((OB==1 || OS==1) && TradingAllowed)
        {
         //Print("Signal from one of  strategies! Control Point 0!..");
         OpenPosition(Symbol(),strategyName,Period(),OP,OSC,OBC,OS,OB,LotSizeIsBiggerThenMaxLot,countRemainingMaxLots,MaxLot,RemainingLotSize);
        }

      double TempProfitUserPosis=0.0;
      if(HandleUserPositions)
        {
         for(int ff=0;ff<OrdersTotal();ff++)
           {
            if(OrderSelect(ff,SELECT_BY_POS,MODE_TRADES))
              {
               string OrderCom=OrderComment();
               if((StringLen(OrderCom)-CountCharsInCommentToEscape)>0 || (StringLen(OrderCom)-CountCharsInCommentToEscape==0))
                 {
                  OrderCom=StringSubstr(OrderCom,StringLen(OrderCom)-CountCharsInCommentToEscape,StringLen(OrderCom));
                    } else if((StringLen(OrderCom)-CountCharsInCommentToEscape)<0) {
                  OrderCom="";
                 }
               if(OrderSymbol()==Symbol() && (OrderComment()=="" || OrderCom=="") && OrderMagicNumber()==0)
                 {
                  TrP(Symbol());
                 }
              }
           }
         for(int f=0;f<OrdersTotal();f++)
           {
            if(OrderSelect(f,SELECT_BY_POS,MODE_TRADES))
              {
               string OrderCom=OrderComment();
               if((StringLen(OrderCom)-CountCharsInCommentToEscape)>0 || (StringLen(OrderCom)-CountCharsInCommentToEscape==0))
                 {
                  OrderCom=StringSubstr(OrderCom,StringLen(OrderCom)-CountCharsInCommentToEscape,StringLen(OrderCom));
                    } else if((StringLen(OrderCom)-CountCharsInCommentToEscape)<0) {
                  OrderCom="";
                 }
               if(OrderSymbol()==Symbol() && (OrderComment()=="" || OrderCom=="") && OrderMagicNumber()==0)
                 {
                  TempProfitUserPosis=TempProfitUserPosis+OrderProfit()+OrderCommission()+OrderSwap();
                 }
              }
           }
         CurrentProfit(checkForMod(Symbol()),TempProfitUserPosis);
           } else {
         CurrentProfit(checkForMod(Symbol()),0.0);
        }
        } else {
      double TempProfit=0.0;
      for(int j=0;j<OrdersTotal();j++)
        {
         if(OrderSelect(j,SELECT_BY_POS,MODE_TRADES))
           {
            if(OrderMagicNumber()==MagicNumber)
              {
               TempProfit=TempProfit+OrderProfit()+OrderCommission()+OrderSwap();
               if(Debug){Print("TempProfit="+DoubleToStr(TempProfit));}
              }
           }
        }
      CurrentProfit(TempProfit,0.0);
     }
   uint time=GetTickCount()-start;
//PrintFormat("Calculating tick fun took %d ms",time);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OpenPosition(string symbolName,string strategyName,int symbolTimeframe,int OP,int OSC,int OBC,int OS,int OB,bool LotSizeIsBiggerThenMaxLotT,int countRemainingMaxLotsT,double MaxLotT,double RemainingLotSizeT)
  {
//Print("OpenPositionFun-Start -> SymbolName="+symbolName+";OSC="+IntegerToString(OSC)+";OBC="+IntegerToString(OBC));
   if(TradeFromSignalToSignal)
     {
      //Print("OpenPositionFun-TradeFromSignalToSignal is active.");
      if(OS==1)
        {
         ClosePreviousSignalTrade(symbolName,OS,0);
        }
      if(OB==1)
        {
         ClosePreviousSignalTrade(symbolName,0,OB);
        }
     }

//open position
   if(((getCurrentSpreadForSymbol(symbolName)<=MaxSpread) && AddP(symbolName) && AddPositionsIndependently && OP*2<=MaxConcurrentOpenedOrders) || (OP==0 && !AddPositionsIndependently))
     {
      Print("OpenPositionFun-Control Point 1 passed...");
      if(OnlySell==true && !(AccountFreeMarginCheck(symbolName,OP_SELL,tradeDoubleVarsValues[getSymbolArrayIndex(symbolName)][6]*3)<=0 || GetLastError()==134))
        {
         Print("OpenPositionFun-Control Point 2 for SELL passed... OS="+(string)OS+";OSC="+(string)OSC);
         if(OS==1 && OSC<MaxConcurrentOpenedOrders)
           {
            Print("OpenPositionFun-Control Point 3 passed...");
            if(TP==0)TPI=0;else TPI=MarketInfo(symbolName,MODE_BID)-TP*MarketInfo(symbolName,MODE_POINT);if(SL==0)SLI=MarketInfo(symbolName,MODE_BID)+10000*MarketInfo(symbolName,MODE_POINT);else SLI=MarketInfo(symbolName,MODE_BID)+SL*MarketInfo(symbolName,MODE_POINT);
            if(UseLongTermJourneyToSunriseStrategy && SunriseSL>0){SLI=SunriseSL+AdditionalSL*MarketInfo(symbolName,MODE_POINT);}
            if(CheckMoneyForTrade(symbolName,tradeDoubleVarsValues[getSymbolArrayIndex(symbolName)][6],OP_SELL))
              {
               Print("OpenPositionFun-Control Point 4 passed...");
               if(CheckStopLoss_Takeprofit(symbolName,ORDER_TYPE_SELL,SLI,TPI) && CheckVolumeValue(symbolName,tradeDoubleVarsValues[getSymbolArrayIndex(symbolName)][6]))
                 {
                  Print("OpenPositionFun-Control Point 5 passed... Try to open sell trade!");
                  if(strategyName=="smoothed")
                    {
                     double smoothed3_blue_pending_o_price=NormalizeDouble(iCustom(symbolName,symbolTimeframe,"::"+INDPATH+""+IndicatorName7+".ex4",3,0),(int)MarketInfo(symbolName,MODE_DIGITS))-DistanceForPending;
                     if(NormalizeDouble(MarketInfo(symbolName,MODE_BID),5)<NormalizeDouble(smoothed3_blue_pending_o_price,5))
                       {
                        smoothed3_blue_pending_o_price=MarketInfo(symbolName,MODE_BID)+DistanceForPending;
                       }
                     //Add pending orders instead of market orders
                     TicketNrSell=OrderSend(symbolName,OP_SELLSTOP,tradeDoubleVarsValues[getSymbolArrayIndex(symbolName)][6],smoothed3_blue_pending_o_price,Slippage,SLI,TPI,EAName+"!1",MagicNumber,0,Red);OS=0;
                       } else {
                     TicketNrSell=OrderSend(symbolName,OP_SELL,tradeDoubleVarsValues[getSymbolArrayIndex(symbolName)][6],MarketInfo(symbolName,MODE_BID),Slippage,SLI,TPI,EAName+"!1",MagicNumber,0,Red);OS=0;
                    }
                  if(TicketNrSell<0)
                    {Print(EAName+" => OrderSend Error: "+IntegerToString(GetLastError()));}
                  if(LotSizeIsBiggerThenMaxLotT)
                    {
                     Print("OpenPositionFun-Control Point 6 passed...");
                     for(int c=0;c<countRemainingMaxLotsT-1;c++)
                       {
                        if(OrderSend(symbolName,OP_SELL,MaxLotT,MarketInfo(symbolName,MODE_BID),Slippage,SLI,TPI,EAName+"!1",MagicNumber,0,Red)<0)
                          {Print(EAName+" => OrderSend Error: "+IntegerToString(GetLastError()));}
                       }
                     if(OrderSend(symbolName,OP_SELL,RemainingLotSizeT,MarketInfo(symbolName,MODE_BID),Slippage,SLI,TPI,EAName+"!1",MagicNumber,0,Red)<0)
                       {Print(EAName+" => OrderSend Error: "+IntegerToString(GetLastError()));}
                    }
                 }
              }
           }
        }
      if(OnlyBuy==true && !(AccountFreeMarginCheck(Symbol(),OP_BUY,tradeDoubleVarsValues[getSymbolArrayIndex(symbolName)][6]*3)<=0 || GetLastError()==134))
        {
         Print("OpenPositionFun-Control Point 2 for BUY passed...");
         if(OB==1 && OBC<MaxConcurrentOpenedOrders)
           {
            Print("OpenPositionFun-Control Point 3 passed...");
            if(TP==0)TPI=0;else TPI=MarketInfo(symbolName,MODE_ASK)+TP*MarketInfo(symbolName,MODE_POINT);if(SL==0)SLI=MarketInfo(symbolName,MODE_ASK)-10000*MarketInfo(symbolName,MODE_POINT);else SLI=MarketInfo(symbolName,MODE_ASK)-SL*MarketInfo(symbolName,MODE_POINT);
            if(UseLongTermJourneyToSunriseStrategy && SunriseSL>0){SLI=SunriseSL-AdditionalSL*MarketInfo(symbolName,MODE_POINT);}
            if(CheckMoneyForTrade(symbolName,tradeDoubleVarsValues[getSymbolArrayIndex(symbolName)][6],OP_BUY))
              {
               Print("OpenPositionFun-Control Point 4 passed...");
               if(CheckStopLoss_Takeprofit(symbolName,ORDER_TYPE_BUY,SLI,TPI) && CheckVolumeValue(symbolName,tradeDoubleVarsValues[getSymbolArrayIndex(symbolName)][6]))
                 {
                  Print("OpenPositionFun-Control Point 5 passed... Try to open buy trade!");
                  if(strategyName=="smoothed")
                    {
                     double smoothed2_red_pending_o_price=NormalizeDouble(iCustom(symbolName,symbolTimeframe,"::"+INDPATH+""+IndicatorName7+".ex4",2,0),(int)MarketInfo(symbolName,MODE_DIGITS))+DistanceForPending;
                     if(NormalizeDouble(MarketInfo(symbolName,MODE_ASK),5)>NormalizeDouble(smoothed2_red_pending_o_price,5))
                       {
                        smoothed2_red_pending_o_price=MarketInfo(symbolName,MODE_ASK)+DistanceForPending;
                       }
                     //Add pending orders instead of market orders
                     TicketNrSell=OrderSend(symbolName,OP_BUYSTOP,tradeDoubleVarsValues[getSymbolArrayIndex(symbolName)][6],smoothed2_red_pending_o_price,Slippage,SLI,TPI,EAName+"!1",MagicNumber,0,Red);OS=0;
                       } else {
                     TicketNrBuy=OrderSend(symbolName,OP_BUY,tradeDoubleVarsValues[getSymbolArrayIndex(symbolName)][6],MarketInfo(symbolName,MODE_ASK),Slippage,SLI,TPI,EAName+"!1",MagicNumber,0,Lime);OB=0;
                    }
                  if(TicketNrBuy<0)
                    {Print(EAName+" => OrderSend Error: "+IntegerToString(GetLastError()));}
                  if(LotSizeIsBiggerThenMaxLotT)
                    {
                     Print("OpenPositionFun-Control Point 6 passed...");
                     for(int c=0;c<countRemainingMaxLotsT-1;c++)
                       {
                        if(OrderSend(symbolName,OP_BUY,MaxLotT,MarketInfo(symbolName,MODE_ASK),Slippage,SLI,TPI,EAName+"!1",MagicNumber,0,Lime)<0)
                          {Print(EAName+" => OrderSend Error: "+IntegerToString(GetLastError()));}
                       }
                     if(OrderSend(symbolName,OP_BUY,RemainingLotSizeT,MarketInfo(symbolName,MODE_ASK),Slippage,SLI,TPI,EAName+"!1",MagicNumber,0,Lime)<0)
                       {Print(EAName+" => OrderSend Error: "+IntegerToString(GetLastError()));}
                    }
                 }
              }
           }
        }
     }
   CurrentProfit(checkForMod(symbolName),0.0);
//not enough money message to continue the martingale
   if((TicketNrBuy<0 || TicketNrSell<0) && GetLastError()==134){Print("NOT ENOGUGHT MONEY!!");}
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ClosePreviousSignalTrade(string symbolName,int OS,int OB)
  {
//Print("symbolName="+symbolName+";OS="+OS+";OB="+OB);
   bool closed=false;
   for(int cnt=0;cnt<OrdersTotal();cnt++)
     {
      if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol()==symbolName && OrderMagicNumber()==MagicNumber)
           {
            if(OrderType()==OP_BUY && OS==1)
              {
               closed=OrderClose(OrderTicket(),OrderLots(),MarketInfo(symbolName,MODE_BID),Slippage,Red);
               if(!closed) {closed=OrderClose(OrderTicket(),OrderLots(),MarketInfo(symbolName,MODE_BID),Slippage,Red);}
              }
            if(OrderType()==OP_SELL && OB==1)
              {
               closed=OrderClose(OrderTicket(),OrderLots(),MarketInfo(symbolName,MODE_ASK),Slippage,Red);
               if(!closed) {closed=OrderClose(OrderTicket(),OrderLots(),MarketInfo(symbolName,MODE_ASK),Slippage,Red);}
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
//---
   double ret=AccountBalance();
   return(ret);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//TODO: Add csv file with ordernummer, magicnumber
// this csv should check, if for current magicnumber orders are found 
// then the orders should be handled
// the fun can be enabled due a param HandleUserPositionsOnDifferentCharts=false/true
// with this functionallity should reached, that user positions will be handled 
// with different settings (e.g. TS and DS values)
void HandleUserPositionsFun()
  {
   for(int j=0;j<OrdersTotal();j++)
     {
      if(OrderSelect(j,SELECT_BY_POS)==true && OrderSymbol()==Symbol())
        {
         if(Debug){Print("OrderComment='"+OrderComment()+"'");}
         if(Debug){Print("OrderMagicNumber='"+IntegerToString(OrderMagicNumber())+"'");}
         string OrderCom=OrderComment();
         if((StringLen(OrderCom)-CountCharsInCommentToEscape)>0 || (StringLen(OrderCom)-CountCharsInCommentToEscape==0))
           {
            OrderCom=StringSubstr(OrderCom,StringLen(OrderCom)-CountCharsInCommentToEscape,StringLen(OrderCom));
              } else if((StringLen(OrderCom)-CountCharsInCommentToEscape)<0) {
            OrderCom="";
           }
         if(OrderMagicNumber()==0 && (OrderComment()=="" || OrderCom==""))
           {
            if((OrderType()==OP_SELL) && (((OrderOpenPrice()-OrderTakeProfit())!=TakeProfit*Point)
               || ((OrderStopLoss()>OrderOpenPrice()) || OrderStopLoss()==0)))
              {
               if(TP==0)TPI=0;else TPI=OrderOpenPrice()-TP*Point;if(SL==0)SLI=OrderOpenPrice()+10000*Point;else SLI=OrderOpenPrice()+SL*Point;
               if(OrderModifyCheck(Symbol(),OrderTicket(),OrderOpenPrice(),SLI,TPI) && CheckStopLoss_Takeprofit(OrderTicket(),OrderOpenPrice(),Symbol(),ORDER_TYPE_SELL,SLI,TPI))
                 {
                  if(OrderTakeProfit()!=TPI && ((OrderStopLoss()<SLI && OrderOpenPrice()<OrderStopLoss()) || OrderStopLoss()==0))
                    {
                     bool Res=OrderModify(OrderTicket(),OrderOpenPrice(),SLI,TPI,0,clrGoldenrod);
                    }
                 }
              }
            else
               if((OrderType()==OP_BUY) && (((OrderTakeProfit()-OrderOpenPrice())!=TakeProfit*Point)
                  || ((OrderStopLoss()<OrderOpenPrice()) || OrderStopLoss()==0)))
                 {
                  if(TP==0)TPI=0;else TPI=OrderOpenPrice()+TP*Point;if(SL==0)SLI=OrderOpenPrice()-10000*Point;else SLI=OrderOpenPrice()-SL*Point;
                  if(OrderModifyCheck(Symbol(),OrderTicket(),OrderOpenPrice(),SLI,TPI) && CheckStopLoss_Takeprofit(OrderTicket(),OrderOpenPrice(),Symbol(),ORDER_TYPE_BUY,SLI,TPI))
                    {
                     if(OrderTakeProfit()!=TPI && ((OrderStopLoss()>SLI && OrderOpenPrice()>OrderStopLoss()) || OrderStopLoss()==0))
                       {
                        bool Res=OrderModify(OrderTicket(),OrderOpenPrice(),SLI,TPI,0,clrGoldenrod);
                       }
                    }
                 }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|add positions function                                            |
//+------------------------------------------------------------------+													  
bool AddP(string symbolName)
  {
   int _num=0,_ot=0;
   for(int j=0;j<OrdersTotal();j++)
     {
      if(OrderSelect(j,SELECT_BY_POS)==true && OrderSymbol()==symbolName && OrderType()<3 && (OrderMagicNumber()==MagicNumber))
        {
         _num++;if(OrderOpenTime()>_ot) _ot=(int)OrderOpenTime();
        }
     }
   if(_num==0) return(true);if(_num>0 && ((Time[0]-_ot))>0) return(true);else return(false);
  }
//trailing stop and breakeven
void TrP(string symbolName)
  {
   int BE=0;int TS=DistanceStep;double pbid,pask,ppoint;ppoint=MarketInfo(symbolName,MODE_POINT);
   TS=getTradeIntVarValue(getSymbolArrayIndex(symbolName),3);
   int TRS=getTradeIntVarValue(getSymbolArrayIndex(symbolName),2);
   double commissions=OrderCommission()+OrderSwap();
   double commissionsInPips;
   double tickValue=MarketInfo(symbolName,MODE_TICKVALUE);
   if(Debug) {Print("tickValue="+DoubleToStr(tickValue,5));}
   if(tickValue==0) {tickValue=0.9;}
   double spread=MarketInfo(symbolName,MODE_ASK)-MarketInfo(symbolName,MODE_BID);
   double tickSize=MarketInfo(symbolName,MODE_TICKSIZE);
   if(Debug) {Print("commissions="+DoubleToStr(commissions,8));}
   commissionsInPips=((commissions/OrderLots()/tickValue)*tickSize)+(spread*2);
   if(Debug){Print("commissionsInPips="+DoubleToStr(commissionsInPips));}
   if(commissionsInPips<0){commissionsInPips=commissionsInPips-(commissionsInPips*2);}
   if(DebugTrace)
     {
      Print("commissionsInPips(Ticket="+IntegerToString(OrderTicket())+")="+DoubleToStr(commissionsInPips,5)
            +";DistanceStep="+IntegerToString(TS)+";TrailingStep="+IntegerToString(TRS));
     }
   if(OrderType()==OP_BUY)
     {
      pbid=MarketInfo(symbolName,MODE_BID);
      if(BE>0)
        {
         if((pbid-OrderOpenPrice())>BE*ppoint)
           {
            if((OrderStopLoss()-OrderOpenPrice())<0)
              {
               if(Debug){Print("Fall1");}
               ModSL(symbolName,OrderOpenPrice()+0*ppoint+commissionsInPips);
              }
           }
        }
      if(TS>0)
        {
         if((pbid-OrderOpenPrice())>TS*ppoint)
           {
            if(OrderStopLoss()<(pbid-((TS+TRS-1)*ppoint+commissionsInPips+tradeDoubleVarsValues[getSymbolArrayIndex(symbolName)][7]*1.3)))
              {
               if((pbid-((TS+TRS-1)*ppoint+commissionsInPips+tradeDoubleVarsValues[getSymbolArrayIndex(symbolName)][7]*1.3))>OrderOpenPrice())
                 {
                  if(Debug)
                    {
                     Print("Fall2: "+"Ask="+DoubleToStr(pbid,5)+";TS="+IntegerToString(TS)+
                           ";commissionInPips="+DoubleToStr(commissionsInPips,5));
                    }
                  if(pbid>pbid-(TS*ppoint+commissionsInPips+tradeDoubleVarsValues[getSymbolArrayIndex(symbolName)][7]*1.3))
                    {
                     ModSL(symbolName,pbid-(TS*ppoint+commissionsInPips+tradeDoubleVarsValues[getSymbolArrayIndex(symbolName)][7]*1.3));
                    }
                 }
               return;
              }
           }
        }
     }
   if(OrderType()==OP_SELL)
     {
      pask=MarketInfo(OrderSymbol(),MODE_ASK);
      if(BE>0)
        {
         if((OrderOpenPrice()-pask)>BE*ppoint)
           {
            if((OrderOpenPrice()-OrderStopLoss())<0)
              {
               if(Debug){Print("Fall3");}
               ModSL(symbolName,OrderOpenPrice()-0*ppoint-commissionsInPips);
              }
           }
        }
      if(TS>0)
        {
         if(OrderOpenPrice()-pask>TS*ppoint)
           {
            if(OrderStopLoss()>(pask+((TS+TRS-1)*ppoint+commissionsInPips+tradeDoubleVarsValues[getSymbolArrayIndex(symbolName)][7]*1.3)) || OrderStopLoss()==0)
              {
               if((pask+((TS+TRS-1)*ppoint+commissionsInPips+tradeDoubleVarsValues[getSymbolArrayIndex(symbolName)][7]*1.3))<OrderOpenPrice())
                 {
                  if(Debug)
                    {
                     Print("Fall4: "+"Ask="+DoubleToStr(pask,5)+";TS="+IntegerToString(TS)+
                           ";commissionInPips="+DoubleToStr(commissionsInPips,5));
                    }
                  if(pask<pask+(TS*ppoint+commissionsInPips+tradeDoubleVarsValues[getSymbolArrayIndex(symbolName)][7]*1.3))
                    {
                     ModSL(symbolName,pask+(TS*ppoint+commissionsInPips+tradeDoubleVarsValues[getSymbolArrayIndex(symbolName)][7]*1.3));
                    }
                 }
               return;
              }
           }
        }
     }
  }
//stop loss modification function
void ModSL(string symbolName,double ldSL)
  {
   if(Debug)
     {
      Print("ldSL="+DoubleToStr(ldSL,5));
     }
   if(OrderModifyCheck(symbolName,OrderTicket(),OrderOpenPrice(),ldSL,OrderTakeProfit()))
     {
      if(OrderType()==OP_BUY)
        {
         if(CheckStopLoss_Takeprofit(OrderTicket(),OrderOpenPrice(),symbolName,ORDER_TYPE_BUY,ldSL,OrderTakeProfit()))
           {
            bool fm;fm=OrderModify(OrderTicket(),OrderOpenPrice(),ldSL,OrderTakeProfit(),0,Red);
           }
        }
      if(OrderType()==OP_SELL)
        {
         if(CheckStopLoss_Takeprofit(OrderTicket(),OrderOpenPrice(),symbolName,ORDER_TYPE_SELL,ldSL,OrderTakeProfit()))
           {
            bool fm;fm=OrderModify(OrderTicket(),OrderOpenPrice(),ldSL,OrderTakeProfit(),0,Red);
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
int cs,cb,total;
//+------------------------------------------------------------------+
void ClosePositionsByType(int type)
  {
   bool success;
   color col;
   int NumRetries=3;
   if(type==OP_BUY)
      col=Blue;
   else
      col=Red;
   for(int cnt=OrdersTotal()-1; cnt>=0; cnt --)
     {
      if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderMagicNumber()==MagicNumber && OrderSymbol()==Symbol() && OrderType()==type)
           {
            int i=0;
            while(i<3)
              {
               i+=1;
               while(IsTradeContextBusy())Sleep(NumRetries*1000);
               RefreshRates();

               Print("Try "+IntegerToString(i)+" : Close "+IntegerToString(OrderTicket()));
               success=OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),99,col);
               if(!success)
                 {
                  Print("Failed to close order "+IntegerToString(OrderTicket())+" Error code:"+IntegerToString(GetLastError()));
                  if(i==NumRetries)
                     Print("*** Final retry to CLOSE ORDER failed. Close trade manually ***");
                 }
               else
                  i=NumRetries;
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CountOrders()
  {
   cb = 0;
   cs = 0;

   for(int y=0; y<OrdersTotal(); y++)
     {
      if(OrderSelect(y,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderMagicNumber()==MagicNumber && OrderSymbol()==Symbol())
           {
            if(OrderType()==OP_BUY)
               cb++;
            else if(OrderType()==OP_SELL)
               cs++;

           }
        }
     }

   total=cb+cs;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string getSignalForCurrencyAndStrategy(string symbolName,int symbolTimeframe,string strategyName)
  {
// HideTestIndicators(true); //<- reactivate before publish!
   SellFlag=false;
   BuyFlag=false;
   string additionalText;
   int digits=(int)MarketInfo(symbolName,MODE_DIGITS);
   Print(strategyName);

   if(strategyName=="ichimoku")
     {
      double ask = NormalizeDouble(MarketInfo(symbolName,MODE_ASK),digits);
      double bid = NormalizeDouble(MarketInfo(symbolName,MODE_BID),digits);
      double tenkanSenCurr= NormalizeDouble(iIchimoku(symbolName,symbolTimeframe,Tenkan,Kijun,Senkou,MODE_TENKANSEN,0),digits);
      double kijunSenCurr = NormalizeDouble(iIchimoku(symbolName,symbolTimeframe,Tenkan,Kijun,Senkou,MODE_KIJUNSEN,0),digits);
      double tenkanSenPrev= NormalizeDouble(iIchimoku(symbolName,symbolTimeframe,Tenkan,Kijun,Senkou,MODE_TENKANSEN,1),digits);
      double kijunSenPrev = NormalizeDouble(iIchimoku(symbolName,symbolTimeframe,Tenkan,Kijun,Senkou,MODE_KIJUNSEN,1),digits);
      double tenkanSenPrev2=NormalizeDouble(iIchimoku(symbolName,symbolTimeframe,Tenkan,Kijun,Senkou,MODE_TENKANSEN,2),digits);
      double senkouSpanA = NormalizeDouble(iIchimoku(symbolName,symbolTimeframe,Tenkan,Kijun,Senkou,MODE_SENKOUSPANA,0),digits);
      double senkouSpanB = NormalizeDouble(iIchimoku(symbolName,symbolTimeframe,Tenkan,Kijun,Senkou,MODE_SENKOUSPANB,0),digits);
      double ma=NormalizeDouble(iMA(symbolName,symbolTimeframe,IchimokuMAPeriod,IchimokuMAShift,3,4,0),digits);
      double maPrev=NormalizeDouble(iMA(symbolName,symbolTimeframe,IchimokuMAPeriod,IchimokuMAShift,3,4,1),digits);
      double maPrev2=NormalizeDouble(iMA(symbolName,symbolTimeframe,IchimokuMAPeriod,IchimokuMAShift,3,4,2),digits);
      double adxLineCurr = NormalizeDouble(iADX(symbolName,symbolTimeframe,14,5,MODE_MAIN,0),digits);
      double adxLinePrev = NormalizeDouble(iADX(symbolName,symbolTimeframe,14,5,MODE_MAIN,1),digits);
      double adxDPlus=NormalizeDouble(iADX(symbolName,symbolTimeframe,14,5,MODE_PLUSDI,0),digits);
      double adxDMinus= NormalizeDouble(iADX(symbolName,symbolTimeframe,14,5,MODE_MINUSDI,0),digits);
      double ma34Curr = NormalizeDouble(iMA(symbolName,symbolTimeframe,34,0,MODE_EMA,5,0),digits);

      if(UseIchimokuADXMA)
        {
         if(adxLineCurr>20 && adxDPlus>adxDMinus && tenkanSenCurr>kijunSenCurr
            && senkouSpanA<senkouSpanB
            && (ask<senkouSpanA || ask<senkouSpanB))
           {
            if(!SendOnlyNotificationsNoTrades) {BuyFlag=true;}
            createNotifications(symbolName,"BUY",symbolTimeframe,additionalText,strategyName);
           }
         if(adxLineCurr>20 && adxDPlus<adxDMinus && tenkanSenCurr<kijunSenCurr
            && senkouSpanA>senkouSpanB
            && (bid>senkouSpanA || bid>senkouSpanB))
           {
            if(!SendOnlyNotificationsNoTrades) {SellFlag=true;}
            createNotifications(symbolName,"SELL",symbolTimeframe,additionalText,strategyName);
           }
         // TODO add closing rules
         // if(UseIchimokuADXMA2) {

         //}
/*
          Buy
- ADX(21/4) > 20
- -DI < +DI
- MA34/0/3/4 < TenkanSen(12/26/52)
- SenkouSpanA < SenkouSpanB
- SenkouSpanA > Preis || SenkouSpanB > Preis
- SL -> Tief der letzten 34 Kerzen
Sell
- ADX(21/4) > 20
- -DI > +DI
- MA34/0/3/4 > TenkanSen(12/26/52)
- SenkouSpanA > SenkouSpanB
- SenkouSpanA > Preis || SenkouSpanB > Preis
- SL -> Hoch der letzten 34 Kerzen
*/

        }

      // Print(tenkanSenCurr+"<>"+kijunSenCurr+" && " + tenkanSenCurr + "<>" + ma + "&& ("+tenkanSenPrev+"<>"+kijunSenPrev+") && "+senkouSpanA+"<>"+senkouSpanB);
      if(UseIchimokuCrossing)
        {
         if(tenkanSenCurr>kijunSenCurr && (tenkanSenPrev==kijunSenPrev || tenkanSenPrev<kijunSenPrev) && senkouSpanA<senkouSpanB && (ask<senkouSpanA || ask<senkouSpanB))
           {
            if(!SendOnlyNotificationsNoTrades) {BuyFlag=true;}
            createNotifications(symbolName,"BUY",symbolTimeframe,additionalText,strategyName);
           }

         if(tenkanSenCurr<kijunSenCurr && (tenkanSenPrev==kijunSenPrev || tenkanSenPrev>kijunSenPrev) && senkouSpanA>senkouSpanB && (bid>senkouSpanA || bid>senkouSpanB))
           {
            if(!SendOnlyNotificationsNoTrades) {SellFlag=true;}
            createNotifications(symbolName,"SELL",symbolTimeframe,additionalText,strategyName);
           }
        }
      if(UseIchimokuMACrossing)
        {
         if(tenkanSenCurr>ma && (tenkanSenPrev<maPrev || tenkanSenPrev2<maPrev2) && (tenkanSenPrev==kijunSenPrev || tenkanSenPrev<kijunSenPrev) && senkouSpanA<senkouSpanB && (ask<senkouSpanA || ask<senkouSpanB))
           {
            if(!SendOnlyNotificationsNoTrades) {BuyFlag=true;}
            createNotifications(symbolName,"BUY",symbolTimeframe,additionalText,strategyName);
           }
         if(tenkanSenCurr<ma && (tenkanSenPrev>maPrev || tenkanSenPrev2>maPrev2) && (tenkanSenPrev==kijunSenPrev || tenkanSenPrev>kijunSenPrev) && senkouSpanA>senkouSpanB && (bid>senkouSpanA || bid>senkouSpanB))
           {
            if(!SendOnlyNotificationsNoTrades) {SellFlag=true;}
            createNotifications(symbolName,"SELL",symbolTimeframe,additionalText,strategyName);
           }
        }
     }
   if(strategyName=="hmaColor")
     {
      int hmaPeriodSlow=110;
      int EMA_period=14;
      double currAsk = NormalizeDouble(MarketInfo(symbolName,MODE_ASK),digits);
      double currBid = NormalizeDouble(MarketInfo(symbolName,MODE_BID),digits);
      double adxLineCurr = NormalizeDouble(iADX(symbolName,symbolTimeframe,ADX50PlusPeriod,0,MODE_MAIN,0),digits);
      double adxLinePrev = NormalizeDouble(iADX(symbolName,symbolTimeframe,ADX50PlusPeriod,0,MODE_MAIN,1),digits);
      double adxDPlus=NormalizeDouble(iADX(symbolName,symbolTimeframe,ADX50PlusPeriod,0,MODE_PLUSDI,0),digits);
      double adxDMinus=NormalizeDouble(iADX(symbolName,symbolTimeframe,ADX50PlusPeriod,0,MODE_MINUSDI,0),digits);
      double adxDPlusPrev=NormalizeDouble(iADX(symbolName,symbolTimeframe,ADX50PlusPeriod,0,MODE_PLUSDI,1),digits);
      double adxDMinusPrev=NormalizeDouble(iADX(symbolName,symbolTimeframe,ADX50PlusPeriod,0,MODE_MINUSDI,1),digits);

      double hmaCurrSlow1=NormalizeDouble(iCustom(symbolName,symbolTimeframe,"::"+INDPATH+""+IndicatorName9+".ex4",hmaPeriodSlow,0,3,false,0,0,1,0),digits);
      double hmaPrevSlow2=NormalizeDouble(iCustom(symbolName,symbolTimeframe,"::"+INDPATH+""+IndicatorName9+".ex4",hmaPeriodSlow,0,3,false,0,0,2,1),digits);
      double hmaPrevSlow1=NormalizeDouble(iCustom(symbolName,symbolTimeframe,"::"+INDPATH+""+IndicatorName9+".ex4",hmaPeriodSlow,0,3,false,0,0,1,1),digits);
      double hmaPrev2Slow1=NormalizeDouble(iCustom(symbolName,symbolTimeframe,"::"+INDPATH+""+IndicatorName9+".ex4",hmaPeriodSlow,0,3,false,0,0,1,2),digits);
      double hmaCurrSlow3=NormalizeDouble(iCustom(symbolName,symbolTimeframe,"::"+INDPATH+""+IndicatorName9+".ex4",hmaPeriodSlow,0,3,false,0,0,3,0),digits);
      double hmaPrevSlow4=NormalizeDouble(iCustom(symbolName,symbolTimeframe,"::"+INDPATH+""+IndicatorName9+".ex4",hmaPeriodSlow,0,3,false,0,0,4,1),digits);
      double hmaPrevSlow3=NormalizeDouble(iCustom(symbolName,symbolTimeframe,"::"+INDPATH+""+IndicatorName9+".ex4",hmaPeriodSlow,0,3,false,0,0,3,1),digits);
      double hmaPrev2Slow3=NormalizeDouble(iCustom(symbolName,symbolTimeframe,"::"+INDPATH+""+IndicatorName9+".ex4",hmaPeriodSlow,0,3,false,0,0,3,2),digits);

      double eMACurr=NormalizeDouble(iMA(symbolName,symbolTimeframe,EMA_period,0,MODE_EMA,PRICE_CLOSE,0),digits);
      double eMAPrev=NormalizeDouble(iMA(symbolName,symbolTimeframe,EMA_period,0,MODE_EMA,PRICE_CLOSE,1),digits);

      double openPrice=NormalizeDouble(iOpen(symbolName,symbolTimeframe,1),digits);
      double closePrice=NormalizeDouble(iClose(symbolName,symbolTimeframe,1),digits);

      //if(UseSimpleEMA_HMACroosing) 
      // {
      if(adxLineCurr>20.0)
        {
         if(adxDPlus>20.0 && adxDPlus>adxDMinus && ((hmaCurrSlow1!=EMPTY_VALUE && currAsk>hmaCurrSlow1) || (hmaCurrSlow3!=EMPTY_VALUE && currAsk>hmaCurrSlow3))
            && ((hmaCurrSlow1!=EMPTY_VALUE && eMACurr>hmaCurrSlow1) || (hmaCurrSlow3!=EMPTY_VALUE && eMACurr>hmaCurrSlow3)))
           {
            if(((hmaCurrSlow3!=EMPTY_VALUE && eMAPrev<hmaPrevSlow3) || (hmaCurrSlow1!=EMPTY_VALUE && eMAPrev<hmaPrevSlow1))
               && ((closePrice-openPrice)>MarketInfo(symbolName,MODE_POINT)*12))
              {
               if(!SendOnlyNotificationsNoTrades) {BuyFlag=true;BuyOpened=true;}
               createNotifications(symbolName,"BUY",symbolTimeframe,additionalText,strategyName);
              }
           }

         //if(adxDMinus>20.0 && adxDPlus<adxDMinus
         //&& 
         if(adxDPlus<adxDMinus && ((hmaCurrSlow1!=EMPTY_VALUE && currBid<hmaCurrSlow1) || (hmaCurrSlow3!=EMPTY_VALUE && currBid<hmaCurrSlow3))
            && ((hmaCurrSlow1!=EMPTY_VALUE && eMACurr<hmaCurrSlow1) || (hmaCurrSlow3!=EMPTY_VALUE && eMACurr<hmaCurrSlow3)))
           {
            if(((hmaCurrSlow3!=EMPTY_VALUE && eMAPrev>hmaPrevSlow3) || (hmaCurrSlow1!=EMPTY_VALUE && eMAPrev>hmaPrevSlow1))
               && ((openPrice-closePrice)>MarketInfo(symbolName,MODE_POINT)*12))
              {
               if(!SendOnlyNotificationsNoTrades) {SellFlag=true;SellOpened=true;}
               createNotifications(symbolName,"SELL",symbolTimeframe,additionalText,strategyName);
              }
           }
         // }
        }

/*Print("hmaCurrSlow1="+hmaCurrSlow1);
      Print("hmaCurrSlow3="+hmaCurrSlow3);
      Print("hmaPrevSlow3="+hmaPrevSlow3);
      Print("hmaPrev2Slow3="+hmaPrev2Slow3);
      Print("hmaPrevSlow4="+hmaPrevSlow4);
      Print("hmaPrevSlow2="+hmaPrevSlow2);*/

/* if(adxLineCurr>25.0)
        {
         if(adxDPlus>20.0 && ((currAsk>hmaCurrSlow1) || (currAsk>hmaCurrSlow3)))
           {
            if(//(adxDPlus>adxDMinus || adxDPlusPrev<adxDMinusPrev) 
               /*&&*//*((hmaCurrSlow1!=EMPTY_VALUE && (eMACurr>hmaCurrSlow1)) || (hmaCurrSlow3!=EMPTY_VALUE && (eMACurr>hmaCurrSlow3))))
              {
               if(!SendOnlyNotificationsNoTrades) {BuyFlag=true;BuyOpened=true;}
               createNotifications(symbolName,"BUY",symbolTimeframe,additionalText,strategyName);
              }
           }
        }
      //closing conditions
      // || (adxDPlus<adxDMinus && adxDPlusPrev>adxDMinusPrev)
      if((((hmaCurrSlow1!=EMPTY_VALUE && currBid<hmaCurrSlow1) || (hmaCurrSlow3!=EMPTY_VALUE && currBid<hmaCurrSlow3))
         ||(((hmaCurrSlow1!=EMPTY_VALUE && (eMACurr<hmaCurrSlow1)) || (hmaCurrSlow3!=EMPTY_VALUE && (eMACurr<hmaCurrSlow3)))
         && ((hmaPrevSlow1!=EMPTY_VALUE && (eMACurr>hmaPrevSlow1)) || (hmaPrevSlow3!=EMPTY_VALUE && (eMACurr>hmaPrevSlow3)))))
         && BuyOpened && IsNewBar())
        {
         //CloseSellTrade=true;
         //BuyOpened=false;
        }
      if(adxLineCurr>25.0)
        {
         if(adxDMinus>20.0 && ((currBid<hmaCurrSlow1) || (currBid<hmaCurrSlow3)))
           {
            if(//(adxDPlus>adxDMinus || adxDPlusPrev<adxDMinusPrev) 
               /*&&*//*((hmaCurrSlow1!=EMPTY_VALUE && (eMACurr<hmaCurrSlow1)) || (hmaCurrSlow3!=EMPTY_VALUE && (eMACurr<hmaCurrSlow3))))
              {
               if(!SendOnlyNotificationsNoTrades) {SellFlag=true;SellOpened=true;}
               createNotifications(symbolName,"SELL",symbolTimeframe,additionalText,strategyName);
              }
           }
        }
*/
      //closing conditions
      //  || (adxDPlus>adxDMinus && adxDPlusPrev<adxDMinusPrev)
      if((((hmaCurrSlow1!=EMPTY_VALUE && currAsk>hmaCurrSlow1) || (hmaCurrSlow3!=EMPTY_VALUE && currAsk>hmaCurrSlow3))

         ||(((hmaCurrSlow1!=EMPTY_VALUE && (eMACurr>hmaCurrSlow1)) || (hmaCurrSlow3!=EMPTY_VALUE && (eMACurr>hmaCurrSlow3)))
         && ((hmaPrevSlow1!=EMPTY_VALUE && (eMACurr<hmaPrevSlow1)) || (hmaPrevSlow3!=EMPTY_VALUE && (eMACurr<hmaPrevSlow3)))))
         && SellOpened && IsNewBar())
        {
         //CloseBuyTrade=true;
         //SellOpened=false;
        }

/*  if(hmaCurrSlow1!=EMPTY_VALUE && (hmaPrevSlow1==EMPTY_VALUE || hmaPrev2Slow1==EMPTY_VALUE))
        {
         if(!SendOnlyNotificationsNoTrades) {BuyFlag=true;}
         createNotifications(symbolName,"BUY",symbolTimeframe,additionalText,strategyName);
        }
      if(hmaCurrSlow3!=EMPTY_VALUE && (hmaCurrSlow1==EMPTY_VALUE && (hmaPrevSlow3==EMPTY_VALUE || hmaPrev2Slow3==EMPTY_VALUE)))
        {
         if(!SendOnlyNotificationsNoTrades) {SellFlag=true;}
         createNotifications(symbolName,"SELL",symbolTimeframe,additionalText,strategyName);
        } */
/* 
      if(adxDPlus>adxDMinus && hmaCurrSlow1!=EMPTY_VALUE && hmaCurrFast1>hmaCurrSlow1 && (hmaCurrFast1!=EMPTY_VALUE && hmaCurrSlow1<hmaCurrFast1)
         &&((hmaCurrFast1!=EMPTY_VALUE && (hmaPrevFast1==EMPTY_VALUE || hmaPrev2Fast1==EMPTY_VALUE)
         || ((hmaPrevSlow1==EMPTY_VALUE || hmaPrev2Slow1==EMPTY_VALUE) && hmaCurrSlow1!=EMPTY_VALUE && hmaCurrFast1!=EMPTY_VALUE))))
        {
         Print("BUY:hmaCurrSlow1="+hmaCurrSlow1);
         Print("BUY:hmaCurrFast1="+hmaCurrFast1);
         Print("BUY:hmaCurrSlow3="+hmaCurrSlow3);
         Print("BUY:hmaCurrFast3="+hmaCurrFast3);
         if(!SendOnlyNotificationsNoTrades) {BuyFlag=true;}
         createNotifications(symbolName,"BUY",symbolTimeframe,additionalText,strategyName);
        }
      if(adxDPlus<adxDMinus && hmaCurrSlow3!=EMPTY_VALUE && hmaCurrFast3<hmaCurrSlow3 && (hmaCurrFast3!=EMPTY_VALUE && hmaCurrSlow1>hmaCurrFast3)
         &&((hmaCurrFast3!=EMPTY_VALUE && (hmaPrevFast3==EMPTY_VALUE || hmaPrev2Fast3==EMPTY_VALUE)
         || ((hmaPrevSlow3==EMPTY_VALUE || hmaPrev2Slow3==EMPTY_VALUE) && hmaCurrSlow3!=EMPTY_VALUE && hmaCurrFast3!=EMPTY_VALUE))))
        {
         Print("SELL:hmaCurrSlow1="+hmaCurrSlow1);
         Print("SELL:hmaCurrFast1="+hmaCurrFast1);
         Print("SELL:hmaCurrSlow3="+hmaCurrSlow3);
         Print("SELL:hmaCurrFast3="+hmaCurrFast3);
         if(!SendOnlyNotificationsNoTrades) {SellFlag=true;}
         createNotifications(symbolName,"SELL",symbolTimeframe,additionalText,strategyName);
        }
        */
     }
   if(strategyName=="smoothed")
     {
      int EMA_period=6;
      double adxDPlus,adxDMinus,adxLineCurr;
      bool adxLine,adxPlusMinus,adxMinusPlus;
      double smoothed2 = NormalizeDouble(iCustom(symbolName,symbolTimeframe,"::"+INDPATH+""+IndicatorName7+".ex4",2,0),digits);
      double smoothed3 = NormalizeDouble(iCustom(symbolName,symbolTimeframe,"::"+INDPATH+""+IndicatorName7+".ex4",3,0),digits);
      double smoothed3Prev=NormalizeDouble(iCustom(symbolName,symbolTimeframe,"::"+INDPATH+""+IndicatorName7+".ex4",3,1),digits);
      double eMACurr=NormalizeDouble(iMA(symbolName,symbolTimeframe,EMA_period,0,MODE_SMA,PRICE_CLOSE,0),digits);
      double eMAPrev=NormalizeDouble(iMA(symbolName,symbolTimeframe,EMA_period,0,MODE_SMA,PRICE_CLOSE,1),digits);
      if(SmoothedWithADX)
        {
         adxLineCurr=NormalizeDouble(iADX(symbolName,symbolTimeframe,ADX50PlusPeriod,0,MODE_MAIN,0),digits);
         adxDPlus=NormalizeDouble(iADX(symbolName,symbolTimeframe,ADX50PlusPeriod,0,MODE_PLUSDI,0),digits);
         adxDMinus=NormalizeDouble(iADX(symbolName,symbolTimeframe,ADX50PlusPeriod,0,MODE_MINUSDI,0),digits);
         adxLine=adxLineCurr>20.0;
         adxPlusMinus=adxDPlus>adxDMinus;
         adxMinusPlus=adxDPlus<adxDMinus;
           } else {
         adxLine=true;
         adxPlusMinus=true;
         adxMinusPlus=true;
        }
      if(adxLine)
        {
         if(adxPlusMinus && smoothed3<eMACurr && smoothed3Prev>eMAPrev)
           {
            if(!SendOnlyNotificationsNoTrades) {BuyFlag=true;BuyOpened=true;}
            createNotifications(symbolName,"BUY",symbolTimeframe,additionalText,strategyName);
           }
         if(adxMinusPlus && smoothed3>eMACurr && smoothed3Prev<eMAPrev)
           {
            if(!SendOnlyNotificationsNoTrades) {SellFlag=true;SellOpened=true;}
            createNotifications(symbolName,"SELL",symbolTimeframe,additionalText,strategyName);
           }
        }
     }
   if(strategyName=="simpleMAs")
     {
      int MA_period1=6,MA_period2=12;
      double eMACurr1=NormalizeDouble(iMA(symbolName,symbolTimeframe,MA_period1,0,MODE_EMA,PRICE_CLOSE,0),digits);
      double eMAPrev1=NormalizeDouble(iMA(symbolName,symbolTimeframe,MA_period1,0,MODE_EMA,PRICE_CLOSE,1),digits);
      double eMACurr2=NormalizeDouble(iMA(symbolName,symbolTimeframe,MA_period2,0,MODE_EMA,PRICE_TYPICAL,0),digits);
      double eMAPrev2=NormalizeDouble(iMA(symbolName,symbolTimeframe,MA_period2,0,MODE_EMA,PRICE_TYPICAL,1),digits);

      if(UseCCIAverageFiltering)
        {
         double averageCCI=NormalizeDouble(iCustom(symbolName,symbolTimeframe,"::"+INDPATH+""+IndicatorName10+".ex4",24,32,49,5,2,0,0),digits);
         double averageCCIPrev=NormalizeDouble(iCustom(symbolName,symbolTimeframe,"::"+INDPATH+""+IndicatorName10+".ex4",24,32,49,5,2,0,1),digits);
         if(eMACurr1>eMACurr2 && eMAPrev1<eMAPrev2 && averageCCI<0.0)
           {
            if(!SendOnlyNotificationsNoTrades) {BuyFlag=true;}
            createNotifications(symbolName,"BUY",symbolTimeframe,additionalText,strategyName);
           }
         if(eMACurr1<eMACurr2 && eMAPrev1>eMAPrev2 && averageCCIPrev>0.0)
           {
            if(!SendOnlyNotificationsNoTrades) {SellFlag=true;}
            createNotifications(symbolName,"SELL",symbolTimeframe,additionalText,strategyName);
           }
           }else{
         if(eMACurr1>eMACurr2 && eMAPrev1<eMAPrev2)
           {
            if(!SendOnlyNotificationsNoTrades) {BuyFlag=true;BuyOpened=true;}
            createNotifications(symbolName,"BUY",symbolTimeframe,additionalText,strategyName);
           }
         if(eMACurr1<eMACurr2 && eMAPrev1>eMAPrev2)
           {
            if(!SendOnlyNotificationsNoTrades) {SellFlag=true;SellOpened=true;}
            createNotifications(symbolName,"SELL",symbolTimeframe,additionalText,strategyName);
           }
        }
     }
   if(strategyName=="cciaverage")
     {
      double averageCCI=NormalizeDouble(iCustom(symbolName,symbolTimeframe,"::"+INDPATH+""+IndicatorName10+".ex4",24,32,49,5,2,0,0),digits);
      double averageCCIPrev=NormalizeDouble(iCustom(symbolName,symbolTimeframe,"::"+INDPATH+""+IndicatorName10+".ex4",24,32,49,5,2,0,1),digits);
      double averageCCIPrev2=NormalizeDouble(iCustom(symbolName,symbolTimeframe,"::"+INDPATH+""+IndicatorName10+".ex4",24,32,49,5,2,0,2),digits);
      if(NormalizeDouble(averageCCIPrev,digits)<NormalizeDouble(-CCISignalValue,digits) && NormalizeDouble(averageCCI,digits)>NormalizeDouble(-CCISignalValue,digits))
        {
         if(!SendOnlyNotificationsNoTrades) {BuyFlag=true;}
         createNotifications(symbolName,"BUY",symbolTimeframe,additionalText,strategyName);
        }

      if(NormalizeDouble(averageCCIPrev,digits)>NormalizeDouble(CCISignalValue,digits) && NormalizeDouble(averageCCI,digits)<NormalizeDouble(CCISignalValue,digits))
        {
         if(!SendOnlyNotificationsNoTrades) {SellFlag=true;}
         createNotifications(symbolName,"SELL",symbolTimeframe,additionalText,strategyName);
        }
     }
   if(strategyName=="adx50")
     {
      double adxDPlus=NormalizeDouble(iADX(symbolName,symbolTimeframe,ADX50PlusPeriod,5,MODE_PLUSDI,0),digits);
      double adxDMinus=NormalizeDouble(iADX(symbolName,symbolTimeframe,ADX50PlusPeriod,5,MODE_MINUSDI,0),digits);
      double adxDPlusPrev=NormalizeDouble(iADX(symbolName,symbolTimeframe,ADX50PlusPeriod,5,MODE_PLUSDI,1),digits);
      double adxDMinusPrev=NormalizeDouble(iADX(symbolName,symbolTimeframe,ADX50PlusPeriod,5,MODE_MINUSDI,1),digits);
      double adxDPlusPrev2=NormalizeDouble(iADX(symbolName,symbolTimeframe,ADX50PlusPeriod,5,MODE_PLUSDI,2),digits);
      double adxDMinusPrev2=NormalizeDouble(iADX(symbolName,symbolTimeframe,ADX50PlusPeriod,5,MODE_MINUSDI,2),digits);
      if(adxDPlus>adxDMinus && (adxDPlusPrev<adxDMinusPrev || adxDPlusPrev2<adxDMinusPrev2))
        {
         if(!SendOnlyNotificationsNoTrades) {BuyFlag=true;}
         createNotifications(symbolName,"BUY",symbolTimeframe,additionalText,strategyName);
        }
      if(adxDPlus<adxDMinus && (adxDPlusPrev>adxDMinusPrev || adxDPlusPrev2>adxDMinusPrev2))
        {
         if(!SendOnlyNotificationsNoTrades) {SellFlag=true;}
         createNotifications(symbolName,"SELL",symbolTimeframe,additionalText,strategyName);
        }
     }
   if(strategyName=="magicTrend")
     {
      double lastValueLow=NormalizeDouble(iCustom(symbolName,symbolTimeframe,"::"+INDPATH+""+IndicatorName8+".ex4",1,0), digits);
      double prevValueLow=NormalizeDouble(iCustom(symbolName,symbolTimeframe,"::"+INDPATH+""+IndicatorName8+".ex4",1,1), digits);
      double lastValueHigh=NormalizeDouble(iCustom(symbolName,symbolTimeframe,"::"+INDPATH+""+IndicatorName8+".ex4",0,0), digits);
      double prevValueHigh=NormalizeDouble(iCustom(symbolName,symbolTimeframe,"::"+INDPATH+""+IndicatorName8+".ex4",0,1), digits);
      if(lastValueLow>prevValueLow)
        {
         if(!SendOnlyNotificationsNoTrades) {BuyFlag=true;}
         createNotifications(symbolName,"BUY",symbolTimeframe,additionalText,strategyName);
        }
      else if(lastValueHigh<prevValueHigh)
        {
         if(!SendOnlyNotificationsNoTrades) {SellFlag=true;}
         createNotifications(symbolName,"SELL",symbolTimeframe,additionalText,strategyName);
        }
     }
   if(strategyName=="nightAsianBlock")
     {
      // block time period from 23:00 till 02:00 (close of M15 candle)
      if(TimeHour(TimeCurrent())==2 && TimeMinute(TimeCurrent())==15)
        {
         int i=CandleCountInBlock+1;
         double priceMax=-1000000;
         double priceMin=1000000;
         double priceHigh=0;
         double priceLow=0;
         while(i>=1)
           {
            priceHigh=NormalizeDouble(High[i],digits);
            priceLow=NormalizeDouble(Low[i],digits);
            if(priceMax<priceHigh) priceMax=priceHigh;
            if(priceMin>priceLow) priceMin=priceLow;
            i--;
           }
         //--- get minimum stop level 
         double minstoplevel=MarketInfo(symbolName,MODE_STOPLEVEL);
         double priceBuy=priceMax+GapFromBlock*Point;
         double priceSell=priceMin-GapFromBlock*Point;
         //--- calculated SL and TP prices must be normalized 
         double stoplossBuy=NormalizeDouble(priceMin-((GapFromBlock+minstoplevel)*MarketInfo(symbolName,MODE_POINT)),digits);
         double takeprofitBuy=NormalizeDouble(priceBuy+((GapFromBlock+minstoplevel+TP)*MarketInfo(symbolName,MODE_POINT)),digits);
         double stoplossSell=NormalizeDouble(priceMax+((GapFromBlock+minstoplevel)*MarketInfo(symbolName,MODE_POINT)),digits);
         double takeprofitSell=NormalizeDouble(priceSell-((GapFromBlock+minstoplevel+TP)*MarketInfo(symbolName,MODE_POINT)),digits);
         if((priceBuy-priceSell)<MaxBlockSizeInPoints*Point && !SendOnlyNotificationsNoTrades)
           {
            bool pendingBuyCheck=OrderSend(symbolName,OP_BUYSTOP,getTradeDoubleValue(0,6),priceBuy,3,0,takeprofitBuy,"Area51Night",MagicNumber,TimeCurrent()+75600,clrGreen);
            bool pendingSellCheck=OrderSend(symbolName,OP_SELLSTOP,getTradeDoubleValue(0,6),priceSell,3,0,takeprofitSell,"Area51Night",MagicNumber,TimeCurrent()+75600,clrRed);
           }
        }
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(strategyName=="stochCroosingRSI")
     {
      int i=0,KPeriod2=21,DPeriod2=7,Slowing2=7,MAMethod2=MODE_SMA,PriceField2=0;
      double stochastic1now,stochastic1previous;
      stochastic1now=iStochastic(symbolName,symbolTimeframe,KPeriod2,DPeriod2,Slowing1,MAMethod2,PriceField2,0,i);
      stochastic1previous=iStochastic(symbolName,symbolTimeframe,KPeriod2,DPeriod2,Slowing1,MAMethod2,PriceField2,0,i+1);

      if((MathRound(iRSI(symbolName,symbolTimeframe,45,PRICE_CLOSE,i))<MathRound(stochastic1now))
         && (MathRound(iRSI(symbolName,symbolTimeframe,45,PRICE_CLOSE,i))>MathRound(stochastic1previous)))
        {
         if(!SendOnlyNotificationsNoTrades) {BuyFlag=true;}
         createNotifications(symbolName,"BUY",symbolTimeframe,additionalText,strategyName);
        }
      if((MathRound(iRSI(symbolName,symbolTimeframe,45,PRICE_CLOSE,i))>MathRound(stochastic1now))
         && (MathRound(iRSI(symbolName,symbolTimeframe,45,PRICE_CLOSE,i))<MathRound(stochastic1previous)))
        {
         if(!SendOnlyNotificationsNoTrades) {SellFlag=true;}
         createNotifications(symbolName,"SELL",symbolTimeframe,additionalText,strategyName);
        }
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(strategyName=="MaOn5050")
     {
      int buff=150;
      int i=0;
      double RSIBuffer[];
      double MAofRSIBuffer[];
      ArrayResize(RSIBuffer,buff);
      ArrayResize(MAofRSIBuffer,buff);
      for(int j=0; j<buff; j++)
        {
         RSIBuffer[j]=iRSI(symbolName,0,45,PRICE_CLOSE,i);
         MAofRSIBuffer[j]=iMAOnArray(RSIBuffer,0,21,0,0,j);
        }

      if(RSIBuffer[i+1]>MAofRSIBuffer[i+1] && MathRound(RSIBuffer[i+1])==MathRound(MAofRSIBuffer[i+1]))
        {
         if(!SendOnlyNotificationsNoTrades) {SellFlag=true;}
         createNotifications(symbolName,"SELL",symbolTimeframe,additionalText,strategyName);
        }
      if(RSIBuffer[i+1]<MAofRSIBuffer[i+1] && MathRound(RSIBuffer[i+1])==MathRound(MAofRSIBuffer[i+1]))
        {
         if(!SendOnlyNotificationsNoTrades) {BuyFlag=true;}
         createNotifications(symbolName,"BUY",symbolTimeframe,additionalText,strategyName);
        }
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(strategyName=="5050")
     {
      int i=0;
      if((MathRound(iRSI(symbolName,symbolTimeframe,45,PRICE_CLOSE,i))>50) && (MathRound(iRSI(symbolName,symbolTimeframe,45,PRICE_CLOSE,i))<52)
         && ((MathRound(iRSI(symbolName,symbolTimeframe,45,PRICE_CLOSE,i+1))==50) || (MathRound(iRSI(symbolName,symbolTimeframe,45,PRICE_CLOSE,i+1))==49))
         && (iMA(symbolName,symbolTimeframe,34,8,MODE_SMA,PRICE_CLOSE,0)<MarketInfo(symbolName,MODE_ASK)))
        {
         if(!SendOnlyNotificationsNoTrades) {BuyFlag=true;}
         createNotifications(symbolName,"BUY",symbolTimeframe,additionalText,strategyName);
        }
      if((MathRound(iRSI(symbolName,symbolTimeframe,45,PRICE_CLOSE,i))<50) && (MathRound(iRSI(symbolName,symbolTimeframe,45,PRICE_CLOSE,i))>48)
         && ((MathRound(iRSI(symbolName,symbolTimeframe,45,PRICE_CLOSE,i+1))==50) || (MathRound(iRSI(symbolName,symbolTimeframe,45,PRICE_CLOSE,i+1))==49))
         && (iMA(symbolName,symbolTimeframe,34,8,MODE_SMA,PRICE_CLOSE,0)>MarketInfo(symbolName,MODE_BID)))
        {
         if(!SendOnlyNotificationsNoTrades) {SellFlag=true;}
         createNotifications(symbolName,"SELL",symbolTimeframe,additionalText,strategyName);
        }
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(strategyName=="baseStochi")
     {
      for(int i=0; i<=2; i++)
        {
         double stochastic1now,stochastic2now,stochastic1previous,stochastic2previous,stochastic1after,stochastic2after;
         stochastic1now=iStochastic(symbolName,symbolTimeframe,KPeriod1,DPeriod1,Slowing1,MAMethod1,PriceField1,0,i);
         stochastic1previous=iStochastic(symbolName,symbolTimeframe,KPeriod1,DPeriod1,Slowing1,MAMethod1,PriceField1,0,i+1);
         stochastic1after=iStochastic(symbolName,symbolTimeframe,KPeriod1,DPeriod1,Slowing1,MAMethod1,PriceField1,0,i-1);
         stochastic2now=iStochastic(symbolName,symbolTimeframe,KPeriod1,DPeriod1,Slowing1,MAMethod1,PriceField1,1,i);
         stochastic2previous=iStochastic(symbolName,symbolTimeframe,KPeriod1,DPeriod1,Slowing1,MAMethod1,PriceField1,1,i+1);
         stochastic2after=iStochastic(symbolName,symbolTimeframe,KPeriod1,DPeriod1,Slowing1,MAMethod1,PriceField1,1,i-1);

         if((stochastic1now>stochastic2now) && (stochastic1previous<stochastic2previous) && (stochastic1after>stochastic2after)
            && ((stochastic1now-stochastic2now)>0.5) && (stochastic1now<70.0))
           {
            if(NewBar())
              {
               if(!SendOnlyNotificationsNoTrades) {BuyFlag=true;}
               createNotifications(symbolName,"BUY",symbolTimeframe,additionalText,strategyName);
              }
           }
         if((stochastic1now<stochastic2now) && (stochastic1previous>stochastic2previous) && (stochastic1after<stochastic2after)
            && ((stochastic2now-stochastic1now)>0.5) && (stochastic1now>30.0))
           {
            if(NewBar())
              {
               if(!SendOnlyNotificationsNoTrades) {SellFlag=true;}
               createNotifications(symbolName,"SELL",symbolTimeframe,additionalText,strategyName);
              }
           }
        }
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(strategyName=="simpleTrend")
     {
      double MAFastPrevious1,MAFastPrevious2;
      double MASlowPrevious1,MASlowPrevious2;
      MAFastPrevious1=NormalizeDouble(iMA(symbolName,symbolTimeframe,MAFastPeriod,0,MODE_EMA,PRICE_CLOSE,1),digits);
      MAFastPrevious2=NormalizeDouble(iMA(symbolName,symbolTimeframe,MAFastPeriod,0,MODE_EMA,PRICE_CLOSE,2),digits);
      MASlowPrevious1=NormalizeDouble(iMA(symbolName,symbolTimeframe,MASlowPeriod,0,MODE_EMA,PRICE_CLOSE,1),digits);
      MASlowPrevious2=NormalizeDouble(iMA(symbolName,symbolTimeframe,MASlowPeriod,0,MODE_EMA,PRICE_CLOSE,2),digits);

      //fast MA > slow MA.
      if(MAFastPrevious1>MASlowPrevious1)
        {
         //BuyFlag = true;
         //fast MA crosses over slow MA.
         if(MAFastPrevious2<MASlowPrevious2)
           {
            if(iMACD(symbolName,symbolTimeframe,12,26,9,PRICE_CLOSE,MODE_MAIN,1)>0 && 
               iADX(symbolName,symbolTimeframe,14,PRICE_CLOSE,MODE_MAIN,1)>20 && iADX(symbolName,symbolTimeframe,14,PRICE_CLOSE,MODE_MAIN,1)<33)
              {
               if(!SendOnlyNotificationsNoTrades) {BuyFlag=true;}
               createNotifications(symbolName,"BUY",symbolTimeframe,additionalText,strategyName);

              }
           }
        }
      //fast MA < slow MA.
      else if(MAFastPrevious1<MASlowPrevious1)
        {
         //SellFlag = true;
         //fast MA crosses below slow MA.
         if(MAFastPrevious2>MASlowPrevious2)
           {
            if(iMACD(symbolName,symbolTimeframe,12,26,9,PRICE_CLOSE,MODE_MAIN,1)<0 && 
               iADX(symbolName,symbolTimeframe,14,PRICE_CLOSE,MODE_MAIN,1)>20 && iADX(symbolName,symbolTimeframe,14,PRICE_CLOSE,MODE_MAIN,1)<33)
              {
               if(!SendOnlyNotificationsNoTrades) {SellFlag=true;}
               createNotifications(symbolName,"SELL",symbolTimeframe,additionalText,strategyName);
              }
           }
        }
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(strategyName=="trendy")
     {
      double Trend=NormalizeDouble(iCustom(symbolName,symbolTimeframe,"::"+INDPATH+""+IndicatorName2+".ex4",7575,Smoothing,0,0),1);
      double TrendBack=NormalizeDouble(iCustom(symbolName,symbolTimeframe,"::"+INDPATH+""+IndicatorName2+".ex4",7575,Smoothing,0,1),1);
      double TrendBack2=NormalizeDouble(iCustom(symbolName,symbolTimeframe,"::"+INDPATH+""+IndicatorName2+".ex4",7575,Smoothing,0,2),1);
      double MA=NormalizeDouble(iCustom(symbolName,symbolTimeframe,"::"+INDPATH+""+IndicatorName2+".ex4",7575,Smoothing,1,0),1);
      double MABack=NormalizeDouble(iCustom(symbolName,symbolTimeframe,"::"+INDPATH+""+IndicatorName2+".ex4",7575,Smoothing,1,1),1);
      double MABack2=NormalizeDouble(iCustom(symbolName,symbolTimeframe,"::"+INDPATH+""+IndicatorName2+".ex4",7575,Smoothing,1,2),1);
      double MA_Second=NormalizeDouble(iCustom(symbolName,symbolTimeframe,"::"+INDPATH+""+IndicatorName2+".ex4",7575,Smoothing,2,0),1);
      double MABack_Second=NormalizeDouble(iCustom(symbolName,symbolTimeframe,"::"+INDPATH+""+IndicatorName2+".ex4",7575,Smoothing,2,1),1);
      double MABack2_Second=NormalizeDouble(iCustom(symbolName,symbolTimeframe,"::"+INDPATH+""+IndicatorName2+".ex4",7575,Smoothing,2,2),1);

      if(Debug)
        {
         Print("Trend="+DoubleToStr(Trend));
         Print("TrendBack="+DoubleToStr(TrendBack));
         Print("TrendBack2="+DoubleToStr(TrendBack2));
         Print("MA="+DoubleToStr(MA));
         Print("MABack="+DoubleToStr(MABack));
         Print("MABack2="+DoubleToStr(MABack2));
         Print("MA_Second="+DoubleToStr(MA_Second));
         Print("MABack_Second="+DoubleToStr(MABack_Second));
         Print("MABack2_Second="+DoubleToStr(MABack2_Second));
        }
      if(!UseSMAOnTrendIndicator)
        {
         if(((Trend<TrendBack || CompareDoubles(Trend,TrendBack)) && ((Trend<26) && (TrendBack>=23)) && (TrendBack2>=26)))
           {
            if(Debug)
              {
               Print("SellSignal!");
               Print("Trend="+DoubleToStr(Trend));
               Print("TrendBack="+DoubleToStr(TrendBack));
              }
            if(!SendOnlyNotificationsNoTrades) {SellFlag=true;}
            createNotifications(symbolName,"SELL",symbolTimeframe,additionalText,strategyName);
           }
         if(((Trend>TrendBack || CompareDoubles(Trend,TrendBack)) && (Trend>4) && (TrendBack<=8) && (TrendBack2<=5)))
           {
            if(Debug)
              {
               Print("BuySignal!");
               Print("Trend="+DoubleToStr(Trend));
               Print("TrendBack="+DoubleToStr(TrendBack));
              }
            if(!SendOnlyNotificationsNoTrades) {BuyFlag=true;}
            createNotifications(symbolName,"BUY",symbolTimeframe,additionalText,strategyName);

           }
        }
      if(UseSMAOnTrendIndicator && (UseOneOrTwoSMAOnTrendIndicator==1 || UseOneOrTwoSMAOnTrendIndicator==2))
        {
         if(((MathRound(MA)>MathRound(Trend)) || ((MA-0.5)==Trend))
            && (((MA-Trend)>1) || ((MA-Trend)==1)) && (Trend<14.5 || Trend>16.5)
            && ((MathRound(MABack)<MathRound(TrendBack)) || (MathRound(MABack)==MathRound(TrendBack)))
            && (MathRound(MABack2)<MathRound(TrendBack2)))
           {
            if(Debug)
              {
               Print("SELL=>MA="+DoubleToStr(MathRound(MA))+">Trend="+DoubleToStr(MathRound(Trend))
                     +"&&MABack="+DoubleToStr(MathRound(MABack))+"<=TrendBack="+DoubleToStr(MathRound(TrendBack))
                     +"&&MaBack2="+DoubleToStr(MathRound(MABack2))+"<=TrendBack2="+DoubleToStr(MathRound(TrendBack2)));
              }
            if(!SendOnlyNotificationsNoTrades) {SellFlag=true;}
            createNotifications(symbolName,"SELL",symbolTimeframe,additionalText,strategyName);

           }
         if(((MathRound(MA)<MathRound(Trend)) || ((MA+0.5)==Trend))
            && (((Trend-MA)>1) || ((Trend-MA)==1)) && (Trend<14.5 || Trend>16.5) && (Trend>4)
            && ((MathRound(MABack)>MathRound(TrendBack)) || (MathRound(MABack)==MathRound(TrendBack)))
            && (MathRound(MABack2)>MathRound(TrendBack2)))
           {
            if(Debug)
              {
               Print("BUY=>MA="+DoubleToStr(MathRound(MA))+"<Trend="+DoubleToStr(MathRound(Trend))
                     +"&&MABack="+DoubleToStr(MathRound(MABack))+"=>TrendBack="+DoubleToStr(MathRound(TrendBack))
                     +"&&MaBack2="+DoubleToStr(MathRound(MABack2))+"=>TrendBack2="+DoubleToStr(MathRound(TrendBack2)));
              }
            if(!SendOnlyNotificationsNoTrades) {BuyFlag=true;}
            createNotifications(symbolName,"BUY",symbolTimeframe,additionalText,strategyName);

           }
        }

      if(UseSMAOnTrendIndicator && (UseOneOrTwoSMAOnTrendIndicator==2 || UseOneOrTwoSMAOnTrendIndicator==3))
        {
         //using ma50
         if(((MathRound(MA_Second)>MathRound(Trend)) || (MathRound(MA_Second-0.5)==Trend))
            && (((MA_Second-Trend)>0.5) || ((MA_Second-Trend)==1)) && (Trend<14.5 || Trend>16.5)
            && ((MathRound(MABack_Second)<MathRound(TrendBack)) || (MathRound(MABack_Second)==MathRound(TrendBack)))
            && (MathRound(MABack2_Second)<MathRound(TrendBack2)))
           {
            if(Debug)
              {
               Print("SELL=>MA_Second="+DoubleToStr(MathRound(MA_Second))+">Trend="+DoubleToStr(MathRound(Trend))
                     +"&&MABack_Second="+DoubleToStr(MathRound(MABack_Second))+"<=TrendBack="+DoubleToStr(MathRound(TrendBack))
                     +"&&MaBack2_Second="+DoubleToStr(MathRound(MABack2_Second))+"<=TrendBack2="+DoubleToStr(MathRound(TrendBack2)));
              }
            if(!SendOnlyNotificationsNoTrades) {SellFlag=true;}
            createNotifications(symbolName,"SELL",symbolTimeframe,additionalText,strategyName);

           }
         if(((MathRound(MA_Second)<MathRound(Trend)) || (MathRound(MA_Second+0.5)==Trend))
            && (((Trend-MA_Second)>0.5) || ((Trend-MA_Second)==1)) && (Trend<14.5 || Trend>16.5)
            && ((MathRound(MABack_Second)>MathRound(TrendBack)) || (MathRound(MABack_Second)==MathRound(TrendBack)))
            && (MathRound(MABack2_Second)>MathRound(TrendBack2)))
           {
            if(Debug)
              {
               Print("BUY=>MA_Second="+DoubleToStr(MathRound(MA_Second))+"<Trend="+DoubleToStr(MathRound(Trend))
                     +"&&MABack_Second="+DoubleToStr(MathRound(MABack_Second))+"=>TrendBack="+DoubleToStr(MathRound(TrendBack))
                     +"&&MaBack2_Second="+DoubleToStr(MathRound(MABack2_Second))+"=>TrendBack2="+DoubleToStr(MathRound(TrendBack2)));
              }
            if(!SendOnlyNotificationsNoTrades) {BuyFlag=true;}
            createNotifications(symbolName,"BUY",symbolTimeframe,additionalText,strategyName);
           }
        }
      if(UseSMAOnTrendIndicator && UseSMAsCrossingOnTrendIndicatorData)
        {
         //using emas
         if(((MathRound(MA_Second)>MathRound(MA)) || (MathRound(MA_Second-0.5)==MA))
            && (((MA_Second-MA)>0.5) || ((MA_Second-MA)==1))
            && ((MathRound(MABack_Second)<MathRound(MABack)) || (MathRound(MABack_Second)==MathRound(MABack2)))
            && (MathRound(MABack2_Second)<MathRound(MABack2)))
           {
            if(Debug)
              {
               Print("SELL=>MA_Second="+DoubleToStr(MathRound(MA_Second))+">MATrend="+DoubleToStr(MathRound(MA))
                     +"&&MABack_Second="+DoubleToStr(MathRound(MABack_Second))+"<=MABack="+DoubleToStr(MathRound(MABack))
                     +"&&MaBack2_Second="+DoubleToStr(MathRound(MABack2_Second))+"<=MABack2="+DoubleToStr(MathRound(MABack2)));
              }
            if(!SendOnlyNotificationsNoTrades) {SellFlag=true;}
            createNotifications(symbolName,"SELL",symbolTimeframe,additionalText,strategyName);
           }
         if(((MathRound(MA_Second)<MathRound(MA)) || (MathRound(MA_Second+0.5)==MA))
            && (((MA-MA_Second)>0.5) || ((MA-MA_Second)==1))
            && ((MathRound(MABack_Second)>MathRound(MABack)) || (MathRound(MABack_Second)==MathRound(MABack)))
            && (MathRound(MABack2_Second)>MathRound(MABack2)))
           {
            if(Debug)
              {
               Print("BUY=>MA_Second="+DoubleToStr(MathRound(MA_Second))+"<MA="+DoubleToStr(MathRound(MA))
                     +"&&MABack_Second="+DoubleToStr(MathRound(MABack_Second))+"=>MABack="+DoubleToStr(MathRound(MABack))
                     +"&&MaBack2_Second="+DoubleToStr(MathRound(MABack2_Second))+"=>MABack2="+DoubleToStr(MathRound(MABack2)));
              }
            if(!SendOnlyNotificationsNoTrades) {BuyFlag=true;}
            createNotifications(symbolName,"BUY",symbolTimeframe,additionalText,strategyName);
           }
        }
      if((SellFlag || BuyFlag) && Debug) {Print("Got signal from trend-based indicator!");}
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(strategyName=="tdi")
     {
      int i=0;
      double TDIGreen=iCustom(symbolName,symbolTimeframe,"::"+INDPATH+""+IndicatorName+".ex4",RSI_Period,RSI_Price,Volatility_Band,RSI_Price_Line,RSI_Price_Type,Trade_Signal_Line,Trade_Signal_Line2,Trade_Signal_Type,4,i);
      double TDIGreenPrevious=iCustom(symbolName,symbolTimeframe,"::"+INDPATH+""+IndicatorName+".ex4",RSI_Period,RSI_Price,Volatility_Band,RSI_Price_Line,RSI_Price_Type,Trade_Signal_Line,Trade_Signal_Line2,Trade_Signal_Type,4,i+1);
      double TDIYellow=NormalizeDouble(iCustom(symbolName,symbolTimeframe,"::"+INDPATH+""+IndicatorName+".ex4",RSI_Period,RSI_Price,Volatility_Band,RSI_Price_Line,RSI_Price_Type,Trade_Signal_Line,Trade_Signal_Line2,Trade_Signal_Type,2,i),digits);
      double TDIYellowPrevous=NormalizeDouble(iCustom(symbolName,symbolTimeframe,"::"+INDPATH+""+IndicatorName+".ex4",RSI_Period,RSI_Price,Volatility_Band,RSI_Price_Line,RSI_Price_Type,Trade_Signal_Line,Trade_Signal_Line2,Trade_Signal_Type,2,i+1),digits);
      double TDIRedPrevous=NormalizeDouble(iCustom(Symbol(),0,"::"+INDPATH+""+IndicatorName+".ex4",RSI_Period,RSI_Price,Volatility_Band,RSI_Price_Line,RSI_Price_Type,Trade_Signal_Line,Trade_Signal_Line2,Trade_Signal_Type,5,i+1),digits);
      double TDIRed=NormalizeDouble(iCustom(Symbol(),0,"::"+INDPATH+""+IndicatorName+".ex4",RSI_Period,RSI_Price,Volatility_Band,RSI_Price_Line,RSI_Price_Type,Trade_Signal_Line,Trade_Signal_Line2,Trade_Signal_Type,5,i),digits);
      // double TDIUp=iCustom(Symbol(),0,"::"+INDPATH+""+IndicatorName+".ex4",RSI_Period,RSI_Price,Volatility_Band,RSI_Price_Line,RSI_Price_Type,Trade_Signal_Line,Trade_Signal_Line2,Trade_Signal_Type,1,i);
      // double TDIDown=iCustom(Symbol(),0,"::"+INDPATH+""+IndicatorName+".ex4",RSI_Period,RSI_Price,Volatility_Band,RSI_Price_Line,RSI_Price_Type,Trade_Signal_Line,Trade_Signal_Line2,Trade_Signal_Type,3,i);
      double TSL2=iCustom(symbolName,symbolTimeframe,"::"+INDPATH+""+IndicatorName+".ex4",RSI_Period,RSI_Price,Volatility_Band,RSI_Price_Line,RSI_Price_Type,Trade_Signal_Line,Trade_Signal_Line2,Trade_Signal_Type,6,i);
      double TSL2Previous=iCustom(symbolName,symbolTimeframe,"::"+INDPATH+""+IndicatorName+".ex4",RSI_Period,RSI_Price,Volatility_Band,RSI_Price_Line,RSI_Price_Type,Trade_Signal_Line,Trade_Signal_Line2,Trade_Signal_Type,6,i+1);

      double adxLineCurr=NormalizeDouble(iADX(symbolName,symbolTimeframe,ADX50PlusPeriod,0,MODE_MAIN,i),digits);
      double adxDPlus=NormalizeDouble(iADX(symbolName,symbolTimeframe,ADX50PlusPeriod,0,MODE_PLUSDI,i),digits);
      double adxDMinus=NormalizeDouble(iADX(symbolName,symbolTimeframe,ADX50PlusPeriod,0,MODE_MINUSDI,i),digits);

      double currAsk = NormalizeDouble(MarketInfo(symbolName,MODE_ASK),digits);
      double currBid = NormalizeDouble(MarketInfo(symbolName,MODE_BID),digits);
      double hmaCurr1=NormalizeDouble(iCustom(symbolName,symbolTimeframe,"::"+INDPATH+""+IndicatorName9+".ex4",110,0,3,false,0,0,1,0),digits);
      double hmaCurr3=NormalizeDouble(iCustom(symbolName,symbolTimeframe,"::"+INDPATH+""+IndicatorName9+".ex4",110,0,3,false,0,0,3,0),digits);

      double hmaCurr1Sell=NormalizeDouble(iCustom(symbolName,symbolTimeframe,"::"+INDPATH+""+IndicatorName9+".ex4",110,0,3,false,0,-40,1,0),digits);
      double hmaCurr3Sell=NormalizeDouble(iCustom(symbolName,symbolTimeframe,"::"+INDPATH+""+IndicatorName9+".ex4",110,0,3,false,0,-40,3,0),digits);

      double stochValue=iStochastic(symbolName,symbolTimeframe,18,5,3,MODE_EMA,0,MODE_MAIN,0);

      double openPrice=NormalizeDouble(iOpen(symbolName,symbolTimeframe,1),digits);
      double closePrice=NormalizeDouble(iClose(symbolName,symbolTimeframe,1),digits);

      //if(UseADXWithBaseLine)
      //{

      if(adxLineCurr>20.0)
        {
         if(adxDPlus>adxDMinus && TDIYellow>28 && (TDIRed<45.0 || TDIRed>55.0) && TDIYellow<60 && TDIRed>TDIYellow && ((TDIRed-TDIYellow)>1.0) && TDIRedPrevous<TDIYellowPrevous)
           {
            if((currAsk>hmaCurr1) || (currAsk>hmaCurr3))
              {
               if(!SendOnlyNotificationsNoTrades) {BuyFlag=true;}
               createNotifications(symbolName,"BUY",symbolTimeframe,additionalText,strategyName);
              }
           }
         if(adxDMinus>adxDPlus && TDIYellow<70 && (TDIRed>55.0 || TDIRed<45.0) && TDIYellow>32 && TDIRed<TDIYellow && ((TDIYellow-TDIRed)>1.0) && TDIRedPrevous>TDIYellowPrevous)
           {
            if((currBid<hmaCurr1) || (currBid<hmaCurr3))
              {
               if(!SendOnlyNotificationsNoTrades) {SellFlag=true;}
               createNotifications(symbolName,"SELL",symbolTimeframe,additionalText,strategyName);
              }
           }
         // }
        }

      if(adxLineCurr>20.0)
        {
         if(adxDPlus>adxDMinus && adxDPlus>18.0
            && stochValue<80.0
            && ((openPrice>hmaCurr1 || openPrice>hmaCurr3)
            && (closePrice>hmaCurr1 || closePrice>hmaCurr3)
            && (closePrice-openPrice)>MarketInfo(symbolName,MODE_POINT)*12))
           {
            Print("Buy -> price is higher as HMA");
            if(!SendOnlyNotificationsNoTrades) {BuyFlag=true;}
            createNotifications(symbolName,"BUY",symbolTimeframe,additionalText,strategyName);
           }
         if(adxDMinus>adxDPlus && adxDMinus>18.0
            && stochValue>20.0
            && ((openPrice<hmaCurr1Sell || openPrice<hmaCurr3Sell)
            && (closePrice<hmaCurr1Sell || closePrice<hmaCurr3Sell)
            && (openPrice-closePrice)>MarketInfo(symbolName,MODE_POINT)*12))
           {
            Print("Sell -> price is lower as HMA");
            if(!SendOnlyNotificationsNoTrades) {SellFlag=true;}
            createNotifications(symbolName,"SELL",symbolTimeframe,additionalText,strategyName);
           }
        }

      if(UseCorridorCroosing)
        {
         if((TSL2<TDIYellow) && (TDIGreen>TSL2 && (TDIGreenPrevious<TSL2Previous || TDIGreenPrevious==TSL2Previous))) {BuyFlag=true;}
         if((TSL2>TDIYellow) && (TDIGreen<TSL2 && (TDIGreenPrevious>TSL2Previous || TDIGreenPrevious==TSL2Previous))) {SellFlag=true;}
        }

/*if((UseCorridorCroosing==false))// && (UseADXWithBaseLine=false))
        {
         if((TDIYellow<50) && (TSL2<TDIYellow) && (TDIGreen>TDIYellow && (TDIGreenPrevious<TDIYellowPrevous || TDIGreenPrevious==TDIYellowPrevous))) {BuyFlag=true;}
         if((TDIYellow>50) && (TSL2>TDIYellow) && (TDIGreen<TDIYellow && (TDIGreenPrevious>TDIYellowPrevous || TDIGreenPrevious==TDIYellowPrevous))) {SellFlag=true;}
        }
      */
     }

   string res="noSignal";
   if(SellFlag) {res="Sell";}
   if(BuyFlag) {res="Buy";}
   if(res!="noSignal"){Print("Got signal ("+res+")  from "+strategyName+" on "+symbolName);}
   if(CloseBuyTrade){ClosePreviousSignalTrade(symbolName,0,1);}
   if(CloseSellTrade){ClosePreviousSignalTrade(symbolName,1,0);}
// HideTestIndicators(true); //<- reactivate before publish!
   return res;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
/*bool PositionCanBeOpened()
  {
   bool positionCanBeOpened=false;
   if(HandleOnCandleOpenOnly==false && MaxOpenedPositionsOnCandle>0 && (OrdersHistoryTotal()>0 || OrdersTotal()>0))
     {
      int currentAlreadyOpenedPositions=0;
      for(int cnt=0;cnt<OrdersTotal();cnt++)
        {
         if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES)==true)
           {
            if((OrderType()==OP_SELL || OrderType()==OP_BUY) && OrderSymbol()==Symbol() && ((OrderMagicNumber()==MagicNumber)))
              {
               if(Period()==PERIOD_M1 || Period()==PERIOD_M5 || Period()==PERIOD_M15 || Period()==PERIOD_M30)
                 {
                  if(TimeMinute(Time[0])==TimeMinute(OrderOpenTime()))
                    {
                     currentAlreadyOpenedPositions=currentAlreadyOpenedPositions+1;
                     if(currentAlreadyOpenedPositions<MaxOpenedPositionsOnCandle)
                       {
                        //positionCanBeOpened=true;
                       }
                    }
                 }
               if(Period()==PERIOD_H1 || Period()==PERIOD_H4)
                 {
                  if(TimeHour(Time[0])==TimeHour(OrderOpenTime()))
                    {
                    Print(TimeHour(Time[0])+"=="+TimeHour(OrderOpenTime()));
                     currentAlreadyOpenedPositions=currentAlreadyOpenedPositions+1;
                     Print("currentAlreadyOpenedPositions="+currentAlreadyOpenedPositions);
                     Print("MaxOpenedPositionsOnCandle="+MaxOpenedPositionsOnCandle);
                     if(currentAlreadyOpenedPositions<MaxOpenedPositionsOnCandle)
                       {
                        positionCanBeOpened=true;
                          } else {
                        positionCanBeOpened=false;
                       }
                    }
                 }
               if(Period()==PERIOD_D1 || Period()==PERIOD_W1)
                 {
                  if(TimeDay(Time[0])==TimeDay(OrderOpenTime()))
                    {
                     currentAlreadyOpenedPositions=currentAlreadyOpenedPositions+1;
                     if(currentAlreadyOpenedPositions<MaxOpenedPositionsOnCandle)
                       {
                        //positionCanBeOpened=true;
                       }
                    }
                 }
               if(Period()==PERIOD_MN1)
                 {
                  if(TimeMinute(Time[0])==TimeMinute(OrderOpenTime()))
                    {
                     currentAlreadyOpenedPositions=currentAlreadyOpenedPositions+1;
                     if(currentAlreadyOpenedPositions<MaxOpenedPositionsOnCandle)
                       {
                        //positionCanBeOpened=true;
                       }
                    }
                 }
              }
           }
        }
      for(int cnt=0;cnt<OrdersHistoryTotal();cnt++)
        {
         if(OrderSelect(cnt,SELECT_BY_POS,MODE_HISTORY)==true)
           {
            if((OrderType()==OP_SELL || OrderType()==OP_BUY) && OrderSymbol()==Symbol() && ((OrderMagicNumber()==MagicNumber)))
              {
               if(Period()==PERIOD_M1 || Period()==PERIOD_M5 || Period()==PERIOD_M15 || Period()==PERIOD_M30)
                 {
                  if(TimeMinute(Time[0])==TimeMinute(OrderOpenTime()))
                    {
                     Print(TimeMinute(Time[0])+"=="+TimeMinute(OrderOpenTime()));
                     currentAlreadyOpenedPositions=currentAlreadyOpenedPositions+1;
                     if(currentAlreadyOpenedPositions<MaxOpenedPositionsOnCandle)
                       {
                        //positionCanBeOpened=true;
                       }
                    }
                 }
               if(Period()==PERIOD_H1 || Period()==PERIOD_H4)
                 {
                  if(TimeHour(Time[0])==TimeHour(OrderOpenTime()))
                    {
                     Print(TimeHour(Time[0])+"=="+TimeHour(OrderOpenTime()));
                     currentAlreadyOpenedPositions=currentAlreadyOpenedPositions+1;
                     Print("currentAlreadyOpenedPositions="+currentAlreadyOpenedPositions);
                     if(currentAlreadyOpenedPositions<MaxOpenedPositionsOnCandle)
                       {
                        positionCanBeOpened=true;
                          } else {
                        positionCanBeOpened=false;
                       }
                    }
                 }
               if(Period()==PERIOD_D1 || Period()==PERIOD_W1)
                 {
                  if(TimeDay(Time[0])==TimeDay(OrderOpenTime()))
                    {
                     currentAlreadyOpenedPositions=currentAlreadyOpenedPositions+1;
                     if(currentAlreadyOpenedPositions<MaxOpenedPositionsOnCandle)
                       {
                        //positionCanBeOpened=true;
                       }
                    }
                 }
               if(Period()==PERIOD_MN1)
                 {
                  if(TimeMinute(Time[0])==TimeMinute(OrderOpenTime()))
                    {
                     currentAlreadyOpenedPositions=currentAlreadyOpenedPositions+1;
                     if(currentAlreadyOpenedPositions<MaxOpenedPositionsOnCandle)
                       {
                        //positionCanBeOpened=true;
                       }
                    }
                 }
              }
           }
        }
        } else {
      positionCanBeOpened=true;
     }
   return positionCanBeOpened;
  }*/
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CurrentProfit(double CurProfit,double CurProfitOfUserPosis)
  {
   ObjectCreate("CurProfit",OBJ_LABEL,0,0,0);
   if(CurProfit>=0.0)
     {
      ObjectSetText("CurProfit","EA Profit: "+DoubleToString(CurProfit,2)+" "+AccountCurrency(),11,"Calibri",clrLime);
        }else{ObjectSetText("CurProfit","EA Profit: "+DoubleToString(CurProfit,2)+" "+AccountCurrency(),11,"Calibri",clrOrangeRed);

     }
   ObjectSet("CurProfit",OBJPROP_CORNER,1);
   ObjectSet("CurProfit",OBJPROP_XDISTANCE,5);
   ObjectSet("CurProfit",OBJPROP_YDISTANCE,40);
   if(HandleUserPositions)
     {
      ObjectCreate("CurProfitOfManualPlacedUserPositions",OBJ_LABEL,0,0,0);
      if(CurProfitOfUserPosis>=0.0)
        {
         ObjectSetText("CurProfitOfManualPlacedUserPositions",
                       "Profit(user positions): "+DoubleToString(CurProfitOfUserPosis,2)+" "+AccountCurrency(),11,"Calibri",clrLime);
           }else{ObjectSetText("CurProfitOfManualPlacedUserPositions",
                                 "Profit(user positions): "+DoubleToString(CurProfitOfUserPosis,2)+" "+AccountCurrency(),11,"Calibri",clrOrangeRed);
        }
      ObjectSet("CurProfitOfManualPlacedUserPositions",OBJPROP_CORNER,1);
      ObjectSet("CurProfitOfManualPlacedUserPositions",OBJPROP_XDISTANCE,5);
      ObjectSet("CurProfitOfManualPlacedUserPositions",OBJPROP_YDISTANCE,120);
     }

   ObjectCreate("MagicNumber",OBJ_LABEL,0,0,0);
   ObjectSetText("MagicNumber","MagicNumber: "+IntegerToString(MagicNumber),11,"Calibri",clrMediumVioletRed);
   ObjectSet("MagicNumber",OBJPROP_CORNER,1);
   ObjectSet("MagicNumber",OBJPROP_XDISTANCE,5);
   ObjectSet("MagicNumber",OBJPROP_YDISTANCE,60);
   if(!TradeOnAllSymbols)
     {
      ObjectCreate("NextLotSize",OBJ_LABEL,0,0,0);
      if(tradeDoubleVarsValues[0][5]>0.0)
        {ObjectSetText("NextLotSize","NextLotSize: "+DoubleToString(tradeDoubleVarsValues[0][5],2),11,"Calibri",clrLightYellow);}
      else {ObjectSetText("NextLotSize","NextLotSize: "+DoubleToString(tradeDoubleVarsValues[0][6],2),11,"Calibri",clrLightYellow);}
      ObjectSet("NextLotSize",OBJPROP_CORNER,1);
      ObjectSet("NextLotSize",OBJPROP_XDISTANCE,5);
      ObjectSet("NextLotSize",OBJPROP_YDISTANCE,80);
/*ObjectCreate("EAName",OBJ_LABEL,0,0,0);
   ObjectSetText("EAName","EAName: "+EAName,11,"Calibri",clrGold);
   ObjectSet("EAName",OBJPROP_CORNER,1);
   ObjectSet("EAName",OBJPROP_XDISTANCE,5);
   ObjectSet("EAName",OBJPROP_YDISTANCE,75);*/
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(CurrentLoss<0.0)
     {
      ObjectCreate("CurrentLoss",OBJ_LABEL,0,0,0);
      ObjectSetText("CurrentLoss","Current loss in %: "+DoubleToString(CurrentLoss,2),11,"Calibri",clrDeepPink);
      ObjectSet("CurrentLoss",OBJPROP_CORNER,1);
      ObjectSet("CurrentLoss",OBJPROP_XDISTANCE,5);
      ObjectSet("CurrentLoss",OBJPROP_YDISTANCE,100);
        } else {ObjectDelete("CurrentLoss");

     }

   if(!IsTesting() && trial_lic && TimeCurrent()>expiryDate) {ExpertRemove();}
   if(!IsTesting() && rent_lic && TimeCurrent()>rentExpiryDate) {ExpertRemove();}
  }
//+------------------------------------------------------------------+  
int getContractProfitCalcMode(string symbolName)
  {
   int profitCalcMode=(int)MarketInfo(symbolName,MODE_PROFITCALCMODE);
   return profitCalcMode;
  }
//+------------------------------------------------------------------+
//| die Überprüfung der neuen Ebene-Werte vor der Modifikation der Order         |
//+------------------------------------------------------------------+
bool OrderModifyCheck(string symbol,int ticket,double price,double sl,double tp)
  {
//--- Wählen wir die Order nach dem Ticket
   if(OrderSelect(ticket,SELECT_BY_TICKET))
     {
      //--- Die Größe des Punktes und des Symbol-Namens, nach dem die Pending Order gesetzt wurde
      double point=SymbolInfoDouble(symbol,SYMBOL_POINT);
      //--- Überprüfen wir - ob es Änderungen im Eröffnungspreis gibt 
      bool PriceOpenChanged=true;
      int type=OrderType();
      if(!(type==OP_BUY || type==OP_SELL))
        {
         PriceOpenChanged=(nd(MathAbs(OrderOpenPrice()-price))>point);
        }
      //--- Überprüfen wir - ob es Änderungen in der Ebene StopLoss gibt
      bool StopLossChanged=(MathAbs(OrderStopLoss()-sl)>point);
      //--- Überprüfen wir - ob es Änderungen in der Ebene Takeprofit gibt
      bool TakeProfitChanged=(MathAbs(OrderTakeProfit()-sl)>tp);
      //--- wenn es Änderungen in den Ebenen  gibt
      if(PriceOpenChanged || StopLossChanged || TakeProfitChanged)
         return(true);  // kann man diese Order modifizieren      
      //--- Änderungen gibt es nicht in den Eröffnungsebenen,StopLoss und Takeprofit 
      else
      //--- Berichten wir über den Fehler
         PrintFormat("Order #%d hat schon Ebene Open=%.5f SL=.5f TP=%.5f",
                     ticket,OrderOpenPrice(),OrderStopLoss(),OrderTakeProfit());
     }
//--- kommen bis zu Ende, Änderungen für die Order nicht gibt
   return(false);       // es gibt keinen Sinn, zu modifizieren 
  }
//+------------------------------------------------------------------+
int getOpenedPositionsForSymbol(string symbolName)
  {
   int cnt=0,OP=0;
   for(cnt=0;cnt<OrdersTotal();cnt++)

     {
      if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES)==true)
        {
         if((OrderType()==OP_SELL || OrderType()==OP_BUY) && OrderSymbol()==symbolName && (OrderMagicNumber()==MagicNumber))
           {
            OP=OP+1;
           }
        }
     }
   return OP;
  }
//+------------------------------------------------------------------+
int getOpenedBuyPositionsForSymbol(string symbolName)
  {
   int cnt=0,OP=0;
   for(cnt=0;cnt<OrdersTotal();cnt++)

     {
      if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES)==true)
        {
         if(OrderType()==OP_BUY && OrderSymbol()==symbolName && OrderMagicNumber()==MagicNumber)
           {
            OP=OP+1;
           }
        }
     }
   return OP;
  }
//+------------------------------------------------------------------+
int getOpenedSellPositionsForSymbol(string symbolName)
  {
   int cnt=0,OP=0;
   for(cnt=0;cnt<OrdersTotal();cnt++)

     {
      if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES)==true)
        {
         if(OrderType()==OP_SELL && OrderSymbol()==symbolName && OrderMagicNumber()==MagicNumber)
           {
            OP=OP+1;
           }
        }
     }
   return OP;
  }
//+------------------------------------------------------------------+
void generateSignalsAndPositions(string strategyName)
  {
   int OB=0,OS=0;
   for(int x=0;x<ArraySize(symbolNameBuffer);x++)
     {
      if(symbolNameBuffer[x]!=IntegerToString(EMPTY_VALUE))
        {
         int symbolTimeframe=_Period;
         if(TradeOnlyListOfSelectedSymbols)
            symbolTimeframe=getTimeframeFromString(symbolTimeframeBuffer[x]);
         string signalStr=getSignalForCurrencyAndStrategy(symbolNameBuffer[x],symbolTimeframe,strategyName);
         if(signalStr!="noSignal")
           {
            int OSC=getOpenedSellPositionsForSymbol(symbolNameBuffer[x]);
            int OBC=getOpenedBuyPositionsForSymbol(symbolNameBuffer[x]);
            int OP = getOpenedPositionsForSymbol(symbolNameBuffer[x]);
            if(signalStr=="Buy")
              {
               OB=1;OS=0;
               if(IsTesting())
                 {
                  Print("Signal for buy on "+symbolNameBuffer[x]+" on "+DoubleToStr(MarketInfo(symbolNameBuffer[x],MODE_ASK),(int)MarketInfo(symbolNameBuffer[x],MODE_DIGITS)));
                    } else {
                  LotSizeIsBiggerThenMaxLot=tradeIntVarsValues[x][4];
                  RemainingLotSize=tradeDoubleVarsValues[x][4];
                  countRemainingMaxLots=(int)tradeDoubleVarsValues[x][3];
                  MaxLot=tradeDoubleVarsValues[x][2];
                  OpenPosition(symbolNameBuffer[x],strategyName,symbolTimeframe,OP,OSC,OBC,OS,OB,LotSizeIsBiggerThenMaxLot,countRemainingMaxLots,MaxLot,RemainingLotSize);
                 }
                 } else if(signalStr=="Sell") {
               OS=1;OB=0;
               if(IsTesting())
                 {
                  Print("Signal for sell on "+symbolNameBuffer[x]+" on "+DoubleToStr(MarketInfo(symbolNameBuffer[x],MODE_BID),(int)MarketInfo(symbolNameBuffer[x],MODE_DIGITS)));
                    } else {
                  LotSizeIsBiggerThenMaxLot=tradeIntVarsValues[x][4];
                  RemainingLotSize=tradeDoubleVarsValues[x][4];
                  countRemainingMaxLots=(int)tradeDoubleVarsValues[x][3];
                  MaxLot=tradeDoubleVarsValues[x][2];
                  OpenPosition(symbolNameBuffer[x],strategyName,symbolTimeframe,OP,OSC,OBC,OS,OB,LotSizeIsBiggerThenMaxLot,countRemainingMaxLots,getTradeDoubleValue(x,1),RemainingLotSize);
                 }
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
void setAllForTradeAvailableSymbols()
  {
   if(TradeOnlyListOfSelectedSymbols)
     {
      string sep=";";
      ushort u_sep;
      u_sep=StringGetCharacter(sep,0);
      StringSplit(ListOfSelectedSymbols,u_sep,symbolNameBuffer);
      StringSplit(ListOfSelectedTimeframesForSymbols,u_sep,symbolTimeframeBuffer);
        } else if(TradeOnAllSymbols) {
      int countOfAllSymbols=SymbolsTotal(false);
      ArrayResize(symbolNameBuffer,countOfAllSymbols);

      for(int j=0;j<countOfAllSymbols;j++)
        {
         string symbolName=SymbolName(j,false);
         bool tradingAllowed=(bool)MarketInfo(symbolName,MODE_TRADEALLOWED);
         int profitCalcMode=(int)MarketInfo(symbolName,MODE_PROFITCALCMODE);
         int marginCalcMode=(int)MarketInfo(symbolName,MODE_MARGINCALCMODE);
         if(IsTesting()) {tradingAllowed=true;}
         if(profitCalcMode==0 && marginCalcMode==0 && tradingAllowed)
           {
            symbolNameBuffer[j]=symbolName;
              } else {
            symbolNameBuffer[j]=IntegerToString(EMPTY_VALUE);
           }
        }
        } else {
      ArrayResize(symbolNameBuffer,1);
      symbolNameBuffer[0]=Symbol();
     }
  }
//+------------------------------------------------------------------+
void setTradeVarsValues()
  {
   ArrayResize(tradeDoubleVarsValues,ArraySize(symbolNameBuffer));
   ArrayResize(tradeIntVarsValues,ArraySize(symbolNameBuffer));
   double TempLotSize=LotSize,tempSymbolLotStep;
   int tempCountedDecimals,tempStopLevel,tempMarginMode,tempTrailingStep=TrailingStep,tempDistanceStep=DistanceStep;

   for(int c=0;c<ArraySize(symbolNameBuffer);c++)

     {
      if(symbolNameBuffer[c]!=IntegerToString(EMPTY_VALUE))
        {
         if(TempLotSize<MarketInfo(symbolNameBuffer[c],MODE_MINLOT))
           {
            TempLotSize=MarketInfo(symbolNameBuffer[c],MODE_MINLOT);
           }
         if(TempLotSize>=MarketInfo(symbolNameBuffer[c],MODE_MAXLOT))
           {
            TempLotSize=MarketInfo(symbolNameBuffer[c],MODE_MAXLOT);
           }
         tradeDoubleVarsValues[c][0]=TempLotSize;
         tempSymbolLotStep=SymbolInfoDouble(symbolNameBuffer[c],SYMBOL_VOLUME_STEP);
         tradeDoubleVarsValues[c][1]=tempSymbolLotStep;
         tempCountedDecimals=(int)-MathLog10(tempSymbolLotStep);
         tempStopLevel=(int)(MarketInfo(symbolNameBuffer[c],MODE_STOPLEVEL)*1.3);
         tradeIntVarsValues[c][0]=tempCountedDecimals;
         tradeIntVarsValues[c][1]=tempStopLevel;
         tempMarginMode=(int)MarketInfo(symbolNameBuffer[c],MODE_MARGINCALCMODE);
         tradeIntVarsValues[c][1]=tempMarginMode;
         if(tempStopLevel>0)
           {
            tempTrailingStep=tempTrailingStep+tempStopLevel;
            tempDistanceStep=tempDistanceStep+tempStopLevel;
            tradeIntVarsValues[c][2]=tempTrailingStep;
            tradeIntVarsValues[c][3]=tempDistanceStep;
            if(Debug)
              {
               Print("tempTrailingStep="+IntegerToString(tempTrailingStep)+
                     ";tempDistanceStep="+IntegerToString(tempDistanceStep)+";tempStopLevel="+IntegerToString(tempStopLevel));
              }
              } else {
            tradeIntVarsValues[c][2]=tempTrailingStep;
            tradeIntVarsValues[c][3]=tempDistanceStep;
           }

         //risk management
         bool compareContractSizes=false;
         if(CompareDoubles(SymbolInfoDouble(symbolNameBuffer[c],SYMBOL_TRADE_CONTRACT_SIZE),100000.0)) {compareContractSizes=true;}
         else {compareContractSizes=false;}
         countRemainingMaxLots=0;
         LotSizeIsBiggerThenMaxLot=false;
         MaxLot=MarketInfo(symbolNameBuffer[c],MODE_MAXLOT);
         if(tempSymbolLotStep>0.0)
           {
            MaxLot=NormalizeDouble(MaxLot-MathMod(MaxLot,tempSymbolLotStep),tempCountedDecimals);
           }
         tradeDoubleVarsValues[c][2]=MaxLot;
         if(LotAutoSize)
           {
            int Faktor=100;
            if(AccountLeverage()<100)Faktor=Faktor*100;
            if(LotRiskPercent<0.001 || LotRiskPercent>1000){Comment("Invalid Risk Value.");}
            else
              {
               if(getContractProfitCalcMode(symbolNameBuffer[c])==0 || (tempMarginMode==0 && compareContractSizes))
                 {
                  if(MarketInfo(symbolNameBuffer[c],MODE_ASK)!=0 && MarketInfo(symbolNameBuffer[c],MODE_LOTSIZE)!=0 && MarketInfo(symbolNameBuffer[c],MODE_MINLOT)!=0)
                    {
                     TempLotSize=NormalizeDouble(MathFloor((AccountFreeMargin()*AccountLeverage()*LotRiskPercent*MarketInfo(symbolNameBuffer[c],MODE_POINT)*Faktor)/
                                                 (MarketInfo(symbolNameBuffer[c],MODE_ASK)*MarketInfo(symbolNameBuffer[c],MODE_LOTSIZE)*MarketInfo(symbolNameBuffer[c],MODE_MINLOT)))
                                                 *MarketInfo(symbolNameBuffer[c],MODE_MINLOT),tempCountedDecimals);
                    }
                 }
               else if((getContractProfitCalcMode(symbolNameBuffer[c])==1 || getContractProfitCalcMode(symbolNameBuffer[c])==2 || tempMarginMode==4) && (compareContractSizes==false))
                 {
                  //Print("Fall2:"+((getContractProfitCalcMode()==1 || getContractProfitCalcMode()==2 || tempMarginMode==4) && (compareContractSizes==false)));
                  if(SymbolInfoDouble(symbolNameBuffer[c],SYMBOL_TRADE_CONTRACT_SIZE)==1.0){tempCountedDecimals=0;}
                  int Splitter=1000;
                  if(getContractProfitCalcMode(symbolNameBuffer[c])==1){Splitter=100000;}
                  if(tempMarginMode==4 && MarketInfo(symbolNameBuffer[c],MODE_TICKSIZE)==0.001){Splitter=1000000;}
                  if((int)MarketInfo(symbolNameBuffer[c],MODE_DIGITS)==3){Faktor=1;}
                  if((int)MarketInfo(symbolNameBuffer[c],MODE_DIGITS)==2){Faktor=10;}
                  if(MarketInfo(symbolNameBuffer[c],MODE_ASK)!=0 && MarketInfo(symbolNameBuffer[c],MODE_LOTSIZE)!=0 && MarketInfo(symbolNameBuffer[c],MODE_MINLOT)!=0)
                    {
                     TempLotSize=NormalizeDouble(MathFloor((AccountFreeMargin()*AccountLeverage()*LotRiskPercent*Faktor*MarketInfo(symbolNameBuffer[c],MODE_POINT))/
                                                 (MarketInfo(symbolNameBuffer[c],MODE_ASK)*MarketInfo(symbolNameBuffer[c],MODE_TICKSIZE)*MarketInfo(symbolNameBuffer[c],MODE_MINLOT)))
                                                 *MarketInfo(symbolNameBuffer[c],MODE_MINLOT)/Splitter,tempCountedDecimals);
                    }
                  if(tempSymbolLotStep>0.0)
                    {
                     TempLotSize=TempLotSize-MathMod(TempLotSize,tempSymbolLotStep);
                    }
                    } else {
                  Print("Cannot calculate the right auto lot size!");
                  TempLotSize=MarketInfo(symbolNameBuffer[c],MODE_MINLOT);
                 }
              }
            if(MaxDynamicLotSize>0 && TempLotSize>MaxDynamicLotSize)
              {
               TempLotSize=MaxDynamicLotSize;
              }
           }
         if(LotAutoSize==false){TempLotSize=TempLotSize;}
         if(TempLotSize<MarketInfo(symbolNameBuffer[c],MODE_MINLOT))
           {
            TempLotSize=MarketInfo(symbolNameBuffer[c],MODE_MINLOT);
            if(tempSymbolLotStep>0.0)
              {
               TempLotSize=NormalizeDouble(TempLotSize-MathMod(TempLotSize,tempSymbolLotStep),tempCountedDecimals);
              }
           }
         if(TempLotSize>MaxLot)
           {
            countRemainingMaxLots=(int)(TempLotSize/MaxLot);
            tradeDoubleVarsValues[c][3]=countRemainingMaxLots;
            RemainingLotSize=MathMod(TempLotSize,MaxLot);
            tradeDoubleVarsValues[c][4]=RemainingLotSize;
            LotSizeIsBiggerThenMaxLot=true;
            tradeIntVarsValues[c][4]=LotSizeIsBiggerThenMaxLot;
            double CurrentTotalLotSize=TempLotSize;
            tradeDoubleVarsValues[c][5]=CurrentTotalLotSize;
            TempLotSize=MarketInfo(symbolNameBuffer[c],MODE_MAXLOT);
            if(tempSymbolLotStep>0.0)
              {
               TempLotSize=NormalizeDouble(TempLotSize-MathMod(TempLotSize,tempSymbolLotStep),tempCountedDecimals);
              }
           }
         tradeDoubleVarsValues[c][6]=TempLotSize;
         if(Debug)
           {
            Print("LotSize("+symbolNameBuffer[c]+")="+DoubleToStr(TempLotSize,tempCountedDecimals));
           }
         tradeDoubleVarsValues[c][7]=MarketInfo(symbolNameBuffer[c],MODE_STOPLEVEL)*MarketInfo(symbolNameBuffer[c],MODE_POINT);
        }
     }
  }
//+------------------------------------------------------------------+
int getTradeIntVarValue(int arrayIndex,int valueIndex)
  {
   return tradeIntVarsValues[arrayIndex][valueIndex];
  }
//+------------------------------------------------------------------+  
double getTradeDoubleValue(int arrayIndex,int valueIndex)
  {
   return tradeDoubleVarsValues[arrayIndex][valueIndex];
  }
//+------------------------------------------------------------------+  
int getSymbolArrayIndex(string symbolName)
  {
   int symbolNameIndex=0;
   for(int i=0;i<ArraySize(symbolNameBuffer);i++)
     {
      if(symbolNameBuffer[i]==symbolName) {symbolNameIndex=i;break;}
     }
   return symbolNameIndex;
  }
//+------------------------------------------------------------------
double checkForMod(string symbolName)
  {
   double TempProfit=0.0;
   for(int j=0;j<OrdersTotal();j++)
     {
      if(OrderSelect(j,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol()==symbolName && (OrderMagicNumber()==MagicNumber))
           {
            if(TradeFromSignalToSignal && MakeCloseTradeAlwaysInProfit
               && ((OrderType()==OP_BUY && OrderStopLoss()<OrderOpenPrice()) || (OrderType()==OP_SELL && OrderStopLoss()>OrderOpenPrice()))
               && OrderComment()==EAName)
              {
               TrP(symbolName);
              }
            else if(!TradeFromSignalToSignal && OrderComment()==EAName+"!1")
              {
               TrP(symbolName);
              }
            TempProfit=TempProfit+OrderProfit()+OrderCommission()+OrderSwap();
            if(Debug){Print("TempProfit="+DoubleToStr(TempProfit));}
           }
        }
     }
   for(int j=0;j<OrdersTotal();j++)
     {
      if(OrderSelect(j,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol()==symbolName && (OrderMagicNumber()==MagicNumber))
           {
            if(MakeCloseTradeAlwaysInProfit && MinAmount>0 && SetSLToMinAmountUnder>0)
              {
               if(TempProfit>(MinAmount+SetSLToMinAmountUnder))
                 {
                  if(OrderType()==OP_SELL && OrderStopLoss()>OrderOpenPrice())
                    {
                     if(TP==0)TPI=0;else TPI=OrderOpenPrice()-TP*Point;if(SL==0)SLI=OrderOpenPrice()+10000*Point;else SLI=OrderOpenPrice()+SL*Point;
                     if(OrderModifyCheck(Symbol(),OrderTicket(),OrderOpenPrice(),SLI,TPI) && CheckStopLoss_Takeprofit(Symbol(),ORDER_TYPE_SELL,SLI,TPI))
                       {
                        if(OrderTakeProfit()!=TPI && ((OrderStopLoss()<SLI && OrderOpenPrice()<OrderStopLoss()) || OrderStopLoss()==0))
                          {
                           bool Res=OrderModify(OrderTicket(),OrderOpenPrice(),SLI,OrderTakeProfit(),0,clrGoldenrod);
                          }
                       }
                    }
                  else
                  if(OrderType()==OP_BUY && OrderStopLoss()<OrderOpenPrice())
                    {
                     if(TP==0)TPI=0;else TPI=OrderOpenPrice()+TP*Point;if(SL==0)SLI=OrderOpenPrice()-10000*Point;else SLI=OrderOpenPrice()-SL*Point;
                     if(OrderModifyCheck(Symbol(),OrderTicket(),OrderOpenPrice(),SLI,TPI) && CheckStopLoss_Takeprofit(Symbol(),ORDER_TYPE_BUY,SLI,TPI))
                       {
                        if(OrderStopLoss()>SLI && OrderOpenPrice()>OrderStopLoss())
                          {
                           bool Res=OrderModify(OrderTicket(),OrderOpenPrice(),SLI,OrderTakeProfit(),0,clrGoldenrod);
                          }
                       }
                    }
                 }
              }
           }
        }
     }
   return TempProfit;
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
int getCurrentSpreadForSymbol(string symbolName)
  {
   return (int)MarketInfo(symbolName,MODE_SPREAD);
  }
//+------------------------------------------------------------------+
void createNotifications(string symbolName,string direction,int period,string additionalText,string strategyName)
  {

   if(DebugTrace){Print("Area51 on "+symbolName+"("+getTimeframeFromMinutes(period)+")",strategyName+" strategy: "+direction+" signal at "+DoubleToStr(iClose(symbolName,0,0),(int)MarketInfo(symbolName,MODE_DIGITS)));}
   if(SendEMail){SendMail("Area51 on "+symbolName+"("+getTimeframeFromMinutes(period)+")",strategyName+" strategy: "+direction+" signal at "+DoubleToStr(iClose(symbolName,0,0),(int)MarketInfo(symbolName,MODE_DIGITS)));}
   if(SendNotificationToPhone){SendNotification(direction+" signal at "+DoubleToStr(iClose(symbolName,0,0),(int)MarketInfo(symbolName,MODE_DIGITS))+" -> Area51 on "+symbolName+"("+getTimeframeFromMinutes(period)+") with "+strategyName+" strategy");}
   if(ShowAlertBox) {Alert("Area51 on "+symbolName+"("+getTimeframeFromMinutes(period)+") "+strategyName+" strategy: "+direction+" signal at "+DoubleToStr(iClose(symbolName,0,0),(int)MarketInfo(symbolName,MODE_DIGITS)));}
  }
//+------------------------------------------------------------------+
void openPendingsForWrongDirectionTrades(string symbolName)
  {
//get all current trades for symbol with the same magic number
//iterate above the list
//for each trade, that distance from open price more than StepInPoints in wrong direction
//multiple StepInPoints if price is over OpenPrice+-StepInPoints
//set a pending order at the price from open price +-PendingOrderAfter
//with expiry PendingOrderExpiry
//

   int lastticket=-1,lasttype=0,lastm=0,lastn=0;
   double lastlot=0,lastprice=0,lastprofit=0;
   datetime lasttime=0;
   string lastcom="";
   if(IsNewBar())
     {
      for(int i=OrdersTotal();i>=0;i--)
        {
         if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))continue;
         if(OrderSymbol()!=symbolName)continue;
         if(OrderMagicNumber()!=MagicNumber)continue;
         //if(OrderTicket()>lastticket)
           {
            lastticket=OrderTicket();
            lastlot=OrderLots();
            lastprice=OrderOpenPrice();
            lasttype=OrderType();
            lasttime=OrderOpenTime();
            lastcom=OrderComment();
           }
         //}
         int n=(int)cutEnd(lastcom,"!")+1;
         string comment=EAName+"_"+IntegerToString(lastticket)+"!"+string(n);
         if(n-1>=MaxPendingAmount && MaxPendingAmount>0) {Print("HandleWrongPositions: Max amount of orders reached!");continue;}
         if((lasttype==OP_BUY || lasttype==OP_BUYSTOP) && Bid<=lastprice-StepInPoints*_Point)
           {
            double price=lastprice-(PendingOrderAfter)*_Point;
            if(!hasAlreadyPending(OrderSymbol(),price,lastticket))
              {
               int pendingBuy=OrderSend(symbolName,OP_BUYSTOP,getTradeDoubleValue(0,6),price,Slippage,0,0,comment,MagicNumber,TimeCurrent()+2592000,clrBlue);
               if(pendingBuy<0) {Print("Error send sell pending order: "+IntegerToString(GetLastError()));}
               else{Print("OrderComment="+comment);}
              }
           }
         if((lasttype==OP_SELL || lasttype==OP_SELLSTOP) && Ask>=lastprice+StepInPoints*_Point)
           {
            double price=lastprice+(PendingOrderAfter)*_Point;
            if(!hasAlreadyPending(OrderSymbol(),price,lastticket))
              {
               int pendingSell=OrderSend(symbolName,OP_SELLSTOP,getTradeDoubleValue(0,6),price,Slippage,0,0,comment,MagicNumber,TimeCurrent()+2592000,clrRed);
               if(pendingSell<0) {Print("Error send sell pending order: "+IntegerToString(GetLastError()));}
               else{Print("OrderComment="+comment);}
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
void handleWrongDirectionTrades(string symbolName)
  {
   double currentProfit=0.0;
   double bprice=0,sprice=0,bavgprice=0,savgprice=0,
   pipval=0,buylot=0,selllot=0,bprofit=0,sprofit=0,bweight=0,sweight=0,totalprofit=0;
   int bn=0,sn=0,pe=0,market=0;
   for(int i=0;i<OrdersTotal();i++)
     {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))continue;
      if(OrderSymbol()!=_Symbol)continue;
      if(OrderMagicNumber()!=MagicNumber)continue;
      if(OrderType()!=OP_BUY && OrderType()!=OP_SELL)continue;
      currentProfit+=OrderProfit()+OrderSwap()+OrderCommission();
      double profit=OrderProfit();
      double diff=(OrderClosePrice()-OrderOpenPrice())/_Point;
      double lot=OrderLots();
      if(profit==0)profit=0.01;
      if(diff==0)diff=1;
      pipval=fabs(nd(profit/diff/lot));
      if(OrderType()==OP_BUY)
        {
         bprofit+=OrderProfit()+OrderSwap()+OrderCommission();
         bprice+=OrderOpenPrice();
         bn++;
         buylot+=OrderLots();
         bweight+=OrderOpenPrice()*OrderLots();
        }
      if(OrderType()==OP_SELL)
        {
         sprofit+=OrderProfit()+OrderSwap()+OrderCommission();
         sprice+=OrderOpenPrice();
         sn++;
         selllot+=OrderLots();
         sweight+=OrderOpenPrice()*OrderLots();
        }
     }

   currentProfit=nd2(currentProfit);
   double pips=0;
   if(buylot!=selllot)
     {
      pips=nd((currentProfit/fabs(buylot-selllot)*pipval)*_Point);
     }
   double beprice=0;
   if(buylot>selllot)
     {
      beprice=Bid-pips+PointsToTake*_Point;
     }
   if(buylot<selllot)
     {
      beprice=Ask+pips-PointsToTake*_Point;
     }

   double tickValue=MarketInfo(symbolName,MODE_TICKVALUE);
   if(tickValue==0) {tickValue=0.9;}
   double pointsToTakeInMoney=NormalizeDouble(tickValue*getTradeDoubleValue(0,6)*PointsToTake,2);

   if(currentProfit>0 && ((buylot>selllot && Bid>=beprice)
      || (buylot<selllot && Ask<=beprice))
      )
     {
      //close all positions with the same ordernummer and order if PointsToTake*TickValue*Lots are reached
      CloseAll();
     }
  }
//+------------------------------------------------------------------+
bool hasAlreadyPending(string symbolName,double openPrice,int orderNumber)
  {
   bool res=false;
   for(int z=0;z<OrdersTotal();z++)
     {
      if(OrderSelect(z,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol()==symbolName && OrderMagicNumber()==MagicNumber
            && StringFind(OrderComment(),EAName+"_"+IntegerToString(orderNumber))>-1
            && NormalizeDouble(OrderOpenPrice(),5)==NormalizeDouble(openPrice,5))
           {
            res=true;
            break;
           }
        }
     }
   return res;
  }
//+------------------------------------------------------------------+
