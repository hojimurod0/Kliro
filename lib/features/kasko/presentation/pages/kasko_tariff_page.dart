import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/navigation/app_router.dart';

// --- MA'LUMOT MODELI ---
class TariffModel {
  final String title;
  final String duration;
  final String description;
  final String price;

  TariffModel({
    required this.title,
    required this.duration,
    required this.description,
    required this.price,
  });
}

// --- ASOSIY EKRAN ---
@RoutePage()
class KaskoTariffPage extends StatefulWidget {
  const KaskoTariffPage({super.key});

  @override
  State<KaskoTariffPage> createState() => _KaskoTariffPageState();
}

class _KaskoTariffPageState extends State<KaskoTariffPage> {
  int _selectedCardIndex = 0;
  int _selectedTabIndex = 0;

  // Ma'lumotlar ro'yxati (Data Source)
  final List<TariffModel> _tariffs = [
    TariffModel(
      title: "Standart A",
      duration: "12 oy",
      description: "To'liq zarar qoplash 80%",
      price: "550 000",
    ),
    TariffModel(
      title: "Standart B",
      duration: "12 oy",
      description: "To'liq zarar qoplash 90%",
      price: "750 000",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? const Color(0xFF121212) : const Color(0xFFF4F6F8);
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF111827);
    final subtitleColor = isDark ? Colors.grey[400]! : const Color(0xFF6B7280);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildCustomAppBar(cardBg, textColor),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                children: [
                  Text(
                    "Tarifni tanlang",
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "O'zingizga mos bo'lgan sug'urta tarifini tanlang",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: subtitleColor,
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Tab Switcher
                  _TabSelector(
                    selectedIndex: _selectedTabIndex,
                    onChanged: (index) => setState(() => _selectedTabIndex = index),
                    isDark: isDark,
                  ),

                  SizedBox(height: 24.h),
                  // Tariflar ro'yxatini generatsiya qilish
                  ...List.generate(_tariffs.length, (index) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 16.h),
                      child: _TariffCard(
                        data: _tariffs[index],
                        isSelected: _selectedCardIndex == index,
                        onTap: () => setState(() => _selectedCardIndex = index),
                        isDark: isDark,
                      ),
                    );
                  }),
                ],
              ),
            ),
            _buildBottomButton(cardBg, bottomPadding),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(Color cardBg, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      color: cardBg,
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFFE5E7EB),
              ),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_rounded,
                size: 20.sp,
                color: textColor,
              ),
              onPressed: () {
                context.router.pop();
              },
            ),
          ),
          Expanded(
            child: Text(
              "KASKO",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ),
          SizedBox(width: 44.w), // Balans uchun
        ],
      ),
    );
  }

  Widget _buildBottomButton(Color cardBg, double bottomPadding) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16.w,
        16.h,
        16.w,
        16.h + bottomPadding,
      ),
      decoration: BoxDecoration(
        color: cardBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 16,
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56.h,
        child: ElevatedButton(
          onPressed: () {
            // Keyingi sahifaga o'tish - hujjat ma'lumotlari sahifasiga
            context.router.push(const KaskoDocumentDataRoute());
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0085FF),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
          child: Text(
            "Davom etish",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

// --- TAB SWITCH WIDGET ---
class _TabSelector extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onChanged;
  final bool isDark;

  const _TabSelector({
    required this.selectedIndex,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF3F4F6);
    final selectedBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          _buildItem("Standart tariflar", 0, selectedBg),
          _buildItem("Boshqa tariflar", 1, selectedBg),
        ],
      ),
    );
  }

  Widget _buildItem(String text, int index, Color selectedBg) {
    final bool isSelected = selectedIndex == index;
    final textColor = isSelected
        ? const Color(0xFF0085FF)
        : (isDark ? Colors.grey[400]! : const Color(0xFF6B7280));

    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected ? selectedBg : Colors.transparent,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14.sp,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}

// --- CARD WIDGET ---
class _TariffCard extends StatelessWidget {
  final TariffModel data;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _TariffCard({
    required this.data,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF0085FF);
    final cardBg = isSelected
        ? (isDark ? const Color(0xFF1A3A5C) : const Color(0xFFEFF8FF))
        : (isDark ? const Color(0xFF1E1E1E) : Colors.white);
    final titleColor = isSelected
        ? primaryColor
        : (isDark ? Colors.white : const Color(0xFF111827));
    final textColor = isDark ? Colors.grey[300]! : const Color(0xFF4B5563);
    final subtitleColor = isDark ? Colors.grey[400]! : const Color(0xFF6B7280);
    final dividerColor = isSelected
        ? primaryColor.withOpacity(0.1)
        : (isDark ? Colors.grey[700]! : const Color(0xFFE5E7EB));
    final iconBg = isSelected
        ? const Color(0xFFD1E9FF)
        : (isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF3F4F6));
    final iconColor = isSelected
        ? primaryColor
        : (isDark ? Colors.grey[500]! : const Color(0xFF9CA3AF));

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF101828).withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Icon(
                    Icons.verified_user_outlined,
                    color: iconColor,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: titleColor,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      data.duration,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                if (isSelected)
                  Container(
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                    padding: EdgeInsets.all(4.w),
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 14.sp,
                    ),
                  ),
              ],
            ),
            SizedBox(height: 20.h),

            // Description
            Text(
              data.description,
              style: TextStyle(
                color: textColor,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 20.h),

            // Divider
            Divider(color: dividerColor),
            SizedBox(height: 12.h),

            // Price
            Row(
              children: [
                Text(
                  data.price,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF111827),
                  ),
                ),
                SizedBox(width: 6.w),
                Text(
                  "so'm",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: subtitleColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
