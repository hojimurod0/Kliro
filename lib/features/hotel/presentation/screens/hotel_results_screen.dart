import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/hotel_bloc.dart';
import '../../domain/entities/hotel_filter.dart';
import '../pages/hotel_results_page.dart';

class HotelResultsScreen extends StatelessWidget {
  const HotelResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HotelBloc, HotelState>(
      buildWhen: (previous, current) {
        // Rebuild only on search states to avoid wiping UI when other hotel states emit (photos, room types, etc.)
        return current is HotelSearchLoading ||
            current is HotelSearchFailure ||
            current is HotelSearchSuccess;
      },
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
                  ElevatedButton.icon(
                    onPressed: () {
                      // Retry last search
                      final bloc = context.read<HotelBloc>();
                      final lastFilter = state.filter;
                      if (lastFilter != null) {
                        bloc.add(SearchHotelsRequested(lastFilter));
                      } else {
                        bloc.add(const HotelStateReset());
                      }
                    },
                    icon: const Icon(Icons.refresh),
                    label: Text('hotel.common.retry'.tr()),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is HotelSearchSuccess) {
          final filter = state.filter ?? HotelFilter.empty;
          // Debug log qo'shamiz
          debugPrint('🔍 HotelResultsScreen: HotelSearchSuccess');
          debugPrint('🔍 Hotels count in state: ${state.result.hotels.length}');
          debugPrint('🔍 Hotels isEmpty: ${state.result.hotels.isEmpty}');
          if (state.result.hotels.isNotEmpty) {
            debugPrint('🔍 First hotel name: ${state.result.hotels.first.name}');
          }
          
          return HotelResultsPage(
            result: state.result,
            city: filter.city,
            checkInDate: filter.checkInDate,
            checkOutDate: filter.checkOutDate,
            guests: filter.guests,
            filter: filter,
          );
        }

        return Scaffold(
          body: Center(
            child: Text('hotel.common.data_not_found'.tr()),
          ),
        );
      },
    );
  }
}

