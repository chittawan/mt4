//+------------------------------------------------------------------+
//|                  Safe Martingale Pro Expert Advisor             |
//|        Features: Dynamic TP, Distance-Based, Fibo Recovery      |
//|        Supports: Trailing Stop or Immediate Close on Profit     |
//+------------------------------------------------------------------+
#property strict

//-----------------------
// External Parameters
//-----------------------
extern int    version                     = 3;
extern bool   AllowBuy                    = true;
extern bool   AllowSell                   = true;
   

extern double StartLot                    = 0.01;
extern int    MaxSteps                    = 100;
extern double MaxLot                      = 2.0;
extern int    MagicNumber                 = 212225;

extern int    MinDistancePoints           = 1000;   // Minimum distance between orders in points
extern int    FirstOrderTPPoints          = 0;   // TP points for the first order

extern string AutoTailing = "----- AutoTailing -----";
extern bool   UseTrailingStop             = true;
extern int    TrailingProfitBufferPoints  = 150;    // Distance from current price for SL
extern int    TrailingStepPoints          = 50;     // Minimum step to adjust SL
extern double MinimumProfitToClose        = 2.0;    // Minimum profit for immediate close when not using trailing

extern string Fibonancii = "----- Fibo -----";
extern double FiboRetracementLevel        = 0.236;

//-----------------------
// Internal Variables
//-----------------------
int stepBuy = 0, stepSell = 0;
double CurrentLotBuy = 0.0, CurrentLotSell = 0.0;
datetime lastBuyBar = 0, lastSellBar = 0;
datetime lastCheckedBarTime = 0;
double drawPriceToTP_Buy = 0.0;
double drawPriceToTP_Sell = 0.0;

//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    RebuildStateFromOrders();
    Comment("");
    return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Main Tick Logic                                                  |
//+------------------------------------------------------------------+
void OnTick()
{
    RebuildStateFromOrders();
    UpdateDashboard();
    DrawDashboard();

    bool isBarChange = false;
    // Open new orders only at the start of a new bar
    if (Time[0] != lastCheckedBarTime)
    {
        lastCheckedBarTime = Time[0];
        isBarChange = true;

        if (AllowBuy) {
            ManageMartingale(OP_BUY, stepBuy, CurrentLotBuy);
        }  
        if (AllowSell) {
            ManageMartingale(OP_SELL, stepSell, CurrentLotSell);    
        } 
    }

    // Manage existing orders with trailing stop or immediate close
    if (AllowBuy)
    {
        CalculateBreakEvenPrice(OP_BUY);
        if (UseTrailingStop) {
            if(stepBuy == 1) {
                if (isBarChange){
                    CloseProfitableLastOrders(OP_BUY, 20);
                }
            } else {
                CloseProfitableLastOrders(OP_BUY, 20);
            }
        } else {
            CloseProfitableImmediately(OP_BUY, MinimumProfitToClose);
        }
    }

    if (AllowSell)
    {
        CalculateBreakEvenPrice(OP_SELL);
        if (UseTrailingStop) {
            if (stepSell == 1) {
                if(isBarChange){
                    CloseProfitableLastOrders(OP_BUY, 20);
                }
            } else {
                CloseProfitableLastOrders(OP_SELL, 20);
            }
        } else {
            CloseProfitableImmediately(OP_SELL, MinimumProfitToClose);
        }
    }
}

//+------------------------------------------------------------------+
//| Get safe lot size respecting broker constraints                  |
//+------------------------------------------------------------------+
double GetSafeLot(double rawLot)
{
    double step = MarketInfo(Symbol(), MODE_LOTSTEP);
    double minLot = MarketInfo(Symbol(), MODE_MINLOT);
    double maxLot = MarketInfo(Symbol(), MODE_MAXLOT);

    double normalized = MathFloor(rawLot / step) * step;

    if (normalized < minLot) return minLot;
    if (normalized > maxLot) return maxLot;

    return NormalizeDouble(normalized, 2);
}

//+------------------------------------------------------------------+
//| Calculate next lot using incremental growth (5% per step)       |
//+------------------------------------------------------------------+
double CalculateNextLot(int step, double baseLot)
{
    double lot = baseLot * MathPow(1.05, step); // Increase by 5% per step
    return GetSafeLot(MathMin(lot, MaxLot));
}

//+------------------------------------------------------------------+
//| Rebuild state from current open orders                          |
//+------------------------------------------------------------------+
void RebuildStateFromOrders()
{
    stepBuy = 0; stepSell = 0;
    double maxLotBuy = 0, maxLotSell = 0;

    for (int i = 0; i < OrdersTotal(); i++)
    {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderMagicNumber() == MagicNumber)
        {
            if (OrderType() == OP_BUY)
            {
                stepBuy++;
                if (OrderLots() > maxLotBuy) maxLotBuy = OrderLots();
            }
            else if (OrderType() == OP_SELL)
            {
                stepSell++;
                if (OrderLots() > maxLotSell) maxLotSell = OrderLots();
            }
        }
    }

    CurrentLotBuy = (stepBuy > 0) ? GetSafeLot(maxLotBuy) : GetSafeLot(StartLot);
    CurrentLotSell = (stepSell > 0) ? GetSafeLot(maxLotSell) : GetSafeLot(StartLot);
}

//+------------------------------------------------------------------+
//| Calculate next lot based on Fibonacci recovery method           |
//+------------------------------------------------------------------+
double CalculateNextLotFromFiboRecovery(int orderType, double baseLot, double targetProfitPerOrder = 0)
{
    double minPrice = -1, maxPrice = -1;
    double totalLots = 0, totalLoss = 0;
    double currentPrice = (orderType == OP_BUY) ? Ask : Bid;
    double pointValue = Point;

    // Collect order data for the same type
    for (int i = 0; i < OrdersTotal(); i++)
    {
        if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
        if (OrderType() != orderType) continue;

        double price = OrderOpenPrice();
        double lot = OrderLots();

        if (minPrice == -1 || price < minPrice) minPrice = price;
        if (maxPrice == -1 || price > maxPrice) maxPrice = price;

        totalLots += lot;

        // Calculate unrealized loss
        if (orderType == OP_BUY)
            totalLoss += (currentPrice - price) * lot / pointValue;
        else
            totalLoss += (price - currentPrice) * lot / pointValue;
    }

    if (totalLots == 0) return baseLot;

    // Calculate price range
    double priceRange = MathAbs(maxPrice - minPrice);

    // 23.6% Fibonacci retracement level
    double recoveryDistance = priceRange * FiboRetracementLevel;
    
    
    
    // Distance from current price to Fibo TP
    double priceToTP = (orderType == OP_BUY)
                       ? (minPrice + recoveryDistance) - currentPrice
                       : currentPrice - (maxPrice - recoveryDistance);

    if (priceToTP <= 0.00001) return baseLot;

    // Calculate lot required to cover current loss
    double requiredProfit = MathAbs(totalLoss) + targetProfitPerOrder;
    double nextLot = requiredProfit / (priceToTP / pointValue);
    return GetSafeLot(nextLot);
}

//+------------------------------------------------------------------+
//| Main martingale management                                      |
//+------------------------------------------------------------------+
void ManageMartingale(int orderType, int &step, double &currentLot)
{
    double minPrice, maxPrice;
    GetExtremePrices(orderType, minPrice, maxPrice);

    bool hasOrders = HasOpenOrders(orderType);
    datetime lastBarRef = (orderType == OP_BUY) ? lastBuyBar : lastSellBar;

    // Avoid multiple entries in the same bar
    if (lastBarRef == Time[0]) return;

    if (!hasOrders)
    {
        // First order entry if signal confirms
        if (IsSignalConfirmed(orderType))
        {
            step = 0;
            currentLot = StartLot;
            OpenOrder(orderType, currentLot, minPrice, maxPrice, step);
            if (orderType == OP_BUY) lastBuyBar = Time[0];
            else lastSellBar = Time[0];
        }
    }
    else
    {
        // Add next order if allowed
        bool shouldOpenNext = (step < MaxSteps && CanOpenNext(orderType, minPrice, maxPrice));
        if (shouldOpenNext && IsSignalConfirmed(orderType))
        {
            currentLot = CalculateNextLotFromFiboRecovery(orderType, 0.02, MinimumProfitToClose);
            OpenOrder(orderType, currentLot, minPrice, maxPrice, step);
            if (orderType == OP_BUY) lastBuyBar = Time[0];
            else lastSellBar = Time[0];
        }
    }
}

//+------------------------------------------------------------------+
//| Check if there are open orders of a specific type               |
//+------------------------------------------------------------------+
bool HasOpenOrders(int orderType)
{
    for (int i = 0; i < OrdersTotal(); i++)
    {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) &&
            OrderMagicNumber() == MagicNumber &&
            OrderType() == orderType)
        {
            return true;
        }
    }
    return false;
}

//+------------------------------------------------------------------+
//| Check if next order can be opened based on minimum distance      |
//+------------------------------------------------------------------+
bool CanOpenNext(int orderType, double minPrice, double maxPrice)
{
    if (orderType == OP_BUY)
        return (maxPrice == 0 || Ask < minPrice - MinDistancePoints * Point);
    else
        return (minPrice == 0 || Bid > maxPrice + MinDistancePoints * Point);
}

//+------------------------------------------------------------------+
//| Open a new order with optional TP for the first order            |
//+------------------------------------------------------------------+
void OpenOrder(int orderType, double lot, double minPrice, double maxPrice, int step)
{
    double price = (orderType == OP_BUY) ? Ask : Bid;
    double tp = 0, sl = 0;

    // Apply TP for the first order
    if (step == 0 && FirstOrderTPPoints > 0)
    {
        tp = (orderType == OP_BUY)
             ? price + FirstOrderTPPoints * Point
             : price - FirstOrderTPPoints * Point;
    }

    OrderSend(Symbol(), orderType, lot, price, 3, sl, tp,
              (orderType == OP_BUY) ? "Martingale Buy" : "Martingale Sell",
              MagicNumber, 0, (orderType == OP_BUY) ? clrBlue : clrRed);
}

//+------------------------------------------------------------------+
//| Find extreme (min/max) open prices for a given order type        |
//+------------------------------------------------------------------+
void GetExtremePrices(int orderType, double &minPrice, double &maxPrice)
{
    minPrice = 0; maxPrice = 0;
    for (int i = 0; i < OrdersTotal(); i++)
    {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) &&
            OrderMagicNumber() == MagicNumber &&
            OrderType() == orderType)
        {
            if (minPrice == 0 || OrderOpenPrice() < minPrice) minPrice = OrderOpenPrice();
            if (maxPrice == 0 || OrderOpenPrice() > maxPrice) maxPrice = OrderOpenPrice();
        }
    }
}

//+------------------------------------------------------------------+
//| Close last N profitable orders using trailing stop logic         |
//+------------------------------------------------------------------+
void CloseProfitableLastOrders(int orderType, int nOrders)
{
    struct OrderInfo { int ticket; double openPrice; double lot; double swap; double commission; };
    OrderInfo orders[];
    ArrayResize(orders, 0);

    // Collect last N orders of this type
    for (int i = OrdersTotal() - 1; i >= 0; i--)
    {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            if (OrderMagicNumber() == MagicNumber && OrderType() == orderType)
            {
                OrderInfo oi;
                oi.ticket = OrderTicket();
                oi.openPrice = OrderOpenPrice();
                oi.lot = OrderLots();
                oi.swap = OrderSwap();
                oi.commission = OrderCommission();

                int oldSize = ArraySize(orders);
                ArrayResize(orders, oldSize + 1);
                for (int j = oldSize; j > 0; j--) orders[j] = orders[j - 1];
                orders[0] = oi;

                if (ArraySize(orders) >= nOrders) break;
            }
        }
    }

    double price = (orderType == OP_BUY) ? Bid : Ask;
    double pointValue = MarketInfo(Symbol(), MODE_TICKVALUE);

    // Proposed SL for trailing
    double proposedSL = (orderType == OP_BUY)
                        ? price - TrailingProfitBufferPoints * Point
                        : price + TrailingProfitBufferPoints * Point;

    // Simulate total profit if SL hits
    double estimatedTotalProfit = 0.0;
    for (int i = 0; i < ArraySize(orders); i++)
    {
        double priceDiff = (orderType == OP_BUY)
                           ? (proposedSL - orders[i].openPrice)
                           : (orders[i].openPrice - proposedSL);
        double profit = (priceDiff / Point) * pointValue * orders[i].lot;
        profit += orders[i].swap + orders[i].commission;
        estimatedTotalProfit += profit;
    }

    if (estimatedTotalProfit < 0) return;

    // Apply SL if profitable
    for (int i = 0; i < ArraySize(orders); i++)
    {
        if (OrderSelect(orders[i].ticket, SELECT_BY_TICKET))
        {
            double currentSL = OrderStopLoss();
            double openPrice = OrderOpenPrice();
            bool needToModify = false;

            if (orderType == OP_BUY)
            {
                if (currentSL == 0 || proposedSL > currentSL + TrailingStepPoints * Point)
                    needToModify = true;
            }
            else
            {
                if (currentSL == 0 || proposedSL < currentSL - TrailingStepPoints * Point)
                    needToModify = true;
            }

            if (needToModify)
            {
                OrderModify(OrderTicket(), openPrice, proposedSL, OrderTakeProfit(), 0, clrGreen);
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Close last N orders immediately if total profit > threshold      |
//+------------------------------------------------------------------+
void CloseProfitableImmediately(int orderType, double minProfit)
{
    struct OrderInfo { int openTime; int ticket; double profit; };
    OrderInfo orders[];
    ArrayResize(orders, 0);

    // Collect orders of this type
    for (int i = 0; i < OrdersTotal(); i++)
    {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) &&
            OrderMagicNumber() == MagicNumber && OrderType() == orderType)
        {
            OrderInfo oi;
            oi.openTime = OrderOpenTime();
            oi.ticket = OrderTicket();
            oi.profit = OrderProfit() + OrderSwap() + OrderCommission();
            ArrayResize(orders, ArraySize(orders) + 1);
            orders[ArraySize(orders) - 1] = oi;
        }
    }

    if (ArraySize(orders) == 0) return;

    double totalProfit = 0.0;
    for (int k = 0; k < ArraySize(orders); k++) totalProfit += orders[k].profit;

    if (totalProfit >= minProfit)
    {
        for (int k = 0; k < ArraySize(orders); k++)
        {
            if (OrderSelect(orders[k].ticket, SELECT_BY_TICKET))
            {
                OrderClose(orders[k].ticket, OrderLots(), OrderClosePrice(), 3, clrRed);
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Signal confirmation logic (replace with real conditions)         |
//+------------------------------------------------------------------+
bool IsSignalConfirmed(int orderType)
{
    // Example RSI condition placeholder
    // double rsi = iRSI(Symbol(), 0, 14, PRICE_CLOSE, 0);
    return true;
}

double CalculateBreakEvenPrice(int orderType)
{
    double totalLots = 0;
    double weightedPriceSum = 0;
    double extraCosts = 0; // Swap + Commission
    double tickValue = MarketInfo(Symbol(), MODE_TICKVALUE);
    double spreadPoints = MarketInfo(Symbol(), MODE_SPREAD); // Spread ใน Points

    for (int i = 0; i < OrdersTotal(); i++)
    {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            if (OrderMagicNumber() == MagicNumber && OrderType() == orderType)
            {
                double lot = OrderLots();
                double openPrice = OrderOpenPrice();

                weightedPriceSum += openPrice * lot;
                totalLots += lot;

                extraCosts += (OrderSwap() + OrderCommission());
            }
        }
    }

    if (totalLots == 0) return 0; // ไม่มีออเดอร์

    double averagePrice = weightedPriceSum / totalLots;

    // ✅ ปรับสำหรับ Costs + TargetProfit + Trailing + Spread
    double adjustmentFromCosts = extraCosts / (totalLots * tickValue / Point);
    double adjustmentFromTargetProfit = MinimumProfitToClose / (totalLots * tickValue / Point);
    double adjustmentFromTrailing = (UseTrailingStop) ? TrailingProfitBufferPoints : 0;

    double totalAdjustment = adjustmentFromCosts + adjustmentFromTargetProfit + adjustmentFromTrailing;

    double breakEvenPrice;
    if (orderType == OP_BUY)
        breakEvenPrice = averagePrice + (totalAdjustment + spreadPoints) * Point;  // BUY บวก spread
    else
        breakEvenPrice = averagePrice - (totalAdjustment + spreadPoints) * Point;  // SELL ลบ spread

    // เก็บค่าไว้สำหรับวาดเส้น
    if (orderType == OP_BUY)
        drawPriceToTP_Buy = breakEvenPrice;
    else
        drawPriceToTP_Sell = breakEvenPrice;

    return breakEvenPrice;
}


void DrawDashboard()
{
    datetime t1 = Time[0];
    datetime t2 = Time[1]; // เอาแท่งก่อนหน้า ทำให้เส้นสั้นแค่ 1 แท่ง

    if (drawPriceToTP_Buy > 0)
    {
        if (ObjectFind(0, "FiboTP_Buy") == -1)
        {
            ObjectCreate(0, "FiboTP_Buy", OBJ_TREND, 0, t2, drawPriceToTP_Buy, t1, drawPriceToTP_Buy);
            ObjectSetInteger(0, "FiboTP_Buy", OBJPROP_COLOR, clrLime);
            ObjectSetInteger(0, "FiboTP_Buy", OBJPROP_WIDTH, 3);
            ObjectSetInteger(0, "FiboTP_Buy", OBJPROP_RAY, false);
        }
        else
        {
            ObjectMove(0, "FiboTP_Buy", 0, t2, drawPriceToTP_Buy);
            ObjectMove(0, "FiboTP_Buy", 1, t1, drawPriceToTP_Buy);
        }
    }

    if (drawPriceToTP_Sell > 0)
    {
        if (ObjectFind(0, "FiboTP_Sell") == -1)
        {
            ObjectCreate(0, "FiboTP_Sell", OBJ_TREND, 0, t2, drawPriceToTP_Sell, t1, drawPriceToTP_Sell);
            ObjectSetInteger(0, "FiboTP_Sell", OBJPROP_COLOR, clrRed);
            ObjectSetInteger(0, "FiboTP_Sell", OBJPROP_WIDTH, 3);
            ObjectSetInteger(0, "FiboTP_Sell", OBJPROP_RAY, false);
        }
        else
        {
            ObjectMove(0, "FiboTP_Sell", 0, t2, drawPriceToTP_Sell);
            ObjectMove(0, "FiboTP_Sell", 1, t1, drawPriceToTP_Sell);
        }
    }
}


//+------------------------------------------------------------------+
//| Update dashboard on chart                                       |
//+------------------------------------------------------------------+
void UpdateDashboard()
{
    double totalProfit = 0;
    int trades = 0;
    for (int i = OrdersTotal() - 1; i >= 0; i--)
    {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderMagicNumber() == MagicNumber)
        {
            totalProfit += OrderProfit() + OrderSwap() + OrderCommission();
            trades++;
        }
    }

    string msg = "Safe Martingale Pro EA\n"
                 + "Buy Steps: " + IntegerToString(stepBuy) + " | Lot: " + DoubleToString(CurrentLotBuy, 2) + "\n"
                 + "Sell Steps: " + IntegerToString(stepSell) + " | Lot: " + DoubleToString(CurrentLotSell, 2) + "\n"
                 + "Open Trades: " + IntegerToString(trades) + "\n"
                 + "Total Profit: " + DoubleToString(totalProfit, 2) + "\n"
                 + "Min Distance: " + IntegerToString(MinDistancePoints) + " pts";
    Comment(msg);
}
//+------------------------------------------------------------------+
