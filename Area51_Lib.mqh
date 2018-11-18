

//+------------------------------------------------------------------+
int getContractProfitCalcMode(string symbolName)
  {
   int profitCalcMode=(int)MarketInfo(symbolName,MODE_PROFITCALCMODE);
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
bool CheckStopLoss_Takeprofit(string symbolName,ENUM_ORDER_TYPE type,double SLT,double TPT)
  {
   int stops_level=(int)SymbolInfoInteger(symbolName,SYMBOL_TRADE_STOPS_LEVEL);
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
         SLT_check=(MarketInfo(symbolName,MODE_BID)-SLT>stops_level*MarketInfo(symbolName,MODE_POINT));
         if(!SLT_check)
            PrintFormat("For order %s StopLoss=%.5f must be less than %.5f"+
                        " (Bid=%.5f - SYMBOL_TRADE_STOPS_LEVEL=%d points)",
                        EnumToString(type),SLT,MarketInfo(symbolName,MODE_BID)-stops_level*MarketInfo(symbolName,MODE_POINT),MarketInfo(symbolName,MODE_BID),stops_level);
         TPT_check=(TPT-MarketInfo(symbolName,MODE_BID)>stops_level*MarketInfo(symbolName,MODE_POINT));
         if(!TPT_check)
            PrintFormat("For order %s TakeProfit=%.5f must be greater than %.5f"+
                        " (Bid=%.5f + SYMBOL_TRADE_STOPS_LEVEL=%d points)",
                        EnumToString(type),TPT,MarketInfo(symbolName,MODE_BID)+stops_level*MarketInfo(symbolName,MODE_POINT),MarketInfo(symbolName,MODE_BID),stops_level);
         return(SLT_check&&TPT_check);
        }
      case  ORDER_TYPE_SELL:
        {
         SLT_check=(SLT-MarketInfo(symbolName,MODE_ASK)>stops_level*MarketInfo(symbolName,MODE_POINT));
         if(!SLT_check)
            PrintFormat("For order %s StopLoss=%.5f must be greater than %.5f "+
                        " (Ask=%.5f + SYMBOL_TRADE_STOPS_LEVEL=%d points)",
                        EnumToString(type),SLT,MarketInfo(symbolName,MODE_ASK)+stops_level*MarketInfo(symbolName,MODE_POINT),MarketInfo(symbolName,MODE_ASK),stops_level);
         TPT_check=(MarketInfo(symbolName,MODE_ASK)-TPT>stops_level*MarketInfo(symbolName,MODE_POINT));
         if(!TPT_check)
            PrintFormat("For order %s TakeProfit=%.5f must be less than %.5f "+
                        " (Ask=%.5f - SYMBOL_TRADE_STOPS_LEVEL=%d points)",
                        EnumToString(type),TPT,MarketInfo(symbolName,MODE_ASK)-stops_level*MarketInfo(symbolName,MODE_POINT),MarketInfo(symbolName,MODE_ASK),stops_level);
         return(TPT_check&&SLT_check);
        }
      break;
     }
   return false;
  }

//+------------------------------------------------------------------+
//| Check the correctness of the order volume                        |
//+------------------------------------------------------------------+
bool CheckVolumeValue(string symbolName,double volume)
  {
//--- minimal allowed volume for trade operations
   string description="";
   double min_volume=SymbolInfoDouble(symbolName,SYMBOL_VOLUME_MIN);

   if(volume<min_volume)
     {
      PrintFormat("Volume is less than the minimal allowed SYMBOL_VOLUME_MIN=%.2f",min_volume);
      return(false);
     }

//--- maximal allowed volume of trade operations
   double max_volume=SymbolInfoDouble(symbolName,SYMBOL_VOLUME_MAX);
   if(volume>max_volume)
     {
      PrintFormat("Volume is greater than the maximal allowed SYMBOL_VOLUME_MAX=%.2f",max_volume);
      return(false);
     }

//--- get minimal step of volume changing
   double volume_step=SymbolInfoDouble(symbolName,SYMBOL_VOLUME_STEP);

   int ratio=(int)MathRound(volume/volume_step);
   if(MathAbs(ratio*volume_step-volume)>0.0000001)
     {
      Print(StringFormat("Volume is not a multiple of the minimal step SYMBOL_VOLUME_STEP=%.2f, the closest correct volume is %.2f",
            volume_step,ratio*volume_step));
      return(false);
     }
   return(true);
  }
//+-----------------------------------------------------------------+
bool NewBar()
  {
   static datetime lastbar;
   datetime curbar=Time[0];
   if(lastbar!=curbar)
     {
      lastbar=curbar;
      return(true);
     }
   else
     {
      return(false);
     }
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
int getTimeframeFromString(string timeFrameFromString)
  {
   int timeFrame=0;
   if(timeFrameFromString=="M1"){timeFrame=1;}
   if(timeFrameFromString=="M5"){timeFrame=5;}
   if(timeFrameFromString=="M15"){timeFrame=15;}
   if(timeFrameFromString=="M30"){timeFrame=30;}
   if(timeFrameFromString=="H1"){timeFrame=60;}
   if(timeFrameFromString=="H4"){timeFrame=240;}
   if(timeFrameFromString=="D1"){timeFrame=1440;}
   if(timeFrameFromString=="W1"){timeFrame=10080;}
   if(timeFrameFromString=="MN"){timeFrame=43200;}
   return (timeFrame);
  }

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
int CloseAll()
  {
   bool rv=NO_ERROR;
   int numOfOrders=OrdersTotal();
   int FirstOrderType=0;

   for(int index=0; index<OrdersTotal(); index++)

     {
      bool oS=OrderSelect(index,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
        {
         FirstOrderType=OrderType();
         break;
        }
     }

   for(int index=numOfOrders-1; index>=0; index--)

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
 int getTicketCurrentType(int TicketNr)
   {
    int result=-1;
    if(OrderSelect(TicketNr,SELECT_BY_TICKET,MODE_TRADES))
      {
       result=OrderType();
      }
    return result;
   }

//+------------------------------------------------------------------+
bool CurrentCandleHasNoOpenedTrades(string symbolName)
  {
   bool positionCanBeOpened=false;
   int currentAlreadyOpenedPositions=0;
   if(OrdersTotal()>0)
     {
      for(int cnt=0;cnt<OrdersTotal();cnt++)
        {
         if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES)==true)
           {
            if((OrderType()==OP_SELL || OrderType()==OP_BUY) && OrderSymbol()==symbolName && (OrderMagicNumber()==MagicNumber))
              {
               if(Period()==PERIOD_M1 || Period()==PERIOD_M5 || Period()==PERIOD_M15 || Period()==PERIOD_M30)
                 {
                  if(TimeMinute(Time[0])==TimeMinute(OrderOpenTime()))
                    {
                     positionCanBeOpened=false;
                       }else{
                     positionCanBeOpened=true;
                    }
                 }
               if(Period()==PERIOD_H1 || Period()==PERIOD_H4)
                 {
                  if(TimeHour(Time[0])==TimeHour(OrderOpenTime()))
                    {
                     positionCanBeOpened=false;
                       }else{
                     positionCanBeOpened=true;
                    }
                 }

               if(Period()==PERIOD_D1 || Period()==PERIOD_W1)
                 {
                  if(TimeDay(Time[0])==TimeDay(OrderOpenTime()))
                    {
                     positionCanBeOpened=false;
                       }else{
                     positionCanBeOpened=true;
                    }
                 }

               if(Period()==PERIOD_MN1)
                 {
                  if(TimeMinute(Time[0])==TimeMinute(OrderOpenTime()))
                    {
                     positionCanBeOpened=false;
                       }else{
                     positionCanBeOpened=true;
                    }
                 }
              }
           }
        }
        } else {

      positionCanBeOpened=true;
     }
   return positionCanBeOpened;
  }
