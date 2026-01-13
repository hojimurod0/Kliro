// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

abstract class _$AppRouter extends RootStackRouter {
  // ignore: unused_element
  _$AppRouter({super.navigatorKey});

  @override
  final Map<String, PageFactory> pagesMap = {
    AboutAppRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const AboutAppPage(),
      );
    },
    AccidentModuleRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const AccidentModule(),
      );
    },
    AmenitiesRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const AmenitiesPage(),
      );
    },
    AutoCreditRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const AutoCreditPage(),
      );
    },
    AviaMyOrdersRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const AviaMyOrdersPage(),
      );
    },
    AvichiptalarModuleRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const AvichiptalarModule(),
      );
    },
    BankServicesRoute.name: (routeData) {
      final args = routeData.argsAs<BankServicesRouteArgs>(
          orElse: () => const BankServicesRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: BankServicesPage(key: args.key),
      );
    },
    BookingDetailsRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const BookingDetailsPage(),
      );
    },
    AviaBookingRoute.name: (routeData) {
      final args = routeData.argsAs<AviaBookingRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: BookingPage(
          key: args.key,
          offerId: args.offerId,
        ),
      );
    },
    BookingSuccessRoute.name: (routeData) {
      final args = routeData.argsAs<BookingSuccessRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: WrappedRoute(
            child: BookingSuccessPage(
          key: args.key,
          outboundOffer: args.outboundOffer,
          returnOffer: args.returnOffer,
          bookingId: args.bookingId,
        )),
      );
    },
    CardsRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const CardsPage(),
      );
    },
    CurrencyDetailRoute.name: (routeData) {
      final args = routeData.argsAs<CurrencyDetailRouteArgs>(
          orElse: () => const CurrencyDetailRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: CurrencyDetailPage(
          key: args.key,
          bankName: args.bankName,
          currencyCode: args.currencyCode,
          buyRate: args.buyRate,
          sellRate: args.sellRate,
        ),
      );
    },
    CurrencyRatesRoute.name: (routeData) {
      final args = routeData.argsAs<CurrencyRatesRouteArgs>(
          orElse: () => const CurrencyRatesRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: CurrencyRatesPage(key: args.key),
      );
    },
    DepositRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const DepositPage(),
      );
    },
    FlightConfirmationRoute.name: (routeData) {
      final args = routeData.argsAs<FlightConfirmationRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: FlightConfirmationPage(
          key: args.key,
          outboundOffer: args.outboundOffer,
          returnOffer: args.returnOffer,
          totalPrice: args.totalPrice,
          currency: args.currency,
          adults: args.adults,
          childrenCount: args.childrenCount,
          babies: args.babies,
        ),
      );
    },
    FlightDetailsRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const FlightDetailsScreen(),
      );
    },
    FlightFormalizationRoute.name: (routeData) {
      final args = routeData.argsAs<FlightFormalizationRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: WrappedRoute(
            child: FlightFormalizationPage(
          key: args.key,
          outboundOffer: args.outboundOffer,
          returnOffer: args.returnOffer,
          totalPrice: args.totalPrice,
          currency: args.currency,
          adults: args.adults,
          childrenCount: args.childrenCount,
          babies: args.babies,
        )),
      );
    },
    FlightResultsRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const FlightResultsScreen(),
      );
    },
    FlightSearchRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const FlightSearchScreen(),
      );
    },
    HotelModuleRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const HotelModule(),
      );
    },
    InsuranceServicesRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const InsuranceServicesPage(),
      );
    },
    KaskoCarsListRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const KaskoCarsListPage(),
      );
    },
    KaskoDocumentDataRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const KaskoDocumentDataPage(),
      );
    },
    KaskoFormRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const KaskoFormPage(),
      );
    },
    KaskoFormSelectionRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const KaskoFormSelectionPage(),
      );
    },
    KaskoModuleRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const KaskoModule(),
      );
    },
    KaskoOrderDetailsRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const KaskoOrderDetailsPage(),
      );
    },
    KaskoPaymentRoute.name: (routeData) {
      final args = routeData.argsAs<KaskoPaymentRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: KaskoPaymentPage(
          key: args.key,
          orderId: args.orderId,
          amount: args.amount,
          clickUrl: args.clickUrl,
          paymeUrl: args.paymeUrl,
          paymentMethod: args.paymentMethod,
        ),
      );
    },
    KaskoPaymentTypeRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const KaskoPaymentTypePage(),
      );
    },
    KaskoPersonalDataRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const KaskoPersonalDataPage(),
      );
    },
    KaskoSuccessRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const KaskoSuccessPage(),
      );
    },
    KaskoTariffRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const KaskoTariffPage(),
      );
    },
    LoginForgotPasswordRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: WrappedRoute(child: const LoginForgotPasswordPage()),
      );
    },
    LoginNewPasswordRoute.name: (routeData) {
      final args = routeData.argsAs<LoginNewPasswordRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: WrappedRoute(
            child: LoginNewPasswordPage(
          key: args.key,
          contactInfo: args.contactInfo,
          otp: args.otp,
        )),
      );
    },
    LoginRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: WrappedRoute(child: const LoginPage()),
      );
    },
    LoginResetPasswordRoute.name: (routeData) {
      final args = routeData.argsAs<LoginResetPasswordRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: WrappedRoute(
            child: LoginResetPasswordPage(
          key: args.key,
          contactInfo: args.contactInfo,
        )),
      );
    },
    LoginVerificationRoute.name: (routeData) {
      final args = routeData.argsAs<LoginVerificationRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: LoginVerificationPage(
          key: args.key,
          phoneNumber: args.phoneNumber,
        ),
      );
    },
    HomeRoute.name: (routeData) {
      final args =
          routeData.argsAs<HomeRouteArgs>(orElse: () => const HomeRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: MainNavigationPage(
          key: args.key,
          initialTab: args.initialTab,
        ),
      );
    },
    MicroLoanRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const MicroLoanPage(),
      );
    },
    MortgageRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const MortgagePage(),
      );
    },
    MyOrdersRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const MyOrdersPage(),
      );
    },
    OfferDetailRoute.name: (routeData) {
      final args = routeData.argsAs<OfferDetailRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: OfferDetailPage(
          key: args.key,
          offerId: args.offerId,
        ),
      );
    },
    OnboardingRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const OnboardingPage(),
      );
    },
    OsagoModuleRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const OsagoModule(),
      );
    },
    PaymentRoute.name: (routeData) {
      final args = routeData.argsAs<PaymentRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: PaymentPage(
          key: args.key,
          bookingId: args.bookingId,
        ),
      );
    },
    PaymentProcessingRoute.name: (routeData) {
      final args = routeData.argsAs<PaymentProcessingRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: PaymentProcessingPage(
          key: args.key,
          uuid: args.uuid,
          checkoutUrl: args.checkoutUrl,
          returnUrl: args.returnUrl,
        ),
      );
    },
    ProfileEditRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const ProfileEditPage(),
      );
    },
    RegisterRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: WrappedRoute(child: const RegisterPage()),
      );
    },
    RegisterVerificationRoute.name: (routeData) {
      final args = routeData.argsAs<RegisterVerificationRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: RegisterVerificationScreen(
          key: args.key,
          contactInfo: args.contactInfo,
        ),
      );
    },
    AviaSearchRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const SearchPage(),
      );
    },
    SecurityRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const SecurityPage(),
      );
    },
    SplashRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const SplashPage(),
      );
    },
    StatusRoute.name: (routeData) {
      final args = routeData.argsAs<StatusRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: StatusPage(
          key: args.key,
          bookingId: args.bookingId,
          status: args.status,
        ),
      );
    },
    SupportChatRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const SupportChatPage(),
      );
    },
    SupportRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const SupportPage(),
      );
    },
    TransferAppsRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const TransferAppsPage(),
      );
    },
    TravelModuleRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const TravelModule(),
      );
    },
    TravelOrderInformationRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const TravelOrderInformationScreen(),
      );
    },
    UserDetailsRoute.name: (routeData) {
      final args = routeData.argsAs<UserDetailsRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: WrappedRoute(
            child: UserDetailsScreen(
          key: args.key,
          contactInfo: args.contactInfo,
        )),
      );
    },
    GoogleCompleteFormRoute.name: (routeData) {
      final args = routeData.argsAs<GoogleCompleteFormRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: WrappedRoute(
            child: GoogleCompleteFormPage(
          key: args.key,
          sessionId: args.sessionId,
        )),
      );
    },
  };
}

/// generated route for
/// [AboutAppPage]
class AboutAppRoute extends PageRouteInfo<void> {
  const AboutAppRoute({List<PageRouteInfo>? children})
      : super(
          AboutAppRoute.name,
          initialChildren: children,
        );

  static const String name = 'AboutAppRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [AccidentModule]
class AccidentModuleRoute extends PageRouteInfo<void> {
  const AccidentModuleRoute({List<PageRouteInfo>? children})
      : super(
          AccidentModuleRoute.name,
          initialChildren: children,
        );

  static const String name = 'AccidentModuleRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [AmenitiesPage]
class AmenitiesRoute extends PageRouteInfo<void> {
  const AmenitiesRoute({List<PageRouteInfo>? children})
      : super(
          AmenitiesRoute.name,
          initialChildren: children,
        );

  static const String name = 'AmenitiesRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [AutoCreditPage]
class AutoCreditRoute extends PageRouteInfo<void> {
  const AutoCreditRoute({List<PageRouteInfo>? children})
      : super(
          AutoCreditRoute.name,
          initialChildren: children,
        );

  static const String name = 'AutoCreditRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [AviaMyOrdersPage]
class AviaMyOrdersRoute extends PageRouteInfo<void> {
  const AviaMyOrdersRoute({List<PageRouteInfo>? children})
      : super(
          AviaMyOrdersRoute.name,
          initialChildren: children,
        );

  static const String name = 'AviaMyOrdersRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [AvichiptalarModule]
class AvichiptalarModuleRoute extends PageRouteInfo<void> {
  const AvichiptalarModuleRoute({List<PageRouteInfo>? children})
      : super(
          AvichiptalarModuleRoute.name,
          initialChildren: children,
        );

  static const String name = 'AvichiptalarModuleRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [BankServicesPage]
class BankServicesRoute extends PageRouteInfo<BankServicesRouteArgs> {
  BankServicesRoute({
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          BankServicesRoute.name,
          args: BankServicesRouteArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'BankServicesRoute';

  static const PageInfo<BankServicesRouteArgs> page =
      PageInfo<BankServicesRouteArgs>(name);
}

class BankServicesRouteArgs {
  const BankServicesRouteArgs({this.key});

  final Key? key;

  @override
  String toString() {
    return 'BankServicesRouteArgs{key: $key}';
  }
}

/// generated route for
/// [BookingDetailsPage]
class BookingDetailsRoute extends PageRouteInfo<void> {
  const BookingDetailsRoute({List<PageRouteInfo>? children})
      : super(
          BookingDetailsRoute.name,
          initialChildren: children,
        );

  static const String name = 'BookingDetailsRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [BookingPage]
class AviaBookingRoute extends PageRouteInfo<AviaBookingRouteArgs> {
  AviaBookingRoute({
    Key? key,
    required String offerId,
    List<PageRouteInfo>? children,
  }) : super(
          AviaBookingRoute.name,
          args: AviaBookingRouteArgs(
            key: key,
            offerId: offerId,
          ),
          initialChildren: children,
        );

  static const String name = 'AviaBookingRoute';

  static const PageInfo<AviaBookingRouteArgs> page =
      PageInfo<AviaBookingRouteArgs>(name);
}

class AviaBookingRouteArgs {
  const AviaBookingRouteArgs({
    this.key,
    required this.offerId,
  });

  final Key? key;

  final String offerId;

  @override
  String toString() {
    return 'AviaBookingRouteArgs{key: $key, offerId: $offerId}';
  }
}

/// generated route for
/// [BookingSuccessPage]
class BookingSuccessRoute extends PageRouteInfo<BookingSuccessRouteArgs> {
  BookingSuccessRoute({
    Key? key,
    required OfferModel outboundOffer,
    OfferModel? returnOffer,
    required String bookingId,
    List<PageRouteInfo>? children,
  }) : super(
          BookingSuccessRoute.name,
          args: BookingSuccessRouteArgs(
            key: key,
            outboundOffer: outboundOffer,
            returnOffer: returnOffer,
            bookingId: bookingId,
          ),
          initialChildren: children,
        );

  static const String name = 'BookingSuccessRoute';

  static const PageInfo<BookingSuccessRouteArgs> page =
      PageInfo<BookingSuccessRouteArgs>(name);
}

class BookingSuccessRouteArgs {
  const BookingSuccessRouteArgs({
    this.key,
    required this.outboundOffer,
    this.returnOffer,
    required this.bookingId,
  });

  final Key? key;

  final OfferModel outboundOffer;

  final OfferModel? returnOffer;

  final String bookingId;

  @override
  String toString() {
    return 'BookingSuccessRouteArgs{key: $key, outboundOffer: $outboundOffer, returnOffer: $returnOffer, bookingId: $bookingId}';
  }
}

/// generated route for
/// [CardsPage]
class CardsRoute extends PageRouteInfo<void> {
  const CardsRoute({List<PageRouteInfo>? children})
      : super(
          CardsRoute.name,
          initialChildren: children,
        );

  static const String name = 'CardsRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [CurrencyDetailPage]
class CurrencyDetailRoute extends PageRouteInfo<CurrencyDetailRouteArgs> {
  CurrencyDetailRoute({
    Key? key,
    String? bankName,
    String? currencyCode,
    double? buyRate,
    double? sellRate,
    List<PageRouteInfo>? children,
  }) : super(
          CurrencyDetailRoute.name,
          args: CurrencyDetailRouteArgs(
            key: key,
            bankName: bankName,
            currencyCode: currencyCode,
            buyRate: buyRate,
            sellRate: sellRate,
          ),
          initialChildren: children,
        );

  static const String name = 'CurrencyDetailRoute';

  static const PageInfo<CurrencyDetailRouteArgs> page =
      PageInfo<CurrencyDetailRouteArgs>(name);
}

class CurrencyDetailRouteArgs {
  const CurrencyDetailRouteArgs({
    this.key,
    this.bankName,
    this.currencyCode,
    this.buyRate,
    this.sellRate,
  });

  final Key? key;

  final String? bankName;

  final String? currencyCode;

  final double? buyRate;

  final double? sellRate;

  @override
  String toString() {
    return 'CurrencyDetailRouteArgs{key: $key, bankName: $bankName, currencyCode: $currencyCode, buyRate: $buyRate, sellRate: $sellRate}';
  }
}

/// generated route for
/// [CurrencyRatesPage]
class CurrencyRatesRoute extends PageRouteInfo<CurrencyRatesRouteArgs> {
  CurrencyRatesRoute({
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          CurrencyRatesRoute.name,
          args: CurrencyRatesRouteArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'CurrencyRatesRoute';

  static const PageInfo<CurrencyRatesRouteArgs> page =
      PageInfo<CurrencyRatesRouteArgs>(name);
}

class CurrencyRatesRouteArgs {
  const CurrencyRatesRouteArgs({this.key});

  final Key? key;

  @override
  String toString() {
    return 'CurrencyRatesRouteArgs{key: $key}';
  }
}

/// generated route for
/// [DepositPage]
class DepositRoute extends PageRouteInfo<void> {
  const DepositRoute({List<PageRouteInfo>? children})
      : super(
          DepositRoute.name,
          initialChildren: children,
        );

  static const String name = 'DepositRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [FlightConfirmationPage]
class FlightConfirmationRoute
    extends PageRouteInfo<FlightConfirmationRouteArgs> {
  FlightConfirmationRoute({
    Key? key,
    required OfferModel outboundOffer,
    OfferModel? returnOffer,
    required String totalPrice,
    required String currency,
    int adults = 1,
    int childrenCount = 0,
    int babies = 0,
    List<PageRouteInfo>? children,
  }) : super(
          FlightConfirmationRoute.name,
          args: FlightConfirmationRouteArgs(
            key: key,
            outboundOffer: outboundOffer,
            returnOffer: returnOffer,
            totalPrice: totalPrice,
            currency: currency,
            adults: adults,
            childrenCount: childrenCount,
            babies: babies,
          ),
          initialChildren: children,
        );

  static const String name = 'FlightConfirmationRoute';

  static const PageInfo<FlightConfirmationRouteArgs> page =
      PageInfo<FlightConfirmationRouteArgs>(name);
}

class FlightConfirmationRouteArgs {
  const FlightConfirmationRouteArgs({
    this.key,
    required this.outboundOffer,
    this.returnOffer,
    required this.totalPrice,
    required this.currency,
    this.adults = 1,
    this.childrenCount = 0,
    this.babies = 0,
  });

  final Key? key;

  final OfferModel outboundOffer;

  final OfferModel? returnOffer;

  final String totalPrice;

  final String currency;

  final int adults;

  final int childrenCount;

  final int babies;

  @override
  String toString() {
    return 'FlightConfirmationRouteArgs{key: $key, outboundOffer: $outboundOffer, returnOffer: $returnOffer, totalPrice: $totalPrice, currency: $currency, adults: $adults, childrenCount: $childrenCount, babies: $babies}';
  }
}

/// generated route for
/// [FlightDetailsScreen]
class FlightDetailsRoute extends PageRouteInfo<void> {
  const FlightDetailsRoute({List<PageRouteInfo>? children})
      : super(
          FlightDetailsRoute.name,
          initialChildren: children,
        );

  static const String name = 'FlightDetailsRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [FlightFormalizationPage]
class FlightFormalizationRoute
    extends PageRouteInfo<FlightFormalizationRouteArgs> {
  FlightFormalizationRoute({
    Key? key,
    required OfferModel outboundOffer,
    OfferModel? returnOffer,
    required String totalPrice,
    required String currency,
    int adults = 1,
    int childrenCount = 0,
    int babies = 0,
    List<PageRouteInfo>? children,
  }) : super(
          FlightFormalizationRoute.name,
          args: FlightFormalizationRouteArgs(
            key: key,
            outboundOffer: outboundOffer,
            returnOffer: returnOffer,
            totalPrice: totalPrice,
            currency: currency,
            adults: adults,
            childrenCount: childrenCount,
            babies: babies,
          ),
          initialChildren: children,
        );

  static const String name = 'FlightFormalizationRoute';

  static const PageInfo<FlightFormalizationRouteArgs> page =
      PageInfo<FlightFormalizationRouteArgs>(name);
}

class FlightFormalizationRouteArgs {
  const FlightFormalizationRouteArgs({
    this.key,
    required this.outboundOffer,
    this.returnOffer,
    required this.totalPrice,
    required this.currency,
    this.adults = 1,
    this.childrenCount = 0,
    this.babies = 0,
  });

  final Key? key;

  final OfferModel outboundOffer;

  final OfferModel? returnOffer;

  final String totalPrice;

  final String currency;

  final int adults;

  final int childrenCount;

  final int babies;

  @override
  String toString() {
    return 'FlightFormalizationRouteArgs{key: $key, outboundOffer: $outboundOffer, returnOffer: $returnOffer, totalPrice: $totalPrice, currency: $currency, adults: $adults, childrenCount: $childrenCount, babies: $babies}';
  }
}

/// generated route for
/// [FlightResultsScreen]
class FlightResultsRoute extends PageRouteInfo<void> {
  const FlightResultsRoute({List<PageRouteInfo>? children})
      : super(
          FlightResultsRoute.name,
          initialChildren: children,
        );

  static const String name = 'FlightResultsRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [FlightSearchScreen]
class FlightSearchRoute extends PageRouteInfo<void> {
  const FlightSearchRoute({List<PageRouteInfo>? children})
      : super(
          FlightSearchRoute.name,
          initialChildren: children,
        );

  static const String name = 'FlightSearchRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [HotelModule]
class HotelModuleRoute extends PageRouteInfo<void> {
  const HotelModuleRoute({List<PageRouteInfo>? children})
      : super(
          HotelModuleRoute.name,
          initialChildren: children,
        );

  static const String name = 'HotelModuleRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [InsuranceServicesPage]
class InsuranceServicesRoute extends PageRouteInfo<void> {
  const InsuranceServicesRoute({List<PageRouteInfo>? children})
      : super(
          InsuranceServicesRoute.name,
          initialChildren: children,
        );

  static const String name = 'InsuranceServicesRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [KaskoCarsListPage]
class KaskoCarsListRoute extends PageRouteInfo<void> {
  const KaskoCarsListRoute({List<PageRouteInfo>? children})
      : super(
          KaskoCarsListRoute.name,
          initialChildren: children,
        );

  static const String name = 'KaskoCarsListRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [KaskoDocumentDataPage]
class KaskoDocumentDataRoute extends PageRouteInfo<void> {
  const KaskoDocumentDataRoute({List<PageRouteInfo>? children})
      : super(
          KaskoDocumentDataRoute.name,
          initialChildren: children,
        );

  static const String name = 'KaskoDocumentDataRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [KaskoFormPage]
class KaskoFormRoute extends PageRouteInfo<void> {
  const KaskoFormRoute({List<PageRouteInfo>? children})
      : super(
          KaskoFormRoute.name,
          initialChildren: children,
        );

  static const String name = 'KaskoFormRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [KaskoFormSelectionPage]
class KaskoFormSelectionRoute extends PageRouteInfo<void> {
  const KaskoFormSelectionRoute({List<PageRouteInfo>? children})
      : super(
          KaskoFormSelectionRoute.name,
          initialChildren: children,
        );

  static const String name = 'KaskoFormSelectionRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [KaskoModule]
class KaskoModuleRoute extends PageRouteInfo<void> {
  const KaskoModuleRoute({List<PageRouteInfo>? children})
      : super(
          KaskoModuleRoute.name,
          initialChildren: children,
        );

  static const String name = 'KaskoModuleRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [KaskoOrderDetailsPage]
class KaskoOrderDetailsRoute extends PageRouteInfo<void> {
  const KaskoOrderDetailsRoute({List<PageRouteInfo>? children})
      : super(
          KaskoOrderDetailsRoute.name,
          initialChildren: children,
        );

  static const String name = 'KaskoOrderDetailsRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [KaskoPaymentPage]
class KaskoPaymentRoute extends PageRouteInfo<KaskoPaymentRouteArgs> {
  KaskoPaymentRoute({
    Key? key,
    required String orderId,
    required double amount,
    String? clickUrl,
    String? paymeUrl,
    required String paymentMethod,
    List<PageRouteInfo>? children,
  }) : super(
          KaskoPaymentRoute.name,
          args: KaskoPaymentRouteArgs(
            key: key,
            orderId: orderId,
            amount: amount,
            clickUrl: clickUrl,
            paymeUrl: paymeUrl,
            paymentMethod: paymentMethod,
          ),
          initialChildren: children,
        );

  static const String name = 'KaskoPaymentRoute';

  static const PageInfo<KaskoPaymentRouteArgs> page =
      PageInfo<KaskoPaymentRouteArgs>(name);
}

class KaskoPaymentRouteArgs {
  const KaskoPaymentRouteArgs({
    this.key,
    required this.orderId,
    required this.amount,
    this.clickUrl,
    this.paymeUrl,
    required this.paymentMethod,
  });

  final Key? key;

  final String orderId;

  final double amount;

  final String? clickUrl;

  final String? paymeUrl;

  final String paymentMethod;

  @override
  String toString() {
    return 'KaskoPaymentRouteArgs{key: $key, orderId: $orderId, amount: $amount, clickUrl: $clickUrl, paymeUrl: $paymeUrl, paymentMethod: $paymentMethod}';
  }
}

/// generated route for
/// [KaskoPaymentTypePage]
class KaskoPaymentTypeRoute extends PageRouteInfo<void> {
  const KaskoPaymentTypeRoute({List<PageRouteInfo>? children})
      : super(
          KaskoPaymentTypeRoute.name,
          initialChildren: children,
        );

  static const String name = 'KaskoPaymentTypeRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [KaskoPersonalDataPage]
class KaskoPersonalDataRoute extends PageRouteInfo<void> {
  const KaskoPersonalDataRoute({List<PageRouteInfo>? children})
      : super(
          KaskoPersonalDataRoute.name,
          initialChildren: children,
        );

  static const String name = 'KaskoPersonalDataRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [KaskoSuccessPage]
class KaskoSuccessRoute extends PageRouteInfo<void> {
  const KaskoSuccessRoute({List<PageRouteInfo>? children})
      : super(
          KaskoSuccessRoute.name,
          initialChildren: children,
        );

  static const String name = 'KaskoSuccessRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [KaskoTariffPage]
class KaskoTariffRoute extends PageRouteInfo<void> {
  const KaskoTariffRoute({List<PageRouteInfo>? children})
      : super(
          KaskoTariffRoute.name,
          initialChildren: children,
        );

  static const String name = 'KaskoTariffRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [LoginForgotPasswordPage]
class LoginForgotPasswordRoute extends PageRouteInfo<void> {
  const LoginForgotPasswordRoute({List<PageRouteInfo>? children})
      : super(
          LoginForgotPasswordRoute.name,
          initialChildren: children,
        );

  static const String name = 'LoginForgotPasswordRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [LoginNewPasswordPage]
class LoginNewPasswordRoute extends PageRouteInfo<LoginNewPasswordRouteArgs> {
  LoginNewPasswordRoute({
    Key? key,
    required String contactInfo,
    required String otp,
    List<PageRouteInfo>? children,
  }) : super(
          LoginNewPasswordRoute.name,
          args: LoginNewPasswordRouteArgs(
            key: key,
            contactInfo: contactInfo,
            otp: otp,
          ),
          initialChildren: children,
        );

  static const String name = 'LoginNewPasswordRoute';

  static const PageInfo<LoginNewPasswordRouteArgs> page =
      PageInfo<LoginNewPasswordRouteArgs>(name);
}

class LoginNewPasswordRouteArgs {
  const LoginNewPasswordRouteArgs({
    this.key,
    required this.contactInfo,
    required this.otp,
  });

  final Key? key;

  final String contactInfo;

  final String otp;

  @override
  String toString() {
    return 'LoginNewPasswordRouteArgs{key: $key, contactInfo: $contactInfo, otp: $otp}';
  }
}

/// generated route for
/// [LoginPage]
class LoginRoute extends PageRouteInfo<void> {
  const LoginRoute({List<PageRouteInfo>? children})
      : super(
          LoginRoute.name,
          initialChildren: children,
        );

  static const String name = 'LoginRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [LoginResetPasswordPage]
class LoginResetPasswordRoute
    extends PageRouteInfo<LoginResetPasswordRouteArgs> {
  LoginResetPasswordRoute({
    Key? key,
    required String contactInfo,
    List<PageRouteInfo>? children,
  }) : super(
          LoginResetPasswordRoute.name,
          args: LoginResetPasswordRouteArgs(
            key: key,
            contactInfo: contactInfo,
          ),
          initialChildren: children,
        );

  static const String name = 'LoginResetPasswordRoute';

  static const PageInfo<LoginResetPasswordRouteArgs> page =
      PageInfo<LoginResetPasswordRouteArgs>(name);
}

class LoginResetPasswordRouteArgs {
  const LoginResetPasswordRouteArgs({
    this.key,
    required this.contactInfo,
  });

  final Key? key;

  final String contactInfo;

  @override
  String toString() {
    return 'LoginResetPasswordRouteArgs{key: $key, contactInfo: $contactInfo}';
  }
}

/// generated route for
/// [LoginVerificationPage]
class LoginVerificationRoute extends PageRouteInfo<LoginVerificationRouteArgs> {
  LoginVerificationRoute({
    Key? key,
    required String phoneNumber,
    List<PageRouteInfo>? children,
  }) : super(
          LoginVerificationRoute.name,
          args: LoginVerificationRouteArgs(
            key: key,
            phoneNumber: phoneNumber,
          ),
          initialChildren: children,
        );

  static const String name = 'LoginVerificationRoute';

  static const PageInfo<LoginVerificationRouteArgs> page =
      PageInfo<LoginVerificationRouteArgs>(name);
}

class LoginVerificationRouteArgs {
  const LoginVerificationRouteArgs({
    this.key,
    required this.phoneNumber,
  });

  final Key? key;

  final String phoneNumber;

  @override
  String toString() {
    return 'LoginVerificationRouteArgs{key: $key, phoneNumber: $phoneNumber}';
  }
}

/// generated route for
/// [MainNavigationPage]
class HomeRoute extends PageRouteInfo<HomeRouteArgs> {
  HomeRoute({
    Key? key,
    TabItem initialTab = TabItem.home,
    List<PageRouteInfo>? children,
  }) : super(
          HomeRoute.name,
          args: HomeRouteArgs(
            key: key,
            initialTab: initialTab,
          ),
          initialChildren: children,
        );

  static const String name = 'HomeRoute';

  static const PageInfo<HomeRouteArgs> page = PageInfo<HomeRouteArgs>(name);
}

class HomeRouteArgs {
  const HomeRouteArgs({
    this.key,
    this.initialTab = TabItem.home,
  });

  final Key? key;

  final TabItem initialTab;

  @override
  String toString() {
    return 'HomeRouteArgs{key: $key, initialTab: $initialTab}';
  }
}

/// generated route for
/// [MicroLoanPage]
class MicroLoanRoute extends PageRouteInfo<void> {
  const MicroLoanRoute({List<PageRouteInfo>? children})
      : super(
          MicroLoanRoute.name,
          initialChildren: children,
        );

  static const String name = 'MicroLoanRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [MortgagePage]
class MortgageRoute extends PageRouteInfo<void> {
  const MortgageRoute({List<PageRouteInfo>? children})
      : super(
          MortgageRoute.name,
          initialChildren: children,
        );

  static const String name = 'MortgageRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [MyOrdersPage]
class MyOrdersRoute extends PageRouteInfo<void> {
  const MyOrdersRoute({List<PageRouteInfo>? children})
      : super(
          MyOrdersRoute.name,
          initialChildren: children,
        );

  static const String name = 'MyOrdersRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [OfferDetailPage]
class OfferDetailRoute extends PageRouteInfo<OfferDetailRouteArgs> {
  OfferDetailRoute({
    Key? key,
    required String offerId,
    List<PageRouteInfo>? children,
  }) : super(
          OfferDetailRoute.name,
          args: OfferDetailRouteArgs(
            key: key,
            offerId: offerId,
          ),
          initialChildren: children,
        );

  static const String name = 'OfferDetailRoute';

  static const PageInfo<OfferDetailRouteArgs> page =
      PageInfo<OfferDetailRouteArgs>(name);
}

class OfferDetailRouteArgs {
  const OfferDetailRouteArgs({
    this.key,
    required this.offerId,
  });

  final Key? key;

  final String offerId;

  @override
  String toString() {
    return 'OfferDetailRouteArgs{key: $key, offerId: $offerId}';
  }
}

/// generated route for
/// [OnboardingPage]
class OnboardingRoute extends PageRouteInfo<void> {
  const OnboardingRoute({List<PageRouteInfo>? children})
      : super(
          OnboardingRoute.name,
          initialChildren: children,
        );

  static const String name = 'OnboardingRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [OsagoModule]
class OsagoModuleRoute extends PageRouteInfo<void> {
  const OsagoModuleRoute({List<PageRouteInfo>? children})
      : super(
          OsagoModuleRoute.name,
          initialChildren: children,
        );

  static const String name = 'OsagoModuleRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [PaymentPage]
class PaymentRoute extends PageRouteInfo<PaymentRouteArgs> {
  PaymentRoute({
    Key? key,
    required String bookingId,
    List<PageRouteInfo>? children,
  }) : super(
          PaymentRoute.name,
          args: PaymentRouteArgs(
            key: key,
            bookingId: bookingId,
          ),
          initialChildren: children,
        );

  static const String name = 'PaymentRoute';

  static const PageInfo<PaymentRouteArgs> page =
      PageInfo<PaymentRouteArgs>(name);
}

class PaymentRouteArgs {
  const PaymentRouteArgs({
    this.key,
    required this.bookingId,
  });

  final Key? key;

  final String bookingId;

  @override
  String toString() {
    return 'PaymentRouteArgs{key: $key, bookingId: $bookingId}';
  }
}

/// generated route for
/// [PaymentProcessingPage]
class PaymentProcessingRoute extends PageRouteInfo<PaymentProcessingRouteArgs> {
  PaymentProcessingRoute({
    Key? key,
    required String uuid,
    required String checkoutUrl,
    required String returnUrl,
    List<PageRouteInfo>? children,
  }) : super(
          PaymentProcessingRoute.name,
          args: PaymentProcessingRouteArgs(
            key: key,
            uuid: uuid,
            checkoutUrl: checkoutUrl,
            returnUrl: returnUrl,
          ),
          initialChildren: children,
        );

  static const String name = 'PaymentProcessingRoute';

  static const PageInfo<PaymentProcessingRouteArgs> page =
      PageInfo<PaymentProcessingRouteArgs>(name);
}

class PaymentProcessingRouteArgs {
  const PaymentProcessingRouteArgs({
    this.key,
    required this.uuid,
    required this.checkoutUrl,
    required this.returnUrl,
  });

  final Key? key;

  final String uuid;

  final String checkoutUrl;

  final String returnUrl;

  @override
  String toString() {
    return 'PaymentProcessingRouteArgs{key: $key, uuid: $uuid, checkoutUrl: $checkoutUrl, returnUrl: $returnUrl}';
  }
}

/// generated route for
/// [ProfileEditPage]
class ProfileEditRoute extends PageRouteInfo<void> {
  const ProfileEditRoute({List<PageRouteInfo>? children})
      : super(
          ProfileEditRoute.name,
          initialChildren: children,
        );

  static const String name = 'ProfileEditRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [RegisterPage]
class RegisterRoute extends PageRouteInfo<void> {
  const RegisterRoute({List<PageRouteInfo>? children})
      : super(
          RegisterRoute.name,
          initialChildren: children,
        );

  static const String name = 'RegisterRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [RegisterVerificationScreen]
class RegisterVerificationRoute
    extends PageRouteInfo<RegisterVerificationRouteArgs> {
  RegisterVerificationRoute({
    Key? key,
    required String contactInfo,
    List<PageRouteInfo>? children,
  }) : super(
          RegisterVerificationRoute.name,
          args: RegisterVerificationRouteArgs(
            key: key,
            contactInfo: contactInfo,
          ),
          initialChildren: children,
        );

  static const String name = 'RegisterVerificationRoute';

  static const PageInfo<RegisterVerificationRouteArgs> page =
      PageInfo<RegisterVerificationRouteArgs>(name);
}

class RegisterVerificationRouteArgs {
  const RegisterVerificationRouteArgs({
    this.key,
    required this.contactInfo,
  });

  final Key? key;

  final String contactInfo;

  @override
  String toString() {
    return 'RegisterVerificationRouteArgs{key: $key, contactInfo: $contactInfo}';
  }
}

/// generated route for
/// [SearchPage]
class AviaSearchRoute extends PageRouteInfo<void> {
  const AviaSearchRoute({List<PageRouteInfo>? children})
      : super(
          AviaSearchRoute.name,
          initialChildren: children,
        );

  static const String name = 'AviaSearchRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [SecurityPage]
class SecurityRoute extends PageRouteInfo<void> {
  const SecurityRoute({List<PageRouteInfo>? children})
      : super(
          SecurityRoute.name,
          initialChildren: children,
        );

  static const String name = 'SecurityRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [SplashPage]
class SplashRoute extends PageRouteInfo<void> {
  const SplashRoute({List<PageRouteInfo>? children})
      : super(
          SplashRoute.name,
          initialChildren: children,
        );

  static const String name = 'SplashRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [StatusPage]
class StatusRoute extends PageRouteInfo<StatusRouteArgs> {
  StatusRoute({
    Key? key,
    required String bookingId,
    required String status,
    List<PageRouteInfo>? children,
  }) : super(
          StatusRoute.name,
          args: StatusRouteArgs(
            key: key,
            bookingId: bookingId,
            status: status,
          ),
          initialChildren: children,
        );

  static const String name = 'StatusRoute';

  static const PageInfo<StatusRouteArgs> page = PageInfo<StatusRouteArgs>(name);
}

class StatusRouteArgs {
  const StatusRouteArgs({
    this.key,
    required this.bookingId,
    required this.status,
  });

  final Key? key;

  final String bookingId;

  final String status;

  @override
  String toString() {
    return 'StatusRouteArgs{key: $key, bookingId: $bookingId, status: $status}';
  }
}

/// generated route for
/// [SupportChatPage]
class SupportChatRoute extends PageRouteInfo<void> {
  const SupportChatRoute({List<PageRouteInfo>? children})
      : super(
          SupportChatRoute.name,
          initialChildren: children,
        );

  static const String name = 'SupportChatRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [SupportPage]
class SupportRoute extends PageRouteInfo<void> {
  const SupportRoute({List<PageRouteInfo>? children})
      : super(
          SupportRoute.name,
          initialChildren: children,
        );

  static const String name = 'SupportRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [TransferAppsPage]
class TransferAppsRoute extends PageRouteInfo<void> {
  const TransferAppsRoute({List<PageRouteInfo>? children})
      : super(
          TransferAppsRoute.name,
          initialChildren: children,
        );

  static const String name = 'TransferAppsRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [TravelModule]
class TravelModuleRoute extends PageRouteInfo<void> {
  const TravelModuleRoute({List<PageRouteInfo>? children})
      : super(
          TravelModuleRoute.name,
          initialChildren: children,
        );

  static const String name = 'TravelModuleRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [TravelOrderInformationScreen]
class TravelOrderInformationRoute extends PageRouteInfo<void> {
  const TravelOrderInformationRoute({List<PageRouteInfo>? children})
      : super(
          TravelOrderInformationRoute.name,
          initialChildren: children,
        );

  static const String name = 'TravelOrderInformationRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [UserDetailsScreen]
class UserDetailsRoute extends PageRouteInfo<UserDetailsRouteArgs> {
  UserDetailsRoute({
    Key? key,
    required String contactInfo,
    List<PageRouteInfo>? children,
  }) : super(
          UserDetailsRoute.name,
          args: UserDetailsRouteArgs(
            key: key,
            contactInfo: contactInfo,
          ),
          initialChildren: children,
        );

  static const String name = 'UserDetailsRoute';

  static const PageInfo<UserDetailsRouteArgs> page =
      PageInfo<UserDetailsRouteArgs>(name);
}

class UserDetailsRouteArgs {
  const UserDetailsRouteArgs({
    this.key,
    required this.contactInfo,
  });

  final Key? key;

  final String contactInfo;

  @override
  String toString() {
    return 'UserDetailsRouteArgs{key: $key, contactInfo: $contactInfo}';
  }
}

/// generated route for
/// [GoogleCompleteFormPage]
class GoogleCompleteFormRoute extends PageRouteInfo<GoogleCompleteFormRouteArgs> {
  GoogleCompleteFormRoute({
    Key? key,
    required String sessionId,
    List<PageRouteInfo>? children,
  }) : super(
          GoogleCompleteFormRoute.name,
          args: GoogleCompleteFormRouteArgs(
            key: key,
            sessionId: sessionId,
          ),
          initialChildren: children,
        );

  static const String name = 'GoogleCompleteFormRoute';

  static const PageInfo<GoogleCompleteFormRouteArgs> page =
      PageInfo<GoogleCompleteFormRouteArgs>(name);
}

class GoogleCompleteFormRouteArgs {
  const GoogleCompleteFormRouteArgs({
    this.key,
    required this.sessionId,
  });

  final Key? key;

  final String sessionId;

  @override
  String toString() {
    return 'GoogleCompleteFormRouteArgs{key: $key, sessionId: $sessionId}';
  }
}
