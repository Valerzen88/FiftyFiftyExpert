//+------------------------------------------------------------------+
//|                                               AreaFiftyOne_Trend |
//|                                           Copyright 2017, VBApps |
//|                                             http://www.vbapps.co |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2017, VBApps"

#property indicator_separate_window
#property indicator_minimum -5.0
#property indicator_maximum 36.0
#property indicator_buffers 3
#property indicator_color1 Red
#property indicator_color2 Lime
#property indicator_color3 Blue
#property indicator_level2 4.0
#property indicator_level3 16.5
#property indicator_level4 14.5
#property indicator_level5 27.0
#property indicator_level6 31.0

double g_ibuf_76[];
extern int InternalKey=7575;
extern double Smoothing=1.0;
double gd_92=100.0;
extern int BarsToLoad=701;
int gi_104=0;
extern int Progression=8;
extern int Length=3;
extern int Sensitivity=30;
extern int Period_MA=23;
extern int Period_MA_Second=50;
extern int ModeMA=MODE_LWMA;
extern bool UseAlerts=false;
extern bool SendEMailOnSignal=false;
extern bool UseSMAOnTrendIndicatorForAlerts=true;
extern bool UseFirstSMAOnTrendIndicatorForAlerts=true;
extern bool UseSecondSMAOnTrendIndicatorForAlerts=true;
bool Debug=false;
int gi_120 = 1;
int gi_124 = 0;
double gd_128=0.0;
double gd_136;
double gd_144;
double gd_152;
double gd_160;
double gd_168;
double gd_176;
double gd_184;
double gd_192;
double gd_200=0.0;
int g_index_208;
int gi_212;
int gi_216;
int gi_220;
int gi_224;
int gi_228;
int gi_232;
int gi_236;
int gi_240;
int gi_244;
int gi_248;
int gi_252;
int gi_256=0;
double gd_260;
double gd_268;
double gd_276;
double gd_284;
double gd_292;
double gd_300;
double gd_308;
double gd_316;
double gd_324;
double gd_332;
double gd_340;
double gd_348;
double gd_356;
double gd_364;
double gd_372;
double gd_380;
double gd_388;
double gd_396;
double gd_404;
double gd_412;
double gd_420;
double gd_428;
double gd_436;
double gd_444;
double gd_452;
double gd_460=0.0;
bool gi_468;
int gi_472;
int gi_476;
int gi_480;
int gi_484;
int gi_488=0;
double gda_492[128];
double gda_496[128];
double gda_500[11];
double gda_504[62];
double gda_unused_508[300];
int gi_unused_512;
int g_index_516;
int gi_520;
int gi_528;
double g_ibuf_556[];
double MA_Buff[];
double MA_Buff_Second[];
double gda_560[150];
double gda_564[150];
double g_icustom_568;
double g_icustom_576=0.0;
double gd_584;
double gd_592;
double g_bars_600=0.0;
string selfpath;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   IndicatorShortName("AreaFiftyOne_Trend");
   selfpath=GetRelativeProgramPath();
   for(g_index_208 = 0; g_index_208 < 128; g_index_208++) gda_492[g_index_208] = 0.0;
   for(g_index_208 = 0; g_index_208 < 128; g_index_208++) gda_496[g_index_208] = 0.0;
   for(g_index_208 = 0; g_index_208 < 11; g_index_208++) gda_500[g_index_208] = 0.0;
   for(g_index_208 = 0; g_index_208 < 62; g_index_208++) gda_504[g_index_208] = 0.0;
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,2);
   SetIndexBuffer(0,g_ibuf_76);
   SetIndexStyle(3,DRAW_LINE,STYLE_SOLID,2);
   SetIndexBuffer(3,g_ibuf_556);
   SetIndexStyle(1,DRAW_LINE,STYLE_SOLID,2);
   SetIndexBuffer(1,MA_Buff);
   ArraySetAsSeries(MA_Buff,true);
   SetIndexStyle(2,DRAW_LINE,STYLE_SOLID,2);
   SetIndexBuffer(2,MA_Buff_Second);
   ArraySetAsSeries(MA_Buff_Second,true);
   return (0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   int li_unused_16;
   int li_12= InternalKey;
   if(li_12 == 34562788) loadJMA();
   else
     {
      if(Bars>g_bars_600)
        {
         g_bars_600=Bars;
         li_unused_16=0;
         for(int l_index_20=0; l_index_20<150; l_index_20++)
           {
            gd_584 = 0;
            gd_592 = 0;
            for(int li_24=Length; li_24<=Length+Progression*Sensitivity; li_24+=Progression)
              {
               g_icustom_568 = iCustom(NULL, 0, selfpath, 34562788, li_24, BarsToLoad, 0, l_index_20);
               g_icustom_576 = iCustom(NULL, 0, selfpath, 34562788, li_24, BarsToLoad, 0, l_index_20 + 1);
               if(g_icustom_568>g_icustom_576) gd_584++;
               else gd_592++;
              }
            gda_560[l_index_20] = gd_584;
            gda_564[l_index_20] = gd_592;
           }
         lenars(gda_560,1);
         lenars(gda_564,2);
         for(int k=BarsToLoad;k>-1;k--)
           {
            MA_Buff[k]=iMAOnArray(g_ibuf_76,0,Period_MA,0,ModeMA,k);
            MA_Buff_Second[k]=iMAOnArray(g_ibuf_76,0,Period_MA_Second,0,ModeMA,k);
           }
         if(UseAlerts) {HandleAlerts();}
         return (0);
        }
     }
   return (0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void HandleAlerts()
  {
   bool   SellFlag=false;
   bool   BuyFlag=false;
   double Trend=NormalizeDouble(g_ibuf_76[0],1);
   double TrendBack=NormalizeDouble(g_ibuf_76[1],1);
   double TrendBack2=NormalizeDouble(g_ibuf_76[2],1);
   double MA=NormalizeDouble(MA_Buff[0],1);
   double MABack=NormalizeDouble(MA_Buff[1],1);
   double MABack2=NormalizeDouble(MA_Buff[2],1);
   double MA_Second=NormalizeDouble(MA_Buff_Second[0],1);
   double MABack_Second=NormalizeDouble(MA_Buff_Second[1],1);
   double MABack2_Second=NormalizeDouble(MA_Buff_Second[2],1);
   string CrossingText;

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
   if(!UseSMAOnTrendIndicatorForAlerts)
     {
      if(((Trend<TrendBack || CompareDoubles(Trend,TrendBack)) && ((Trend<26)
         && (TrendBack>=23))
         && (TrendBack2>=26)))
        {
         if(Debug)
           {
            Print("SellSignal!");
            Print("Trend="+DoubleToStr(Trend));
            Print("TrendBack="+DoubleToStr(TrendBack));
           }
         SellFlag=true;
         CrossingText = "Crossing from overbougth in sell area.";
        }

      if(((Trend>TrendBack || CompareDoubles(Trend,TrendBack)) && (Trend>4)
         && (TrendBack<=8)
         && (TrendBack2<=5)))
        {
         if(Debug)
           {
            Print("BuySignal!");
            Print("Trend="+DoubleToStr(Trend));
            Print("TrendBack="+DoubleToStr(TrendBack));
           }
         BuyFlag=true;
         CrossingText = "Crossing from oversold in buy area.";
        }
     }
   if(UseSMAOnTrendIndicatorForAlerts && UseFirstSMAOnTrendIndicatorForAlerts)
     {
      if((((MathRound(MA)>MathRound(Trend)) || ((MA-0.5)==Trend))
         && (((MA-Trend)>1) || ((MA-Trend)==1)) && (Trend<14.5 || Trend>16.5)
         && ((MathRound(MABack)<MathRound(TrendBack)) || (MathRound(MABack)==MathRound(TrendBack)))
         && ((MathRound(MABack2)<MathRound(TrendBack2)) /*|| (MathRound(MABack2)==MathRound(TrendBack2))*/
         /*|| (MathRound(MABack2)>MathRound(TrendBack2))*/))
         /*|| (((Trend<26) && (TrendBack>=23)) && (TrendBack2>=26))*/)
        {
         if(Debug)
           {
            Print("SELL=>MA="+DoubleToStr(MathRound(MA))+">Trend="+DoubleToStr(MathRound(Trend))
                  +"&&MABack="+DoubleToStr(MathRound(MABack))+"<=TrendBack="+DoubleToStr(MathRound(TrendBack))
                  +"&&MaBack2="+DoubleToStr(MathRound(MABack2))+"<=TrendBack2="+DoubleToStr(MathRound(TrendBack2)));
           }
         SellFlag=true;
         CrossingText = "Crossing with first MA to sell.";
        }
      if((((MathRound(MA)<MathRound(Trend)) || ((MA+0.5)==Trend))
         && (((Trend-MA)>1) || ((Trend-MA)==1)) && (Trend<14.5 || Trend>16.5) && (Trend>4)
         && ((MathRound(MABack)>MathRound(TrendBack)) || (MathRound(MABack)==MathRound(TrendBack)))
         && ((MathRound(MABack2)>MathRound(TrendBack2)) /*|| (MathRound(MABack2)==MathRound(TrendBack2))*/
         /*|| (MathRound(MABack2)<MathRound(TrendBack2))*/))
         /*|| ((Trend>4) && (TrendBack<=8) && (TrendBack2<=5))*/)
        {
         if(Debug)
           {
            Print("BUY=>MA="+DoubleToStr(MathRound(MA))+"<Trend="+DoubleToStr(MathRound(Trend))
                  +"&&MABack="+DoubleToStr(MathRound(MABack))+"=>TrendBack="+DoubleToStr(MathRound(TrendBack))
                  +"&&MaBack2="+DoubleToStr(MathRound(MABack2))+"=>TrendBack2="+DoubleToStr(MathRound(TrendBack2)));
           }
         BuyFlag=true;
         CrossingText = "Crossing with first MA to buy.";
        }
     }
   if(UseSMAOnTrendIndicatorForAlerts && UseSecondSMAOnTrendIndicatorForAlerts)
     {
      //using ma50
      if((((MathRound(MA_Second)>MathRound(Trend)) || (MathRound(MA_Second-0.5)==Trend))
         && (((MA_Second-Trend)>0.5) || ((MA_Second-Trend)==1)) && (Trend<14.5 || Trend>16.5)
         && ((MathRound(MABack_Second)<MathRound(TrendBack)) || (MathRound(MABack_Second)==MathRound(TrendBack)))
         && ((MathRound(MABack2_Second)<MathRound(TrendBack2)) /*|| (MathRound(MABack2_Second)==MathRound(TrendBack2))*/
         /*|| (MathRound(MABack2_Second)>MathRound(TrendBack2))*/))
         /*|| (((Trend<26) && (TrendBack>=23)) && (TrendBack2>=26))*/)
        {
         if(Debug)
           {
            Print("SELL=>MA_Second="+DoubleToStr(MathRound(MA_Second))+">Trend="+DoubleToStr(MathRound(Trend))
                  +"&&MABack_Second="+DoubleToStr(MathRound(MABack_Second))+"<=TrendBack="+DoubleToStr(MathRound(TrendBack))
                  +"&&MaBack2_Second="+DoubleToStr(MathRound(MABack2_Second))+"<=TrendBack2="+DoubleToStr(MathRound(TrendBack2)));
           }
         SellFlag=true;
         CrossingText = "Crossing with second MA to sell.";
        }
      if((((MathRound(MA_Second)<MathRound(Trend)) || (MathRound(MA_Second+0.5)==Trend))
         && (((Trend-MA_Second)>0.5) || ((Trend-MA_Second)==1)) && (Trend<14.5 || Trend>16.5)
         && ((MathRound(MABack_Second)>MathRound(TrendBack)) || (MathRound(MABack_Second)==MathRound(TrendBack)))
         && ((MathRound(MABack2_Second)>MathRound(TrendBack2)) /*|| (MathRound(MABack2_Second)==MathRound(TrendBack2))*/
         /*|| (MathRound(MABack2_Second)<MathRound(TrendBack2))*/))
         /*|| ((Trend>4) && (TrendBack<=8) && (TrendBack2<=5))*/)
        {
         if(Debug)
           {
            Print("BUY=>MA_Second="+DoubleToStr(MathRound(MA_Second))+"<Trend="+DoubleToStr(MathRound(Trend))
                  +"&&MABack_Second="+DoubleToStr(MathRound(MABack_Second))+"=>TrendBack="+DoubleToStr(MathRound(TrendBack))
                  +"&&MaBack2_Second="+DoubleToStr(MathRound(MABack2_Second))+"=>TrendBack2="+DoubleToStr(MathRound(TrendBack2)));
           }
         BuyFlag=true;
         CrossingText = "Crossing with second MA to buy.";
        }
     }
   if(BuyFlag) {Alert(Symbol()+"("+TimeFrameToString(Period())+")"+": Buy signal at "+Ask+"! "+CrossingText);}
   if(SellFlag) {Alert(Symbol()+"("+TimeFrameToString(Period())+")"+": Sell signal at "+Bid+"! "+CrossingText);}
  }

string TimeFrameToString(int TimeFrameInt)
{
   string TimeFrame="";
      if (TimeFrameInt==1)  TimeFrame="M1";
      if (TimeFrameInt==5)  TimeFrame="M5";
      if (TimeFrameInt==15) TimeFrame="M115";       
      if (TimeFrameInt==30) TimeFrame="M30";       
      if (TimeFrameInt==60)  TimeFrame="H1";        
      if (TimeFrameInt==240)  TimeFrame="H4";       
      if (TimeFrameInt==1440)  TimeFrame="D1";       
      if (TimeFrameInt==10080)  TimeFrame="W1";        
      if (TimeFrameInt==43200)  TimeFrame="MN";        
   return(TimeFrame);
}  
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void loadJMA()
  {
   double ld_0;
   gi_220 = 63;
   gi_224 = 64;
   if(gi_120==TRUE)
     {
      for(g_index_208 = 1; g_index_208 < gi_220 + 1; g_index_208++) gda_492[g_index_208] = -100;
      for(g_index_208 = gi_224; g_index_208 < 128; g_index_208++) gda_492[g_index_208] = 100;
      gi_120=FALSE;
     }
   gi_468=TRUE;
   if(Smoothing<=1.0) gd_380=0.0000000001;
   else gd_380=(Smoothing-1.0)/2.0;
   if(gd_92<-100.0) gd_268=0.5;
   else
     {
      if(gd_92>100.0) gd_268=2.5;
      else gd_268=gd_92/100.0+1.5;
     }
   gd_144 = MathLog(MathSqrt(gd_380));
   gd_152 = gd_144;
   if(gd_144/MathLog(2.0)+2.0<0.0) gd_160=0;
   else gd_160=gd_152/MathLog(2.0)+2.0;
   gd_404=gd_160;
   if(gd_404-2.0>=0.5) gd_388=gd_404-2.0;
   else gd_388=0.5;
   gd_372 = MathSqrt(gd_380) * gd_404;
   gd_396 = gd_372 / (gd_372 + 1.0);
   gd_380 = 0.9 * gd_380;
   gd_332 = gd_380 / (gd_380 + 2.0);
   gi_468 = TRUE;
   if(BarsToLoad==0) BarsToLoad=Bars;
   for(gi_124=BarsToLoad+1000; gi_124>=0; gi_124--)
     {
      switch(gi_104)
        {
         case 0:
            ld_0=Close[gi_124];
            break;
         case 1:
            ld_0=Open[gi_124];
            break;
         case 2:
            ld_0=(Open[gi_124]+High[gi_124]+Low[gi_124]+Close[gi_124])/4.0;
            break;
         case 3:
            ld_0=High[gi_124];
            break;
         case 4:
            ld_0=Low[gi_124];
            break;
         default:
            ld_0=Close[gi_124];
        }
      if(gi_484<61)
        {
         gi_484++;
         gda_504[gi_484]=ld_0;
        }
      if(gi_484>30)
        {
         if(gi_468!=FALSE)
           {
            gi_468 = FALSE;
            gi_212 = 0;
            for(g_index_208=1; g_index_208<30; g_index_208++)
               if(gda_504[g_index_208+1]!=gda_504[g_index_208]) gi_212=1;
            gi_472=30*gi_212;
            if(gi_472==0) gd_308=ld_0;
            else gd_308=gda_504[1];
            gd_276=gd_308;
            if(gi_472>29) gi_472=29;
           }
         else gi_472=0;
         for(g_index_208=gi_472; g_index_208>=0; g_index_208--)
           {
            if(g_index_208==0) gd_260=ld_0;
            else gd_260=gda_504[31-g_index_208];
            gd_292 = gd_260 - gd_276;
            gd_324 = gd_260 - gd_308;
            if(MathAbs(gd_292)>MathAbs(gd_324)) gd_152=MathAbs(gd_292);
            else gd_152=MathAbs(gd_324);
            gd_412 = gd_152;
            gd_136 = gd_412 + 0.0000000001;
            if(gi_236<=1) gi_236=127;
            else gi_236--;
            if(gi_240<=1) gi_240=10;
            else gi_240--;
            if(gi_256<128) gi_256++;
            gd_176=gd_176+gd_136-gda_500[gi_240];
            gda_500[gi_240]=gd_136;
            if(gi_256>10) gd_200=gd_176/10.0;
            else gd_200=gd_176/gi_256;
            if(gi_256==30) g_index_516=0;
            if(gi_256>127)
              {
               gd_184=gda_496[gi_236];
               gda_496[gi_236]=gd_200;
               gi_252 = 64;
               gi_244 = gi_252;
               gi_unused_512=gi_244;
               while(gi_252>1)
                 {
                  if(gda_492[gi_244]<gd_184)
                    {
                     gi_252 /= 2;
                     gi_244 += gi_252;
                     gi_unused_512=gi_244;
                       } else {
                     if(gda_492[gi_244]<=gd_184) gi_252=1;
                     else
                       {
                        gi_252 /= 2;
                        gi_244 -= gi_252;
                        gi_unused_512=gi_244;
                       }
                    }
                 }
                 } else {
               gda_496[gi_236]=gd_200;
               if(gi_220+gi_224>127)
                 {
                  gi_224--;
                  gi_244=gi_224;
                  gi_unused_512=gi_244;
                    } else {
                  gi_220++;
                  gi_244=gi_220;
                  gi_unused_512=gi_244;
                 }
               if(gi_220>96) gi_228=96;
               else gi_228=gi_220;
               if(gi_224<32) gi_232=32;
               else gi_232=gi_224;
              }
            gi_252 = 64;
            gi_248 = gi_252;
            while(gi_252>1)
              {
               if(gda_492[gi_248]>=gd_200)
                 {
                  if(gda_492[gi_248-1]<=gd_200) gi_252=1;
                  else
                    {
                     gi_252 /= 2;
                     gi_248 -= gi_252;
                    }
                    } else {
                  gi_252 /= 2;
                  gi_248 += gi_252;
                 }
               if(gi_248==127 && gd_200>gda_492[127]) gi_248=128;
              }
            if(gi_256>127)
              {
               if(gi_244>=gi_248)
                 {
                  if(gi_228+1>gi_248 && gi_232-1<gi_248) gd_192+=gd_200;
                  else
                     if(gi_232>gi_248 && gi_232-1<gi_244) gd_192+=gda_492[gi_232-1];
                    } else {
                  if(gi_232>=gi_248)
                    {
                     if(gi_228+1<gi_248 && gi_228+1>gi_244) gd_192+=gda_492[gi_228+1];
                       } else {
                     if(gi_228+2>gi_248) gd_192+=gd_200;
                     else
                        if(gi_228+1<gi_248 && gi_228+1>gi_244) gd_192+=gda_492[gi_228+1];
                    }
                 }
               if(gi_244>gi_248)
                 {
                  if(gi_232-1<gi_244 && gi_228+1>gi_244) gd_192-=gda_492[gi_244];
                  else
                     if(gi_228<gi_244 && gi_228+1>gi_248) gd_192-=gda_492[gi_228];
                    } else {
                  if(gi_228+1>gi_244 && gi_232-1<gi_244) gd_192-=gda_492[gi_244];
                  else
                     if(gi_232>gi_244 && gi_232<gi_248) gd_192-=gda_492[gi_232];
                 }
              }
            if(gi_244<=gi_248)
              {
               if(gi_244>=gi_248) gda_492[gi_248]=gd_200;
               else
                 {
                  for(g_index_516=gi_244+1; g_index_516<gi_248; g_index_516++) gda_492[g_index_516-1]=gda_492[g_index_516];
                  gda_492[gi_248-1]=gd_200;
                 }
                 } else {
               for(gi_520=gi_244-1; gi_520>=gi_248; gi_520--) gda_492[gi_520+1]=gda_492[gi_520];
               gda_492[gi_248]=gd_200;
              }
            if(gi_256<=127)
              {
               gd_192=0;
               for(gi_528=gi_232; gi_528<gi_228+1; gi_528++) gd_192+=gda_492[gi_528];
              }
            gd_348=gd_192/(gi_228-gi_232+1);
            if(gi_488+1>31) gi_488=31;
            else gi_488++;
            if(gi_488<=30)
              {
               if(gd_292>0.0) gd_276=gd_260;
               else gd_276=gd_260-gd_292*gd_396;
               if(gd_324<0.0) gd_308=gd_260;
               else gd_308=gd_260-gd_324*gd_396;
               gd_436=ld_0;
               if(gi_488==30)
                 {
                  gd_444=ld_0;
                  if(MathCeil(gd_372)>=1.0) gd_168=MathCeil(gd_372);
                  else gd_168=1;
                  gi_480=gd_168;
                  if(MathFloor(gd_372)>=1.0) gd_152=MathFloor(gd_372);
                  else gd_152=1;
                  gi_476=gd_152;
                  if(gi_480==gi_476) gd_356=1;
                  else
                    {
                     gd_168 = gi_480 - gi_476;
                     gd_356 = (gd_372 - gi_476) / gd_168;
                    }
                  if(gi_476<=29) gi_212=gi_476;
                  else gi_212=29;
                  if(gi_480<=29) gi_216=gi_480;
                  else gi_216=29;
                  gd_420=(ld_0 -(gda_504[gi_484-gi_212])) *(1-gd_356)/gi_476+(ld_0 -(gda_504[gi_484-gi_216]))*gd_356/gi_480;
                 }
                 } else {
               if(gd_404>=MathPow(MathAbs(gd_412/gd_348),gd_388)) gd_144=MathPow(MathAbs(gd_412/gd_348),gd_388);
               else gd_144=gd_404;
               if(gd_144<1.0) gd_152=1.0;
               else
                 {
                  if(gd_404>=MathPow(MathAbs(gd_412/gd_348),gd_388)) gd_160=MathPow(MathAbs(gd_412/gd_348),gd_388);
                  else gd_160=gd_404;
                  gd_152=gd_160;
                 }
               gd_340 = gd_152;
               gd_364 = MathPow(gd_396, MathSqrt(gd_340));
               if(gd_292>0.0) gd_276=gd_260;
               else gd_276=gd_260-gd_292*gd_364;
               if(gd_324<0.0) gd_308=gd_260;
               else gd_308=gd_260-gd_324*gd_364;
              }
           }
         if(gi_488>30)
           {
            gd_300 = MathPow(gd_332, gd_340);
            gd_444 = (1 - gd_300) * ld_0 + gd_300 * gd_444;
            gd_452 = (ld_0 - gd_444) * (1 - gd_332) + gd_332 * gd_452;
            gd_460 = gd_268 * gd_452 + gd_444;
            gd_284 = -2.0 * gd_300;
            gd_316 = gd_300 * gd_300;
            gd_428 = gd_284 + gd_316 + 1.0;
            gd_420 = (gd_460 - gd_436) * gd_428 + gd_316 * gd_420;
            gd_436+= gd_420;
           }
        }
      gd_128=gd_436;
      g_ibuf_76[gi_124]=gd_128;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void lenars(double ada_0[150],int ai_4)
  {
   double ld_8;
   gi_220 = 63;
   gi_224 = 64;
   if(gi_120==TRUE)
     {
      for(g_index_208 = 1; g_index_208 < gi_220 + 1; g_index_208++) gda_492[g_index_208] = -100;
      for(g_index_208 = gi_224; g_index_208 < 128; g_index_208++) gda_492[g_index_208] = 100;
      gi_120=FALSE;
     }
   gi_468=TRUE;
   if(Smoothing<=1.0) gd_380=0.0000000001;
   else gd_380=(Smoothing-1.0)/2.0;
   if(gd_92<-100.0) gd_268=0.5;
   else
     {
      if(gd_92>100.0) gd_268=2.5;
      else gd_268=gd_92/100.0+1.5;
     }
   gd_144 = MathLog(MathSqrt(gd_380));
   gd_152 = gd_144;
   if(gd_144/MathLog(2.0)+2.0<0.0) gd_160=0;
   else gd_160=gd_152/MathLog(2.0)+2.0;
   gd_404=gd_160;
   if(gd_404-2.0>=0.5) gd_388=gd_404-2.0;
   else gd_388=0.5;
   gd_372 = MathSqrt(gd_380) * gd_404;
   gd_396 = gd_372 / (gd_372 + 1.0);
   gd_380 = 0.9 * gd_380;
   gd_332 = gd_380 / (gd_380 + 2.0);
   gi_468 = TRUE;
   if(BarsToLoad==0) BarsToLoad=Bars;
   for(gi_124=BarsToLoad+30; gi_124>=0; gi_124--)
     {
      ld_8=ada_0[gi_124];
      if(gi_484<61)
        {
         gi_484++;
         gda_504[gi_484]=ld_8;
        }
      if(gi_484>30)
        {
         if(gi_468!=FALSE)
           {
            gi_468 = FALSE;
            gi_212 = 0;
            for(g_index_208=1; g_index_208<30; g_index_208++)
               if(gda_504[g_index_208+1]!=gda_504[g_index_208]) gi_212=1;
            gi_472=30*gi_212;
            if(gi_472==0) gd_308=ld_8;
            else gd_308=gda_504[1];
            gd_276=gd_308;
            if(gi_472>29) gi_472=29;
           }
         else gi_472=0;
         for(g_index_208=gi_472; g_index_208>=0; g_index_208--)
           {
            if(g_index_208==0) gd_260=ld_8;
            else gd_260=gda_504[31-g_index_208];
            gd_292 = gd_260 - gd_276;
            gd_324 = gd_260 - gd_308;
            if(MathAbs(gd_292)>MathAbs(gd_324)) gd_152=MathAbs(gd_292);
            else gd_152=MathAbs(gd_324);
            gd_412 = gd_152;
            gd_136 = gd_412 + 0.0000000001;
            if(gi_236<=1) gi_236=127;
            else gi_236--;
            if(gi_240<=1) gi_240=10;
            else gi_240--;
            if(gi_256<128) gi_256++;
            gd_176=gd_176+gd_136-gda_500[gi_240];
            gda_500[gi_240]=gd_136;
            if(gi_256>10) gd_200=gd_176/10.0;
            else gd_200=gd_176/gi_256;
            if(gi_256==30) g_index_516=0;
            if(gi_256>127)
              {
               gd_184=gda_496[gi_236];
               gda_496[gi_236]=gd_200;
               gi_252 = 64;
               gi_244 = gi_252;
               gi_unused_512=gi_244;
               while(gi_252>1)
                 {
                  if(gda_492[gi_244]<gd_184)
                    {
                     gi_252 /= 2;
                     gi_244 += gi_252;
                     gi_unused_512=gi_244;
                       } else {
                     if(gda_492[gi_244]<=gd_184) gi_252=1;
                     else
                       {
                        gi_252 /= 2;
                        gi_244 -= gi_252;
                        gi_unused_512=gi_244;
                       }
                    }
                 }
                 } else {
               gda_496[gi_236]=gd_200;
               if(gi_220+gi_224>127)
                 {
                  gi_224--;
                  gi_244=gi_224;
                  gi_unused_512=gi_244;
                    } else {
                  gi_220++;
                  gi_244=gi_220;
                  gi_unused_512=gi_244;
                 }
               if(gi_220>96) gi_228=96;
               else gi_228=gi_220;
               if(gi_224<32) gi_232=32;
               else gi_232=gi_224;
              }
            gi_252 = 64;
            gi_248 = gi_252;
            while(gi_252>1)
              {
               if(gda_492[gi_248]>=gd_200)
                 {
                  if(gda_492[gi_248-1]<=gd_200) gi_252=1;
                  else
                    {
                     gi_252 /= 2;
                     gi_248 -= gi_252;
                    }
                    } else {
                  gi_252 /= 2;
                  gi_248 += gi_252;
                 }
               if(gi_248==127 && gd_200>gda_492[127]) gi_248=128;
              }
            if(gi_256>127)
              {
               if(gi_244>=gi_248)
                 {
                  if(gi_228+1>gi_248 && gi_232-1<gi_248) gd_192+=gd_200;
                  else
                     if(gi_232>gi_248 && gi_232-1<gi_244) gd_192+=gda_492[gi_232-1];
                    } else {
                  if(gi_232>=gi_248)
                    {
                     if(gi_228+1<gi_248 && gi_228+1>gi_244) gd_192+=gda_492[gi_228+1];
                       } else {
                     if(gi_228+2>gi_248) gd_192+=gd_200;
                     else
                        if(gi_228+1<gi_248 && gi_228+1>gi_244) gd_192+=gda_492[gi_228+1];
                    }
                 }
               if(gi_244>gi_248)
                 {
                  if(gi_232-1<gi_244 && gi_228+1>gi_244) gd_192-=gda_492[gi_244];
                  else
                     if(gi_228<gi_244 && gi_228+1>gi_248) gd_192-=gda_492[gi_228];
                    } else {
                  if(gi_228+1>gi_244 && gi_232-1<gi_244) gd_192-=gda_492[gi_244];
                  else
                     if(gi_232>gi_244 && gi_232<gi_248) gd_192-=gda_492[gi_232];
                 }
              }
            if(gi_244<=gi_248)
              {
               if(gi_244>=gi_248) gda_492[gi_248]=gd_200;
               else
                 {
                  for(g_index_516=gi_244+1; g_index_516<gi_248; g_index_516++) gda_492[g_index_516-1]=gda_492[g_index_516];
                  gda_492[gi_248-1]=gd_200;
                 }
                 } else {
               for(gi_520=gi_244-1; gi_520>=gi_248; gi_520--) gda_492[gi_520+1]=gda_492[gi_520];
               gda_492[gi_248]=gd_200;
              }
            if(gi_256<=127)
              {
               gd_192=0;
               for(gi_528=gi_232; gi_528<gi_228+1; gi_528++) gd_192+=gda_492[gi_528];
              }
            gd_348=gd_192/(gi_228-gi_232+1);
            if(gi_488+1>31) gi_488=31;
            else gi_488++;
            if(gi_488<=30)
              {
               if(gd_292>0.0) gd_276=gd_260;
               else gd_276=gd_260-gd_292*gd_396;
               if(gd_324<0.0) gd_308=gd_260;
               else gd_308=gd_260-gd_324*gd_396;
               gd_436=ld_8;
               if(gi_488==30)
                 {
                  gd_444=ld_8;
                  if(MathCeil(gd_372)>=1.0) gd_168=MathCeil(gd_372);
                  else gd_168=1;
                  gi_480=gd_168;
                  if(MathFloor(gd_372)>=1.0) gd_152=MathFloor(gd_372);
                  else gd_152=1;
                  gi_476=gd_152;
                  if(gi_480==gi_476) gd_356=1;
                  else
                    {
                     gd_168 = gi_480 - gi_476;
                     gd_356 = (gd_372 - gi_476) / gd_168;
                    }
                  if(gi_476<=29) gi_212=gi_476;
                  else gi_212=29;
                  if(gi_480<=29) gi_216=gi_480;
                  else gi_216=29;
                  gd_420=(ld_8 -(gda_504[gi_484-gi_212])) *(1-gd_356)/gi_476+(ld_8 -(gda_504[gi_484-gi_216]))*gd_356/gi_480;
                 }
                 } else {
               if(gd_404>=MathPow(MathAbs(gd_412/gd_348),gd_388)) gd_144=MathPow(MathAbs(gd_412/gd_348),gd_388);
               else gd_144=gd_404;
               if(gd_144<1.0) gd_152=1.0;
               else
                 {
                  if(gd_404>=MathPow(MathAbs(gd_412/gd_348),gd_388)) gd_160=MathPow(MathAbs(gd_412/gd_348),gd_388);
                  else gd_160=gd_404;
                  gd_152=gd_160;
                 }
               gd_340 = gd_152;
               gd_364 = MathPow(gd_396, MathSqrt(gd_340));
               if(gd_292>0.0) gd_276=gd_260;
               else gd_276=gd_260-gd_292*gd_364;
               if(gd_324<0.0) gd_308=gd_260;
               else gd_308=gd_260-gd_324*gd_364;
              }
           }
         if(gi_488>30)
           {
            gd_300 = MathPow(gd_332, gd_340);
            gd_444 = (1 - gd_300) * ld_8 + gd_300 * gd_444;
            gd_452 = (ld_8 - gd_444) * (1 - gd_332) + gd_332 * gd_452;
            gd_460 = gd_268 * gd_452 + gd_444;
            gd_284 = -2.0 * gd_300;
            gd_316 = gd_300 * gd_300;
            gd_428 = gd_284 + gd_316 + 1.0;
            gd_420 = (gd_460 - gd_436) * gd_428 + gd_316 * gd_420;
            gd_436+= gd_420;
           }
        }
      gd_128=gd_436;
      if(ai_4==1) g_ibuf_76[gi_124]=gd_128;
      else g_ibuf_556[gi_124]=gd_128;
     }
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
  {
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- The first way to get the uninitialization reason code 
   Print(__FUNCTION__,"_Uninitalization reason code = ",reason);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
//---
   double ret=0.0;
//---
   return(ret);
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
//--- if this is a resource, return the path relative to MQL4 directory
   if(StringFind(path,"::",pos)>=0)
      return(StringSubstr(path,pos));
//--- find a separator for the first MQL4 subdirectory (for example, MQL4\Indicators)
//--- if not found, return the path relative to MQL4 directory
   if((pos2=StringFind(path,"\\",pos+1))<0)
      return(StringSubstr(path,pos));
//--- return the path relative to the subdirectory (for example, MQL4\Indicators)
   return(StringSubstr(path,pos2+1));
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
bool CompareDoubles(double number1,double number2)
  {
   if(NormalizeDouble(number1-number2,5)==0) return(true);
   else return(false);
  }
//+------------------------------------------------------------------+
