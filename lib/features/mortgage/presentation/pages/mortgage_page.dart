import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/dio/singletons/service_locator.dart';
import '../../../../core/widgets/primary_back_button.dart';
import '../../../../core/widgets/primary_search_filter_bar.dart';
import '../../../common/utils/amount_formatter.dart';
import '../../../common/utils/bank_assets.dart';
import '../../../common/utils/bank_data.dart';
import '../../domain/entities/mortgage_entity.dart';
import '../../domain/entities/mortgage_filter.dart';
import '../bloc/mortgage_bloc.dart';

@RoutePage()
class MortgagePage extends StatefulWidget {
  const MortgagePage({super.key});

  @override
  State<MortgagePage> createState() => _MortgagePageState();
}

class _MortgagePageState extends State<MortgagePage> {
  late final TextEditingController _searchController;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(BuildContext context, String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 450), () {
      final trimmed = value.trim();
      debugPrint('[MortgagePage] Search changed -> "$trimmed"');
      context.read<MortgageBloc>().add(MortgageSearchChanged(trimmed));
    });
  }

  Future<void> _openFilterSheet(
    BuildContext context,
    MortgageFilter filter,
    List<MortgageEntity> items,
  ) async {
    debugPrint('[MortgagePage] Opening filter sheet');
    final result = await showModalBottomSheet<MortgageFilter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _MortgageFilterSheet(initialFilter: filter, items: items),
      ),
    );

    if (result != null) {
      debugPrint(
        '[MortgagePage] Filter applied: ${result.toQueryParameters()}',
      );
      context.read<MortgageBloc>().add(MortgageFilterApplied(result));
    } else {
      debugPrint('[MortgagePage] Filter sheet dismissed without changes');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ServiceLocator.resolve<MortgageBloc>()..add(const MortgageStarted()),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          toolbarHeight: 72.h,
          leadingWidth: 72.w,
          titleSpacing: 0,
          backgroundColor:
              Theme.of(context).appBarTheme.backgroundColor ??
              Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: Padding(
            padding: EdgeInsets.only(left: 16.w),
            child: Center(
              child: PrimaryBackButton(onTap: () => Navigator.pop(context)),
            ),
          ),
          centerTitle: true,
          title: Text(
            tr('mortgage.title'),
            style: TextStyle(
              color:
                  Theme.of(context).textTheme.titleLarge?.color ?? Colors.black,
              fontSize: 17.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: Column(
          children: [
            BlocBuilder<MortgageBloc, MortgageState>(
              builder: (context, state) {
                return PrimarySearchFilterBar(
                  controller: _searchController,
                  onSearchChanged: (value) =>
                      _onSearchChanged(context, value),
                  onFilterTap: () =>
                      _openFilterSheet(context, state.filter, state.items),
                  hasActiveFilter: state.filter.hasActiveFilters,
                  hintText: tr('mortgage.search_hint'),
                );
              },
            ),
            Expanded(
              child: BlocListener<MortgageBloc, MortgageState>(
                listener: (context, state) {
                  debugPrint('[MortgagePage] BlocListener: State changed!');
                  debugPrint('  - Status: ${state.status}');
                  debugPrint('  - Items: ${state.items.length}');
                  debugPrint('  - isInitialLoading: ${state.isInitialLoading}');
                  debugPrint('  - isPaginating: ${state.isPaginating}');
                  debugPrint('  - hasMore: ${state.hasMore}');
                  if (state.items.isNotEmpty) {
                    debugPrint('  - First item: ${state.items.first.bankName}');
                  }
                },
                child: BlocBuilder<MortgageBloc, MortgageState>(
                  builder: (context, state) {
                    debugPrint(
                      '[MortgagePage] BlocBuilder: Building UI - status: ${state.status}, '
                      'items: ${state.items.length}, isInitialLoading: ${state.isInitialLoading}',
                    );

                    if (state.isInitialLoading) {
                      debugPrint('[MortgagePage] Showing initial loader');
                      return const _CenteredLoader();
                    }

                    if (state.status == MortgageViewStatus.failure &&
                        state.items.isEmpty) {
                      debugPrint(
                        '[MortgagePage] Showing error state: ${state.errorMessage}',
                      );
                      return _StateMessage(
                        icon: Icons.error_outline,
                        title: tr('common.error'),
                        subtitle:
                            state.errorMessage ??
                            tr('common.something_went_wrong'),
                        actionLabel: tr('common.retry'),
                        onAction: () async {
                          context.read<MortgageBloc>().add(
                            const MortgageStarted(),
                          );
                        },
                      );
                    }

                    if (state.items.isEmpty &&
                        state.status != MortgageViewStatus.failure) {
                      debugPrint(
                        '[MortgagePage] Items are empty, showing empty state',
                      );
                      return _StateMessage(
                        icon: Icons.search_off_rounded,
                        title: tr('mortgage.empty_title'),
                        subtitle: tr('mortgage.empty_subtitle'),
                        actionLabel: tr('common.refresh'),
                        onAction: () async {
                          context.read<MortgageBloc>().add(
                            const MortgageRefreshRequested(),
                          );
                        },
                      );
                    }

                    debugPrint(
                      '[MortgagePage] Rendering list with ${state.items.length} items',
                    );

                    return RefreshIndicator(
                      onRefresh: () {
                        final completer = Completer<void>();
                        context.read<MortgageBloc>().add(
                          MortgageRefreshRequested(completer: completer),
                        );
                        return completer.future;
                      },
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          if (notification.metrics.pixels >=
                                  notification.metrics.maxScrollExtent - 120 &&
                              state.hasMore &&
                              !state.isPaginating) {
                            debugPrint(
                              '[MortgagePage] Scroll reached threshold, requesting more',
                            );
                            context.read<MortgageBloc>().add(
                              const MortgageLoadMoreRequested(),
                            );
                          }
                          return false;
                        },
                        child: _MortgageList(
                          state: state,
                          onRetryPagination: () {
                            context.read<MortgageBloc>().add(
                              const MortgageLoadMoreRequested(),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RateOption {
  const _RateOption(this.label, {this.min, this.max});
  final String label;
  final double? min;
  final double? max;
  static const empty = _RateOption('');
}

class _TermOption {
  const _TermOption(this.label, {this.min, this.max});
  final String label;
  final int? min;
  final int? max;
  static const empty = _TermOption('');
}

class _MortgageList extends StatelessWidget {
  const _MortgageList({required this.state, required this.onRetryPagination});

  final MortgageState state;
  final VoidCallback onRetryPagination;

  @override
  Widget build(BuildContext context) {
    final hasPaginationError = state.paginationErrorMessage != null;
    final extraSlots = (state.hasMore ? 1 : 0) + (hasPaginationError ? 1 : 0);
    final itemCount = state.items.length + extraSlots;

    return ListView.separated(
      padding: EdgeInsets.all(20.w),
      itemCount: itemCount,
      separatorBuilder: (_, __) => SizedBox(height: 16.h),
      itemBuilder: (context, index) {
        if (hasPaginationError && index == 0) {
          return _PaginationErrorBanner(
            message: state.paginationErrorMessage ?? '',
            onRetry: onRetryPagination,
          );
        }

        final adjustedIndex = hasPaginationError ? index - 1 : index;
        if (adjustedIndex >= state.items.length) {
          return state.hasMore
              ? const _BottomLoader()
              : const SizedBox.shrink();
        }

        final item = state.items[adjustedIndex];
        return _MortgageCard(item: item);
      },
    );
  }
}

class _MortgageCard extends StatelessWidget {
  const _MortgageCard({required this.item});

  final MortgageEntity item;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final formattedMaxSum = formatCompactAmount(item.maxSum);
    final logoAsset = bankLogoAsset(item.bankName);
    final useContainFit =
        logoAsset != null && bankLogoUsesContainFit(item.bankName);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MortgageHeader(
            item: item,
            logoAsset: logoAsset,
            useContainFit: useContainFit,
          ),
          SizedBox(height: 16.h),
          _MortgagePropertyBadge(propertyType: item.propertyType),
          SizedBox(height: 16.h),
          _MortgageInfoGrid(
            interestRate: item.interestRate,
            term: item.term,
            amount: formattedMaxSum,
            downPayment: item.downPayment,
          ),
          SizedBox(height: 16.h),
          _MortgageBenefitsSection(item: item),
          SizedBox(height: 16.h),
          _MortgageApplyButton(bankName: item.bankName),
        ],
      ),
    );
  }
}

class _MortgageHeader extends StatelessWidget {
  const _MortgageHeader({
    required this.item,
    required this.logoAsset,
    required this.useContainFit,
  });

  final MortgageEntity item;
  final String? logoAsset;
  final bool useContainFit;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48.w,
          height: 48.w,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.midnight
                : AppColors.secondaryBlue,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: logoAsset != null
                ? Padding(
                    padding: useContainFit
                        ? EdgeInsets.all(6.w)
                        : EdgeInsets.zero,
                    child: Image.asset(
                      logoAsset!,
                      fit: useContainFit ? BoxFit.contain : BoxFit.cover,
                    ),
                  )
                : Icon(
                    Icons.apartment_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.bankName,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color:
                      Theme.of(context).textTheme.titleLarge?.color ??
                      AppColors.charcoal,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              SizedBox(height: 4.h),
              Text(
                item.currency ?? 'UZS',
                style: TextStyle(
                  fontSize: 12.sp,
                  color:
                      Theme.of(context).textTheme.bodySmall?.color ??
                      AppColors.grayText,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MortgagePropertyBadge extends StatelessWidget {
  const _MortgagePropertyBadge({required this.propertyType});

  final String? propertyType;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).scaffoldBackgroundColor
            : AppColors.skySurface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 18.sp,
                  color: AppColors.skyAccent,
                ),
                SizedBox(width: 8.w),
                Flexible(
                  child: Text(
                    tr('mortgage.property_type'),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color:
                          Theme.of(context).textTheme.bodySmall?.color ??
                          AppColors.grayText,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Flexible(
            child: Text(
              (propertyType == null || propertyType!.isEmpty)
                  ? tr('mortgage.property_type_value')
                  : propertyType!,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _MortgageInfoGrid extends StatelessWidget {
  const _MortgageInfoGrid({
    required this.interestRate,
    required this.term,
    required this.amount,
    required this.downPayment,
  });

  final String interestRate;
  final String term;
  final String amount;
  final String downPayment;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MortgageInfoItem(
                icon: Icons.percent_rounded,
                label: tr('mortgage.interest_rate'),
                value: interestRate,
                valueColor: AppColors.accentGreen,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _MortgageInfoItem(
                icon: Icons.calendar_month_outlined,
                label: tr('mortgage.term'),
                value: term,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _MortgageInfoItem(
                icon: Icons.account_balance_wallet_outlined,
                label: tr('mortgage.amount'),
                value: amount,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _MortgageInfoItem(
                icon: Icons.pie_chart_outline_rounded,
                label: tr('mortgage.down_payment'),
                value: downPayment,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MortgageInfoItem extends StatelessWidget {
  const _MortgageInfoItem({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16.sp,
                color: Theme.of(context).textTheme.bodySmall?.color ??
                    AppColors.grayText,
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color:
                        Theme.of(context).textTheme.bodySmall?.color ??
                        AppColors.grayText,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color:
                  valueColor ??
                  Theme.of(context).textTheme.titleLarge?.color ??
                  AppColors.charcoal,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}

class _MortgageBenefitsSection extends StatefulWidget {
  const _MortgageBenefitsSection({required this.item});

  final MortgageEntity item;

  @override
  State<_MortgageBenefitsSection> createState() =>
      _MortgageBenefitsSectionState();
}

class _MortgageBenefitsSectionState extends State<_MortgageBenefitsSection> {
  bool _isExpanded = false;

  List<String> _getAdvantages() {
    if (widget.item.advantages != null && widget.item.advantages!.isNotEmpty) {
      return widget.item.advantages!;
    }
    final advantages = <String>[];
    if (widget.item.interestRate.isNotEmpty) {
      advantages.add('${tr('mortgage.interest_rate')} ${widget.item.interestRate}');
    }
    if (widget.item.term.isNotEmpty) {
      advantages.add('${tr('mortgage.term')} ${widget.item.term}');
    }
    if (widget.item.maxSum.isNotEmpty) {
      advantages.add('${tr('mortgage.amount')} ${widget.item.maxSum}');
    }
    if (widget.item.downPayment.isNotEmpty) {
      advantages.add('${tr('mortgage.down_payment')} ${widget.item.downPayment}');
    }
    if (advantages.isEmpty) {
      advantages.add(tr('mortgage.default_advantages'));
    }
    return advantages;
  }

  @override
  Widget build(BuildContext context) {
    final advantages = _getAdvantages();

    if (advantages.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Theme.of(context).dividerColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    tr('mortgage.advantages_count', namedArgs: {'count': advantages.length.toString()}),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                      color:
                          Theme.of(context).textTheme.titleLarge?.color ??
                          AppColors.charcoal,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: AppColors.grayText,
                ),
              ],
            ),
          ),
          if (_isExpanded && advantages.isNotEmpty) ...[
            SizedBox(height: 12.h),
            ...advantages.map(
              (advantage) => Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary,
                      size: 16.sp,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        advantage,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color:
                              Theme.of(context).textTheme.bodyMedium?.color ??
                              AppColors.gray500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MortgageApplyButton extends StatelessWidget {
  const _MortgageApplyButton({required this.bankName});
  
  final String bankName;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton(
        onPressed: () async {
          final opened = await openBankApplication(bankName);
          if (!opened && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  tr('common.error'),
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Text(
          tr('mortgage.apply'),
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final Future<void> Function() onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 48.sp,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(height: 12.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 8.h),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                color:
                    Theme.of(context).textTheme.bodyMedium?.color ??
                    Colors.grey,
              ),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () {
                onAction();
              },
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _MortgageFilterSheet extends StatefulWidget {
  const _MortgageFilterSheet({
    required this.initialFilter,
    required this.items,
  });

  final MortgageFilter initialFilter;
  final List<MortgageEntity> items;

  @override
  State<_MortgageFilterSheet> createState() => _MortgageFilterSheetState();
}

class _MortgageFilterSheetState extends State<_MortgageFilterSheet> {
  late final List<_RateOption> _rateOptions;
  late final List<_TermOption> _termOptions;
  List<String> _propertyTypeOptions = const [];
  String? _selectedRateLabel;
  String? _selectedTermLabel;
  String? _selectedPropertyTypeLabel;

  @override
  void initState() {
    super.initState();
    _rateOptions = _buildRateOptions(widget.items);
    _termOptions = _buildTermOptions(widget.items);
    _propertyTypeOptions = _buildPropertyTypeOptions(widget.items);
    _selectedRateLabel = _labelForRate(
      widget.initialFilter.interestRateFrom,
      widget.initialFilter.interestRateTo,
      _rateOptions,
    );
    _selectedTermLabel = _labelForTerm(
      widget.initialFilter.termMonthsFrom,
      widget.initialFilter.termMonthsTo,
      _termOptions,
    );
    _selectedPropertyTypeLabel = widget.initialFilter.propertyType;
  }

  void _reset() {
    setState(() {
      _selectedRateLabel = null;
      _selectedTermLabel = null;
      _selectedPropertyTypeLabel = null;
    });
  }

  void _apply() {
    final rateOption = _rateOptions.firstWhere(
      (option) => option.label == _selectedRateLabel,
      orElse: () => _RateOption.empty,
    );
    final termOption = _termOptions.firstWhere(
      (option) => option.label == _selectedTermLabel,
      orElse: () => _TermOption.empty,
    );
    final rateSelected = rateOption.min != null;
    final termSelected = termOption.min != null;
    final sortField = rateSelected
        ? 'rate'
        : termSelected
        ? 'term'
        : null;
    final updatedFilter = widget.initialFilter.copyWith(
      interestRateFrom: rateOption.min,
      interestRateTo: rateOption.max,
      termMonthsFrom: termOption.min,
      termMonthsTo: termOption.max,
      propertyType: _selectedPropertyTypeLabel,
      resetInterestRate: rateOption.min == null,
      resetInterestRateTo: rateOption.max == null,
      resetTerm: termOption.min == null,
      resetTermTo: termOption.max == null,
      resetPropertyType: _selectedPropertyTypeLabel == null,
      sort: sortField,
      direction: sortField == null ? null : 'asc',
      resetSort: sortField == null,
      resetDirection: sortField == null,
    );

    Navigator.of(context).pop(updatedFilter);
  }

  List<_RateOption> _buildRateOptions(List<MortgageEntity> items) {
    final values =
        items
            .map((e) => _parseNumeric(e.interestRate))
            .whereType<double>()
            .toList()
          ..sort();
    if (values.isEmpty) {
      return const [
        _RateOption('16-20%', min: 16, max: 20),
        _RateOption('21-25%', min: 21, max: 25),
        _RateOption('26%+', min: 26, max: null),
      ];
    }
    final min = values.first;
    final max = values.last;
    final mid = (min + max) / 2;
    return _deduplicateRateOptions([
      _RateOption(_formatPercentRange(min, mid), min: min, max: mid),
      _RateOption(_formatPercentRange(mid, max), min: mid, max: max),
      _RateOption('${_formatPercentValue(max)}%+', min: max, max: null),
    ]);
  }

  List<_RateOption> _deduplicateRateOptions(List<_RateOption> options) {
    final seen = <String>{};
    final result = <_RateOption>[];
    for (final option in options) {
      if (option.min == null && option.max == null) continue;
      final key = '${option.min ?? 'null'}-${option.max ?? 'null'}';
      if (seen.add(key)) {
        result.add(option);
      }
    }
    return result;
  }

  List<_TermOption> _buildTermOptions(List<MortgageEntity> items) {
    final values =
        items.map((e) => _parseTermToMonths(e.term)).whereType<int>().toList()
          ..sort();
    if (values.isEmpty) {
      return [
        _TermOption('5 ${tr('mortgage.years_short')}', min: 60, max: 60),
        _TermOption('7 ${tr('mortgage.years_short')}', min: 84, max: 84),
        _TermOption('8+ ${tr('mortgage.years_short')}', min: 96, max: null),
      ];
    }
    final min = values.first;
    final max = values.last;
    final mid = ((min + max) / 2).round();
    return _deduplicateTermOptions([
      _TermOption(_formatTermRange(min, mid), min: min, max: mid),
      _TermOption(_formatTermRange(mid, max), min: mid, max: max),
      _TermOption('${_formatTermValue(max)}+', min: max, max: null),
    ]);
  }

  List<String> _buildPropertyTypeOptions(List<MortgageEntity> items) {
    final seen = <String>{};
    for (final item in items) {
      final value = item.propertyType?.trim();
      if (value != null && value.isNotEmpty) {
        seen.add(value);
      }
    }
    if (seen.isEmpty) {
      return [
        tr('mortgage.property_type_new_building'),
        tr('mortgage.property_type_residential'),
        tr('mortgage.property_type_country_house'),
      ];
    }
    final list = seen.toList();
    list.sort();
    return list;
  }

  List<_TermOption> _deduplicateTermOptions(List<_TermOption> options) {
    final seen = <String>{};
    final result = <_TermOption>[];
    for (final option in options) {
      if (option.min == null && option.max == null) continue;
      final key = '${option.min ?? 'null'}-${option.max ?? 'null'}';
      if (seen.add(key)) {
        result.add(option);
      }
    }
    return result;
  }

  double? _parseNumeric(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final match = RegExp(r'[\d.,]+').firstMatch(raw);
    if (match == null) return null;
    final normalized = match
        .group(0)!
        .replaceAll(RegExp(r'\s'), '')
        .replaceAll(',', '.');
    return double.tryParse(normalized);
  }

  int? _parseTermToMonths(String raw) {
    final value = _parseNumeric(raw);
    if (value == null) return null;
    final lower = raw.toLowerCase();
    // Проверяем различные варианты написания года/месяца на разных языках
    if (lower.contains('yil') || lower.contains('year') || lower.contains('лет') || lower.contains('йил')) {
      return (value * 12).round();
    }
    return value.round();
  }

  String _formatPercentValue(double value) {
    return value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(1);
  }

  String _formatPercentRange(double from, double? to) {
    if (to == null || to == from) {
      return '${_formatPercentValue(from)}%';
    }
    return '${_formatPercentValue(from)}-${_formatPercentValue(to)}%';
  }

  String _formatTermValue(int months) {
    if (months % 12 == 0) {
      final years = months ~/ 12;
      return '$years ${tr('mortgage.years_short')}';
    }
    return '$months ${tr('mortgage.months_short')}';
  }

  String _formatTermRange(int from, int? to) {
    if (to == null || to == from) {
      return _formatTermValue(from);
    }
    return '${_formatTermValue(from)} - ${_formatTermValue(to)}';
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = Theme.of(context).cardColor;
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          children: [
            SizedBox(height: 12.h),
            Container(
              width: 48.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              tr('mortgage.filters'),
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color:
                    Theme.of(context).textTheme.titleLarge?.color ??
                    Colors.black87,
              ),
            ),
            SizedBox(height: 24.h),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      Icons.percent_rounded,
                      tr('mortgage.interest_rate'),
                    ),
                    SizedBox(height: 12.h),
                    _buildChipWrap(
                      options: _rateOptions.map((e) => e.label).toList(),
                      selected: _selectedRateLabel,
                      onSelected: (value) =>
                          setState(() => _selectedRateLabel = value),
                    ),
                    SizedBox(height: 28.h),
                    _buildSectionHeader(
                      Icons.calendar_today_outlined,
                      tr('mortgage.term'),
                    ),
                    SizedBox(height: 12.h),
                    _buildChipWrap(
                      options: _termOptions.map((e) => e.label).toList(),
                      selected: _selectedTermLabel,
                      onSelected: (value) =>
                          setState(() => _selectedTermLabel = value),
                    ),
                    SizedBox(height: 28.h),
                    if (_propertyTypeOptions.isNotEmpty) ...[
                      _buildSectionHeader(
                        Icons.home_outlined,
                        tr('mortgage.property_type'),
                      ),
                      SizedBox(height: 12.h),
                      _buildChipWrap(
                        options: _propertyTypeOptions,
                        selected: _selectedPropertyTypeLabel,
                        onSelected: (value) => setState(() {
                          _selectedPropertyTypeLabel =
                              value == _selectedPropertyTypeLabel
                              ? null
                              : value;
                        }),
                      ),
                      SizedBox(height: 28.h),
                    ],
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 36.h),
              decoration: BoxDecoration(
                color: cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52.h,
                      child: OutlinedButton(
                        onPressed: _reset,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Theme.of(context).dividerColor,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                        child: Text(
                          tr('common.reset'),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color:
                                Theme.of(context).textTheme.titleLarge?.color ??
                                const Color(0xFF1F2937),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: SizedBox(
                      height: 52.h,
                      child: ElevatedButton(
                        onPressed: _apply,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                        child: Text(
                          tr('common.apply'),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20.sp,
          color: Theme.of(context).textTheme.bodyMedium?.color ??
              AppColors.gray500,
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).textTheme.titleLarge?.color ??
                  AppColors.charcoal,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildChipWrap({
    required List<String> options,
    required String? selected,
    required ValueChanged<String> onSelected,
  }) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: options.map((label) {
        final isSelected = label == selected;
        return GestureDetector(
          onTap: () => onSelected(label),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryBlue.withOpacity(0.08)
                  : (Theme.of(context).brightness == Brightness.dark
                      ? AppColors.midnight
                      : AppColors.grayLight),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isSelected
                    ? AppColors.primaryBlue
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? AppColors.primaryBlue
                    : (Theme.of(context).textTheme.bodyMedium?.color ??
                        AppColors.gray500),
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        );
      }).toList(),
    );
  }

  String? _labelForRate(
    double? minValue,
    double? maxValue,
    List<_RateOption> options,
  ) {
    for (final option in options) {
      final minMatches =
          (option.min == null && minValue == null) || option.min == minValue;
      final maxMatches =
          (option.max == null && maxValue == null) || option.max == maxValue;
      if (minMatches && maxMatches) return option.label;
    }
    return null;
  }

  String? _labelForTerm(
    int? minMonths,
    int? maxMonths,
    List<_TermOption> options,
  ) {
    for (final option in options) {
      final minMatches =
          (option.min == null && minMonths == null) || option.min == minMonths;
      final maxMatches =
          (option.max == null && maxMonths == null) || option.max == maxMonths;
      if (minMatches && maxMatches) return option.label;
    }
    return null;
  }
}

class _PaginationErrorBanner extends StatelessWidget {
  const _PaginationErrorBanner({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12.sp,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
          TextButton(onPressed: onRetry, child: Text(tr('common.retry'))),
        ],
      ),
    );
  }
}

class _BottomLoader extends StatelessWidget {
  const _BottomLoader();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _CenteredLoader extends StatelessWidget {
  const _CenteredLoader();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
