import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
import '../../services/auth/auth_service.dart';
import '../client/dio_client.dart';

class ServiceLocator {
  ServiceLocator._();

  static final GetIt _getIt = GetIt.instance;

  static Future<void> init() async {
    final authService = AuthService.instance;
    final sharedPreferences = await SharedPreferences.getInstance();

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
    _registerRepositories();
    _registerUseCases();
    _registerBlocs(authService);
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
  }
}
