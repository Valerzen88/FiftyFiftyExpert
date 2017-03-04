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
string filename="TradeSignal.csv";
int file_handle= 0;
string terminal_data_path=TerminalInfoString(TERMINAL_DATA_PATH);
int direction;
double pricedir;
int str_size,size;
string arr[];
string str,word;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---  
   int space,i;
   int pos[];
   ArrayResize(arr,5);

   ResetLastError();
   str="";
   file_handle=FileOpen(filename,FILE_READ|FILE_CSV);

   if(file_handle!=INVALID_HANDLE)
     {

      //--- read all data from the file to the array 
      while(!FileIsEnding(file_handle))//read file to the end by paragraph. if you have only one string, omit it
        {
         str=FileReadString(file_handle);//read one paragraph to the string variable
         if(str!="" && StringLen(str) >0)//if string not empty
           {
            space=0;
            for(i=0;i<StringLen(str);i++)
              {
               if(StringGetChar(str,i)==32)// look for spaces (32) only
                 {
                  space++;//yes, we found one more space
                  ArrayResize(pos,space);//increase array
                  pos[space-1]=i;//write the number of space position to array
                 }
              }//now we have array with numbers of positions of all spaces
            for(i=0;i<space;i++)//start to read elements of string
              {
               if(i==0) word=StringSubstr(str,0,pos[0]);//the first element of string (in your case it is 100)
               else word=StringSubstr(str,pos[i-1]+1,pos[i]-pos[i-1]-1);//the rest of elements
                                                                        //analize your word. I mean you can calculate (StrToInteger or StrToDouble), print or collect to another array
               arr[i]=word;
              }
           }
        }
     }
/*for(int i=0;i<ArraySize(arr);i++) Print(arr[i]);
         Print("Date = ",arr[0]," symbol = ",arr[1]," price = ",arr[2]);
     }*/
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

      if(arr[3]=="BUY")
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
         int ticket=OrderSend(Symbol(),direction,LotSize,pricedir,3,0,0,arr[0],MagicNumber,0,Blue);
         if(ticket<0)
           {
            Print("OrderSend"+arr[3]+" failed with error #",GetLastError());
           }
         else Print("OrderSend"+arr[3]+" placed successfully");
        }
      for(int pos=0;pos<totalOrders;pos++)
        {
         bool b=OrderSelect(pos,SELECT_BY_POS,MODE_TRADES);
         if(b)
           {
            if(OrderSymbol()==Symbol())
              {
               if(OrderComment()!=arr[0])
                 {
                  int ticket=OrderSend(Symbol(),direction,LotSize,pricedir,3,0,0,arr[0],MagicNumber,0,Blue);
                  if(ticket<0)
                    {
                     Print("OrderSend"+arr[3]+" failed with error #",GetLastError());
                    }
                  else Print("OrderSend"+arr[3]+" placed successfully");
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
