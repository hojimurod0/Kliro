import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/dio/singletons/service_locator.dart';
import 'domain/repositories/hotel_repository.dart';
import 'presentation/bloc/hotel_bloc.dart';
import 'presentation/screens/hotel_search_screen.dart';

@RoutePage(name: 'HotelModuleRoute')
class HotelModule extends StatelessWidget {
  const HotelModule({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<HotelRepository>(
      create: (_) => ServiceLocator.resolve<HotelRepository>(),
      child: BlocProvider<HotelBloc>(
        create: (_) => ServiceLocator.resolve<HotelBloc>(),
        child: const HotelSearchScreen(),
      ),
    );
  }
}

