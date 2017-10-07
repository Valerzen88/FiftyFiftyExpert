//+------------------------------------------------------------------+
//|                                           Area51LittleHelper.mq4 |
//|                                           Copyright 2017, VBApps |
//|                                                                  |
//+------------------------------------------------------------------+
#define Version "1.00"
#property copyright "Copyright © 2017 VBApps::Valeri Balachnin"
#property description "Handles manually opened positions."
#property version Version
#property strict

//--- input parameters
extern static string Trading="Base trading params";
double   LotSize=0.01;
bool     LotAutoSize=true;
extern int      LotRiskPercent=25;
extern int      MoneyRiskInPercent=0;
extern static string Positions="Handle positions params";
extern int      TrailingStep=15;
extern int      DistanceStep=15;
extern int      TakeProfit=750;
extern int      StopLoss=0;

#define SLIPPAGE              5
#define NO_ERROR              1
#define AT_LEAST_ONE_FAILED   2

bool Debug=false;
bool DebugTrace=false;

string EAName="Area51 Little Helper";
int StopLevel=0;
double StopLevelDouble=MarketInfo(Symbol(),MODE_STOPLEVEL)*Point();
double CurrentLoss=0;
double TP=TakeProfit,SL=StopLoss;
int countedDecimals=2;
double CurrentTotalLotSize=0.0;
double SLI=0,TPI=0;

/*licence*/
bool trial_lic=false;
datetime expiryDate=D'2017.10.15 00:00';
bool rent_lic=false;
datetime rentExpiryDate=D'2018.06.01 00:00';
int rentAccountNumber=0;
string rentCustomerName="";
/*licence_end*/

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   if(LotSize<MarketInfo(Symbol(),MODE_MINLOT))
     {
      LotSize=MarketInfo(Symbol(),MODE_MINLOT);
     }
   if(LotSize>=MarketInfo(Symbol(),MODE_MAXLOT))
     {
      LotSize=MarketInfo(Symbol(),MODE_MAXLOT);
     }
   double lotstep=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
   countedDecimals=(int)-MathLog10(lotstep);
   if(Debug)
     {
      Print("AccountNumber="+IntegerToString(AccountNumber()));
      Print("AccountCompany="+AccountCompany());
      Print("AccountName=",AccountName());
      Print("AccountServer=",AccountServer());
      Print("MODE_LOTSIZE=",MarketInfo(Symbol(),MODE_LOTSIZE),", Symbol=",Symbol());
      Print("MODE_MINLOT=",MarketInfo(Symbol(),MODE_MINLOT),", Symbol=",Symbol());
      Print("MODE_LOTSTEP=",MarketInfo(Symbol(),MODE_LOTSTEP),", Symbol=",Symbol());
      Print("MODE_MAXLOT=",MarketInfo(Symbol(),MODE_MAXLOT),", Symbol=",Symbol());
      Print("countedDecimals="+IntegerToString(countedDecimals));
     }
   bool compareContractSizes=false;
   if(CompareDoubles(SymbolInfoDouble(Symbol(),SYMBOL_TRADE_CONTRACT_SIZE),100000.0)) {compareContractSizes=true;}
   else {compareContractSizes=false;}
   StopLevel=(int)(MarketInfo(Symbol(),MODE_STOPLEVEL)*1.3);
   int MarginMode=(int)MarketInfo(Symbol(),MODE_MARGINCALCMODE);
   if(StopLevel>0)
     {
      TrailingStep=TrailingStep+StopLevel;
      DistanceStep=DistanceStep+StopLevel;
      if(Debug){Print("TrailingStep="+IntegerToString(TrailingStep)+";DistanceStep="+IntegerToString(DistanceStep)+";StopLevel="+IntegerToString(StopLevel));}
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
      if(!IsTesting() && AccountName()==rentCustomerName && AccountNumber()==rentAccountNumber)
        {
         if(TimeCurrent()>rentExpiryDate)
           {
            Alert("Your license is expired. Please contact us.");
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
            return(INIT_FAILED);
           }
        }
     }
   //double LotSizeTesting = MarketInfo(Symbol(),MODE_MINLOT)*35;
   //if(CheckMoneyForTrade(Symbol(), LotSizeTesting, OP_BUY)) { bool c=OrderSend(Symbol(),OP_BUY,LotSizeTesting,Ask,3,0,0);}
   //if(CheckMoneyForTrade(Symbol(), LotSizeTesting, OP_SELL)) { bool h=OrderSend(Symbol(),OP_SELL,LotSizeTesting,Bid,3,0,0);}
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
   HandleUserPositionsFun();
   //risk management
   double SymbolStep=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP);
   int MarginMode=(int)MarketInfo(Symbol(),MODE_MARGINCALCMODE);
   bool compareContractSizes=false;
   if(CompareDoubles(SymbolInfoDouble(Symbol(),SYMBOL_TRADE_CONTRACT_SIZE),100000.0)) {compareContractSizes=true;}
   else {compareContractSizes=false;}
   double RemainingLotSize=0.0;
   int countRemainingMaxLots=0;
   bool LotSizeIsBiggerThenMaxLot=false;
   double MaxLot=MarketInfo(Symbol(),MODE_MAXLOT);
   if(SymbolStep>0.0)
     {
      MaxLot=NormalizeDouble(MaxLot-MathMod(MaxLot,SymbolStep),countedDecimals);
     }

   if(LotAutoSize)
     {
      int Faktor=100;
      if(LotRiskPercent<0.1 || LotRiskPercent>1000){Comment("Invalid Risk Value.");}
      else
        {
         if(getContractProfitCalcMode()==0 || (MarginMode==0 && compareContractSizes))
           {
            //Print("Fall1:"+(MarginMode==0 && compareContractSizes));
            LotSize=NormalizeDouble(MathFloor((AccountFreeMargin()*AccountLeverage()*LotRiskPercent*Point*Faktor)/
                                    (Ask*MarketInfo(Symbol(),MODE_LOTSIZE)*MarketInfo(Symbol(),MODE_MINLOT)))*MarketInfo(Symbol(),MODE_MINLOT),countedDecimals);
           }
         else if((getContractProfitCalcMode()==1 || getContractProfitCalcMode()==2 || MarginMode==4) && (compareContractSizes==false))
           {
            //Print("Fall2:"+((getContractProfitCalcMode()==1 || getContractProfitCalcMode()==2 || MarginMode==4) && (compareContractSizes==false)));
            if(SymbolInfoDouble(Symbol(),SYMBOL_TRADE_CONTRACT_SIZE)==1.0){countedDecimals=0;}
            int Splitter=1000;
            if(getContractProfitCalcMode()==1){Splitter=100000;}
            if(MarginMode==4 && MarketInfo(Symbol(),MODE_TICKSIZE)==0.001){Splitter=1000000;}
            if(Digits==3){Faktor=1;}
            if(Digits==2){Faktor=10;}
            LotSize=NormalizeDouble(MathFloor((AccountFreeMargin()*AccountLeverage()*LotRiskPercent*Faktor*Point)/
                                    (Ask*MarketInfo(Symbol(),MODE_TICKSIZE)*MarketInfo(Symbol(),MODE_MINLOT)))*MarketInfo(Symbol(),MODE_MINLOT)/Splitter,countedDecimals);
            if(SymbolStep>0.0)
              {
               LotSize=LotSize-MathMod(LotSize,SymbolStep);
              }
              } else {
            Print("Cannot calculate the right auto lot size!");
            LotSize=MarketInfo(Symbol(),MODE_MINLOT);
           }
        }
     }
   if(LotAutoSize==false){LotSize=LotSize;}
   if(LotSize<MarketInfo(Symbol(),MODE_MINLOT))
     {
      LotSize=MarketInfo(Symbol(),MODE_MINLOT);
      if(SymbolStep>0.0)
        {
         LotSize=NormalizeDouble(LotSize-MathMod(LotSize,SymbolStep),countedDecimals);
        }
     }
   if(LotSize>MaxLot)
     {
      countRemainingMaxLots=(int)(LotSize/MaxLot);
      RemainingLotSize=MathMod(LotSize,MaxLot);
      LotSizeIsBiggerThenMaxLot=true;
      CurrentTotalLotSize=LotSize;
      LotSize=MarketInfo(Symbol(),MODE_MAXLOT);
      if(SymbolStep>0.0)
        {
         LotSize=NormalizeDouble(LotSize-MathMod(LotSize,SymbolStep),countedDecimals);
        }
     }

   if(Debug)
     {
      Print("LotSize="+DoubleToStr(LotSize,countedDecimals));
     }

//Money Management
   double TempLoss=0;
   for(int j=0;j<OrdersTotal();j++)
     {
      if(OrderSelect(j,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol()==Symbol())
           {
            TempLoss=TempLoss+OrderProfit();
           }
        }
     }
   if(AccountBalance()>0)
     {
      CurrentLoss=NormalizeDouble((TempLoss/AccountBalance())*100,2);
     }
   if(MoneyRiskInPercent>0 && StrToInteger(DoubleToStr(MathAbs(CurrentLoss),0))>MoneyRiskInPercent)
     {
      while(CloseAll()==AT_LEAST_ONE_FAILED)
        {
         Sleep(1000);
         Print("Order close failed - retrying error: #"+IntegerToString(GetLastError()));
        }
     }

   double TempProfit=0;
   double TempProfitUserPosis=0.0;
   for(int ff=0;ff<OrdersTotal();ff++)
     {
      if(OrderSelect(ff,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol()==Symbol() && (OrderComment()=="" || OrderComment()=="[0]") && OrderMagicNumber()==0)
           {
            TrP();
           }
        }
     }
   for(int f=0;f<OrdersTotal();f++)
     {
      if(OrderSelect(f,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol()==Symbol() && (OrderComment()=="" || OrderComment()=="[0]") && OrderMagicNumber()==0)
           {
            TempProfitUserPosis=TempProfitUserPosis+OrderProfit()+OrderCommission()+OrderSwap();
           }
        }
     }
   CurrentProfit(TempProfit,TempProfitUserPosis);   
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void HandleUserPositionsFun()
  {
   for(int j=0;j<OrdersTotal();j++)
     {
      if(OrderSelect(j,SELECT_BY_POS)==true && OrderSymbol()==Symbol())
        {
         if(Debug){Print("OrderComment='"+OrderComment()+"'");}
         if(Debug){Print("OrderMagicNumber='"+IntegerToString(OrderMagicNumber())+"'");}
         if(OrderMagicNumber()==0 && (OrderComment()=="" || OrderComment()=="[0]"))
           {
            if((OrderType()==OP_SELL) && (((OrderOpenPrice()-OrderTakeProfit())!=TakeProfit*Point)
               || ((OrderStopLoss()>OrderOpenPrice()) || OrderStopLoss()==0)))
              {
               if(TP==0)TPI=0;else TPI=OrderOpenPrice()-TP*Point;if(SL==0)SLI=OrderOpenPrice()+10000*Point;else SLI=OrderOpenPrice()+SL*Point;
               if(OrderModifyCheck(OrderTicket(),OrderOpenPrice(),SLI,TPI) && CheckStopLoss_Takeprofit(ORDER_TYPE_SELL,SLI,TPI))
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
                  if(OrderModifyCheck(OrderTicket(),OrderOpenPrice(),SLI,TPI) && CheckStopLoss_Takeprofit(ORDER_TYPE_BUY,SLI,TPI))
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
//trailing stop and breakeven
void TrP()
  {
   int BE=0;int TS=DistanceStep;double pbid,pask,ppoint;ppoint=MarketInfo(OrderSymbol(),MODE_POINT);
   double commissions=OrderCommission()+OrderSwap();
   double commissionsInPips;
   double tickValue=MarketInfo(Symbol(),MODE_TICKVALUE);
   if(Debug) {Print("tickValue="+DoubleToStr(tickValue,5));}
   if(tickValue==0) {tickValue=0.9;}
   double spread=Ask-Bid;
   double tickSize=MarketInfo(Symbol(),MODE_TICKSIZE);
   if(Debug) {Print("commissions="+DoubleToStr(commissions,8));}
   commissionsInPips=((commissions/OrderLots()/tickValue)*tickSize)+(spread*2);
   if(Debug){Print("commissionsInPips="+DoubleToStr(commissionsInPips));}
   if(commissionsInPips<0){commissionsInPips=commissionsInPips-(commissionsInPips*2);}
   if(DebugTrace)
     {
      Print("commissionsInPips(Ticket="+IntegerToString(OrderTicket())+")="+DoubleToStr(commissionsInPips,5)
            +";DistanceStep="+IntegerToString(TS)+";TrailingStep="+IntegerToString(TrailingStep));
     }
   if(OrderType()==OP_BUY)
     {
      pbid=MarketInfo(OrderSymbol(),MODE_BID);
      if(BE>0)
        {
         if((pbid-OrderOpenPrice())>BE*ppoint)
           {
            if((OrderStopLoss()-OrderOpenPrice())<0)
              {
               if(Debug){Print("Fall1");}
               ModSL(OrderOpenPrice()+0*ppoint+commissionsInPips);
              }
           }
        }
      if(TS>0)
        {
         if((pbid-OrderOpenPrice())>TS*ppoint)
           {
            if(OrderStopLoss()<(pbid-((TS+TrailingStep-1)*ppoint+commissionsInPips+StopLevelDouble*1.3)))
              {
               if((pbid-((TS+TrailingStep-1)*ppoint+commissionsInPips+StopLevelDouble*1.3))>OrderOpenPrice())
                 {
                  if(Debug)
                    {
                     Print("Fall2: "+"Ask="+DoubleToStr(pbid,5)+";TS="+IntegerToString(TS)+
                           ";commissionInPips="+DoubleToStr(commissionsInPips,5));
                    }
                  if(pbid>pbid-(TS*ppoint+commissionsInPips+StopLevelDouble*1.3))
                    {
                     ModSL(pbid-(TS*ppoint+commissionsInPips+StopLevelDouble*1.3));
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
               ModSL(OrderOpenPrice()-0*ppoint-commissionsInPips);
              }
           }
        }
      if(TS>0)
        {
         if(OrderOpenPrice()-pask>TS*ppoint)
           {
            if(OrderStopLoss()>(pask+((TS+TrailingStep-1)*ppoint+commissionsInPips+StopLevelDouble*1.3)) || OrderStopLoss()==0)
              {
               if((pask+((TS+TrailingStep-1)*ppoint+commissionsInPips+StopLevelDouble*1.3))<OrderOpenPrice())
                 {
                  if(Debug)
                    {
                     Print("Fall4: "+"Ask="+DoubleToStr(pask,5)+";TS="+IntegerToString(TS)+
                           ";commissionInPips="+DoubleToStr(commissionsInPips,5));
                    }
                  if(pask<pask+(TS*ppoint+commissionsInPips+StopLevelDouble*1.3))
                    {
                     ModSL(pask+(TS*ppoint+commissionsInPips+StopLevelDouble*1.3));
                    }
                 }
               return;
              }
           }
        }
     }
  }
//stop loss modification function
void ModSL(double ldSL)
  {
   if(Debug)
     {
      Print("ldSL="+DoubleToStr(ldSL,5));
     }
   if(OrderModifyCheck(OrderTicket(),OrderOpenPrice(),ldSL,OrderTakeProfit()))
     {
      if(OrderType()==OP_BUY)
        {
         if(CheckStopLoss_Takeprofit(ORDER_TYPE_BUY,ldSL,OrderTakeProfit()))
           {
            bool fm;fm=OrderModify(OrderTicket(),OrderOpenPrice(),ldSL,OrderTakeProfit(),0,CLR_NONE);
           }
        }
      if(OrderType()==OP_SELL)
        {
         if(CheckStopLoss_Takeprofit(ORDER_TYPE_SELL,ldSL,OrderTakeProfit()))
           {
            bool fm;fm=OrderModify(OrderTicket(),OrderOpenPrice(),ldSL,OrderTakeProfit(),0,CLR_NONE);
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CurrentProfit(double CurProfit,double CurProfitOfUserPosis)
  {
   ObjectCreate("EAName",OBJ_LABEL,0,0,0);
   ObjectSetText("EAName",EAName + " V. " + Version,11,"Calibri",clrGold);
   ObjectSet("EAName",OBJPROP_CORNER,1);
   ObjectSet("EAName",OBJPROP_XDISTANCE,5);
   ObjectSet("EAName",OBJPROP_YDISTANCE,55);

   ObjectCreate("CurProfitOfManualPlacedUserPositions",OBJ_LABEL,0,0,0);
   if(CurProfitOfUserPosis>=0.0)
     {
      ObjectSetText("CurProfitOfManualPlacedUserPositions",
                    "Current profit: "+DoubleToString(CurProfitOfUserPosis,2)+" "+AccountCurrency(),11,"Calibri",clrLime);
        }else{ObjectSetText("CurProfitOfManualPlacedUserPositions",
                              "Current profit: "+DoubleToString(CurProfitOfUserPosis,2)+" "+AccountCurrency(),11,"Calibri",clrOrangeRed);
     }
   ObjectSet("CurProfitOfManualPlacedUserPositions",OBJPROP_CORNER,1);
   ObjectSet("CurProfitOfManualPlacedUserPositions",OBJPROP_XDISTANCE,5);
   ObjectSet("CurProfitOfManualPlacedUserPositions",OBJPROP_YDISTANCE,120);

   ObjectCreate("NextLotSize",OBJ_LABEL,0,0,0);
   if(CurrentTotalLotSize>0.0)
     {ObjectSetText("NextLotSize","Recomended Lot size: "+DoubleToString(CurrentTotalLotSize,2),11,"Calibri",clrLightYellow);}
   else {ObjectSetText("NextLotSize","Recomended Lot size: "+DoubleToString(LotSize,2),11,"Calibri",clrLightYellow);}
   ObjectSet("NextLotSize",OBJPROP_CORNER,1);
   ObjectSet("NextLotSize",OBJPROP_XDISTANCE,5);
   ObjectSet("NextLotSize",OBJPROP_YDISTANCE,80);

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
int CloseAll()
  {
   bool rv=NO_ERROR;
   int numOfOrders=OrdersTotal();
   int FirstOrderType=0;

   for(int index=0; index<OrdersTotal(); index++)
     {
      bool oS=OrderSelect(index,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()==Symbol())
        {
         FirstOrderType=OrderType();
         break;
        }
     }

   for(int index=numOfOrders-1; index>=0; index--)
     {
      bool oS=OrderSelect(index,SELECT_BY_POS,MODE_TRADES);

      if(OrderSymbol()==Symbol())
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
      //--- Die Größe des Punktes und des Symbol-Namens, nach dem die Pending Order gesetzt wurde
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
bool CheckStopLoss_Takeprofit(ENUM_ORDER_TYPE type,double SLT,double TPT)
  {
   int stops_level=(int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);
   if(stops_level!=0)
     {
      PrintFormat("SYMBOL_TRADE_STOPS_LEVEL=%d: StopLoss and TakeProfit must be"+
                  " less %d points from close price",stops_level,stops_level);
     }
   bool SLT_check=false,TPT_check=false;
   switch(type)
     {
      case  ORDER_TYPE_BUY:
        {
         SLT_check=(Bid-SLT>stops_level*_Point);
         if(!SLT_check)
            PrintFormat("For order %s StopLoss=%.5f must be less than %.5f"+
                        " (Bid=%.5f - SYMBOL_TRADE_STOPS_LEVEL=%d points)",
                        EnumToString(type),SLT,Bid-stops_level*_Point,Bid,stops_level);
         TPT_check=(TPT-Bid>stops_level*_Point);
         if(!TPT_check)
            PrintFormat("For order %s TakeProfit=%.5f must be greater than %.5f"+
                        " (Bid=%.5f + SYMBOL_TRADE_STOPS_LEVEL=%d points)",
                        EnumToString(type),TPT,Bid+stops_level*_Point,Bid,stops_level);
         return(SLT_check&&TPT_check);
        }
      case  ORDER_TYPE_SELL:
        {
         SLT_check=(SLT-Ask>stops_level*_Point);
         if(!SLT_check)
            PrintFormat("For order %s StopLoss=%.5f must be greater than %.5f "+
                        " (Ask=%.5f + SYMBOL_TRADE_STOPS_LEVEL=%d points)",
                        EnumToString(type),SLT,Ask+stops_level*_Point,Ask,stops_level);
         TPT_check=(Ask-TPT>stops_level*_Point);
         if(!TPT_check)
            PrintFormat("For order %s TakeProfit=%.5f must be less than %.5f "+
                        " (Ask=%.5f - SYMBOL_TRADE_STOPS_LEVEL=%d points)",
                        EnumToString(type),TPT,Ask-stops_level*_Point,Ask,stops_level);
         return(TPT_check&&SLT_check);
        }
      break;
     }
   return false;
  }
//+------------------------------------------------------------------+
