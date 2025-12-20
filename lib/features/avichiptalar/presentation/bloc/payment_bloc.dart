import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/invoice_request_model.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/repositories/payment_repository.dart';

// Events
abstract class PaymentEvent extends Equatable {
  const PaymentEvent();
  @override
  List<Object?> get props => [];
}

class CreateInvoiceRequested extends PaymentEvent {
  final InvoiceRequestModel request;
  const CreateInvoiceRequested(this.request);
  @override
  List<Object?> get props => [request];
}

class CheckStatusRequested extends PaymentEvent {
  final String uuid;
  const CheckStatusRequested(this.uuid);
  @override
  List<Object?> get props => [uuid];
}

class GetInvoiceRequested extends PaymentEvent {
  final String uuid;
  const GetInvoiceRequested(this.uuid);
  @override
  List<Object?> get props => [uuid];
}

class ScanpayRequested extends PaymentEvent {
  final String uuid;
  final String code;
  const ScanpayRequested({required this.uuid, required this.code});
  @override
  List<Object?> get props => [uuid, code];
}

// States
abstract class PaymentState extends Equatable {
  const PaymentState();
  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class InvoiceCreatedSuccess extends PaymentState {
  final Invoice invoice;
  const InvoiceCreatedSuccess(this.invoice);
  @override
  List<Object?> get props => [invoice];
}

class InvoiceRetrievedSuccess extends PaymentState {
  final Invoice invoice;
  const InvoiceRetrievedSuccess(this.invoice);
  @override
  List<Object?> get props => [invoice];
}

class ScanpaySuccess extends PaymentState {
  final Invoice invoice;
  const ScanpaySuccess(this.invoice);
  @override
  List<Object?> get props => [invoice];
}

class PaymentStatusSuccess extends PaymentState {
  final String status;
  const PaymentStatusSuccess(this.status);
  @override
  List<Object?> get props => [status];
}

class PaymentFailure extends PaymentState {
  final String message;
  const PaymentFailure(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final PaymentRepository repository;

  PaymentBloc({required this.repository}) : super(PaymentInitial()) {
    on<CreateInvoiceRequested>(_onCreateInvoice);
    on<GetInvoiceRequested>(_onGetInvoice);
    on<ScanpayRequested>(_onScanpay);
    on<CheckStatusRequested>(_onCheckStatus);
  }

  Future<void> _onCreateInvoice(
    CreateInvoiceRequested event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentLoading());
    final result = await repository.createInvoice(event.request);
    result.fold(
      (failure) => emit(PaymentFailure(failure.message)),
      (invoice) => emit(InvoiceCreatedSuccess(invoice)),
    );
  }

  Future<void> _onGetInvoice(
    GetInvoiceRequested event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentLoading());
    final result = await repository.getInvoice(event.uuid);
    result.fold(
      (failure) => emit(PaymentFailure(failure.message)),
      (invoice) => emit(InvoiceRetrievedSuccess(invoice)),
    );
  }

  Future<void> _onScanpay(
    ScanpayRequested event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentLoading());
    final result = await repository.scanpay(event.uuid, event.code);
    result.fold(
      (failure) => emit(PaymentFailure(failure.message)),
      (invoice) => emit(ScanpaySuccess(invoice)),
    );
  }

  Future<void> _onCheckStatus(
    CheckStatusRequested event,
    Emitter<PaymentState> emit,
  ) async {
    // Note: status check creates heavy load if polled too frequently.
    // UI should handle the polling interval.
    final result = await repository.checkStatus(event.uuid);
    result.fold(
      (failure) => emit(PaymentFailure(failure.message)),
      (status) => emit(PaymentStatusSuccess(status)),
    );
  }
}
