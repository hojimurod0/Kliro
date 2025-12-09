import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
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
        // Og'ir ishlarni microtask'ga ko'chiramiz
        Future.microtask(() => bloc.add(const FetchCars()));
        return bloc;
      },
      child: Scaffold(
        backgroundColor: scaffoldBg,
        appBar: AppBar(
          backgroundColor: cardBg,
          elevation: 0.5,
          title: Text(
            'KASKO - Avtomobillar',
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
                          context.read<KaskoBloc>().add(const FetchCars());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.kaskoPrimaryBlue,
                          padding: EdgeInsets.symmetric(
                            horizontal: 32.w,
                            vertical: 12.h,
                          ),
                        ),
                        child: Text(
                          'Qayta urinib ko\'ring',
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
                          'Avtomobillar topilmadi',
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
                                'Marka: ${car.brand}',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: subtitleColor,
                                ),
                              ),
                            ),
                          if (car.model != null)
                            Text(
                              'Model: ${car.model}',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: subtitleColor,
                              ),
                            ),
                          if (car.year != null)
                            Text(
                              'Yil: ${car.year}',
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
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

