//+------------------------------------------------------------------+
//|                                                 AreaFiftyOne.mq4 |
//|                                                           VBApps |
//|                         http://dax-trading-group.de/AreaFiftyOne |
//+------------------------------------------------------------------+
#property copyright "VBApps, 2017"
#property link      "http://dax-trading-group.de/AreaFiftyOne"
#property version   "1.0"
#property description "Trades on oversold or overbought market till the next signal."
#property strict

#resource "\\Indicators\\AreaFiftyOneIndicator.ex4"

//--- input parameters
extern double   LotSize=0.01;
extern bool     LotAutoSize=true;
extern int      RiskPercent=50;
extern int      TrailingStep=150;
extern int      DistanceStep=150;
extern int      MagicNumber=3537;

int RSI_Period=13;         //8-25
int RSI_Price=5;           //0-6
int Volatility_Band=34;    //20-40
int RSI_Price_Line=0;
int RSI_Price_Type=MODE_SMA;      //0-3
int Trade_Signal_Line=7;
int Trade_Signal_Line2=18;
int Trade_Signal_Type=MODE_SMA;   //0-3
int Slippage=3,MaxOrders=3,BreakEven=0;
int TicketNrPending=0,TicketNrPending2=0,TicketNr=0;
bool AddPositions=false;
double RSI_Top_Value=65;
double RSI_Down_Value=35;
double TP=750,SL=0;
double SLI=0,TPI=0;
string EAName="AreaFiftyOne";
string IndicatorName="AreaFiftyOneIndicator";
double CurrBid=0;
double CurrAsk=0;
int handle_ind;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   string path=GetRelativeProgramPath();
   handle_ind=iCustom(Symbol(),0,path+"::Indicators\\"+IndicatorName+".ex4",0,0);
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

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   int limit=1,err=0,BuyFlag=0,SellFlag=0;
   bool BUY=false,SELL=false;
   double TempTDIGreen=0,TempTDIRed=0;
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
      if((TDIGreen>65) && (NormalizeDouble(TDIGreen,3)>NormalizeDouble(TDIRed,3)) && (NormalizeDouble(NormalizeDouble(TDIGreen,3)-NormalizeDouble(TDIRed,3),1)>=3.5)) SELL=true;
      if((TDIRed<35) && (NormalizeDouble(TDIGreen,3)<NormalizeDouble(TDIRed,3)) && (NormalizeDouble(NormalizeDouble(TDIRed,3)-NormalizeDouble(TDIGreen,3),1)>=3.5)) BUY=true;

      //if((SELL==false && BUY ==false) && (TDIRed>TDIGreen) && (TDIRedPlusOne<=TDIGreenPlusOne) && (TDIGreen-TDIRed)>=3.5)BUY=true;
      //if((SELL==false && BUY ==false) && (TDIRed<TDIGreen) && (TDIRedPlusOne>=TDIGreenPlusOne) && (TDIGreen-TDIRed)>=3.5)SELL=true;
      /*if(SELL==false && BUY==false)
        {
         if((TDIGreen-TDIRed)>=3.5)
           {
           Print(TDIGreen);
           Print(TDIRed);
            string TSRed=DoubleToStr(TDIRed);
            string TSGreen=DoubleToStr(TDIGreen);
            string TSYellow=DoubleToStr(TDIYellow);
            StringReplace(TSRed,".","");
            StringReplace(TSGreen,".","");
            StringReplace(TSYellow,".","");
            int TRed=StrToInteger(TSRed);
            int TGreen=StrToInteger(TSGreen);
            int TYellow=StrToInteger(TSYellow);
            Print(TGreen>RSI_Top_Value);
            Print(TRed>TGreen);
            if(TDIGreen<TRed && TGreen>65 && TGreen>TYellow)
              {
               TempTDIGreen=TDIGreen;TempTDIRed=TDIRed;
               SELL=true;SellFlag=1;break;
              }
            if(TGreen>TRed && TGreen<35 && TGreen<TYellow) 
              {
               TempTDIGreen=TDIGreen;TempTDIRed=TDIRed;
               BUY=true;BuyFlag=1;break;
              }
           }
        }*/

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
      if(RiskPercent<0.1 || RiskPercent>100){Comment("Invalid Risk Value.");}
      else
        {
         LotSize=MathFloor((AccountFreeMargin()*AccountLeverage()*RiskPercent*Point*100)/(Ask*MarketInfo(Symbol(),MODE_LOTSIZE)*
                           MarketInfo(Symbol(),MODE_MINLOT)))*MarketInfo(Symbol(),MODE_MINLOT);
         if(LotSize<MarketInfo(Symbol(),MODE_MINLOT)) LotSize=MarketInfo(Symbol(),MODE_MINLOT);
        }
     }
   if(LotAutoSize==false){LotSize=LotSize;}

//positions initialization
   int cnt=0,OP=0,OS=0,OB=0,CloseSell=0,OSC=0,OBC=0,CloseBuy=0;OP=0;
   for(cnt=0;cnt<OrdersTotal();cnt++)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
      if((OrderType()==OP_SELL || OrderType()==OP_BUY) && OrderSymbol()==Symbol() && ((OrderMagicNumber()==MagicNumber) || MagicNumber==0))
        {
         OP=OP+1;
         if(OrderType()==OP_SELL)OSC=OSC+1;
         if(OrderType()==OP_BUY)OBC=OBC+1;
        }
     }
   if(OP>=1){OS=0;OB=0;}OB=0;OS=0;CloseBuy=0;CloseSell=0;

//entry conditions verification
   if(SellFlag>0){OS=1;OB=0;}if(BuyFlag>0){OB=1;OS=0;}

//conditions to close positions
   if(SellFlag>0){CloseBuy=1;}
   if(BuyFlag>0){CloseSell=1;}

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
         (TicketNrPending>0 || TicketNrPending2>0) && 
         (OrderMagicNumber()==MagicNumber || MagicNumber==0) && TicketNr>0 && OrderTicket()==TicketNr)
        {
         bool found=false,found2=false;
         for(int cnt0=0;cnt0<OrdersHistoryTotal();cnt0++)
           {
            if(OrderTicket()==TicketNrPending)
              {
               found=true;break;
                 }else if(OrderTicket()==TicketNrPending2) {
               found2=true;break;
              }
           }
         if(found==false)if(!OrderDelete(TicketNrPending,clrNONE))OrderDelete(TicketNrPending,clrNONE);
         if(found==false)TicketNrPending=0;
         if(found2==false)if(!OrderDelete(TicketNrPending2,clrNONE))OrderDelete(TicketNrPending2,clrNONE);
         if(found2==false)TicketNrPending2=0;
        }
     }

//open position
   if((AddP() && AddPositions && OP<=MaxOrders) || (OP==0 && !AddPositions))
     {
      // && TempTDIGreen>RSI_Top_Value && (TempTDIGreen-TempTDIRed)>=3.5
      if(OS==1)
        {
         if(TP==0)TPI=0;else TPI=Bid-TP*Point;if(SL==0)SLI=0;else SLI=Bid+SL*Point;
         TicketNr=OrderSend(Symbol(),OP_SELL,LotSize,Bid,Slippage,SLI,TPI,EAName,MagicNumber,0,Red);OS=0;
         //if(TicketNr==-1)OrderSend(Symbol(),OP_SELL,LotSize,Bid,Slippage,SLI,TPI,EAName,MagicNumber,0,Red);
         double TempPendingLotSize=NormalizeDouble(LotSize*0.625,Digits);
         if(TempPendingLotSize<MarketInfo(Symbol(),MODE_MINLOT))TempPendingLotSize=LotSize;
         TicketNrPending=OrderSend(Symbol(),OP_SELLLIMIT,TempPendingLotSize,Bid+TP/2*Point,Slippage,SLI,Bid,EAName+"P1S",MagicNumber,0,Red);
         //if(TicketNrPending==-1)OrderSend(Symbol(),OP_SELLLIMIT,TempPendingLotSize,Bid+TP/2*Point,Slippage,SLI,Bid,EAName+"P1S",MagicNumber,0,Red);

         double TempPendingLotSize2=NormalizeDouble(LotSize*0.250,Digits);
         if(TempPendingLotSize2<MarketInfo(Symbol(),MODE_MINLOT))TempPendingLotSize2=LotSize;
         TicketNrPending2=OrderSend(Symbol(),OP_SELLLIMIT,TempPendingLotSize2,Bid+TP*Point,Slippage,SLI,Bid,EAName+"P2S",MagicNumber,0,Red);
         // if(TicketNrPending2==-1)OrderSend(Symbol(),OP_SELLLIMIT,TempPendingLotSize2,Bid+TP*Point,Slippage,SLI,Bid,EAName+"P2S",MagicNumber,0,Red);
        }
      // && TempTDIGreen<RSI_Down_Value && (TempTDIGreen-TempTDIRed)>=3.5
      if(OB==1)
        {
         if(TP==0)TPI=0;else TPI=Ask+TP*Point;if(SL==0)SLI=0;else SLI=Ask-SL*Point;
         TicketNr=OrderSend(Symbol(),OP_BUY,LotSize,Ask,Slippage,SLI,TPI,EAName,MagicNumber,0,Lime);OB=0;
         //if(TicketNr==-1)OrderSend(Symbol(),OP_BUY,LotSize,Ask,Slippage,SLI,TPI,EAName,MagicNumber,0,Lime);

         double TempPendingLotSize=NormalizeDouble(LotSize*0.625,Digits);
         if(TempPendingLotSize<MarketInfo(Symbol(),MODE_MINLOT))TempPendingLotSize=LotSize;
         TicketNrPending=OrderSend(Symbol(),OP_BUYLIMIT,TempPendingLotSize,Bid-TP/2*Point,Slippage,SLI,Bid,EAName+"P1B",MagicNumber,0,Red);
         //if(TicketNrPending==-1)OrderSend(Symbol(),OP_BUYLIMIT,TempPendingLotSize,Bid-TP/2*Point,Slippage,SLI,Bid,EAName+"P1B",MagicNumber,0,Red);

         double TempPendingLotSize2=NormalizeDouble(LotSize*0.250,Digits);
         if(TempPendingLotSize2<MarketInfo(Symbol(),MODE_MINLOT))TempPendingLotSize2=LotSize;
         TicketNrPending2=OrderSend(Symbol(),OP_BUYLIMIT,TempPendingLotSize2,Bid-TP*Point,Slippage,SLI,Bid,EAName+"P2B",MagicNumber,0,Red);
         //if(TicketNrPending2==-1)OrderSend(Symbol(),OP_BUYLIMIT,TempPendingLotSize2,Bid-TP*Point,Slippage,SLI,Bid,EAName+"P2B",MagicNumber,0,Red);
        }
     }
   double TempProfit=0;
   for(int j=0;j<OrdersTotal();j++)
     {
      if(OrderSelect(j,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol()==Symbol() && ((OrderMagicNumber()==MagicNumber) || MagicNumber==0))
           {
            TrP();
            TempProfit=TempProfit+OrderProfit();
           }
        }
     }
   CurrentProfit(TempProfit);

//not enough money message to continue the martingale
   if(TicketNr<0 && GetLastError()==134){err=1;Print("NOT ENOGUGHT MONEY!!");}
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
      if(OrderSelect(j,SELECT_BY_POS)==true && OrderSymbol()==Symbol() && OrderType()<3 && ((OrderMagicNumber()==MagicNumber) || MagicNumber==0))
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
   ObjectSet("CurProfit",OBJPROP_CORNER,0);
   ObjectSet("CurProfit",OBJPROP_XDISTANCE,5);
   ObjectSet("CurProfit",OBJPROP_YDISTANCE,20);
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
//--- if this is a resource, return the path relative to MQL5 directory
   if(StringFind(path,"::",pos)>=0)
      return(StringSubstr(path,pos));
//--- find a separator for the first MQL5 subdirectory (for example, MQL5\Indicators)
//--- if not found, return the path relative to MQL5 directory
   if((pos2=StringFind(path,"\\",pos+1))<0)
      return(StringSubstr(path,pos));
//--- return the path relative to the subdirectory (for example, MQL5\Indicators)
   return(StringSubstr(path,pos2+1));
  }
//+------------------------------------------------------------------+
