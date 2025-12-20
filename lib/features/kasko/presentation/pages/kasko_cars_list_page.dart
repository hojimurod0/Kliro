import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/car_entity.dart';
import '../bloc/kasko_bloc.dart';
import '../bloc/kasko_event.dart';
import '../bloc/kasko_state.dart';

@RoutePage()
class KaskoCarsListPage extends StatelessWidget {
  const KaskoCarsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = AppColors.getScaffoldBg(isDark);
    final cardBg = AppColors.getCardBg(isDark);
    final textColor = AppColors.getTextColor(isDark);
    final subtitleColor = AppColors.getSubtitleColor(isDark);

    return BlocProvider(
      create: (context) {
        final bloc = context.read<KaskoBloc>();
        // Pagination bilan birinchi sahifani yuklash
        Future.microtask(() => bloc.add(const FetchCarsPaginated(page: 0, size: 20)));
        return bloc;
      },
      child: Scaffold(
        backgroundColor: scaffoldBg,
        appBar: AppBar(
          backgroundColor: cardBg,
          elevation: 0.5,
          title: Text(
            'insurance.kasko.cars_list.title'.tr(),
            style: TextStyle(
              color: textColor,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          ),
        ),
        body: BlocBuilder<KaskoBloc, KaskoState>(
          builder: (context, state) {
            if (state is KaskoLoading) {
              return Center(
                child: CircularProgressIndicator(
                  color: AppColors.kaskoPrimaryBlue,
                ),
              );
            }

            if (state is KaskoError) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64.sp,
                        color: AppColors.dangerRed,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        state.message,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: textColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24.h),
                      ElevatedButton(
                        onPressed: () {
                          context.read<KaskoBloc>().add(const FetchCarsPaginated(page: 0, size: 20));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.kaskoPrimaryBlue,
                          padding: EdgeInsets.symmetric(
                            horizontal: 32.w,
                            vertical: 12.h,
                          ),
                        ),
                        child: Text(
                          'insurance.kasko.cars_list.retry'.tr(),
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Eski KaskoCarsLoaded state'ni qo'llab-quvvatlash (backward compatibility)
            if (state is KaskoCarsLoaded) {
              if (state.cars.isEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.directions_car_outlined,
                          size: 64.sp,
                          color: subtitleColor,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'insurance.kasko.cars_list.not_found'.tr(),
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: textColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.all(16.w),
                itemCount: state.cars.length,
                itemBuilder: (context, index) {
                  final car = state.cars[index];
                  return _buildCarCard(
                    car: car,
                    cardBg: cardBg,
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                    isDark: isDark,
                  );
                },
              );
            }

            // Yangi pagination state
            if (state is KaskoCarsPageLoaded) {
              if (state.cars.isEmpty && !state.isPaginating) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.directions_car_outlined,
                          size: 64.sp,
                          color: subtitleColor,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'insurance.kasko.cars_list.not_found'.tr(),
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: textColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Pull-to-refresh va infinite scroll
              return RefreshIndicator(
                onRefresh: () {
                  final completer = Completer<void>();
                  context.read<KaskoBloc>().add(
                    RefreshCarsPaginated(completer: completer),
                  );
                  return completer.future;
                },
                child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    // Scroll oxiriga yetganda keyingi sahifani yuklash
                    if (notification.metrics.pixels >=
                            notification.metrics.maxScrollExtent - 200 &&
                        state.hasMore &&
                        !state.isPaginating) {
                      context.read<KaskoBloc>().add(
                        FetchCarsPaginated(
                          page: state.pageNumber + 1,
                          size: 20,
                          append: true,
                        ),
                      );
                    }
                    return false;
                  },
                child: ListView.builder(
                  padding: EdgeInsets.all(16.w),
                  cacheExtent: 500, // Scroll performance optimizatsiyasi
                  itemCount: state.cars.length + (state.hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    // Loading indicator (oxirida)
                    if (index >= state.cars.length) {
                      return Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.kaskoPrimaryBlue,
                          ),
                        ),
                      );
                    }

                    final car = state.cars[index];
                    return _buildCarCard(
                      car: car,
                      cardBg: cardBg,
                      textColor: textColor,
                      subtitleColor: subtitleColor,
                      isDark: isDark,
                    );
                  },
                  ),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildCarCard({
    required CarEntity car,
    required Color cardBg,
    required Color textColor,
    required Color subtitleColor,
    required bool isDark,
  }) {
    return Card(
      color: cardBg,
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(
          color: AppColors.getBorderColor(isDark),
          width: 1,
        ),
      ),
      child: ListTile(
        title: Text(
          car.name,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (car.brand != null)
              Padding(
                padding: EdgeInsets.only(top: 4.h),
                child: Text(
                  '${'insurance.kasko.cars_list.brand'.tr()}: ${car.brand}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: subtitleColor,
                  ),
                ),
              ),
            if (car.model != null)
              Text(
                '${'insurance.kasko.cars_list.model'.tr()}: ${car.model}',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: subtitleColor,
                ),
              ),
            if (car.year != null)
              Text(
                '${'insurance.kasko.cars_list.year'.tr()}: ${car.year}',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: subtitleColor,
                ),
              ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16.sp,
          color: subtitleColor,
        ),
        onTap: () {
          // Navigate to car details or calculation page
        },
      ),
    );
  }
}

