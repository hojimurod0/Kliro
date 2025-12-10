import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/dio/singletons/service_locator.dart';
import 'presentation/bloc/accident_bloc.dart';
import 'presentation/pages/insurance_form_page.dart';

@RoutePage(name: 'AccidentModuleRoute')
class AccidentModule extends StatelessWidget {
  const AccidentModule({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: ServiceLocator.resolve<AccidentBloc>(),
      child: const InsuranceFormPage(),
    );
  }
}

