import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/avia_orders_local_data_source.dart';
import '../../data/models/booking_model.dart';
import '../../domain/repositories/avichiptalar_repository.dart';

class AviaOrderItem {
  final AviaOrderRef ref;
  final BookingModel? booking;
  final String? error;

  const AviaOrderItem({
    required this.ref,
    this.booking,
    this.error,
  });

  AviaOrderItem copyWith({
    BookingModel? booking,
    String? error,
  }) {
    return AviaOrderItem(
      ref: ref,
      booking: booking ?? this.booking,
      error: error,
    );
  }
}

abstract class AviaOrdersState {
  const AviaOrdersState();
}

class AviaOrdersInitial extends AviaOrdersState {
  const AviaOrdersInitial();
}

class AviaOrdersLoading extends AviaOrdersState {
  const AviaOrdersLoading();
}

class AviaOrdersLoaded extends AviaOrdersState {
  final List<AviaOrderItem> items;

  const AviaOrdersLoaded(this.items);
}

class AviaOrdersFailure extends AviaOrdersState {
  final String message;
  const AviaOrdersFailure(this.message);
}

class AviaOrdersCubit extends Cubit<AviaOrdersState> {
  final AvichiptalarRepository _repository;
  final AviaOrdersLocalDataSource _local;

  AviaOrdersCubit({
    required AvichiptalarRepository repository,
    required AviaOrdersLocalDataSource local,
  })  : _repository = repository,
        _local = local,
        super(const AviaOrdersInitial());

  Future<void> load() async {
    emit(const AviaOrdersLoading());
    try {
      final refs = _local.getOrders();
      if (refs.isEmpty) {
        emit(const AviaOrdersLoaded([]));
        return;
      }

      final baseItems = refs.map((r) => AviaOrderItem(ref: r)).toList();
      emit(AviaOrdersLoaded(baseItems));

      // Fetch details in parallel, but keep UI responsive.
      final futures = refs.map((r) async {
        final res = await _repository.getBooking(r.bookingId);
        return res.fold(
          (failure) => AviaOrderItem(ref: r, booking: null, error: failure.message),
          (booking) => AviaOrderItem(ref: r, booking: booking, error: null),
        );
      }).toList();

      final loaded = await Future.wait(futures);
      // Keep order (refs are already sorted newest first)
      emit(AviaOrdersLoaded(loaded));
    } catch (e) {
      emit(AviaOrdersFailure('Buyurtmalarni yuklashda xatolik: $e'));
    }
  }

  Future<void> remove(String bookingId) async {
    await _local.removeOrder(bookingId);
    await load();
  }

  Future<void> clear() async {
    await _local.clear();
    await load();
  }
}








