import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/navigation/app_router.dart';
import '../../data/datasources/insurance_local_data_source.dart';
import '../../data/repositories/insurance_repository_impl.dart';
import '../../domain/entities/insurance_service.dart';
import '../../domain/usecases/get_insurance_services.dart';

@RoutePage()
class InsuranceServicesPage extends StatefulWidget {
  const InsuranceServicesPage({super.key});

  @override
  State<InsuranceServicesPage> createState() => _InsuranceServicesPageState();
}

class _InsuranceServicesPageState extends State<InsuranceServicesPage> {
  late final GetInsuranceServices _getInsuranceServices;
  List<InsuranceService> _services = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getInsuranceServices = GetInsuranceServices(
      InsuranceRepositoryImpl(
        localDataSource: const InsuranceLocalDataSource(),
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadServices();
    });
  }

  Future<void> _loadServices() async {
    if (!mounted) return;

    try {
      final services = await _getInsuranceServices();
      if (mounted) {
        setState(() {
          _services = services;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'common.error_occurred'.tr().replaceAll('{0}', e.toString()),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? const Color(0xFF121212)
        : const Color(0xFFF5F7FA);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        toolbarHeight: 60.h,
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 60.w,
        leading: Container(
          margin: EdgeInsets.only(left: 16.w, top: 8.h, bottom: 8.h),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark ? Colors.white24 : const Color(0xFFE0E0E0),
              width: 1,
            ),
          ),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back,
              size: 20.sp,
              color:
                  Theme.of(context).iconTheme.color ??
                  (isDark ? Colors.white : const Color(0xFF333333)),
            ),
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          tr('insurance.title'),
          style: TextStyle(
            color:
                Theme.of(context).textTheme.titleLarge?.color ??
                (isDark ? Colors.white : const Color(0xFF333333)),
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              itemCount: _services.length,
              separatorBuilder: (context, index) => SizedBox(height: 16.h),
              itemBuilder: (context, index) {
                return InsuranceCard(service: _services[index]);
              },
            ),
    );
  }
}

class InsuranceCard extends StatelessWidget {
  const InsuranceCard({super.key, required this.service});

  final InsuranceService service;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? Colors.transparent : const Color(0xFFEEEEEE),
          width: 1,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: const Color(0xFF000000).withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, isDark),
          SizedBox(height: 12.h),
          Text(
            service.description,
            style: TextStyle(
              fontSize: 13.sp,
              color: isDark ? Colors.grey[400] : const Color(0xFF666666),
              height: 1.4,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 16.h),
          _buildFeaturesList(context, isDark),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton(
              onPressed: () {
                // OSAGO, KASKO va Travel uchun navigatsiya
                if (service.id == 'osago') {
                  context.router.push(const OsagoModuleRoute());
                } else if (service.id == 'kasko') {
                  context.router.push(const KaskoModuleRoute());
                } else if (service.id == 'travel') {
                  context.router.push(const TravelModuleRoute());
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: service.primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                padding: EdgeInsets.zero,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    service.buttonText,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(Icons.arrow_forward_ios_rounded, size: 14.sp),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: service.lightColor,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: service.imagePath != null
                    ? Image.asset(
                        service.imagePath!,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            service.iconData,
                            color: service.primaryColor,
                            size: 24.sp,
                          );
                        },
                      )
                    : Icon(
                        service.iconData,
                        color: service.primaryColor,
                        size: 24.sp,
                      ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.title.toUpperCase(),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF222222),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      service.subtitle,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: service.primaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (service.tag != null)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: const Color(0xFFFFA726),
              borderRadius: BorderRadius.circular(6.r),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFA726).withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, color: Colors.white, size: 12.sp),
                SizedBox(width: 4.w),
                Text(
                  service.tag!,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildFeaturesList(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: service.features.map((feature) {
          return Padding(
            padding: EdgeInsets.only(bottom: 6.h),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  size: 18.sp,
                  color: service.primaryColor,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    feature,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: isDark
                          ? Colors.grey[300]
                          : const Color(0xFF555555),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
