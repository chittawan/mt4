//+------------------------------------------------------------------+
//|                                              HyhasSweetSpots.mq4 |
//|                                                            Hyhas |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Hyhas"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

#include <../Experts/_HyhasLib/HyhasStd.mqh>
extern int    _size=250;
extern double _lotsMTG =0.01;
extern int    _dePip   =0;
extern int    _magicNumberMTG=888;
extern string _settingDelayByM1="--- Delay By M1 ---";
extern int    _delayOpenOrder_M1=1;
extern string _settingDelayByMACD="--- Delay By MACD ---";
extern bool   _isMacd=false;
extern string _fiboLot="--- Fibo Lots ---";
extern bool   _isFiboLots=false;
extern string _overLimit="--- Save Over Lots ---";
extern double _overLostCutOff=2;
extern double _manyBalance=100;
extern string _showDescription="--- Show Description ---";
extern bool   _isShowDescription=false;
/*Text*/
string Text2,Text3,Text4,txtBarAction;
/*SweetSpots*/
double upline_Buy,upline_Sell,downline_Buy,downline_Sell;
/*Matingle*/
double lotBuy=_lotsMTG,lotSell=_lotsMTG,
preLotBuy=_lotsMTG,preLotSell=_lotsMTG,
lastPriceBuy,lastPriceSell,
priceProfitBuy,priceProfitSell;
int lastTicketBuy=-1,lastTicketSell=-1;
int OPType=-1,closeAllPriceOP = -1;
int buyCnt=0,sellCnt=0;
/*Delay Open Order*/
int delayBarBuy=0,delayBarSell=0,bars;
/*MACD*/
int OP_Macd=-1;
bool Macd_Buy=false,Macd_Sell=false;
bool isWorkingDay=true;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   bool isAccess=false;
   string accName=AccountName();
   if(IsDemo() || IsTesting())
     {
      isAccess=true;
     }
   else if(StringToLower(accName))
     {
      isAccess=-1!=StringFind("chittawan risukhumal,vittaya jongudomporn,jirapas sukumarphan,athichart na suwan,rapeeporn poosawan",accName);

      if(accName=="rapeeporn poosawan")
        {
         if(!(TimeYear(TimeCurrent())==2015 && TimeMonth(TimeCurrent())==9))
            isAccess=false;
        }
     }

   if(!isAccess)
     {
      Print("INITIAL FAILED");
      return(INIT_FAILED);
     }

   delayBarBuy=0;delayBarBuy=0;
   getSweetSpots(upline_Buy,downline_Buy,OP_BUY);
   getSweetSpots(upline_Sell,downline_Sell,OP_SELL);

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

   if(_isShowDescription) DrawMenu();

   if(_isFridaySavingMode) isWorkingDay=isNotHoliday();
   bool isOrderBuyWorking=false,
   isOrderSellWorking=false;
   if(OrderSelect(lastTicketBuy,SELECT_BY_TICKET))
      isOrderBuyWorking=OrderCloseTime()==0 && OrderLots()>_lotsMTG;
   if(OrderSelect(lastTicketSell,SELECT_BY_TICKET))
      isOrderSellWorking=OrderCloseTime()==0 && OrderLots()>_lotsMTG;

   Text4=(isWorkingDay ? "isWorkingDay true" : "isWorkingDay false");// + " isOrderBuyWorking " + isOrderBuyWorking + " isOrderSellWorking " + isOrderSellWorking;

   if(isWorkingDay || isOrderBuyWorking || isOrderSellWorking)
     {
      if(_isMacd)
        {
         double macdMain=iMACD(NULL,PERIOD_M15,12,26,3,PRICE_CLOSE,MODE_MAIN,0);
         double macdSig=iMACD(NULL,PERIOD_M15,12,26,3,PRICE_CLOSE,MODE_SIGNAL,0);

         OP_Macd=(macdMain>macdSig)? OP_BUY : OP_SELL;
         Macd_Buy=(OP_Macd==OP_BUY);// || macdMain > macdMain1
         Macd_Sell=(OP_Macd==OP_SELL);// || macdMain1 > macdMain
        }
      if(0>=delayBarBuy)
        {
         bool isOpenBuy=openOrderBuy();
         if(isOpenBuy) delayBarBuy=_delayOpenOrder_M1;
        }
      if(0>=delayBarSell)
        {
         bool isOpenSell=openOrderSell();
         if(isOpenSell) delayBarSell=_delayOpenOrder_M1;
        }
        } else{
      closeOrder(-1,_magicNumberMTG);
     }
   int curBars=iBars(Symbol(),PERIOD_M1);
   if(bars!=curBars)
     {
      delayBarBuy--;
      delayBarSell--;
     }
   bars=curBars;
   getSweetSpots(upline_Buy,downline_Buy,OP_BUY);
   getSweetSpots(upline_Sell,downline_Sell,OP_SELL);

   profitCloseOrder();
   processOverLostCutOff();
   Text3="DelayBuy : "+IntegerToString(delayBarBuy)+" DelaySell : "+IntegerToString(delayBarSell);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void profitCloseOrder()
  {
   double macdMain=iMACD(NULL,PERIOD_M15,12,26,3,PRICE_CLOSE,MODE_MAIN,0);
   double macdSig=iMACD(NULL,PERIOD_M15,12,26,3,PRICE_CLOSE,MODE_SIGNAL,0);
   OP_Macd=(macdMain>macdSig)? OP_BUY : OP_SELL;
   Macd_Buy=(OP_Macd==OP_BUY);// || macdMain > macdMain1
   Macd_Sell=(OP_Macd==OP_SELL);
     
   if(Bid>priceProfitBuy && OP_Macd != OP_BUY)
     {
      closeOrder(OP_BUY,_magicNumberMTG);
     }
   if(priceProfitSell>Ask && OP_Macd != OP_SELL)
     {
      closeOrder(OP_SELL,_magicNumberMTG);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void processOverLostCutOff()
  {
   if(lotBuy>=_overLostCutOff || lotSell>=_overLostCutOff)
     {
      if(AccountEquity()>AccountBalance()+_manyBalance)
        {
         closeOrder(-1,_magicNumberMTG);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void getSweetSpots(double &upLine,double &downLine,int OP_Type)
  {
   double price;

   price=(OP_Type==OP_BUY ? Ask : Bid);
   if(!(downLine<price && price<upLine) || upLine==0)
     {
      price=price-NormalizeDouble(MathMod((price/Point),_size),0)*Point;

      upLine=NormalizeDouble(price+(_size*Point),Digits);
      downLine=NormalizeDouble(price,Digits);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool openOrderBuy()
  {
   int ticket= -1;
   double ask=Ask;
   if((ask==upline_Buy || downline_Buy==ask))
     {
      double tp,xlot;
      double preLot=lotBuy;
      double line=ask;

      bool lastTicket=OrderSelect(lastTicketBuy,SELECT_BY_TICKET,MODE_TRADES);
      if(lastTicket && OrderCloseTime()>0) lastTicket=false;
      bool skip=false,isLotX2=(lastTicket && OrderCloseTime()==0 && OrderOpenPrice()>ask);

      if(isLotX2 && StrToDouble(OrderComment())>line && (!_isMacd || (_isMacd && (lotBuy==_lotsMTG || Macd_Buy))))
        {
         if(_isFiboLots)
           {
            xlot=MathRound(((StrToDouble(OrderComment())/Point) -(ask/Point)))/_size;
            //lotBuy=lotBuy *MathPow(2,xlot);
            while(xlot>=1)
              {
               double tLot=lotBuy;
               lotBuy=preLotBuy+lotBuy;
               preLotBuy=tLot;
               xlot--;
              }
           }
         else
           {
            xlot=MathRound(((StrToDouble(OrderComment())/Point) -(ask/Point)))/_size;
            lotBuy=lotBuy *MathPow(2,xlot);
           }
        }
      else if(!lastTicket)
        {
         lotBuy=_lotsMTG;
         if(_isFiboLots)preLot=_lotsMTG;
        }
      else
        {
         skip=true;
        }

      if(!skip && ((!lastTicket) || isLotX2))//Bid>ma && 
        {
         tp=ask+((_size-_dePip) *Point);
         ticket=OrderSend(Symbol(),OP_BUY,lotBuy,ask,3,0,0,DoubleToString(line,Digits),_magicNumberMTG,0,clrGreen);
         if(ticket!=-1)
           {
            preLotBuy=preLot;//fibo
            lastPriceBuy=ask;
            buyCnt=(lotBuy==_lotsMTG) ? 1 : buyCnt+1;

            lastTicketBuy=ticket;
            priceProfitBuy=tp;

/*int totals=OrdersTotal();
            for(int i=0; i<totals; i++)
              {
               if(OrderSelect(i,SELECT_BY_POS))
                 {
                  if(OrderTicket()!=ticket
                     && OrderSymbol()==Symbol()
                     && OrderType()==OP_BUY
                     && OrderMagicNumber()==_magicNumberMTG)
                    {
                     if(OrderTakeProfit()>tp || OrderTakeProfit()==0)
                       {
                        if(!OrderModify(OrderTicket(),OrderOpenPrice(),0,tp,0))
                          {
                           Print("--------------- OrderModify TP Fail.");
                          }
                       }
                    }
                 }
              }*/
           }
         else
           {
            lotBuy=preLot;
           }
        }
     }
   return ticket > -1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool openOrderSell()
  {
   int ticket=-1;
   double bid=Bid;
   if((bid==upline_Sell || downline_Sell==bid))
     {
      double tp;

      double preLot=lotSell;
      double line=bid,xlot;
      bool skip=false,lastTicket=OrderSelect(lastTicketSell,SELECT_BY_TICKET,MODE_TRADES);

      if(lastTicket && OrderCloseTime()>0) lastTicket=false;
      bool isLotX2=(lastTicket && OrderCloseTime()==0 && bid>OrderOpenPrice());
      if(isLotX2 && line>StrToDouble(OrderComment()) && (!_isMacd || (_isMacd && (lotSell==_lotsMTG || Macd_Sell))))
        {
         if(_isFiboLots)
           {
            xlot=MathRound(((bid/Point) -(StrToDouble(OrderComment())/Point)))/_size;

            while(xlot>=1)
              {
               double tLot=lotSell;
               lotSell=preLotSell+lotSell;
               preLotSell=tLot;
               xlot--;
              }
           }
         else
           {
            xlot=MathRound(((bid/Point) -(StrToDouble(OrderComment())/Point)))/_size;
            lotSell=lotSell*MathPow(2,xlot);
           }
        }
      else if(!lastTicket)
        {
         lotSell=_lotsMTG;
         if(_isFiboLots)preLot=_lotsMTG;
        }
      else
        {
         skip=true;
        }

      if(!skip && ((!lastTicket) || isLotX2))
        {
         tp=bid-((_size-_dePip) *Point);
         ticket=OrderSend(Symbol(),OP_SELL,lotSell,bid,3,0,0,DoubleToString(line,Digits),_magicNumberMTG,0,clrRed);
         if(ticket!=-1)
           {
            preLotSell=preLot;//fibo
            lastTicketSell=ticket;
            sellCnt=(lotSell==_lotsMTG) ? 1 : sellCnt+1;

            lastPriceSell=bid;
            priceProfitSell=tp;
/*int totals=OrdersTotal();
            for(int i=0; i<totals; i++)
              {
               if(OrderSelect(i,SELECT_BY_POS))
                 {
                  if(OrderTicket()!=ticket
                     && OrderSymbol()==Symbol()
                     && OrderType()==OP_SELL
                     && OrderMagicNumber()==_magicNumberMTG)
                    {
                     if(tp>OrderTakeProfit() || OrderTakeProfit()==0)
                       {
                        if(!OrderModify(OrderTicket(),OrderOpenPrice(),0,tp,0))
                          {
                           Print("--------------- OrderModify TP Fail.");
                          }
                       }
                    }
                 }
              }*/
           }
         else
           {
            lotSell=preLot;
           }
        }
     }

   return ticket > -1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawMenu()
  {

   color yellow=Yellow;
   color red=Red;
   color ProfitcolorEdit = White;
   color EquityColorEdit = White;
   color OrderMaxColorEdit=White;
   if(AccountProfit()<0) ProfitcolorEdit=Red;
   else ProfitcolorEdit=Green;

   if(AccountEquity()>AccountBalance()) EquityColorEdit=Green;
   else EquityColorEdit=Red;

   int lenShort=12;

   DrawItem("Server","Forex Server :",AccountServer(),yellow,StringLen(AccountServer())+1);
   DrawItem("sep1","","",0,0);
   DrawItem("Balance","Balance :",DoubleToStr(AccountBalance(),2),yellow,lenShort);
   DrawItem("Equity","Equity :",DoubleToStr(AccountEquity(),2),EquityColorEdit,lenShort);
   DrawItem("Spread","Spread:",DoubleToString(MarketInfo(NULL,MODE_SPREAD),0),yellow,lenShort);
//DrawItem("Min","STOPLEVEL",MarketInfo(OrderSymbol(),MODE_STOPLEVEL),yellow,lenShort);
   DrawItem("Loop","","BUY:"+IntegerToString(buyCnt)+" SELL:"+IntegerToString(sellCnt),yellow,lenShort);
   DrawItem("Text","",Text,yellow,lenShort);
   DrawItem("Text2","",Text2,yellow,lenShort);
   DrawItem("Text3","",Text3,yellow,lenShort);
   DrawItem("Text4","",Text4,yellow,lenShort);
   RowCount=1;
  }
//+------------------------------------------------------------------+
