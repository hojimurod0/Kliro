import 'dart:developer';

import 'package:dio/dio.dart';

class LoggingInterceptor extends Interceptor {
  LoggingInterceptor();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    log(
      '[DIO][REQUEST] ${options.method} ${options.uri}\nBase URL: ${options.baseUrl}\nHeaders: ${options.headers}\nData: ${options.data}',
      name: 'DIO',
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    log(
      '[DIO][RESPONSE] ${response.requestOptions.method} ${response.requestOptions.uri}\nStatus: ${response.statusCode}\n✅ SUCCESS\nData: ${response.data}',
      name: 'DIO',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final errorDetails = StringBuffer();
    errorDetails.writeln('[DIO][ERROR] ${err.requestOptions.method} ${err.requestOptions.uri}');
    errorDetails.writeln('Status: ${err.response?.statusCode ?? "No response"}');
    errorDetails.writeln('Error Type: ${err.type}');
    errorDetails.writeln('Message: ${err.message}');
    
    if (err.type == DioExceptionType.receiveTimeout) {
      errorDetails.writeln('⚠️ TIMEOUT: Server 60 soniya ichida javob bermadi!');
      errorDetails.writeln('Tekshiring: Server ishlamayaptimi? Internet aloqasi bormi?');
    } else if (err.type == DioExceptionType.connectionTimeout) {
      errorDetails.writeln('⚠️ CONNECTION TIMEOUT: Serverga ulanib bo\'lmadi!');
      errorDetails.writeln('Tekshiring: Server manzili to\'g\'rimi? Server ishlamayaptimi?');
    } else if (err.type == DioExceptionType.connectionError) {
      errorDetails.writeln('⚠️ CONNECTION ERROR: Serverga ulanib bo\'lmadi!');
      errorDetails.writeln('Tekshiring: Internet aloqasi bormi? Server ishlamayaptimi?');
    }
    
    if (err.response?.data != null) {
      errorDetails.writeln('Response Data: ${err.response?.data}');
    }
    
    log(errorDetails.toString(), name: 'DIO');
    handler.next(err);
  }
}
