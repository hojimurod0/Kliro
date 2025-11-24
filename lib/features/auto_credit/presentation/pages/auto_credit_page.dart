import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/datasources/auto_credit_local_data_source.dart';
import '../../data/repositories/auto_credit_repository_impl.dart';
import '../../domain/entities/auto_credit_offer.dart';
import '../../domain/usecases/get_auto_credit_offers.dart';

@RoutePage()
class AutoCreditPage extends StatefulWidget {
  const AutoCreditPage({super.key});

  @override
  State<AutoCreditPage> createState() => _AutoCreditPageState();
}

class _AutoCreditPageState extends State<AutoCreditPage> {
  late final GetAutoCreditOffers _getAutoCreditOffers;
  List<AutoCreditOffer> _offers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getAutoCreditOffers = GetAutoCreditOffers(
      AutoCreditRepositoryImpl(
        localDataSource: const AutoCreditLocalDataSource(),
      ),
    );
    _loadOffers();
  }

  Future<void> _loadOffers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final offers = await _getAutoCreditOffers();
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
          'Avtokredit takliflari',
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
          // Qidiruv va Filtr
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: const SearchAndFilterBar(),
          ),
          // Takliflar Ro'yxati
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
                        child: AutoCreditOfferCard(offer: _offers[index]),
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

class AutoCreditOfferCard extends StatefulWidget {
  const AutoCreditOfferCard({super.key, required this.offer});

  final AutoCreditOffer offer;

  @override
  State<AutoCreditOfferCard> createState() => _AutoCreditOfferCardState();
}

class _AutoCreditOfferCardState extends State<AutoCreditOfferCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final applicationIcon = widget.offer.applicationIcon;
    final applicationColor = widget.offer.applicationColor;

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
          _buildTopInfoRow(applicationIcon, applicationColor),
          SizedBox(height: 16.h),
          _buildMetricsGrid(applicationIcon, applicationColor),
          SizedBox(height: 16.h),
          _buildAdvantagesSection(),
          SizedBox(height: 16.h),
          _buildActionButton(),
        ],
      ),
    );
  }

  Widget _buildTopInfoRow(IconData applicationIcon, Color applicationColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.apartment,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.offer.bankName,
                    style: TextStyle(
                      fontSize: 16.sp,
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
                        '${widget.offer.rating}',
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
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.credit_card_outlined,
              color: Theme.of(context).colorScheme.primary,
              size: 18.sp,
            ),
            SizedBox(width: 4.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "Oylik to'lov",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.mutedText,
                  ),
                ),
                Text(
                  widget.offer.monthlyPayment,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricsGrid(IconData applicationIcon, Color applicationColor) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AutoCreditMetricBox(
                label: 'Foiz',
                value: widget.offer.interestRate,
                valueColor: AppColors.accentGreen,
                icon: Icons.percent,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: AutoCreditMetricBox(
                label: 'Muddat',
                value: widget.offer.term,
                icon: Icons.calendar_today_outlined,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: AutoCreditMetricBox(
                label: 'Maks. summa',
                value: widget.offer.maxSum,
                icon: Icons.credit_card_outlined,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: AutoCreditMetricBox(
                label: 'Ariza berish',
                value: widget.offer.applicationMethod,
                icon: applicationIcon,
                valueColor: applicationColor,
                isApplicationType: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAdvantagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Row(
            children: [
              Text(
                'Afzalliklar (${widget.offer.advantages.length})',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.titleLarge?.color ?? AppColors.darkText,
                ),
              ),
              const Spacer(),
              Icon(
                _isExpanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: Theme.of(context).textTheme.titleLarge?.color ?? AppColors.darkText,
              ),
            ],
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: _isExpanded ? null : 0.0,
          width: double.infinity,
          child: _isExpanded
              ? SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: widget.offer.advantages.map((advantage) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 4.h),
                          child: Text(
                            "• $advantage",
                            style: TextStyle(
                              color: (Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.darkText).withOpacity(0.8),
                              fontSize: 14.sp,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
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
          backgroundColor: Theme.of(context).colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 0,
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

class AutoCreditMetricBox extends StatelessWidget {
  const AutoCreditMetricBox({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
    this.isApplicationType = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;
  final bool isApplicationType;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 70.h,
      padding: EdgeInsets.only(
        left: 12.w,
        right: 12.w,
        top: 8.h,
        bottom: 8.h,
      ),
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).scaffoldBackgroundColor : AppColors.metricBoxBackground,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? (Theme.of(context).textTheme.titleLarge?.color ?? AppColors.darkText),
                ),
              ),
              if (isApplicationType && value == 'Onlayn')
                Padding(
                  padding: EdgeInsets.only(left: 4.w),
                  child: Icon(
                    Icons.check_circle_outline,
                    color: AppColors.accentGreen,
                    size: 14.sp,
                  ),
                ),
            ],
          ),
          Row(
            children: [
              Icon(
                icon,
                color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.veryMutedText,
                size: 14.sp,
              ),
              SizedBox(width: 4.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.veryMutedText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

