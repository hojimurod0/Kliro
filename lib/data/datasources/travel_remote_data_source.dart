import '../../core/constants/api_paths.dart';
import '../../core/errors/exceptions.dart';
import '../../core/network/dio_client.dart';
import '../models/api_response_model.dart';
import '../models/session_model.dart';
import '../models/travel_details_model.dart';
import '../models/calculate_request_model.dart';
import '../models/calculate_response_model.dart';
import '../models/save_policy_request_model.dart';
import '../models/save_policy_response_model.dart';
import '../models/check_response_model.dart';
import '../models/country_model.dart';
import '../models/tarif_request_model.dart';
import '../models/tarif_response_model.dart';
import '../models/purpose_request_model.dart';

/// Удаленный источник данных для Travel Insurance
abstract class TravelRemoteDataSource {
  /// Создать цель путешествия
  Future<SessionModel> createPurpose(PurposeRequestModel request);

  /// Отправить детали путешествия
  Future<void> sendDetails(TravelDetailsModel request);

  /// Рассчитать стоимость
  Future<CalculateResponseModel> calculate(CalculateRequestModel request);

  /// Сохранить полис
  Future<SavePolicyResponseModel> savePolicy(SavePolicyRequestModel request);

  /// Проверить статус сессии
  Future<CheckResponseModel> checkSession(String sessionId);

  /// Получить список стран
  Future<List<CountryModel>> getCountries();

  /// Получить тарифы по стране
  Future<TarifResponseModel> getTarifs(TarifRequestModel request);
}

/// Реализация TravelRemoteDataSource
class TravelRemoteDataSourceImpl implements TravelRemoteDataSource {
  final DioClient dioClient;

  TravelRemoteDataSourceImpl(this.dioClient);

  @override
  Future<SessionModel> createPurpose(PurposeRequestModel request) async {
    try {
      final response = await dioClient.post(
        ApiPaths.purpose,
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        // Обработка разных форматов ответа
        if (data is Map<String, dynamic>) {
          // Если есть session_id напрямую
          if (data.containsKey('session_id')) {
            return SessionModel(
              sessionId: data['session_id'] as String,
              data: data,
            );
          }
          
          // Если обернуто в result или data
          if (data.containsKey('result')) {
            final result = data['result'] as Map<String, dynamic>;
            return SessionModel(
              sessionId: result['session_id'] as String,
              data: result,
            );
          }
          
          if (data.containsKey('data')) {
            final result = data['data'] as Map<String, dynamic>;
            return SessionModel(
              sessionId: result['session_id'] as String,
              data: result,
            );
          }
        }

        throw const ParsingException('Неверный формат ответа сервера');
      }

      throw ServerException(
        'Ошибка создания цели путешествия',
        statusCode: response.statusCode,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw ParsingException('Ошибка парсинга ответа: ${e.toString()}');
    }
  }

  @override
  Future<void> sendDetails(TravelDetailsModel request) async {
    try {
      final response = await dioClient.post(
        ApiPaths.details,
        data: request.toJson(),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerException(
          'Ошибка отправки деталей',
          statusCode: response.statusCode,
        );
      }
    } on AppException {
      rethrow;
    } catch (e) {
      throw ParsingException('Ошибка отправки деталей: ${e.toString()}');
    }
  }

  @override
  Future<CalculateResponseModel> calculate(CalculateRequestModel request) async {
    try {
      final response = await dioClient.post(
        ApiPaths.calculate,
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        if (data is Map<String, dynamic>) {
          // Обработка разных форматов ответа
          Map<String, dynamic> resultData = data;
          
          if (data.containsKey('result')) {
            resultData = data['result'] as Map<String, dynamic>;
          } else if (data.containsKey('data')) {
            resultData = data['data'] as Map<String, dynamic>;
          }

          return CalculateResponseModel.fromJson(resultData);
        }

        throw const ParsingException('Неверный формат ответа сервера');
      }

      throw ServerException(
        'Ошибка расчета',
        statusCode: response.statusCode,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw ParsingException('Ошибка парсинга ответа: ${e.toString()}');
    }
  }

  @override
  Future<SavePolicyResponseModel> savePolicy(SavePolicyRequestModel request) async {
    try {
      final response = await dioClient.post(
        ApiPaths.save,
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        
        if (data is Map<String, dynamic>) {
          Map<String, dynamic> resultData = data;
          
          if (data.containsKey('result')) {
            resultData = data['result'] as Map<String, dynamic>;
          } else if (data.containsKey('data')) {
            resultData = data['data'] as Map<String, dynamic>;
          }

          return SavePolicyResponseModel.fromJson(resultData);
        }

        throw const ParsingException('Неверный формат ответа сервера');
      }

      throw ServerException(
        'Ошибка сохранения полиса',
        statusCode: response.statusCode,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw ParsingException('Ошибка парсинга ответа: ${e.toString()}');
    }
  }

  @override
  Future<CheckResponseModel> checkSession(String sessionId) async {
    try {
      final response = await dioClient.post(
        ApiPaths.check,
        data: {'session_id': sessionId},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        if (data is Map<String, dynamic>) {
          Map<String, dynamic> resultData = data;
          
          if (data.containsKey('result')) {
            resultData = data['result'] as Map<String, dynamic>;
          } else if (data.containsKey('data')) {
            resultData = data['data'] as Map<String, dynamic>;
          }

          return CheckResponseModel.fromJson(resultData);
        }

        throw const ParsingException('Неверный формат ответа сервера');
      }

      throw ServerException(
        'Ошибка проверки сессии',
        statusCode: response.statusCode,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw ParsingException('Ошибка парсинга ответа: ${e.toString()}');
    }
  }

  @override
  Future<List<CountryModel>> getCountries() async {
    try {
      final response = await dioClient.get(ApiPaths.country);

      if (response.statusCode == 200) {
        final data = response.data;
        
        if (data is List) {
          return data
              .map((item) => CountryModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        
        if (data is Map<String, dynamic>) {
          List<dynamic>? countries;
          
          if (data.containsKey('result') && data['result'] is List) {
            countries = data['result'] as List;
          } else if (data.containsKey('data') && data['data'] is List) {
            countries = data['data'] as List;
          } else if (data.containsKey('countries') && data['countries'] is List) {
            countries = data['countries'] as List;
          }
          
          if (countries != null) {
            return countries
                .map((item) => CountryModel.fromJson(item as Map<String, dynamic>))
                .toList();
          }
        }

        throw const ParsingException('Неверный формат ответа сервера');
      }

      throw ServerException(
        'Ошибка получения стран',
        statusCode: response.statusCode,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw ParsingException('Ошибка парсинга ответа: ${e.toString()}');
    }
  }

  @override
  Future<TarifResponseModel> getTarifs(TarifRequestModel request) async {
    try {
      final response = await dioClient.post(
        ApiPaths.tarifs,
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        if (data is Map<String, dynamic>) {
          Map<String, dynamic> resultData = data;
          
          if (data.containsKey('result')) {
            resultData = data['result'] as Map<String, dynamic>;
          } else if (data.containsKey('data')) {
            resultData = data['data'] as Map<String, dynamic>;
          }

          return TarifResponseModel.fromJson(resultData);
        }

        throw const ParsingException('Неверный формат ответа сервера');
      }

      throw ServerException(
        'Ошибка получения тарифов',
        statusCode: response.statusCode,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw ParsingException('Ошибка парсинга ответа: ${e.toString()}');
    }
  }
}

