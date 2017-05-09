//+------------------------------------------------------------------+
//|                                                 AreaFiftyOne.mq4 |
//|                                                           VBApps |
//|                                                 http://vbapps.co |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2017 VBApps::Valeri Balachnin"
#property link      "http://vbapps.co"
#property version   "1.20"
#property description "Trades on oversold or overbought market."
#property strict

#resource "\\Indicators\\AreaFiftyOneIndicator.ex4"

#define SLIPPAGE              5
#define NO_ERROR              1
#define AT_LEAST_ONE_FAILED   2

//--- input parameters
extern double   LotSize=0.01;
extern bool     LotAutoSize=false;
extern int      LotRiskPercent=25;
extern int      MoneyRiskInPercent=0;
bool     UseMainIndicator=true;
extern bool     AllowPendings=false;
bool     AllowStoch=false;
extern int      TrailingStep=50;
extern int      DistanceStep=50;
extern int      MagicNumber=3537;
extern int      TakeProfit=750;
extern int      StopLoss=0;

int RSI_Period=13;         //8-25
int RSI_Price=5;           //0-6
int Volatility_Band=34;    //20-40
int RSI_Price_Line=0;
int RSI_Price_Type=MODE_SMA;      //0-3
int Trade_Signal_Line=7;
int Trade_Signal_Line2=18;
int Trade_Signal_Type=MODE_SMA;   //0-3
double over_bought=80;
double over_sold=20;
int k_period=9;
int d_period=6;
int slowing=6;
double sto_main_curr,sto_sign_curr,sto_main_prev1,sto_sign_prev1,sto_main_prev2,sto_sign_prev2;
int ma_method=MODE_SMA;
int price_field=0;
int Slippage=3,MaxOrders=6,BreakEven=0;
int TicketNrPendingSell=0,TicketNrPendingSell2=0,TicketNrSell=0;
int TicketNrPendingBuy=0,TicketNrPendingBuy2=0,TicketNrBuy=0;
double LotSizeP1,LotSizeP2;
bool AddPositions=false;
int StopLevel=0;
double CurrentLoss=0;
double TP=TakeProfit,SL=StopLoss;
double SLI=0,TPI=0;
string EAName="AreaFiftyOne";
string IndicatorName="AreaFiftyOneIndicator";
/*licence*/
bool trial_lic=false;
datetime expiryDate=D'2017.05.27 00:00';
/*licence_end*/
bool WrongDirectionBuy=false,WrongDirectionSell=false;
int WrongDirectionBuyTicketNr=0,WrongDirectionSellTicketNr=0;
int TicketNrBuyWD=0,TicketNrSellWD=0;
int TicketNrBuyStoch=0,TicketNrSellStoch=0;
int handle_ind;
bool OrderDueStoch=false;
int countStochOrders=0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   if(trial_lic)
     {
      if(TimeCurrent()>expiryDate)
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

   handle_ind=(int)iCustom(_Symbol,_Period,"::Indicators\\"+IndicatorName+".ex4",0,0);
   if(handle_ind==INVALID_HANDLE)
     {
      Print("Expert: iCustom call: Error code=",GetLastError());
      return(INIT_FAILED);
     }
   bool compareContractSizes=false;
   if(CompareDoubles(SymbolInfoDouble(Symbol(),SYMBOL_TRADE_CONTRACT_SIZE),100000.0)) {compareContractSizes=true;}
   else {compareContractSizes=false;}
   StopLevel=(int)(MarketInfo(Symbol(),MODE_STOPLEVEL)*Point()*1.3);
   int MarginMode=(int)MarketInfo(Symbol(),MODE_MARGINCALCMODE);
   if((getContractProfitCalcMode()==1 || getContractProfitCalcMode()==2 || MarginMode==4)
      && (AllowPendings) && (compareContractSizes==false))
     {AllowPendings=false;Print("Pendings are disabled due CFD or Futures.");}
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(AllowStoch){Print("countStochOrders="+IntegerToString(countStochOrders));}
   ObjectsDeleteAll();
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   int limit=1,err=0,BuyFlag=0,SellFlag=0;
   bool BUY=false,SELL=false;

   if(StopLevel>0)
     {
      TrailingStep=TrailingStep+StopLevel;
      DistanceStep=DistanceStep+StopLevel;
     }
//double TempTDIGreen=0,TempTDIRed=0;
   if(UseMainIndicator)
     {
      for(int i=1;i<=limit;i++)
        {
         //double TDIGreenPlusOne=iCustom(Symbol(),0,"::Indicators\\"+IndicatorName+".ex4",RSI_Period,RSI_Price,Volatility_Band,RSI_Price_Line,RSI_Price_Type,Trade_Signal_Line,Trade_Signal_Line2,Trade_Signal_Type,4,i+1);
         double TDIGreen=iCustom(Symbol(),0,"::Indicators\\"+IndicatorName+".ex4",RSI_Period,RSI_Price,Volatility_Band,RSI_Price_Line,RSI_Price_Type,Trade_Signal_Line,Trade_Signal_Line2,Trade_Signal_Type,4,i);
         double TDIYellow=iCustom(Symbol(),0,"::Indicators\\"+IndicatorName+".ex4",RSI_Period,RSI_Price,Volatility_Band,RSI_Price_Line,RSI_Price_Type,Trade_Signal_Line,Trade_Signal_Line2,Trade_Signal_Type,2,i);
         //double TDIRedPlusOne=iCustom(Symbol(),0,"::Indicators\\"+IndicatorName+".ex4",RSI_Period,RSI_Price,Volatility_Band,RSI_Price_Line,RSI_Price_Type,Trade_Signal_Line,Trade_Signal_Line2,Trade_Signal_Type,5,i+1);
         double TDIRed=iCustom(Symbol(),0,"::Indicators\\"+IndicatorName+".ex4",RSI_Period,RSI_Price,Volatility_Band,RSI_Price_Line,RSI_Price_Type,Trade_Signal_Line,Trade_Signal_Line2,Trade_Signal_Type,5,i);
         // double TDIUp=iCustom(Symbol(),0,"::Indicators\\"+IndicatorName+".ex4",RSI_Period,RSI_Price,Volatility_Band,RSI_Price_Line,RSI_Price_Type,Trade_Signal_Line,Trade_Signal_Line2,Trade_Signal_Type,1,i);
         // double TDIDown=iCustom(Symbol(),0,"::Indicators\\"+IndicatorName+".ex4",RSI_Period,RSI_Price,Volatility_Band,RSI_Price_Line,RSI_Price_Type,Trade_Signal_Line,Trade_Signal_Line2,Trade_Signal_Type,3,i);
         // double TDIB3=iCustom(Symbol(),0,"::Indicators\\"+IndicatorName+".ex4",RSI_Period,RSI_Price,Volatility_Band,RSI_Price_Line,RSI_Price_Type,Trade_Signal_Line,Trade_Signal_Line2,Trade_Signal_Type,6,i);

         if((TDIGreen>68) &&(NormalizeDouble(TDIGreen,3)>NormalizeDouble(TDIRed,3)) &&(NormalizeDouble(NormalizeDouble(TDIGreen,3)-NormalizeDouble(TDIRed,3),1)>=3.5)) SELL=true;
         if((TDIRed<32) && (NormalizeDouble(TDIGreen,3)<NormalizeDouble(TDIRed,3)) && (NormalizeDouble(NormalizeDouble(TDIRed,3)-NormalizeDouble(TDIGreen,3),1)>=3.5)) BUY=true;

         //if((SELL==false && BUY ==false) && (TDIRed>TDIGreen) && (TDIRedPlusOne<=TDIGreenPlusOne) && (TDIGreen-TDIRed)>=3.5)BUY=true;
         //if((SELL==false && BUY ==false) && (TDIRed<TDIGreen) && (TDIRedPlusOne>=TDIGreenPlusOne) && (TDIGreen-TDIRed)>=3.5)SELL=true;


/*if(TDIGreen-TDIRed<6){Print("NO Exit !");}*/
/*  if(TDIGreen-TDIRed>=6){Print("Change of Trend: If you have SELL Position(s),Check Exit Rules!");}
      if(TDIRed-TDIGreen>=6){Print("Change of Trend: If you have BUY Position(s),Check Exit Rules!");}*/
/*
TempTDIGreen=TDIGreen;
      TempTDIRed=TDIRed;*/
         //entry conditions

         if(BUY==true){BuyFlag=1;break;}
         if(SELL==true){SellFlag=1;break;}
        }
     }
   if(AllowStoch)
     {
      sto_main_curr  = iStochastic(Symbol(),PERIOD_D1,k_period,d_period,slowing,ma_method,price_field,MODE_MAIN,0);
      sto_sign_curr  = iStochastic(Symbol(),PERIOD_D1,k_period,d_period,slowing,ma_method,price_field,MODE_SIGNAL,0);
      sto_main_prev1 = iStochastic(Symbol(),PERIOD_D1,k_period,d_period,slowing,ma_method,price_field,MODE_MAIN,1);
      sto_sign_prev1 = iStochastic(Symbol(),PERIOD_D1,k_period,d_period,slowing,ma_method,price_field,MODE_SIGNAL,1);
      sto_main_prev2 = iStochastic(Symbol(),PERIOD_D1,k_period,d_period,slowing,ma_method,price_field,MODE_MAIN,2);
      sto_sign_prev2 = iStochastic(Symbol(),PERIOD_D1,k_period,d_period,slowing,ma_method,price_field,MODE_SIGNAL,2);

      if((sto_sign_prev2<over_sold) && (sto_main_prev2<over_sold))
        {
         if((sto_sign_prev2>sto_main_prev2) && (sto_sign_prev1<sto_main_prev1))
           {
            if(sto_sign_prev1<sto_sign_curr)
              {
               //Print("Buy due Stoch!");
               OrderDueStoch=true;
               BuyFlag=1;
              }
           }
        }
      //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~SELL~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      if((sto_sign_prev2>over_bought) && (sto_main_prev2>over_bought))
        {
         if((sto_sign_prev2<sto_main_prev2) && (sto_sign_prev1>sto_main_prev1))
           {
            if(sto_sign_prev1>sto_sign_curr)
              {
               //Print("Sell due Stoch!");
               OrderDueStoch=true;
               SellFlag=1;
              }
           }
        }
     }

//risk management
   int digits=Digits;
   double SymbolStep=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP);
   int MarginMode=(int)MarketInfo(Symbol(),MODE_MARGINCALCMODE);
   bool compareContractSizes=false;
   if(CompareDoubles(SymbolInfoDouble(Symbol(),SYMBOL_TRADE_CONTRACT_SIZE),100000.0)) {compareContractSizes=true;}
   else {compareContractSizes=false;}

   if(LotAutoSize)
     {
      int Faktor=100;
      if(LotRiskPercent<0.1 || LotRiskPercent>100){Comment("Invalid Risk Value.");}
      else
        {
         if(getContractProfitCalcMode()==0 || (MarginMode==0 && compareContractSizes))
           {
            //Print("Fall1:"+(MarginMode==0 && compareContractSizes));
            LotSize=MathFloor((AccountFreeMargin()*AccountLeverage()*LotRiskPercent*Point*Faktor)/
                              (Ask*MarketInfo(Symbol(),MODE_LOTSIZE)*MarketInfo(Symbol(),MODE_MINLOT)))*MarketInfo(Symbol(),MODE_MINLOT);
            //Print("LotSize="+LotSize);
            LotSizeP1 = NormalizeDouble(LotSize*0.625,Digits);
            LotSizeP2 = NormalizeDouble(LotSize*0.5,Digits);
           }
         else if((getContractProfitCalcMode()==1 || getContractProfitCalcMode()==2 || MarginMode==4) && (compareContractSizes==false))
           {
            //Print("Fall2:"+((getContractProfitCalcMode()==1 || getContractProfitCalcMode()==2 || MarginMode==4) && (compareContractSizes==false)));
            if(SymbolInfoDouble(Symbol(),SYMBOL_TRADE_CONTRACT_SIZE)==1){digits=0;}
            int Splitter=1000;
            if(getContractProfitCalcMode()==1){Splitter=100000;}
            if(MarginMode==4 && MarketInfo(Symbol(),MODE_TICKSIZE)==0.001){Splitter=1000000;}
            if(Digits==3){Faktor=1;}
            if(Digits==2){Faktor=10;}
            LotSize=NormalizeDouble(MathFloor((AccountFreeMargin()*AccountLeverage()*LotRiskPercent*Faktor*Point)/
                                    (Ask*MarketInfo(Symbol(),MODE_TICKSIZE)*MarketInfo(Symbol(),MODE_MINLOT)))*MarketInfo(Symbol(),MODE_MINLOT)/Splitter,digits);
            LotSizeP1 = MathFloor(NormalizeDouble(LotSize*0.625,digits));
            LotSizeP2 = MathFloor(NormalizeDouble(LotSize*0.5,digits));
            //Print("LotSize2="+LotSize);
            if(SymbolStep>0.0)
              {
               LotSize=LotSize-MathMod(LotSize,SymbolStep);
               LotSizeP1=LotSizeP1-MathMod(LotSizeP1,SymbolStep);
               LotSizeP2=LotSizeP2-MathMod(LotSizeP2,SymbolStep);
              }
              } else {
            Print("Cannot calculate the right auto lot size!");
            LotSize=MarketInfo(Symbol(),MODE_MINLOT);
            LotSizeP1=MarketInfo(Symbol(),MODE_MINLOT);
            LotSizeP2=MarketInfo(Symbol(),MODE_MINLOT);
           }
        }
     }
   if(LotAutoSize==false){LotSize=LotSize;}
   if(LotSize<MarketInfo(Symbol(),MODE_MINLOT))
     {
      LotSize=MarketInfo(Symbol(),MODE_MINLOT);
      LotSizeP1 = NormalizeDouble(LotSize*0.625,digits);
      LotSizeP2 = NormalizeDouble(LotSize*0.5,digits);
      if(SymbolStep>0.0)
        {
         LotSize=LotSize-MathMod(LotSize,SymbolStep);
         LotSizeP1=LotSizeP1-MathMod(LotSizeP1,SymbolStep);
         LotSizeP2=LotSizeP2-MathMod(LotSizeP2,SymbolStep);
        }
     }
   if(LotSize>MarketInfo(Symbol(),MODE_MAXLOT))
     {
      LotSize=MarketInfo(Symbol(),MODE_MAXLOT);
      LotSizeP1=NormalizeDouble(LotSizeP1*0.625,digits);
      LotSizeP2=NormalizeDouble(LotSizeP2*0.5,digits);
      if(SymbolStep>0.0)
        {
         LotSize=LotSize-MathMod(LotSize,SymbolStep);
         LotSizeP1=LotSizeP1-MathMod(LotSizeP1,SymbolStep);
         LotSizeP2=LotSizeP2-MathMod(LotSizeP2,SymbolStep);
        }
     }

/* Print("LotSize="+(LotSize-MathMod(LotSize,SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP))));
      Print("LotSize*0,625="+(LotSizeP1-MathMod(LotSize,SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP))));
      Print("LotSize*0,5="+(LotSizeP2-MathMod(LotSize,SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP))));*/

//Money Management
   double TempLoss=0;
   for(int j=0;j<OrdersTotal();j++)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      if(OrderSelect(j,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol()==Symbol() && (OrderMagicNumber()==MagicNumber))
           {
            TempLoss=TempLoss+OrderProfit();
           }
        }
     }
     if(AccountBalance()>0) {
   CurrentLoss=NormalizeDouble((TempLoss/AccountBalance())*100,2);}
   if(MoneyRiskInPercent>0 && StrToInteger(DoubleToStr(MathAbs(CurrentLoss),0))>MoneyRiskInPercent)
     {
      while(CloseAll()==AT_LEAST_ONE_FAILED)
        {
         Sleep(1000);
         Print("Order close failed - retrying error: #"+IntegerToString(GetLastError()));
        }
     }

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
   if(SellFlag>0){OS=1;OB=0;}if(BuyFlag>0){OB=1;OS=0;}

//conditions to close positions
/* if(SellFlag>0){CloseBuy=1;}
   if(BuyFlag>0){CloseSell=1;}
*/
/*for(cnt=0;cnt<OrdersTotal();cnt++)
     {
      OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
      if((OrderType()==OP_BUY || OrderType()==OP_BUYLIMIT) && OrderSymbol()==Symbol() && ((OrderMagicNumber()==MagicNumber) || MagicNumber==0))
        {
         if(CloseBuy==1)
           {
            OrderClose(OrderTicket(),OrderLots(),Bid,Slippage,Red);
            for(int t=0;t<OrdersTotal();t++)
              {
               if(OrderType()==OP_BUYLIMIT && OrderSymbol()==Symbol() && ((OrderMagicNumber()==MagicNumber) || MagicNumber==0))
                 {
                  if(StringCompare(OrderComment(),EAName+"P1B")==0 || StringCompare(OrderComment(),EAName+"P2B")==0) OrderDelete(OrderTicket(),clrNONE);
                 }
              }
            TicketNr=0;
            TicketNrPending=0;
            TicketNrPending2=0;
            CurrentProfit(0);
           }
        }
      if((OrderType()==OP_SELL || OrderType()==OP_SELLLIMIT) && OrderSymbol()==Symbol() && ((OrderMagicNumber()==MagicNumber) || MagicNumber==0))
        {
         if(CloseSell==1)
           {
            OrderClose(OrderTicket(),OrderLots(),Ask,Slippage,Red);
            for(int k=0;k<OrdersTotal();k++)
              {
               if(OrderType()==OP_SELLLIMIT && OrderSymbol()==Symbol() && ((OrderMagicNumber()==MagicNumber) || MagicNumber==0))
                 {
                  if(StringCompare(OrderComment(),EAName+"P1S") || StringCompare(OrderComment(),EAName+"P2S")) OrderDelete(OrderTicket(),clrNONE);
                 }
              }
            TicketNr=0;
            TicketNrPending=0;
            TicketNrPending2=0;
            CurrentProfit(0);
           }
        }
     }*/

   for(cnt=0;cnt<OrdersHistoryTotal();cnt++)
     {
      if(OrderSelect(cnt,SELECT_BY_POS,MODE_HISTORY) && OrderSymbol()==Symbol() && 
         (TicketNrPendingSell>0 || TicketNrPendingSell2>0 || TicketNrPendingBuy>0 || TicketNrPendingBuy2>0 || TicketNrSellStoch>0 || TicketNrBuyStoch>0) && 
         (OrderMagicNumber()==MagicNumber) && 
         (OrderTicket()==TicketNrBuy || OrderTicket()==TicketNrSell || OrderTicket()==TicketNrBuyWD || OrderTicket()==TicketNrSellWD
         || OrderTicket()==TicketNrSellStoch || OrderTicket()==TicketNrBuyStoch))
        {
         bool foundS1=false,foundS2=false,foundB1=false,foundB2=false,foundSWD=false,foundBWD=false,foundSST=false,foundBST=false;
         for(int cnt0=0;cnt0<OrdersHistoryTotal();cnt0++)
           {
            if(WrongDirectionSellTicketNr>0 && WrongDirectionSellTicketNr==OrderTicket()){WrongDirectionSell=false;WrongDirectionSellTicketNr=0;}
            if(WrongDirectionBuyTicketNr>0  &&  WrongDirectionBuyTicketNr==OrderTicket()){WrongDirectionBuy=false;WrongDirectionBuyTicketNr=0;}
            if(OrderTicket()==TicketNrPendingSell) {foundS1=true;}
            if(OrderTicket()==TicketNrPendingSell2) {foundS2=true;}
            if(OrderTicket()==TicketNrPendingBuy) {foundB1=true;}
            if(OrderTicket()==TicketNrPendingBuy2) {foundB2=true;}
            if(OrderTicket()==TicketNrSellWD) {foundSWD=true;}
            if(OrderTicket()==TicketNrBuyWD) {foundBWD=true;}
            if(OrderTicket()==TicketNrSellStoch) {foundSST=true;}
            if(OrderTicket()==TicketNrBuyStoch) {foundBST=true;}

            if(foundSST){TicketNrSellStoch=0;}
            if(foundBST){TicketNrBuyStoch=0;}
            if(OrderTicket()==TicketNrSell)
              {
               if(foundS1==false && TicketNrPendingSell>0
                  && getTicketCurrentType(TicketNrPendingSell)>-1 && getTicketCurrentType(TicketNrPendingSell)==3)
                 {
                  bool delS1; delS1=OrderDelete(TicketNrPendingSell);
                  if(delS1==false){bool delS11;delS11=OrderDelete(TicketNrPendingSell);TicketNrPendingSell=0;}else{TicketNrPendingSell=0;}
                 }
               if(foundS2==false && TicketNrPendingSell2>0
                  && getTicketCurrentType(TicketNrPendingSell2)>-1 && getTicketCurrentType(TicketNrPendingSell2)==3)
                 {
                  bool delS2; delS2=OrderDelete(TicketNrPendingSell2);
                  if(delS2==false){bool delS21;delS21=OrderDelete(TicketNrPendingSell2);TicketNrPendingSell2=0;}else{TicketNrPendingSell2=0;}
                 }
               if(foundBWD==false && getTicketCurrentType(TicketNrBuyWD)>-1 && getTicketCurrentType(TicketNrBuyWD)==3)
                 {
                  bool delB; delB=OrderDelete(TicketNrPendingSell2);
                  if(delB==false){bool delB1;delB1=OrderDelete(TicketNrBuyWD);TicketNrBuyWD=0;}else{TicketNrBuyWD=0;}
                 }
              }
            if(OrderTicket()==TicketNrBuy)
              {
               if(foundB1==false && TicketNrPendingBuy>0
                  && getTicketCurrentType(TicketNrPendingBuy)>-1 && getTicketCurrentType(TicketNrPendingBuy)==2)
                 {
                  bool delB1; delB1=OrderDelete(TicketNrPendingBuy);
                  if(delB1==false){bool delB11;delB11=OrderDelete(TicketNrPendingBuy);TicketNrPendingBuy=0;}else{TicketNrPendingBuy=0;}
                 }

               if(foundB2==false && TicketNrPendingBuy2>0
                  && getTicketCurrentType(TicketNrPendingBuy2)>-1 && getTicketCurrentType(TicketNrPendingBuy2)==2)
                 {
                  bool delB2; delB2=OrderDelete(TicketNrPendingBuy2);
                  if(delB2==false){bool delB21;delB21=OrderDelete(TicketNrPendingBuy2);TicketNrPendingBuy2=0;}else{TicketNrPendingBuy2=0;}
                 }
               if(foundSWD==false && getTicketCurrentType(TicketNrSellWD)>-1 && getTicketCurrentType(TicketNrSellWD)==3)
                 {
                  bool delS; delS=OrderDelete(TicketNrPendingSell2);
                  if(delS==false){bool delS1;delS1=OrderDelete(TicketNrSellWD);TicketNrSellWD=0;}else{TicketNrSellWD=0;}
                 }
              }
           }
        }
     }

   for(cnt=0;cnt<OrdersTotal();cnt++)
     {
      if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES)==true && (OrderType()==OP_BUY || OrderType()==OP_SELL) && (OrderSymbol()==Symbol()) && (OrderMagicNumber()==MagicNumber) && 
         ((TicketNrPendingSell>0 || (TicketNrPendingSell>0 && TicketNrPendingSell2>0)) || 
         (TicketNrPendingBuy>0 || (TicketNrPendingBuy>0 && TicketNrPendingBuy2>0))) && (TicketNrBuy>0 || TicketNrSell>0))
        {
         for(int c=0;c<OrdersTotal();c++)
           {
            if(OrderSelect(c,SELECT_BY_POS,MODE_TRADES)==true)
              {
               double TempTP=NormalizeDouble(OrderTakeProfit(),Digits);
               if((OrderTicket()==TicketNrPendingSell && OrderType()==OP_SELL) || (OrderTicket()==TicketNrPendingSell2 && OrderType()==OP_SELL))
                 {
                  if((TicketNrSell>0) && (OrderSelect(TicketNrSell,SELECT_BY_TICKET,MODE_TRADES)==true) && TempTP!=OrderTakeProfit())
                    {
                     if(OrderModifyCheck(OrderTicket(),OrderOpenPrice(),0,TempTP))
                       {
                        bool fm;fm=OrderModify(TicketNrSell,OrderOpenPrice(),0,TempTP,0,CLR_NONE);
                       }
                    }
/*if((TicketNrPendingSell>0) && (OrderSelect(TicketNrPendingSell,SELECT_BY_TICKET,MODE_TRADES)==true) && TempTP!=OrderTakeProfit())
                    {bool fm1;fm1=OrderModify(TicketNrPendingSell,OrderOpenPrice(),0,TempTP,0,CLR_NONE);}
                  if((TicketNrPendingSell2>0) && (OrderSelect(TicketNrPendingSell2,SELECT_BY_TICKET,MODE_TRADES)==true) && TempTP!=OrderTakeProfit())
                    {bool fm2;fm2=OrderModify(TicketNrPendingSell2,OrderOpenPrice(),0,TempTP,0,CLR_NONE);}*/
                  WrongDirectionSell=true;
                  WrongDirectionSellTicketNr=TicketNrSell;
                  break;
                 }
              }
           }
         for(int f=0;f<OrdersTotal();f++)
           {
            if(OrderSelect(f,SELECT_BY_POS,MODE_TRADES)==true)
              {
               double TempTP=NormalizeDouble(OrderTakeProfit(),Digits);
               if((OrderTicket()==TicketNrPendingBuy && OrderType()==OP_BUY) || (OrderTicket()==TicketNrPendingBuy2 && OrderType()==OP_BUY))
                 {
                  if((TicketNrBuy>0) && (OrderSelect(TicketNrBuy,SELECT_BY_TICKET,MODE_TRADES)==true) && TempTP!=OrderTakeProfit())
                    {
                     if(OrderModifyCheck(OrderTicket(),OrderOpenPrice(),0,TempTP))
                       {
                        bool fm;fm=OrderModify(TicketNrBuy,OrderOpenPrice(),0,TempTP,0,CLR_NONE);
                       }
                    }
/* if((TicketNrPendingBuy>0) && (OrderSelect(TicketNrPendingBuy,SELECT_BY_TICKET,MODE_TRADES)==true) && TempTP!=OrderTakeProfit())
                    {bool fm1;fm1=OrderModify(TicketNrPendingBuy,OrderOpenPrice(),0,TempTP,0,CLR_NONE);}
                  if((TicketNrPendingBuy2>0) && (OrderSelect(TicketNrPendingBuy2,SELECT_BY_TICKET,MODE_TRADES)==true) && TempTP!=OrderTakeProfit())
                    {bool fm2;fm2=OrderModify(TicketNrPendingBuy2,OrderOpenPrice(),0,TempTP,0,CLR_NONE);}*/
                  WrongDirectionBuy=true;
                  WrongDirectionBuyTicketNr=TicketNrBuy;
                  break;
                 }
              }
           }
        }
     }
//open position
// 
   if((AddP() && AddPositions && OP<=MaxOrders) || (OP<=MaxOrders && !AddPositions))
     {
      // && TempTDIGreen>RSI_Top_Value && (TempTDIGreen-TempTDIRed)>=3.5
      //&& MarketInfo(Symbol(),MODE_TRADEALLOWED)
      if(!(AccountFreeMarginCheck(Symbol(),OP_SELL,LotSize*3)<=0 || GetLastError()==134))
        {
         if(OrderDueStoch && AllowStoch && TicketNrSellStoch==0)
           {
            if(OrderDueStoch){Print("Sell due Stoch!");countStochOrders=countStochOrders+1;}
            if(TP==0)TPI=0;else TPI=Bid-TP*Point;if(SL==0)SLI=0;else SLI=Bid+SL*Point;
            if(CheckMoneyForTrade(Symbol(),LotSize,OP_SELL))
              {
               TicketNrSellStoch=OrderSend(Symbol(),OP_SELL,LotSize,Bid,Slippage,SLI,TPI,EAName,MagicNumber,0,Red);OS=0;
               if(TicketNrSellStoch<0)
                 {Print("OrderSend Error: "+IntegerToString(GetLastError()));}
               //else{Print("Order Sent Successfully, Ticket # is: "+string(TicketNrSell));}
              }
           }
         if(OS==1 && OSC==0 && !OrderDueStoch)
           {
            if(TP==0)TPI=0;else TPI=Bid-TP*Point;if(SL==0)SLI=0;else SLI=Bid+SL*Point;
            if(CheckMoneyForTrade(Symbol(),LotSize,OP_SELL))
              {
               TicketNrSell=OrderSend(Symbol(),OP_SELL,LotSize,Bid,Slippage,SLI,TPI,EAName,MagicNumber,0,Red);OS=0;
               if(TicketNrSell<0)
                 {Print("OrderSend Error: "+IntegerToString(GetLastError()));}
               //else{Print("Order Sent Successfully, Ticket # is: "+string(TicketNrSell));}
              }

            if(AllowPendings && !OrderDueStoch)
              {
               double TempPendingLotSize=LotSizeP1;
               if(TempPendingLotSize<MarketInfo(Symbol(),MODE_MINLOT))TempPendingLotSize=MarketInfo(Symbol(),MODE_MINLOT);
               if(TicketNrPendingSell>0 && OrderSelect(TicketNrPendingSell,SELECT_BY_POS))
                 {if(OrderType()==3){bool delS=OrderDelete(TicketNrPendingSell);}TicketNrPendingSell=0;}
               else if(!OrderSelect(TicketNrPendingSell,SELECT_BY_POS) && TicketNrPendingSell>0)
                 {TicketNrPendingSell=0;}
               if(TicketNrPendingSell==0 && IsNewOrderAllowed() && (CheckMoneyForTrade(Symbol(),TempPendingLotSize,OP_SELL)))
                 {
                  TicketNrPendingSell=OrderSend(Symbol(),OP_SELLLIMIT,TempPendingLotSize,Bid+TP/2*Point,Slippage,0,Bid,EAName+"P1S",MagicNumber,0,Red);
                  if(TicketNrPendingSell<0)
                    {Print("OrderSend Error: "+IntegerToString(GetLastError()));}
                  // else{Print("Order Sent Successfully, Ticket # is: "+string(TicketNrPendingSell));}
                 }

               double TempPendingLotSize2=LotSizeP1;
               if(TempPendingLotSize2<MarketInfo(Symbol(),MODE_MINLOT))TempPendingLotSize2=MarketInfo(Symbol(),MODE_MINLOT);
               if(TicketNrPendingSell2>0 && OrderSelect(TicketNrPendingSell2,SELECT_BY_POS))
                 {if(OrderType()==3){bool delS2=OrderDelete(TicketNrPendingSell2);}TicketNrPendingSell2=0;}
               else if(!OrderSelect(TicketNrPendingSell2,SELECT_BY_POS) && TicketNrPendingSell2>0)
                 {TicketNrPendingSell2=0;}
               if(TicketNrPendingSell2==0 && IsNewOrderAllowed() && (CheckMoneyForTrade(Symbol(),TempPendingLotSize2,OP_SELL)))
                 {
                  TicketNrPendingSell2=OrderSend(Symbol(),OP_SELLLIMIT,TempPendingLotSize2,Bid+TP/1*Point,Slippage,0,Bid,EAName+"P2S",MagicNumber,0,Red);
                  if(TicketNrPendingSell2<0)
                    {Print("OrderSend Error: "+IntegerToString(GetLastError()));}
                  else{Print("Order Sent Successfully, Ticket # is: "+string(TicketNrPendingSell2));}
                 }

               if(TP==0)TPI=0;else TPI=Ask+(TP*2)*Point;if(SL==0)SLI=0;else SLI=Ask-(SL*2)*Point;
               if(CheckMoneyForTrade(Symbol(),LotSize,OP_BUY) && IsNewOrderAllowed())
                 {
                  int expiryTime=(int)TimeCurrent()+(1209600);
                  TicketNrBuyWD=OrderSend(Symbol(),OP_BUYSTOP,LotSize,Ask+TP*Point,Slippage,SLI,TPI,EAName+"WD_BUY",MagicNumber,expiryTime,Lime);
                  if(TicketNrBuyWD<0)
                    {Print("OrderSend Error: "+IntegerToString(GetLastError()));}
                  //else{Print("Order Sent Successfully, Ticket # is: "+string(TicketNrBuy));}
                 }
              }
            OrderDueStoch=false;
           }
        }
      // && TempTDIGreen<RSI_Down_Value && (TempTDIGreen-TempTDIRed)>=3.5
      // && MarketInfo(Symbol(),MODE_TRADEALLOWED)
      if(!(AccountFreeMarginCheck(Symbol(),OP_BUY,LotSize*3)<=0 || GetLastError()==134))
        {
         if(OrderDueStoch && AllowStoch && TicketNrBuyStoch==0)
           {
            if(OrderDueStoch){Print("Buy due Stoch!");countStochOrders=countStochOrders+1;}
            if(TP==0)TPI=0;else TPI=Ask+TP*Point;if(SL==0)SLI=0;else SLI=Ask-SL*Point;
            if(CheckMoneyForTrade(Symbol(),LotSize,OP_BUY))
              {
               TicketNrBuyStoch=OrderSend(Symbol(),OP_BUY,LotSize,Ask,Slippage,SLI,TPI,EAName,MagicNumber,0,Lime);OB=0;
               if(TicketNrBuyStoch<0)
                 {Print("OrderSend Error: "+IntegerToString(GetLastError()));}
               //else{Print("Order Sent Successfully, Ticket # is: "+string(TicketNrBuy));}
              }
           }
         if(OB==1 && OBC==0 && !OrderDueStoch)
           {
            if(TP==0)TPI=0;else TPI=Ask+TP*Point;if(SL==0)SLI=0;else SLI=Ask-SL*Point;
            if(CheckMoneyForTrade(Symbol(),LotSize,OP_BUY))
              {
               TicketNrBuy=OrderSend(Symbol(),OP_BUY,LotSize,Ask,Slippage,SLI,TPI,EAName,MagicNumber,0,Lime);OB=0;
               if(TicketNrBuy<0)
                 {Print("OrderSend Error: "+IntegerToString(GetLastError()));}
               //else{Print("Order Sent Successfully, Ticket # is: "+string(TicketNrBuy));}
              }
            if(AllowPendings && !OrderDueStoch)
              {
               double TempPendingLotSize=LotSizeP1;
               if(TempPendingLotSize<MarketInfo(Symbol(),MODE_MINLOT))TempPendingLotSize=MarketInfo(Symbol(),MODE_MINLOT);
               if(TicketNrPendingBuy>0 && OrderSelect(TicketNrPendingBuy,SELECT_BY_POS))
                 {if(OrderType()==2){bool delB=OrderDelete(TicketNrPendingBuy);}TicketNrPendingBuy=0;}
               else if(!OrderSelect(TicketNrPendingBuy,SELECT_BY_POS) && TicketNrPendingBuy>0)
                 {TicketNrPendingBuy=0;}
               if(TicketNrPendingBuy==0 && IsNewOrderAllowed() && (CheckMoneyForTrade(Symbol(),TempPendingLotSize,OP_BUY)))
                 {
                  TicketNrPendingBuy=OrderSend(Symbol(),OP_BUYLIMIT,TempPendingLotSize,Ask-TP/2*Point,Slippage,0,Ask,EAName+"P1B",MagicNumber,0,Red);
                  if(TicketNrPendingBuy<0)
                    {Print("OrderSend Error: "+IntegerToString(GetLastError()));}
                  //else{Print("Order Sent Successfully, Ticket # is: "+string(TicketNrPendingBuy));}
                 }

               double TempPendingLotSize2=LotSizeP2;
               if(TempPendingLotSize2<MarketInfo(Symbol(),MODE_MINLOT))TempPendingLotSize2=MarketInfo(Symbol(),MODE_MINLOT);
               if(TicketNrPendingBuy2>0 && OrderSelect(TicketNrPendingBuy2,SELECT_BY_POS) && OrderType()==2)
                 {if(OrderType()==2){bool delB2=OrderDelete(TicketNrPendingBuy2);}TicketNrPendingBuy2=0;}
               else if(!OrderSelect(TicketNrPendingBuy2,SELECT_BY_POS) && TicketNrPendingBuy2>0)
                 {TicketNrPendingBuy2=0;}
               if(TicketNrPendingBuy2==0 && IsNewOrderAllowed() && (CheckMoneyForTrade(Symbol(),TempPendingLotSize2,OP_BUY)))
                 {
                  TicketNrPendingBuy2=OrderSend(Symbol(),OP_BUYLIMIT,TempPendingLotSize2,Ask-TP/1*Point,Slippage,0,Ask,EAName+"P2B",MagicNumber,0,Red);
                  if(TicketNrPendingBuy2<0)
                    {Print("OrderSend Error: "+IntegerToString(GetLastError()));}
                  //else{Print("Order Sent Successfully, Ticket # is: "+string(TicketNrPendingBuy2));}
                 }

               if(TP==0)TPI=0;else TPI=Bid-(TP*2)*Point;if(SL==0)SLI=0;else SLI=Bid+(SL*2)*Point;
               if(CheckMoneyForTrade(Symbol(),LotSize,OP_SELL) && IsNewOrderAllowed())
                 {
                  int expiryTime=(int)TimeCurrent()+(1209600);
                  TicketNrSellWD=OrderSend(Symbol(),OP_SELLSTOP,LotSize,Bid-TP*Point,Slippage,SLI,TPI,EAName+"WD_SELL",MagicNumber,expiryTime,Red);
                  if(TicketNrSellWD<0)
                    {Print("OrderSend Error: "+IntegerToString(GetLastError()));}
                  // else{Print("Order Sent Successfully, Ticket # is: "+string(TicketNrSellWD));}
                 }
              }
            OrderDueStoch=false;
           }
        }
     }
   double TempProfit=0;
   for(int j=0;j<OrdersTotal();j++)
     {
      if(OrderSelect(j,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol()==Symbol() && (OrderMagicNumber()==MagicNumber))
           {
            if(WrongDirectionBuy==true && OrderType()==OP_SELL){TrP();}
            else if(WrongDirectionSell==true && OrderType()==OP_BUY){TrP();}
            else if(WrongDirectionBuy==false && WrongDirectionSell==false){TrP();}
            TempProfit=TempProfit+OrderProfit()+OrderCommission()+OrderSwap();
           }
        }
     }
   CurrentProfit(TempProfit);

//not enough money message to continue the martingale
   if((TicketNrBuy<0 || TicketNrSell<0) && GetLastError()==134){err=1;Print("NOT ENOGUGHT MONEY!!");}
  }
//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
//---
   double ret=AccountBalance();
//---
//---
   return(ret);
  }
//add positions function
bool AddP()
  {
   int _num=0,_ot=0;
   for(int j=0;j<OrdersTotal();j++)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      if(OrderSelect(j,SELECT_BY_POS)==true && OrderSymbol()==Symbol() && OrderType()<3 && (OrderMagicNumber()==MagicNumber))
        {
         _num++;if(OrderOpenTime()>_ot) _ot=(int)OrderOpenTime();
        }
     }
   if(_num==0) return(true);if(_num>0 && ((Time[0]-_ot))>0) return(true);else return(false);
  }
//trailing stop and breakeven
void TrP()
  {
   int BE=BreakEven;int TS=DistanceStep;double pb,pa,pp;pp=MarketInfo(OrderSymbol(),MODE_POINT);
   if(OrderType()==OP_BUY)
     {
      pb=MarketInfo(OrderSymbol(),MODE_BID);
      if(BE>0)
        {
         if((pb-OrderOpenPrice())>BE*pp)
           {
            if((OrderStopLoss()-OrderOpenPrice())<0)
              {
               ModSL(OrderOpenPrice()+0*pp);
              }
           }
        }
      if(TS>0)
        {
         if((pb-OrderOpenPrice())>TS*pp)
           {
            if(OrderStopLoss()<pb-(TS+TrailingStep-1)*pp)
              {
               ModSL(pb-TS*pp);return;
              }
           }
        }
     }
   if(OrderType()==OP_SELL)
     {
      pa=MarketInfo(OrderSymbol(),MODE_ASK);
      if(BE>0)
        {
         if((OrderOpenPrice()-pa)>BE*pp)
           {
            if((OrderOpenPrice()-OrderStopLoss())<0)
              {
               ModSL(OrderOpenPrice()-0*pp);
              }
           }
        }
      if(TS>0)
        {
         if(OrderOpenPrice()-pa>TS*pp)
           {
            if(OrderStopLoss()>pa+(TS+TrailingStep-1)*pp || OrderStopLoss()==0)
              {
               ModSL(pa+TS*pp);
               return;
              }
           }
        }
     }
  }
//stop loss modification function
void ModSL(double ldSL)
  {
   double commissions=OrderCommission()+OrderSwap();
   double commissionsInPips=0.0;
   commissionsInPips=((commissions/OrderLots()/MarketInfo(Symbol(),MODE_TICKVALUE))
                        +MarketInfo(Symbol(),MODE_SPREAD))*MarketInfo(Symbol(),MODE_TICKSIZE);
   Print("commissionsInPips="+DoubleToStr(commissionsInPips,5));
   if(OrderModifyCheck(OrderTicket(),OrderOpenPrice(),ldSL+commissionsInPips,OrderTakeProfit()))
     {
      bool fm;fm=OrderModify(OrderTicket(),OrderOpenPrice(),ldSL,OrderTakeProfit(),0,CLR_NONE);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CurrentProfit(double CurProfit)
  {
   ObjectCreate("CurProfit",OBJ_LABEL,0,0,0);
   if(CurProfit>=0.0)
     {
      ObjectSetText("CurProfit","Current Profit: "+DoubleToString(CurProfit,2)+" "+AccountCurrency(),11,"Calibri",clrLime);
        }else{ObjectSetText("CurProfit","Current Profit: "+DoubleToString(CurProfit,2)+" "+AccountCurrency(),11,"Calibri",clrOrangeRed);
     }
   ObjectSet("CurProfit",OBJPROP_CORNER,1);
   ObjectSet("CurProfit",OBJPROP_XDISTANCE,5);
   ObjectSet("CurProfit",OBJPROP_YDISTANCE,30);

   ObjectCreate("MagicNumber",OBJ_LABEL,0,0,0);
   ObjectSetText("MagicNumber","MagicNumber: "+IntegerToString(MagicNumber),11,"Calibri",clrMediumVioletRed);
   ObjectSet("MagicNumber",OBJPROP_CORNER,1);
   ObjectSet("MagicNumber",OBJPROP_XDISTANCE,5);
   ObjectSet("MagicNumber",OBJPROP_YDISTANCE,45);

   ObjectCreate("NextLotSize",OBJ_LABEL,0,0,0);
   ObjectSetText("NextLotSize","NextLotSize: "+DoubleToString(LotSize,2),11,"Calibri",clrLightYellow);
   ObjectSet("NextLotSize",OBJPROP_CORNER,1);
   ObjectSet("NextLotSize",OBJPROP_XDISTANCE,5);
   ObjectSet("NextLotSize",OBJPROP_YDISTANCE,60);

   ObjectCreate("EAName",OBJ_LABEL,0,0,0);
   ObjectSetText("EAName","EAName: "+EAName,11,"Calibri",clrGold);
   ObjectSet("EAName",OBJPROP_CORNER,1);
   ObjectSet("EAName",OBJPROP_XDISTANCE,5);
   ObjectSet("EAName",OBJPROP_YDISTANCE,75);

   if(CurrentLoss<0.0)
     {
      ObjectCreate("CurrentLoss",OBJ_LABEL,0,0,0);
      ObjectSetText("CurrentLoss","Current loss in %: "+DoubleToString(CurrentLoss,2),11,"Calibri",clrDeepPink);
      ObjectSet("CurrentLoss",OBJPROP_CORNER,1);
      ObjectSet("CurrentLoss",OBJPROP_XDISTANCE,5);
      ObjectSet("CurrentLoss",OBJPROP_YDISTANCE,90);
        } else {ObjectDelete("CurrentLoss");

     }

   if(trial_lic && TimeCurrent()>expiryDate) {ExpertRemove();}
  }
//+------------------------------------------------------------------+
int getTicketCurrentType(int TicketNr)
  {
   int res=-1;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(OrderSelect(TicketNr,SELECT_BY_TICKET,MODE_TRADES))
     {
      res=OrderType();
     }
   return res;
  }
//+------------------------------------------------------------------+
int CloseAll()
  {
   bool rv=NO_ERROR;
   int numOfOrders=OrdersTotal();
   int FirstOrderType=0;

   for(int index=0; index<OrdersTotal(); index++)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      bool oS=OrderSelect(index,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
        {
         FirstOrderType=OrderType();
         break;
        }
     }

   for(int index=numOfOrders-1; index>=0; index--)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      bool oS=OrderSelect(index,SELECT_BY_POS,MODE_TRADES);

      if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
         switch(OrderType())
           {
            case OP_BUY:
               if(!OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),SLIPPAGE,Red))
               rv=AT_LEAST_ONE_FAILED;
               break;

            case OP_SELL:
               if(!OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),SLIPPAGE,Red))
               rv=AT_LEAST_ONE_FAILED;
               break;

            case OP_BUYLIMIT:
            case OP_SELLLIMIT:
            case OP_BUYSTOP:
            case OP_SELLSTOP:
               if(!OrderDelete(OrderTicket()))
               rv=AT_LEAST_ONE_FAILED;
               break;
           }
     }

   return(rv);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Überprüft - ob noch eine Order gesetzt werden kann               |
//+------------------------------------------------------------------+
bool IsNewOrderAllowed()
  {
//--- Bekommen die Anzahl der erlaubten Pending Orders am Konto
   int max_allowed_orders=(int)AccountInfoInteger(ACCOUNT_LIMIT_ORDERS);

//---  wenn es keine Beschränkungen gibt - geben true zurück, man kann auch Order absenden
   if(max_allowed_orders==0) return(true);

//--- wenn es bis zu dieser Stelle angekommen ist, bedeutet dies, dass eine Beschränkung gibt, wie viel Order schon gelten
   int orders=OrdersTotal();

//--- geben wir das Ergebnis des Vergleiches zurück
   return(orders<max_allowed_orders);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int getContractProfitCalcMode()
  {
   int profitCalcMode=(int)MarketInfo(Symbol(),MODE_PROFITCALCMODE);
   return profitCalcMode;
  }
//+------------------------------------------------------------------+
bool CheckMoneyForTrade(string symb,double lots,int type)
  {
   double free_margin=AccountFreeMarginCheck(symb,type,lots);
//-- wenn es Geldmittel nicht ausreichend sind
   if(free_margin<0)
     {
      string oper=(type==OP_BUY)? "Buy":"Sell";
      Print("Not enough money for ",oper," ",lots," ",symb," Error code=",GetLastError());
      return(false);
     }
//-- die Überprüfung ist erfolgreich gelaufen
   return(true);
  }
//+------------------------------------------------------------------+
bool CompareDoubles(double number1,double number2)
  {
   if(NormalizeDouble(number1-number2,5)==0) return(true);
   else return(false);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| die Überprüfung der neuen Ebene-Werte vor der Modifikation der Order         |
//+------------------------------------------------------------------+
bool OrderModifyCheck(int ticket,double price,double sl,double tp)
  {
//--- Wählen wir die Order nach dem Ticket
   if(OrderSelect(ticket,SELECT_BY_TICKET))
     {
      //--- Die Größe des Punktes und des Symbol-Namens, nach dem die Pendig Order gesetzt wurde
      string symbol=OrderSymbol();
      double point=SymbolInfoDouble(symbol,SYMBOL_POINT);
      //--- Überprüfen wir - ob es Änderungen im Eröffnungspreis gibt 
      bool PriceOpenChanged=true;
      int type=OrderType();
      if(!(type==OP_BUY || type==OP_SELL))
        {
         PriceOpenChanged=(MathAbs(OrderOpenPrice()-price)>point);
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
