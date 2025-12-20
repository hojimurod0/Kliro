import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/hotel_bloc.dart';
import '../pages/hotel_details_page.dart';

class HotelDetailsScreen extends StatelessWidget {
  final String hotelId;

  const HotelDetailsScreen({
    super.key,
    required this.hotelId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HotelBloc, HotelState>(
      builder: (context, state) {
        if (state is HotelLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is HotelDetailsFailure) {
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
                      Navigator.of(context).pop();
                    },
                    child: Text('hotel.common.back'.tr()),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is HotelDetailsSuccess) {
          return HotelDetailsPage(hotel: state.hotel);
        }

        // Initial state - load hotel details
        if (state is HotelInitial) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<HotelBloc>().add(GetHotelDetailsRequested(hotelId));
          });
        }

        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}

