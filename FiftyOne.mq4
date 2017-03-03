//+------------------------------------------------------------------+
//|                                                     FiftyOne.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      ""
#property version   "1.00"
#property strict
//--- input parameters
input double   LotSize=0.01;
input int MagicNumber = 888;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct prices
  {
   string            timestamp; // date 
   string            symbol;
   string            period;
   string            direction;
   double            price;  // bid price 
  };
string filename="EURUSD.csv";
int file_handle= 0;
string terminal_data_path=TerminalInfoString(TERMINAL_DATA_PATH);
prices arr[];
int direction;
double pricedir;
int str_size;
string str_arr[];
string str;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
ArrayResize(str_arr,4); 
   ResetLastError();
   string sep=";";                // A separator as a character 
   ushort u_sep;  
   file_handle=FileOpen(filename,FILE_READ);

   if(file_handle!=INVALID_HANDLE)
     {
      FileReadStruct(file_handle,arr[5]);
      int size=ArraySize(arr);
      //--- print data from the array 
      for(int i=0;i<size;i++)
         Print("Date = ",arr[i].timestamp," symbol = ",arr[i].symbol," price = ",arr[i].price);
      Print("Total data = ",size);
       while(!FileIsEnding(file_handle)) 
        { 
         //--- find out how many symbols are used for writing the time 
         str_size=FileReadInteger(file_handle,INT_VALUE); 
         //--- read the string 
         str=str+FileReadString(file_handle,str_size)+";"; 
        } 
//--- print the string 
u_sep=StringGetCharacter(sep,0); 

         //PrintFormat(str); 
         str_size = StringSplit(str,sep,str_arr);
         int size=ArraySize(str_arr);
      //--- print data from the array 
      for(int i=0;i<size;i++) Print(str_arr[0]);
         //Print("Date = ",str_arr[0]," symbol = ",str_arr[1]," price = ",str_arr[2]);
     }
//--- close the file 
   FileClose(file_handle);
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

   if(ArraySize(arr)>0)
     {

      if(arr[0].direction=="BUY")
        {
         direction= OP_BUY;
         pricedir = Ask;
           } else {
         direction= OP_SELL;
         pricedir = Bid;
        }
      int totalOrders=OrdersTotal();
      if(totalOrders==0)
        {
         Print("Total Orders = 0");
         int ticket=OrderSend(Symbol(),direction,LotSize,pricedir,3,0,0,arr[0].timestamp,MagicNumber,0,Blue);
         if(ticket<0)
           {
            Print("OrderSend"+arr[0].direction+" failed with error #",GetLastError());
           }
         else Print("OrderSend"+arr[0].direction+" placed successfully");
        }
      for(int pos=0;pos<totalOrders;pos++)
        {
         bool b=OrderSelect(pos,SELECT_BY_POS,MODE_TRADES);
         if(b)
           {
            if(OrderSymbol()==Symbol())
              {
               if(OrderComment()!=arr[0].timestamp)
                 {
                  int ticket=OrderSend(Symbol(),direction,LotSize,pricedir,3,0,0,arr[0].timestamp,MagicNumber,0,Blue);
                  if(ticket<0)
                    {
                     Print("OrderSend"+arr[0].direction+" failed with error #",GetLastError());
                    }
                  else Print("OrderSend"+arr[0].direction+" placed successfully");
                 }
              }
              } else {

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
