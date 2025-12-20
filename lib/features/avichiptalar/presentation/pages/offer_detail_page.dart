import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/navigation/app_router.dart';
import '../bloc/avia_bloc.dart';
import '../widgets/primary_button.dart';

@RoutePage(name: 'OfferDetailRoute')
class OfferDetailPage extends StatefulWidget {
  final String offerId;

  const OfferDetailPage({
    super.key,
    required this.offerId,
  });

  @override
  State<OfferDetailPage> createState() => _OfferDetailPageState();
}

class _OfferDetailPageState extends State<OfferDetailPage> {
  bool _hasLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasLoaded) {
        _hasLoaded = true;
        context.read<AviaBloc>().add(OfferDetailRequested(widget.offerId));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('avia.details.title'.tr()),
      ),
      body: BlocBuilder<AviaBloc, AviaState>(
        builder: (context, state) {
          if (state is AviaLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AviaOfferDetailSuccess) {
              final offer = state.offer;
              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${'avia.details.price'.tr()} ${offer.price ?? 'avia.common.na'.tr()} ${offer.currency ?? ''}',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 16),
                          Text('${'avia.details.airline'.tr()} ${offer.airline ?? 'avia.common.na'.tr()}'),
                          Text('${'avia.details.duration'.tr()} ${offer.duration ?? 'avia.common.na'.tr()}'),
                          if (offer.segments != null && offer.segments!.isNotEmpty)
                            ...offer.segments!.map((segment) => Card(
                                  margin: const EdgeInsets.symmetric(vertical: 8),
                                  child: ListTile(
                                    title: Text(
                                        '${segment.departureAirport} → ${segment.arrivalAirport}'),
                                    subtitle: Text(
                                        '${segment.departureTime} - ${segment.arrivalTime}'),
                                    trailing: Text(segment.flightNumber ?? ''),
                                  ),
                                )),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      boxShadow: Theme.of(context).brightness == Brightness.dark
                          ? null
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, -2),
                              ),
                            ],
                    ),
                    child: BlocBuilder<AviaBloc, AviaState>(
                      builder: (context, buttonState) {
                        final isLoading = buttonState is AviaLoading;
                        return PrimaryButton(
                          text: 'avia.details.book'.tr(),
                          isLoading: isLoading,
                          onPressed: isLoading ? null : () {
                            context.router.push(
                              AviaBookingRoute(offerId: widget.offerId),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            }

            if (state is AviaOfferDetailFailure) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${'avia.details.error'.tr()} ${state.message}'),
                    PrimaryButton(
                      text: 'avia.details.retry'.tr(),
                      onPressed: () {
                        context.read<AviaBloc>().add(
                              OfferDetailRequested(widget.offerId),
                            );
                      },
                    ),
                  ],
                ),
              );
            }

            return Center(child: Text('avia.details.loading'.tr()));
        },
      ),
    );
  }
}

