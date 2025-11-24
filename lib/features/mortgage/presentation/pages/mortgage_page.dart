import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/datasources/mortgage_local_data_source.dart';
import '../../data/repositories/mortgage_repository_impl.dart';
import '../../domain/entities/mortgage_offer.dart';
import '../../domain/usecases/get_mortgage_offers.dart';

@RoutePage()
class MortgagePage extends StatefulWidget {
  const MortgagePage({super.key});

  @override
  State<MortgagePage> createState() => _MortgagePageState();
}

class _MortgagePageState extends State<MortgagePage> {
  late final GetMortgageOffers _getMortgageOffers;
  List<MortgageOffer> _offers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getMortgageOffers = GetMortgageOffers(
      MortgageRepositoryImpl(
        localDataSource: const MortgageLocalDataSource(),
      ),
    );
    _loadOffers();
  }

  Future<void> _loadOffers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final offers = await _getMortgageOffers();
      setState(() {
        _offers = offers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Xatolik yuz berdi: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).iconTheme.color ?? Theme.of(context).textTheme.titleLarge?.color,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Ipoteka takliflari',
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color ?? AppColors.darkText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: const SearchAndFilterBar(),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    itemCount: _offers.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 16.h),
                        child: MortgageOfferCard(offer: _offers[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class SearchAndFilterBar extends StatelessWidget {
  const SearchAndFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48.h,
            decoration: BoxDecoration(
              color: isDark ? Theme.of(context).cardColor : AppColors.metricBoxBackground,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: TextField(
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.darkText,
              ),
              decoration: InputDecoration(
                hintText: "Bank nomini qidiring...",
                hintStyle: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.mutedText,
                  fontSize: 16.sp,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24.sp,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14.h),
              ),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Container(
          height: 48.h,
          width: 48.w,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Center(
            child: Icon(
              Icons.filter_list,
              color: Theme.of(context).colorScheme.primary,
              size: 24.sp,
            ),
          ),
        ),
      ],
    );
  }
}

class MortgageOfferCard extends StatelessWidget {
  const MortgageOfferCard({super.key, required this.offer});

  final MortgageOffer offer;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
        boxShadow: isDark ? null : [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBankInfo(context),
          SizedBox(height: 12.h),
          _buildPropertyType(context),
          SizedBox(height: 16.h),
          _buildMetricsGrid(),
          SizedBox(height: 16.h),
          AdvantagesDropdown(advantages: offer.advantages),
          SizedBox(height: 16.h),
          _buildActionButton(),
        ],
      ),
    );
  }

  Widget _buildBankInfo(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            Icons.apartment,
            color: AppColors.primaryBlue,
            size: 20.sp,
          ),
        ),
        SizedBox(width: 12.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              offer.bankName,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.titleLarge?.color ?? AppColors.darkText,
              ),
            ),
            Row(
              children: [
                Text(
                  'UZS',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.mutedText,
                  ),
                ),
                SizedBox(width: 6.w),
                Icon(Icons.star, color: Colors.amber, size: 16.sp),
                Text(
                  '${offer.rating}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Theme.of(context).textTheme.titleLarge?.color ?? AppColors.darkText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPropertyType(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.location_on_outlined,
          color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.veryMutedText,
          size: 18.sp,
        ),
        SizedBox(width: 8.w),
        Text(
          'Mulk turi',
          style: TextStyle(
            fontSize: 14.sp,
            color: Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.mutedText,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () {},
          child: Text(
            'Barcha turlar',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: MortgageMetricBox(
                label: 'Foiz',
                value: offer.interestRate,
                valueColor: AppColors.accentGreen,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: MortgageMetricBox(
                label: 'Muddat',
                value: offer.term,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: MortgageMetricBox(
                label: 'Maks. summa',
                value: offer.maxSum,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: MortgageMetricBox(
                label: "Boshlang'ich",
                value: offer.downPayment,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      height: 48.h,
      child: ElevatedButton(
        onPressed: () {
          // TODO: Navigate to application page
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 0,
          padding: EdgeInsets.symmetric(vertical: 14.h),
        ),
        child: Text(
          'Ariza topshirish',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class MortgageMetricBox extends StatelessWidget {
  const MortgageMetricBox({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    IconData icon;
    if (label == 'Foiz') {
      icon = Icons.percent;
    } else if (label == 'Muddat') {
      icon = Icons.calendar_today_outlined;
    } else if (label == 'Maks. summa') {
      icon = Icons.money;
    } else {
      icon = Icons.schedule;
    }

    return Container(
      height: 70.h,
      padding: EdgeInsets.only(
        left: 12.w,
        right: 12.w,
        top: 8.h,
        bottom: 8.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.metricBoxBackground,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.darkText,
            ),
          ),
          Row(
            children: [
              Icon(
                icon,
                color: AppColors.veryMutedText,
                size: 14.sp,
              ),
              SizedBox(width: 4.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.veryMutedText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AdvantagesDropdown extends StatefulWidget {
  const AdvantagesDropdown({super.key, required this.advantages});

  final List<String> advantages;

  @override
  State<AdvantagesDropdown> createState() => _AdvantagesDropdownState();
}

class _AdvantagesDropdownState extends State<AdvantagesDropdown> {
  bool isOpen = false;
  late List<String> advantages;

  @override
  void initState() {
    super.initState();
    advantages = List.from(widget.advantages);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              isOpen = !isOpen;
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark 
                  ? Theme.of(context).scaffoldBackgroundColor 
                  : AppColors.metricBoxBackground,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              children: [
                Text(
                  "Afzalliklar (${advantages.length})",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                Icon(
                  isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: Colors.black87,
                ),
              ],
            ),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: isOpen ? (advantages.length * 55.h) + 60.h : 0,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: isOpen
              ? Column(
                  children: [
                    ...advantages.map(
                      (item) => Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          vertical: 12.h,
                          horizontal: 8.w,
                        ),
                        child: Text(
                          "- $item",
                          style: TextStyle(fontSize: 15.sp),
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    InkWell(
                      onTap: () {
                        setState(() {
                          advantages.add("Yangi afzallik");
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 12.h,
                          horizontal: 8.w,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add, size: 20.sp),
                            SizedBox(width: 6.w),
                            Text(
                              "Afzallik qo'shish",
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : null,
        ),
      ],
    );
  }
}

