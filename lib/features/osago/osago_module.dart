import 'package:dio/dio.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/dio/singletons/service_locator.dart';
import 'data/data_source/osago_api.dart';
import 'data/repository/osago_repository_impl.dart';
import 'domain/repositories/osago_repository.dart';
import 'domain/usecases/calc_osago.dart';
import 'domain/usecases/check_osago_status.dart';
import 'domain/usecases/create_osago_policy.dart';
import 'logic/bloc/osago_bloc.dart';
import 'presentation/screens/osago_vehicle_screen.dart';

@RoutePage(name: 'OsagoModuleRoute')
class OsagoModule extends StatelessWidget {
  const OsagoModule({super.key});

  @override
  Widget build(BuildContext context) {
    final dio = ServiceLocator.resolve<Dio>();
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<OsagoRepository>(
          create: (_) => OsagoRepositoryImpl(OsagoApi(dio)),
        ),
        RepositoryProvider<CalcOsago>(
          create: (context) => CalcOsago(context.read<OsagoRepository>()),
        ),
        RepositoryProvider<CreateOsagoPolicy>(
          create: (context) =>
              CreateOsagoPolicy(context.read<OsagoRepository>()),
        ),
        RepositoryProvider<CheckOsagoStatus>(
          create: (context) =>
              CheckOsagoStatus(context.read<OsagoRepository>()),
        ),
      ],
      child: BlocProvider(
        create: (context) => OsagoBloc(
          calcOsago: context.read<CalcOsago>(),
          createOsagoPolicy: context.read<CreateOsagoPolicy>(),
          checkOsagoStatus: context.read<CheckOsagoStatus>(),
        ),
        child: const OsagoVehicleScreen(),
      ),
    );
  }
}
