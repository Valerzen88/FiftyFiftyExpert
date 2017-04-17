//+------------------------------------------------------------------+
//|                                                 AreaFiftyOne.mq4 |
//|                                                           VBApps |
//|                                                 http://vbapps.co |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2017 VBApps::Valeri Balachnin"
#property link      "http://vbapps.co"
#property version   "1.5"
#property description "Trades on oversold or overbought market till the next signal."
#property strict

#resource "\\Indicators\\AreaFiftyOneIndicator.ex4"

//--- input parameters
extern double   LotSize=0.01;
extern bool     LotAutoSize=true;
extern int      LotRiskPercent=50;
extern int      MoneyRiskInPercent=32;
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
int Slippage=3,MaxOrders=6,BreakEven=0;
int TicketNrPendingSell=0,TicketNrPendingSell2=0,TicketNrSell=0;
int TicketNrPendingBuy=0,TicketNrPendingBuy2=0,TicketNrBuy=0;
bool AddPositions=false;
double CurrentLoss=0;
double TP=TakeProfit,SL=StopLoss;
double SLI=0,TPI=0;
string EAName="AreaFiftyOne";
string IndicatorName="AreaFiftyOneIndicator";
/*licence*/
bool trial_lic=true;
datetime expiryDate=D'2017.05.27 00:00';
/*licence_end*/
bool WrongDirectionBuy=false,WrongDirectionSell=false;
int WrongDirectionBuyTicketNr=0,WrongDirectionSellTicketNr=0;
int handle_ind;
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

   handle_ind=iCustom(_Symbol,_Period,"::Indicators\\"+IndicatorName+".ex4",0,0);
   if(handle_ind==INVALID_HANDLE)
     {
      Print("Expert: iCustom call: Error code=",GetLastError());
      return(INIT_FAILED);
     }
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
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
//double TempTDIGreen=0,TempTDIRed=0;
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

/* string TSRed=DoubleToStr(TDIRed);
      string TSGreen=DoubleToStr(TDIGreen);
      StringReplace(TSRed,".","");
      StringReplace(TSGreen,".","");
      int TRed=StrToInteger(TSRed);
      int TGreen=StrToInteger(TSGreen);*/
/*Print("*****************START");
      Print("TDIGreen="+NormalizeDouble(TDIGreen,3));
      Print("TDIRed="+NormalizeDouble(TDIRed,3));
      Print(TDIGreen>65.0);
      Print(TDIRed<35.0);
      Print(NormalizeDouble(TDIGreen,3)>NormalizeDouble(TDIRed,3));
      Print(NormalizeDouble(TDIGreen,3)<NormalizeDouble(TDIRed,3));
      Print(NormalizeDouble(NormalizeDouble(TDIRed,3)-NormalizeDouble(TDIGreen,3),1)>=3.5);
      Print(NormalizeDouble(NormalizeDouble(TDIGreen,3)-NormalizeDouble(TDIRed,3),1)>=3.5);
      Print("*****************END");*/
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
//risk management
   if(LotAutoSize)
     {
      int Faktor=100;
      if(LotRiskPercent<0.1 || LotRiskPercent>100){Comment("Invalid Risk Value.");}
      else
        {
         if(Digits<3){Faktor=10;}else{Faktor=100;}
         LotSize=MathFloor((AccountFreeMargin()*AccountLeverage()*LotRiskPercent*Point*Faktor)/(Ask*MarketInfo(Symbol(),MODE_LOTSIZE)*
                           MarketInfo(Symbol(),MODE_MINLOT)))*MarketInfo(Symbol(),MODE_MINLOT);
         if(LotSize<MarketInfo(Symbol(),MODE_MINLOT)) LotSize=MarketInfo(Symbol(),MODE_MINLOT);
        }
     }
   if(LotAutoSize==false){LotSize=LotSize;}

//Money Management
   double TempLoss=0;
   for(int j=0;j<OrdersTotal();j++)
     {
      if(OrderSelect(j,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol()==Symbol() && (OrderMagicNumber()==MagicNumber))
           {
            TempLoss=TempLoss+OrderProfit();
           }
        }
     }
   CurrentLoss=NormalizeDouble((TempLoss/AccountBalance())*100,2);
   if(MoneyRiskInPercent>0 && StrToInteger(DoubleToStr(MathAbs(CurrentLoss),0))>MoneyRiskInPercent) 
     {
      for(int j=0;j<OrdersTotal();j++)
        {
         if(OrderSelect(j,SELECT_BY_POS,MODE_TRADES))
           {
            if(OrderSymbol()==Symbol() && (OrderMagicNumber()==MagicNumber))
              {
               if(OrderType()==3){bool delP = OrderDelete(OrderTicket());}
               if(OrderType()==2){bool delP = OrderDelete(OrderTicket());}
               if(OrderType()==0){bool delO = OrderClose(OrderTicket(),OrderLots(),Bid,Slippage,clrRed);}
               if(OrderType()==1){bool delO = OrderClose(OrderTicket(),OrderLots(),Ask,Slippage,clrRed);}
              }
           }
        }
     }

//positions initialization
   int cnt=0,OP=0,OS=0,OB=0,CloseSell=0,OSC=0,OBC=0,CloseBuy=0;OP=0;
   for(cnt=0;cnt<OrdersTotal();cnt++)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
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
         (TicketNrPendingSell>0 || TicketNrPendingSell2>0 || TicketNrPendingBuy>0 || TicketNrPendingBuy2>0) && 
         (OrderMagicNumber()==MagicNumber) && (OrderTicket()==TicketNrBuy || OrderTicket()==TicketNrSell))
        {
         bool foundS1=false,foundS2=false,foundB1=false,foundB2=false;
         for(int cnt0=0;cnt0<OrdersHistoryTotal();cnt0++)
           {
            if(WrongDirectionSellTicketNr>0 && WrongDirectionSellTicketNr==OrderTicket()){WrongDirectionSell=false;WrongDirectionSellTicketNr=0;}
            if(WrongDirectionBuyTicketNr>0  &&  WrongDirectionBuyTicketNr==OrderTicket()){WrongDirectionBuy=false;WrongDirectionBuyTicketNr=0;}
            if(OrderTicket()==TicketNrPendingSell) {foundS1=true;}
            if(OrderTicket()==TicketNrPendingSell2) {foundS2=true;}
            if(OrderTicket()==TicketNrPendingBuy) {foundB1=true;}
            if(OrderTicket()==TicketNrPendingBuy2) {foundB2=true;}

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
                    {bool fm;fm=OrderModify(TicketNrSell,OrderOpenPrice(),0,TempTP,0,CLR_NONE);}
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
                    {bool fm;fm=OrderModify(TicketNrBuy,OrderOpenPrice(),0,TempTP,0,CLR_NONE);}
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
      if(OS==1 && OSC==0 && (!(AccountFreeMarginCheck(Symbol(),OP_SELL,LotSize*3)<=0 || GetLastError()==134)))
        {
         if(TP==0)TPI=0;else TPI=Bid-TP*Point;if(SL==0)SLI=0;else SLI=Bid+SL*Point;
         TicketNrSell=OrderSend(Symbol(),OP_SELL,LotSize,Bid,Slippage,SLI,TPI,EAName,MagicNumber,0,Red);OS=0;

         double TempPendingLotSize=NormalizeDouble(LotSize*0.625,Digits);
         if(TempPendingLotSize<MarketInfo(Symbol(),MODE_MINLOT))TempPendingLotSize=MarketInfo(Symbol(),MODE_MINLOT);
         if(TicketNrPendingSell>0 && OrderSelect(TicketNrPendingSell,SELECT_BY_POS))
           {if(OrderType()==3){bool delS=OrderDelete(TicketNrPendingSell);}TicketNrPendingSell=0;}
         else if(!OrderSelect(TicketNrPendingSell,SELECT_BY_POS) && TicketNrPendingSell>0)
           {TicketNrPendingSell=0;}
         if(TicketNrPendingSell==0)
           {TicketNrPendingSell=OrderSend(Symbol(),OP_SELLLIMIT,TempPendingLotSize,Bid+TP/2*Point,Slippage,0,Bid,EAName+"P1S",MagicNumber,0,Red);}

         double TempPendingLotSize2=NormalizeDouble(LotSize*0.5,Digits);
         if(TempPendingLotSize2<MarketInfo(Symbol(),MODE_MINLOT))TempPendingLotSize2=MarketInfo(Symbol(),MODE_MINLOT);
         if(TicketNrPendingSell2>0 && OrderSelect(TicketNrPendingSell2,SELECT_BY_POS))
           {if(OrderType()==3){bool delS2=OrderDelete(TicketNrPendingSell2);}TicketNrPendingSell2=0;}
         else if(!OrderSelect(TicketNrPendingSell2,SELECT_BY_POS) && TicketNrPendingSell2>0)
           {TicketNrPendingSell2=0;}
         if(TicketNrPendingSell2==0)
           {TicketNrPendingSell2=OrderSend(Symbol(),OP_SELLLIMIT,TempPendingLotSize2,Bid+TP/1*Point,Slippage,0,Bid,EAName+"P2S",MagicNumber,0,Red);}
        }
      // && TempTDIGreen<RSI_Down_Value && (TempTDIGreen-TempTDIRed)>=3.5
      if(OB==1 && OBC==0 && (!(AccountFreeMarginCheck(Symbol(),OP_BUY,LotSize*3)<=0 || GetLastError()==134)))
        {
         if(TP==0)TPI=0;else TPI=Ask+TP*Point;if(SL==0)SLI=0;else SLI=Ask-SL*Point;
         TicketNrBuy=OrderSend(Symbol(),OP_BUY,LotSize,Ask,Slippage,SLI,TPI,EAName,MagicNumber,0,Lime);OB=0;

         double TempPendingLotSize=NormalizeDouble(LotSize*0.625,Digits);
         if(TempPendingLotSize<MarketInfo(Symbol(),MODE_MINLOT))TempPendingLotSize=MarketInfo(Symbol(),MODE_MINLOT);
         if(TicketNrPendingBuy>0 && OrderSelect(TicketNrPendingBuy,SELECT_BY_POS))
           {if(OrderType()==2){bool delB=OrderDelete(TicketNrPendingBuy);}TicketNrPendingBuy=0;}
         else if(!OrderSelect(TicketNrPendingBuy,SELECT_BY_POS) && TicketNrPendingBuy>0)
           {TicketNrPendingBuy=0;}
         if(TicketNrPendingBuy==0)
           {TicketNrPendingBuy=OrderSend(Symbol(),OP_BUYLIMIT,TempPendingLotSize,Ask-TP/2*Point,Slippage,0,Ask,EAName+"P1B",MagicNumber,0,Red);}

         double TempPendingLotSize2=NormalizeDouble(LotSize*0.5,Digits);
         if(TempPendingLotSize2<MarketInfo(Symbol(),MODE_MINLOT))TempPendingLotSize2=MarketInfo(Symbol(),MODE_MINLOT);
         if(TicketNrPendingBuy2>0 && OrderSelect(TicketNrPendingBuy2,SELECT_BY_POS) && OrderType()==2)
           {if(OrderType()==2){bool delB2=OrderDelete(TicketNrPendingBuy2);}TicketNrPendingBuy2=0;}
         else if(!OrderSelect(TicketNrPendingBuy2,SELECT_BY_POS) && TicketNrPendingBuy2>0)
           {TicketNrPendingBuy2=0;}
         if(TicketNrPendingBuy2==0)
           {TicketNrPendingBuy2=OrderSend(Symbol(),OP_BUYLIMIT,TempPendingLotSize2,Ask-TP/1*Point,Slippage,0,Ask,EAName+"P2B",MagicNumber,0,Red);}
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
            TempProfit=TempProfit+OrderProfit();
           }
        }
     }
   CurrentProfit(TempProfit);

//not enough money message to continue the martingale
   if((TicketNrBuy<0 || TicketNrSell) && GetLastError()==134){err=1;Print("NOT ENOGUGHT MONEY!!");}
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
//add positions function
bool AddP()
  {
   int _num=0; int _ot=0;
   for(int j=0;j<OrdersTotal();j++)
     {
      if(OrderSelect(j,SELECT_BY_POS)==true && OrderSymbol()==Symbol() && OrderType()<3 && (OrderMagicNumber()==MagicNumber))
        {
         _num++;if(OrderOpenTime()>_ot) _ot=OrderOpenTime();
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
   bool fm;fm=OrderModify(OrderTicket(),OrderOpenPrice(),ldSL,OrderTakeProfit(),0,CLR_NONE);
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
      ObjectSetText("CurrentLoss","Current loss in '%: "+DoubleToString(CurrentLoss,2),11,"Calibri",clrDeepPink);
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
   if(OrderSelect(TicketNr,SELECT_BY_TICKET,MODE_TRADES))
     {
      res=OrderType();
     }
   return res;
  }
//+------------------------------------------------------------------+
