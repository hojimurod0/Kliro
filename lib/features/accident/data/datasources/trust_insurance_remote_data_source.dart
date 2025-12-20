import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/tariff_model.dart';
import '../models/region_model.dart';
import '../models/create_insurance_request.dart';
import '../models/create_insurance_response.dart';
import '../models/check_payment_request.dart';
import '../models/check_payment_response.dart';
import '../../../../core/errors/exceptions.dart';

abstract class TrustInsuranceRemoteDataSource {
  Future<List<TariffModel>> getTariffs();
  Future<List<RegionModel>> getRegions();
  Future<CreateInsuranceResponse> createInsurance(
      CreateInsuranceRequest request);
  Future<CheckPaymentResponse> checkPayment(CheckPaymentRequest request);
}

class TrustInsuranceRemoteDataSourceImpl
    implements TrustInsuranceRemoteDataSource {
  final Dio dio;

  TrustInsuranceRemoteDataSourceImpl(this.dio);

  @override
  Future<List<TariffModel>> getTariffs() async {
    try {
      if (kDebugMode) {
        debugPrint('📤 Loading tariffs...');
      }

      final response = await dio.get('/trust-insurance/accident/tarifs');

      if (kDebugMode) {
        debugPrint('📥 Tariffs API Response Status: ${response.statusCode}');
        debugPrint('📥 Tariffs API Response Data: ${response.data}');
      }

      if (response.statusCode == 200) {
        // API javob strukturasi: {result: {result: 0, result_message: "Successful", tariffs: [...]}}
        final responseData = _ensureMap(response.data);

        if (kDebugMode) {
          debugPrint('📋 Tariffs API Response: $responseData');
        }

        // result ichidagi tariffs ni olish
        if (responseData.containsKey('result')) {
          final resultData = _ensureMap(responseData['result']);

          if (kDebugMode) {
            debugPrint('📋 Result data: $resultData');
            debugPrint('📋 Result data keys: ${resultData.keys.toList()}');
          }

          // result ichidagi result_code ni tekshirish
          if (resultData.containsKey('result') && resultData['result'] != 0) {
            final errorMessage =
                resultData['result_message'] as String? ?? 'Unknown error';
            if (kDebugMode) {
              debugPrint(
                  '❌ API returned error: result=${resultData['result']}, message=$errorMessage');
            }
            throw ServerException(
              message: errorMessage,
              statusCode: response.statusCode,
            );
          }

          if (resultData.containsKey('tariffs')) {
            final tariffsList = resultData['tariffs'];

            if (kDebugMode) {
              debugPrint('📋 Tariffs list type: ${tariffsList.runtimeType}');
            }

            if (tariffsList is List) {
              if (kDebugMode) {
                debugPrint('✅ Found ${tariffsList.length} tariffs in result');
              }

              try {
                return tariffsList.map((json) {
                  if (json is Map<String, dynamic>) {
                    return TariffModel.fromJson(json);
                  }
                  throw const ParsingException('Invalid tariff data format');
                }).toList();
              } catch (e) {
                if (kDebugMode) {
                  debugPrint('❌ Error parsing tariffs: $e');
                }
                throw ParsingException('Failed to parse tariffs: $e');
              }
            } else {
              if (kDebugMode) {
                debugPrint(
                    '❌ Tariffs is not a list, type: ${tariffsList.runtimeType}');
              }
              throw const ParsingException('Tariffs is not a list');
            }
          } else {
            if (kDebugMode) {
              debugPrint(
                  '❌ Tariffs key not found in result. Keys: ${resultData.keys.toList()}');
            }
            throw const ParsingException('Tariffs key not found in result');
          }
        } else {
          // Agar to'g'ridan-to'g'ri list bo'lsa (eski format uchun backward compatibility)
          if (kDebugMode) {
            debugPrint('⚠️ No "result" key found, trying direct list format');
          }
          try {
            final data = _ensureList(response.data);
            if (kDebugMode) {
              debugPrint('✅ Found ${data.length} tariffs in direct format');
            }
            return data.map((json) {
              if (json is Map<String, dynamic>) {
                return TariffModel.fromJson(json);
              }
              throw const ParsingException('Invalid tariff data format');
            }).toList();
          } catch (e) {
            if (kDebugMode) {
              debugPrint('❌ Error parsing tariffs (direct): $e');
            }
            throw ParsingException('Failed to parse tariffs: $e');
          }
        }
      } else {
        throw ServerException(
          message: 'Failed to load tariffs',
          statusCode: response.statusCode,
        );
      }
    } on ParsingException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Parsing error: ${e.message}');
      }
      rethrow;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Unexpected error loading tariffs: $e');
        debugPrint('❌ Error type: ${e.runtimeType}');
      }
      throw ServerException(message: 'Unexpected error loading tariffs: $e');
    }
  }

  @override
  Future<List<RegionModel>> getRegions() async {
    try {
      final response = await dio.get('/trust-insurance/accident/regions');
      if (response.statusCode == 200) {
        // API javob strukturasi: {result: [{id: 10, name: "г.Ташкент}, ...]}
        final responseData = _ensureMap(response.data);

        if (kDebugMode) {
          debugPrint('📋 Regions API Response: $responseData');
        }

        // result ichidagi regions list ni olish
        if (responseData.containsKey('result')) {
          final regionsList = responseData['result'];

          if (regionsList is List) {
            if (kDebugMode) {
              debugPrint('✅ Found ${regionsList.length} regions in result');
            }

            return regionsList.map((json) {
              if (json is Map<String, dynamic>) {
                try {
                  return RegionModel.fromJson(json);
                } catch (e) {
                  if (kDebugMode) {
                    debugPrint('❌ Error parsing region: $json, Error: $e');
                  }
                  throw ParsingException('Invalid region data format: $e');
                }
              }
              throw const ParsingException(
                  'Invalid region data format: not a Map');
            }).toList();
          } else {
            if (kDebugMode) {
              debugPrint(
                  '❌ Regions is not a list, type: ${regionsList.runtimeType}');
            }
            throw const ParsingException('Regions is not a list');
          }
        } else {
          if (kDebugMode) {
            debugPrint('⚠️ No "result" key found, trying direct list format');
          }
          // Agar to'g'ridan-to'g'ri list bo'lsa (eski format uchun backward compatibility)
          final data = _ensureList(response.data);
          return data.map((json) {
            if (json is Map<String, dynamic>) {
              return RegionModel.fromJson(json);
            }
            throw const ParsingException('Invalid region data format');
          }).toList();
        }
      } else {
        throw ServerException(
          message: 'Failed to load regions',
          statusCode: response.statusCode,
        );
      }
    } on ParsingException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Parsing error: ${e.message}');
      }
      rethrow;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Unexpected error loading regions: $e');
      }
      throw ServerException(message: 'Unexpected error loading regions: $e');
    }
  }

  @override
  Future<CreateInsuranceResponse> createInsurance(
      CreateInsuranceRequest request) async {
    try {
      if (kDebugMode) {
        debugPrint('📤 Creating insurance with request: ${request.toJson()}');
      }

      final response = await dio.post(
        '/trust-insurance/accident/create',
        data: request.toJson(),
      );

      if (kDebugMode) {
        debugPrint(
            '📥 Create Insurance API Response Status: ${response.statusCode}');
        debugPrint('📥 Create Insurance API Response Data: ${response.data}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        // API javob strukturasi: {result: {result: 0, result_message: "", anketa_id: ..., payment_urls: {...}}}
        final responseData = _ensureMap(response.data);

        if (kDebugMode) {
          debugPrint('📋 Create Insurance API Response: $responseData');
        }

        // result ichidagi ma'lumotlarni olish
        if (responseData.containsKey('result')) {
          final resultData = _ensureMap(responseData['result']);

          if (kDebugMode) {
            debugPrint('📋 Result data: $resultData');
            debugPrint('📋 Result data keys: ${resultData.keys.toList()}');
          }

          // result ichidagi result_code ni tekshirish
          if (resultData.containsKey('result') && resultData['result'] != 0) {
            final errorMessage =
                resultData['result_message'] as String? ?? 'Unknown error';
            
            // Agar payment_urls va anketa_id mavjud bo'lsa, xatolikka qaramay
            // javobni qaytarish (chunki sug'urta yaratilgan va to'lov mumkin)
            final hasPaymentUrls = resultData.containsKey('payment_urls') && 
                                   resultData['payment_urls'] != null;
            final hasAnketaId = resultData.containsKey('anketa_id') && 
                                resultData['anketa_id'] != null;
            
            if (hasPaymentUrls && hasAnketaId) {
              // Warning log qilish, lekin javobni qaytarish
              if (kDebugMode) {
                debugPrint(
                    '⚠️ API returned warning: result=${resultData['result']}, message=$errorMessage');
                debugPrint('⚠️ But payment URLs and anketa_id exist, proceeding to payment...');
              }
              // Warning bor bo'lsa ham, payment_urls va anketa_id mavjud bo'lsa
              // javobni parse qilish va qaytarish
              try {
                return CreateInsuranceResponse.fromJson(resultData);
              } catch (e) {
                if (kDebugMode) {
                  debugPrint('❌ Error parsing CreateInsuranceResponse: $e');
                  debugPrint('❌ Result data that failed to parse: $resultData');
                }
                throw ParsingException(
                    'Failed to parse CreateInsuranceResponse: $e');
              }
            } else {
              // Agar payment_urls yoki anketa_id yo'q bo'lsa, xatolikni throw qilish
              if (kDebugMode) {
                debugPrint(
                    '❌ API returned error: result=${resultData['result']}, message=$errorMessage');
              }
              throw ServerException(
                message: errorMessage,
                statusCode: response.statusCode,
              );
            }
          }

          try {
            return CreateInsuranceResponse.fromJson(resultData);
          } catch (e) {
            if (kDebugMode) {
              debugPrint('❌ Error parsing CreateInsuranceResponse: $e');
              debugPrint('❌ Result data that failed to parse: $resultData');
            }
            throw ParsingException(
                'Failed to parse CreateInsuranceResponse: $e');
          }
        } else {
          // Agar to'g'ridan-to'g'ri ma'lumot bo'lsa (backward compatibility)
          if (kDebugMode) {
            debugPrint('⚠️ No "result" key found, using direct data');
          }
          try {
            return CreateInsuranceResponse.fromJson(responseData);
          } catch (e) {
            if (kDebugMode) {
              debugPrint(
                  '❌ Error parsing CreateInsuranceResponse (direct): $e');
              debugPrint('❌ Response data that failed to parse: $responseData');
            }
            throw ParsingException(
                'Failed to parse CreateInsuranceResponse: $e');
          }
        }
      } else {
        throw ServerException(
          message: 'Failed to create insurance',
          statusCode: response.statusCode,
        );
      }
    } on ParsingException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Parsing error: ${e.message}');
      }
      rethrow;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Unexpected error creating insurance: $e');
        debugPrint('❌ Error type: ${e.runtimeType}');
      }
      throw ServerException(message: 'Unexpected error creating insurance: $e');
    }
  }

  @override
  Future<CheckPaymentResponse> checkPayment(CheckPaymentRequest request) async {
    try {
      if (kDebugMode) {
        debugPrint('📤 Checking payment with request: ${request.toJson()}');
      }

      final response = await dio.post(
        '/trust-insurance/accident/check-payment',
        data: request.toJson(),
      );

      if (kDebugMode) {
        debugPrint(
            '📥 Check Payment API Response Status: ${response.statusCode}');
        debugPrint('📥 Check Payment API Response Data: ${response.data}');
      }

      if (response.statusCode == 200) {
        // API javob strukturasi: {result: {result: 0, result_message: "", status_payment: ..., ...}}
        final responseData = _ensureMap(response.data);

        if (kDebugMode) {
          debugPrint('📋 Check Payment API Response: $responseData');
        }

        // result ichidagi ma'lumotlarni olish
        if (responseData.containsKey('result')) {
          final resultData = _ensureMap(responseData['result']);

          if (kDebugMode) {
            debugPrint('📋 Result data: $resultData');
            debugPrint('📋 Result data keys: ${resultData.keys.toList()}');
          }

          // result ichidagi result_code ni tekshirish
          if (resultData.containsKey('result') && resultData['result'] != 0) {
            final errorMessage =
                resultData['result_message'] as String? ?? 'Unknown error';
            if (kDebugMode) {
              debugPrint(
                  '❌ API returned error: result=${resultData['result']}, message=$errorMessage');
            }
            throw ServerException(
              message: errorMessage,
              statusCode: response.statusCode,
            );
          }

          try {
            return CheckPaymentResponse.fromJson(resultData);
          } catch (e) {
            if (kDebugMode) {
              debugPrint('❌ Error parsing CheckPaymentResponse: $e');
              debugPrint('❌ Result data that failed to parse: $resultData');
            }
            throw ParsingException('Failed to parse CheckPaymentResponse: $e');
          }
        } else {
          // Agar to'g'ridan-to'g'ri ma'lumot bo'lsa (backward compatibility)
          if (kDebugMode) {
            debugPrint('⚠️ No "result" key found, using direct data');
          }
          try {
            return CheckPaymentResponse.fromJson(responseData);
          } catch (e) {
            if (kDebugMode) {
              debugPrint('❌ Error parsing CheckPaymentResponse (direct): $e');
              debugPrint('❌ Response data that failed to parse: $responseData');
            }
            throw ParsingException('Failed to parse CheckPaymentResponse: $e');
          }
        }
      } else {
        throw ServerException(
          message: 'Failed to check payment',
          statusCode: response.statusCode,
        );
      }
    } on ParsingException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Parsing error: ${e.message}');
      }
      rethrow;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Unexpected error checking payment: $e');
        debugPrint('❌ Error type: ${e.runtimeType}');
      }
      throw ServerException(message: 'Unexpected error checking payment: $e');
    }
  }

  Exception _handleDioError(DioException error) {
    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data;

    // Server xatoliklari
    if (error.response != null) {
      String? serverMessage;
      if (responseData is Map<String, dynamic>) {
        serverMessage = responseData['message'] as String? ??
            responseData['error'] as String? ??
            responseData['detail'] as String?;
      } else if (responseData is String) {
        serverMessage = responseData;
      }

      final message = serverMessage ?? 'Server error';

      // 401 - Unauthorized
      if (statusCode == 401) {
        return ServerException(
          message: 'Authentication failed. Please check your credentials.',
          statusCode: statusCode,
        );
      }

      // 400 - Bad Request
      if (statusCode == 400) {
        return ServerException(
          message: message,
          statusCode: statusCode,
        );
      }

      // 404 - Not Found
      if (statusCode == 404) {
        return ServerException(
          message: 'Resource not found',
          statusCode: statusCode,
        );
      }

      // 500+ - Server Error
      if (statusCode != null && statusCode >= 500) {
        return ServerException(
          message: 'Server error. Please try again later.',
          statusCode: statusCode,
        );
      }

      return ServerException(message: message, statusCode: statusCode);
    }

    // Network xatoliklari
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return const NetworkException(
          message:
              'Connection timeout. Please check your internet connection.');
    }

    if (error.type == DioExceptionType.connectionError) {
      return const NetworkException(
          message:
              'No internet connection. Please check your network settings.');
    }

    return NetworkException(message: error.message ?? 'Unknown network error');
  }

  /// Response data Map ekanligini tekshirish
  Map<String, dynamic> _ensureMap(Object? data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    throw const ParsingException('Malformed server response: expected Map');
  }

  /// Response data List ekanligini tekshirish
  List<dynamic> _ensureList(Object? data) {
    if (data is List) {
      return data;
    }
    throw const ParsingException('Malformed server response: expected List');
  }
}
