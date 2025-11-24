import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/navigation/app_router.dart';

// Ranglar
const Color kPrimaryBlue = Color(0xFF007AFF); // Moviy (ko'k) rang
const Color kPrimaryCyan = Color(0xFF00CFFF); // Cyan rang (gradient uchun)
const Color kScaffoldBgColor = Color(0xFFF9F9F9); // Umumiy och kulrang fon
const Color kConfirmedColor = Color(0xFF34C759); // Tasdiqlangan (yashil) rang
const Color kConfirmedBgColor = Color(0xFFE5F7EB); // Tasdiqlangan fon rangi
const Color kPriceColor = Color(0xFF007AFF); // Narx (UZS) uchun rang
const Color kHintColor = Color(0xFF8E8E93); // Kichik ma'lumotlar rangi
const Color kTabIndicatorColor = kPrimaryBlue; // Tab chizig'i rangi
const Color kExchangeColor = Color(0xFFFF9500); // Reys almashtirish (sariq) rang

@RoutePage()
class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Tablar ro'yxati: Nomi va elementlar soni
  final List<Map<String, dynamic>> _tabs = [
    {'title': 'All', 'count': 8, 'key': 'all'},
    {'title': 'Flights', 'count': 2, 'key': 'flights'},
    {'title': 'Hotels', 'count': 2, 'key': 'hotels'},
    {'title': 'Banking', 'count': 1, 'key': 'banking'},
    {'title': 'Insu', 'count': 0, 'key': 'insurance'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      setState(() {
        // Tab o'zgarganda UI yangilanadi
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ??
            Theme.of(context).scaffoldBackgroundColor,
        scrolledUnderElevation: 0,
        title: Text(
          "Buyurtmalarim",
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color ?? Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).iconTheme.color ?? Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        // App Barning pastki qismiga TabBar joylashtiriladi
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50.h), // TabBar balandligi
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: TabBar(
              controller: _tabController,
              isScrollable: true, // Tablar ko'p bo'lsa scroll bo'lishi uchun
              indicatorColor: Theme.of(context).colorScheme.primary,
              dividerColor: Colors.transparent, // Divider ni olib tashlash
              labelColor: Theme.of(context).colorScheme.primary, // Tanlangan tab rangi
              unselectedLabelColor: Theme.of(context).textTheme.bodySmall?.color ??
                  kHintColor, // Tanlanmagan tab rangi
              labelStyle: TextStyle(
                fontWeight: FontWeight.w600, // Qalinroq
                fontSize: 16.sp,
              ),
              unselectedLabelStyle: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 16.sp,
              ),
              tabs: _tabs.asMap().entries.map((entry) {
                final index = entry.key;
                final tab = entry.value;
                final isSelected = _tabController.index == index;
                return _buildTab(
                  tab['title'],
                  tab['count'],
                  isSelected: isSelected,
                );
              }).toList(),
            ),
          ),
        ),
      ),
      // Body qismida TabBarView
      body: TabBarView(
        controller: _tabController,
        children: _tabs.map((tab) {
          // Har bir tab uchun kontent
          return _buildTabContent(context, tab['key']);
        }).toList(),
      ),
    );
  }

  // Tab sarlavhalarini yaratish uchun yordamchi widget
  Widget _buildTab(String title, int count, {bool isSelected = false}) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title),
          if (count > 0) ...[
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
                    : Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.2) ??
                        kHintColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).textTheme.titleLarge?.color ?? Colors.black,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Har bir Tab uchun kontentni yaratish uchun yordamchi widget
  Widget _buildTabContent(BuildContext context, String tabKey) {
    // Eng pastki qismdagi padding
    EdgeInsets contentPadding = EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 16.h);

    // Barcha buyurtmalar (rasmdagi)
    if (tabKey == 'all' || tabKey == 'flights' || tabKey == 'hotels') {
      return SingleChildScrollView(
        padding: contentPadding,
        child: Column(
          children: [
            // Mehmonxona buyurtmasi
            if (tabKey == 'all' || tabKey == 'hotels') ...[
              OrderCardHotel(
                title: 'Hyatt Regency Tashkent',
                duration: '3 kecha • 2 mehmon',
                dates: '15-18 Dec 2024',
                price: '1,200,000 UZS',
                onTap: () {
                  context.router.push(const BookingDetailsRoute());
                },
              ),
              SizedBox(height: 12.h),
            ],
            // Avia chipta buyurtmasi (To'g'ridan-to'g'ri reys)
            if (tabKey == 'all' || tabKey == 'flights') ...[
              OrderCardFlight(
                route: 'Toshkent (TAS) — Istanbul (IST)',
                dateTime: '20 Dec 2024, 10:00',
                statusInfo: 'To\'g\'ridan-to\'g\'ri',
                duration: '4 soat 30 minut',
                classType: 'Ekonom',
                airline: 'Turkish Airlines',
                code: 'TK36820241220ABC',
                price: '3,500,000 UZS',
                isExchange: false,
                onTap: () {
                  context.router.push(const BookingDetailsRoute());
                },
              ),
              SizedBox(height: 12.h),
            ],
            // Avia chipta buyurtmasi (Reys almashtirish)
            if (tabKey == 'all' || tabKey == 'flights') ...[
              OrderCardFlight(
                route: 'Toshkent (TAS) — Istanbul (IST)',
                dateTime: '20 Dec 2024, 10:00',
                statusInfo: 'Reys almashtirish',
                duration: '4 soat 30 minut',
                classType: 'Ekonom',
                airline: 'Turkish Airlines',
                code: 'TK36820241220ABC',
                price: '3,500,000 UZS',
                isExchange: true,
                onTap: () {
                  context.router.push(const BookingDetailsRoute());
                },
              ),
              SizedBox(height: 12.h),
            ],
          ],
        ),
      );
    }

    // Boshqa tablar uchun Loading va Hech narsa yo'q holati
    return _buildEmptyContent();
  }

  // Loading va Hech narsa yo'q holatini ko'rsatuvchi yordamchi widget
  Widget _buildEmptyContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 30.w,
            height: 30.w,
            child:             CircularProgressIndicator(
              strokeWidth: 2,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            "Buyurtmalar hozircha mavjud emas",
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color ?? kHintColor,
              fontSize: 16.sp,
            ),
          ),
          SizedBox(height: 100.h), // Ekranning pastki qismida bo'lishi uchun
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------
// 3. Hotel (Mehmonxona) Buyurtmasi Card Widgeti
class OrderCardHotel extends StatelessWidget {
  final String title;
  final String duration;
  final String dates;
  final String price;
  final VoidCallback onTap;

  const OrderCardHotel({
    super.key,
    required this.title,
    required this.duration,
    required this.dates,
    required this.price,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(15.r),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hotel Icon
                _buildIconBackground(Icons.business, context),
                SizedBox(width: 12.w),
                // Title and Status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.titleLarge?.color ??
                              Colors.black,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            duration,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Theme.of(context).textTheme.bodyMedium?.color ??
                                  kHintColor,
                            ),
                          ),
                          _buildStatusChip(context, 'Tasdiqlangan'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            // Dates and Icon
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16.sp,
                  color: kHintColor,
                ),
                SizedBox(width: 6.w),
                Text(
                  dates,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Theme.of(context).textTheme.bodyMedium?.color ??
                        kHintColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Divider(
              color: Theme.of(context).dividerColor,
              height: 20.h,
              thickness: 1,
            ),
            // Price and Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Row(
                  children: [
                    _buildTextButton(
                      context,
                      'Aloqa',
                      Icons.call_outlined,
                      isGreen: true,
                    ),
                    SizedBox(width: 8.w),
                    _buildTextButton(
                      context,
                      'Batafsil',
                      Icons.arrow_forward,
                      isInfo: true,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------
// 4. Flight (Avia chipta) Buyurtmasi Card Widgeti
class OrderCardFlight extends StatelessWidget {
  final String route;
  final String dateTime;
  final String statusInfo;
  final String duration;
  final String classType;
  final String airline;
  final String code;
  final String price;
  final bool isExchange; // Reys almashtirish
  final VoidCallback onTap;

  const OrderCardFlight({
    super.key,
    required this.route,
    required this.dateTime,
    required this.statusInfo,
    required this.duration,
    required this.classType,
    required this.airline,
    required this.code,
    required this.price,
    this.isExchange = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(15.r),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Flight Icon
                _buildIconBackground(Icons.flight_takeoff, context),
                SizedBox(width: 12.w),
                // Route and Status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        route,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.titleLarge?.color ??
                              Colors.black,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            dateTime,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Theme.of(context).textTheme.bodyMedium?.color ??
                                  kHintColor,
                            ),
                          ),
                          _buildStatusChip(context, 'Tasdiqlangan'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            // Additional Flight Info (To'g'ridan-to'g'ri / Reys almashtirish, Vaqt, Klass)
            Row(
              children: [
                Text(
                  statusInfo,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: isExchange ? kExchangeColor : kConfirmedColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  " • ",
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color ??
                        kHintColor,
                    fontSize: 13.sp,
                  ),
                ),
                Text(
                  duration,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Theme.of(context).textTheme.bodyMedium?.color ??
                        kHintColor,
                  ),
                ),
                Text(
                  " • ",
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color ??
                        kHintColor,
                    fontSize: 13.sp,
                  ),
                ),
                Text(
                  classType,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Theme.of(context).textTheme.bodyMedium?.color ??
                        kHintColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            // Airline and Code
            Text(
              airline,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.titleLarge?.color ??
                    Colors.black,
              ),
            ),
            Text(
              'Kod: $code',
              style: TextStyle(
                fontSize: 13.sp,
                color: Theme.of(context).textTheme.bodyMedium?.color ??
                    kHintColor,
              ),
            ),
            Divider(
              color: Theme.of(context).dividerColor,
              height: 20.h,
              thickness: 1,
            ),
            // Price and Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                _buildTextButton(
                  context,
                  'Batafsil',
                  Icons.arrow_forward,
                  isInfo: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------
// 5. Yordamchi Widgetlar (OrderCardHotel va OrderCardFlight uchun)
// 5.1. Icon Foni
Widget _buildIconBackground(IconData icon, BuildContext context) {
  return Container(
    width: 40.w,
    height: 40.w,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      borderRadius: BorderRadius.circular(10.r),
    ),
    child: Icon(
      icon,
      size: 20.sp,
      color: Theme.of(context).colorScheme.primary,
    ),
  );
}

// 5.2. Status Chip (Tasdiqlangan)
Widget _buildStatusChip(BuildContext context, String text) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
    decoration: BoxDecoration(
      color: kConfirmedBgColor, // Yashil fon (status uchun maxsus rang)
      borderRadius: BorderRadius.circular(12.r),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.check_circle_outline,
          size: 14.sp,
          color: kConfirmedColor,
        ),
        SizedBox(width: 4.w),
        Text(
          text,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: kConfirmedColor,
          ),
        ),
      ],
    ),
  );
}

// 5.3. Tugma (Aloqa/Batafsil)
Widget _buildTextButton(
  BuildContext context,
  String text,
  IconData? icon, {
  bool isGreen = false,
  bool isInfo = false,
}) {
  Color buttonColor = isGreen
      ? kConfirmedBgColor
      : (isInfo
          ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
          : Colors.transparent);
  Color textColor = isGreen
      ? kConfirmedColor
      : Theme.of(context).colorScheme.primary;
  return Container(
    height: 36.h,
    decoration: BoxDecoration(
      color: buttonColor,
      borderRadius: BorderRadius.circular(8.r),
      border: isInfo
          ? null
          : (isGreen ? null : Border.all(color: Colors.transparent)),
    ),
    child: TextButton(
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: () {},
      child: Row(
        children: [
          if (isGreen) Icon(Icons.call_outlined, size: 16.sp, color: textColor),
          if (isGreen) SizedBox(width: 4.w),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    ),
  );
}


