import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/dio/singletons/service_locator.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/navigation/app_router.dart';
import '../bloc/avia_bloc.dart';
import '../bloc/avia_orders_cubit.dart';
import '../../data/datasources/avia_orders_local_data_source.dart';
import '../../domain/repositories/avichiptalar_repository.dart';
import '../../data/models/login_request_model.dart';

@RoutePage(name: 'AviaMyOrdersRoute')
class AviaMyOrdersPage extends StatefulWidget {
  const AviaMyOrdersPage({super.key});

  @override
  State<AviaMyOrdersPage> createState() => _AviaMyOrdersPageState();
}

class _AviaMyOrdersPageState extends State<AviaMyOrdersPage> {
  late AviaBloc _aviaBloc;
  late AviaOrdersCubit _ordersCubit;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _scheduleFromController = TextEditingController();
  final TextEditingController _scheduleToController = TextEditingController();
  final TextEditingController _scheduleAirportController = TextEditingController();
  bool _isLoadingLogin = false;
  bool _isLoadingBalance = false;
  bool _isLoadingSchedule = false;
  bool _isLoadingVisaTypes = false;
  bool _isLoadingServiceClasses = false;
  bool _isLoadingPassengerTypes = false;
  bool _isLoadingHealth = false;

  @override
  void initState() {
    super.initState();
    _aviaBloc = ServiceLocator.resolve<AviaBloc>();
    final prefs = ServiceLocator.resolve<SharedPreferences>();
    final local = AviaOrdersLocalDataSource(prefs);
    _ordersCubit = AviaOrdersCubit(
      repository: ServiceLocator.resolve<AvichiptalarRepository>(),
      local: local,
    )..load();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _scheduleFromController.dispose();
    _scheduleToController.dispose();
    _scheduleAirportController.dispose();
    _aviaBloc.close();
    _ordersCubit.close();
    super.dispose();
  }

  void _openOrder(AviaOrderItem item) {
    final bookingId = item.ref.bookingId;
    final status = (item.booking?.status ?? 'pending').toString();
    context.router.push(StatusRoute(bookingId: bookingId, status: status));
  }

  Widget _buildOrdersSection(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<AviaOrdersCubit, AviaOrdersState>(
      bloc: _ordersCubit,
      builder: (context, state) {
        if (state is AviaOrdersLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is AviaOrdersFailure) {
          return Card(
            color: theme.cardColor,
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    state.message,
                    style: TextStyle(
                      color: theme.colorScheme.error,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12.h),
                  ElevatedButton(
                    onPressed: () => _ordersCubit.load(),
                    child: const Text('Qayta yuklash'),
                  ),
                ],
              ),
            ),
          );
        }

        final items =
            state is AviaOrdersLoaded ? state.items : const <AviaOrderItem>[];

        if (items.isEmpty) {
          return Card(
            color: theme.cardColor,
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.airplane_ticket_outlined,
                    size: 64.sp,
                    color: theme.iconTheme.color?.withOpacity(0.6) ??
                        AppColors.grayText,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'avia.orders.empty_title'.tr(),
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7) ??
                          AppColors.grayText,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'avia.orders.empty_subtitle'.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6) ??
                          AppColors.grayText,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Card(
          color: theme.cardColor,
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Mening buyurtmalarim',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.titleLarge?.color,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Yangilash',
                      onPressed: () => _ordersCubit.load(),
                      icon: const Icon(Icons.refresh),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (v) async {
                        if (v == 'clear') {
                          await _ordersCubit.clear();
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 'clear', child: Text('Tozalash')),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => SizedBox(height: 8.h),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final b = item.booking;
                    final status = (b?.status ?? '...').toString();
                    final price = b?.price;
                    final currency = b?.currency;

                    final subtitle = item.error != null
                        ? 'Xatolik: ${item.error}'
                        : [
                            'Status: $status',
                            if (price != null && price.isNotEmpty)
                              'Narx: $price ${currency ?? ''}'.trim(),
                          ].join(' • ');

                    final Color statusColor;
                    final s = status.toLowerCase();
                    if (['paid', 'success', 'confirmed', 'ticketed'].contains(s)) {
                      statusColor = Colors.green;
                    } else if (['failed', 'canceled', 'cancelled'].contains(s)) {
                      statusColor = theme.colorScheme.error;
                    } else {
                      statusColor =
                          isDark ? AppColors.grayText : AppColors.bodyText;
                    }

                    return ListTile(
                      onTap: () => _openOrder(item),
                      title: Text(
                        item.ref.bookingId,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      subtitle: Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: statusColor.withOpacity(0.9),
                        ),
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (v) async {
                          if (v == 'open') {
                            _openOrder(item);
                          } else if (v == 'remove') {
                            await _ordersCubit.remove(item.ref.bookingId);
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(value: 'open', child: Text('Ochish')),
                          PopupMenuItem(
                            value: 'remove',
                            child: Text('Ro\'yxatdan olib tashlash'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleLogin() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      SnackbarHelper.showError(context, 'Email va parol kiritilishi kerak');
      return;
    }

    setState(() {
      _isLoadingLogin = true;
    });

    _aviaBloc.add(
      LoginRequested(
        LoginRequestModel(
          email: email,
          password: password,
          accessType: 'avia',
        ),
      ),
    );
  }

  void _handleCheckBalance() {
    setState(() {
      _isLoadingBalance = true;
    });
    _aviaBloc.add(CheckBalanceRequested());
  }

  void _handleGetSchedule() {
    final from = _scheduleFromController.text.trim();
    final to = _scheduleToController.text.trim();
    final airport = _scheduleAirportController.text.trim();

    if (from.isEmpty || to.isEmpty || airport.isEmpty) {
      SnackbarHelper.showError(context, 'Barcha maydonlar to\'ldirilishi kerak');
      return;
    }

    setState(() {
      _isLoadingSchedule = true;
    });
    _aviaBloc.add(ScheduleRequested(
      departureFrom: from,
      departureTo: to,
      airportFrom: airport,
    ));
  }

  void _handleGetVisaTypes() {
    setState(() {
      _isLoadingVisaTypes = true;
    });
    _aviaBloc.add(VisaTypesRequested(['UZ', 'TR']));
  }

  void _handleGetServiceClasses() {
    setState(() {
      _isLoadingServiceClasses = true;
    });
    _aviaBloc.add(ServiceClassesRequested());
  }

  void _handleGetPassengerTypes() {
    setState(() {
      _isLoadingPassengerTypes = true;
    });
    _aviaBloc.add(PassengerTypesRequested());
  }

  void _handleGetHealth() {
    setState(() {
      _isLoadingHealth = true;
    });
    _aviaBloc.add(HealthRequested());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('avia.orders.title'.tr()),
        centerTitle: true,
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
      ),
      body: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: _aviaBloc),
          BlocProvider.value(value: _ordersCubit),
        ],
        child: MultiBlocListener(
          listeners: [
            BlocListener<AviaBloc, AviaState>(
              listener: (context, state) {
                if (state is AviaLoginSuccess) {
                  setState(() {
                    _isLoadingLogin = false;
                  });
                  SnackbarHelper.showSuccess(context, 'Muvaffaqiyatli kirildi');
                } else if (state is AviaLoginFailure) {
                  setState(() {
                    _isLoadingLogin = false;
                  });
                  SnackbarHelper.showError(context, state.message);
                } else if (state is AviaBalanceSuccess) {
                  setState(() {
                    _isLoadingBalance = false;
                  });
                  showDialog(
                    context: context,
                    builder: (context) {
                      final dialogTheme = Theme.of(context);
                      final isDialogDark = dialogTheme.brightness == Brightness.dark;
                      return AlertDialog(
                        backgroundColor: isDialogDark ? AppColors.darkCardBg : AppColors.white,
                        title: Text(
                          'avia.orders.balance'.tr(),
                          style: TextStyle(
                            color: isDialogDark ? AppColors.white : AppColors.black,
                          ),
                        ),
                        content: Text(
                          '${state.response.balance ?? 0} ${state.response.currency ?? ''}',
                          style: TextStyle(
                            color: isDialogDark ? AppColors.white : AppColors.black,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'common.close'.tr(),
                              style: TextStyle(color: AppColors.primaryBlue),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                } else if (state is AviaBalanceFailure) {
                  setState(() {
                    _isLoadingBalance = false;
                  });
                  SnackbarHelper.showError(context, state.message);
                } else if (state is AviaScheduleSuccess) {
                  setState(() {
                    _isLoadingSchedule = false;
                  });
                  _showScheduleDialog(context, state.schedules);
                } else if (state is AviaScheduleFailure) {
                  setState(() {
                    _isLoadingSchedule = false;
                  });
                  SnackbarHelper.showError(context, state.message);
                } else if (state is AviaVisaTypesSuccess) {
                  setState(() {
                    _isLoadingVisaTypes = false;
                  });
                  _showVisaTypesDialog(context, state.visaTypes);
                } else if (state is AviaVisaTypesFailure) {
                  setState(() {
                    _isLoadingVisaTypes = false;
                  });
                  SnackbarHelper.showError(context, state.message);
                } else if (state is AviaServiceClassesSuccess) {
                  setState(() {
                    _isLoadingServiceClasses = false;
                  });
                  _showServiceClassesDialog(context, state.serviceClasses);
                } else if (state is AviaServiceClassesFailure) {
                  setState(() {
                    _isLoadingServiceClasses = false;
                  });
                  SnackbarHelper.showError(context, state.message);
                } else if (state is AviaPassengerTypesSuccess) {
                  setState(() {
                    _isLoadingPassengerTypes = false;
                  });
                  _showPassengerTypesDialog(context, state.passengerTypes);
                } else if (state is AviaPassengerTypesFailure) {
                  setState(() {
                    _isLoadingPassengerTypes = false;
                  });
                  SnackbarHelper.showError(context, state.message);
                } else if (state is AviaHealthSuccess) {
                  setState(() {
                    _isLoadingHealth = false;
                  });
                  _showHealthDialog(context, state.health);
                } else if (state is AviaHealthFailure) {
                  setState(() {
                    _isLoadingHealth = false;
                  });
                  SnackbarHelper.showError(context, state.message);
                }
              },
            ),
          ],
          child: BlocBuilder<AviaBloc, AviaState>(
            builder: (context, state) {
              return SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Real orders list (local + fetch booking details)
                    _buildOrdersSection(context),
                    SizedBox(height: 16.h),
                    // Login Section
                    Card(
                      color: theme.cardColor,
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'avia.orders.login_title'.tr(),
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: theme.textTheme.titleLarge?.color,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            TextField(
                              controller: _emailController,
                              style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                              decoration: InputDecoration(
                                labelText: 'auth.field.email_label'.tr(),
                                labelStyle: TextStyle(color: theme.textTheme.bodySmall?.color),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: theme.dividerColor),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: theme.dividerColor),
                                ),
                                filled: true,
                                fillColor: isDark ? AppColors.darkCardBg : AppColors.white,
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            SizedBox(height: 12.h),
                            TextField(
                              controller: _passwordController,
                              style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                              decoration: InputDecoration(
                                labelText: 'auth.field.password_label'.tr(),
                                labelStyle: TextStyle(color: theme.textTheme.bodySmall?.color),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: theme.dividerColor),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: theme.dividerColor),
                                ),
                                filled: true,
                                fillColor: isDark ? AppColors.darkCardBg : AppColors.white,
                              ),
                              obscureText: true,
                            ),
                            SizedBox(height: 16.h),
                            ElevatedButton(
                              onPressed: _isLoadingLogin ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                foregroundColor: AppColors.white,
                              ),
                              child: _isLoadingLogin
                                  ? SizedBox(
                                      width: 20.w,
                                      height: 20.h,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                                      ),
                                    )
                                  : Text('auth.login.title'.tr()),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    // Check Balance Section
                    Card(
                      color: theme.cardColor,
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'avia.orders.check_balance'.tr(),
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: theme.textTheme.titleLarge?.color,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            ElevatedButton(
                              onPressed: _isLoadingBalance
                                  ? null
                                  : _handleCheckBalance,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                foregroundColor: AppColors.white,
                              ),
                              child: _isLoadingBalance
                                  ? SizedBox(
                                      width: 20.w,
                                      height: 20.h,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                                      ),
                                    )
                                  : Text('avia.orders.check_balance'.tr()),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    // Schedule Section
                    Card(
                      color: theme.cardColor,
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'avia.orders.schedule_title'.tr(),
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: theme.textTheme.titleLarge?.color,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            TextField(
                              controller: _scheduleFromController,
                              style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                              decoration: InputDecoration(
                                labelText: 'avia.orders.schedule_from'.tr(),
                                labelStyle: TextStyle(color: theme.textTheme.bodySmall?.color),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: theme.dividerColor),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: theme.dividerColor),
                                ),
                                filled: true,
                                fillColor: isDark ? AppColors.darkCardBg : AppColors.white,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            TextField(
                              controller: _scheduleToController,
                              style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                              decoration: InputDecoration(
                                labelText: 'avia.orders.schedule_to'.tr(),
                                labelStyle: TextStyle(color: theme.textTheme.bodySmall?.color),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: theme.dividerColor),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: theme.dividerColor),
                                ),
                                filled: true,
                                fillColor: isDark ? AppColors.darkCardBg : AppColors.white,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            TextField(
                              controller: _scheduleAirportController,
                              style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                              decoration: InputDecoration(
                                labelText: 'avia.orders.airport_code'.tr(),
                                labelStyle: TextStyle(color: theme.textTheme.bodySmall?.color),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: theme.dividerColor),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: theme.dividerColor),
                                ),
                                filled: true,
                                fillColor: isDark ? AppColors.darkCardBg : AppColors.white,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            ElevatedButton(
                              onPressed: _isLoadingSchedule
                                  ? null
                                  : _handleGetSchedule,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                foregroundColor: AppColors.white,
                              ),
                              child: _isLoadingSchedule
                                  ? SizedBox(
                                      width: 20.w,
                                      height: 20.h,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                                      ),
                                    )
                                  : Text('avia.orders.get_schedule'.tr()),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    // Additional APIs Section
                    Card(
                      color: theme.cardColor,
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'avia.orders.additional_apis'.tr(),
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: theme.textTheme.titleLarge?.color,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            ElevatedButton(
                              onPressed: _isLoadingVisaTypes
                                  ? null
                                  : _handleGetVisaTypes,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                foregroundColor: AppColors.white,
                              ),
                              child: _isLoadingVisaTypes
                                  ? SizedBox(
                                      width: 20.w,
                                      height: 20.h,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                                      ),
                                    )
                                  : Text('avia.orders.visa_types'.tr()),
                            ),
                            SizedBox(height: 12.h),
                            ElevatedButton(
                              onPressed: _isLoadingServiceClasses
                                  ? null
                                  : _handleGetServiceClasses,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                foregroundColor: AppColors.white,
                              ),
                              child: _isLoadingServiceClasses
                                  ? SizedBox(
                                      width: 20.w,
                                      height: 20.h,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                                      ),
                                    )
                                  : Text('avia.orders.service_classes'.tr()),
                            ),
                            SizedBox(height: 12.h),
                            ElevatedButton(
                              onPressed: _isLoadingPassengerTypes
                                  ? null
                                  : _handleGetPassengerTypes,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                foregroundColor: AppColors.white,
                              ),
                              child: _isLoadingPassengerTypes
                                  ? SizedBox(
                                      width: 20.w,
                                      height: 20.h,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                                      ),
                                    )
                                  : Text('avia.orders.passenger_types'.tr()),
                            ),
                            SizedBox(height: 12.h),
                            ElevatedButton(
                              onPressed: _isLoadingHealth
                                  ? null
                                  : _handleGetHealth,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                foregroundColor: AppColors.white,
                              ),
                              child: _isLoadingHealth
                                  ? SizedBox(
                                      width: 20.w,
                                      height: 20.h,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                                      ),
                                    )
                                  : Text('avia.orders.health_check'.tr()),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showScheduleDialog(BuildContext context, List<dynamic> schedules) {
    final dialogTheme = Theme.of(context);
    final isDialogDark = dialogTheme.brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDialogDark ? AppColors.darkCardBg : AppColors.white,
        title: Text(
          'avia.orders.schedule_title'.tr(),
          style: TextStyle(
            color: isDialogDark ? AppColors.white : AppColors.black,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: schedules.length,
            itemBuilder: (context, index) {
              final schedule = schedules[index];
              return ListTile(
                title: Text(
                  schedule.flightNumber ?? '',
                  style: TextStyle(
                    color: isDialogDark ? AppColors.white : AppColors.black,
                  ),
                ),
                subtitle: Text(
                  '${schedule.departureAirport} - ${schedule.arrivalAirport}',
                  style: TextStyle(
                    color: isDialogDark ? AppColors.grayText : AppColors.bodyText,
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'common.close'.tr(),
              style: TextStyle(color: AppColors.primaryBlue),
            ),
          ),
        ],
      ),
    );
  }

  void _showVisaTypesDialog(BuildContext context, List<dynamic> visaTypes) {
    final dialogTheme = Theme.of(context);
    final isDialogDark = dialogTheme.brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDialogDark ? AppColors.darkCardBg : AppColors.white,
        title: Text(
          'avia.orders.visa_types'.tr(),
          style: TextStyle(
            color: isDialogDark ? AppColors.white : AppColors.black,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: visaTypes.length,
            itemBuilder: (context, index) {
              final visa = visaTypes[index];
              return ListTile(
                title: Text(
                  visa.name ?? '',
                  style: TextStyle(
                    color: isDialogDark ? AppColors.white : AppColors.black,
                  ),
                ),
                subtitle: Text(
                  visa.description ?? '',
                  style: TextStyle(
                    color: isDialogDark ? AppColors.grayText : AppColors.bodyText,
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'common.close'.tr(),
              style: TextStyle(color: AppColors.primaryBlue),
            ),
          ),
        ],
      ),
    );
  }

  void _showServiceClassesDialog(
      BuildContext context, List<dynamic> serviceClasses) {
    final dialogTheme = Theme.of(context);
    final isDialogDark = dialogTheme.brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDialogDark ? AppColors.darkCardBg : AppColors.white,
        title: Text(
          'avia.orders.service_classes'.tr(),
          style: TextStyle(
            color: isDialogDark ? AppColors.white : AppColors.black,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: serviceClasses.length,
            itemBuilder: (context, index) {
              final serviceClass = serviceClasses[index];
              return ListTile(
                title: Text(
                  serviceClass.code ?? '',
                  style: TextStyle(
                    color: isDialogDark ? AppColors.white : AppColors.black,
                  ),
                ),
                subtitle: Text(
                  serviceClass.name ?? '',
                  style: TextStyle(
                    color: isDialogDark ? AppColors.grayText : AppColors.bodyText,
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'common.close'.tr(),
              style: TextStyle(color: AppColors.primaryBlue),
            ),
          ),
        ],
      ),
    );
  }

  void _showPassengerTypesDialog(
      BuildContext context, List<dynamic> passengerTypes) {
    final dialogTheme = Theme.of(context);
    final isDialogDark = dialogTheme.brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDialogDark ? AppColors.darkCardBg : AppColors.white,
        title: Text(
          'avia.orders.passenger_types'.tr(),
          style: TextStyle(
            color: isDialogDark ? AppColors.white : AppColors.black,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: passengerTypes.length,
            itemBuilder: (context, index) {
              final passengerType = passengerTypes[index];
              return ListTile(
                title: Text(
                  passengerType.code ?? '',
                  style: TextStyle(
                    color: isDialogDark ? AppColors.white : AppColors.black,
                  ),
                ),
                subtitle: Text(
                  passengerType.name ?? '',
                  style: TextStyle(
                    color: isDialogDark ? AppColors.grayText : AppColors.bodyText,
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'common.close'.tr(),
              style: TextStyle(color: AppColors.primaryBlue),
            ),
          ),
        ],
      ),
    );
  }

  void _showHealthDialog(BuildContext context, dynamic health) {
    final dialogTheme = Theme.of(context);
    final isDialogDark = dialogTheme.brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDialogDark ? AppColors.darkCardBg : AppColors.white,
        title: Text(
          'avia.orders.health_check'.tr(),
          style: TextStyle(
            color: isDialogDark ? AppColors.white : AppColors.black,
          ),
        ),
        content: Text(
          health.status ?? 'common.unknown'.tr(),
          style: TextStyle(
            color: isDialogDark ? AppColors.white : AppColors.black,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'common.close'.tr(),
              style: TextStyle(color: AppColors.primaryBlue),
            ),
          ),
        ],
      ),
    );
  }
}
