import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/dio/singletons/service_locator.dart';
import '../../../common/utils/amount_formatter.dart';
import '../../../common/utils/bank_assets.dart';
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
        child: _MortgageFilterSheet(initialFilter: filter),
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
          backgroundColor:
              Theme.of(context).appBarTheme.backgroundColor ??
              Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleSpacing: 0,
          leading: Center(
            child: Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.arrow_back,
                  color: Theme.of(context).iconTheme.color ?? Colors.black,
                  size: 20.sp,
                ),
                onPressed: () => Navigator.pop(context),
              ),
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
                return _SearchAndActionsBar(
                  controller: _searchController,
                  onSearchChanged: (value) => _onSearchChanged(context, value),
                  onOpenFilter: () => _openFilterSheet(context, state.filter),
                  hasActiveFilter: state.filter.hasActiveFilters,
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

class _SearchAndActionsBar extends StatelessWidget {
  const _SearchAndActionsBar({
    required this.controller,
    required this.onSearchChanged,
    required this.onOpenFilter,
    required this.hasActiveFilter,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onOpenFilter;
  final bool hasActiveFilter;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor,
      padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 16.h),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 40.h,
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20.sp,
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: TextField(
                          controller: controller,
                          onChanged: onSearchChanged,
                          decoration: InputDecoration(
                            hintText: tr('mortgage.search_hint'),
                            hintStyle: TextStyle(
                              color:
                                  Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.color ??
                                  const Color(0xFF9CA3AF),
                              fontSize: 13.sp,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            focusedErrorBorder: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: TextStyle(
                            fontSize: 13.sp,
                            color:
                                Theme.of(context).textTheme.bodyLarge?.color ??
                                const Color(0xFF111827),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              InkWell(
                onTap: onOpenFilter,
                borderRadius: BorderRadius.circular(12.r),
                child: Container(
                  width: 40.h,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: hasActiveFilter
                        ? Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.08)
                        : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: hasActiveFilter
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).dividerColor,
                    ),
                  ),
                  child: Icon(
                    Icons.filter_alt_outlined,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20.sp,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
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
          const _MortgagePropertyBadge(),
          SizedBox(height: 16.h),
          _MortgageInfoGrid(
            interestRate: item.interestRate,
            term: item.term,
            amount: formattedMaxSum,
            downPayment: item.downPayment,
          ),
          if (item.advantages != null && item.advantages!.isNotEmpty) ...[
            SizedBox(height: 16.h),
            _MortgageBenefitsSection(advantages: item.advantages!),
          ],
          SizedBox(height: 16.h),
          _MortgageApplyButton(),
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
            color: Colors.blue.shade50,
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
                      Colors.black87,
                ),
              ),
              SizedBox(height: 4.h),
              Row(
                children: [
                  if (item.currency != null)
                    Text(
                      item.currency!,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color:
                            Theme.of(context).textTheme.bodySmall?.color ??
                            Colors.grey,
                      ),
                    ),
                  if (item.currency != null) SizedBox(width: 8.w),
                  Icon(Icons.star_rounded, color: Colors.amber, size: 16.sp),
                  SizedBox(width: 4.w),
                  Text(
                    (item.rating ?? 0).toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color:
                          Theme.of(context).textTheme.titleLarge?.color ??
                          Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MortgagePropertyBadge extends StatelessWidget {
  const _MortgagePropertyBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F9FF),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 18.sp,
                color: Colors.blue.shade300,
              ),
              SizedBox(width: 8.w),
              Text(
                tr('mortgage.property_type'),
                style: TextStyle(
                  fontSize: 12.sp,
                  color:
                      Theme.of(context).textTheme.bodySmall?.color ??
                      Colors.grey,
                ),
              ),
            ],
          ),
          Text(
            tr('mortgage.property_type_value'),
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
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
                valueColor: const Color(0xFF00C853),
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
              Icon(icon, size: 16.sp, color: Colors.grey),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color:
                      Theme.of(context).textTheme.bodySmall?.color ??
                      Colors.grey,
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
                  Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _MortgageBenefitsSection extends StatelessWidget {
  const _MortgageBenefitsSection({required this.advantages});

  final List<String> advantages;

  @override
  Widget build(BuildContext context) {
    final title = tr(
      'mortgage.advantages_count',
      namedArgs: {'count': advantages.length.toString()},
    );
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          dense: true,
          tilePadding: EdgeInsets.symmetric(horizontal: 12.w),
          childrenPadding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color:
                  Theme.of(context).textTheme.titleLarge?.color ??
                  Colors.black87,
            ),
          ),
          children: [_AdvantagesList(advantages: advantages)],
        ),
      ),
    );
  }
}

class _MortgageApplyButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton(
        onPressed: () {},
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

class _AdvantagesList extends StatelessWidget {
  const _AdvantagesList({required this.advantages});

  final List<String> advantages;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr('mortgage.advantages'),
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        SizedBox(height: 8.h),
        ...advantages.map(
          (advantage) => Padding(
            padding: EdgeInsets.only(bottom: 4.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• ',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Expanded(
                  child: Text(
                    advantage,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color:
                          Theme.of(context).textTheme.bodyMedium?.color ??
                          const Color(0xFF6B7280),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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

enum _MortgageSortType { interestRate, amount, term }

extension _MortgageSortTypeX on _MortgageSortType {
  String get label {
    switch (this) {
      case _MortgageSortType.interestRate:
        return tr('mortgage.interest_rate');
      case _MortgageSortType.amount:
        return tr('mortgage.amount');
      case _MortgageSortType.term:
        return tr('mortgage.term');
    }
  }

  IconData get icon {
    switch (this) {
      case _MortgageSortType.interestRate:
        return Icons.percent_rounded;
      case _MortgageSortType.amount:
        return Icons.payments_outlined;
      case _MortgageSortType.term:
        return Icons.calendar_month_outlined;
    }
  }

  String get apiField {
    switch (this) {
      case _MortgageSortType.interestRate:
        return 'rate';
      case _MortgageSortType.amount:
        return 'amount';
      case _MortgageSortType.term:
        return 'term';
    }
  }
}

class _MortgageFilterSheet extends StatefulWidget {
  const _MortgageFilterSheet({required this.initialFilter});

  final MortgageFilter initialFilter;

  @override
  State<_MortgageFilterSheet> createState() => _MortgageFilterSheetState();
}

class _MortgageFilterSheetState extends State<_MortgageFilterSheet> {
  _MortgageSortType? _selectedSort;

  final Color _primaryBlue = const Color(0xFF008CF0);
  final Color _borderColor = const Color(0xFFE0E0E0);

  @override
  void initState() {
    super.initState();
    _selectedSort = _sortFromValue(widget.initialFilter.sort);
  }

  _MortgageSortType? _sortFromValue(String? value) {
    switch (value) {
      case 'interest_rate':
        return _MortgageSortType.interestRate;
      case 'max_sum':
        return _MortgageSortType.amount;
      case 'term':
        return _MortgageSortType.term;
      case 'rate':
        return _MortgageSortType.interestRate;
      case 'amount':
        return _MortgageSortType.amount;
      default:
        return null;
    }
  }

  void _reset() {
    setState(() {
      _selectedSort = null;
    });
  }

  void _apply() {
    final updatedFilter = widget.initialFilter.copyWith(
      sort: _selectedSort?.apiField,
      direction: _selectedSort == null ? null : 'asc',
      resetSort: _selectedSort == null,
      resetDirection: _selectedSort == null,
    );
    Navigator.of(context).pop(updatedFilter);
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = Theme.of(context).cardColor;
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
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
              width: 40.w,
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
                fontWeight: FontWeight.w600,
                color:
                    Theme.of(context).textTheme.titleLarge?.color ??
                    Colors.black87,
              ),
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                children: [
                  ..._MortgageSortType.values.map(
                    (type) => Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: _buildSortOption(
                        type: type,
                        isSelected: _selectedSort == type,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 36.h),
              decoration: BoxDecoration(
                color: cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _reset,
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        side: BorderSide(color: _borderColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      child: Text(
                        tr('common.reset'),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color:
                              Theme.of(context).textTheme.titleLarge?.color ??
                              Colors.black,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _apply,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        backgroundColor: _primaryBlue,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption({
    required _MortgageSortType type,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => setState(() => _selectedSort = type),
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: isSelected ? _primaryBlue : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: isSelected ? _primaryBlue : _borderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(type.icon, color: isSelected ? Colors.white : _primaryBlue),
            SizedBox(width: 8.w),
            Text(
              type.label,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
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
