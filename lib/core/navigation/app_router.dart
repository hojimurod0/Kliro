import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:klero/features/register/presentation/pages/login_page.dart';

import '../../features/auto_credit/presentation/pages/auto_credit_page.dart';
import '../../features/bank/presentation/pages/bank_services_page.dart';
import '../../features/cards/presentation/pages/cards_page.dart';
import '../../features/currency/presentation/pages/currency_rates_page.dart';
import '../../features/currency/presentation/pages/currency_detail_page.dart';
import '../../features/deposit/presentation/pages/deposit_page.dart';
import '../../features/home/presentation/pages/main_navigation_page.dart';
import '../../features/home/presentation/widgets/main_bottom_navigation.dart';
import '../../features/mortgage/presentation/pages/mortgage_page.dart';
import '../../features/insurance/presentation/pages/insurance_services_page.dart';
import '../../features/insurance/presentation/pages/kasko_form_page.dart';
import '../../features/insurance/presentation/pages/kasko_document_data_page.dart';
import '../../features/insurance/presentation/pages/kasko_personal_data_page.dart';
import '../../features/insurance/presentation/pages/kasko_order_details_page.dart';
import '../../features/insurance/presentation/pages/kasko_payment_type_page.dart';
import '../../features/insurance/presentation/pages/kasko_success_page.dart';
import '../../features/kasko/presentation/pages/kasko_form_selection_page.dart';
import '../../features/kasko/presentation/pages/kasko_cars_list_page.dart';
import '../../features/kasko/presentation/pages/kasko_payment_page.dart';
import '../../features/kasko/presentation/pages/kasko_tariff_page.dart';
import '../../features/kasko/kasko_module.dart';
import '../../features/osago/osago_module.dart';
import '../../features/travel/travel/travel_module.dart';
import '../../features/travel/travel/presentation/screens/travel_order_information_screen.dart';
import '../../features/accident/accident_module.dart';
import '../../features/micro_loan/presentation/pages/micro_loan_page.dart';
import '../../features/profile/presentation/pages/profile_edit_page.dart';
import '../../features/profile/presentation/pages/about_app_page.dart';
import '../../features/profile/presentation/pages/support_page.dart';
import '../../features/profile/presentation/pages/support_chat_page.dart';
import '../../features/profile/presentation/pages/security_page.dart';
import '../../features/profile/presentation/pages/my_orders_page.dart';
import '../../features/profile/presentation/pages/booking_details_page.dart';
import '../../features/profile/presentation/pages/amenities_page.dart';
import '../../features/register/presentation/pages/login_forgot_password_page.dart';
import '../../features/register/presentation/pages/login_reset_password_page.dart';
import '../../features/register/presentation/pages/login_verification_page.dart';
import '../../features/register/presentation/pages/login_new_password_page.dart';
import '../../features/register/presentation/pages/onboarding_page.dart';
import '../../features/register/presentation/pages/register_page.dart';
import '../../features/register/presentation/pages/register_verification_screen.dart';
import '../../features/register/presentation/pages/user_details_screen.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/transfer_apps/presentation/pages/transfer_apps_page.dart';
import '../../features/avichiptalar/avichiptalar_module.dart';
import '../../features/avichiptalar/presentation/screens/flight_search_screen.dart';
import '../../features/avichiptalar/presentation/screens/flight_results_screen.dart';
import '../../features/avichiptalar/presentation/screens/flight_details_screen.dart';
import '../../features/avichiptalar/presentation/pages/search_page.dart';
import '../../features/avichiptalar/presentation/pages/offer_detail_page.dart';
import '../../features/avichiptalar/presentation/pages/booking_page.dart';
import '../../features/avichiptalar/presentation/pages/payment_page.dart';
import '../../features/avichiptalar/presentation/pages/status_page.dart';
import '../../features/avichiptalar/presentation/pages/flight_confirmation_page.dart';
import '../../features/avichiptalar/presentation/pages/flight_formalization_page.dart';
import '../../features/avichiptalar/presentation/pages/booking_success_page.dart';
import '../../features/avichiptalar/presentation/pages/avia_my_orders_page.dart';
import '../../features/avichiptalar/data/models/offer_model.dart';
import '../../features/hotel/hotel_module.dart';
import '../../features/avichiptalar/presentation/pages/payment_processing_page.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends _$AppRouter {
  @override
  RouteType get defaultRouteType => const RouteType.material();

  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: SplashRoute.page, initial: true),
        AutoRoute(page: OnboardingRoute.page),
        AutoRoute(page: LoginRoute.page),
        AutoRoute(page: LoginVerificationRoute.page),
        AutoRoute(page: LoginForgotPasswordRoute.page),
        AutoRoute(page: LoginResetPasswordRoute.page),
        AutoRoute(page: LoginNewPasswordRoute.page),
        AutoRoute(page: RegisterRoute.page),
        AutoRoute(page: RegisterVerificationRoute.page),
        AutoRoute(page: UserDetailsRoute.page),
        AutoRoute(page: HomeRoute.page),
        AutoRoute(page: BankServicesRoute.page),
        AutoRoute(page: CurrencyRatesRoute.page),
        AutoRoute(page: CurrencyDetailRoute.page),
        AutoRoute(page: InsuranceServicesRoute.page),
        AutoRoute(page: KaskoFormRoute.page),
        AutoRoute(page: KaskoTariffRoute.page),
        AutoRoute(page: KaskoDocumentDataRoute.page),
        AutoRoute(page: KaskoPersonalDataRoute.page),
        AutoRoute(page: KaskoOrderDetailsRoute.page),
        AutoRoute(page: KaskoPaymentTypeRoute.page),
        AutoRoute(page: KaskoSuccessRoute.page),
        AutoRoute(page: KaskoModuleRoute.page),
        AutoRoute(page: KaskoFormSelectionRoute.page),
        AutoRoute(page: KaskoCarsListRoute.page),
        AutoRoute(page: KaskoPaymentRoute.page),
        AutoRoute(page: OsagoModuleRoute.page),
        AutoRoute(page: TravelModuleRoute.page),
        AutoRoute(page: TravelOrderInformationRoute.page),
        AutoRoute(page: AccidentModuleRoute.page),
        AutoRoute(page: AutoCreditRoute.page),
        AutoRoute(page: MortgageRoute.page),
        AutoRoute(page: CardsRoute.page),
        AutoRoute(page: MicroLoanRoute.page),
        AutoRoute(page: DepositRoute.page),
        AutoRoute(page: TransferAppsRoute.page),
        AutoRoute(page: ProfileEditRoute.page),
        AutoRoute(page: AboutAppRoute.page),
        AutoRoute(page: SupportRoute.page),
        AutoRoute(page: SupportChatRoute.page),
        AutoRoute(page: SecurityRoute.page),
        AutoRoute(page: MyOrdersRoute.page),
        AutoRoute(page: BookingDetailsRoute.page),
        AutoRoute(page: AmenitiesRoute.page),
        AutoRoute(page: AvichiptalarModuleRoute.page),
        AutoRoute(page: FlightSearchRoute.page),
        AutoRoute(page: FlightResultsRoute.page),
        AutoRoute(page: FlightDetailsRoute.page),
        AutoRoute(page: AviaSearchRoute.page),
        AutoRoute(page: OfferDetailRoute.page),
        AutoRoute(page: AviaBookingRoute.page),
        AutoRoute(page: PaymentRoute.page),
        AutoRoute(page: StatusRoute.page),
        AutoRoute(page: FlightConfirmationRoute.page),
        AutoRoute(page: FlightFormalizationRoute.page),
        AutoRoute(page: BookingSuccessRoute.page),
        AutoRoute(page: AviaMyOrdersRoute.page),
        AutoRoute(page: HotelModuleRoute.page),
        AutoRoute(page: PaymentProcessingRoute.page),
      ];
}
