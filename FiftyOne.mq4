//+------------------------------------------------------------------+
//|                                                     FiftyOne.mq4 |
//|                        Copyright 2017, VBApps, Valeri Balachnin |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, VBApps, Valeri Balachnin"
#property link      ""
#property version   "1.00"
#property strict
//--- input parameters
input double LotSize=0.01;
input int MagicNumber=888;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string filename="TradeSignal.csv";
int file_handle= 0;
string terminal_data_path=TerminalInfoString(TERMINAL_DATA_PATH);
int direction;
double pricedir,closepricedir;
int str_size,size;
string arr[];
string str,word;
int ticket=0;
int oldTicket=0;
int space;
int pos[];
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
   ArrayResize(arr,7);
   double iVal=iCustom(Symbol(),Period(),"TDI",13,MODE_SMA,34,2,MODE_SMA,7,MODE_SMA,true,LotSize,6,0);
   ResetLastError();
   str="";
   file_handle= 0;
   file_handle=FileOpen(filename,FILE_READ|FILE_CSV|FILE_SHARE_READ|FILE_SHARE_WRITE);

   if(file_handle!=INVALID_HANDLE)
     {
      //--- read all data from the file to the array 
      while(!FileIsEnding(file_handle))//read file to the end by paragraph. if you have only one string, omit it
        {
         str=FileReadString(file_handle);//read one paragraph to the string variable
         if(str!="" && StringLen(str) >0)//if string not empty
           {
            space=0;
            for(int i=0;i<StringLen(str);i++)
              {
               if(StringGetChar(str,i)==32)// look for spaces (32) only
                 {
                  space++;//yes, we found one more space
                  ArrayResize(pos,space);//increase array
                  pos[space-1]=i;//write the number of space position to array
                 }
              }//now we have array with numbers of positions of all spaces
            if(space>0)
              {
               for(int i=0;i<space;i++)//start to read elements of string
                 {
                  if(i==0) word=StringSubstr(str,0,pos[0]);//the first element of string (in your case it is 100)
                  else word=StringSubstr(str,pos[i-1]+1,pos[i]-pos[i-1]-1);//the rest of elements
                  arr[i]=word;
                 }
              }
           }
        }
     }
//--- close the file 
   FileClose(file_handle);
   if(ArraySize(arr)>0)
     {

      if(arr[3]=="BUY")
        {
         direction= OP_BUY;
         pricedir = Ask;
         closepricedir=Bid;
           } else {
         direction= OP_SELL;
         pricedir = Bid;
         closepricedir=Ask;
        }
      int totalOrders=OrdersTotal();

      if(totalOrders==0)
        {
         //Print("Total Orders = 0");
         if(StringLen(arr[0])>0)
           {
            ticket=OrderSend(Symbol(),direction,LotSize,pricedir,3,0,0,arr[0],MagicNumber,0,Blue);
            if(ticket<0)
              {
               Print("OrderSend"+arr[3]+" failed with error #",GetLastError());
              }
            else Print("OrderSend"+arr[3]+" placed successfully");
           }

        }
      for(int pos1=0;pos1<totalOrders;pos1++)
        {
         bool b=OrderSelect(pos1,SELECT_BY_POS,MODE_TRADES);
         if(b)
           {
            if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=MagicNumber) continue;
            if(OrderSymbol()==Symbol() && StringLen(arr[0]) > 0)
              {
               //check StringCompare for if
               //Print(OrderComment());
               //Print(arr[0]);
               //Print(StringToInteger(OrderComment())!=StringToInteger(arr[0]));
               if(StringToInteger(OrderComment())!=StringToInteger(arr[0]))
                 {
                  ticket=OrderSend(Symbol(),direction,LotSize,pricedir,3,0,0,arr[0],MagicNumber,0,Blue);
                  bool closedOrder = false;

                  for(int pos10=0;pos10<totalOrders;pos10++)
                    {
                     bool b0=OrderSelect(pos10,SELECT_BY_POS,MODE_TRADES);
                     if(b0)
                       {
                        if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=MagicNumber) continue;
                        if(OrderSymbol()==Symbol())
                          {
                           //check StringCompare for if
                           /*Print(OrderComment());
                           Print(arr[5]);
                           Print(OrderComment()==arr[5]);*/
                           if(StringToInteger(OrderComment())==StringToInteger(arr[5]))
                             {
                             while(closedOrder != true)
                               {
                                closedOrder=OrderClose(OrderTicket(),LotSize,closepricedir,10,Red);
                               }
                              
                              if(closedOrder) Print("OrderClose "+IntegerToString(OrderTicket())+" closed successfully");
                              else
                                {
                                 Print("OrderClose "+IntegerToString(OrderTicket())+" failed to close with error#",GetLastError());
                                 //bool closedOrder2=OrderClose(OrderTicket(),LotSize,closepricedir,3,Red);
                                }
                             }
                          }
                       }
                    }
                  if(ticket<0)
                    {
                     Print("OrderSend"+arr[3]+" failed with error #",GetLastError());
                     //ticket=OrderSend(Symbol(),direction,LotSize,pricedir,3,0,0,arr[0],MagicNumber,0,Blue);
                    }
                  else
                    {
                     Print("OrderSend"+arr[3]+" placed successfully");
                    }
                 }
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
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
