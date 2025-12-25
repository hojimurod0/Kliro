import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'service_locator_state.dart';
import '../../utils/logger.dart';

import '../../../features/bank/data/datasources/bank_local_data_source.dart';
import '../../../features/bank/data/datasources/bank_remote_data_source.dart';
import '../../../features/bank/data/repositories/bank_repository_impl.dart';
import '../../../features/bank/domain/repositories/bank_repository.dart';
import '../../../features/bank/domain/usecases/get_currencies.dart';
import '../../../features/bank/domain/usecases/search_bank_services.dart';
import '../../../features/bank/presentation/bloc/currency_bloc.dart';
import '../../../features/cards/data/datasources/card_local_data_source.dart';
import '../../../features/cards/data/datasources/card_remote_data_source.dart';
import '../../../features/cards/data/repositories/card_repository_impl.dart';
import '../../../features/cards/domain/repositories/card_repository.dart';
import '../../../features/cards/domain/usecases/get_card_offers.dart';
import '../../../features/cards/presentation/bloc/card_bloc.dart';
import '../../../features/micro_loan/data/datasources/microcredit_local_data_source.dart';
import '../../../features/micro_loan/data/datasources/microcredit_remote_data_source.dart';
import '../../../features/micro_loan/data/repositories/microcredit_repository_impl.dart';
import '../../../features/micro_loan/domain/repositories/microcredit_repository.dart';
import '../../../features/micro_loan/domain/usecases/get_microcredits.dart';
import '../../../features/micro_loan/presentation/bloc/microcredit_bloc.dart';
import '../../../features/deposit/data/datasources/deposit_local_data_source.dart';
import '../../../features/deposit/data/datasources/deposit_remote_data_source.dart';
import '../../../features/deposit/data/repositories/deposit_repository_impl.dart';
import '../../../features/deposit/domain/repositories/deposit_repository.dart';
import '../../../features/deposit/domain/usecases/get_deposit_offers.dart';
import '../../../features/deposit/presentation/bloc/deposit_bloc.dart';
import '../../../features/mortgage/data/datasources/mortgage_local_data_source.dart';
import '../../../features/mortgage/data/datasources/mortgage_remote_data_source.dart';
import '../../../features/mortgage/data/repositories/mortgage_repository_impl.dart';
import '../../../features/mortgage/domain/repositories/mortgage_repository.dart';
import '../../../features/mortgage/domain/usecases/get_mortgage_offers.dart';
import '../../../features/mortgage/presentation/bloc/mortgage_bloc.dart';
import '../../../features/register/data/datasources/auth_remote_data_source.dart';
import '../../../features/register/data/datasources/profile_remote_data_source.dart';
import '../../../features/register/data/repositories/auth_repository_impl.dart';
import '../../../features/register/data/repositories/profile_repository_impl.dart';
import '../../../features/register/domain/repositories/auth_repository.dart';
import '../../../features/register/domain/repositories/profile_repository.dart';
import '../../../features/register/domain/usecases/register_user.dart';
import '../../../features/register/presentation/bloc/register_bloc.dart';
import '../../../features/transfer_apps/data/datasources/transfer_app_local_data_source.dart';
import '../../../features/transfer_apps/data/datasources/transfer_app_remote_data_source.dart';
import '../../../features/transfer_apps/data/repositories/transfer_app_repository_impl.dart';
import '../../../features/transfer_apps/domain/repositories/transfer_app_repository.dart';
import '../../../features/transfer_apps/domain/usecases/get_transfer_apps.dart';
import '../../../features/transfer_apps/presentation/bloc/transfer_apps_bloc.dart';
import '../../../features/kasko/data/datasources/kasko_local_data_source.dart';
import '../../../features/kasko/data/datasources/kasko_remote_data_source.dart';
import '../../../features/kasko/data/repositories/kasko_repository_impl.dart';
import '../../../features/kasko/domain/repositories/kasko_repository.dart';
import '../../../features/kasko/domain/usecases/calculate_car_price.dart';
import '../../../features/kasko/domain/usecases/calculate_policy.dart';
import '../../../features/kasko/domain/usecases/check_payment_status.dart';
import '../../../features/kasko/domain/usecases/get_cars.dart';
import '../../../features/kasko/domain/usecases/get_cars_minimal.dart';
import '../../../features/kasko/domain/usecases/get_cars_paginated.dart';
import '../../../features/kasko/domain/usecases/get_payment_link.dart';
import '../../../features/kasko/domain/usecases/get_rates.dart';
import '../../../features/kasko/domain/usecases/save_order.dart';
import '../../../features/kasko/domain/usecases/upload_image.dart';
import '../../../features/kasko/presentation/bloc/kasko_bloc.dart';
import '../../../features/accident/data/datasources/trust_insurance_remote_data_source.dart';
import '../../../features/accident/data/datasources/trust_insurance_dio_client.dart';
import '../../../features/accident/data/repositories/accident_repository_impl.dart';
import '../../../features/accident/domain/repositories/accident_repository.dart';
import '../../../features/avichiptalar/data/datasources/payment_remote_data_source.dart';
import '../../../features/avichiptalar/data/repositories/payment_repository_impl.dart';
import '../../../features/avichiptalar/domain/repositories/payment_repository.dart';
import '../../../features/avichiptalar/presentation/bloc/payment_bloc.dart';
import '../../../features/accident/domain/usecases/get_tariffs.dart';
import '../../../features/accident/domain/usecases/get_regions.dart';
import '../../../features/accident/domain/usecases/create_insurance.dart';
import '../../../features/accident/domain/usecases/check_payment.dart';
import '../../../features/accident/presentation/bloc/accident_bloc.dart';
import '../../../features/avichiptalar/data/repositories/avichiptalar_repository_impl.dart';
import '../../../features/avichiptalar/domain/repositories/avichiptalar_repository.dart';
import '../../../features/avichiptalar/presentation/bloc/avia_bloc.dart';
import '../../services/auth/auth_service.dart';
import '../../constants/constants.dart';
import '../client/dio_client.dart';
import '../../network/avia/avia_dio_client.dart';

class ServiceLocator {
  ServiceLocator._();

  static final GetIt _getIt = GetIt.instance;

  static Future<void> _yieldToUi() async {
    // Register'lar katta bo'lsa debug'da frame skip bo'lishi mumkin.
    // Bitta micro-yield UI'ga nafas beradi.
    await Future<void>.delayed(Duration.zero);
  }

  static Future<void> init() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    return initWithPrefs(sharedPreferences);
  }

  /// SharedPreferences ni tashqaridan olish - performance optimizatsiyasi uchun
  /// Bu metod SharedPreferences ni bir marta yuklab, ikkala service'ga pass qilish uchun ishlatiladi
  static Future<void> initWithPrefs(SharedPreferences sharedPreferences) async {
    try {
      ServiceLocatorStateController.instance.setInitializing();
      AppLogger.info('ServiceLocator initialization started');

      final authService = AuthService.instance;

      if (!_getIt.isRegistered<AuthService>()) {
        _getIt.registerSingleton<AuthService>(authService);
      }

      if (!_getIt.isRegistered<DioClient>()) {
        _getIt.registerLazySingleton<DioClient>(
          () => DioClient(authService: authService),
        );
      }

      if (!_getIt.isRegistered<Dio>()) {
        _getIt.registerLazySingleton<Dio>(() => _getIt<DioClient>().client);
      }
      
      if (!_getIt.isRegistered<SharedPreferences>()) {
        _getIt.registerSingleton<SharedPreferences>(sharedPreferences);
      }

      _registerDataSources();
      await _yieldToUi();
      _registerRepositories();
      await _yieldToUi();
      _registerUseCases();
      await _yieldToUi();
      _registerBlocs(authService);

      ServiceLocatorStateController.instance.setReady();
      AppLogger.success('ServiceLocator initialized successfully');
    } catch (e, stackTrace) {
      ServiceLocatorStateController.instance.setError(e);
      AppLogger.error(
        'ServiceLocator initialization failed',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  static T resolve<T extends Object>() => _getIt<T>();

  static void _registerDataSources() {
    if (!_getIt.isRegistered<AuthRemoteDataSource>()) {
      _getIt.registerLazySingleton<AuthRemoteDataSource>(
        () => AuthRemoteDataSourceImpl(_getIt<Dio>()),
      );
    }
    if (!_getIt.isRegistered<ProfileRemoteDataSource>()) {
      _getIt.registerLazySingleton<ProfileRemoteDataSource>(
        () => ProfileRemoteDataSourceImpl(_getIt<Dio>()),
      );
    }
    if (!_getIt.isRegistered<BankRemoteDataSource>()) {
      _getIt.registerLazySingleton<BankRemoteDataSource>(
        () => BankRemoteDataSourceImpl(_getIt<Dio>()),
      );
    }
    if (!_getIt.isRegistered<BankLocalDataSource>()) {
      _getIt.registerLazySingleton<BankLocalDataSource>(
        () => const BankLocalDataSource(),
      );
    }
    if (!_getIt.isRegistered<MicrocreditRemoteDataSource>()) {
      _getIt.registerLazySingleton<MicrocreditRemoteDataSource>(
        () => MicrocreditRemoteDataSourceImpl(_getIt<Dio>()),
      );
    }
    if (!_getIt.isRegistered<MicrocreditLocalDataSource>()) {
      _getIt.registerLazySingleton<MicrocreditLocalDataSource>(
        () => MicrocreditLocalDataSource(_getIt<SharedPreferences>()),
      );
    }
    if (!_getIt.isRegistered<DepositRemoteDataSource>()) {
      _getIt.registerLazySingleton<DepositRemoteDataSource>(
        () => DepositRemoteDataSourceImpl(_getIt<Dio>()),
      );
    }
    if (!_getIt.isRegistered<DepositLocalDataSource>()) {
      _getIt.registerLazySingleton<DepositLocalDataSource>(
        () => DepositLocalDataSource(_getIt<SharedPreferences>()),
      );
    }
    if (!_getIt.isRegistered<TransferAppRemoteDataSource>()) {
      _getIt.registerLazySingleton<TransferAppRemoteDataSource>(
        () => TransferAppRemoteDataSourceImpl(_getIt<Dio>()),
      );
    }
    if (!_getIt.isRegistered<TransferAppLocalDataSource>()) {
      _getIt.registerLazySingleton<TransferAppLocalDataSource>(
        () => TransferAppLocalDataSource(_getIt<SharedPreferences>()),
      );
    }
    if (!_getIt.isRegistered<MortgageRemoteDataSource>()) {
      _getIt.registerLazySingleton<MortgageRemoteDataSource>(
        () => MortgageRemoteDataSourceImpl(_getIt<Dio>()),
      );
    }
    if (!_getIt.isRegistered<MortgageLocalDataSource>()) {
      _getIt.registerLazySingleton<MortgageLocalDataSource>(
        () => MortgageLocalDataSource(_getIt<SharedPreferences>()),
      );
    }
    if (!_getIt.isRegistered<CardRemoteDataSource>()) {
      _getIt.registerLazySingleton<CardRemoteDataSource>(
        () => CardRemoteDataSourceImpl(_getIt<Dio>()),
      );
    }
    if (!_getIt.isRegistered<CardLocalDataSource>()) {
      _getIt.registerLazySingleton<CardLocalDataSource>(
        () => CardLocalDataSource(_getIt<SharedPreferences>()),
      );
    }
    if (!_getIt.isRegistered<KaskoRemoteDataSource>()) {
      _getIt.registerLazySingleton<KaskoRemoteDataSource>(
        () => KaskoRemoteDataSourceImpl(_getIt<Dio>()),
      );
    }
    if (!_getIt.isRegistered<KaskoLocalDataSource>()) {
      _getIt.registerLazySingleton<KaskoLocalDataSource>(
        () => KaskoLocalDataSource(_getIt<SharedPreferences>()),
      );
    }
    if (!_getIt.isRegistered<PaymentRemoteDataSource>()) {
      _getIt.registerLazySingleton<PaymentRemoteDataSource>(
        () => PaymentRemoteDataSourceImpl(_getIt<Dio>()),
      );
    }
    // Avia Data Sources
    if (!_getIt.isRegistered<AviaDioClient>()) {
      _getIt.registerLazySingleton<AviaDioClient>(
        () => AviaDioClient(authService: _getIt<AuthService>()),
      );
    }
    // Trust Insurance Data Sources
    if (!_getIt.isRegistered<TrustInsuranceDioClient>()) {
      // Config tekshiruvi
      if (!TrustInsuranceConfig.isConfigured) {
        AppLogger.warning('Trust Insurance config not fully configured!');
        AppLogger.warning(TrustInsuranceConfig.configInfo);
        AppLogger.warning(
            'Please configure credentials before using Trust Insurance API');
      }

      _getIt.registerLazySingleton<TrustInsuranceDioClient>(
        () => TrustInsuranceDioClient(
          baseUrl: TrustInsuranceConfig.baseUrl,
          username: TrustInsuranceConfig.username,
          password: TrustInsuranceConfig.password,
        ),
      );
    }
    if (!_getIt.isRegistered<TrustInsuranceRemoteDataSource>()) {
      _getIt.registerLazySingleton<TrustInsuranceRemoteDataSource>(
        () => TrustInsuranceRemoteDataSourceImpl(
          _getIt<TrustInsuranceDioClient>().client,
        ),
      );
    }
  }

  static void _registerRepositories() {
    if (!_getIt.isRegistered<AuthRepository>()) {
      _getIt.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(_getIt<AuthRemoteDataSource>()),
      );
    }
    if (!_getIt.isRegistered<ProfileRepository>()) {
      _getIt.registerLazySingleton<ProfileRepository>(
        () => ProfileRepositoryImpl(_getIt<ProfileRemoteDataSource>()),
      );
    }
    if (!_getIt.isRegistered<BankRepository>()) {
      _getIt.registerLazySingleton<BankRepository>(
        () => BankRepositoryImpl(
          localDataSource: _getIt<BankLocalDataSource>(),
          remoteDataSource: _getIt<BankRemoteDataSource>(),
        ),
      );
    }
    if (!_getIt.isRegistered<MicrocreditRepository>()) {
      _getIt.registerLazySingleton<MicrocreditRepository>(
        () => MicrocreditRepositoryImpl(
          remoteDataSource: _getIt<MicrocreditRemoteDataSource>(),
          localDataSource: _getIt<MicrocreditLocalDataSource>(),
        ),
      );
    }
    if (!_getIt.isRegistered<DepositRepository>()) {
      _getIt.registerLazySingleton<DepositRepository>(
        () => DepositRepositoryImpl(
          remoteDataSource: _getIt<DepositRemoteDataSource>(),
          localDataSource: _getIt<DepositLocalDataSource>(),
        ),
      );
    }
    if (!_getIt.isRegistered<MortgageRepository>()) {
      _getIt.registerLazySingleton<MortgageRepository>(
        () => MortgageRepositoryImpl(
          remoteDataSource: _getIt<MortgageRemoteDataSource>(),
          localDataSource: _getIt<MortgageLocalDataSource>(),
        ),
      );
    }
    if (!_getIt.isRegistered<CardRepository>()) {
      _getIt.registerLazySingleton<CardRepository>(
        () => CardRepositoryImpl(
          remoteDataSource: _getIt<CardRemoteDataSource>(),
          localDataSource: _getIt<CardLocalDataSource>(),
        ),
      );
    }
    if (!_getIt.isRegistered<TransferAppRepository>()) {
      _getIt.registerLazySingleton<TransferAppRepository>(
        () => TransferAppRepositoryImpl(
          remoteDataSource: _getIt<TransferAppRemoteDataSource>(),
          localDataSource: _getIt<TransferAppLocalDataSource>(),
        ),
      );
    }
    if (!_getIt.isRegistered<KaskoRepository>()) {
      _getIt.registerLazySingleton<KaskoRepository>(
        () => KaskoRepositoryImpl(
          remoteDataSource: _getIt<KaskoRemoteDataSource>(),
          localDataSource: _getIt<KaskoLocalDataSource>(),
        ),
      );
    }
    if (!_getIt.isRegistered<PaymentRepository>()) {
      _getIt.registerLazySingleton<PaymentRepository>(
        () => PaymentRepositoryImpl(_getIt<PaymentRemoteDataSource>()),
      );
    }
    // Accident Repository
    if (!_getIt.isRegistered<AccidentRepository>()) {
      _getIt.registerLazySingleton<AccidentRepository>(
        () => AccidentRepositoryImpl(
          remoteDataSource: _getIt<TrustInsuranceRemoteDataSource>(),
        ),
      );
    }
    // Avia Repository
    if (!_getIt.isRegistered<AvichiptalarRepository>()) {
      _getIt.registerLazySingleton<AvichiptalarRepository>(
        () => AvichiptalarRepositoryImpl(
          dioClient: _getIt<AviaDioClient>(),
        ),
      );
    }
  }

  static void _registerUseCases() {
    _registerLazy<SendRegisterOtp>(
      () => SendRegisterOtp(_getIt<AuthRepository>()),
    );
    _registerLazy<ConfirmRegisterOtp>(
      () => ConfirmRegisterOtp(_getIt<AuthRepository>()),
    );
    _registerLazy<CompleteRegistration>(
      () => CompleteRegistration(_getIt<AuthRepository>()),
    );
    _registerLazy<LoginUser>(() => LoginUser(_getIt<AuthRepository>()));
    _registerLazy<SendForgotPasswordOtp>(
      () => SendForgotPasswordOtp(_getIt<AuthRepository>()),
    );
    _registerLazy<ResetPassword>(() => ResetPassword(_getIt<AuthRepository>()));
    _registerLazy<GetGoogleRedirect>(
      () => GetGoogleRedirect(_getIt<AuthRepository>()),
    );
    _registerLazy<CompleteGoogleRegistration>(
      () => CompleteGoogleRegistration(_getIt<AuthRepository>()),
    );
    _registerLazy<GetProfile>(() => GetProfile(_getIt<ProfileRepository>()));
    _registerLazy<UpdateProfile>(
      () => UpdateProfile(_getIt<ProfileRepository>()),
    );
    _registerLazy<ChangeRegion>(
      () => ChangeRegion(_getIt<ProfileRepository>()),
    );
    _registerLazy<ChangePassword>(
      () => ChangePassword(_getIt<ProfileRepository>()),
    );
    _registerLazy<UpdateContact>(
      () => UpdateContact(_getIt<ProfileRepository>()),
    );
    _registerLazy<ConfirmUpdateContact>(
      () => ConfirmUpdateContact(_getIt<ProfileRepository>()),
    );
    _registerLazy<LogoutUser>(() => LogoutUser(_getIt<ProfileRepository>()));
    _registerLazy<GetCurrencies>(() => GetCurrencies(_getIt<BankRepository>()));
    _registerLazy<SearchBankServices>(
      () => SearchBankServices(_getIt<BankRepository>()),
    );
    _registerLazy<GetMicrocredits>(
      () => GetMicrocredits(_getIt<MicrocreditRepository>()),
    );
    _registerLazy<GetDeposits>(() => GetDeposits(_getIt<DepositRepository>()));
    _registerLazy<GetMortgages>(
      () => GetMortgages(_getIt<MortgageRepository>()),
    );
    _registerLazy<GetCardOffers>(() => GetCardOffers(_getIt<CardRepository>()));
    _registerLazy<GetTransferApps>(
      () => GetTransferApps(_getIt<TransferAppRepository>()),
    );
    _registerLazy<GetCars>(() => GetCars(_getIt<KaskoRepository>()));
    _registerLazy<GetCarsMinimal>(
      () => GetCarsMinimal(_getIt<KaskoRepository>()),
    );
    _registerLazy<GetCarsPaginated>(
      () => GetCarsPaginated(_getIt<KaskoRepository>()),
    );
    _registerLazy<GetRates>(() => GetRates(_getIt<KaskoRepository>()));
    _registerLazy<CalculateCarPrice>(
      () => CalculateCarPrice(_getIt<KaskoRepository>()),
    );
    _registerLazy<CalculatePolicy>(
      () => CalculatePolicy(_getIt<KaskoRepository>()),
    );
    _registerLazy<SaveOrder>(() => SaveOrder(_getIt<KaskoRepository>()));
    _registerLazy<GetPaymentLink>(
      () => GetPaymentLink(_getIt<KaskoRepository>()),
    );
    _registerLazy<CheckPaymentStatus>(
      () => CheckPaymentStatus(_getIt<KaskoRepository>()),
    );
    _registerLazy<UploadImage>(() => UploadImage(_getIt<KaskoRepository>()));
    // Accident Use Cases
    _registerLazy<GetTariffs>(() => GetTariffs(_getIt<AccidentRepository>()));
    _registerLazy<GetRegions>(() => GetRegions(_getIt<AccidentRepository>()));
    _registerLazy<CreateInsurance>(
      () => CreateInsurance(_getIt<AccidentRepository>()),
    );
    _registerLazy<CheckPayment>(
      () => CheckPayment(_getIt<AccidentRepository>()),
    );
  }

  static void _registerLazy<T extends Object>(T Function() factoryFunc) {
    if (!_getIt.isRegistered<T>()) {
      _getIt.registerLazySingleton<T>(factoryFunc);
    }
  }

  static void _registerBlocs(AuthService authService) {
    if (_getIt.isRegistered<RegisterBloc>()) {
      _getIt.unregister<RegisterBloc>();
    }
    _getIt.registerFactory<RegisterBloc>(
      () => RegisterBloc(
        sendRegisterOtp: _getIt(),
        confirmRegisterOtp: _getIt(),
        completeRegistration: _getIt(),
        loginUser: _getIt(),
        sendForgotPasswordOtp: _getIt(),
        resetPassword: _getIt(),
        getGoogleRedirect: _getIt(),
        completeGoogleRegistration: _getIt(),
        getProfile: _getIt(),
        updateProfile: _getIt(),
        changeRegion: _getIt(),
        changePassword: _getIt(),
        updateContact: _getIt(),
        confirmUpdateContact: _getIt(),
        logoutUser: _getIt(),
        authService: authService,
      ),
    );
    _getIt.registerFactory<CurrencyBloc>(
      () => CurrencyBloc(getCurrencies: _getIt(), searchBankServices: _getIt()),
    );
    _getIt.registerFactory<MicrocreditBloc>(
      () => MicrocreditBloc(getMicrocredits: _getIt()),
    );
    _getIt.registerFactory<DepositBloc>(
      () => DepositBloc(getDeposits: _getIt()),
    );
    _getIt.registerFactory<MortgageBloc>(
      () => MortgageBloc(getMortgages: _getIt()),
    );
    _getIt.registerFactory<CardBloc>(() => CardBloc(getCardOffers: _getIt()));
    _getIt.registerFactory<TransferAppsBloc>(
      () => TransferAppsBloc(getTransferApps: _getIt()),
    );
    _getIt.registerFactory<KaskoBloc>(
      () => KaskoBloc(
        getCars: _getIt(),
        getCarsMinimal: _getIt(),
        getCarsPaginated: _getIt(),
        getRates: _getIt(),
        calculateCarPrice: _getIt(),
        calculatePolicy: _getIt(),
        saveOrder: _getIt(),
        getPaymentLink: _getIt(),
        checkPaymentStatus: _getIt(),
        uploadImage: _getIt(),
      ),
    );
    // Accident BLoC
    _getIt.registerFactory<AccidentBloc>(
      () => AccidentBloc(
        getTariffs: _getIt(),
        getRegions: _getIt(),
        createInsurance: _getIt(),
        checkPayment: _getIt(),
      ),
    );
    _getIt.registerFactory<PaymentBloc>(
      () => PaymentBloc(repository: _getIt<PaymentRepository>()),
    );
    // Avia BLoC
    _getIt.registerFactory<AviaBloc>(
      () => AviaBloc(
        repository: _getIt<AvichiptalarRepository>(),
        dioClient: _getIt<AviaDioClient>(),
      ),
    );
  }
}
