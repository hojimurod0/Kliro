import 'package:dio/dio.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/dio/singletons/service_locator.dart';
import 'data/data_source/travel_api.dart';
import 'data/repository/travel_repository_impl.dart';
import 'domain/repositories/travel_repository.dart';
import 'domain/usecases/calc_travel.dart';
import 'domain/usecases/check_travel_status.dart';
import 'domain/usecases/create_travel_policy.dart';
import 'presentation/logic/bloc/travel_bloc.dart';
import 'presentation/screens/travel_persons_screen.dart';

@RoutePage(name: 'TravelModuleRoute')
class TravelModule extends StatelessWidget {
  const TravelModule({super.key});

  @override
  Widget build(BuildContext context) {
    final dio = ServiceLocator.resolve<Dio>();
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<TravelRepository>(
          create: (_) => TravelRepositoryImpl(TravelApi(dio)),
        ),
        RepositoryProvider<CalcTravel>(
          create: (context) => CalcTravel(context.read<TravelRepository>()),
        ),
        RepositoryProvider<CreateTravelPolicy>(
          create: (context) =>
              CreateTravelPolicy(context.read<TravelRepository>()),
        ),
        RepositoryProvider<CheckTravelStatus>(
          create: (context) =>
              CheckTravelStatus(context.read<TravelRepository>()),
        ),
      ],
      child: BlocProvider(
        create: (context) => TravelBloc(
          calcTravel: context.read<CalcTravel>(),
          createTravelPolicy: context.read<CreateTravelPolicy>(),
          checkTravelStatus: context.read<CheckTravelStatus>(),
          repository: context.read<TravelRepository>(),
        ),
        child: const TravelPersonsScreen(),
      ),
    );
  }
}

