import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../data/models/search_offers_request_model.dart' show SearchOffersRequestModel, DirectionModel;
import '../bloc/avia_bloc.dart';
import '../widgets/primary_button.dart';

@RoutePage(name: 'AviaSearchRoute')
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _formKey = GlobalKey<FormState>();
  final _departureController = TextEditingController(text: 'TAS');
  final _arrivalController = TextEditingController(text: 'DXB');
  final _dateController = TextEditingController(text: '2025-11-25');
  final _returnDateController = TextEditingController(text: '2025-11-25');
  int _adults = 1;
  int _children = 0;
  String _serviceClass = 'A';

  @override
  void dispose() {
    _departureController.dispose();
    _arrivalController.dispose();
    _dateController.dispose();
    _returnDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('avia.search.title'.tr()),
      ),
      body: BlocBuilder<AviaBloc, AviaState>(
        builder: (context, state) {
          if (state is AviaLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AviaSearchSuccess) {
            final offers = state.offers;
            if (offers.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.flight_takeoff,
                      size: 64,
                      color: theme.iconTheme.color?.withValues(alpha: 0.6) ??
                          Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'avia.results.not_found'.tr(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: theme.textTheme.titleLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        context.read<AviaBloc>().add(const AviaStateReset());
                      },
                      child: Text('avia.results.retry_search'.tr()),
                    ),
                  ],
                ),
              );
            }
            
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${'avia.results.found'.tr()}: ${offers.length} ${'avia.results.flights'.tr()}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          // TODO: Implement filter dialog
                          SnackbarHelper.showInfo(
                            context,
                            'avia.results.filter_coming_soon'.tr(),
                          );
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.filter_list, size: 20),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {
                          context.read<AviaBloc>().add(const AviaStateReset());
                        },
                        child: Text('avia.results.new_search'.tr()),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    cacheExtent: 500, // Cache optimization for better scroll performance
                    itemCount: offers.length,
                    itemBuilder: (context, index) {
                      final offer = offers[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: const Icon(Icons.flight),
                          title: Text(
                            offer.airline ?? 'avia.results.unknown_airline'.tr(),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(() {
                                if (offer.price == null) {
                                  return '${'avia.results.price_label'.tr()} ${'avia.common.na'.tr()} ${offer.currency ?? ''}';
                                }
                                // Parse price and add 10% commission
                                final rawPrice = offer.price!.replaceAll(RegExp(r'[^\d.]'), '');
                                final priceValue = double.tryParse(rawPrice) ?? 0.0;
                                final priceWithCommission = (priceValue * 1.10).toStringAsFixed(0);
                                return '${'avia.results.price_label'.tr()} $priceWithCommission ${offer.currency ?? ''}';
                              }()),
                              if (offer.duration != null)
                                Text('${'avia.results.duration'.tr()} ${offer.duration}'),
                            ],
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            if (offer.id != null) {
                              context.router.push(
                                OfferDetailRoute(offerId: offer.id!),
                              );
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }

          if (state is AviaSearchFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${'avia.details.error'.tr()} ${state.message}',
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AviaBloc>().add(const AviaStateReset());
                    },
                    child: Text('avia.results.retry_search'.tr()),
                  ),
                ],
              ),
            );
          }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _departureController,
                      decoration: InputDecoration(
                        labelText: 'avia.search.from'.tr(),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _arrivalController,
                      decoration: InputDecoration(
                        labelText: 'avia.search.to'.tr(),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _dateController,
                      decoration: InputDecoration(
                        labelText: '${'avia.search.departure_date'.tr()} (YYYY-MM-DD)',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _returnDateController,
                      decoration: InputDecoration(
                        labelText: '${'avia.search.return_date'.tr()} (YYYY-MM-DD)',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text('${'avia.confirmation.adult'.tr()}: '),
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            setState(() {
                              if (_adults > 1) _adults--;
                            });
                          },
                        ),
                        Text('$_adults'),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              _adults++;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _serviceClass,
                      decoration: InputDecoration(
                        labelText: 'avia.search.service_class'.tr(),
                        border: const OutlineInputBorder(),
                      ),
                      items: ['A', 'B', 'C'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _serviceClass = value ?? 'A';
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    BlocBuilder<AviaBloc, AviaState>(
                      builder: (context, state) {
                        final isLoading = state is AviaLoading;
                        return PrimaryButton(
                          text: 'avia.search.search_button'.tr(),
                          isLoading: isLoading,
                          onPressed: isLoading ? null : () {
                            if (_formKey.currentState!.validate()) {
                              _searchOffers(context);
                            }
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
        },
      ),
    );
  }

  void _searchOffers(BuildContext context) {
    // Aeroportlarni tekshirish
    final departureAirport = _departureController.text.trim();
    final arrivalAirport = _arrivalController.text.trim();
    
    if (departureAirport.isEmpty || arrivalAirport.isEmpty) {
      SnackbarHelper.showError(
        context,
        'avia.search.fill_fields'.tr(),
      );
      return;
    }
    
    // Agar aeroportlar bir xil bo'lsa, xatolik ko'rsatish
    if (departureAirport == arrivalAirport) {
      SnackbarHelper.showError(
        context,
        'avia.search.same_airports'.tr(),
      );
      return;
    }
    
    // Borish sanasini tekshirish
    final departureDate = _dateController.text.trim();
    if (departureDate.isEmpty) {
      SnackbarHelper.showError(
        context,
        'avia.search.select_departure_date'.tr(),
      );
      return;
    }
    
    // Qaytish sanasi mavjudligini tekshirish
    final returnDate = _returnDateController.text.trim();
    final hasReturnDate = returnDate.isNotEmpty;
    
    final request = SearchOffersRequestModel(
      adults: _adults,
      children: _children,
      serviceClass: _serviceClass,
      directions: [
        DirectionModel(
          departureAirport: departureAirport,
          arrivalAirport: arrivalAirport,
          date: departureDate,
        ),
        // Faqat qaytish sanasi bo'lsa, ikkinchi yo'nalishni qo'shish
        if (hasReturnDate)
          DirectionModel(
            departureAirport: arrivalAirport,
            arrivalAirport: departureAirport,
            date: returnDate,
          ),
      ],
    );

    context.read<AviaBloc>().add(SearchOffersRequested(request));
  }
}

