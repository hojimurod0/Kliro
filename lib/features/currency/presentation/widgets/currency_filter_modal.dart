import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Ranglar va stillar
class _AppStyle {
  static const Color primaryBlue = Color(0xFF0094FF);
  static const Color textBlack = Color(0xFF111111);
  static const Color borderGray = Color(0xFFE0E0E0);
  static const Color bgWhite = Colors.white;

  static const TextStyle titleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: textBlack,
    fontFamily: 'Roboto',
  );

  static const TextStyle labelStyle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: textBlack,
  );
}

Future<Map<String, dynamic>?> showCurrencyFilterModal(BuildContext context) {
  return showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.5),
    builder: (BuildContext context) {
      return _FilterScreen();
    },
  );
}

class _FilterScreen extends StatefulWidget {
  _FilterScreen();

  @override
  State<_FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<_FilterScreen> {
  final List<Map<String, dynamic>> currencies = [
    {'code': 'USD', 'flag': '🇬🇧', 'selected': false, 'isSvg': true},
    {'code': 'EUR', 'flag': '🇪🇺', 'selected': false, 'isSvg': false},
    {'code': 'RUB', 'flag': '🇷🇺', 'selected': false, 'isSvg': false},
    {'code': 'KZT', 'flag': '🇰🇿', 'selected': false, 'isSvg': false},
  ];

  bool onlineBanksOnly = false;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: _AppStyle.bgWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const _DragHandle(),
            const _HeaderTitle(),
            SizedBox(height: 20.h),
            _CurrencySelector(
              currencies: currencies,
              onCurrencySelected: (index) {
                setState(() {
                  for (var i = 0; i < currencies.length; i++) {
                    currencies[i]['selected'] = i == index;
                  }
                });
              },
            ),
            SizedBox(height: 24.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: _OnlineBanksTile(
                isSelected: onlineBanksOnly,
                onChanged: (value) {
                  setState(() {
                    onlineBanksOnly = value;
                  });
                },
              ),
            ),
            const Spacer(),
            _BottomActionButtons(
              onClear: () {
                setState(() {
                  for (var currency in currencies) {
                    currency['selected'] = false;
                  }
                  onlineBanksOnly = false;
                });
                // Filterni tozalash
                Navigator.pop(context, {
                  'currencyCode': null,
                  'onlineOnly': false,
                });
              },
              onApply: () {
                // Tanlangan valyutani topish
                String? selectedCurrencyCode;
                for (var currency in currencies) {
                  if (currency['selected'] == true) {
                    selectedCurrencyCode = currency['code'] as String;
                    break;
                  }
                }
                
                Navigator.pop(context, {
                  'currencyCode': selectedCurrencyCode,
                  'onlineOnly': onlineBanksOnly,
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.only(top: 12.h, bottom: 16.h),
        width: 40.w,
        height: 4.h,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(2.r),
        ),
      ),
    );
  }
}

class _HeaderTitle extends StatelessWidget {
  const _HeaderTitle();

  @override
  Widget build(BuildContext context) {
    return const Text("Filter", style: _AppStyle.titleStyle);
  }
}

class _CurrencySelector extends StatelessWidget {
  const _CurrencySelector({
    required this.currencies,
    required this.onCurrencySelected,
  });

  final List<Map<String, dynamic>> currencies;
  final Function(int) onCurrencySelected;

  Widget _getCurrencyFlagWidget(String code, {double size = 18.0}) {
    switch (code.toUpperCase()) {
      case 'USD':
        return SvgPicture.asset(
          'assets/images/brinatya.svg',
          width: size,
          height: size,
          fit: BoxFit.contain,
        );
      case 'EUR':
        return Text('🇪🇺', style: TextStyle(fontSize: size));
      case 'RUB':
        return Text('🇷🇺', style: TextStyle(fontSize: size));
      case 'KZT':
        return Text('🇰🇿', style: TextStyle(fontSize: size));
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44.h,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        scrollDirection: Axis.horizontal,
        itemCount: currencies.length,
        separatorBuilder: (_, __) => SizedBox(width: 10.w),
        itemBuilder: (context, index) {
          final item = currencies[index];
          final bool isSelected = item['selected'] as bool;

          return InkWell(
            onTap: () => onCurrencySelected(index),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: isSelected ? _AppStyle.primaryBlue : Colors.transparent,
                borderRadius: BorderRadius.circular(50.r),
                border: isSelected
                    ? null
                    : Border.all(color: _AppStyle.borderGray),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  item['isSvg'] == true
                      ? _getCurrencyFlagWidget(item['code'] as String, size: 18.sp)
                      : Text(item['flag'] as String, style: TextStyle(fontSize: 18.sp)),
                  SizedBox(width: 8.w),
                  Text(
                    item['code'] as String,
                    style: TextStyle(
                      color: isSelected ? Colors.white : _AppStyle.textBlack,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OnlineBanksTile extends StatelessWidget {
  const _OnlineBanksTile({
    required this.isSelected,
    required this.onChanged,
  });

  final bool isSelected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!isSelected),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
        decoration: BoxDecoration(
          border: Border.all(color: _AppStyle.borderGray),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            Icon(Icons.language, color: Colors.grey, size: 22.sp),
            SizedBox(width: 12.w),
            const Text("Faqat onlayn banklar", style: _AppStyle.labelStyle),
            const Spacer(),
            Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? _AppStyle.primaryBlue
                      : Colors.grey.shade300,
                  width: 2,
                ),
                color: isSelected ? _AppStyle.primaryBlue : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16.sp,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomActionButtons extends StatelessWidget {
  const _BottomActionButtons({
    required this.onClear,
    required this.onApply,
  });

  final VoidCallback onClear;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 52.h,
                child: OutlinedButton(
                  onPressed: onClear,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: _AppStyle.borderGray),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    overlayColor: Colors.grey.shade100,
                  ),
                  child: Text(
                    "Tozalash",
                    style: TextStyle(
                      color: _AppStyle.textBlack,
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: SizedBox(
                height: 52.h,
                child: ElevatedButton(
                  onPressed: onApply,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _AppStyle.primaryBlue,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: Text(
                    "Saralash",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

