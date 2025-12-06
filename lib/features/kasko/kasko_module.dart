import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/dio/singletons/service_locator.dart';
import 'data/datasources/kasko_remote_data_source.dart';
import 'data/repositories/kasko_repository_impl.dart';
import 'domain/repositories/kasko_repository.dart';
import 'domain/usecases/calculate_car_price.dart';
import 'domain/usecases/calculate_policy.dart';
import 'domain/usecases/check_payment_status.dart';
import 'domain/usecases/get_cars.dart';
import 'domain/usecases/get_cars_minimal.dart';
import 'domain/usecases/get_payment_link.dart';
import 'domain/usecases/get_rates.dart';
import 'domain/usecases/save_order.dart';
import 'domain/usecases/upload_image.dart';
import 'presentation/bloc/kasko_bloc.dart';
import 'presentation/pages/kasko_form_selection_page.dart';

@RoutePage(name: 'KaskoModuleRoute')
class KaskoModule extends StatelessWidget {
  const KaskoModule({super.key});

  @override
  Widget build(BuildContext context) {
    final dio = ServiceLocator.resolve<Dio>();
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<KaskoRepository>(
          create: (_) => KaskoRepositoryImpl(KaskoRemoteDataSourceImpl(dio)),
        ),
        RepositoryProvider<GetCars>(
          create: (context) => GetCars(context.read<KaskoRepository>()),
        ),
        RepositoryProvider<GetCarsMinimal>(
          create: (context) => GetCarsMinimal(context.read<KaskoRepository>()),
        ),
        RepositoryProvider<GetRates>(
          create: (context) => GetRates(context.read<KaskoRepository>()),
        ),
        RepositoryProvider<CalculateCarPrice>(
          create: (context) =>
              CalculateCarPrice(context.read<KaskoRepository>()),
        ),
        RepositoryProvider<CalculatePolicy>(
          create: (context) => CalculatePolicy(context.read<KaskoRepository>()),
        ),
        RepositoryProvider<SaveOrder>(
          create: (context) => SaveOrder(context.read<KaskoRepository>()),
        ),
        RepositoryProvider<GetPaymentLink>(
          create: (context) => GetPaymentLink(context.read<KaskoRepository>()),
        ),
        RepositoryProvider<CheckPaymentStatus>(
          create: (context) =>
              CheckPaymentStatus(context.read<KaskoRepository>()),
        ),
        RepositoryProvider<UploadImage>(
          create: (context) => UploadImage(context.read<KaskoRepository>()),
        ),
      ],
      child: BlocProvider(
        create: (context) => KaskoBloc(
          getCars: context.read<GetCars>(),
          getCarsMinimal: context.read<GetCarsMinimal>(),
          getRates: context.read<GetRates>(),
          calculateCarPrice: context.read<CalculateCarPrice>(),
          calculatePolicy: context.read<CalculatePolicy>(),
          saveOrder: context.read<SaveOrder>(),
          getPaymentLink: context.read<GetPaymentLink>(),
          checkPaymentStatus: context.read<CheckPaymentStatus>(),
          uploadImage: context.read<UploadImage>(),
        ),
        child: const KaskoFormSelectionPage(),
      ),
    );
  }
}
