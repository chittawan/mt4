//+------------------------------------------------------------------+
//|                                                          CFX.mq4 |
//|                                             associa_@hotmail.com |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "associa_@hotmail.com"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

extern double _lots = 0.01; /*Lots*/
extern bool _IsAllowBuy = true; /*OpenDirectBuy*/
extern bool _IsAllowSell = true; /*OpenDirectSell*/

int _magic = 20191025;
double _lotsExplode = 1.55;
int _hour = 0;
double _size = 170;
int _firstTp = 120;
int _maxOrderPerDay = 1;
/*
4 5 6 10 11 12 16 17 18 22 23 0
*/
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
//---
   bool isAccess=false;
   /*if(IsDemo() || (IsTesting())) { //&& !IsVisualMode()
      isAccess=true;
   }*/
   
   if(((TimeYear(TimeCurrent())==2019) && TimeMonth(TimeCurrent())==12) 
   || ((TimeYear(TimeCurrent())==2020) && TimeMonth(TimeCurrent())==1))
   {
      isAccess=true;
   }
//---
   if(!isAccess) {
      Print("INITIAL FAIL");
      return(INIT_FAILED);
   }
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
//---

}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {

   if(_hour != Hour()) {
      // Get Info Order
      double minPriceBuy,maxPriceBuy,minPriceSell,maxPriceSell;
      int buyCnt,sellCnt,buyDayOrder,sellDayOrder;
      CountOp(minPriceBuy,maxPriceBuy,minPriceSell,maxPriceSell,buyCnt,sellCnt,buyDayOrder,sellDayOrder);

      if(_IsAllowBuy) {

         if(_maxOrderPerDay > buyDayOrder && (minPriceBuy == 0 || minPriceBuy > Ask + _size * Point)) {
            if(CheckSignal(OP_BUY)) {
               double lot = NormalizeDouble(_lots * MathPow(_lotsExplode,buyCnt), 2);
               lot = MathMax(lot,_lots);

               double tp = calTakeProfit(OP_BUY);
               int ticket=OrderSend(Symbol(),OP_BUY,lot,Ask,3,0,tp,_hour,_magic);
               if(ticket > 0) {

                  markIsSwBuy = false;
                  markIsMinBuy = false;



                  int i = 0;
                  while(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) {
                     if(Symbol()==OrderSymbol()
                           && OrderMagicNumber()==_magic
                           && OrderType() == OP_BUY
                       ) {
                        if(OrderTakeProfit() != tp) {
                           OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),tp,NULL,clrNONE);
                        }
                     }
                     i++;
                  }
               }
            }
         }
      }

      if(_IsAllowSell && CheckSignal(OP_SELL)) {
         if(_maxOrderPerDay > sellDayOrder && (maxPriceSell == 0 || maxPriceSell < Bid - _size * Point)) {
            double lot = NormalizeDouble(_lots * MathPow(_lotsExplode,sellCnt), 2);
            lot = MathMax(lot,_lots);

            double tp = calTakeProfit(OP_SELL);
            int ticket=OrderSend(Symbol(),OP_SELL,lot,Bid,3,0,tp,_hour,_magic);
            if(ticket > 0) {

               markIsSwSell = false;
               markIsMinSell = false;

               int i = 0;
               while(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) {
                  if(Symbol()==OrderSymbol()
                        && OrderMagicNumber()==_magic
                        && OrderType() == OP_SELL
                    ) {
                     if(OrderTakeProfit() != tp) {
                        OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),tp,NULL,clrNONE);
                     }
                  }
                  i++;
               }
            }
         }
      }
      _hour = Hour();
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calTakeProfit(int OpOrder) {

   int i = 0;
   double averagePrice=0;
   double count=0;
   double tp = 0;
   while(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) {
      if(Symbol()==OrderSymbol()
            && OrderMagicNumber()==_magic
            && OrderType() == OpOrder
        ) {

         averagePrice += OrderOpenPrice()*OrderLots();
         count += OrderLots();
      }
      i++;
   }
   if(count > 0) {
      tp = NormalizeDouble(averagePrice/count,Digits);
   } else if(OpOrder == OP_BUY) {
      tp = Ask + _firstTp * Point;
   } else if(OpOrder == OP_SELL) {
      tp = Bid - _firstTp * Point;
   }

   return tp;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CountOp(double &minPriceBuy
             , double &maxPriceBuy
             , double &minPriceSell
             , double &maxPriceSell
             , int &opCntBuy
             , int &opCntSell
             , int &dayCntBuy
             , int &dayCntSell) {
   minPriceBuy = 0;
   maxPriceSell = 0;
   opCntBuy= 0;
   opCntSell = 0;
   dayCntBuy = 0;
   dayCntSell = 0;
   int i = 0;
   while(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) {
      if(Symbol()==OrderSymbol()
            && OrderMagicNumber()==_magic
        ) {
         if(OrderType() == OP_BUY) {
            if(minPriceBuy == 0) {
               minPriceBuy = OrderOpenPrice();
            } else {
               minPriceBuy  = MathMin(minPriceBuy,OrderOpenPrice());
            }

            if(maxPriceBuy == 0) {
               maxPriceBuy = OrderOpenPrice();
            } else {
               maxPriceBuy  = MathMax(maxPriceBuy,OrderOpenPrice());
            }

            if(TimeMonth(OrderOpenTime()) == Month() && TimeDay(OrderOpenTime()) == Day()) {
               dayCntBuy++;
            }

            opCntBuy++;
         } else if(OrderType() == OP_SELL) {
            if(minPriceSell == 0) {
               minPriceSell = OrderOpenPrice();
            } else {
               minPriceSell  = MathMin(minPriceSell,OrderOpenPrice());
            }

            if(maxPriceSell == 0) {
               maxPriceSell = OrderOpenPrice();
            } else {
               maxPriceSell  = MathMax(maxPriceSell,OrderOpenPrice());
            }

            if(TimeMonth(OrderOpenTime()) == Month() && TimeDay(OrderOpenTime()) == Day()) {
               dayCntSell++;
            }

            opCntSell++;
         }
      }
      i++;
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool markIsSwBuy = false,markIsSwSell = false;
bool markIsMinBuy = false,markIsMinSell = false;
bool CheckSignal(int OpOrder) {

   int cntSw = 0;
   int bar = 0;
   double swPrice = 0;

   while(bar <= 72) {

      if(swPrice == 0 ) {
         swPrice = Open[0];
      } else {
         double max = swPrice + 10 * Point;
         double min = swPrice - 10 * Point;
         if( (max > Open[bar] && Open[bar] > min )
               || (max > Close[bar] && Close[bar] > min )
               || (max > High[bar] && High[bar] > min )
               || (max > Low[bar] && Low[bar] > min ) ) {
            cntSw++;
         }
      }
      bar++;
   }

   bool result = false;
   if(OP_BUY == OpOrder) {

      bar =2;
      double minPrice = 0;
      while(bar <= 12) {
         double price = Open[bar];
         if( minPrice  == 0 ) {
            minPrice = price;
         } else {
            minPrice = MathMin(price, minPrice);
         }
         bar++;
      }

      if(minPrice > Open[0]) {
         markIsMinBuy = true;
      }
      if(cntSw >= 10 ) {
         markIsSwBuy = true;
      }
      int idxLowest = iLowest(NULL,PERIOD_H1,MODE_LOW,24,2);
      bool isLowest = (Low[idxLowest] + 20 * Point) > Ask;

      result = markIsSwBuy && isLowest && markIsMinBuy;
   } else {

      bar =2;
      double maxPrice = 0;
      while(bar <= 12) {
         double price = Open[bar];
         if( maxPrice  == 0 ) {
            maxPrice = price;
         } else {
            maxPrice = MathMax(price, maxPrice);
         }
         bar++;
      }

      if(maxPrice < Bid) {
         markIsMinSell = true;
      }
      if(cntSw >= 10 ) {
         markIsSwSell = true;
      }
      int idxLowest = iLowest(NULL,PERIOD_H1,MODE_HIGH,24,2);
      bool isLowest = (High[idxLowest] - 20 * Point) < Bid;
      result = markIsSwSell && markIsMinSell && isLowest;
   }
   return result;
}
//+------------------------------------------------------------------+
