import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/navigation/app_router.dart';
import '../widgets/home_banner.dart';
import '../widgets/home_header.dart';
import '../widgets/home_news_section.dart';
import '../widgets/home_services_grid.dart';
import '../widgets/main_bottom_navigation.dart';

class HomePage extends StatelessWidget {
  final ValueChanged<TabItem>? onTabChange;

  const HomePage({super.key, this.onTabChange});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 110.h),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.h),
              HomeHeader(
                onProfileTap: () => onTabChange?.call(TabItem.profile),
              ),
              SizedBox(height: 20.h),
              HomeBanner(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
                child: Column(
                  children: [
                    HomeServicesGrid(
                      onBankTap: () => context.router.push(BankServicesRoute()),
                      onInsuranceTap: () =>
                          context.router.push(InsuranceServicesRoute()),
                      onFlightsTap: () =>
                          context.router.push(AvichiptalarModuleRoute()),
                    ),
                    SizedBox(height: 16.h),
                    HomeWideServiceCard(
                      onTap: () => context.router.push(HotelModuleRoute()),
                    ),
                    SizedBox(height: 30.h),
                    const HomeNewsSection(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
