import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'data/repositories/hotel_repository_impl.dart';
import '../../core/network/hotel/hotel_dio_client.dart';
import '../../core/services/auth/auth_service.dart';
import 'domain/repositories/hotel_repository.dart';
import 'presentation/bloc/hotel_bloc.dart';
import 'presentation/screens/hotel_search_screen.dart';

@RoutePage(name: 'HotelModuleRoute')
class HotelModule extends StatelessWidget {
  const HotelModule({super.key});

  @override
  Widget build(BuildContext context) {
    // Используем AuthService для автоматического получения токена
    final authService = AuthService.instance;

    // Создаем HotelDioClient с AuthService для автоматического получения токена
    final hotelDioClient = HotelDioClient(authService: authService);
    
    final repository = HotelRepositoryImpl(
      dioClient: hotelDioClient,
    );

    return RepositoryProvider<HotelRepository>(
      create: (_) => repository,
      child: BlocProvider<HotelBloc>(
        create: (context) => HotelBloc(
          repository: context.read<HotelRepository>(),
        ),
        child: const HotelSearchScreen(),
      ),
    );
  }
}

