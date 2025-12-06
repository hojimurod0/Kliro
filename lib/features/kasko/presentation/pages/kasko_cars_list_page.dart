import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../bloc/kasko_bloc.dart';
import '../bloc/kasko_event.dart';
import '../bloc/kasko_state.dart';

@RoutePage()
class KaskoCarsListPage extends StatelessWidget {
  const KaskoCarsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = context.read<KaskoBloc>();
        // Og'ir ishlarni microtask'ga ko'chiramiz
        Future.microtask(() => bloc.add(const FetchCars()));
        return bloc;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('KASKO - Avtomobillar'),
        ),
        body: BlocBuilder<KaskoBloc, KaskoState>(
          builder: (context, state) {
            if (state is KaskoLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is KaskoError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.message,
                      style: TextStyle(fontSize: 16.sp),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () {
                        context.read<KaskoBloc>().add(const FetchCars());
                      },
                      child: const Text('Qayta urinib ko\'ring'),
                    ),
                  ],
                ),
              );
            }

            if (state is KaskoCarsLoaded) {
              if (state.cars.isEmpty) {
                return Center(
                  child: Text(
                    'Avtomobillar topilmadi',
                    style: TextStyle(fontSize: 16.sp),
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.all(16.w),
                itemCount: state.cars.length,
                itemBuilder: (context, index) {
                  final car = state.cars[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 12.h),
                    child: ListTile(
                      title: Text(
                        car.name,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (car.brand != null)
                            Text('Marka: ${car.brand}'),
                          if (car.model != null) Text('Model: ${car.model}'),
                          if (car.year != null) Text('Yil: ${car.year}'),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // Navigate to car details or calculation page
                      },
                    ),
                  );
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

