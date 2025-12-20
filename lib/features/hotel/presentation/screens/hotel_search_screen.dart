import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/hotel_bloc.dart';
import '../pages/hotel_search_page.dart';
import 'hotel_results_screen.dart';

class HotelSearchScreen extends StatelessWidget {
  const HotelSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<HotelBloc, HotelState>(
      listener: (context, state) {
        if (state is HotelSearchSuccess) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<HotelBloc>(),
                child: const HotelResultsScreen(),
              ),
            ),
          );
        }
      },
      child: BlocBuilder<HotelBloc, HotelState>(
        builder: (context, state) {
          if (state is HotelSearchLoading) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (state is HotelSearchFailure) {
            return Scaffold(
              appBar: AppBar(title: Text('hotel.common.error'.tr())),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.message,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<HotelBloc>().add(const HotelStateReset());
                      },
                      child: Text('hotel.common.retry'.tr()),
                    ),
                  ],
                ),
              ),
            );
          }

          return const HotelSearchPage();
        },
      ),
    );
  }
}

