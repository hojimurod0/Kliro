import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/dio/singletons/service_locator.dart';
import '../../../../core/utils/snackbar_helper.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Text('avia.orders.title'.tr()),
        centerTitle: true,
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
                    builder: (context) => AlertDialog(
                      title: Text('Balans'),
                      content: Text(
                        '${state.response.balance ?? 0} ${state.response.currency ?? ''}',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('OK'),
                        ),
                      ],
                    ),
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
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Avia Login',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            TextField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            SizedBox(height: 12.h),
                            TextField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                labelText: 'Parol',
                                border: OutlineInputBorder(),
                              ),
                              obscureText: true,
                            ),
                            SizedBox(height: 16.h),
                            ElevatedButton(
                              onPressed: _isLoadingLogin ? null : _handleLogin,
                              child: _isLoadingLogin
                                  ? SizedBox(
                                      width: 20.w,
                                      height: 20.h,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text('Kirish'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    // Check Balance Section
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Balansni tekshirish',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            ElevatedButton(
                              onPressed: _isLoadingBalance
                                  ? null
                                  : _handleCheckBalance,
                              child: _isLoadingBalance
                                  ? SizedBox(
                                      width: 20.w,
                                      height: 20.h,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text('Balansni tekshirish'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    // Schedule Section
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Reyjlar jadvali',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            TextField(
                              controller: _scheduleFromController,
                              decoration: InputDecoration(
                                labelText: 'Dan (YYYY-MM-DD)',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 12.h),
                            TextField(
                              controller: _scheduleToController,
                              decoration: InputDecoration(
                                labelText: 'Gacha (YYYY-MM-DD)',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 12.h),
                            TextField(
                              controller: _scheduleAirportController,
                              decoration: InputDecoration(
                                labelText: 'Aeroport kodi',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 16.h),
                            ElevatedButton(
                              onPressed: _isLoadingSchedule
                                  ? null
                                  : _handleGetSchedule,
                              child: _isLoadingSchedule
                                  ? SizedBox(
                                      width: 20.w,
                                      height: 20.h,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text('Jadvalni olish'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    // Additional APIs Section
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Qo\'shimcha API\'lar',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            ElevatedButton(
                              onPressed: _isLoadingVisaTypes
                                  ? null
                                  : _handleGetVisaTypes,
                              child: _isLoadingVisaTypes
                                  ? SizedBox(
                                      width: 20.w,
                                      height: 20.h,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text('Viza turlari'),
                            ),
                            SizedBox(height: 12.h),
                            ElevatedButton(
                              onPressed: _isLoadingServiceClasses
                                  ? null
                                  : _handleGetServiceClasses,
                              child: _isLoadingServiceClasses
                                  ? SizedBox(
                                      width: 20.w,
                                      height: 20.h,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text('Xizmat sinflari'),
                            ),
                            SizedBox(height: 12.h),
                            ElevatedButton(
                              onPressed: _isLoadingPassengerTypes
                                  ? null
                                  : _handleGetPassengerTypes,
                              child: _isLoadingPassengerTypes
                                  ? SizedBox(
                                      width: 20.w,
                                      height: 20.h,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text('Yo\'lovchi turlari'),
                            ),
                            SizedBox(height: 12.h),
                            ElevatedButton(
                              onPressed: _isLoadingHealth
                                  ? null
                                  : _handleGetHealth,
                              child: _isLoadingHealth
                                  ? SizedBox(
                                      width: 20.w,
                                      height: 20.h,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text('Health check'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    // Orders Section
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(24.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.airplane_ticket_outlined,
                              size: 64.sp,
                              color: theme.iconTheme.color
                                      ?.withValues(alpha: 0.6) ??
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reyjlar jadvali'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: schedules.length,
            itemBuilder: (context, index) {
              final schedule = schedules[index];
              return ListTile(
                title: Text(schedule.flightNumber ?? ''),
                subtitle: Text(
                  '${schedule.departureAirport} - ${schedule.arrivalAirport}',
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showVisaTypesDialog(BuildContext context, List<dynamic> visaTypes) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Viza turlari'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: visaTypes.length,
            itemBuilder: (context, index) {
              final visa = visaTypes[index];
              return ListTile(
                title: Text(visa.name ?? ''),
                subtitle: Text(visa.description ?? ''),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showServiceClassesDialog(
      BuildContext context, List<dynamic> serviceClasses) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xizmat sinflari'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: serviceClasses.length,
            itemBuilder: (context, index) {
              final serviceClass = serviceClasses[index];
              return ListTile(
                title: Text(serviceClass.code ?? ''),
                subtitle: Text(serviceClass.name ?? ''),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPassengerTypesDialog(
      BuildContext context, List<dynamic> passengerTypes) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Yo\'lovchi turlari'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: passengerTypes.length,
            itemBuilder: (context, index) {
              final passengerType = passengerTypes[index];
              return ListTile(
                title: Text(passengerType.code ?? ''),
                subtitle: Text(passengerType.name ?? ''),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showHealthDialog(BuildContext context, dynamic health) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Health check'),
        content: Text(health.status ?? 'Unknown'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
