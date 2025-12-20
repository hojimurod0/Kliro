import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/invoice_request_model.dart';
import '../models/invoice_response_model.dart';

abstract class PaymentRemoteDataSource {
  Future<InvoiceResponseModel> createInvoice(InvoiceRequestModel request);
  Future<InvoiceResponseModel> getInvoice(String uuid);
  Future<InvoiceResponseModel> scanpay(String uuid, String code);
  Future<String> checkStatus(String uuid);
  Future<void> deleteInvoice(String uuid);
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final Dio client;

  PaymentRemoteDataSourceImpl(this.client);

  @override
  Future<InvoiceResponseModel> createInvoice(
      InvoiceRequestModel request) async {
    try {
      final response = await client.post(
        '/payment/invoice',
        data: request.toJson(),
      );

      return InvoiceResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Invoice yaratishda xatolik',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<InvoiceResponseModel> getInvoice(String uuid) async {
    try {
      final response = await client.get('/payment/invoice/$uuid');
      return InvoiceResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Invoice ma\'lumotlarini olishda xatolik',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<InvoiceResponseModel> scanpay(String uuid, String code) async {
    try {
      final response = await client.put(
        '/payment/$uuid/scanpay',
        data: {'code': code},
      );
      return InvoiceResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Scanpay amalga oshirishda xatolik',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<String> checkStatus(String uuid) async {
    try {
      final response = await client.get(
        '/payment/ui/status',
        queryParameters: {'uuid': uuid},
      );

      final data = response.data;
      // Handle both wrapped and unwrapped responses
      if (data is Map<String, dynamic>) {
        // Check if response has 'data' wrapper
        final statusData = data.containsKey('data') ? data['data'] : data;
        if (statusData is Map<String, dynamic>) {
          return statusData['status'] ?? 'unknown';
        }
        // If status is directly in the root
        return data['status'] ?? 'unknown';
      }
      return data.toString();
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Status tekshirishda xatolik',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> deleteInvoice(String uuid) async {
    try {
      await client.delete('/payment/invoice/$uuid');
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Invoice o\'chirishda xatolik',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
