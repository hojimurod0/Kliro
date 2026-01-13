import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/dio/singletons/service_locator.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/avia_bloc.dart';
import '../../data/models/login_request_model.dart';

@RoutePage(name: 'AviaMyOrdersRoute')
class AviaMyOrdersPage extends StatefulWidget {
  const AviaMyOrdersPage({super.key});

  @override
  State<AviaMyOrdersPage> createState() => _AviaMyOrdersPageState();
}

class _AviaMyOrdersPageState extends State<AviaMyOrdersPage> {
  late AviaBloc _aviaBloc;
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
    _loadOrders();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _scheduleFromController.dispose();
    _scheduleToController.dispose();
    _scheduleAirportController.dispose();
    _aviaBloc.close();
    super.dispose();
  }

  void _loadOrders() {
    // API da ro'yxatni olish metodi hozircha yo'q, lekin biz booking info orqali olishimiz mumkin
    // Yoki vaqtincha local storage dan o'qish mumkin.
    // Hozirgi API da faqat bitta booking olish bor (getBooking).
    // Shuning uchun bu yerda faqat UI skeletini qilaman, keyinroq API ga bog'laymiz.
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
      body: BlocProvider.value(
        value: _aviaBloc,
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
                    SizedBox(height: 16.h),
                    // Orders Section
                    Card(
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
