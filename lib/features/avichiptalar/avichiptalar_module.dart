import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/dio/singletons/service_locator.dart';
import 'presentation/bloc/avia_bloc.dart';
import 'presentation/screens/flight_search_screen.dart';

/// Aviachiptalar moduli
/// ServiceLocator dan dependencylarni oladi
@RoutePage(name: 'AvichiptalarModuleRoute')
class AvichiptalarModule extends StatelessWidget {
  const AvichiptalarModule({super.key});

  @override
  Widget build(BuildContext context) {
    // ServiceLocator dan dependencylarni olish
    // Bu yagona DI source bo'ladi
    return BlocProvider<AviaBloc>(
      create: (_) => ServiceLocator.resolve<AviaBloc>(),
      child: const FlightSearchScreen(),
    );
  }
}
