// Safe Martingale Pro EA - Dynamic TP + Distance + Hedge
#property strict

extern int version = 3;
extern double StartLot = 0.01;
extern double Multiplier = 1.1;
extern int MaxSteps = 100;
extern double MaxLot = 2.0;
extern double StopLoss = 0;
extern int MagicNumber = 212225;
extern bool AllowBuy = true;
extern bool AllowSell = true;
extern double MinDistancePoints = 50;
extern int FirstOrderTPPoints = 20;  // TP points for the first order

int stepBuy = 0, stepSell = 0;
double CurrentLotBuy = 0.0, CurrentLotSell = 0.0;
datetime lastBuyBar = 0;
datetime lastSellBar = 0;

int OnInit() {
    RebuildStateFromOrders();
    Comment("");
    return INIT_SUCCEEDED;
}

void OnTick() {
    UpdateDashboard();

    ManageMartingale(OP_BUY, stepBuy, CurrentLotBuy);
    ManageMartingale(OP_SELL, stepSell, CurrentLotSell);

    CloseProfitableLastOrders(OP_BUY, 2);
    CloseProfitableLastOrders(OP_SELL, 2);
}

double GetSafeLot(double rawLot) {
    double step = MarketInfo(Symbol(), MODE_LOTSTEP);
    double minLot = MarketInfo(Symbol(), MODE_MINLOT);
    double maxLot = MarketInfo(Symbol(), MODE_MAXLOT);

    double normalized = MathFloor(rawLot / step) * step;

    if (normalized < minLot) return minLot;
    if (normalized > maxLot) return maxLot;

    return NormalizeDouble(normalized, 2);
}

double CalculateNextLot(int step, double baseLot) {
    int fibIndex = step / 2 + 1;
    int fib = 1, prev = 0;
    for (int i = 0; i < fibIndex; i++) {
        int temp = fib;
        fib = fib + prev;
        prev = temp;
    }
    double lot = baseLot * fib;
    lot = MathMin(lot, MaxLot);
    return GetSafeLot(lot);
}

void RebuildStateFromOrders() {
    stepBuy = 0;
    stepSell = 0;
    double maxLotBuy = 0, maxLotSell = 0;

    for (int i = 0; i < OrdersTotal(); i++) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) &&
            OrderMagicNumber() == MagicNumber) {
            if (OrderType() == OP_BUY) {
                stepBuy++;
                if (OrderLots() > maxLotBuy) maxLotBuy = OrderLots();
            } else if (OrderType() == OP_SELL) {
                stepSell++;
                if (OrderLots() > maxLotSell) maxLotSell = OrderLots();
            }
        }
    }

    CurrentLotBuy = stepBuy > 0 ? GetSafeLot(maxLotBuy) : GetSafeLot(StartLot);
    CurrentLotSell = stepSell > 0 ? GetSafeLot(maxLotSell) : GetSafeLot(StartLot);
}

void ManageMartingale(int orderType, int &step, double &currentLot) {
    double minPrice, maxPrice;
    GetExtremePrices(orderType, minPrice, maxPrice);

    bool hasOrders = HasOpenOrders(orderType);

    // Reference to the last opened bar timestamp for the given order type
    datetime lastBarRef = (orderType == OP_BUY) ? lastBuyBar : lastSellBar;

    // Prevent opening multiple orders in the same candle/bar
    if (lastBarRef == Time[0]) return;

    if (!hasOrders) {
        // If there are no open orders and signal is confirmed
        if (IsSignalConfirmed(orderType)) {
            step = 0;
            currentLot = StartLot;
            OpenOrder(orderType, currentLot, minPrice, maxPrice, step);
            
            // Mark current candle as used
            if (orderType == OP_BUY) lastBuyBar = Time[0];
            else if (orderType == OP_SELL) lastSellBar = Time[0];
        }
    } else {
        // If max step not reached and price is far enough from previous orders
        bool shouldOpenNext = (step < MaxSteps && CanOpenNext(orderType, minPrice, maxPrice));
        if (shouldOpenNext && IsSignalConfirmed(orderType)) {
            step++;
            currentLot = CalculateNextLot(step, StartLot);
            OpenOrder(orderType, currentLot, minPrice, maxPrice, step);
            
            // Mark current candle as used
            if (orderType == OP_BUY) lastBuyBar = Time[0];
            else if (orderType == OP_SELL) lastSellBar = Time[0];
        }
    }
}



// Check if there are open orders of specific type
bool HasOpenOrders(int orderType) {
    for (int i = 0; i < OrdersTotal(); i++) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) &&
            OrderMagicNumber() == MagicNumber &&
            OrderType() == orderType) {
            return true;
        }
    }
    return false;
}

// Check if next order can be opened based on min distance points
bool CanOpenNext(int orderType, double minPrice, double maxPrice) {
    if (orderType == OP_BUY)
        return (maxPrice == 0 || Ask < minPrice - MinDistancePoints * Point);
    else
        return (minPrice == 0 || Bid > maxPrice + MinDistancePoints * Point);
}

// Open new order with optional TP for first order
void OpenOrder(int orderType, double lot, double minPrice, double maxPrice, int step) {
    double price = (orderType == OP_BUY) ? Ask : Bid;
    double tp = 0;
    double sl = 0;

    // Set TP for first order at fixed distance
    if (step == 0 && FirstOrderTPPoints > 0) {
        if (orderType == OP_BUY) {
            tp = price + FirstOrderTPPoints * Point;
        } else {
            tp = price - FirstOrderTPPoints * Point;
        }
    }

    // Set stop loss if defined
    if (StopLoss > 0) {
        sl = (orderType == OP_BUY) ? price - StopLoss * Point : price + StopLoss * Point;
    }

    OrderSend(Symbol(), orderType, lot, price, 3, sl, tp,
              (orderType == OP_BUY) ? "Martingale Buy" : "Martingale Sell",
              MagicNumber, 0, (orderType == OP_BUY) ? clrBlue : clrRed);
}

// Find min and max open prices of current orders for given order type
void GetExtremePrices(int orderType, double &minPrice, double &maxPrice) {
    minPrice = 0;
    maxPrice = 0;
    for (int i = 0; i < OrdersTotal(); i++) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) &&
            OrderMagicNumber() == MagicNumber &&
            OrderType() == orderType) {
            if (minPrice == 0 || OrderOpenPrice() < minPrice) minPrice = OrderOpenPrice();
            if (maxPrice == 0 || OrderOpenPrice() > maxPrice) maxPrice = OrderOpenPrice();
        }
    }
}

// Close last n profitable orders if their combined profit > 0
void CloseProfitableLastOrders(int orderType, int nOrders) {
    struct OrderInfo {
        int openTime;
        int ticket;
        double profit;
    };
    OrderInfo orders[];
    ArrayResize(orders, 0);

    // Collect orders info
    for (int i = 0; i < OrdersTotal(); i++) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) &&
            OrderMagicNumber() == MagicNumber &&
            OrderType() == orderType) {
            OrderInfo oi;
            oi.openTime = OrderOpenTime();
            oi.ticket = OrderTicket();
            oi.profit = OrderProfit() + OrderSwap() + OrderCommission();
            ArrayResize(orders, ArraySize(orders) + 1);
            orders[ArraySize(orders) - 1] = oi;
        }
    }

    // Sort orders by open time descending (latest first)
    for (int i = 0; i < ArraySize(orders) - 1; i++) {
        for (int j = i + 1; j < ArraySize(orders); j++) {
            if (orders[i].openTime < orders[j].openTime) {
                OrderInfo temp = orders[i];
                orders[i] = orders[j];
                orders[j] = temp;
            }
        }
    }

    if (ArraySize(orders) < nOrders) return;

    double totalProfit = 0.0;
    for (int k = 0; k < nOrders; k++) {
        totalProfit += orders[k].profit;
    }

    if (totalProfit > 0) {
        for (int k = 0; k < nOrders; k++) {
            if (OrderSelect(orders[k].ticket, SELECT_BY_TICKET)) {
                OrderClose(orders[k].ticket,
                           OrderLots(),
                           OrderClosePrice(),
                           3, clrRed);
            }
        }
    }
}

// Return true if external signal allows opening order of given type
bool IsSignalConfirmed(int orderType) {
    // TODO: Replace this with real signal logic
    // For now, it always returns true for both Buy and Sell
    double rsi = iRSI(Symbol(), 0, 14, PRICE_CLOSE, 0);
    if (orderType == OP_BUY) {
        // Add your Buy signal condition here
        //return true;
        return rsi < 30;
    } else if (orderType == OP_SELL) {
        // Add your Sell signal condition here
        //return true;
        return rsi > 70;
    }
    return false;
}


// Update on-screen info dashboard
void UpdateDashboard() {
    double totalProfit = 0;
    int trades = 0;
    for (int i = OrdersTotal() - 1; i >= 0; i--) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) &&
            OrderMagicNumber() == MagicNumber) {
            totalProfit += OrderProfit() + OrderSwap() + OrderCommission();
            trades++;
        }
    }

    string msg = "Safe Martingale Pro - Dynamic TP + Distance + Hedge\n"
                 + "Buy Step: " + IntegerToString(stepBuy) + " | Lot: " + DoubleToString(CurrentLotBuy, 2) + "\n"
                 + "Sell Step: " + IntegerToString(stepSell) + " | Lot: " + DoubleToString(CurrentLotSell, 2) + "\n"
                 + "Open Trades: " + IntegerToString(trades) + "\n"
                 + "Total Profit: " + DoubleToString(totalProfit, 2) + "\n"
                 + "Min Distance: " + DoubleToString(MinDistancePoints, 0) + " points";
    Comment(msg);
}
