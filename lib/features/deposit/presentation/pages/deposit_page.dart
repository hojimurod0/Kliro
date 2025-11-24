import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../deposit/data/datasources/deposit_local_data_source.dart';
import '../../../deposit/data/repositories/deposit_repository_impl.dart';
import '../../../deposit/domain/entities/deposit_offer.dart';
import '../../../deposit/domain/usecases/get_deposit_offers.dart';

@RoutePage()
class DepositPage extends StatelessWidget {
  DepositPage({super.key});

  static final GetDepositOffers _getDepositOffers = GetDepositOffers(
    DepositRepositoryImpl(localDataSource: const DepositLocalDataSource()),
  );

  static final List<DepositOffer> _offers = _getDepositOffers();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        leading: Center(
          child: Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(
                Icons.arrow_back,
                color: Theme.of(context).iconTheme.color ?? Colors.black,
                size: 20.sp,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        centerTitle: true,
        title: Text(
          tr('deposit.title'),
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color ?? Colors.black,
            fontSize: 17.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Theme.of(context).cardColor,
            padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 16.h),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48.h,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: tr('deposit.search_hint'),
                        hintStyle: TextStyle(
                          color: Theme.of(context).textTheme.bodySmall?.color ?? const Color(0xFF9CA3AF),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Theme.of(context).colorScheme.primary,
                          size: 22.sp,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 13.h),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Container(
                  width: 48.h,
                  height: 48.h,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Icon(
                    Icons.filter_alt_outlined,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24.sp,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.all(20.w),
              itemCount: _offers.length,
              separatorBuilder: (context, index) => SizedBox(height: 16.h),
              itemBuilder: (context, index) {
                return _DepositCard(offer: _offers[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DepositCard extends StatelessWidget {
  const _DepositCard({required this.offer});

  final DepositOffer offer;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
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
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: offer.logoColor,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  offer.logoIcon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offer.bankName,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).textTheme.titleLarge?.color ?? const Color(0xFF111827),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Text(
                          offer.currency,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).textTheme.bodyMedium?.color ?? const Color(0xFF6B7280),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Icon(
                          Icons.star_rounded,
                          color: const Color(0xFFF59E0B),
                          size: 16.sp,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          offer.rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).textTheme.titleLarge?.color ?? const Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildInfoBlock(
                  context: context,
                  icon: Icons.percent_rounded,
                  label: tr('deposit.interest_rate'),
                  value: offer.interestRate,
                  isGreen: true,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildInfoBlock(
                  context: context,
                  icon: Icons.calendar_today_outlined,
                  label: tr('deposit.term'),
                  value: offer.term,
                  isGreen: false,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildInfoBlock(
                  context: context,
                  icon: Icons.account_balance_wallet_outlined,
                  label: tr('deposit.amount'),
                  value: offer.amount,
                  isGreen: false,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  tr('deposit.advantages_count', namedArgs: {'count': '3'}),
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.titleLarge?.color ?? const Color(0xFF111827),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Theme.of(context).textTheme.bodyMedium?.color ?? const Color(0xFF6B7280),
                  size: 20.sp,
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            height: 46.h,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                tr('deposit.open_deposit'),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBlock({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required bool isGreen,
  }) {
    final bgColor = isGreen 
        ? const Color(0xFFECFDF5) 
        : Theme.of(context).scaffoldBackgroundColor;
    final iconColor = isGreen
        ? const Color(0xFF10B981)
        : const Color(0xFF6B7280);
    final valueColor = isGreen
        ? const Color(0xFF10B981)
        : Theme.of(context).textTheme.titleLarge?.color ?? const Color(0xFF111827);

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: iconColor, size: 18.sp),
              SizedBox(height: 8.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Theme.of(context).textTheme.bodyMedium?.color ?? const Color(0xFF6B7280),
                  fontWeight: FontWeight.w400,
                ),
              ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 12.sp,
              color: valueColor,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
