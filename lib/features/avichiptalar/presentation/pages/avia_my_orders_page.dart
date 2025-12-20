import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/dio/singletons/service_locator.dart';
import '../bloc/avia_bloc.dart';

@RoutePage(name: 'AviaMyOrdersRoute')
class AviaMyOrdersPage extends StatefulWidget {
  const AviaMyOrdersPage({super.key});

  @override
  State<AviaMyOrdersPage> createState() => _AviaMyOrdersPageState();
}

class _AviaMyOrdersPageState extends State<AviaMyOrdersPage> {
  late AviaBloc _aviaBloc;

  @override
  void initState() {
    super.initState();
    _aviaBloc = ServiceLocator.resolve<AviaBloc>();
    _loadOrders();
  }

  void _loadOrders() {
    // API da ro'yxatni olish metodi hozircha yo'q, lekin biz booking info orqali olishimiz mumkin
    // Yoki vaqtincha local storage dan o'qish mumkin.
    // Hozirgi API da faqat bitta booking olish bor (getBooking).
    // Shuning uchun bu yerda faqat UI skeletini qilaman, keyinroq API ga bog'laymiz.
  }

  @override
  void dispose() {
    _aviaBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('avia.orders.title'.tr()),
        centerTitle: true,
      ),
      body: BlocProvider.value(
        value: _aviaBloc,
        child: BlocBuilder<AviaBloc, AviaState>(
          builder: (context, state) {
            // Hozircha bo'sh holat, chunki API da ro'yxat olish yo'q
            // Loyiha talabiga ko'ra bu yerga keyinroq API ulanadi
            return Center(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.airplane_ticket_outlined,
                      size: 64.sp,
                      color: theme.iconTheme.color?.withValues(alpha: 0.6) ??
                          Colors.grey,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'avia.orders.empty_title'.tr(),
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyLarge?.color
                                ?.withValues(alpha: 0.7) ??
                            Colors.grey,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'avia.orders.empty_subtitle'.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: theme.textTheme.bodyMedium?.color
                                ?.withValues(alpha: 0.6) ??
                            Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
