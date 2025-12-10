import 'dart:developer';

import 'package:dio/dio.dart';

class LoggingInterceptor extends Interceptor {
  LoggingInterceptor();

  /// Juda katta JSONlarni log qilish main-isolate va IDE konsolini qotirib qo‘ymasligi
  /// uchun maksimal uzunlikni cheklaymiz.
  static const int _maxLoggedChars = 2000;

  String _buildSafePreview(Object? data) {
    if (data == null) return 'null';

    // Katta String bo‘lsa (masalan, kasko mashinalar ro‘yxati), faqat preview
    if (data is String) {
      if (data.length <= _maxLoggedChars) return data;
      return '${data.substring(0, _maxLoggedChars)}... [truncated, length=${data.length}]';
    }

    final full = data.toString();
    if (full.length <= _maxLoggedChars) return full;
    return '${full.substring(0, _maxLoggedChars)}... [truncated, length=${full.length}]';
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final dataPreview = _buildSafePreview(options.data);
    log(
      '[DIO][REQUEST] ${options.method} ${options.uri}\n'
      'Base URL: ${options.baseUrl}\n'
      'Headers: ${options.headers}\n'
      'Data: $dataPreview',
      name: 'DIO',
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final dataPreview = _buildSafePreview(response.data);
    log(
      '[DIO][RESPONSE] ${response.requestOptions.method} ${response.requestOptions.uri}\n'
      'Status: ${response.statusCode}\n'
      '✅ SUCCESS\n'
      'Data: $dataPreview',
      name: 'DIO',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // 404 xatolikni /travel/purposes endpoint uchun loglamaymiz
    // chunki bu endpoint mavjud emas va biz fallback ma'lumotlardan foydalanamiz
    if (err.response?.statusCode == 404 &&
        err.requestOptions.uri.toString().contains('/travel/purposes')) {
      // Faqat handler.next() ni chaqiramiz, loglamaymiz
      handler.next(err);
      return;
    }

    final errorDetails = StringBuffer();
    errorDetails.writeln(
      '[DIO][ERROR] ${err.requestOptions.method} ${err.requestOptions.uri}',
    );
    errorDetails.writeln(
      'Status: ${err.response?.statusCode ?? "No response"}',
    );
    errorDetails.writeln('Error Type: ${err.type}');
    errorDetails.writeln('Message: ${err.message}');

    if (err.type == DioExceptionType.receiveTimeout) {
      errorDetails.writeln(
        '⚠️ TIMEOUT: Server 60 soniya ichida javob bermadi!',
      );
      errorDetails.writeln(
        'Tekshiring: Server ishlamayaptimi? Internet aloqasi bormi?',
      );
    } else if (err.type == DioExceptionType.connectionTimeout) {
      errorDetails.writeln('⚠️ CONNECTION TIMEOUT: Serverga ulanib bo\'lmadi!');
      errorDetails.writeln(
        'Tekshiring: Server manzili to\'g\'rimi? Server ishlamayaptimi?',
      );
    } else if (err.type == DioExceptionType.connectionError) {
      errorDetails.writeln('⚠️ CONNECTION ERROR: Serverga ulanib bo\'lmadi!');
      errorDetails.writeln(
        'Tekshiring: Internet aloqasi bormi? Server ishlamayaptimi?',
      );
    }

    if (err.response?.data != null) {
      final dataPreview = _buildSafePreview(err.response?.data);
      errorDetails.writeln('Response Data: $dataPreview');
    }

    log(errorDetails.toString(), name: 'DIO');
    handler.next(err);
  }
}
