#property copyright "Clevr FX";
#property link "https://clevrfx.com/";
#property version "3.00";
#property strict
#include <EasyXml/easyxml.mqh>
#import "wininet.dll"

int InternetAttemptConnect(int);
int InternetOpenW(string,int,string,string,int);
int InternetOpenUrlW(int,string,string,int,int,int);
int InternetReadFile(int,uchar&[],int,int&[]);
int HttpQueryInfoW(int,int,uchar&[],int&,int&);
int InternetCloseHandle(int);

#import "shell32.dll"

int ShellExecuteW(int,const string,const string,const string,const string,int);

#import

enum StratType
{
   rsi = 0, // Low Risk
   med = 1, // Medium Risk
   hed = 2, // High Reward
   man = 3 // Manual
};

enum LotType
{
   ltauto = 0, // Automatic
   ltmanu = 1 // Manual
};

enum LossCutType
{
   lcnone = 0, // None
   lcamount = 1, // Amount
   lcpercent = 2 // Percentage
};

enum DBType
{
   fulldb = 0, // Full
   minidb = 1, // Mini
   none = 2 // None
};

extern bool allowBuy = true; // Allow Buy
extern bool allowSell = true; // Allow Sell
extern StratType strattype = med; // Strategy Type
extern string ORDER = "======= ORDER SETTINGS ======";
extern LotType lottype = ltmanu; // Lot Type
extern double lotSize = 0.01; // Initial Lot Size (Manual)
extern double takeprofit = 10; // Trade TP (pips)
extern double lotMul = 1.5; // Lot Multiplier
extern double lotMax; // Max Lot Limit
extern int mulSkip = 1; // Increase Lot Size After Trades
extern double dist2 = 20; // 2nd Trade Distance
extern double dist3 = 1; // 3rd Trade Distance Multiplier
extern double dist4 = 1; // Next Trades Distance Multiplier
extern string RISK_MANAGEMENT = "====== RISK MANAGEMENT =====";
extern bool oneTradePerCandle = true; // One Trade Per Candle
extern bool allowHedge = true; // Allow Hedge
extern double maxspread; // Maximum Spread (0=No Limit)
extern int tradeLimit = 20; // Max Trades Per Side (0=Max)
extern int maxPairs; // Max Pairs To Trade (0=No Limit)
extern string LOSS_CUT = "========= LOSS CUT =========";
extern LossCutType lossCutType = lcnone; // Loss Cut Type
extern double lcvalue = 1000; // Loss Cut Value
extern string DD_RECOVERY = "======== DD RECOVERY ========";
extern bool ddRecovery = true; // Use DD Recovery
extern int ddrCount = 3; // Start After Trades
extern double ddrProfit = 1; // DDR Profit
extern string RSI_ = "======= RSI SETTINGS ========"; // RSI
extern int rsiperiod = 9; // Period
extern ENUM_APPLIED_PRICE rsiprice = PRICE_CLOSE; // Applied Price
extern double roverbought = 70; // Over Bought
extern double roversold = 30; // Over Sold
extern string MA_ = "======== MA SETTINGS ========"; // MA
extern int ma1period = 5; // Period
extern int ma1shift; // Shift
extern ENUM_MA_METHOD ma1method = MODE_SMA; // Method
extern ENUM_APPLIED_PRICE ma1price = PRICE_CLOSE; // Applied Price
extern string TIME_MANAGEMNET = "====== TIME MANAGEMENT ======";
extern bool use_date; // Use Timer
extern string startTime = "7:00"; // Trading Start Time
extern string endTime = "19:00"; // Trading End Time
extern string DAY_MANAGEMNET = "======= DAY MANAGEMENT =======";
extern bool monday = true; // Monday
extern bool tuesday = true; // Tuesday
extern bool wednesday = true; // Wednesday
extern bool thursday = true; // Thursday
extern bool friday; // Friday
extern string OTHER = "======= OTHER SETTINGS ======";
extern bool highRes; // High Resolution Display
extern DBType dbtype = fulldb; // Dashboard
extern bool showCandleProf = true; // Show Candle Profit
extern int magic = 9244; // Magic Number
extern string NEWS = "======== NEWS ========";
extern int closeBefore = 15; // Pause Before News (mins)
extern int startAfter = 30; // Start After News (mins)
extern string currencies = "AUD,CAD,EUR,GBP,JPY,NZD,USD"; // Currencies
extern string NEWS_IMPACT = "======= IMPACT =======";
extern bool highImpact = true; // High Impact
extern bool medImpact = true; // Medium Impact
extern bool lowImpact; // Low Impact
extern string NEWS_COLORS = "======= COLORS ========";
extern color clrHighNews = Red; // High News
extern color clrMedNews = Orange; // Medium News
extern color clrLowNews = Yellow; // Low News
extern string NEWS_BOX = "====== NEWS BOX ======";
extern bool showNewsBox = true; // Show News Box
extern bool showBg = true; // Create Background Box
extern color bgcolor = 0; // Background Color
extern int newsCount = 5; // Number of News
extern string NEWS_LINES = "====== NEWS LINES ======";
extern bool showNewsLines = true; // Show News Lines
extern bool showText = true; // Show News Text

struct TimeInfo
{
   public:
      int m_0;
      int m_4;
      int m_8;
};

class Node_Data
{
   public:
      string m_16;
      string m_28;
      datetime m_40;
      string m_48;

      void func_1213()
      {
      }

      Node_Data()
      {
      }

};

class HTMLParser
{
   public:
};

class ReadNews
{
   public:
      Node_Data m_16[];
      string m_68[];

      void func_1228(string Fa_s_00, bool FuncArg_Boolean_00000001)
      {
         string tmp_str0000;
         string tmp_str0001;
         CEasyXml *Local_Pointer_FFFFFFC0 = new CEasyXml();
         CEasyXmlNode* Local_Pointer_FFFFFFB8;
         CEasyXmlNode* Local_Pointer_FFFFFFB0;
         CEasyXmlNode* Local_Pointer_FFFFFFA8;
         Node_Data* Local_Pointer_FFFFFFA0;
         int Li_FF9C;
         string Ls_FF90;

         Local_Pointer_FFFFFFC0.setDebugging(false);
         tmp_str0000 = "https://nfs.faireconomy.media/ff_calendar_thisweek.xml";
         if (Local_Pointer_FFFFFFC0.loadXmlFromUrl(tmp_str0000)) { 
         Local_Pointer_FFFFFFB8 = Local_Pointer_FFFFFFC0.getDocumentRoot();
         Local_Pointer_FFFFFFB0 = Local_Pointer_FFFFFFC0.getDocumentRoot();
         Local_Pointer_FFFFFFA8 = Local_Pointer_FFFFFFB0.Children().At(0);
         Local_Pointer_FFFFFFA0 = NULL;
         Li_FF9C = 0;
         ArrayResize(this.m_68, 0, 0);
         ArrayFree(this.m_68);
         if (FuncArg_Boolean_00000001) { 
         ArrayResize(this.m_16, 0, 0);
         ArrayFree(this.m_16);
         } 
         StringSplit(Fa_s_00, 44, this.m_68);

         Gi_0002 = CheckPointer(Local_Pointer_FFFFFFA8.Next());
         if (Gi_0002 != 0) { 
         do { 
         Local_Pointer_FFFFFFA8 = dynamic_cast<CEasyXmlNode *>(Local_Pointer_FFFFFFA8.Next());
         
         Local_Pointer_FFFFFFA0 = func_1234(Local_Pointer_FFFFFFA8);
         Ls_FF90 = Local_Pointer_FFFFFFA0.m_28;
         tmp_str0001 = Ls_FF90;
         if (func_1232(tmp_str0001)) { 
         Li_FF9C = ArraySize(this.m_16);
         ArrayResize(this.m_16, (ArraySize(this.m_16) + 1), 0);
         this.m_16[Li_FF9C].m_28 = Local_Pointer_FFFFFFA0.m_28;
         this.m_16[Li_FF9C].m_40 = Local_Pointer_FFFFFFA0.m_40;
         this.m_16[Li_FF9C].m_48 = Local_Pointer_FFFFFFA0.m_48;
         this.m_16[Li_FF9C].m_16 = Local_Pointer_FFFFFFA0.m_16;
         } 
         Gi_000A = CheckPointer(Local_Pointer_FFFFFFA8.Next());
         } while (Gi_000A != 0); 
         }} 
         delete Local_Pointer_FFFFFFC0;
         delete Local_Pointer_FFFFFFB8;
         delete Local_Pointer_FFFFFFB0;
         delete Local_Pointer_FFFFFFA8;
         delete Local_Pointer_FFFFFFA0;
      }

      bool func_1232(string Fa_s_00)
      {
         int Li_FFF4;
         int Li_FFF0;
         bool Lb_FFFB;

         Li_FFF4 = ArraySize(this.m_68);
         Li_FFF0 = 0;
         if (ArraySize(this.m_68) <= 0) return false; 
         do { 
         if (this.m_68[Li_FFF0] == Fa_s_00) { 
         Lb_FFFB = true;
         return Lb_FFFB;
         } 
         Li_FFF0 = Li_FFF0 + 1;
         } while (Li_FFF0 < Li_FFF4); 
         
         Lb_FFFB = false;
         
         return Lb_FFFB;
      }

      void func_1235()
      {
      }

      ReadNews()
      {
      }

      virtual ~ReadNews()
      {
         ArrayFree(this.m_68);
         ArrayFree(this.m_16);
      }

   private:
      Node_Data * func_1234(CEasyXmlNode *arg)
      {
         string tmp_str0000;
         string tmp_str0001;
         string tmp_str0002;
         string tmp_str0003;
         string tmp_str0004;
         string tmp_str0005;
         CEasyXmlNode* Local_Pointer_FFFFFFE8;
         Node_Data* Local_Pointer_FFFFFFE0;
         string Ls_FFD0;
         long Ll_FF90;
         string Ls_FF80;
         long Ll_FF78;
         string Ls_FF68;
         string Ls_FF58;
         string Ls_FF00;
         string Ls_FEF0;
         string Ls_FEE0;
         Node_Data* Local_Pointer_FFFFFFF0;
         int Li_FEFC;

         Local_Pointer_FFFFFFE8 = arg.Children().At(0);
         Local_Pointer_FFFFFFE0 = new Node_Data();
         //Global_Pointer_00000001.func_1213();
         //Global_Pointer_00000001.func_1214();
         //Local_Pointer_FFFFFFE0 = Global_Pointer_00000001;
         Local_Pointer_FFFFFFE0.m_16 = Local_Pointer_FFFFFFE8.getValue();
         //Global_Pointer_00000007 = Local_Pointer_FFFFFFE8.Next();
         Local_Pointer_FFFFFFE8 = dynamic_cast<CEasyXmlNode *>(Local_Pointer_FFFFFFE8.Next());
         Local_Pointer_FFFFFFE0.m_28 = Local_Pointer_FFFFFFE8.getValue();
         //Global_Pointer_0000000A = Local_Pointer_FFFFFFE8.func_1095();
         Local_Pointer_FFFFFFE8 = dynamic_cast<CEasyXmlNode *>(Local_Pointer_FFFFFFE8.Next());
         Ls_FFD0 = Local_Pointer_FFFFFFE8.getValue();
         string Ls_FF9C[];
         StringSplit(Ls_FFD0, StringGetCharacter("-", 0), Ls_FF9C);
         tmp_str0000 = Ls_FF9C[2] + ".";
         tmp_str0000 = tmp_str0000 + Ls_FF9C[0];
         tmp_str0000 = tmp_str0000 + ".";
         tmp_str0000 = tmp_str0000 + Ls_FF9C[1];
         Ll_FF90 = StringToTime(tmp_str0000);
         //Global_Pointer_0000000F = Local_Pointer_FFFFFFE8.Next();
         Local_Pointer_FFFFFFE8 = dynamic_cast<CEasyXmlNode *>(Local_Pointer_FFFFFFE8.Next());
         Ls_FF80 = Local_Pointer_FFFFFFE8.getValue();
         Ll_FF78 = StringToTime(Ls_FF80);
         Gi_0010 = StringLen(Ls_FF80);
         tmp_str0001 = "" + Ls_FF80;
         Ls_FF68 = StringSubstr(tmp_str0001, (Gi_0010 - 2), 2);
         Gi_0010 = StringLen(Ls_FF80);
         tmp_str0002 = "" + Ls_FF80;
         Ls_FF58 = StringSubstr(tmp_str0002, 0, (Gi_0010 - 2));
         string Ls_FF40[2];
         StringSplit(Ls_FF58, StringGetCharacter(":", 0), Ls_FF40);
         if (Ls_FF68 == "pm") {
         if (StringToInteger(Ls_FF40[0]) != 12) {
         tmp_str0003 = IntegerToString((StringToInteger(Ls_FF40[0]) + 12), 0, 32);
         tmp_str0003 = tmp_str0003 + "";
         Ls_FF00 = tmp_str0003;
         }
         else{
         Ls_FF00 = Ls_FF40[0] + "";
         Li_FEFC = 0;
         }}
         else{
         if (StringToInteger(Ls_FF40[0]) != 12) { 
         Ls_FF00 = Ls_FF40[0];
         } 
         else { 
         tmp_str0003 = IntegerToString((StringToInteger(Ls_FF40[0]) - 12), 0, 32);
         tmp_str0003 = tmp_str0003 + "";
         Ls_FF00 = tmp_str0003;
         }} 
         tmp_str0003 = Ls_FF00 + ":";
         tmp_str0003 = tmp_str0003 + Ls_FF40[1];
         Ls_FEF0 = tmp_str0003;
         tmp_str0004 = "" + TimeToString(Ll_FF90, 3);
         Ls_FEE0 = StringSubstr(tmp_str0004, 0, 10);

         tmp_str0005 = Ls_FEE0 + " ";
         tmp_str0005 = tmp_str0005 + tmp_str0003;
         Local_Pointer_FFFFFFE0.m_40 = StringToTime(tmp_str0005) + TimeCurrent() - TimeGMT();
         //Global_Pointer_00000019 = Local_Pointer_FFFFFFE8.Next();
         Local_Pointer_FFFFFFE8 = dynamic_cast<CEasyXmlNode *>(Local_Pointer_FFFFFFE8.Next());
         Local_Pointer_FFFFFFE0.m_48 = Local_Pointer_FFFFFFE8.getValue();
         Local_Pointer_FFFFFFF0 = Local_Pointer_FFFFFFE0;
         ArrayFree(Ls_FF40);
         ArrayFree(Ls_FF9C);
         

         return Local_Pointer_FFFFFFF0;
         
      }

};


class FilterNews
{
   public:
      Node_Data m_16[];

      void func_1240(Node_Data &FuncArg_Struct_00000000[], bool FuncArg_Boolean_00000001, bool FuncArg_Boolean_00000002, bool FuncArg_Boolean_00000003)
      {
         Node_Data *Local_Pointer_FFFFFFC0 = new Node_Data();
         int Li_FFBC;
         int Li_FFB8;
         int Li_FFB4;

         ArrayFree(this.m_16);
         ArrayResize(this.m_16, 0, 0);
         //Local_Struct_FFFFFFC0.func_1213();
         //Local_Struct_FFFFFFC0.func_1214();
         Li_FFBC = ArraySize(FuncArg_Struct_00000000);
         Li_FFB8 = 0;
         if (Li_FFBC > 0) { 
         do { 
         if ((FuncArg_Struct_00000000[Li_FFB8].m_48 == "High" && FuncArg_Boolean_00000001)
         || (FuncArg_Struct_00000000[Li_FFB8].m_48 == "Medium" && FuncArg_Boolean_00000002)
         || (FuncArg_Struct_00000000[Li_FFB8].m_48 == "Low" && FuncArg_Boolean_00000003)) {
         
         Li_FFB4 = ArraySize(this.m_16);
         ArrayResize(this.m_16, (ArraySize(this.m_16) + 1), 0);
         this.m_16[Li_FFB4].m_28 = FuncArg_Struct_00000000[Li_FFB8].m_28;
         this.m_16[Li_FFB4].m_40 = FuncArg_Struct_00000000[Li_FFB8].m_40;
         this.m_16[Li_FFB4].m_48 = FuncArg_Struct_00000000[Li_FFB8].m_48;
         this.m_16[Li_FFB4].m_16 = FuncArg_Struct_00000000[Li_FFB8].m_16;
         }
         Li_FFB8 = Li_FFB8 + 1;
         } while (Li_FFB8 < Li_FFBC); 
         } 
         delete Local_Pointer_FFFFFFC0;
         //Local_Struct_FFFFFFC0.func_1217();
      }

      bool func_1244(Node_Data &FuncArg_Struct_00000000[], int Fa_i_01, int Fa_i_02)
      {
         int Li_FFF4;
         int Li_FFF0;
         bool Lb_FFFB;

         Li_FFF4 = ArraySize(FuncArg_Struct_00000000);
         Li_FFF0 = 0;
         if (Li_FFF4 <= 0) return false; 
         do { 
         Gl_0000 = TimeCurrent();
         Gl_0002 = Fa_i_01;
         Gl_0002 = FuncArg_Struct_00000000[Li_FFF0].m_40 - Gl_0002;
         if (Gl_0000 >= Gl_0002) { 
         Gl_0002 = TimeCurrent();
         Gl_0004 = Fa_i_02;
         Gl_0004 = FuncArg_Struct_00000000[Li_FFF0].m_40 + Gl_0004;
         if (Gl_0002 <= Gl_0004) { 
         Lb_FFFB = true;
         return Lb_FFFB;
         }} 
         Li_FFF0 = Li_FFF0 + 1;
         } while (Li_FFF0 < Li_FFF4); 
         
         Lb_FFFB = false;
         
         return Lb_FFFB;
      }

      FilterNews()
      {
      }

      virtual ~FilterNews()
      {
         ArrayFree(this.m_16);
      }

};

class DisplayNews
{
   public:
      int m_16;
      int m_20;

      void func_1251(Node_Data &FuncArg_Struct_00000000[], bool FuncArg_Boolean_00000001, int Fa_i_02, int Fa_i_03, int Fa_i_04, string Fa_s_05, int Fa_i_06)
      {
         string tmp_str0000;
         string tmp_str0001;
         string tmp_str0002;
         string tmp_str0003;
         string tmp_str0004;
         string tmp_str0005;
         string tmp_str0006;
         string tmp_str0007;
         string tmp_str0008;
         string tmp_str0009;
         long Ll_FFF0;
         long Ll_FFE8;
         long Ll_FFE0;
         double Ld_FFD8;
         bool Lb_FFD7;
         int Li_FFD0;
         int Li_FFCC;
         string Ls_FFC0;
         int Li_FFBC;
         int Li_FFB8;
         string Ls_FFA8;
         string Ls_FF98;

         Ll_FFF0 = TimeLocal();
         Ll_FFE8 = TimeCurrent();
         Ll_FFE0 = 0;
         Ld_FFD8 = -1;
         Lb_FFD7 = false;
         Li_FFD0 = ArrayRange(FuncArg_Struct_00000000, 0) - Fa_i_06;
         Li_FFCC = 0;
         if (Li_FFD0 <= 0) return; 
         do { 
         Lb_FFD7 = false;
         if (Li_FFCC > 0) {
         Gi_0001 = Li_FFCC - 1;
         if (FuncArg_Struct_00000000[Li_FFCC].m_40 != FuncArg_Struct_00000000[Gi_0001].m_40) {
         Ld_FFD8 = 0;
         }}
         else{
         Ld_FFD8 = 0;
         }
         Ls_FFC0 = FuncArg_Struct_00000000[Li_FFCC].m_28;
         if (Lb_FFD7 != true) { 
         tmp_str0000 = FuncArg_Struct_00000000[Li_FFCC].m_48;
         if ((func_1252(tmp_str0000) > Ld_FFD8)) { 
         tmp_str0001 = FuncArg_Struct_00000000[Li_FFCC].m_48;
         Ld_FFD8 = func_1252(tmp_str0001);
         } 
         if (FuncArg_Struct_00000000[Li_FFCC].m_40 == Ll_FFE0) { 
         } 
         else { 
         Ll_FFE0 = FuncArg_Struct_00000000[Li_FFCC].m_40;
         Li_FFBC = Fa_i_04;
         if ((Ld_FFD8 == 2)) { 
         Li_FFBC = Fa_i_03;
         } 
         else { 
         if ((Ld_FFD8 == 3)) { 
         Li_FFBC = Fa_i_02;
         }} 
         Li_FFB8 = Li_FFBC;
         if (FuncArg_Struct_00000000[Li_FFCC].m_16 == Fa_s_05) { 
         Li_FFB8 = 16776960;
         } 
         Ls_FFA8 = FuncArg_Struct_00000000[Li_FFCC].m_16;
         Ls_FF98 = "FFNewsLine" + IntegerToString(Li_FFCC, 0, 32);
         ObjectCreate(0, Ls_FF98, OBJ_VLINE, 0, Ll_FFE0, 0, 0, 0, 0, 0);
         ObjectSet(Ls_FF98, OBJPROP_COLOR, Li_FFB8);
         ObjectSet(Ls_FF98, OBJPROP_STYLE, 2);
         ObjectSet(Ls_FF98, OBJPROP_BACK, 1);
         tmp_str0002 = "(" + TimeToString(FuncArg_Struct_00000000[Li_FFCC].m_40, 3);
         tmp_str0002 = tmp_str0002 + ") (";
         tmp_str0002 = tmp_str0002 + FuncArg_Struct_00000000[Li_FFCC].m_28;
         tmp_str0002 = tmp_str0002 + ") ";
         tmp_str0002 = tmp_str0002 + Ls_FFA8;
         ObjectSetText(Ls_FF98, tmp_str0002, 8, NULL, 4294967295);
         if (FuncArg_Boolean_00000001) { 
         Gd_000B = WindowPriceMin(0);
         tmp_str0003 = "FFNewsText" + IntegerToString(Li_FFCC, 0, 32);
         ObjectCreate(0, tmp_str0003, OBJ_TEXT, 0, Ll_FFE0, ((Gd_000B + WindowPriceMax(0)) / 2), 0, 0, 0, 0);
         tmp_str0004 = "FFNewsText" + IntegerToString(Li_FFCC, 0, 32);
         ObjectSet(tmp_str0004, OBJPROP_YDISTANCE, 5);
         tmp_str0005 = "FFNewsText" + IntegerToString(Li_FFCC, 0, 32);
         ObjectSet(tmp_str0005, OBJPROP_COLOR, Li_FFBC);
         tmp_str0006 = "FFNewsText" + IntegerToString(Li_FFCC, 0, 32);
         ObjectSet(tmp_str0006, OBJPROP_ANGLE, 90);
         tmp_str0007 = "(" + TimeToString(FuncArg_Struct_00000000[Li_FFCC].m_40, 3);
         tmp_str0007 = tmp_str0007 + ") (";
         tmp_str0007 = tmp_str0007 + FuncArg_Struct_00000000[Li_FFCC].m_28;
         tmp_str0007 = tmp_str0007 + ") ";
         tmp_str0007 = tmp_str0007 + Ls_FFA8;
         tmp_str0008 = "FFNewsText" + IntegerToString(Li_FFCC, 0, 32);
         ObjectSetText(tmp_str0008, tmp_str0007, 8, NULL, 4294967295);
         tmp_str0009 = "FFNewsText" + IntegerToString(Li_FFCC, 0, 32);
         ObjectSet(tmp_str0009, OBJPROP_BACK, 1);
         }}} 
         Li_FFCC = Li_FFCC + 1;
         } while (Li_FFCC < Li_FFD0); 
         
      }

      void func_1253(Node_Data &FuncArg_Struct_00000000[])
      {
         string tmp_str0000;
         string tmp_str0001;
         int Li_FFF8;

         Li_FFF8 = 0;
         Gi_0000 = ArraySize(FuncArg_Struct_00000000);
         if (Gi_0000 <= 0) return; 
         do { 
         tmp_str0000 = "FFNewsLine" + IntegerToString(Li_FFF8, 0, 32);
         ObjectDelete(tmp_str0000);
         tmp_str0001 = "FFNewsText" + IntegerToString(Li_FFF8, 0, 32);
         ObjectDelete(tmp_str0001);
         Li_FFF8 = Li_FFF8 + 1;
         Gi_0000 = ArraySize(FuncArg_Struct_00000000);
         } while (Li_FFF8 < Gi_0000); 
         
      }

      void func_1257(Node_Data &FuncArg_Struct_00000000[], bool FuncArg_Boolean_00000001, int Fa_i_02, int Fa_i_03, int Fa_i_04, int Fa_i_05, int Fa_i_06)
      {
         string tmp_str0000;
         string tmp_str0001;
         string tmp_str0002;
         long Ll_FFF0;
         long Ll_FFE8;
         long Ll_FFE0;
         double Ld_FFD8;
         bool Lb_FFD7;
         int Li_FFD0;
         int Li_FFCC;
         int Li_FFC8;
         string Ls_FFB8;
         int Li_FFB4;
         string Ls_FFA8;
         int Li_FFA4;
         string Ls_FF98;
         string Ls_FF88;
         string Ls_FF78;

         this.m_16 = 20;
         this.m_20 = 20;
         Ll_FFF0 = TimeLocal();
         Ll_FFE8 = TimeCurrent();
         Ll_FFE0 = 0;
         Ld_FFD8 = -1;
         Lb_FFD7 = false;
         Li_FFD0 = ArrayRange(FuncArg_Struct_00000000, 0);
         Li_FFCC = 0;
         Li_FFC8 = 0;
         if (Li_FFD0 > 0) { 
         do { 
         Lb_FFD7 = false;
         if (Li_FFC8 > 0) {
         Gi_0001 = Li_FFC8 - 1;
         if (FuncArg_Struct_00000000[Li_FFC8].m_40 != FuncArg_Struct_00000000[Gi_0001].m_40) {
         Ld_FFD8 = 0;
         }}
         else{
         Ld_FFD8 = 0;
         }
         Ls_FFB8 = FuncArg_Struct_00000000[Li_FFC8].m_28;
         if (func_1260(FuncArg_Struct_00000000[Li_FFC8].m_40)) { 
         Li_FFCC = Li_FFCC + 1;
         } 
         Li_FFC8 = Li_FFC8 + 1;
         } while (Li_FFC8 < Li_FFD0); 
         } 
         Gi_0004 = Li_FFCC;
         if (Li_FFCC >= Fa_i_06) { 
         Gi_0005 = Fa_i_06;
         } 
         else { 
         Gi_0005 = Gi_0004;
         } 
         Li_FFCC = Gi_0005;
         if (FuncArg_Boolean_00000001) { 
         func_1258(Gi_0005, Fa_i_02);
         } 
         Li_FFB4 = 0;
         if (Li_FFD0 <= 0) return; 
         do { 
         Lb_FFD7 = false;
         if (Li_FFB4 > 0) {
         Gi_0006 = Li_FFB4 - 1;
         if (FuncArg_Struct_00000000[Li_FFB4].m_40 != FuncArg_Struct_00000000[Gi_0006].m_40) {
         Ld_FFD8 = 0;
         }}
         else{
         Ld_FFD8 = 0;
         }
         Ls_FFA8 = FuncArg_Struct_00000000[Li_FFB4].m_28;
         if (func_1260(FuncArg_Struct_00000000[Li_FFB4].m_40)) { 
         tmp_str0000 = FuncArg_Struct_00000000[Li_FFB4].m_48;
         if ((func_1252(tmp_str0000) > Ld_FFD8)) { 
         tmp_str0001 = FuncArg_Struct_00000000[Li_FFB4].m_48;
         Ld_FFD8 = func_1252(tmp_str0001);
         } 
         if (FuncArg_Struct_00000000[Li_FFB4].m_40 == Ll_FFE0) { 
         } 
         else { 
         Ll_FFE0 = FuncArg_Struct_00000000[Li_FFB4].m_40;
         Li_FFA4 = Fa_i_05;
         if ((Ld_FFD8 == 2)) { 
         Li_FFA4 = Fa_i_04;
         } 
         else { 
         if ((Ld_FFD8 == 3)) { 
         Li_FFA4 = Fa_i_03;
         }} 
         Ls_FF98 = FuncArg_Struct_00000000[Li_FFB4].m_16;
         Ls_FF88 = func_1259(FuncArg_Struct_00000000[Li_FFB4].m_40);
         Ls_FF78 = "FFNewsTime_" + IntegerToString(Li_FFB4, 0, 32);
         ObjectCreate(0, Ls_FF78, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
         ObjectSet(Ls_FF78, OBJPROP_COLOR, Li_FFA4);
         ObjectSet(Ls_FF78, OBJPROP_BACK, 0);
         ObjectSetText(Ls_FF78, Ls_FF88, 8, NULL, 4294967295);
         ObjectSetInteger(0, Ls_FF78, 102, this.m_20);
         Gi_000F = this.m_16 * Li_FFCC;
         ObjectSetInteger(0, Ls_FF78, 103, Gi_000F);
         ObjectSetInteger(0, Ls_FF78, 101, 2);
         ObjectSetInteger(0, Ls_FF78, 1000, 0);
         Ls_FF78 = "FFNewsTimeInfo_" + IntegerToString(Li_FFB4, 0, 32);
         ObjectCreate(0, Ls_FF78, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
         ObjectSet(Ls_FF78, OBJPROP_COLOR, Li_FFA4);
         ObjectSet(Ls_FF78, OBJPROP_BACK, 0);
         tmp_str0002 = "|    " + TimeToString(FuncArg_Struct_00000000[Li_FFB4].m_40, 3);
         tmp_str0002 = tmp_str0002 + "      ";
         tmp_str0002 = tmp_str0002 + FuncArg_Struct_00000000[Li_FFB4].m_28;
         tmp_str0002 = tmp_str0002 + "     |     ";
         ObjectSetText(Ls_FF78, tmp_str0002, 8, NULL, 4294967295);
         Gi_0012 = this.m_20 + 110;
         ObjectSetInteger(0, Ls_FF78, 102, Gi_0012);
         ObjectSetInteger(0, Ls_FF78, 103, Gi_000F);
         ObjectSetInteger(0, Ls_FF78, 101, 2);
         ObjectSetInteger(0, Ls_FF78, 1000, 0);
         Ls_FF78 = "FFNewsText_" + IntegerToString(Li_FFB4, 0, 32);
         ObjectCreate(0, Ls_FF78, OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
         ObjectSet(Ls_FF78, OBJPROP_COLOR, Li_FFA4);
         ObjectSet(Ls_FF78, OBJPROP_BACK, 0);
         ObjectSetText(Ls_FF78, Ls_FF98, 8, NULL, 4294967295);
         Gi_0012 = this.m_20 + 280;
         ObjectSetInteger(0, Ls_FF78, 102, Gi_0012);
         Gi_0012 = Li_FFCC;
         Li_FFCC = Li_FFCC - 1;
         Gi_0012 = this.m_16 * Gi_0012;
         ObjectSetInteger(0, Ls_FF78, 103, Gi_0012);
         ObjectSetInteger(0, Ls_FF78, 101, 2);
         ObjectSetInteger(0, Ls_FF78, 1000, 0);
         if (Li_FFCC == 0) { 
         return ;
         }}} 
         Li_FFB4 = Li_FFB4 + 1;
         } while (Li_FFB4 < Li_FFD0); 
         
      }

      void func_1258(int Fa_i_00, int Fa_i_01)
      {
         int Li_FFF8;
         string Ls_FFE8;

         Li_FFF8 = Fa_i_00 * this.m_16;
         Ls_FFE8 = "FFNewsRectangle";
         ObjectCreate(0, Ls_FFE8, OBJ_RECTANGLE_LABEL, 0, 0, 0);
         ObjectSetInteger(0, Ls_FFE8, 6, Fa_i_01);
         ObjectSetInteger(0, Ls_FFE8, 1025, Fa_i_01);
         ObjectSet(Ls_FFE8, OBJPROP_BACK, 0);
         Gi_0000 = this.m_20 - 10;
         ObjectSetInteger(0, Ls_FFE8, 102, Gi_0000);
         Gi_0000 = Li_FFF8 + 10;
         ObjectSetInteger(0, Ls_FFE8, 103, Gi_0000);
         ObjectSetInteger(0, Ls_FFE8, 1019, 470);
         ObjectSetInteger(0, Ls_FFE8, 1020, Gi_0000);
         ObjectSetInteger(0, Ls_FFE8, 101, 2);
         ObjectSetInteger(0, Ls_FFE8, 1000, 0);
      }

      string func_1259(long Fa_l_00)
      {
         string tmp_str0000;
         int Li_FFF8;
         int Li_FFF4;
         int Li_FFF0;
         string Ls_FFE0;

         Gl_0000 = Fa_l_00 - TimeCurrent();
         Li_FFF8 = (int)Gl_0000;
         Li_FFF4 = Li_FFF8 / 3600;
         Gi_0000 = Li_FFF4 * 3600;
         Li_FFF8 = Li_FFF8 - Gi_0000;
         Li_FFF0 = Li_FFF8 / 60;
         Gi_0000 = Li_FFF0 * 60;
         Li_FFF8 = Li_FFF8 - Gi_0000;
         Ls_FFE0 = "";
         if (Li_FFF4 != 0) { 
         tmp_str0000 = IntegerToString(Li_FFF4, 0, 32);
         tmp_str0000 = tmp_str0000 + " Hr ";
         Ls_FFE0 = tmp_str0000;
         } 
         if (Li_FFF0 != 0) { 
         tmp_str0000 = IntegerToString(Li_FFF0, 0, 32);
         tmp_str0000 = tmp_str0000 + " Min ";
         Ls_FFE0 = Ls_FFE0 + tmp_str0000;
         } 
         tmp_str0000 = IntegerToString(Li_FFF8, 0, 32);
         tmp_str0000 = tmp_str0000 + " Sec";
         Ls_FFE0 = Ls_FFE0 + tmp_str0000;
         tmp_str0000 = Ls_FFE0;
         return tmp_str0000;
      }

      bool func_1260(long Fa_l_00)
      {
         int Li_FFF4;
         bool Lb_FFFB;

         Gl_0000 = Fa_l_00 - TimeCurrent();
         Li_FFF4 = (int)Gl_0000;
         Lb_FFFB = (Li_FFF4 > 0);
         return Lb_FFFB;
      }

      void func_1261()
      {
         ObjectsDeleteAll(0, "FFNewsTime_", -1, -1);
         ObjectsDeleteAll(0, "FFNewsText_", -1, -1);
         ObjectsDeleteAll(0, "FFNewsTimeInfo_", -1, -1);
         ObjectsDeleteAll(0, "FFNewsRectangle", -1, -1);
      }

      void func_1262()
      {
      }

      DisplayNews()
      {
      }

      virtual ~DisplayNews()
      {
      }

   private:
      double func_1252(string Fa_s_00)
      {
         double Ld_FFF0;

         if (Fa_s_00 == "High" || Fa_s_00 == "HIGH") { 
         
         Ld_FFF0 = 3;
         return Ld_FFF0;
         } 
         if (Fa_s_00 == "Medium") { 
         Ld_FFF0 = 2;
         return Ld_FFF0;
         } 
         if (Fa_s_00 != "Low") { 
         if (Fa_s_00 != "LOW") return 0; 
         } 
         Ld_FFF0 = 1;
         return Ld_FFF0;
         
         Ld_FFF0 = 0;
         
         Ind_000 = Ld_FFF0;
      }

};

bool Gb_0000;
bool Gb_0001;
bool Gb_0002;
int Gi_0004;
int Gi_0005;
int Gi_0006;
struct Global_Struct_00000003;
string Gs_0004;
int Gi_0007;
string Gs_0007;
int Gi_0008;
string Gs_0008;
int Gi_0009;
int Gi_000A;
int Gi_000B;
string Gs_000B;
string Gs_000A;
int Gi_000C;
int Gi_000D;
int Gi_000E;
int Gi_000F;
string Gs_000F;
string Gs_000E;
int Gi_0010;
int Gi_0011;
string Gs_0011;
string Gs_0010;
int Ii_0098;
string Is_01C0;
string Is_0188;
string Is_01A8;
string Is_0198;
bool returned_b;
int Ii_0174;
int Gi_0012;
int returned_i;
int Gi_0013;
int Gi_0015;
int Gi_0016;
char Gc_0014;
char Gc_0017;
char Gc_0015;
int Gi_001C;
int Gi_001D;
int Gi_001F;
int Gi_0020;
char Gc_001E;
char Gc_0021;
char Gc_001F;
int Gi_0021;
int Gi_0022;
int Gi_0024;
int Gi_0025;
char Gc_0023;
char Gc_0026;
char Gc_0024;
int Gi_0026;
int Gi_0027;
int Gi_0029;
int Gi_002A;
char Gc_0028;
char Gc_002B;
char Gc_0029;
int Gi_002B;
int Gi_002C;
int Gi_002E;
int Gi_002F;
char Gc_002D;
char Gc_0030;
char Gc_002E;
int Gi_0030;
int Gi_0031;
int Gi_0033;
int Gi_0034;
char Gc_0032;
char Gc_0035;
char Gc_0033;
int Gi_0035;
int Gi_0036;
int Gi_0038;
int Gi_0039;
char Gc_0037;
char Gc_003A;
char Gc_0038;
int Gi_003A;
int Gi_003B;
int Gi_003D;
int Gi_003E;
char Gc_003C;
char Gc_003F;
char Gc_003D;
int Gi_003F;
int Gi_0040;
int Gi_0042;
int Gi_0043;
char Gc_0041;
char Gc_0044;
char Gc_0042;
int Gi_0044;
int Gi_0045;
int Gi_0047;
int Gi_0048;
char Gc_0046;
char Gc_0049;
char Gc_0047;
int Gi_0049;
int Gi_004A;
int Gi_004C;
int Gi_004D;
char Gc_004B;
char Gc_004E;
char Gc_004C;
int Gi_004E;
int Gi_004F;
int Gi_0051;
int Gi_0052;
char Gc_0050;
char Gc_0053;
char Gc_0051;
string Is_0178;
int Gi_0053;
bool Gb_0054;
long Gl_0055;
long returned_l;
long Gl_0056;
int Gi_0056;
bool Gb_0056;
int Gi_0017;
int Gi_0018;
int Gi_001A;
int Gi_001B;
char Gc_0019;
char Gc_001C;
char Gc_001A;
int Gi_0001;
int Gi_0002;
long Gl_0002;
int Gi_0003;
long Gl_0005;
struct Global_Struct_00000004;
long Gl_0009;
long Gl_000B;
bool Gb_000B;
bool Gb_000D;
long Gl_000E;
long Gl_000F;
bool Gb_000F;
int Gi_0000;
char Gc_0002;
char Gc_0005;
char Gc_0003;
char Gc_000C;
char Gc_000F;
char Gc_000D;
char Gc_0011;
char Gc_0012;
int Gi_0014;
char Gc_0016;
int Gi_0019;
char Gc_001B;
int Gi_001E;
char Gc_0020;
int Gi_0023;
char Gc_0025;
int Gi_0028;
char Gc_002A;
int Gi_002D;
char Gc_002F;
int Gi_0032;
bool Gb_0033;
long Gl_0034;
long Gl_0035;
bool Gb_0035;
char Gc_0007;
char Gc_000A;
char Gc_0008;
string Is_00A0;
int Ii_01B4;
bool Ib_01B8;
int Ii_01CC;
double Id_01D0;
double Id_01D8;
bool Ib_01E0;
bool Ib_01E1;
double Id_01E8;
double Id_01F0;
long Il_01F8;
int Ii_0200;
long Il_0208;
string Gs_0000;
string Gs_0001;
string Gs_0002;
string Gs_0003;
string Gs_0005;
string Gs_0006;
string Gs_0009;
string Gs_000C;
string Gs_000D;
bool Gb_0010;
long Gl_0010;
long Gl_0000;
long Gl_0001;
double Ind_004;
double Gd_0001;
short returned_st;
double Ind_001;
double Ind_000;
double Gd_0005;
char Gc_0006;
bool Gb_0005;
bool Gb_0008;
bool Gb_0004;
bool Gb_0007;
short Gst_0000;
bool Gb_0012;
string Gs_0013;
string Gs_0019;
string Gs_001D;
long Gl_001F;
bool Gb_001F;
string Gs_001B;
long Gl_0003;
char Gc_0001;
char Gc_0000;
short Gst_000A;
short Gst_000E;
string Gs_0014;
long Gl_0015;
string Gs_0017;
string Gs_0016;
string Gs_0012;
long Gl_0014;
double Gd_0004;
double Gd_0006;
bool Gb_0009;
double Ind_003;
long Gl_000C;
double Gd_000D;
double Gd_000E;
long Gl_0011;
long Gl_0004;
long Gl_0007;
long Gl_0008;
long Gl_000D;
double Gd_0010;
bool Gb_0013;
long Gl_0016;
long Gl_0018;
long Gl_001A;
long Gl_001B;
long Gl_001C;
bool Gb_0006;
double Gd_0008;
bool Gb_000A;
double Gd_000A;
double Gd_000C;
double Gd_0002;
double Gd_0003;
bool Gb_0003;
double Gd_0007;
long Gl_0012;
double Ind_002;
long Gl_0013;
double Gd_0015;
double Gd_0016;
double Gd_0017;
double Gd_0018;
long Gl_0019;
double Gd_001A;
double Gd_001B;
double Gd_001C;
bool Gb_001D;
long Gl_001E;
long Gl_001D;
double Gd_0020;
double Gd_0021;
double Gd_0022;
double Gd_0023;
long Gl_0025;
long Gl_0024;
double Gd_0025;
double Gd_0026;
double Gd_0027;
long Gl_000A;
double Gd_0011;
double Gd_0012;
bool Gb_0018;
bool Gb_001B;
double Gd_001D;
double Gd_001F;
bool Gb_0021;
long Gl_0021;
long Gl_0026;
double Gd_0013;
double Gd_0014;
bool Gb_0015;
bool Gb_001A;
double Gd_001E;
bool Gb_0011;
double Gd_000B;
double Gd_000F;
double Gd_0009;
double Gd_0000;
ReadNews Input_Struct_000000A0;
FilterNews Input_Struct_00000130;
DisplayNews Input_Struct_00000118;
string Global_ReturnedString;
double returned_double;
int init()
{  


   string tmp_str0000;
   int Li_FFFC;
   Ii_0174 = 21660;
   Is_0178 = "Fetching License Info";
   Is_0188 = "-Link-";
   Is_0198 = "-ProductCode-";
   Is_01A8 = "-Title-";
   Ii_01B4 = 80;
   Ib_01B8 = false;
   Is_01C0 = "ClevrFX";
   Ii_01CC = 10;
   Id_01D0 = 0;
   Id_01D8 = 5000;
   Ib_01E0 = false;
   Ib_01E1 = false;
   Id_01E8 = 0;
   Id_01F0 = 0;
   Il_01F8 = 0;
   Ii_0200 = 0;
   Il_0208 = 0;
   Ii_0098 = 2;


   tmp_str0000 = currencies;
   Input_Struct_000000A0.func_1228(tmp_str0000, true);
   Input_Struct_00000130.func_1240(Input_Struct_000000A0.m_16, highImpact, medImpact, lowImpact);
   if (Ii_0098 == 2) { 
   Is_01C0 = "Clevr FX";
   Is_0188 = "";
   Is_01A8 = "Clevr FX";
   Is_0198 = "EA_CVR";
   } 

   Comment("Fetching License Information");
   HideTestIndicators(true);
   Is_0178 = "Activated";
   if (IsTesting() != true) { 
   EventSetTimer(21600);
   } 
   func_1276();
   Comment("");
   Li_FFFC = 0;
   return 0;
}

void OnTick()
{
   string tmp_str0000;
   string tmp_str0001;
   string tmp_str0002;
   string tmp_str0003;
   string tmp_str0004;

   func_1273(0);
   func_1273(1);
   func_1295(0);
   func_1295(1);
   func_1296(0);
   func_1296(1);
   if (ddRecovery) { 
   func_1270(0);
   func_1270(1);
   } 
   func_1276();
   if (IsTesting()) { 
   tmp_str0000 = "Tester";
   func_1289(tmp_str0000);
   } 
   if (showNewsLines) { 
   Gi_0001 = 0;
   Gi_0002 = ArraySize(Input_Struct_00000130.m_16);
   if (Gi_0002 > 0) { 
   do { 
   tmp_str0001 = "FFNewsLine" + IntegerToString(Gi_0001, 0, 32);
   ObjectDelete(tmp_str0001);
   tmp_str0002 = "FFNewsText" + IntegerToString(Gi_0001, 0, 32);
   ObjectDelete(tmp_str0002);
   Gi_0001 = Gi_0001 + 1;
   Gi_0002 = ArraySize(Input_Struct_00000130.m_16);
   } while (Gi_0001 < Gi_0002); 
   } 
   tmp_str0003 = "";
   Input_Struct_00000118.func_1251(Input_Struct_00000130.m_16, showText, clrHighNews, clrMedNews, clrLowNews, tmp_str0003, 0);
   } 
   if (showNewsBox) { 
   ObjectsDeleteAll(0, "FFNewsTime_", -1, -1);
   ObjectsDeleteAll(0, "FFNewsText_", -1, -1);
   ObjectsDeleteAll(0, "FFNewsTimeInfo_", -1, -1);
   ObjectsDeleteAll(0, "FFNewsRectangle", -1, -1);
   Input_Struct_00000118.func_1257(Input_Struct_00000130.m_16, showBg, bgcolor, clrHighNews, clrMedNews, clrLowNews, newsCount);
   } 
   if (Input_Struct_00000130.func_1244(Input_Struct_00000130.m_16, (closeBefore * 60), (startAfter * 60))) { 
   
   Comment("Trading Paused News Time");
   return ;
   } 
   Comment("");

   func_1290();
   
}

void OnDeinit(const int reason)
{
   FileDelete("UOPFXPSGV2.lc", 0);
   Comment("");
   ObjectsDeleteAll(0, "OBJ", -1, -1);
   EventKillTimer();
   
   delete GetPointer(Input_Struct_000000A0);
   delete GetPointer(Input_Struct_00000130);
   delete GetPointer(Input_Struct_00000118);
}

void OnTimer()
{

   func_1276();
}

void OnChartEvent(const int id, const long& lparam, const double& dparam, const string& sparam)
{
   string tmp_str0000;
   string tmp_str0001;
   string tmp_str0002;
   string Ls_FFF0;
   string Ls_FFE0;
   int Li_FFDC;

   if (sparam == "OBJLicenseText" || sparam == "OBJLicenseText2") { 
   
   Ls_FFF0 = ObjectGetString(0, sparam, 999, 0);
   if (Ls_FFF0 != "Activated") { 
   Ls_FFE0 = Is_0188;
   Li_FFDC = ShellExecuteW(0, tmp_str0002, Ls_FFE0, tmp_str0001, tmp_str0000, 5);
   Print("Shell", Li_FFDC);
   }} 
   tmp_str0002 = sparam;
   func_1289(tmp_str0002);
}

void func_1270(int Fa_i_00)
{
   string tmp_str0000;
   string tmp_str0001;
   int Li_FFFC;
   int Li_FFF8;
   double Ld_FFF0;
   double Ld_FFE8;

   Gi_0000 = Fa_i_00;
   Gi_0001 = 0;
   Gi_0002 = 0;
   if (OrdersTotal() > 0) { 
   do { 
   if (OrderSelect(Gi_0002, 0, 0) && OrderMagicNumber() == magic && OrderSymbol() == _Symbol) { 
   if (OrderType() == Gi_0000 || Gi_0000 == -1) { 
   
   Gi_0001 = Gi_0001 + 1;
   }} 
   Gi_0002 = Gi_0002 + 1;
   } while (Gi_0002 < OrdersTotal()); 
   } 
   if (Gi_0001 <= ddrCount) return; 
   Gi_0003 = Fa_i_00;
   Gd_0004 = 0;
   Gi_0005 = 0;
   Gi_0006 = OrdersTotal() - 1;
   Gi_0007 = Gi_0006;
   if (Gi_0006 >= 0) { 
   do { 
   if (OrderSelect(Gi_0007, 0, 0) && OrderSymbol() == _Symbol && OrderMagicNumber() == magic && OrderType() == Gi_0003) { 
   returned_double = OrderOpenPrice();
   if ((Gd_0004 < returned_double)) { 
   Gd_0004 = returned_double;
   Gi_0005 = OrderTicket();
   }} 
   Gi_0007 = Gi_0007 - 1;
   } while (Gi_0007 >= 0); 
   } 
   Li_FFFC = Gi_0005;
   Gi_0006 = Fa_i_00;
   Gd_0008 = 2147483647;
   Gi_0009 = 0;
   Gi_000A = OrdersTotal() - 1;
   Gi_000B = Gi_000A;
   if (Gi_000A >= 0) { 
   do { 
   if (OrderSelect(Gi_000B, 0, 0) && OrderSymbol() == _Symbol && OrderMagicNumber() == magic && OrderType() == Gi_0006) { 
   returned_double = OrderOpenPrice();
   if ((Gd_0008 > returned_double)) { 
   Gd_0008 = returned_double;
   Gi_0009 = OrderTicket();
   }} 
   Gi_000B = Gi_000B - 1;
   } while (Gi_000B >= 0); 
   } 
   Li_FFF8 = Gi_0009;
   if (OrderSelect(Li_FFFC, 1, 0)) { 
   Gd_000A = OrderProfit();
   Gd_000A = (Gd_000A + OrderSwap());
   Gd_000A = (Gd_000A + OrderCommission());
   } 
   else { 
   Gd_000A = 0;
   } 
   Ld_FFF0 = Gd_000A;
   if (OrderSelect(Li_FFF8, 1, 0)) { 
   Gd_000C = OrderProfit();
   Gd_000C = (Gd_000C + OrderSwap());
   Gd_000C = (Gd_000C + OrderCommission());
   } 
   else { 
   Gd_000C = 0;
   } 
   Ld_FFE8 = Gd_000C;
   if (((Ld_FFF0 + Gd_000C) <= ddrProfit)) return; 
   tmp_str0000 = "";
   func_1310(Li_FFFC, tmp_str0000);
   tmp_str0001 = "";
   func_1310(Li_FFF8, tmp_str0001);
   
}

double func_1273(int Fa_i_00)
{
   string tmp_str0000;
   string tmp_str0001;
   string tmp_str0002;
   string tmp_str0003;
   string tmp_str0004;
   string tmp_str0005;
   string tmp_str0006;
   string tmp_str0007;
   string tmp_str0008;
   string tmp_str0009;
   double Ld_FFF0;
   double Ld_FFE8;
   double Ld_FFE0;
   double Ld_FFD8;
   double Ld_FFD0;
   double Ld_FFC8;
   double Ld_FFF8;
   string Ls_FFB8;
   int Li_FFB4;
   double Ld_FFA8;
   double Ld_FFA0;
   double Ld_FF98;
   int Li_FF94;
   double Ld_FF88;
   double Ld_FF80;
   string Ls_FF70;
   int Li_FF6C;
   double Ld_FF60;
   double Ld_FF58;
   double Ld_FF50;
   int Li_FF4C;
   double Ld_FF40;
   double Ld_FF38;

   Ld_FFF0 = 0;
   Ld_FFE8 = 0;
   Gb_0000 = false;
   Gi_0001 = 0;
   tmp_str0000 = "";
   tmp_str0000 = _Symbol;
   Gd_0002 = 0;
   Gi_0003 = OrdersTotal() - 1;
   Gi_0004 = Gi_0003;
   if (Gi_0003 >= 0) { 
   do { 
   if (OrderSelect(Gi_0004, 0, 0)) { 
   if (Gb_0000 || OrderSymbol() == tmp_str0000) {
   
   if (OrderMagicNumber() == magic && OrderType() == Gi_0001) { 
   Gd_0003 = OrderProfit();
   Gd_0003 = (Gd_0003 + OrderSwap());
   Gd_0002 = ((Gd_0003 + OrderCommission()) + Gd_0002);
   }}} 
   Gi_0004 = Gi_0004 - 1;
   } while (Gi_0004 >= 0); 
   } 
   Ld_FFE0 = Gd_0002;
   Gb_0003 = false;
   Gi_0005 = 1;
   tmp_str0001 = "";
   tmp_str0001 = _Symbol;
   Gd_0006 = 0;
   Gi_0007 = OrdersTotal() - 1;
   Gi_0008 = Gi_0007;
   if (Gi_0007 >= 0) { 
   do { 
   if (OrderSelect(Gi_0008, 0, 0)) { 
   if (Gb_0003 || OrderSymbol() == tmp_str0001) {
   
   if (OrderMagicNumber() == magic && OrderType() == Gi_0005) { 
   Gd_0007 = OrderProfit();
   Gd_0007 = (Gd_0007 + OrderSwap());
   Gd_0006 = ((Gd_0007 + OrderCommission()) + Gd_0006);
   }}} 
   Gi_0008 = Gi_0008 - 1;
   } while (Gi_0008 >= 0); 
   } 
   Ld_FFD8 = Gd_0006;
   Ld_FFD0 = Ask;
   Ld_FFC8 = Bid;
   Gi_0007 = 0;
   Gi_0009 = 0;
   Gi_000A = 0;
   if (OrdersTotal() > 0) { 
   do { 
   if (OrderSelect(Gi_000A, 0, 0) && OrderMagicNumber() == magic && OrderSymbol() == _Symbol) { 
   if (OrderType() == Gi_0007 || Gi_0007 == -1) { 
   
   Gi_0009 = Gi_0009 + 1;
   }} 
   Gi_000A = Gi_000A + 1;
   } while (Gi_000A < OrdersTotal()); 
   } 
   if (Gi_0009 == 0) { 
   tmp_str0002 = "OLine Buy BO";
   ObjectCreate(0, tmp_str0002, OBJ_HLINE, 0, Time[0], 0);
   ObjectSetDouble(0, tmp_str0002, 20, 0);
   ObjectSetInteger(0, tmp_str0002, 6, 16776960);
   ObjectSetInteger(0, tmp_str0002, 8, 1);
   ObjectSetInteger(0, tmp_str0002, 9, 1);
   ObjectSetInteger(0, tmp_str0002, 1004, 0);
   ObjectSetInteger(0, tmp_str0002, 17, 0);
   ObjectSetInteger(0, tmp_str0002, 1000, 0);
   tmp_str0003 = "OLine Buy TP";
   ObjectCreate(0, tmp_str0003, OBJ_HLINE, 0, Time[0], 0);
   ObjectSetDouble(0, tmp_str0003, 20, 0);
   ObjectSetInteger(0, tmp_str0003, 6, 55295);
   ObjectSetInteger(0, tmp_str0003, 8, 2);
   ObjectSetInteger(0, tmp_str0003, 9, 1);
   ObjectSetInteger(0, tmp_str0003, 1004, 0);
   ObjectSetInteger(0, tmp_str0003, 17, 0);
   ObjectSetInteger(0, tmp_str0003, 1000, 0);
   Id_01E8 = 0;
   if (Fa_i_00 == 0) { 
   Ld_FFF8 = 0;
   return Ld_FFF8;
   }} 
   Gi_000D = 1;
   Gi_000E = 0;
   Gi_000F = 0;
   if (OrdersTotal() > 0) { 
   do { 
   if (OrderSelect(Gi_000F, 0, 0) && OrderMagicNumber() == magic && OrderSymbol() == _Symbol) { 
   if (OrderType() == Gi_000D || Gi_000D == -1) { 
   
   Gi_000E = Gi_000E + 1;
   }} 
   Gi_000F = Gi_000F + 1;
   } while (Gi_000F < OrdersTotal()); 
   } 
   if (Gi_000E == 0) { 
   tmp_str0004 = "OLine Sell BO";
   ObjectCreate(0, tmp_str0004, OBJ_HLINE, 0, Time[0], 0);
   ObjectSetDouble(0, tmp_str0004, 20, 0);
   ObjectSetInteger(0, tmp_str0004, 6, 16776960);
   ObjectSetInteger(0, tmp_str0004, 8, 1);
   ObjectSetInteger(0, tmp_str0004, 9, 1);
   ObjectSetInteger(0, tmp_str0004, 1004, 0);
   ObjectSetInteger(0, tmp_str0004, 17, 0);
   ObjectSetInteger(0, tmp_str0004, 1000, 0);
   tmp_str0005 = "OLine Sell TP";
   ObjectCreate(0, tmp_str0005, OBJ_HLINE, 0, Time[0], 0);
   ObjectSetDouble(0, tmp_str0005, 20, 0);
   ObjectSetInteger(0, tmp_str0005, 6, 55295);
   ObjectSetInteger(0, tmp_str0005, 8, 2);
   ObjectSetInteger(0, tmp_str0005, 9, 1);
   ObjectSetInteger(0, tmp_str0005, 1004, 0);
   ObjectSetInteger(0, tmp_str0005, 17, 0);
   ObjectSetInteger(0, tmp_str0005, 1000, 0);
   Id_01F0 = 0;
   if (Fa_i_00 == 1) { 
   Ld_FFF8 = 0;
   return Ld_FFF8;
   }} 
   if (Fa_i_00 == 0) { 
   Ls_FFB8 = _Symbol;
   Li_FFB4 = OrdersTotal() - 1;
   Ld_FFA8 = 0;
   Ld_FFA0 = 0;
   Ld_FF98 = 0;
   Li_FF94 = Li_FFB4;
   if (Li_FFB4 >= 0) { 
   do { 
   if (OrderSelect(Li_FF94, 0, 0) && OrderSymbol() == Ls_FFB8 && OrderMagicNumber() == magic && OrderType() == Fa_i_00) { 
   Ld_FF88 = (OrderLots() * 100);
   returned_double = OrderOpenPrice();
   Ld_FF80 = returned_double;
   Ld_FFA8 = ((Ld_FF88 * returned_double) + Ld_FFA8);
   Ld_FFA0 = (Ld_FFA0 + Ld_FF88);
   } 
   Li_FF94 = Li_FF94 - 1;
   } while (Li_FF94 >= 0); 
   } 
   if ((Ld_FFA0 != 0)) { 
   Ld_FF98 = (Ld_FFA8 / Ld_FFA0);
   } 
   tmp_str0006 = "OLine Buy BO";
   ObjectCreate(0, tmp_str0006, OBJ_HLINE, 0, Time[0], Ld_FF98);
   ObjectSetDouble(0, tmp_str0006, 20, Ld_FF98);
   ObjectSetInteger(0, tmp_str0006, 6, 16776960);
   ObjectSetInteger(0, tmp_str0006, 8, 1);
   ObjectSetInteger(0, tmp_str0006, 9, 1);
   ObjectSetInteger(0, tmp_str0006, 1004, 0);
   ObjectSetInteger(0, tmp_str0006, 17, 0);
   ObjectSetInteger(0, tmp_str0006, 1000, 0);
   Gi_0013 = 2;
   Gi_0014 = 55295;
   Gd_0015 = takeprofit;
   Gd_0016 = 0;
   if (_Digits == 5 || _Digits == 3) { 
   
   Gd_0016 = (_Point * 10);
   } 
   else { 
   Gd_0016 = _Point;
   } 
   if (_Symbol == "GOLD" || _Symbol == "SILVER" || _Digits == 2) { 
   
   Gd_0017 = (Gd_0015 / 10);
   } 
   else { 
   if (_Symbol == "GOLDEURO" || _Symbol == "SILVEREURO") { 
   
   Gd_0016 = _Point;
   } 
   Gd_0017 = (Gd_0015 * Gd_0016);
   } 
   Gd_0018 = (Ld_FF98 + Gd_0017);
   tmp_str0007 = "OLine Buy TP";
   ObjectCreate(0, tmp_str0007, OBJ_HLINE, 0, Time[0], Gd_0018);
   ObjectSetDouble(0, tmp_str0007, 20, Gd_0018);
   ObjectSetInteger(0, tmp_str0007, 6, Gi_0014);
   ObjectSetInteger(0, tmp_str0007, 8, Gi_0013);
   ObjectSetInteger(0, tmp_str0007, 9, 1);
   ObjectSetInteger(0, tmp_str0007, 1004, 0);
   ObjectSetInteger(0, tmp_str0007, 17, 0);
   ObjectSetInteger(0, tmp_str0007, 1000, 0);
   Gd_001A = takeprofit;
   Gd_001B = 0;
   if (_Digits == 5 || _Digits == 3) { 
   
   Gd_001B = (_Point * 10);
   } 
   else { 
   Gd_001B = _Point;
   } 
   if (_Symbol == "GOLD" || _Symbol == "SILVER" || _Digits == 2) { 
   
   Gd_001C = (Gd_001A / 10);
   } 
   else { 
   if (_Symbol == "GOLDEURO" || _Symbol == "SILVEREURO") { 
   
   Gd_001B = _Point;
   } 
   Gd_001C = (Gd_001A * Gd_001B);
   } 
   Id_01E8 = (Ld_FF98 + Gd_001C);
   return -1;
   } 
   if (Fa_i_00 != 1) return -1; 
   Ls_FF70 = _Symbol;
   Li_FF6C = OrdersTotal() - 1;
   Ld_FF60 = 0;
   Ld_FF58 = 0;
   Ld_FF50 = 0;
   Li_FF4C = Li_FF6C;
   if (Li_FF6C >= 0) { 
   do { 
   if (OrderSelect(Li_FF4C, 0, 0) && OrderSymbol() == Ls_FF70 && OrderMagicNumber() == magic && OrderType() == Fa_i_00) { 
   Ld_FF40 = (OrderLots() * 100);
   returned_double = OrderOpenPrice();
   Ld_FF38 = returned_double;
   Ld_FF60 = ((Ld_FF40 * returned_double) + Ld_FF60);
   Ld_FF58 = (Ld_FF58 + Ld_FF40);
   } 
   Li_FF4C = Li_FF4C - 1;
   } while (Li_FF4C >= 0); 
   } 
   if ((Ld_FF58 != 0)) { 
   Ld_FF50 = (Ld_FF60 / Ld_FF58);
   } 
   tmp_str0008 = "OLine Sell BO";
   ObjectCreate(0, tmp_str0008, OBJ_HLINE, 0, Time[0], Ld_FF50);
   ObjectSetDouble(0, tmp_str0008, 20, Ld_FF50);
   ObjectSetInteger(0, tmp_str0008, 6, 16776960);
   ObjectSetInteger(0, tmp_str0008, 8, 1);
   ObjectSetInteger(0, tmp_str0008, 9, 1);
   ObjectSetInteger(0, tmp_str0008, 1004, 0);
   ObjectSetInteger(0, tmp_str0008, 17, 0);
   ObjectSetInteger(0, tmp_str0008, 1000, 0);
   Gi_001E = 2;
   Gi_001F = 55295;
   Gd_0020 = takeprofit;
   Gd_0021 = 0;
   if (_Digits == 5 || _Digits == 3) { 
   
   Gd_0021 = (_Point * 10);
   } 
   else { 
   Gd_0021 = _Point;
   } 
   if (_Symbol == "GOLD" || _Symbol == "SILVER" || _Digits == 2) { 
   
   Gd_0022 = (Gd_0020 / 10);
   } 
   else { 
   if (_Symbol == "GOLDEURO" || _Symbol == "SILVEREURO") { 
   
   Gd_0021 = _Point;
   } 
   Gd_0022 = (Gd_0020 * Gd_0021);
   } 
   Gd_0023 = (Ld_FF50 - Gd_0022);
   tmp_str0009 = "OLine Sell TP";
   ObjectCreate(0, tmp_str0009, OBJ_HLINE, 0, Time[0], Gd_0023);
   ObjectSetDouble(0, tmp_str0009, 20, Gd_0023);
   ObjectSetInteger(0, tmp_str0009, 6, Gi_001F);
   ObjectSetInteger(0, tmp_str0009, 8, Gi_001E);
   ObjectSetInteger(0, tmp_str0009, 9, 1);
   ObjectSetInteger(0, tmp_str0009, 1004, 0);
   ObjectSetInteger(0, tmp_str0009, 17, 0);
   ObjectSetInteger(0, tmp_str0009, 1000, 0);
   Gd_0025 = takeprofit;
   Gd_0026 = 0;
   if (_Digits == 5 || _Digits == 3) { 
   
   Gd_0026 = (_Point * 10);
   } 
   else { 
   Gd_0026 = _Point;
   } 
   if (_Symbol == "GOLD" || _Symbol == "SILVER" || _Digits == 2) { 
   
   Gd_0027 = (Gd_0025 / 10);
   } 
   else { 
   if (_Symbol == "GOLDEURO" || _Symbol == "SILVEREURO") { 
   
   Gd_0026 = _Point;
   } 
   Gd_0027 = (Gd_0025 * Gd_0026);
   } 
   Id_01F0 = (Ld_FF50 - Gd_0027);
   
   Ld_FFF8 = -1;
   
   return  Ld_FFF8;
}

int func_1276()
{
   string tmp_str0000;
   string tmp_str0001;
   string tmp_str0002;
   string tmp_str0003;
   string tmp_str0004;
   string tmp_str0005;
   string tmp_str0006;
   string tmp_str0007;
   string tmp_str0008;
   string tmp_str0009;
   string tmp_str000A;
   string tmp_str000B;
   string tmp_str000C;
   string tmp_str000D;
   string tmp_str000E;
   string tmp_str000F;
   string tmp_str0010;
   string tmp_str0011;
   string tmp_str0012;
   string tmp_str0013;
   string tmp_str0014;
   string tmp_str0015;
   string tmp_str0016;
   string tmp_str0017;
   string tmp_str0018;
   string tmp_str0019;
   string tmp_str001A;
   string tmp_str001B;
   string tmp_str001C;
   string tmp_str001D;
   string tmp_str001E;
   string tmp_str001F;
   string tmp_str0020;
   string tmp_str0021;
   string tmp_str0022;
   string tmp_str0023;
   string tmp_str0024;
   string tmp_str0025;
   string tmp_str0026;
   string tmp_str0027;
   string tmp_str0028;
   string tmp_str0029;
   string tmp_str002A;
   string tmp_str002B;
   string tmp_str002C;
   string tmp_str002D;
   string tmp_str002E;
   string tmp_str002F;
   string tmp_str0030;
   string tmp_str0031;
   string tmp_str0032;
   string tmp_str0033;
   string tmp_str0034;
   string tmp_str0035;
   string tmp_str0036;
   string tmp_str0037;
   string tmp_str0038;
   string tmp_str0039;
   string tmp_str003A;
   string tmp_str003B;
   string tmp_str003C;
   string tmp_str003D;
   string tmp_str003E;
   string tmp_str003F;
   string tmp_str0040;
   string tmp_str0041;
   string tmp_str0042;
   string tmp_str0043;
   string tmp_str0044;
   string tmp_str0045;
   string tmp_str0046;
   string tmp_str0047;
   string tmp_str0048;
   string tmp_str0049;
   string tmp_str004A;
   string tmp_str004B;
   string tmp_str004C;
   string tmp_str004D;
   string tmp_str004E;
   string tmp_str004F;
   string tmp_str0050;
   string tmp_str0051;
   string tmp_str0052;
   string tmp_str0053;
   string tmp_str0054;
   string tmp_str0055;
   string tmp_str0056;
   string tmp_str0057;
   string tmp_str0058;
   string tmp_str0059;
   string tmp_str005A;
   int Li_FFF8;
   int Li_FFF4;
   int Li_FFF0;
   int Li_FFEC;
   int Li_FFE8;
   int Li_FFE4;
   int Li_FFE0;
   int Li_FFDC;
   double Ld_FFD0;
   int Li_FFFC;
   double Ld_FFC8;
   double Ld_FFC0;
   double Ld_FFB8;
   double Ld_FFB0;

   Li_FFF8 = 15;
   Li_FFF4 = 125;
   Li_FFF0 = 25;
   Li_FFEC = 17;
   Li_FFE8 = 275;
   Li_FFE4 = 315;
   if (IsTesting()) { 
   Li_FFE4 = 240;
   } 
   if (highRes) { 
   Li_FFF8 = 15;
   Li_FFF4 = 170;
   Li_FFF0 = 25;
   Li_FFEC = 25;
   Li_FFE8 = 370;
   Li_FFE4 = 390;
   if (IsTesting()) { 
   Li_FFE4 = 400;
   }} 
   if (Ii_0098 == 1) { 
   Li_FFE4 = Li_FFE4 - 110;
   } 
   Li_FFE0 = (int)ChartGetInteger(0, 22, 0);
   Li_FFDC = (int)ChartGetInteger(0, 21, 0);
   if (dbtype == 1) { 
   tmp_str0000 = "Net Profit: ";
   tmp_str0002 = "OBJText" + IntegerToString(Li_FFF8, 0, 32);
   tmp_str0002 = tmp_str0002 + IntegerToString(Li_FFF0, 0, 32);
   tmp_str0001 = tmp_str0002;
   ObjectCreate(0, tmp_str0001, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str0001, 6, Li_FFE0);
   ObjectSetInteger(0, tmp_str0001, 9, 0);
   ObjectSetInteger(0, tmp_str0001, 1000, 0);
   ObjectSetInteger(0, tmp_str0001, 17, 0);
   ObjectSetString(0, tmp_str0001, 999, tmp_str0000);
   ObjectSetInteger(0, tmp_str0001, 102, Li_FFF8);
   ObjectSetInteger(0, tmp_str0001, 103, Li_FFF0);
   ObjectSetInteger(0, tmp_str0001, 100, 8);
   Gb_0000 = false;
   Gi_0001 = 0;
   tmp_str0002 = "";
   tmp_str0002 = _Symbol;
   Gd_0002 = 0;
   Gi_0003 = OrdersTotal() - 1;
   Gi_0004 = Gi_0003;
   if (Gi_0003 >= 0) { 
   do { 
   if (OrderSelect(Gi_0004, 0, 0)) { 
   if (Gb_0000 || OrderSymbol() == tmp_str0002) {
   
   if (OrderMagicNumber() == magic && OrderType() == Gi_0001) { 
   Gd_0003 = OrderProfit();
   Gd_0003 = (Gd_0003 + OrderSwap());
   Gd_0002 = ((Gd_0003 + OrderCommission()) + Gd_0002);
   }}} 
   Gi_0004 = Gi_0004 - 1;
   } while (Gi_0004 >= 0); 
   } 
   Gd_0003 = Gd_0002;
   Gb_0005 = false;
   Gi_0006 = 1;
   tmp_str0003 = "";
   tmp_str0003 = _Symbol;
   Gd_0007 = 0;
   Gi_0008 = OrdersTotal() - 1;
   Gi_0009 = Gi_0008;
   if (Gi_0008 >= 0) { 
   do { 
   if (OrderSelect(Gi_0009, 0, 0)) { 
   if (Gb_0005 || OrderSymbol() == tmp_str0003) {
   
   if (OrderMagicNumber() == magic && OrderType() == Gi_0006) { 
   Gd_0008 = OrderProfit();
   Gd_0008 = (Gd_0008 + OrderSwap());
   Gd_0007 = ((Gd_0008 + OrderCommission()) + Gd_0007);
   }}} 
   Gi_0009 = Gi_0009 - 1;
   } while (Gi_0009 >= 0); 
   } 
   Ld_FFD0 = (Gd_0003 + Gd_0007);
   if ((Ld_FFD0 >= 0)) { 
   tmp_str0004 = AccountCurrency();
   tmp_str0004 = tmp_str0004 + " ";
   tmp_str0004 = tmp_str0004 + DoubleToString(Ld_FFD0, 2);
   tmp_str0006 = "OBJText" + IntegerToString(Li_FFF4, 0, 32);
   tmp_str0006 = tmp_str0006 + IntegerToString(Li_FFF0, 0, 32);
   tmp_str0005 = tmp_str0006;
   ObjectCreate(0, tmp_str0005, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str0005, 6, 3329330);
   ObjectSetInteger(0, tmp_str0005, 9, 0);
   ObjectSetInteger(0, tmp_str0005, 1000, 0);
   ObjectSetInteger(0, tmp_str0005, 17, 0);
   ObjectSetString(0, tmp_str0005, 999, tmp_str0004);
   ObjectSetInteger(0, tmp_str0005, 102, Li_FFF4);
   ObjectSetInteger(0, tmp_str0005, 103, Li_FFF0);
   ObjectSetInteger(0, tmp_str0005, 100, 8);
   Li_FFF0 = Li_FFF0 + Li_FFEC;
   } 
   if ((Ld_FFD0 < 0)) { 
   tmp_str0006 = AccountCurrency();
   tmp_str0006 = tmp_str0006 + " ";
   tmp_str0006 = tmp_str0006 + DoubleToString(Ld_FFD0, 2);
   tmp_str0008 = "OBJText" + IntegerToString(Li_FFF4, 0, 32);
   tmp_str0008 = tmp_str0008 + IntegerToString(Li_FFF0, 0, 32);
   tmp_str0007 = tmp_str0008;
   ObjectCreate(0, tmp_str0007, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str0007, 6, 4678655);
   ObjectSetInteger(0, tmp_str0007, 9, 0);
   ObjectSetInteger(0, tmp_str0007, 1000, 0);
   ObjectSetInteger(0, tmp_str0007, 17, 0);
   ObjectSetString(0, tmp_str0007, 999, tmp_str0006);
   ObjectSetInteger(0, tmp_str0007, 102, Li_FFF4);
   ObjectSetInteger(0, tmp_str0007, 103, Li_FFF0);
   ObjectSetInteger(0, tmp_str0007, 100, 8);
   Li_FFF0 = Li_FFF0 + Li_FFEC;
   } 
   Li_FFF0 = Li_FFF0 + 10;
   tmp_str0008 = "Balance: ";
   tmp_str000A = "OBJText" + IntegerToString(Li_FFF8, 0, 32);
   tmp_str000A = tmp_str000A + IntegerToString(Li_FFF0, 0, 32);
   tmp_str0009 = tmp_str000A;
   ObjectCreate(0, tmp_str0009, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str0009, 6, Li_FFE0);
   ObjectSetInteger(0, tmp_str0009, 9, 0);
   ObjectSetInteger(0, tmp_str0009, 1000, 0);
   ObjectSetInteger(0, tmp_str0009, 17, 0);
   ObjectSetString(0, tmp_str0009, 999, tmp_str0008);
   ObjectSetInteger(0, tmp_str0009, 102, Li_FFF8);
   ObjectSetInteger(0, tmp_str0009, 103, Li_FFF0);
   ObjectSetInteger(0, tmp_str0009, 100, 8);
   tmp_str000A = AccountCurrency();
   tmp_str000A = tmp_str000A + " ";
   tmp_str000A = tmp_str000A + DoubleToString(AccountBalance(), 2);
   tmp_str000C = "OBJText" + IntegerToString(Li_FFF4, 0, 32);
   tmp_str000C = tmp_str000C + IntegerToString(Li_FFF0, 0, 32);
   tmp_str000B = tmp_str000C;
   ObjectCreate(0, tmp_str000B, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str000B, 6, 3329330);
   ObjectSetInteger(0, tmp_str000B, 9, 0);
   ObjectSetInteger(0, tmp_str000B, 1000, 0);
   ObjectSetInteger(0, tmp_str000B, 17, 0);
   ObjectSetString(0, tmp_str000B, 999, tmp_str000A);
   ObjectSetInteger(0, tmp_str000B, 102, Li_FFF4);
   ObjectSetInteger(0, tmp_str000B, 103, Li_FFF0);
   ObjectSetInteger(0, tmp_str000B, 100, 8);
   Li_FFF0 = Li_FFF0 + Li_FFEC;
   tmp_str000C = "Equity: ";
   tmp_str000E = "OBJText" + IntegerToString(Li_FFF8, 0, 32);
   tmp_str000E = tmp_str000E + IntegerToString(Li_FFF0, 0, 32);
   tmp_str000D = tmp_str000E;
   ObjectCreate(0, tmp_str000D, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str000D, 6, Li_FFE0);
   ObjectSetInteger(0, tmp_str000D, 9, 0);
   ObjectSetInteger(0, tmp_str000D, 1000, 0);
   ObjectSetInteger(0, tmp_str000D, 17, 0);
   ObjectSetString(0, tmp_str000D, 999, tmp_str000C);
   ObjectSetInteger(0, tmp_str000D, 102, Li_FFF8);
   ObjectSetInteger(0, tmp_str000D, 103, Li_FFF0);
   ObjectSetInteger(0, tmp_str000D, 100, 8);
   tmp_str000E = AccountCurrency();
   tmp_str000E = tmp_str000E + " ";
   tmp_str000E = tmp_str000E + DoubleToString(AccountEquity(), 2);
   tmp_str0010 = "OBJText" + IntegerToString(Li_FFF4, 0, 32);
   tmp_str0010 = tmp_str0010 + IntegerToString(Li_FFF0, 0, 32);
   tmp_str000F = tmp_str0010;
   ObjectCreate(0, tmp_str000F, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str000F, 6, 3329330);
   ObjectSetInteger(0, tmp_str000F, 9, 0);
   ObjectSetInteger(0, tmp_str000F, 1000, 0);
   ObjectSetInteger(0, tmp_str000F, 17, 0);
   ObjectSetString(0, tmp_str000F, 999, tmp_str000E);
   ObjectSetInteger(0, tmp_str000F, 102, Li_FFF4);
   ObjectSetInteger(0, tmp_str000F, 103, Li_FFF0);
   ObjectSetInteger(0, tmp_str000F, 100, 8);
   Li_FFF0 = Li_FFF0 + Li_FFEC;
   func_1277(Li_FFF8, Li_FFF0, Li_FFEC, Li_FFE0);
   Li_FFFC = Li_FFF0;
   return Li_FFFC;
   } 
   if (dbtype == 2) { 
   func_1277(Li_FFF8, Li_FFF0, Li_FFEC, Li_FFE0);
   Li_FFFC = Li_FFF0;
   return Li_FFFC;
   } 
   tmp_str0010 = "OBJBoarder";
   tmp_str0010 = "OBJOBJBoarder";
   ObjectCreate(0, tmp_str0010, OBJ_RECTANGLE_LABEL, 0, Time[0], 0);
   ObjectSetInteger(0, tmp_str0010, 1025, Li_FFDC);
   ObjectSetInteger(0, tmp_str0010, 9, 0);
   ObjectSetInteger(0, tmp_str0010, 17, 0);
   ObjectSetInteger(0, tmp_str0010, 1000, 0);
   ObjectSetInteger(0, tmp_str0010, 102, 5);
   ObjectSetInteger(0, tmp_str0010, 103, 20);
   ObjectSetInteger(0, tmp_str0010, 1019, Li_FFE8);
   ObjectSetInteger(0, tmp_str0010, 1020, Li_FFE4);
   ObjectSetInteger(0, tmp_str0010, 1031, 0);
   tmp_str0011 = Is_01A8;
   tmp_str0013 = "OBJText" + IntegerToString(Li_FFF8, 0, 32);
   tmp_str0013 = tmp_str0013 + IntegerToString(Li_FFF0, 0, 32);
   tmp_str0012 = tmp_str0013;
   ObjectCreate(0, tmp_str0012, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str0012, 6, 42495);
   ObjectSetInteger(0, tmp_str0012, 9, 0);
   ObjectSetInteger(0, tmp_str0012, 1000, 0);
   ObjectSetInteger(0, tmp_str0012, 17, 0);
   ObjectSetString(0, tmp_str0012, 999, tmp_str0011);
   ObjectSetInteger(0, tmp_str0012, 102, Li_FFF8);
   ObjectSetInteger(0, tmp_str0012, 103, Li_FFF0);
   ObjectSetInteger(0, tmp_str0012, 100, 12);
   Li_FFF0 = Li_FFF0 + 30;
   tmp_str0013 = TimeToString(TimeCurrent(), 3);
   tmp_str0015 = "OBJText" + IntegerToString(Li_FFF8, 0, 32);
   tmp_str0015 = tmp_str0015 + IntegerToString(Li_FFF0, 0, 32);
   tmp_str0014 = tmp_str0015;
   ObjectCreate(0, tmp_str0014, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str0014, 6, Li_FFE0);
   ObjectSetInteger(0, tmp_str0014, 9, 0);
   ObjectSetInteger(0, tmp_str0014, 1000, 0);
   ObjectSetInteger(0, tmp_str0014, 17, 0);
   ObjectSetString(0, tmp_str0014, 999, tmp_str0013);
   ObjectSetInteger(0, tmp_str0014, 102, Li_FFF8);
   ObjectSetInteger(0, tmp_str0014, 103, Li_FFF0);
   ObjectSetInteger(0, tmp_str0014, 100, 8);
   Li_FFF0 = Li_FFF0 + Li_FFEC;
   Li_FFF0 = Li_FFF0 + 10;
   tmp_str0015 = "Spread: ";
   tmp_str0017 = "OBJText" + IntegerToString(Li_FFF8, 0, 32);
   tmp_str0017 = tmp_str0017 + IntegerToString(Li_FFF0, 0, 32);
   tmp_str0016 = tmp_str0017;
   ObjectCreate(0, tmp_str0016, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str0016, 6, Li_FFE0);
   ObjectSetInteger(0, tmp_str0016, 9, 0);
   ObjectSetInteger(0, tmp_str0016, 1000, 0);
   ObjectSetInteger(0, tmp_str0016, 17, 0);
   ObjectSetString(0, tmp_str0016, 999, tmp_str0015);
   ObjectSetInteger(0, tmp_str0016, 102, Li_FFF8);
   ObjectSetInteger(0, tmp_str0016, 103, Li_FFF0);
   ObjectSetInteger(0, tmp_str0016, 100, 8);
   tmp_str0017 = DoubleToString(MarketInfo(NULL, MODE_SPREAD), 0);
   tmp_str0017 = tmp_str0017 + " points";
   tmp_str0019 = "OBJText" + IntegerToString(Li_FFF4, 0, 32);
   tmp_str0019 = tmp_str0019 + IntegerToString(Li_FFF0, 0, 32);
   tmp_str0018 = tmp_str0019;
   ObjectCreate(0, tmp_str0018, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str0018, 6, Li_FFE0);
   ObjectSetInteger(0, tmp_str0018, 9, 0);
   ObjectSetInteger(0, tmp_str0018, 1000, 0);
   ObjectSetInteger(0, tmp_str0018, 17, 0);
   ObjectSetString(0, tmp_str0018, 999, tmp_str0017);
   ObjectSetInteger(0, tmp_str0018, 102, Li_FFF4);
   ObjectSetInteger(0, tmp_str0018, 103, Li_FFF0);
   ObjectSetInteger(0, tmp_str0018, 100, 8);
   Li_FFF0 = Li_FFF0 + Li_FFEC;
   tmp_str0019 = "Net Profit: ";
   tmp_str001B = "OBJText" + IntegerToString(Li_FFF8, 0, 32);
   tmp_str001B = tmp_str001B + IntegerToString(Li_FFF0, 0, 32);
   tmp_str001A = tmp_str001B;
   ObjectCreate(0, tmp_str001A, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str001A, 6, Li_FFE0);
   ObjectSetInteger(0, tmp_str001A, 9, 0);
   ObjectSetInteger(0, tmp_str001A, 1000, 0);
   ObjectSetInteger(0, tmp_str001A, 17, 0);
   ObjectSetString(0, tmp_str001A, 999, tmp_str0019);
   ObjectSetInteger(0, tmp_str001A, 102, Li_FFF8);
   ObjectSetInteger(0, tmp_str001A, 103, Li_FFF0);
   ObjectSetInteger(0, tmp_str001A, 100, 8);
   Gb_000A = false;
   Gi_000B = 0;
   tmp_str001B = "";
   tmp_str001B = _Symbol;
   Gd_000C = 0;
   Gi_000D = OrdersTotal() - 1;
   Gi_000E = Gi_000D;
   if (Gi_000D >= 0) { 
   do { 
   if (OrderSelect(Gi_000E, 0, 0)) { 
   if (Gb_000A || OrderSymbol() == tmp_str001B) {
   
   if (OrderMagicNumber() == magic && OrderType() == Gi_000B) { 
   Gd_000D = OrderProfit();
   Gd_000D = (Gd_000D + OrderSwap());
   Gd_000C = ((Gd_000D + OrderCommission()) + Gd_000C);
   }}} 
   Gi_000E = Gi_000E - 1;
   } while (Gi_000E >= 0); 
   } 
   Gd_000D = Gd_000C;
   Gb_000F = false;
   Gi_0010 = 1;
   tmp_str001C = "";
   tmp_str001C = _Symbol;
   Gd_0011 = 0;
   Gi_0012 = OrdersTotal() - 1;
   Gi_0013 = Gi_0012;
   if (Gi_0012 >= 0) { 
   do { 
   if (OrderSelect(Gi_0013, 0, 0)) { 
   if (Gb_000F || OrderSymbol() == tmp_str001C) {
   
   if (OrderMagicNumber() == magic && OrderType() == Gi_0010) { 
   Gd_0012 = OrderProfit();
   Gd_0012 = (Gd_0012 + OrderSwap());
   Gd_0011 = ((Gd_0012 + OrderCommission()) + Gd_0011);
   }}} 
   Gi_0013 = Gi_0013 - 1;
   } while (Gi_0013 >= 0); 
   } 
   Ld_FFC8 = (Gd_000D + Gd_0011);
   if ((Ld_FFC8 >= 0)) { 
   tmp_str001D = AccountCurrency();
   tmp_str001D = tmp_str001D + " ";
   tmp_str001D = tmp_str001D + DoubleToString(Ld_FFC8, 2);
   tmp_str001F = "OBJText" + IntegerToString(Li_FFF4, 0, 32);
   tmp_str001F = tmp_str001F + IntegerToString(Li_FFF0, 0, 32);
   tmp_str001E = tmp_str001F;
   ObjectCreate(0, tmp_str001E, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str001E, 6, 3329330);
   ObjectSetInteger(0, tmp_str001E, 9, 0);
   ObjectSetInteger(0, tmp_str001E, 1000, 0);
   ObjectSetInteger(0, tmp_str001E, 17, 0);
   ObjectSetString(0, tmp_str001E, 999, tmp_str001D);
   ObjectSetInteger(0, tmp_str001E, 102, Li_FFF4);
   ObjectSetInteger(0, tmp_str001E, 103, Li_FFF0);
   ObjectSetInteger(0, tmp_str001E, 100, 8);
   Li_FFF0 = Li_FFF0 + Li_FFEC;
   } 
   Gb_0012 = (Ld_FFC8 < 0);
   if (Gb_0012) { 
   tmp_str001F = AccountCurrency();
   tmp_str001F = tmp_str001F + " ";
   tmp_str001F = tmp_str001F + DoubleToString(Ld_FFC8, 2);
   tmp_str0021 = "OBJText" + IntegerToString(Li_FFF4, 0, 32);
   tmp_str0021 = tmp_str0021 + IntegerToString(Li_FFF0, 0, 32);
   tmp_str0020 = tmp_str0021;
   ObjectCreate(0, tmp_str0020, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str0020, 6, 4678655);
   ObjectSetInteger(0, tmp_str0020, 9, 0);
   ObjectSetInteger(0, tmp_str0020, 1000, 0);
   ObjectSetInteger(0, tmp_str0020, 17, 0);
   ObjectSetString(0, tmp_str0020, 999, tmp_str001F);
   ObjectSetInteger(0, tmp_str0020, 102, Li_FFF4);
   ObjectSetInteger(0, tmp_str0020, 103, Li_FFF0);
   ObjectSetInteger(0, tmp_str0020, 100, 8);
   Li_FFF0 = Li_FFF0 + Li_FFEC;
   } 
   tmp_str0021 = "Draw Down: ";
   tmp_str0023 = "OBJText" + IntegerToString(Li_FFF8, 0, 32);
   tmp_str0023 = tmp_str0023 + IntegerToString(Li_FFF0, 0, 32);
   tmp_str0022 = tmp_str0023;
   ObjectCreate(0, tmp_str0022, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str0022, 6, Li_FFE0);
   ObjectSetInteger(0, tmp_str0022, 9, 0);
   ObjectSetInteger(0, tmp_str0022, 1000, 0);
   ObjectSetInteger(0, tmp_str0022, 17, 0);
   ObjectSetString(0, tmp_str0022, 999, tmp_str0021);
   ObjectSetInteger(0, tmp_str0022, 102, Li_FFF8);
   ObjectSetInteger(0, tmp_str0022, 103, Li_FFF0);
   ObjectSetInteger(0, tmp_str0022, 100, 8);
   Gb_0012 = false;
   Gi_0014 = 0;
   tmp_str0023 = "";
   tmp_str0023 = _Symbol;
   Gd_0015 = 0;
   Gi_0016 = OrdersTotal() - 1;
   Gi_0017 = Gi_0016;
   if (Gi_0016 >= 0) { 
   do { 
   if (OrderSelect(Gi_0017, 0, 0)) { 
   if (Gb_0012 || OrderSymbol() == tmp_str0023) {
   
   if (OrderMagicNumber() == magic && OrderType() == Gi_0014) { 
   Gd_0016 = OrderProfit();
   Gd_0016 = (Gd_0016 + OrderSwap());
   Gd_0015 = ((Gd_0016 + OrderCommission()) + Gd_0015);
   }}} 
   Gi_0017 = Gi_0017 - 1;
   } while (Gi_0017 >= 0); 
   } 
   Gd_0016 = Gd_0015;
   Gb_0018 = false;
   Gi_0019 = 1;
   tmp_str0024 = "";
   tmp_str0024 = _Symbol;
   Gd_001A = 0;
   Gi_001B = OrdersTotal() - 1;
   Gi_001C = Gi_001B;
   if (Gi_001B >= 0) { 
   do { 
   if (OrderSelect(Gi_001C, 0, 0)) { 
   if (Gb_0018 || OrderSymbol() == tmp_str0024) {
   
   if (OrderMagicNumber() == magic && OrderType() == Gi_0019) { 
   Gd_001B = OrderProfit();
   Gd_001B = (Gd_001B + OrderSwap());
   Gd_001A = ((Gd_001B + OrderCommission()) + Gd_001A);
   }}} 
   Gi_001C = Gi_001C - 1;
   } while (Gi_001C >= 0); 
   } 
   Ld_FFC0 = (Gd_0016 + Gd_001A);
   Ld_FFB8 = 0;
   if ((AccountBalance() > 0)) { 
   Gd_001B = (AccountBalance() - Ld_FFC0);
   Ld_FFB8 = (((Gd_001B / AccountBalance()) - 1) * 100);
   } 
   if ((Ld_FFB8 < 20)) { 
   tmp_str0025 = AccountCurrency();
   tmp_str0025 = tmp_str0025 + " ";
   tmp_str0025 = tmp_str0025 + DoubleToString(Ld_FFC0, 2);
   tmp_str0025 = tmp_str0025 + " (";
   tmp_str0025 = tmp_str0025 + DoubleToString(Ld_FFB8, 2);
   tmp_str0025 = tmp_str0025 + " %)";
   tmp_str0027 = "OBJText" + IntegerToString(Li_FFF4, 0, 32);
   tmp_str0027 = tmp_str0027 + IntegerToString(Li_FFF0, 0, 32);
   tmp_str0026 = tmp_str0027;
   ObjectCreate(0, tmp_str0026, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str0026, 6, 3329330);
   ObjectSetInteger(0, tmp_str0026, 9, 0);
   ObjectSetInteger(0, tmp_str0026, 1000, 0);
   ObjectSetInteger(0, tmp_str0026, 17, 0);
   ObjectSetString(0, tmp_str0026, 999, tmp_str0025);
   ObjectSetInteger(0, tmp_str0026, 102, Li_FFF4);
   ObjectSetInteger(0, tmp_str0026, 103, Li_FFF0);
   ObjectSetInteger(0, tmp_str0026, 100, 8);
   Li_FFF0 = Li_FFF0 + Li_FFEC;
   } 
   if ((Ld_FFB8 >= 20)) { 
   tmp_str0027 = AccountCurrency();
   tmp_str0027 = tmp_str0027 + " ";
   tmp_str0027 = tmp_str0027 + DoubleToString(Ld_FFC0, 2);
   tmp_str0027 = tmp_str0027 + " (";
   tmp_str0027 = tmp_str0027 + DoubleToString(Ld_FFB8, 2);
   tmp_str0027 = tmp_str0027 + " %)";
   tmp_str0029 = "OBJText" + IntegerToString(Li_FFF4, 0, 32);
   tmp_str0029 = tmp_str0029 + IntegerToString(Li_FFF0, 0, 32);
   tmp_str0028 = tmp_str0029;
   ObjectCreate(0, tmp_str0028, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str0028, 6, 4678655);
   ObjectSetInteger(0, tmp_str0028, 9, 0);
   ObjectSetInteger(0, tmp_str0028, 1000, 0);
   ObjectSetInteger(0, tmp_str0028, 17, 0);
   ObjectSetString(0, tmp_str0028, 999, tmp_str0027);
   ObjectSetInteger(0, tmp_str0028, 102, Li_FFF4);
   ObjectSetInteger(0, tmp_str0028, 103, Li_FFF0);
   ObjectSetInteger(0, tmp_str0028, 100, 8);
   Li_FFF0 = Li_FFF0 + Li_FFEC;
   } 
   tmp_str0029 = "Weekly Profit: ";
   tmp_str002B = "OBJText" + IntegerToString(Li_FFF8, 0, 32);
   tmp_str002B = tmp_str002B + IntegerToString(Li_FFF0, 0, 32);
   tmp_str002A = tmp_str002B;
   ObjectCreate(0, tmp_str002A, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str002A, 6, Li_FFE0);
   ObjectSetInteger(0, tmp_str002A, 9, 0);
   ObjectSetInteger(0, tmp_str002A, 1000, 0);
   ObjectSetInteger(0, tmp_str002A, 17, 0);
   ObjectSetString(0, tmp_str002A, 999, tmp_str0029);
   ObjectSetInteger(0, tmp_str002A, 102, Li_FFF8);
   ObjectSetInteger(0, tmp_str002A, 103, Li_FFF0);
   ObjectSetInteger(0, tmp_str002A, 100, 8);
   Gi_001B = HistoryTotal();
   Gd_001D = 0;
   Gl_001E = iTime(NULL, 1440, 5);
   Gi_001F = Gi_001B - 1;
   Gi_0020 = Gi_001F;
   
   if (Gi_001F >= 0) {
   do { 
   if (OrderSelect(Gi_0020, 0, 1)) {
   if (OrderOpenTime() >= Gl_001E && OrderSymbol() == _Symbol && OrderMagicNumber() == magic) {
   Gd_001D = (Gd_001D + OrderProfit());
   break;
   }
   Gd_001F = Gd_001D;
   break;
   }
   Gi_0020 = Gi_0020 - 1;
   } while (Gi_0020 >= 0); 
   }
   Gd_001F = Gd_001D;
   
   Ld_FFB0 = Gd_001F;
   if ((Gd_001F >= 0)) { 
   tmp_str002B = AccountCurrency();
   tmp_str002B = tmp_str002B + " ";
   tmp_str002B = tmp_str002B + DoubleToString(Gd_001F, 2);
   tmp_str002D = "OBJText" + IntegerToString(Li_FFF4, 0, 32);
   tmp_str002D = tmp_str002D + IntegerToString(Li_FFF0, 0, 32);
   tmp_str002C = tmp_str002D;
   ObjectCreate(0, tmp_str002C, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str002C, 6, 3329330);
   ObjectSetInteger(0, tmp_str002C, 9, 0);
   ObjectSetInteger(0, tmp_str002C, 1000, 0);
   ObjectSetInteger(0, tmp_str002C, 17, 0);
   ObjectSetString(0, tmp_str002C, 999, tmp_str002B);
   ObjectSetInteger(0, tmp_str002C, 102, Li_FFF4);
   ObjectSetInteger(0, tmp_str002C, 103, Li_FFF0);
   ObjectSetInteger(0, tmp_str002C, 100, 8);
   Li_FFF0 = Li_FFF0 + Li_FFEC;
   } 
   if ((Ld_FFB0 < 0)) { 
   tmp_str002D = AccountCurrency();
   tmp_str002D = tmp_str002D + " ";
   tmp_str002D = tmp_str002D + DoubleToString(Ld_FFB0, 2);
   tmp_str002F = "OBJText" + IntegerToString(Li_FFF4, 0, 32);
   tmp_str002F = tmp_str002F + IntegerToString(Li_FFF0, 0, 32);
   tmp_str002E = tmp_str002F;
   ObjectCreate(0, tmp_str002E, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str002E, 6, 4678655);
   ObjectSetInteger(0, tmp_str002E, 9, 0);
   ObjectSetInteger(0, tmp_str002E, 1000, 0);
   ObjectSetInteger(0, tmp_str002E, 17, 0);
   ObjectSetString(0, tmp_str002E, 999, tmp_str002D);
   ObjectSetInteger(0, tmp_str002E, 102, Li_FFF4);
   ObjectSetInteger(0, tmp_str002E, 103, Li_FFF0);
   ObjectSetInteger(0, tmp_str002E, 100, 8);
   Li_FFF0 = Li_FFF0 + Li_FFEC;
   } 
   Li_FFF0 = Li_FFF0 + 10;
   tmp_str002F = "Balance: ";
   tmp_str0031 = "OBJText" + IntegerToString(Li_FFF8, 0, 32);
   tmp_str0031 = tmp_str0031 + IntegerToString(Li_FFF0, 0, 32);
   tmp_str0030 = tmp_str0031;
   ObjectCreate(0, tmp_str0030, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str0030, 6, Li_FFE0);
   ObjectSetInteger(0, tmp_str0030, 9, 0);
   ObjectSetInteger(0, tmp_str0030, 1000, 0);
   ObjectSetInteger(0, tmp_str0030, 17, 0);
   ObjectSetString(0, tmp_str0030, 999, tmp_str002F);
   ObjectSetInteger(0, tmp_str0030, 102, Li_FFF8);
   ObjectSetInteger(0, tmp_str0030, 103, Li_FFF0);
   ObjectSetInteger(0, tmp_str0030, 100, 8);
   tmp_str0031 = AccountCurrency();
   tmp_str0031 = tmp_str0031 + " ";
   tmp_str0031 = tmp_str0031 + DoubleToString(AccountBalance(), 2);
   tmp_str0033 = "OBJText" + IntegerToString(Li_FFF4, 0, 32);
   tmp_str0033 = tmp_str0033 + IntegerToString(Li_FFF0, 0, 32);
   tmp_str0032 = tmp_str0033;
   ObjectCreate(0, tmp_str0032, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str0032, 6, 3329330);
   ObjectSetInteger(0, tmp_str0032, 9, 0);
   ObjectSetInteger(0, tmp_str0032, 1000, 0);
   ObjectSetInteger(0, tmp_str0032, 17, 0);
   ObjectSetString(0, tmp_str0032, 999, tmp_str0031);
   ObjectSetInteger(0, tmp_str0032, 102, Li_FFF4);
   ObjectSetInteger(0, tmp_str0032, 103, Li_FFF0);
   ObjectSetInteger(0, tmp_str0032, 100, 8);
   Li_FFF0 = Li_FFF0 + Li_FFEC;
   tmp_str0033 = "Equity: ";
   tmp_str0035 = "OBJText" + IntegerToString(Li_FFF8, 0, 32);
   tmp_str0035 = tmp_str0035 + IntegerToString(Li_FFF0, 0, 32);
   tmp_str0034 = tmp_str0035;
   ObjectCreate(0, tmp_str0034, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str0034, 6, Li_FFE0);
   ObjectSetInteger(0, tmp_str0034, 9, 0);
   ObjectSetInteger(0, tmp_str0034, 1000, 0);
   ObjectSetInteger(0, tmp_str0034, 17, 0);
   ObjectSetString(0, tmp_str0034, 999, tmp_str0033);
   ObjectSetInteger(0, tmp_str0034, 102, Li_FFF8);
   ObjectSetInteger(0, tmp_str0034, 103, Li_FFF0);
   ObjectSetInteger(0, tmp_str0034, 100, 8);
   tmp_str0035 = AccountCurrency();
   tmp_str0035 = tmp_str0035 + " ";
   tmp_str0035 = tmp_str0035 + DoubleToString(AccountEquity(), 2);
   tmp_str0037 = "OBJText" + IntegerToString(Li_FFF4, 0, 32);
   tmp_str0037 = tmp_str0037 + IntegerToString(Li_FFF0, 0, 32);
   tmp_str0036 = tmp_str0037;
   ObjectCreate(0, tmp_str0036, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str0036, 6, 3329330);
   ObjectSetInteger(0, tmp_str0036, 9, 0);
   ObjectSetInteger(0, tmp_str0036, 1000, 0);
   ObjectSetInteger(0, tmp_str0036, 17, 0);
   ObjectSetString(0, tmp_str0036, 999, tmp_str0035);
   ObjectSetInteger(0, tmp_str0036, 102, Li_FFF4);
   ObjectSetInteger(0, tmp_str0036, 103, Li_FFF0);
   ObjectSetInteger(0, tmp_str0036, 100, 8);
   Li_FFF0 = Li_FFF0 + Li_FFEC;
   Li_FFF0 = Li_FFF0 + 10;
   if (IsTesting() == false && Ii_0098 != 1) { 
   ObjectDelete("OBJHyperlink");
   ObjectDelete("OBJLicenseText");
   tmp_str0037 = "License: ";
   tmp_str0039 = "OBJText" + IntegerToString(Li_FFF8, 0, 32);
   tmp_str0039 = tmp_str0039 + IntegerToString(Li_FFF0, 0, 32);
   tmp_str0038 = tmp_str0039;
   ObjectCreate(0, tmp_str0038, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str0038, 6, Li_FFE0);
   ObjectSetInteger(0, tmp_str0038, 9, 0);
   ObjectSetInteger(0, tmp_str0038, 1000, 0);
   ObjectSetInteger(0, tmp_str0038, 17, 0);
   ObjectSetString(0, tmp_str0038, 999, tmp_str0037);
   ObjectSetInteger(0, tmp_str0038, 102, Li_FFF8);
   ObjectSetInteger(0, tmp_str0038, 103, Li_FFF0);
   ObjectSetInteger(0, tmp_str0038, 100, 8);
   if (Is_0178 == "Activated") { 
   tmp_str0039 = Is_0178;
   tmp_str003A = "OBJLicenseText";
   ObjectCreate(0, tmp_str003A, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str003A, 6, 3329330);
   ObjectSetInteger(0, tmp_str003A, 208, 0);
   ObjectSetInteger(0, tmp_str003A, 9, 0);
   ObjectSetInteger(0, tmp_str003A, 1000, 0);
   ObjectSetInteger(0, tmp_str003A, 17, 0);
   ObjectSetString(0, tmp_str003A, 999, tmp_str0039);
   ObjectSetInteger(0, tmp_str003A, 102, Li_FFF4);
   ObjectSetInteger(0, tmp_str003A, 103, Li_FFF0);
   ObjectSetInteger(0, tmp_str003A, 100, 8);
   } 
   else { 
   tmp_str003B = Is_0178;
   tmp_str003C = "OBJLicenseText";
   ObjectCreate(0, tmp_str003C, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str003C, 6, 255);
   ObjectSetInteger(0, tmp_str003C, 208, 0);
   ObjectSetInteger(0, tmp_str003C, 9, 0);
   ObjectSetInteger(0, tmp_str003C, 1000, 0);
   ObjectSetInteger(0, tmp_str003C, 17, 0);
   ObjectSetString(0, tmp_str003C, 999, tmp_str003B);
   ObjectSetInteger(0, tmp_str003C, 102, Li_FFF4);
   ObjectSetInteger(0, tmp_str003C, 103, Li_FFF0);
   ObjectSetInteger(0, tmp_str003C, 100, 8);
   } 
   Li_FFF0 = Li_FFF0 + Li_FFEC;

   tmp_str003F = "User Name: ";
   tmp_str0041 = "OBJText" + IntegerToString(Li_FFF8, 0, 32);
   tmp_str0041 = tmp_str0041 + IntegerToString(Li_FFF0, 0, 32);
   tmp_str0040 = tmp_str0041;
   ObjectCreate(0, tmp_str0040, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str0040, 6, Li_FFE0);
   ObjectSetInteger(0, tmp_str0040, 9, 0);
   ObjectSetInteger(0, tmp_str0040, 1000, 0);
   ObjectSetInteger(0, tmp_str0040, 17, 0);
   ObjectSetString(0, tmp_str0040, 999, tmp_str003F);
   ObjectSetInteger(0, tmp_str0040, 102, Li_FFF8);
   ObjectSetInteger(0, tmp_str0040, 103, Li_FFF0);
   ObjectSetInteger(0, tmp_str0040, 100, 8);
   tmp_str0041 = AccountName();
   tmp_str0043 = "OBJText" + IntegerToString(Li_FFF4, 0, 32);
   tmp_str0043 = tmp_str0043 + IntegerToString(Li_FFF0, 0, 32);
   tmp_str0042 = tmp_str0043;
   ObjectCreate(0, tmp_str0042, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str0042, 6, 3329330);
   ObjectSetInteger(0, tmp_str0042, 9, 0);
   ObjectSetInteger(0, tmp_str0042, 1000, 0);
   ObjectSetInteger(0, tmp_str0042, 17, 0);
   ObjectSetString(0, tmp_str0042, 999, tmp_str0041);
   ObjectSetInteger(0, tmp_str0042, 102, Li_FFF4);
   ObjectSetInteger(0, tmp_str0042, 103, Li_FFF0);
   ObjectSetInteger(0, tmp_str0042, 100, 8);
   Li_FFF0 = Li_FFF0 + Li_FFEC;
   tmp_str0043 = "Broker: ";
   tmp_str0045 = "OBJText" + IntegerToString(Li_FFF8, 0, 32);
   tmp_str0045 = tmp_str0045 + IntegerToString(Li_FFF0, 0, 32);
   tmp_str0044 = tmp_str0045;
   ObjectCreate(0, tmp_str0044, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str0044, 6, Li_FFE0);
   ObjectSetInteger(0, tmp_str0044, 9, 0);
   ObjectSetInteger(0, tmp_str0044, 1000, 0);
   ObjectSetInteger(0, tmp_str0044, 17, 0);
   ObjectSetString(0, tmp_str0044, 999, tmp_str0043);
   ObjectSetInteger(0, tmp_str0044, 102, Li_FFF8);
   ObjectSetInteger(0, tmp_str0044, 103, Li_FFF0);
   ObjectSetInteger(0, tmp_str0044, 100, 8);
   tmp_str0045 = AccountCompany();
   tmp_str0045 = tmp_str0045 + " ";
   tmp_str0045 = tmp_str0045 + "";
   tmp_str0047 = "OBJText" + IntegerToString(Li_FFF4, 0, 32);
   tmp_str0047 = tmp_str0047 + IntegerToString(Li_FFF0, 0, 32);
   tmp_str0046 = tmp_str0047;
   ObjectCreate(0, tmp_str0046, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str0046, 6, 3329330);
   ObjectSetInteger(0, tmp_str0046, 9, 0);
   ObjectSetInteger(0, tmp_str0046, 1000, 0);
   ObjectSetInteger(0, tmp_str0046, 17, 0);
   ObjectSetString(0, tmp_str0046, 999, tmp_str0045);
   ObjectSetInteger(0, tmp_str0046, 102, Li_FFF4);
   ObjectSetInteger(0, tmp_str0046, 103, Li_FFF0);
   ObjectSetInteger(0, tmp_str0046, 100, 8);
   Li_FFF0 = Li_FFF0 + Li_FFEC;
   tmp_str0047 = "Account ID: ";
   tmp_str0049 = "OBJText" + IntegerToString(Li_FFF8, 0, 32);
   tmp_str0049 = tmp_str0049 + IntegerToString(Li_FFF0, 0, 32);
   tmp_str0048 = tmp_str0049;
   ObjectCreate(0, tmp_str0048, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str0048, 6, Li_FFE0);
   ObjectSetInteger(0, tmp_str0048, 9, 0);
   ObjectSetInteger(0, tmp_str0048, 1000, 0);
   ObjectSetInteger(0, tmp_str0048, 17, 0);
   ObjectSetString(0, tmp_str0048, 999, tmp_str0047);
   ObjectSetInteger(0, tmp_str0048, 102, Li_FFF8);
   ObjectSetInteger(0, tmp_str0048, 103, Li_FFF0);
   ObjectSetInteger(0, tmp_str0048, 100, 8);
   tmp_str0049 = IntegerToString(AccountNumber(), 0, 32);
   tmp_str004B = "OBJText" + IntegerToString(Li_FFF4, 0, 32);
   tmp_str004B = tmp_str004B + IntegerToString(Li_FFF0, 0, 32);
   tmp_str004A = tmp_str004B;
   ObjectCreate(0, tmp_str004A, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str004A, 6, 3329330);
   ObjectSetInteger(0, tmp_str004A, 9, 0);
   ObjectSetInteger(0, tmp_str004A, 1000, 0);
   ObjectSetInteger(0, tmp_str004A, 17, 0);
   ObjectSetString(0, tmp_str004A, 999, tmp_str0049);
   ObjectSetInteger(0, tmp_str004A, 102, Li_FFF4);
   ObjectSetInteger(0, tmp_str004A, 103, Li_FFF0);
   ObjectSetInteger(0, tmp_str004A, 100, 8);
   Li_FFF0 = Li_FFF0 + Li_FFEC;
   tmp_str004B = "License Type: ";
   tmp_str004D = "OBJText" + IntegerToString(Li_FFF8, 0, 32);
   tmp_str004D = tmp_str004D + IntegerToString(Li_FFF0, 0, 32);
   tmp_str004C = tmp_str004D;
   ObjectCreate(0, tmp_str004C, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str004C, 6, Li_FFE0);
   ObjectSetInteger(0, tmp_str004C, 9, 0);
   ObjectSetInteger(0, tmp_str004C, 1000, 0);
   ObjectSetInteger(0, tmp_str004C, 17, 0);
   ObjectSetString(0, tmp_str004C, 999, tmp_str004B);
   ObjectSetInteger(0, tmp_str004C, 102, Li_FFF8);
   ObjectSetInteger(0, tmp_str004C, 103, Li_FFF0);
   ObjectSetInteger(0, tmp_str004C, 100, 8);
   tmp_str004D = "";
   tmp_str004F = "OBJText" + IntegerToString(Li_FFF4, 0, 32);
   tmp_str004F = tmp_str004F + IntegerToString(Li_FFF0, 0, 32);
   tmp_str004E = tmp_str004F;
   ObjectCreate(0, tmp_str004E, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str004E, 6, 3329330);
   ObjectSetInteger(0, tmp_str004E, 9, 0);
   ObjectSetInteger(0, tmp_str004E, 1000, 0);
   ObjectSetInteger(0, tmp_str004E, 17, 0);
   ObjectSetString(0, tmp_str004E, 999, tmp_str004D);
   ObjectSetInteger(0, tmp_str004E, 102, Li_FFF4);
   ObjectSetInteger(0, tmp_str004E, 103, Li_FFF0);
   ObjectSetInteger(0, tmp_str004E, 100, 8);
   Li_FFF0 = Li_FFF0 + Li_FFEC;
   tmp_str004F = "WWW";
   if (StringCompare(tmp_str004F, "demo", false) == 0) { 
   tmp_str0050 = "Expiry: ";
   tmp_str0052 = "OBJText" + IntegerToString(Li_FFF8, 0, 32);
   tmp_str0052 = tmp_str0052 + IntegerToString(Li_FFF0, 0, 32);
   tmp_str0051 = tmp_str0052;
   ObjectCreate(0, tmp_str0051, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str0051, 6, Li_FFE0);
   ObjectSetInteger(0, tmp_str0051, 9, 0);
   ObjectSetInteger(0, tmp_str0051, 1000, 0);
   ObjectSetInteger(0, tmp_str0051, 17, 0);
   ObjectSetString(0, tmp_str0051, 999, tmp_str0050);
   ObjectSetInteger(0, tmp_str0051, 102, Li_FFF8);
   ObjectSetInteger(0, tmp_str0051, 103, Li_FFF0);
   ObjectSetInteger(0, tmp_str0051, 100, 8);
   Gi_0021 = 8;
   Gi_0022 = 65535;
   Gi_0023 = Li_FFF0;
   Gi_0024 = Li_FFF4;
   Gl_0025 = TimeCurrent();
   Gl_0026 = 32477491142;
   Gl_0026 = Gl_0026 - Gl_0025;
   Gi_0026 = (int)Gl_0026;
   Gi_0027 = Gi_0026;
   tmp_str0052 = "";
   if (Gi_0026 > 86400) { 
   Gi_0026 = Gi_0026 / 86400;
   Gi_0028 = Gi_0026;
   Gi_0027 = Gi_0027 % 86400;
   if (Gi_0026 > 1) { 
   tmp_str0053 = (string)Gi_0026;
   tmp_str0053 = tmp_str0053 + " days ";
   tmp_str0052 = "" + tmp_str0053;
   } 
   else { 
   tmp_str0053 = (string)Gi_0028;
   tmp_str0053 = tmp_str0053 + " day ";
   tmp_str0052 = tmp_str0052 + tmp_str0053;
   }} 
   if (Gi_0027 > 3600) { 
   Gi_0026 = Gi_0027 / 3600;
   Gi_0029 = Gi_0026;
   Gi_0027 = Gi_0027 % 3600;
   if (Gi_0026 > 1) { 
   tmp_str0053 = (string)Gi_0026;
   tmp_str0053 = tmp_str0053 + " hrs ";
   tmp_str0052 = tmp_str0052 + tmp_str0053;
   } 
   else { 
   tmp_str0053 = (string)Gi_0029;
   tmp_str0053 = tmp_str0053 + " hr ";
   tmp_str0052 = tmp_str0052 + tmp_str0053;
   }} 
   if (Gi_0027 < 0) { 
   tmp_str0053 = "00:00";
   } 
   else { 
   tmp_str0053 = tmp_str0052;
   } 
   tmp_str0054 = tmp_str0053 + " (click)";
   tmp_str0055 = "OBJLicenseText2";
   ObjectCreate(0, tmp_str0055, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str0055, 6, Gi_0022);
   ObjectSetInteger(0, tmp_str0055, 208, 0);
   ObjectSetInteger(0, tmp_str0055, 9, 0);
   ObjectSetInteger(0, tmp_str0055, 1000, 0);
   ObjectSetInteger(0, tmp_str0055, 17, 0);
   ObjectSetString(0, tmp_str0055, 999, tmp_str0054);
   ObjectSetInteger(0, tmp_str0055, 102, Gi_0024);
   ObjectSetInteger(0, tmp_str0055, 103, Gi_0023);
   ObjectSetInteger(0, tmp_str0055, 100, Gi_0021);
   Li_FFF0 = Li_FFF0 + Li_FFEC;
   }} 

   Li_FFF0 = Li_FFE4;
   func_1277(Li_FFF8, Li_FFE4, Li_FFEC, Li_FFE0);
   Li_FFFC = Li_FFE4;
   
   return Li_FFFC;
}

void func_1277(int Fa_i_00, int Fa_i_01, int Fa_i_02, int Fa_i_03)
{
   string tmp_str0000;
   string tmp_str0001;
   string tmp_str0002;
   string tmp_str0003;
   string tmp_str0004;
   string tmp_str0005;
   string tmp_str0006;
   string tmp_str0007;
   string tmp_str0008;
   string tmp_str0009;
   string tmp_str000A;
   string tmp_str000B;
   string tmp_str000C;
   string tmp_str000D;
   string Ls_FFF0;

   Gi_0000 = Fa_i_02 * 2;
   Fa_i_01 = Fa_i_01 + Gi_0000;
   if (MarketInfo(_Symbol, MODE_TRADEALLOWED) == 0) { 
   tmp_str0000 = "(Market Closed)";
   tmp_str0002 = "OBJText" + IntegerToString(Fa_i_00, 0, 32);
   tmp_str0002 = tmp_str0002 + IntegerToString(Fa_i_01, 0, 32);
   tmp_str0001 = tmp_str0002;
   ObjectCreate(0, tmp_str0001, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str0001, 6, Fa_i_03);
   ObjectSetInteger(0, tmp_str0001, 9, 0);
   ObjectSetInteger(0, tmp_str0001, 1000, 0);
   ObjectSetInteger(0, tmp_str0001, 17, 0);
   ObjectSetString(0, tmp_str0001, 999, tmp_str0000);
   ObjectSetInteger(0, tmp_str0001, 102, Fa_i_00);
   ObjectSetInteger(0, tmp_str0001, 103, Fa_i_01);
   ObjectSetInteger(0, tmp_str0001, 100, 8);
   Gi_0000 = (int)(Fa_i_02 * 1.5);
   Fa_i_01 = Fa_i_01 + Gi_0000;
   } 
   else { 
   if (strattype == 3) { 
   tmp_str0002 = "Place Trade (Manually) ";
   tmp_str0004 = "OBJText" + IntegerToString(Fa_i_00, 0, 32);
   tmp_str0004 = tmp_str0004 + IntegerToString(Fa_i_01, 0, 32);
   tmp_str0003 = tmp_str0004;
   ObjectCreate(0, tmp_str0003, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str0003, 6, Fa_i_03);
   ObjectSetInteger(0, tmp_str0003, 9, 0);
   ObjectSetInteger(0, tmp_str0003, 1000, 0);
   ObjectSetInteger(0, tmp_str0003, 17, 0);
   ObjectSetString(0, tmp_str0003, 999, tmp_str0002);
   ObjectSetInteger(0, tmp_str0003, 102, Fa_i_00);
   ObjectSetInteger(0, tmp_str0003, 103, Fa_i_01);
   ObjectSetInteger(0, tmp_str0003, 100, 8);
   Gi_0000 = (int)(Fa_i_02 * 1.5);
   Fa_i_01 = Fa_i_01 + Gi_0000;
   } 
   else { 
   Ls_FFF0 = "";
   if (allowBuy && allowSell) { 
   Ls_FFF0 = "(Buy & Sell)";
   } 
   else { 
   if (allowBuy) { 
   Ls_FFF0 = "(Buy)";
   } 
   else { 
   if (allowSell) { 
   Ls_FFF0 = "(Sell)";
   } 
   else { 
   Ls_FFF0 = "(None)";
   }}} 
   tmp_str0004 = "Allow Trades " + Ls_FFF0;
   tmp_str0006 = "OBJText" + IntegerToString(Fa_i_00, 0, 32);
   tmp_str0006 = tmp_str0006 + IntegerToString(Fa_i_01, 0, 32);
   tmp_str0005 = tmp_str0006;
   ObjectCreate(0, tmp_str0005, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, tmp_str0005, 6, Fa_i_03);
   ObjectSetInteger(0, tmp_str0005, 9, 0);
   ObjectSetInteger(0, tmp_str0005, 1000, 0);
   ObjectSetInteger(0, tmp_str0005, 17, 0);
   ObjectSetString(0, tmp_str0005, 999, tmp_str0004);
   ObjectSetInteger(0, tmp_str0005, 102, Fa_i_00);
   ObjectSetInteger(0, tmp_str0005, 103, Fa_i_01);
   ObjectSetInteger(0, tmp_str0005, 100, 8);
   Gi_0000 = (int)(Fa_i_02 * 1.5);
   Fa_i_01 = Fa_i_01 + Gi_0000;
   }} 
   Fa_i_00 = Fa_i_00 - 10;
   if (allowBuy) { 
   tmp_str0006 = "Buy";
   tmp_str0007 = "OBJButton_Buy";
   ObjectCreate(0, tmp_str0007, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, tmp_str0007, 208, 0);
   ObjectSetInteger(0, tmp_str0007, 6, 16777215);
   ObjectSetInteger(0, tmp_str0007, 1025, 32768);
   ObjectSetInteger(0, tmp_str0007, 9, 0);
   ObjectSetInteger(0, tmp_str0007, 1000, 0);
   ObjectSetInteger(0, tmp_str0007, 17, 0);
   ObjectSetString(0, tmp_str0007, 999, tmp_str0006);
   ObjectSetInteger(0, tmp_str0007, 102, Fa_i_00);
   ObjectSetInteger(0, tmp_str0007, 103, Fa_i_01);
   ObjectSetInteger(0, tmp_str0007, 1019, 130);
   ObjectSetInteger(0, tmp_str0007, 1020, 50);
   ObjectSetInteger(0, tmp_str0007, 100, 8);
   } 
   else { 
   tmp_str0008 = "Buy";
   tmp_str0009 = "OBJButton_Buy";
   ObjectCreate(0, tmp_str0009, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, tmp_str0009, 208, 0);
   ObjectSetInteger(0, tmp_str0009, 6, 16777215);
   ObjectSetInteger(0, tmp_str0009, 1025, 4678655);
   ObjectSetInteger(0, tmp_str0009, 9, 0);
   ObjectSetInteger(0, tmp_str0009, 1000, 0);
   ObjectSetInteger(0, tmp_str0009, 17, 0);
   ObjectSetString(0, tmp_str0009, 999, tmp_str0008);
   ObjectSetInteger(0, tmp_str0009, 102, Fa_i_00);
   ObjectSetInteger(0, tmp_str0009, 103, Fa_i_01);
   ObjectSetInteger(0, tmp_str0009, 1019, 130);
   ObjectSetInteger(0, tmp_str0009, 1020, 50);
   ObjectSetInteger(0, tmp_str0009, 100, 8);
   } 
   Fa_i_00 = Fa_i_00 + 140;
   if (allowSell) { 
   tmp_str000A = "Sell";
   tmp_str000B = "OBJButton_Sell";
   ObjectCreate(0, tmp_str000B, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, tmp_str000B, 208, 0);
   ObjectSetInteger(0, tmp_str000B, 6, 16777215);
   ObjectSetInteger(0, tmp_str000B, 1025, 32768);
   ObjectSetInteger(0, tmp_str000B, 9, 0);
   ObjectSetInteger(0, tmp_str000B, 1000, 0);
   ObjectSetInteger(0, tmp_str000B, 17, 0);
   ObjectSetString(0, tmp_str000B, 999, tmp_str000A);
   ObjectSetInteger(0, tmp_str000B, 102, Fa_i_00);
   ObjectSetInteger(0, tmp_str000B, 103, Fa_i_01);
   ObjectSetInteger(0, tmp_str000B, 1019, 130);
   ObjectSetInteger(0, tmp_str000B, 1020, 50);
   ObjectSetInteger(0, tmp_str000B, 100, 8);
   return ;
   } 
   tmp_str000C = "Sell";
   tmp_str000D = "OBJButton_Sell";
   ObjectCreate(0, tmp_str000D, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, tmp_str000D, 208, 0);
   ObjectSetInteger(0, tmp_str000D, 6, 16777215);
   ObjectSetInteger(0, tmp_str000D, 1025, 4678655);
   ObjectSetInteger(0, tmp_str000D, 9, 0);
   ObjectSetInteger(0, tmp_str000D, 1000, 0);
   ObjectSetInteger(0, tmp_str000D, 17, 0);
   ObjectSetString(0, tmp_str000D, 999, tmp_str000C);
   ObjectSetInteger(0, tmp_str000D, 102, Fa_i_00);
   ObjectSetInteger(0, tmp_str000D, 103, Fa_i_01);
   ObjectSetInteger(0, tmp_str000D, 1019, 130);
   ObjectSetInteger(0, tmp_str000D, 1020, 50);
   ObjectSetInteger(0, tmp_str000D, 100, 8);
   
}

void func_1289(string Fa_s_00)
{
   int Li_FFF8;
   int Li_FFFC;

   if (MarketInfo(_Symbol, MODE_TRADEALLOWED) == 0) return; 
   if (Fa_s_00 == "OBJButton_Buy" || Fa_s_00 == "Tester") {
   
   if (strattype == 3) {
   if (ObjectGetInteger(0, "OBJButton_Buy", 1018, 0)) {
   Ib_01E0 = true;
   ObjectSetInteger(0, "OBJButton_Buy", 1018, 0);
   }}
   else{
   Li_FFFC = (int)ObjectGet(Fa_s_00, OBJPROP_BGCOLOR);
   if (Li_FFFC == 32768
   || (ObjectGetInteger(0, "OBJButton_Buy", 1018, 0) != 0 && Fa_s_00 == "Tester")) {
   
   ObjectSet(Fa_s_00, OBJPROP_BGCOLOR, 4678655);
   allowBuy = false;
   }
   else{
   ObjectSet(Fa_s_00, OBJPROP_BGCOLOR, 32768);
   allowBuy = true;
   }}
   ObjectSetInteger(0, Fa_s_00, 1018, 0);
   }
   if (Fa_s_00 != "OBJButton_Sell") { 
   if (Fa_s_00 != "Tester") return; 
   } 
   if (strattype == 3) {
   if (ObjectGetInteger(0, "OBJButton_Sell", 1018, 0)) {
   Ib_01E1 = true;
   ObjectSetInteger(0, "OBJButton_Sell", 1018, 0);
   }}
   else{
   Li_FFF8 = (int)ObjectGet(Fa_s_00, OBJPROP_BGCOLOR);
   if (Li_FFF8 == 32768
   || (ObjectGetInteger(0, "OBJButton_Sell", 1018, 0) != 0 && Fa_s_00 == "Tester")) {
   
   ObjectSet(Fa_s_00, OBJPROP_BGCOLOR, 4678655);
   allowSell = false;
   }
   else{
   ObjectSet(Fa_s_00, OBJPROP_BGCOLOR, 32768);
   allowSell = true;
   }}
   ObjectSetInteger(0, Fa_s_00, 1018, 0);
   
}

void func_1290()
{
   int Li_FFFC;

   RefreshRates();
   Li_FFFC = func_1300();
   
   Gi_0000 = 0;
   Gi_0001 = 0;
   Gi_0002 = 0;
   if (OrdersTotal() > 0) { 
   do { 
   if (OrderSelect(Gi_0002, 0, 0) && OrderMagicNumber() == magic && OrderSymbol() == _Symbol) { 
   if (OrderType() == Gi_0000 || Gi_0000 == -1) { 
   
   Gi_0001 = Gi_0001 + 1;
   }} 
   Gi_0002 = Gi_0002 + 1;
   } while (Gi_0002 < OrdersTotal()); 
   } 
   if ((Li_FFFC == 0 && allowBuy) || Gi_0001 != 0) {
   
   
   func_1295(0);
   if (allowHedge) { 
   func_1291(0);
   } 
   if (allowHedge != true) { 
   Gi_0003 = 1;
   Gi_0004 = 0;
   Gi_0005 = 0;
   if (OrdersTotal() > 0) { 
   do { 
   if (OrderSelect(Gi_0005, 0, 0) && OrderMagicNumber() == magic && OrderSymbol() == _Symbol) { 
   if (OrderType() == Gi_0003 || Gi_0003 == -1) { 
   
   Gi_0004 = Gi_0004 + 1;
   }} 
   Gi_0005 = Gi_0005 + 1;
   } while (Gi_0005 < OrdersTotal()); 
   } 
   if (Gi_0004 == 0) { 
   func_1291(0);
   }}} 
   
   Gi_0006 = 1;
   Gi_0007 = 0;
   Gi_0008 = 0;
   if (OrdersTotal() > 0) { 
   do { 
   if (OrderSelect(Gi_0008, 0, 0) && OrderMagicNumber() == magic && OrderSymbol() == _Symbol) { 
   if (OrderType() == Gi_0006 || Gi_0006 == -1) { 
   
   Gi_0007 = Gi_0007 + 1;
   }} 
   Gi_0008 = Gi_0008 + 1;
   } while (Gi_0008 < OrdersTotal()); 
   } 
   if ((Li_FFFC == 1 && allowSell) || Gi_0007 != 0) {
   
   func_1295(1);
   if (allowHedge) { 
   func_1291(1);
   } 
   if (allowHedge != true) { 
   Gi_0009 = 0;
   Gi_000A = 0;
   Gi_000B = 0;
   if (OrdersTotal() > 0) { 
   do { 
   if (OrderSelect(Gi_000B, 0, 0) && OrderMagicNumber() == magic && OrderSymbol() == _Symbol) { 
   if (OrderType() == Gi_0009 || Gi_0009 == -1) { 
   
   Gi_000A = Gi_000A + 1;
   }} 
   Gi_000B = Gi_000B + 1;
   } while (Gi_000B < OrdersTotal()); 
   } 
   if (Gi_000A == 0) { 
   func_1291(1);
   }}} 
   func_1295(-1);
}

void func_1291(int Fa_i_00)
{
   string tmp_str0000;
   string tmp_str0001;
   string tmp_str0002;
   string tmp_str0003;
   string tmp_str0004;
   string tmp_str0005;
   string tmp_str0006;
   string tmp_str0007;
   int Li_FFFC;
   int Li_FFF8;
   double Ld_FFF0;
   int Li_FFEC;
   double Ld_FFE0;
   int Li_FFDC;
   double Ld_FFD0;

   Gi_0000 = Fa_i_00;
   Gi_0001 = 0;
   Gi_0002 = 0;
   if (OrdersTotal() > 0) { 
   do { 
   if (OrderSelect(Gi_0002, 0, 0) && OrderMagicNumber() == magic && OrderSymbol() == _Symbol) { 
   if (OrderType() == Gi_0000 || Gi_0000 == -1) { 
   
   Gi_0001 = Gi_0001 + 1;
   }} 
   Gi_0002 = Gi_0002 + 1;
   } while (Gi_0002 < OrdersTotal()); 
   } 
   Li_FFFC = Gi_0001;
   if (Gi_0001 == 0) { 
   Li_FFF8 = Fa_i_00;
   if (Fa_i_00 == 1) { 
   tmp_str0000 = "";
   tmp_str0001 = "";
   func_1309(Fa_i_00, func_1299(Fa_i_00), 0, 0, tmp_str0001, tmp_str0000);
   return ;
   } 
   tmp_str0002 = "";
   tmp_str0003 = "";
   func_1309(Li_FFF8, func_1299(Fa_i_00), 0, 0, tmp_str0003, tmp_str0002);
   return ;
   } 
   if (Li_FFFC > 1) { 
   Gi_0003 = Fa_i_00;
   Gi_0004 = 0;
   if (OrdersTotal() > 0) { 
   do { 
   if (OrderSelect(Gi_0004, 0, 0) && OrderMagicNumber() == magic && OrderSymbol() == _Symbol && OrderType() == Gi_0003 && (OrderTakeProfit() != 0)) { 
   int m = OrderModify(OrderTicket(), NormalizeDouble(OrderOpenPrice(), _Digits), NormalizeDouble(OrderStopLoss(), _Digits), 0, OrderExpiration(), 4294967295);
   } 
   Gi_0004 = Gi_0004 + 1;
   } while (Gi_0004 < OrdersTotal()); 
   }} 
   Ld_FFF0 = func_1305((Li_FFFC + 1));
   Gi_0008 = Fa_i_00;
   Gi_0009 = 0;
   Gi_000A = 0;
   if (OrdersTotal() > 0) { 
   do { 
   if (OrderSelect(Gi_000A, 0, 0) && OrderMagicNumber() == magic && OrderSymbol() == _Symbol) { 
   if (OrderType() == Gi_0008 || Gi_0008 == -1) { 
   
   Gi_0009 = Gi_0009 + 1;
   }} 
   Gi_000A = Gi_000A + 1;
   } while (Gi_000A < OrdersTotal()); 
   } 
   if (Gi_0009 > Ii_01B4) return; 
   if (Fa_i_00 == 0) { 
   Gi_000B = 0;
   Gi_000C = 0;
   Gi_000D = 0;
   if (OrdersTotal() > 0) { 
   do { 
   if (OrderSelect(Gi_000D, 0, 0) && OrderMagicNumber() == magic && OrderSymbol() == _Symbol) { 
   if (OrderType() == Gi_000B || Gi_000B == -1) { 
   
   Gi_000C = Gi_000C + 1;
   }} 
   Gi_000D = Gi_000D + 1;
   } while (Gi_000D < OrdersTotal()); 
   } 
   if (tradeLimit == 0 || Gi_000C < tradeLimit) {
   
   Gd_000E = 2147483647;
   Gi_000F = 0;
   Gi_0010 = OrdersTotal() - 1;
   Gi_0011 = Gi_0010;
   if (Gi_0010 >= 0) { 
   do { 
   if (OrderSelect(Gi_0011, 0, 0) && OrderSymbol() == _Symbol && OrderMagicNumber() == magic && OrderType() == OP_BUY && (OrderOpenPrice() < Gd_000E)) { 
   Gd_000E = OrderOpenPrice();
   Gi_000F = OrderTicket();
   } 
   Gi_0011 = Gi_0011 - 1;
   } while (Gi_0011 >= 0); 
   } 
   Li_FFEC = Gi_000F;
   if (OrderSelect(Gi_000F, 1, 0)) { 
   Gd_0010 = OrderOpenPrice();
   } 
   else { 
   Gd_0010 = 0;
   } 
   Gd_0012 = (Gd_0010 - Bid);
   Gd_0013 = 0;
   if (_Digits == 5 || _Digits == 3) { 
   
   Gd_0013 = (_Point * 10);
   } 
   else { 
   Gd_0013 = _Point;
   } 
   if (_Symbol == "GOLD" || _Symbol == "SILVER" || _Digits == 2) { 
   
   Gd_0014 = (Gd_0012 * 10);
   } 
   else { 
   if (_Symbol == "GOLDEURO" || _Symbol == "SILVEREURO") { 
   
   Gd_0013 = _Point;
   } 
   Gd_0014 = (Gd_0012 / Gd_0013);
   } 
   if ((Gd_0014 < Ld_FFF0)) return; 
   if (!OrderSelect(Li_FFEC, 1, 0)) return; 
   Ld_FFE0 = func_1306((Li_FFFC + 1), Fa_i_00);
   tmp_str0004 = "";
   tmp_str0005 = "";
   func_1309(0, Ld_FFE0, 0, 0, tmp_str0005, tmp_str0004);
   return ;
   }} 
   if (Fa_i_00 != 1) return; 
   if (tradeLimit != 0) { 
   Gi_0015 = 1;
   Gi_0016 = 0;
   Gi_0017 = 0;
   if (OrdersTotal() > 0) { 
   do { 
   if (OrderSelect(Gi_0017, 0, 0) && OrderMagicNumber() == magic && OrderSymbol() == _Symbol) { 
   if (OrderType() == Gi_0015 || Gi_0015 == -1) { 
   
   Gi_0016 = Gi_0016 + 1;
   }} 
   Gi_0017 = Gi_0017 + 1;
   } while (Gi_0017 < OrdersTotal()); 
   } 
   if (Gi_0016 >= tradeLimit) return; 
   } 
   Gd_0018 = -2147483648;
   Gi_0019 = 0;
   Gi_001A = OrdersTotal() - 1;
   Gi_001B = Gi_001A;
   if (Gi_001A >= 0) { 
   do { 
   if (OrderSelect(Gi_001B, 0, 0) && OrderSymbol() == _Symbol && OrderMagicNumber() == magic && OrderType() == OP_SELL && (OrderOpenPrice() > Gd_0018)) { 
   Gd_0018 = OrderOpenPrice();
   Gi_0019 = OrderTicket();
   } 
   Gi_001B = Gi_001B - 1;
   } while (Gi_001B >= 0); 
   } 
   Li_FFDC = Gi_0019;
   if (OrderSelect(Gi_0019, 1, 0)) { 
   Gd_001A = OrderOpenPrice();
   } 
   else { 
   Gd_001A = 0;
   } 
   Gd_001C = (Bid - Gd_001A);
   Gd_001D = 0;
   if (_Digits == 5 || _Digits == 3) { 
   
   Gd_001D = (_Point * 10);
   } 
   else { 
   Gd_001D = _Point;
   } 
   if (_Symbol == "GOLD" || _Symbol == "SILVER" || _Digits == 2) { 
   
   Gd_001E = (Gd_001C * 10);
   } 
   else { 
   if (_Symbol == "GOLDEURO" || _Symbol == "SILVEREURO") { 
   
   Gd_001D = _Point;
   } 
   Gd_001E = (Gd_001C / Gd_001D);
   } 
   if ((Gd_001E < Ld_FFF0)) return; 
   if (!OrderSelect(Li_FFDC, 1, 0)) return; 
   Ld_FFD0 = func_1306((Li_FFFC + 1), Fa_i_00);
   tmp_str0006 = "";
   tmp_str0007 = "";
   func_1309(1, Ld_FFD0, 0, 0, tmp_str0007, tmp_str0006);
   
}

void func_1295(int Fa_i_00)
{
   string tmp_str0000;
   string tmp_str0001;
   string tmp_str0002;
   string tmp_str0003;
   string tmp_str0004;
   double Ld_FFF8;
   double Ld_FFF0;

   Gb_0000 = false;
   Gi_0001 = Fa_i_00;
   tmp_str0000 = "";
   tmp_str0000 = _Symbol;
   Gd_0002 = 0;
   Gi_0003 = OrdersTotal() - 1;
   Gi_0004 = Gi_0003;
   if (Gi_0003 >= 0) { 
   do { 
   if (OrderSelect(Gi_0004, 0, 0)) { 
   if (Gb_0000 || OrderSymbol() == tmp_str0000) {
   
   if (OrderMagicNumber() == magic && OrderType() == Gi_0001) { 
   Gd_0003 = OrderProfit();
   Gd_0003 = (Gd_0003 + OrderSwap());
   Gd_0002 = ((Gd_0003 + OrderCommission()) + Gd_0002);
   }}} 
   Gi_0004 = Gi_0004 - 1;
   } while (Gi_0004 >= 0); 
   } 
   Ld_FFF8 = Gd_0002;
   if (Fa_i_00 == 0) { 
   Gd_0003 = Id_01E8;
   } 
   else { 
   Gd_0003 = Id_01F0;
   } 
   Ld_FFF0 = Gd_0003;
   if (Gd_0003 <= 0) return; 
   Gb_0005 = (Bid > Gd_0003);
   if (Gb_0005 && Fa_i_00 == 0) { 
   Gb_0005 = true;
   Gi_0006 = Fa_i_00;
   Gi_0007 = Fa_i_00;
   Gi_0008 = 0;
   Gi_0009 = 0;
   if (OrdersTotal() > 0) { 
   do { 
   if (OrderSelect(Gi_0009, 0, 0) && OrderMagicNumber() == magic && OrderSymbol() == _Symbol) { 
   if (OrderType() == Gi_0007 || Gi_0007 == -1) { 
   
   Gi_0008 = Gi_0008 + 1;
   }} 
   Gi_0009 = Gi_0009 + 1;
   } while (Gi_0009 < OrdersTotal()); 
   } 
   if (Gi_0008 != 0) { 
   do { 
   Gi_000A = OrdersTotal() - 1;
   Gi_000B = Gi_000A;
   if (Gi_000A >= 0) { 
   do { 
   if (OrderSelect(Gi_000B, 0, 0)) { 
   if (OrderMagicNumber() == magic || !Gb_0005) {
   
   if (OrderSymbol() == _Symbol) { 
   if (OrderType() == Gi_0006 || Gi_0006 == -1) { 
   
   tmp_str0001 = "";
   func_1310(OrderTicket(), tmp_str0001);
   }}}} 
   Gi_000B = Gi_000B - 1;
   } while (Gi_000B >= 0); 
   } 
   Gi_000A = Gi_0006;
   Gi_000C = 0;
   Gi_000D = 0;
   if (OrdersTotal() > 0) { 
   do { 
   if (OrderSelect(Gi_000D, 0, 0) && OrderMagicNumber() == magic && OrderSymbol() == _Symbol) { 
   if (OrderType() == Gi_000A || Gi_000A == -1) { 
   
   Gi_000C = Gi_000C + 1;
   }} 
   Gi_000D = Gi_000D + 1;
   } while (Gi_000D < OrdersTotal()); 
   } 
   } while (Gi_000C != 0); 
   } 
   if (showCandleProf) { 
   Gi_000E = (int)ChartGetInteger(0, 22, 0);
   Gi_000E = Gi_000E;
   Gi_000F = 0;
   tmp_str0002 = DoubleToString(Ld_FFF8, 2);
   func_1340(Time[0], tmp_str0002, Gi_000E, false, 1);
   }} 
   Gb_0011 = (Ask < Ld_FFF0);
   if (Gb_0011 == false) return; 
   if (Fa_i_00 != 1) return; 
   Gb_0011 = true;
   Gi_0012 = Fa_i_00;
   Gi_0013 = Fa_i_00;
   Gi_0014 = 0;
   Gi_0015 = 0;
   if (OrdersTotal() > 0) { 
   do { 
   if (OrderSelect(Gi_0015, 0, 0) && OrderMagicNumber() == magic && OrderSymbol() == _Symbol) { 
   if (OrderType() == Gi_0013 || Gi_0013 == -1) { 
   
   Gi_0014 = Gi_0014 + 1;
   }} 
   Gi_0015 = Gi_0015 + 1;
   } while (Gi_0015 < OrdersTotal()); 
   } 
   if (Gi_0014 != 0) { 
   do { 
   Gi_0016 = OrdersTotal() - 1;
   Gi_0017 = Gi_0016;
   if (Gi_0016 >= 0) { 
   do { 
   if (OrderSelect(Gi_0017, 0, 0)) { 
   if (OrderMagicNumber() == magic || !Gb_0011) {
   
   if (OrderSymbol() == _Symbol) { 
   if (OrderType() == Gi_0012 || Gi_0012 == -1) { 
   
   tmp_str0003 = "";
   func_1310(OrderTicket(), tmp_str0003);
   }}}} 
   Gi_0017 = Gi_0017 - 1;
   } while (Gi_0017 >= 0); 
   } 
   Gi_0016 = Gi_0012;
   Gi_0018 = 0;
   Gi_0019 = 0;
   if (OrdersTotal() > 0) { 
   do { 
   if (OrderSelect(Gi_0019, 0, 0) && OrderMagicNumber() == magic && OrderSymbol() == _Symbol) { 
   if (OrderType() == Gi_0016 || Gi_0016 == -1) { 
   
   Gi_0018 = Gi_0018 + 1;
   }} 
   Gi_0019 = Gi_0019 + 1;
   } while (Gi_0019 < OrdersTotal()); 
   } 
   } while (Gi_0018 != 0); 
   } 
   if (showCandleProf == false) return; 
   Gi_001A = (int)ChartGetInteger(0, 22, 0);
   Gi_001A = Gi_001A;
   Gi_001B = 0;
   tmp_str0004 = DoubleToString(Ld_FFF8, 2);
   func_1340(Time[0], tmp_str0004, Gi_001A, false, 1);
   
}

void func_1296(int Fa_i_00)
{
   string tmp_str0000;
   string tmp_str0001;
   string tmp_str0002;
   string tmp_str0003;
   string tmp_str0004;
   double Ld_FFF8;
   bool Lb_FFF7;
   double Ld_FFE8;

   Gb_0000 = false;
   Gi_0001 = Fa_i_00;
   tmp_str0000 = "";
   tmp_str0000 = _Symbol;
   Gd_0002 = 0;
   Gi_0003 = OrdersTotal() - 1;
   Gi_0004 = Gi_0003;
   if (Gi_0003 >= 0) { 
   do { 
   if (OrderSelect(Gi_0004, 0, 0)) { 
   if (Gb_0000 || OrderSymbol() == tmp_str0000) {
   
   if (OrderMagicNumber() == magic && OrderType() == Gi_0001) { 
   Gd_0003 = OrderProfit();
   Gd_0003 = (Gd_0003 + OrderSwap());
   Gd_0002 = ((Gd_0003 + OrderCommission()) + Gd_0002);
   }}} 
   Gi_0004 = Gi_0004 - 1;
   } while (Gi_0004 >= 0); 
   } 
   Ld_FFF8 = Gd_0002;
   Lb_FFF7 = false;
   if (lossCutType == 0) return; 
   if (lossCutType == 1) {
   Gd_0003 = -Gd_0002;
   Gb_0003 = (Gd_0003 > lcvalue);
   if (Gb_0003 != false) {
   Lb_FFF7 = true;
   }}
   else{
   if (lossCutType == 2) { 
   Ld_FFE8 = ((lcvalue / 100) * AccountBalance());
   Gd_0003 = -Ld_FFF8;
   if ((Gd_0003 > Ld_FFE8)) { 
   Lb_FFF7 = true;
   }}} 
   if (Lb_FFF7 && Fa_i_00 == 0) { 
   Gb_0003 = true;
   Gi_0005 = Fa_i_00;
   Gi_0006 = Fa_i_00;
   Gi_0007 = 0;
   Gi_0008 = 0;
   if (OrdersTotal() > 0) { 
   do { 
   if (OrderSelect(Gi_0008, 0, 0) && OrderMagicNumber() == magic && OrderSymbol() == _Symbol) { 
   if (OrderType() == Gi_0006 || Gi_0006 == -1) { 
   
   Gi_0007 = Gi_0007 + 1;
   }} 
   Gi_0008 = Gi_0008 + 1;
   } while (Gi_0008 < OrdersTotal()); 
   } 
   if (Gi_0007 != 0) { 
   do { 
   Gi_0009 = OrdersTotal() - 1;
   Gi_000A = Gi_0009;
   if (Gi_0009 >= 0) { 
   do { 
   if (OrderSelect(Gi_000A, 0, 0)) { 
   if (OrderMagicNumber() == magic || !Gb_0003) {
   
   if (OrderSymbol() == _Symbol) { 
   if (OrderType() == Gi_0005 || Gi_0005 == -1) { 
   
   tmp_str0001 = "";
   func_1310(OrderTicket(), tmp_str0001);
   }}}} 
   Gi_000A = Gi_000A - 1;
   } while (Gi_000A >= 0); 
   } 
   Gi_0009 = Gi_0005;
   Gi_000B = 0;
   Gi_000C = 0;
   if (OrdersTotal() > 0) { 
   do { 
   if (OrderSelect(Gi_000C, 0, 0) && OrderMagicNumber() == magic && OrderSymbol() == _Symbol) { 
   if (OrderType() == Gi_0009 || Gi_0009 == -1) { 
   
   Gi_000B = Gi_000B + 1;
   }} 
   Gi_000C = Gi_000C + 1;
   } while (Gi_000C < OrdersTotal()); 
   } 
   } while (Gi_000B != 0); 
   } 
   if (showCandleProf) { 
   Gi_000D = (int)ChartGetInteger(0, 22, 0);
   Gi_000D = Gi_000D;
   Gi_000E = 0;
   tmp_str0002 = DoubleToString(Ld_FFF8, 2);
   func_1340(Time[0], tmp_str0002, Gi_000D, false, 1);
   }} 
   if (Lb_FFF7 == false) return; 
   if (Fa_i_00 != 1) return; 
   Gb_0010 = true;
   Gi_0011 = Fa_i_00;
   Gi_0012 = Fa_i_00;
   Gi_0013 = 0;
   Gi_0014 = 0;
   if (OrdersTotal() > 0) { 
   do { 
   if (OrderSelect(Gi_0014, 0, 0) && OrderMagicNumber() == magic && OrderSymbol() == _Symbol) { 
   if (OrderType() == Gi_0012 || Gi_0012 == -1) { 
   
   Gi_0013 = Gi_0013 + 1;
   }} 
   Gi_0014 = Gi_0014 + 1;
   } while (Gi_0014 < OrdersTotal()); 
   } 
   if (Gi_0013 != 0) { 
   do { 
   Gi_0015 = OrdersTotal() - 1;
   Gi_0016 = Gi_0015;
   if (Gi_0015 >= 0) { 
   do { 
   if (OrderSelect(Gi_0016, 0, 0)) { 
   if (OrderMagicNumber() == magic || !Gb_0010) {
   
   if (OrderSymbol() == _Symbol) { 
   if (OrderType() == Gi_0011 || Gi_0011 == -1) { 
   
   tmp_str0003 = "";
   func_1310(OrderTicket(), tmp_str0003);
   }}}} 
   Gi_0016 = Gi_0016 - 1;
   } while (Gi_0016 >= 0); 
   } 
   Gi_0015 = Gi_0011;
   Gi_0017 = 0;
   Gi_0018 = 0;
   if (OrdersTotal() > 0) { 
   do { 
   if (OrderSelect(Gi_0018, 0, 0) && OrderMagicNumber() == magic && OrderSymbol() == _Symbol) { 
   if (OrderType() == Gi_0015 || Gi_0015 == -1) { 
   
   Gi_0017 = Gi_0017 + 1;
   }} 
   Gi_0018 = Gi_0018 + 1;
   } while (Gi_0018 < OrdersTotal()); 
   } 
   } while (Gi_0017 != 0); 
   } 
   if (showCandleProf == false) return; 
   Gi_0019 = (int)ChartGetInteger(0, 22, 0);
   Gi_0019 = Gi_0019;
   Gi_001A = 0;
   tmp_str0004 = DoubleToString(Ld_FFF8, 2);
   func_1340(Time[0], tmp_str0004, Gi_0019, false, 1);
   
}

double func_1299(int Fa_i_00)
{
   string tmp_str0000;
   string tmp_str0001;
   string tmp_str0002;
   string tmp_str0003;
   double Ld_FFF0;
   double Ld_FFF8;
   double Ld_FFE8;
   double Ld_FFE0;

   tmp_str0000 = "";
   Gb_0000 = false;
   if (Fa_i_00 == 0) { 
   Gi_0001 = 1;
   } 
   else { 
   Gi_0001 = 0;
   } 
   Gi_0002 = Gi_0001;
   tmp_str0001 = tmp_str0000;
   if (tmp_str0000 == "") { 
   tmp_str0001 = _Symbol;
   } 
   Gd_0003 = 0;
   Gi_0004 = OrdersTotal() - 1;
   Gi_0005 = Gi_0004;
   if (Gi_0004 >= 0) { 
   do { 
   if (OrderSelect(Gi_0005, 0, 0)) { 
   if (Gb_0000 || OrderSymbol() == tmp_str0001) {
   
   if (OrderMagicNumber() == magic && OrderType() == Gi_0002) { 
   Gd_0004 = OrderProfit();
   Gd_0004 = (Gd_0004 + OrderSwap());
   Gd_0003 = ((Gd_0004 + OrderCommission()) + Gd_0003);
   }}} 
   Gi_0005 = Gi_0005 - 1;
   } while (Gi_0005 >= 0); 
   } 
   if (Gd_0003 >= 0) { 
   Gd_0004 = Gd_0003;
   } 
   else { 
   Gd_0004 = 0;
   } 
   Ld_FFF0 = Gd_0004;
   if (lottype == 1) { 
   Gd_0004 = lotSize;
   returned_double = SymbolInfoDouble(NULL, 34);
   Gd_0006 = returned_double;
   if ((lotSize < Gd_0006)) { 
   StringFormat("Volume is less than the minimal allowed SYMBOL_VOLUME_MIN=%.2f", returned_double);
   Gd_0007 = Gd_0006;
   } 
   else { 
   returned_double = SymbolInfoDouble(NULL, 35);
   Gd_0008 = returned_double;
   if ((Gd_0004 > Gd_0008)) { 
   StringFormat("Volume is greater than the maximal allowed SYMBOL_VOLUME_MAX=%.2f", returned_double);
   Gd_0007 = Gd_0008;
   } 
   else { 
   returned_double = SymbolInfoDouble(NULL, 36);
   Gd_0009 = returned_double;
   Gd_000A = round((Gd_0004 / Gd_0009));
   Gi_000A = (int)Gd_000A;
   Gd_000B = fabs(((Gi_000A * returned_double) - Gd_0004));
   if ((Gd_000B > 1E-07)) { 
   StringFormat("Volume is not a multiple of the minimal step SYMBOL_VOLUME_STEP=%.2f, the closest correct volume is %.2f", returned_double, (Gi_000A * returned_double));
   Gd_0007 = (Gi_000A * Gd_0009);
   } 
   else { 
   Gd_0007 = NormalizeDouble(Gd_0004, 2);
   }}} 
   Ld_FFF8 = Gd_0007;
   return Ld_FFF8;
   } 
   Gd_000B = (Ld_FFF0 * 10);
   Ld_FFE8 = (AccountBalance() - Gd_000B);
   Ld_FFE0 = (Ld_FFE8 / 500000);
   if (Ld_FFE0 >= 0.01) { 
   Gd_000B = Ld_FFE0;
   } 
   else { 
   Gd_000B = 0.01;
   } 
   Ld_FFE0 = Gd_000B;
   Gd_000B = NormalizeDouble(Gd_000B, 2);
   returned_double = SymbolInfoDouble(NULL, 34);
   Gd_000C = returned_double;
   if ((Gd_000B < Gd_000C)) { 
   StringFormat("Volume is less than the minimal allowed SYMBOL_VOLUME_MIN=%.2f", returned_double);
   Gd_000D = Gd_000C;
   return Gd_000D;
   } 
   returned_double = SymbolInfoDouble(NULL, 35);
   Gd_000E = returned_double;
   if ((Gd_000B > Gd_000E)) { 
   StringFormat("Volume is greater than the maximal allowed SYMBOL_VOLUME_MAX=%.2f", returned_double);
   Gd_000D = Gd_000E;
   return Gd_000D;
   } 
   returned_double = SymbolInfoDouble(NULL, 36);
   Gd_000F = returned_double;
   Gd_0010 = round((Gd_000B / Gd_000F));
   Gi_0010 = (int)Gd_0010;
   Gd_0011 = fabs(((Gi_0010 * returned_double) - Gd_000B));
   if ((Gd_0011 > 1E-07)) { 
   StringFormat("Volume is not a multiple of the minimal step SYMBOL_VOLUME_STEP=%.2f, the closest correct volume is %.2f", returned_double, (Gi_0010 * returned_double));
   Gd_000D = (Gi_0010 * Gd_000F);
   return Gd_000D;
   } 
   Gd_000D = NormalizeDouble(Gd_000B, 2);
   
   Ld_FFF8 = Gd_000D;
   
   return  Ld_FFF8;
}

int func_1300()
{
   int Li_FFF8;
   int Li_FFFC;

   Li_FFF8 = 1;
   if (func_1343() == false || func_1342() == false) { 
   
   Li_FFFC = -1;
   return Li_FFFC;
   } 
   if (strattype == 0) { 
   Gd_0000 = iRSI(NULL, 0, rsiperiod, rsiprice, Li_FFF8);
   if ((Gd_0000 > roverbought)) { 
   Gi_0001 = 1;
   } 
   else { 
   if ((Gd_0000 < roversold)) { 
   Gi_0001 = 0;
   } 
   else { 
   Gi_0001 = -1;
   }} 
   Li_FFFC = Gi_0001;
   return Li_FFFC;
   } 
   if (strattype == 1) { 
   Gi_0002 = Li_FFF8;
   Gi_0003 = -1;
   Gi_0004 = 0;
   Gi_0005 = 0;
   if (OrdersTotal() > 0) { 
   do { 
   if (OrderSelect(Gi_0005, 0, 0) && OrderMagicNumber() == magic && OrderSymbol() == _Symbol) { 
   if (OrderType() == Gi_0003 || Gi_0003 == -1) { 
   
   Gi_0004 = Gi_0004 + 1;
   }} 
   Gi_0005 = Gi_0005 + 1;
   } while (Gi_0005 < OrdersTotal()); 
   } 
   if (Gi_0004 == 0) {
   returned_double = iMA(NULL, 0, ma1period, ma1shift, ma1method, ma1price, Gi_0002);
   Gd_0006 = returned_double;
   Gd_0008 = Close[Gi_0002];
   if ((returned_double > Gd_0008)) {
   Gi_0009 = 0;
   }
   else{
   if ((Gd_0006 < Gd_0008)) {
   Gi_0009 = 1;
   }}}
   else{
   Gi_0009 = -1;
   }
   Li_FFFC = Gi_0009;
   return Li_FFFC;
   } 
   if (strattype == 2) { 
   if (allowBuy && allowSell == false) { 
   Gi_000A = 0;
   } 
   else { 
   if (allowSell && allowBuy == false) { 
   Gi_000A = 1;
   } 
   else { 
   Gi_000B = 1;
   Gi_000C = 0;
   Gi_000D = 0;
   if (OrdersTotal() > 0) { 
   do { 
   if (OrderSelect(Gi_000D, 0, 0) && OrderMagicNumber() == magic && OrderSymbol() == _Symbol) { 
   if (OrderType() == Gi_000B || Gi_000B == -1) { 
   
   Gi_000C = Gi_000C + 1;
   }} 
   Gi_000D = Gi_000D + 1;
   } while (Gi_000D < OrdersTotal()); 
   } 
   if (Gi_000C == 0) { 
   Gi_000A = 1;
   } 
   else { 
   Gi_000E = 0;
   Gi_000F = 0;
   Gi_0010 = 0;
   if (OrdersTotal() > 0) { 
   do { 
   if (OrderSelect(Gi_0010, 0, 0) && OrderMagicNumber() == magic && OrderSymbol() == _Symbol) { 
   if (OrderType() == Gi_000E || Gi_000E == -1) { 
   
   Gi_000F = Gi_000F + 1;
   }} 
   Gi_0010 = Gi_0010 + 1;
   } while (Gi_0010 < OrdersTotal()); 
   } 
   if (Gi_000F == 0) { 
   Gi_000A = 0;
   } 
   else { 
   Gi_000A = -1;
   }}}} 
   Li_FFFC = Gi_000A;
   return Li_FFFC;
   } 
   if (strattype != 3) return -1; 
   if (Ib_01E0) { 
   Ib_01E0 = false;
   Gi_0011 = 0;
   } 
   else { 
   if (Ib_01E1) { 
   Ib_01E1 = false;
   Gi_0011 = 1;
   } 
   else { 
   Gi_0011 = -1;
   }} 
   Li_FFFC = Gi_0011;
   return Li_FFFC;
   
   Li_FFFC = -1;
   
   return Li_FFFC;
}

double func_1305(int Fa_i_00)
{
   double Ld_FFF0;
   int Li_FFEC;
   double Ld_FFF8;

   returned_i = Fa_i_00;
   if (returned_i == 2) {
   
   Ld_FFF8 = dist2;
   return Ld_FFF8;
   }
   if (returned_i == 3) {
   
   Ld_FFF8 = (dist3 * dist2);
   return Ld_FFF8;
   }
   if (returned_i == 4) {
   
   Ld_FFF8 = ((dist4 * dist3) * dist2);
   return Ld_FFF8;
   }
   if (Fa_i_00 <= 4) return 0; 
   Ld_FFF0 = func_1305(4);
   Li_FFEC = 0;
   Gi_0000 = Fa_i_00 - 4;
   if (Gi_0000 > 0) { 
   do { 
   Ld_FFF0 = (Ld_FFF0 * dist4);
   Li_FFEC = Li_FFEC + 1;
   Gi_0000 = Fa_i_00 - 4;
   } while (Li_FFEC < Gi_0000); 
   } 
   Ld_FFF8 = Ld_FFF0;
   return Ld_FFF8;
   
   Ld_FFF8 = 0;
   
   Ind_000 = Ld_FFF8;
}

double func_1306(int Fa_i_00, int Fa_i_01)
{
   double Ld_FFF0;
   int Li_FFEC;
   double Ld_FFF8;

   Ld_FFF0 = func_1299(Fa_i_01);
   Li_FFEC = 1;
   Gi_0000 = Fa_i_00 - 1;
   Gi_0000 = Gi_0000 / mulSkip;
   if (Gi_0000 >= 1) { 
   do { 
   Ld_FFF0 = (Ld_FFF0 * lotMul);
   Ld_FFF0 = NormalizeDouble(Ld_FFF0, 2);
   Li_FFEC = Li_FFEC + 1;
   Gi_0000 = Fa_i_00 - 1;
   Gi_0000 = Gi_0000 / mulSkip;
   } while (Li_FFEC <= Gi_0000); 
   } 
   if ((lotMax != 0)) { 
   Gd_0000 = lotMax;
   if (lotMax >= Ld_FFF0) { 
   Gd_0001 = Ld_FFF0;
   } 
   else { 
   Gd_0001 = Gd_0000;
   } 
   Ld_FFF0 = Gd_0001;
   } 
   Gd_0001 = NormalizeDouble(Ld_FFF0, 2);
   returned_double = SymbolInfoDouble(NULL, 34);
   Gd_0002 = returned_double;
   if ((Gd_0001 < Gd_0002)) { 
   StringFormat("Volume is less than the minimal allowed SYMBOL_VOLUME_MIN=%.2f", returned_double);
   Gd_0003 = Gd_0002;
   } 
   else { 
   returned_double = SymbolInfoDouble(NULL, 35);
   Gd_0004 = returned_double;
   if ((Gd_0001 > Gd_0004)) { 
   StringFormat("Volume is greater than the maximal allowed SYMBOL_VOLUME_MAX=%.2f", returned_double);
   Gd_0003 = Gd_0004;
   } 
   else { 
   returned_double = SymbolInfoDouble(NULL, 36);
   Gd_0005 = returned_double;
   Gd_0006 = round((Gd_0001 / Gd_0005));
   Gi_0006 = (int)Gd_0006;
   Gd_0007 = fabs(((Gi_0006 * returned_double) - Gd_0001));
   if ((Gd_0007 > 1E-07)) { 
   StringFormat("Volume is not a multiple of the minimal step SYMBOL_VOLUME_STEP=%.2f, the closest correct volume is %.2f", returned_double, (Gi_0006 * returned_double));
   Gd_0003 = (Gi_0006 * Gd_0005);
   } 
   else { 
   Gd_0003 = NormalizeDouble(Gd_0001, 2);
   }}} 
   Ld_FFF0 = Gd_0003;
   Ld_FFF8 = Gd_0003;
   return Gd_0003;
}

int func_1309(int Fa_i_00, double Fa_d_01, double Fa_d_02, double Fa_d_03, string Fa_s_04, string Fa_s_05)
{
   string tmp_str0000;
   string tmp_str0001;
   string tmp_str0002;
   string tmp_str0003;
   string tmp_str0004;
   string tmp_str0005;
   string tmp_str0006;
   int Li_FFFC;
   double Ld_FFF0;
   double Ld_FFE8;
   int Li_FFE4;
   string Ls_FFD8;
   int Li_FFD4;
   double Ld_FFC8;
   string Ls_FFB8;
   long Ll_FFB0;
   int Li_FFAC;
   double Ld_FFA0;
   double Ld_FF98;
   int Li_FF94;
   double Ld_FF88;
   double Ld_FF80;
   int Li_FF7C;
   double Ld_FF70;
   double Ld_FF68;
   double Ld_FF60;
   bool Lb_FF5F;

   if (oneTradePerCandle) { 
   if (Il_01F8 == Time[0]) { 
   Li_FFFC = 0;
   return Li_FFFC;
   } 
   Il_01F8 = Time[0];
   } 
   Ld_FFF0 = (MarketInfo(NULL, MODE_SPREAD) / 10);
   if ((Ld_FFF0 > maxspread) && (maxspread != 0) && IsTesting() == false) { 
   Li_FFFC = -1;
   return Li_FFFC;
   } 
   Fa_d_01 = NormalizeDouble(Fa_d_01, 2);
   Ld_FFE8 = 1;
   if (_Digits == 5 || _Digits == 3) { 
   
   Ld_FFE8 = 10;
   } 
   else { 
   Ld_FFE8 = 1;
   } 
   Li_FFE4 = 0;
   Ls_FFD8 = Fa_s_05;
   if (Ls_FFD8 == "") { 
   Ls_FFD8 = _Symbol;
   } 
   Li_FFD4 = Fa_i_00;
   Ld_FFC8 = Fa_d_01;
   Gd_0002 = (MarketInfo(Ls_FFD8, MODE_MARGINREQUIRED) * Fa_d_01);
   if ((Gd_0002 > AccountFreeMargin())) { 
   tmp_str0000 = "Market Order: Can not open a trade. Not enough free margin to open " + DoubleToString(Fa_d_01, 8);
   tmp_str0000 = tmp_str0000 + " on ";
   tmp_str0000 = tmp_str0000 + Ls_FFD8;
   Print(tmp_str0000);
   Li_FFFC = -1;
   return Li_FFFC;
   } 
   Ls_FFB8 = Is_01C0;
   Ll_FFB0 = 0;
   Li_FFAC = 0;
   if (Fa_i_00 == 0) { 
   Li_FFAC = 16711680;
   } 
   if (Fa_i_00 == 1) { 
   Li_FFAC = 32768;
   } 
   Ld_FFA0 = 0;
   Ld_FF98 = 0;
   if ((Fa_d_02 != 0)) { 
   Gd_0002 = ceil(((MarketInfo(Ls_FFD8, MODE_STOPLEVEL) / Ld_FFE8) * _Point));
   if ((Fa_d_02 <= Gd_0002)) { 
   Fa_d_02 = ceil(((MarketInfo(Ls_FFD8, MODE_STOPLEVEL) / Ld_FFE8) * _Point));
   }} 
   if ((Fa_d_03 != 0)) { 
   Gd_0002 = ceil(((MarketInfo(Ls_FFD8, MODE_STOPLEVEL) / Ld_FFE8) * _Point));
   if ((Fa_d_03 <= Gd_0002)) { 
   Fa_d_03 = ceil(((MarketInfo(Ls_FFD8, MODE_STOPLEVEL) / Ld_FFE8) * _Point));
   }} 
   Li_FF94 = -1;
   Ld_FF88 = 0;
   Ld_FF80 = MarketInfo(Ls_FFD8, MODE_POINT);
   Li_FF7C = (int)MarketInfo(Ls_FFD8, MODE_DIGITS);
   Ld_FF70 = MarketInfo(Ls_FFD8, MODE_ASK);
   Ld_FF68 = MarketInfo(Ls_FFD8, MODE_BID);
   if ((Fa_d_03 == 0) && (Fa_d_02 == 0) && Li_FFE4 < 3) { 
   do { 
   RefreshRates();
   Ld_FF70 = MarketInfo(Ls_FFD8, MODE_ASK);
   Ld_FF68 = MarketInfo(Ls_FFD8, MODE_BID);
   if (Fa_i_00 == 0) { 
   Ld_FF88 = Ld_FF70;
   } 
   if (Fa_i_00 == 1) { 
   Ld_FF88 = Ld_FF68;
   } 
   if (Fa_i_00 == 0 && (Fa_d_02 != 0)) { 
   Gd_0002 = ((Fa_d_02 * Ld_FFE8) * Ld_FF80);
   returned_double = NormalizeDouble((Ld_FF70 - Gd_0002), Li_FF7C);
   Ld_FFA0 = returned_double;
   if ((Ld_FF68 > Ld_FFA0)) { 
   Gd_0002 = (Ld_FF68 - returned_double);
   if ((Gd_0002 <= (MarketInfo(Ls_FFD8, MODE_STOPLEVEL) * Ld_FF80))) { 
   Gd_0002 = (MarketInfo(Ls_FFD8, MODE_STOPLEVEL) * Ld_FF80);
   Ld_FFA0 = NormalizeDouble((Ld_FF68 - Gd_0002), Li_FF7C);
   }}} 
   if (Fa_i_00 == 1 && (Fa_d_02 != 0)) { 
   returned_double = NormalizeDouble((((Fa_d_02 * Ld_FFE8) * Ld_FF80) + Ld_FF68), Li_FF7C);
   Ld_FFA0 = returned_double;
   if ((Ld_FFA0 > Ld_FF70)) { 
   Gd_0002 = (returned_double - Ld_FF70);
   if ((Gd_0002 <= (MarketInfo(Ls_FFD8, MODE_STOPLEVEL) * Ld_FF80))) { 
   Ld_FFA0 = NormalizeDouble(((MarketInfo(Ls_FFD8, MODE_STOPLEVEL) * Ld_FF80) + Ld_FF70), Li_FF7C);
   }}} 
   if (Fa_i_00 == 0 && (Fa_d_03 != 0)) { 
   returned_double = NormalizeDouble((((Fa_d_03 * Ld_FFE8) * Ld_FF80) + Ld_FF70), Li_FF7C);
   Ld_FF98 = returned_double;
   if ((Ld_FF98 > Ld_FF70)) { 
   Gd_0002 = (returned_double - Ld_FF70);
   if ((Gd_0002 <= (MarketInfo(Ls_FFD8, MODE_STOPLEVEL) * Ld_FF80))) { 
   Ld_FF98 = NormalizeDouble(((MarketInfo(Ls_FFD8, MODE_STOPLEVEL) * Ld_FF80) + Ld_FF70), Li_FF7C);
   }}} 
   if (Fa_i_00 == 1 && (Fa_d_03 != 0)) { 
   Gd_0002 = ((Fa_d_03 * Ld_FFE8) * Ld_FF80);
   returned_double = NormalizeDouble((Ld_FF68 - Gd_0002), Li_FF7C);
   Ld_FF98 = returned_double;
   if ((Ld_FF68 > Ld_FF98)) { 
   Gd_0002 = (Ld_FF68 - returned_double);
   Gb_0002 = (Gd_0002 <= (MarketInfo(Ls_FFD8, MODE_STOPLEVEL) * Ld_FF80));
   if (Gb_0002) { 
   Gd_0002 = (MarketInfo(Ls_FFD8, MODE_STOPLEVEL) * Ld_FF80);
   Ld_FF98 = NormalizeDouble((Ld_FF68 - Gd_0002), Li_FF7C);
   }}} 
   tmp_str0001 = "Market Order: Trying to place an order... " + Fa_s_04;
   Print(tmp_str0001);
   if (IsTradeAllowed()) { 
   Gb_0002 = true;
   } 
   else { 
   if (IsConnected() != true) { 
   Print("Terminal is not connected to server...");
   Gb_0002 = false;
   } 
   else { 
   if (IsTradeAllowed() == false && IsTradeContextBusy() == false) { 
   Print("Trade is not alowed for some reason...");
   } 
   if (IsConnected() && IsTradeAllowed() == false && IsTradeContextBusy()) { 
   do { 
   Print("Trading context is busy... Will wait a bit...");
   Sleep(500);
   } while (IsTradeContextBusy()); 
   } 
   if (IsTradeAllowed()) { 
   RefreshRates();
   Gb_0002 = true;
   } 
   else { 
   Gb_0002 = false;
   }}} 
   if (Gb_0002) { 
   Ld_FF70 = MarketInfo(Ls_FFD8, MODE_ASK);
   Ld_FF68 = MarketInfo(Ls_FFD8, MODE_BID);
   if (Fa_i_00 == 0) { 
   Ld_FF88 = Ld_FF70;
   } 
   if (Fa_i_00 == 1) { 
   Ld_FF88 = Ld_FF68;
   } 
   Li_FF94 = OrderSend(Ls_FFD8, Li_FFD4, Ld_FFC8, NormalizeDouble(Ld_FF88, Li_FF7C), Ii_01CC, NormalizeDouble(Ld_FFA0, _Digits), NormalizeDouble(Ld_FF98, _Digits), Ls_FFB8, magic, 0, Li_FFAC);
   if (Li_FF94 < 0) { 
   Gi_0005 = GetLastError();
   tmp_str0002 = "ERROR: " + DoubleToString(Gi_0005, 8);
   Print(tmp_str0002);
   } 
   if (Li_FF94 > 0) { 
   tmp_str0003 = "Order successfully placed. Ticket: " + DoubleToString(Li_FF94, 8);
   tmp_str0003 = tmp_str0003 + ". ";
   tmp_str0003 = tmp_str0003 + Fa_s_04;
   Print(tmp_str0003);
   } 
   if (Li_FF94 > 0) break; 
   Li_FFE4 = Li_FFE4 + 1;
   Sleep(500);
   } 
   } while (Li_FFE4 < 3); 
   } 
   if ((Fa_d_03 != 0) != true) { 
   Gb_0005 = (Fa_d_02 != 0);
   if (Gb_0005 == false) return Li_FF94; 
   } 
   if (Li_FFE4 < 3) { 
   do { 
   tmp_str0004 = "Market Order: Trying to place an order... " + Fa_s_04;
   Print(tmp_str0004);
   if (IsTradeAllowed()) { 
   Gb_0005 = true;
   } 
   else { 
   if (IsConnected() != true) { 
   Print("Terminal is not connected to server...");
   Gb_0005 = false;
   } 
   else { 
   if (IsTradeAllowed() == false && IsTradeContextBusy() == false) { 
   Print("Trade is not alowed for some reason...");
   } 
   if (IsConnected() && IsTradeAllowed() == false && IsTradeContextBusy()) { 
   do { 
   Print("Trading context is busy... Will wait a bit...");
   Sleep(500);
   } while (IsTradeContextBusy()); 
   } 
   if (IsTradeAllowed()) { 
   RefreshRates();
   Gb_0005 = true;
   } 
   else { 
   Gb_0005 = false;
   }}} 
   if (Gb_0005) { 
   Ld_FF70 = MarketInfo(Ls_FFD8, MODE_ASK);
   Ld_FF68 = MarketInfo(Ls_FFD8, MODE_BID);
   if (Fa_i_00 == 0) { 
   Ld_FF88 = Ld_FF70;
   } 
   if (Fa_i_00 == 1) { 
   Ld_FF88 = Ld_FF68;
   } 
   Li_FF94 = OrderSend(Ls_FFD8, Li_FFD4, Ld_FFC8, NormalizeDouble(Ld_FF88, Li_FF7C), Ii_01CC, 0, 0, Ls_FFB8, magic, 0, Li_FFAC);
   if (Li_FF94 < 0) { 
   Gi_0006 = GetLastError();
   tmp_str0005 = "ERROR: " + DoubleToString(Gi_0006, 8);
   Print(tmp_str0005);
   } 
   if (Li_FF94 > 0) { 
   tmp_str0006 = "Order successfully placed. Ticket: " + DoubleToString(Li_FF94, 8);
   tmp_str0006 = tmp_str0006 + ". ";
   tmp_str0006 = tmp_str0006 + Fa_s_04;
   Print(tmp_str0006);
   } 
   if (Li_FF94 > 0) break; 
   Li_FFE4 = Li_FFE4 + 1;
   Sleep(500);
   } 
   } while (Li_FFE4 < 3); 
   } 
   if (Li_FF94 <= 0) return Li_FF94; 
   if (OrderSelect(Li_FF94, 1, 0) != true) return Li_FF94; 
   if ((Fa_d_02 != 0) != true) { 
   if ((Fa_d_03 == 0)) return Li_FF94; 
   } 
   returned_double = OrderOpenPrice();
   Ld_FF60 = returned_double;
   if (Fa_i_00 == 0 && (Fa_d_02 != 0)) { 
   Gd_0006 = ((Fa_d_02 * Ld_FFE8) * Ld_FF80);
   returned_double = NormalizeDouble((returned_double - Gd_0006), Li_FF7C);
   Ld_FFA0 = returned_double;
   if ((Ld_FF68 > Ld_FFA0)) { 
   Gd_0006 = (Ld_FF68 - returned_double);
   if ((Gd_0006 <= (MarketInfo(Ls_FFD8, MODE_STOPLEVEL) * Ld_FF80))) { 
   Gd_0006 = (MarketInfo(Ls_FFD8, MODE_STOPLEVEL) * Ld_FF80);
   Ld_FFA0 = NormalizeDouble((Ld_FF68 - Gd_0006), Li_FF7C);
   }}} 
   if (Fa_i_00 == 1 && (Fa_d_02 != 0)) { 
   returned_double = NormalizeDouble((((Fa_d_02 * Ld_FFE8) * Ld_FF80) + Ld_FF60), Li_FF7C);
   Ld_FFA0 = returned_double;
   if ((Ld_FFA0 > Ld_FF70)) { 
   Gd_0006 = (returned_double - Ld_FF70);
   if ((Gd_0006 <= (MarketInfo(Ls_FFD8, MODE_STOPLEVEL) * Ld_FF80))) { 
   Ld_FFA0 = NormalizeDouble(((MarketInfo(Ls_FFD8, MODE_STOPLEVEL) * Ld_FF80) + Ld_FF70), Li_FF7C);
   }}} 
   if (Fa_i_00 == 0 && (Fa_d_03 != 0)) { 
   returned_double = NormalizeDouble((((Fa_d_03 * Ld_FFE8) * Ld_FF80) + Ld_FF60), Li_FF7C);
   Ld_FF98 = returned_double;
   if ((Ld_FF98 > Ld_FF70)) { 
   Gd_0006 = (returned_double - Ld_FF70);
   if ((Gd_0006 <= (MarketInfo(Ls_FFD8, MODE_STOPLEVEL) * Ld_FF80))) { 
   Ld_FF98 = NormalizeDouble(((MarketInfo(Ls_FFD8, MODE_STOPLEVEL) * Ld_FF80) + Ld_FF70), Li_FF7C);
   }}} 
   if (Fa_i_00 == 1 && (Fa_d_03 != 0)) { 
   Gd_0006 = ((Fa_d_03 * Ld_FFE8) * Ld_FF80);
   returned_double = NormalizeDouble((Ld_FF60 - Gd_0006), Li_FF7C);
   Ld_FF98 = returned_double;
   if ((Ld_FF68 > Ld_FF98)) { 
   Gd_0006 = (Ld_FF68 - returned_double);
   Gb_0006 = (Gd_0006 <= (MarketInfo(Ls_FFD8, MODE_STOPLEVEL) * Ld_FF80));
   if (Gb_0006) { 
   Gd_0006 = (MarketInfo(Ls_FFD8, MODE_STOPLEVEL) * Ld_FF80);
   Ld_FF98 = NormalizeDouble((Ld_FF68 - Gd_0006), Li_FF7C);
   }}} 
   Lb_FF5F = false;
   Li_FFE4 = 0;
   do { 
   if (IsTradeAllowed()) { 
   Gb_0006 = true;
   } 
   else { 
   if (IsConnected() != true) { 
   Print("Terminal is not connected to server...");
   Gb_0006 = false;
   } 
   else { 
   if (IsTradeAllowed() == false && IsTradeContextBusy() == false) { 
   Print("Trade is not alowed for some reason...");
   } 
   if (IsConnected() && IsTradeAllowed() == false && IsTradeContextBusy()) { 
   do { 
   Print("Trading context is busy... Will wait a bit...");
   Sleep(500);
   } while (IsTradeContextBusy()); 
   } 
   if (IsTradeAllowed()) { 
   RefreshRates();
   Gb_0006 = true;
   } 
   else { 
   Gb_0006 = false;
   }}} 
   if (Gb_0006) { 
   Lb_FF5F = OrderModify(Li_FF94, NormalizeDouble(OrderOpenPrice(), _Digits), NormalizeDouble(Ld_FFA0, _Digits), NormalizeDouble(Ld_FF98, _Digits), 0, 4294967295);
   if (Lb_FF5F) return Li_FF94; 
   Li_FFE4 = Li_FFE4 + 1;
   Sleep(500);
   } 
   } while (Li_FFE4 < 3); 
   
   Li_FFFC = Li_FF94;
   
   return Li_FFFC;
}

bool func_1310(int Fa_i_00, string Fa_s_01)
{
   string tmp_str0000;
   string tmp_str0001;
   string tmp_str0002;
   string tmp_str0003;
   string tmp_str0004;
   string tmp_str0005;
   string tmp_str0006;
   bool Lb_FFFE;
   double Ld_FFF0;
   int Li_FFEC;
   bool Lb_FFFF;
   bool Lb_FFEB;

   if (OrderSelect(Fa_i_00, 1, 0) && OrderType() <= OP_SELL && OrderCloseTime() == 0) { 
   Lb_FFFE = false;
   Ld_FFF0 = 0;
   Li_FFEC = 0;
   if (OrderType() == OP_BUY) { 
   Li_FFEC = 16711680;
   } 
   if (OrderType() == OP_SELL) { 
   Li_FFEC = 32768;
   } 
   if (IsTradeAllowed()) { 
   Gb_0000 = true;
   } 
   else { 
   if (IsConnected() != true) { 
   Print("Terminal is not connected to server...");
   Gb_0000 = false;
   } 
   else { 
   if (IsTradeAllowed() == false && IsTradeContextBusy() == false) { 
   Print("Trade is not alowed for some reason...");
   } 
   if (IsConnected() && IsTradeAllowed() == false && IsTradeContextBusy()) { 
   do { 
   Print("Trading context is busy... Will wait a bit...");
   Sleep(500);
   } while (IsTradeContextBusy()); 
   } 
   if (IsTradeAllowed()) { 
   RefreshRates();
   Gb_0000 = true;
   } 
   else { 
   Gb_0000 = false;
   }}} 
   if (Gb_0000) { 
   if (OrderType() == OP_BUY) { 
   tmp_str0000 = OrderSymbol();
   Ld_FFF0 = MarketInfo(tmp_str0000, MODE_BID);
   } 
   if (OrderType() == OP_SELL) { 
   tmp_str0001 = OrderSymbol();
   Ld_FFF0 = MarketInfo(tmp_str0001, MODE_ASK);
   } 
   Lb_FFFE = OrderClose(Fa_i_00, OrderLots(), Ld_FFF0, Ii_01CC, Li_FFEC);
   } 
   if (Lb_FFFE != true) { 
   Gi_0001 = GetLastError();
   tmp_str0002 = "ERROR: " + IntegerToString(Gi_0001, 0, 32);
   Print(tmp_str0002);
   } 
   if (Lb_FFFE) { 
   tmp_str0003 = "Position successfully closed. " + Fa_s_01;
   Print(tmp_str0003);
   } 
   Lb_FFFF = Lb_FFFE;
   return Lb_FFFF;
   } 
   if (!OrderSelect(Fa_i_00, 1, 0)) return true; 
   if (OrderType() <= OP_SELL) return true; 
   if (OrderCloseTime() != 0) return true; 
   Lb_FFEB = false;
   tmp_str0004 = "Kill Ticket: Trying to delete pending order " + IntegerToString(Fa_i_00, 0, 32);
   tmp_str0004 = tmp_str0004 + " ... ";
   tmp_str0004 = tmp_str0004 + Fa_s_01;
   Print(tmp_str0004);
   if (IsTradeAllowed()) { 
   Gb_0001 = true;
   } 
   else { 
   if (IsConnected() != true) { 
   Print("Terminal is not connected to server...");
   Gb_0001 = false;
   } 
   else { 
   if (IsTradeAllowed() == false && IsTradeContextBusy() == false) { 
   Print("Trade is not alowed for some reason...");
   } 
   if (IsConnected() && IsTradeAllowed() == false && IsTradeContextBusy()) { 
   do { 
   Print("Trading context is busy... Will wait a bit...");
   Sleep(500);
   } while (IsTradeContextBusy()); 
   } 
   if (IsTradeAllowed()) { 
   RefreshRates();
   Gb_0001 = true;
   } 
   else { 
   Gb_0001 = false;
   }}} 
   if (Gb_0001) { 
   Lb_FFEB = OrderDelete(Fa_i_00, 4294967295);
   } 
   if (Lb_FFEB != true) { 
   Gi_0002 = GetLastError();
   tmp_str0005 = "ERROR: " + IntegerToString(Gi_0002, 0, 32);
   Print(tmp_str0005);
   } 
   if (Lb_FFEB) { 
   tmp_str0006 = "Order successfully deleted. " + Fa_s_01;
   Print(tmp_str0006);
   } 
   Lb_FFFF = Lb_FFEB;
   return Lb_FFFF;
   
   Lb_FFFF = true;
   
   return Lb_FFFF;
}

void func_1340(long Fa_l_00, string Fa_s_01, int Fa_i_02, bool FuncArg_Boolean_00000003, int Fa_i_04)
{
   string tmp_str0000;
   string tmp_str0001;
   string Ls_FFF0;
   string Ls_FFE0;
   int Li_FFDC;
   int Li_FFD8;
   double Ld_FFD0;

   tmp_str0000 = "iOBJCandleText" + TimeToString(Fa_l_00, 3);
   tmp_str0001 = (string)FuncArg_Boolean_00000003;
   tmp_str0000 = tmp_str0000 + tmp_str0001;
   Ls_FFF0 = tmp_str0000;
   Ls_FFE0 = ObjectGetString(0, Ls_FFF0, 999, 0);
   if (Ls_FFE0 != NULL) { 
   Global_ReturnedString = StringSubstr(Ls_FFE0, 1, 0);
   Ls_FFE0 = Global_ReturnedString;
   Gd_0000 = (double)Fa_s_01;
   Gd_0001 = (double)Global_ReturnedString;
   Fa_s_01 = DoubleToString(NormalizeDouble((Gd_0000 + Gd_0001), 2), 2);
   } 
   if (AccountCurrency() == "USD") { 
   tmp_str0001 = "$" + Fa_s_01;
   Fa_s_01 = tmp_str0001;
   } 
   else { 
   tmp_str0001 = AccountCurrency();
   tmp_str0001 = tmp_str0001 + " ";
   tmp_str0001 = tmp_str0001 + Fa_s_01;
   Fa_s_01 = tmp_str0001;
   } 
   Li_FFDC = 0;
   Li_FFD8 = iBarShift(NULL, 0, Fa_l_00, false);
   if (FuncArg_Boolean_00000003) { 
   Gd_0002 = ((iATR(NULL, 0, 14, 1) * Fa_i_04) + High[Li_FFD8]);
   } 
   else { 
   Gd_0004 = (iATR(NULL, 0, 14, 1) * Fa_i_04);
   Gd_0002 = (Low[Li_FFD8] - Gd_0004);
   } 
   Ld_FFD0 = Gd_0002;
   ObjectCreate(Li_FFDC, Ls_FFF0, OBJ_TEXT, 0, Fa_l_00, Gd_0002);
   ObjectSetDouble(Li_FFDC, Ls_FFF0, 20, Gd_0002);
   ObjectSetInteger(Li_FFDC, Ls_FFF0, 6, Fa_i_02);
   ObjectSetInteger(Li_FFDC, Ls_FFF0, 9, 1);
   ObjectSetInteger(Li_FFDC, Ls_FFF0, 1000, 0);
   ObjectSetInteger(Li_FFDC, Ls_FFF0, 17, 0);
   ObjectSetString(Li_FFDC, Ls_FFF0, 999, Fa_s_01);
}

bool func_1342()
{
   double Ld_FFF0;
   double Ld_FFE8;
   double Ld_FFE0;
   double Ld_FFD8;
   bool Lb_FFD7;
   bool Lb_FFD6;
   bool Lb_FFFF;
   bool Lb_FFD5;
   bool Lb_FFD4;

   if (use_date == false) return true; 
   Ld_FFF0 = TimeHour(StringToTime(startTime));
   Ld_FFE8 = TimeMinute(StringToTime(startTime));
   Ld_FFE0 = TimeHour(StringToTime(endTime));
   Ld_FFD8 = TimeMinute(StringToTime(endTime));
   if ((Ld_FFF0 > Ld_FFE0)) { 
   Ld_FFF0 = TimeHour(StringToTime(endTime));
   Ld_FFE8 = TimeMinute(StringToTime(endTime));
   Ld_FFE0 = TimeHour(StringToTime(startTime));
   Ld_FFD8 = TimeMinute(StringToTime(startTime));
   Lb_FFD7 = false;
   Lb_FFD6 = false;
   if ((Hour() > Ld_FFF0)) { 
   Lb_FFD7 = true;
   } 
   else { 
   if ((Hour() == Ld_FFF0) && (Minute() >= Ld_FFE8)) { 
   Lb_FFD7 = true;
   }} 
   Gb_0000 = (Hour() < Ld_FFE0);
   if (Gb_0000) { 
   Lb_FFD6 = true;
   } 
   else { 
   if ((Hour() == Ld_FFE0) && (Minute() < Ld_FFD8)) { 
   Lb_FFD6 = true;
   }} 
   Gb_0000 = Lb_FFD7;
   if (Lb_FFD7) { 
   Gb_0000 = Lb_FFD6;
   } 
   Lb_FFFF = !Gb_0000;
   return Lb_FFFF;
   } 
   Lb_FFD5 = false;
   Lb_FFD4 = false;
   if ((Hour() > Ld_FFF0)) { 
   Lb_FFD5 = true;
   } 
   else { 
   if ((Hour() == Ld_FFF0) && (Minute() >= Ld_FFE8)) { 
   Lb_FFD5 = true;
   }} 
   Gb_0000 = (Hour() < Ld_FFE0);
   if (Gb_0000) { 
   Lb_FFD4 = true;
   } 
   else { 
   if ((Hour() == Ld_FFE0) && (Minute() < Ld_FFD8)) { 
   Lb_FFD4 = true;
   }} 
   Gb_0000 = Lb_FFD5;
   if (Lb_FFD5) { 
   Gb_0000 = Lb_FFD4;
   } 
   Lb_FFFF = Gb_0000;
   return Lb_FFFF;
   
   Lb_FFFF = true;
   
   return Lb_FFFF;
}

bool func_1343()
{
   int Li_FFF8;
   bool Lb_FFFF;

   Li_FFF8 = DayOfWeek();
   if (Li_FFF8 == 1) { 
   Lb_FFFF = monday;
   return Lb_FFFF;
   } 
   if (Li_FFF8 == 2) { 
   Lb_FFFF = tuesday;
   return Lb_FFFF;
   } 
   if (Li_FFF8 == 3) { 
   Lb_FFFF = wednesday;
   return Lb_FFFF;
   } 
   if (Li_FFF8 == 4) { 
   Lb_FFFF = thursday;
   return Lb_FFFF;
   } 
   if (Li_FFF8 != 5) return true; 
   Lb_FFFF = friday;
   return Lb_FFFF;
   
   Lb_FFFF = true;
   
   return Lb_FFFF;
}


