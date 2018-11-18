//+------------------------------------------------------------------+
//|                                                 AreaFiftyOne.mq4 |
//|                                                           VBApps |
//|                                                 http://vbapps.co |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2018 VBApps::Valeri Balachnin"
#property version   "1.0"
#property description "Utility for."
#property strict

#include "Area51_Lib.mqh"

//--- input parameters
extern static string Trading="Base trading params";
extern double   LotSize=0.01;
//extern static string LotAutoSize_Comment="Available in the full version!";
//extern static string LotRiskPercent_Comment="Available in the full version!";
//extern static string MoneyRiskInPercent_Comment="Available in the full version!";
extern bool     LotAutoSize=false;
extern int      LotRiskPercent=25;
extern static string MoneyManagement="Set MM settings here";
extern int      MoneyRiskInPercent=0;
extern double   MaxDynamicLotSize=0.0;
extern int      MaxMoneyValueToLose=0;
extern static string Positions="Handle positions params";
extern int      TrailingStep=15;
extern int      DistanceStep=15;
extern int      TakeProfit=750;
extern int      StopLoss=0;
extern int      MinAmount=150;
extern int      SetSLToMinAmountUnder=100;
extern int      MaxSpread=25;
extern static string TradeAllSymbolsFromOneChart="Trade the choosen strategy on all available FX symbols";
extern bool     TradeOnAllSymbols=false;
extern bool     TradeOnlyListOfSelectedSymbols=false;
extern string   ListOfSelectedSymbols="EURUSD;USDJPY;GBPUSD";
extern string   ListOfSelectedTimeframesForSymbols="H1;H4;D1";
extern bool     TradeFromSignalToSignal=false;
extern static string OrderHandling="-------------------";
extern bool     openReverseOrders=false;
extern int      MaxPositions=5;
extern double   MultipleFaktor=1.7;
extern static string UsingEAOnDifferentTimeframes="-------------------";
extern int      MagicNumber=513537;


extern bool Debug=false;
extern bool DebugTrace=false;

/*licence*/
bool trial_lic=false;
datetime expiryDate=D'2018.12.01 00:00';
bool rent_lic=false;
datetime rentExpiryDate=D'2019.12.01 00:00';
int rentAccountNumber=0;
string rentCustomerName="";
/*licence_end*/

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
int Slippage=3,BreakEven=0;
int TicketNrSell=0,TicketNrBuy=0;
double CurrentLoss=0;
double TP=TakeProfit,SL=StopLoss;
double SLI=0,TPI=0;
int numBars=0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
     setAllForTradeAvailableSymbols();
     setTradeVarsValues();
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
             return(INIT_FAILED);
            }
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

    }

//+------------------------------------------------------------------+
void OpenPosition() {



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
            if(LotRiskPercent<0.1 || LotRiskPercent>1000){Comment("Invalid Risk Value.");}
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
