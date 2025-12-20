import 'package:dio/dio.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_response.dart';
import '../models/bank_service_model.dart';
import '../models/currency_data_model.dart';
import '../models/currency_model.dart';
import '../models/currency_rate_item_model.dart';

abstract class BankRemoteDataSource {
  Future<List<CurrencyModel>> getCurrencies();
  Future<List<CurrencyModel>> searchBankServices({
    required String query,
    int page = 0,
    int size = 10,
  });
  Future<List<BankServiceModel>> getBankServices();
}

class BankRemoteDataSourceImpl implements BankRemoteDataSource {
  BankRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<CurrencyModel>> getCurrencies() async {
    try {
      final response = await _dio.get(ApiPaths.getCurrencies);
      final data = response.data;
      
      if (data is! Map<String, dynamic>) {
        throw const AppException(message: 'Malformed server response');
      }
      
      final apiResponse = ApiResponse.fromJson(
        data,
        (json) => json,
      );
      
      if (!apiResponse.success) {
        throw ValidationException(
          apiResponse.message ?? 'Request failed',
          statusCode: response.statusCode,
        );
      }
      
      final result = apiResponse.result;
      if (result == null || result is! Map<String, dynamic>) {
        return <CurrencyModel>[];
      }
      
      // Parse the result structure: {EUR: {...}, USD: {...}, etc.}
      final List<CurrencyModel> currencies = [];
      
      result.forEach((currencyCode, currencyData) {
        try {
          if (currencyData is! Map<String, dynamic>) {
            print('Currency $currencyCode: currencyData is not Map');
            return;
          }
          
          final currencyDataModel = CurrencyDataModel.fromJson(currencyData);
          
          // Create CurrencyModel for each bank
          // Combine buy_sorted and sell_sorted by bank name
          final Map<String, CurrencyRateItemModel> buyMap = {};
          final Map<String, CurrencyRateItemModel> sellMap = {};
          
          for (final item in currencyDataModel.buySorted) {
            buyMap[item.bank] = item;
          }
          
          for (final item in currencyDataModel.sellSorted) {
            sellMap[item.bank] = item;
          }
          
          // Get all unique banks
          final allBanks = <String>{...buyMap.keys, ...sellMap.keys};
          
          print('Currency $currencyCode: Found ${allBanks.length} banks');
          
          for (final bankName in allBanks) {
            try {
              final buyItem = buyMap[bankName];
              final sellItem = sellMap[bankName];
              
              if (buyItem != null || sellItem != null) {
                final buyRate = buyItem?.rateAsDouble ?? 0.0;
                final sellRate = sellItem?.rateAsDouble ?? 0.0;
                
                print('Adding currency: $bankName ($currencyCode) - Buy: $buyRate, Sell: $sellRate');
                
                currencies.add(
                  CurrencyModel(
                    id: buyItem?.id ?? sellItem?.id ?? 0,
                    bankName: bankName,
                    currencyCode: currencyCode,
                    currencyName: _getCurrencyName(currencyCode),
                    buyRate: buyRate,
                    sellRate: sellRate,
                    lastUpdated: _parseDateTime(
                      buyItem?.updatedAt ?? sellItem?.updatedAt ?? '',
                    ),
                  ),
                );
              }
            } catch (e) {
              print('Error adding bank $bankName for currency $currencyCode: $e');
            }
          }
        } catch (e, stackTrace) {
          // Skip this currency if parsing fails, continue with others
          print('Error parsing currency $currencyCode: $e');
          print('Stack trace: $stackTrace');
        }
      });
      
      print('Total currencies parsed: ${currencies.length}');
      if (currencies.isEmpty) {
        print('WARNING: No currencies were parsed! Check the parsing logic above.');
      }
      return currencies;
    } on DioException catch (error) {
      _handleDioError(error);
      // _handleDioError always throws, so this is unreachable
    }
  }
  
  String _getCurrencyName(String code) {
    switch (code) {
      case 'USD':
        return 'US Dollar';
      case 'EUR':
        return 'Euro';
      case 'RUB':
        return 'Russian Ruble';
      case 'KZT':
        return 'Kazakhstani Tenge';
      default:
        return code;
    }
  }
  
  DateTime? _parseDateTime(String dateString) {
    try {
      // Format: "2025-11-22 06:50:00"
      return DateTime.parse(dateString.replaceAll(' ', 'T'));
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<CurrencyModel>> searchBankServices({
    required String query,
    int page = 0,
    int size = 10,
  }) async {
    // For now, search uses the same endpoint as getCurrencies
    // You can filter the results locally or implement a separate search endpoint
    final allCurrencies = await getCurrencies();
    
    if (query.trim().isEmpty) {
      return allCurrencies;
    }
    
    final queryLower = query.toLowerCase();
    return allCurrencies.where((currency) {
      return currency.bankName.toLowerCase().contains(queryLower) ||
          currency.currencyCode.toLowerCase().contains(queryLower) ||
          currency.currencyName.toLowerCase().contains(queryLower);
    }).toList();
  }


  @override
  Future<List<BankServiceModel>> getBankServices() async {
    try {
      final response = await _dio.get(ApiPaths.getBankServices);
      final data = response.data;
      
      if (data is! Map<String, dynamic>) {
        throw const AppException(message: 'Malformed server response');
      }
      
      final apiResponse = ApiResponse.fromJson(
        data,
        (json) => json,
      );
      
      if (!apiResponse.success) {
        throw ValidationException(
          apiResponse.message ?? 'Request failed',
          statusCode: response.statusCode,
        );
      }
      
      final result = apiResponse.result;
      if (result == null) {
        return <BankServiceModel>[];
      }
      
      // Если result - это список
      if (result is List) {
        return result
            .whereType<Map<String, dynamic>>()
            .map((json) => BankServiceModel.fromJson(json))
            .toList();
      }
      
      // Если result - это объект с данными
      if (result is Map<String, dynamic>) {
        // Проверяем, есть ли поле 'services' или 'data'
        final servicesData = result['services'] ?? result['data'] ?? result;
        
        if (servicesData is List) {
          return servicesData
              .whereType<Map<String, dynamic>>()
              .map((json) => BankServiceModel.fromJson(json))
              .toList();
        }
      }
      
      return <BankServiceModel>[];
    } on DioException catch (error) {
      _handleDioError(error);
      // _handleDioError always throws, so this is unreachable
    }
  }

  Never _handleDioError(DioException error) {
    final statusCode = error.response?.statusCode;
    
    // Timeout xatolarini alohida handle qilish
    if (error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.connectionTimeout) {
      throw NetworkException(
        message: 'Serverga ulanib bo\'lmadi. Internet aloqasini tekshiring yoki keyinroq urinib ko\'ring.',
        statusCode: statusCode,
        details: error.response?.data,
      );
    }
    
    // Connection xatolari
    if (error.type == DioExceptionType.connectionError) {
      throw NetworkException(
        message: 'Serverga ulanib bo\'lmadi. Server ishlamayotgan bo\'lishi mumkin yoki internet aloqasi yo\'q.',
        statusCode: statusCode,
        details: error.response?.data,
      );
    }
    
    final message =
        _extractMessage(error.response?.data) ?? error.message ?? 'Noma\'lum xatolik';
    
    if (statusCode == 401) {
      throw UnauthorizedException(
        message: message,
        statusCode: statusCode,
        details: error.response?.data,
      );
    }
    
    throw NetworkException(
      message: message,
      statusCode: statusCode,
      details: error.response?.data,
    );
  }

  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
      final error = data['error'];
      if (error is String && error.isNotEmpty) {
        return error;
      }
      final errors = data['errors'];
      if (errors is Map<String, dynamic>) {
        final firstValue = errors.values.cast<List?>().firstWhere(
          (value) => value != null && value.isNotEmpty,
          orElse: () => null,
        );
        if (firstValue != null) {
          final firstMessage = firstValue.first;
          if (firstMessage is String && firstMessage.isNotEmpty) {
            return firstMessage;
          }
        }
      }
    }
    return null;
  }
}

