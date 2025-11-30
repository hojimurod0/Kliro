import '../../domain/entities/bank_service.dart';
import '../../domain/entities/currency_entity.dart';
import '../../domain/repositories/bank_repository.dart';
import '../datasources/bank_local_data_source.dart';
import '../datasources/bank_remote_data_source.dart';
import '../models/bank_service_model.dart';

class BankRepositoryImpl implements BankRepository {
  BankRepositoryImpl({
    required BankLocalDataSource localDataSource,
    required BankRemoteDataSource remoteDataSource,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource;

  final BankLocalDataSource _localDataSource;
  final BankRemoteDataSource _remoteDataSource;

  @override
  List<BankService> getServices() {
    return _localDataSource.fetchServices();
  }

  @override
  Future<List<BankService>> getBankServicesFromApi() async {
    try {
      final apiModels = await _remoteDataSource.getBankServices();
      
      // Если API вернул пустой список, используем локальные данные
      if (apiModels.isEmpty) {
        return _localDataSource.fetchServices();
      }
      
      // Получаем локальные данные для fallback features
      final localServices = _localDataSource.fetchServices();
      final localServicesMap = {
        for (var service in localServices) service.titleKey: service
      };
      
      // Объединяем данные: если у API модели нет features или они пустые,
      // используем features из локальных данных
      final List<BankService> result = [];
      for (final apiModel in apiModels) {
        if (apiModel.features.isEmpty) {
          // Если features пустые, берем из локальных данных
          final localService = localServicesMap[apiModel.titleKey];
          if (localService != null) {
            // Создаем новую модель с features из локальных данных
            result.add(BankServiceModel(
              title: apiModel.title.isNotEmpty ? apiModel.title : localService.title,
              subtitle: apiModel.subtitle.isNotEmpty ? apiModel.subtitle : localService.subtitle,
              description: apiModel.description.isNotEmpty ? apiModel.description : localService.description,
              features: localService.features,
              color: apiModel.color,
              icon: apiModel.icon,
              titleKey: apiModel.titleKey,
            ));
          } else {
            // Если локальных данных нет, используем API модель как есть
            result.add(apiModel);
          }
        } else {
          // Если features есть, используем API модель
          result.add(apiModel);
        }
      }
      
      return result;
    } catch (e) {
      // Если API не работает, возвращаем локальные данные как fallback
      return _localDataSource.fetchServices();
    }
  }

  @override
  Future<List<CurrencyEntity>> getCurrencies() async {
    final models = await _remoteDataSource.getCurrencies();
    return models;
  }

  @override
  Future<List<CurrencyEntity>> searchBankServices({
    required String query,
    int page = 0,
    int size = 10,
  }) async {
    final models = await _remoteDataSource.searchBankServices(
      query: query,
      page: page,
      size: size,
    );
    return models;
  }
}
