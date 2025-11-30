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
import '../../domain/entities/deposit_entity.dart';
import '../../domain/entities/deposit_filter.dart';
import '../bloc/deposit_bloc.dart';

@RoutePage()
class DepositPage extends StatefulWidget {
  const DepositPage({super.key});

  @override
  State<DepositPage> createState() => _DepositPageState();
}

class _DepositPageState extends State<DepositPage> {
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
      debugPrint('[DepositPage] Search changed -> "$trimmed"');
      context.read<DepositBloc>().add(DepositSearchChanged(trimmed));
    });
  }

  Future<void> _openFilterSheet(
    BuildContext context,
    DepositFilter filter,
  ) async {
    debugPrint('[DepositPage] Opening filter sheet');
    final result = await showModalBottomSheet<DepositFilter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _DepositFilterSheet(initialFilter: filter),
      ),
    );

    if (result != null) {
      debugPrint('[DepositPage] Filter applied: ${result.toQueryParameters()}');
      context.read<DepositBloc>().add(DepositFilterApplied(result));
    } else {
      debugPrint('[DepositPage] Filter sheet dismissed without changes');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ServiceLocator.resolve<DepositBloc>()..add(const DepositStarted()),
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
            tr('deposit.title'),
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
            BlocBuilder<DepositBloc, DepositState>(
              builder: (context, state) {
                return PrimarySearchFilterBar(
                  controller: _searchController,
                  onSearchChanged: (value) => _onSearchChanged(context, value),
                  onFilterTap: () => _openFilterSheet(context, state.filter),
                  hasActiveFilter: state.filter.hasActiveFilters,
                  hintText: tr('deposit.search_hint'),
                );
              },
            ),
            Expanded(
              child: BlocListener<DepositBloc, DepositState>(
                listener: (context, state) {
                  debugPrint('[DepositPage] BlocListener: State changed!');
                  debugPrint('  - Status: ${state.status}');
                  debugPrint('  - Items: ${state.items.length}');
                  debugPrint('  - isInitialLoading: ${state.isInitialLoading}');
                  debugPrint('  - isPaginating: ${state.isPaginating}');
                  debugPrint('  - hasMore: ${state.hasMore}');
                  if (state.items.isNotEmpty) {
                    debugPrint('  - First item: ${state.items.first.bankName}');
                  }
                },
                child: BlocBuilder<DepositBloc, DepositState>(
                  builder: (context, state) {
                    debugPrint(
                      '[DepositPage] BlocBuilder: Building UI - status: ${state.status}, '
                      'items: ${state.items.length}, isInitialLoading: ${state.isInitialLoading}',
                    );

                    if (state.isInitialLoading) {
                      debugPrint('[DepositPage] Showing initial loader');
                      return const _CenteredLoader();
                    }

                    if (state.status == DepositViewStatus.failure &&
                        state.items.isEmpty) {
                      debugPrint(
                        '[DepositPage] Showing error state: ${state.errorMessage}',
                      );
                      return _StateMessage(
                        icon: Icons.error_outline,
                        title: tr('common.error'),
                        subtitle:
                            state.errorMessage ??
                            tr('common.something_went_wrong'),
                        actionLabel: tr('common.retry'),
                        onAction: () async {
                          context.read<DepositBloc>().add(
                            const DepositStarted(),
                          );
                        },
                      );
                    }

                    if (state.items.isEmpty &&
                        state.status != DepositViewStatus.failure) {
                      debugPrint(
                        '[DepositPage] Items are empty, showing empty state',
                      );
                      return _StateMessage(
                        icon: Icons.search_off_rounded,
                        title: tr('deposit.empty_title'),
                        subtitle: tr('deposit.empty_subtitle'),
                        actionLabel: tr('common.refresh'),
                        onAction: () async {
                          context.read<DepositBloc>().add(
                            const DepositRefreshRequested(),
                          );
                        },
                      );
                    }

                    debugPrint(
                      '[DepositPage] Rendering list with ${state.items.length} items',
                    );

                    return RefreshIndicator(
                      onRefresh: () {
                        final completer = Completer<void>();
                        context.read<DepositBloc>().add(
                          DepositRefreshRequested(completer: completer),
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
                              '[DepositPage] Scroll reached threshold, requesting more',
                            );
                            context.read<DepositBloc>().add(
                              const DepositLoadMoreRequested(),
                            );
                          }
                          return false;
                        },
                        child: _DepositList(
                          state: state,
                          onRetryPagination: () {
                            context.read<DepositBloc>().add(
                              const DepositLoadMoreRequested(),
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

class _DepositList extends StatelessWidget {
  const _DepositList({required this.state, required this.onRetryPagination});

  final DepositState state;
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
        return _DepositCard(item: item);
      },
    );
  }
}

class _DepositCard extends StatefulWidget {
  const _DepositCard({required this.item});

  final DepositEntity item;

  @override
  State<_DepositCard> createState() => _DepositCardState();
}

class _DepositCardState extends State<_DepositCard> {
  bool _isExpanded = false;

  List<String> _getAdvantages() {
    final advantages = <String>[];
    if (widget.item.rate.isNotEmpty) {
      advantages.add('${tr('deposit.interest_rate_label')} ${widget.item.rate}');
    }
    if (widget.item.term.isNotEmpty) {
      advantages.add('${tr('deposit.term_label')} ${widget.item.term}');
    }
    if (widget.item.amount.isNotEmpty) {
      advantages.add('${tr('deposit.min_amount_label')} ${widget.item.amount}');
    }
    if (advantages.isEmpty) {
      advantages.add(tr('deposit.default_advantages'));
    }
    return advantages;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final formattedAmount = formatCompactAmount(widget.item.amount);
    final logoAsset = bankLogoAsset(widget.item.bankName);
    final useContainFit =
        logoAsset != null && bankLogoUsesContainFit(widget.item.bankName);
    final advantages = _getAdvantages();

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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
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
                            logoAsset,
                            fit: useContainFit ? BoxFit.contain : BoxFit.cover,
                            filterQuality: FilterQuality.medium,
                          ),
                        )
                      : Icon(
                          Icons.account_balance,
                          color: Theme.of(context).colorScheme.primary,
                          size: 22.sp,
                        ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.bankName,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color:
                            Theme.of(context).textTheme.titleLarge?.color ??
                            const Color(0xFF111827),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14.sp,
                          color:
                              Theme.of(context).textTheme.bodySmall?.color ??
                              const Color(0xFF9CA3AF),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          widget.item.createdAt != null
                              ? DateFormat(
                                  'dd MMM, HH:mm',
                                ).format(widget.item.createdAt!.toLocal())
                              : tr('deposit.updated_recently'),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color ??
                                AppColors.gray500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _InfoBlock(
                  icon: Icons.percent_rounded,
                  label: tr('deposit.interest_rate'),
                  value: widget.item.rate,
                  isAccent: true,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _InfoBlock(
                  icon: Icons.calendar_month_outlined,
                  label: tr('deposit.term'),
                  value: widget.item.term,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _InfoBlock(
                  icon: Icons.payments_outlined,
                  label: tr('deposit.amount'),
                  value: formattedAmount,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          // Afzalliklar section
          if (advantages.isNotEmpty)
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                  width: 1.5,
                ),
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
                        Text(
                          tr('deposit.advantages_count', namedArgs: {'count': advantages.length.toString()}),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14.sp,
                            color:
                                Theme.of(context).textTheme.titleLarge?.color ??
                                const Color(0xFF111827),
                          ),
                        ),
                        Icon(
                          _isExpanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          color: const Color(0xFF9CA3AF),
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
            ),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            height: 46.h,
            child: ElevatedButton(
              onPressed: () async {
                final opened = await openBankApplication(widget.item.bankName);
                if (!opened && mounted) {
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
                tr('deposit.open_deposit'),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({
    required this.icon,
    required this.label,
    required this.value,
    this.isAccent = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isAccent;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color accentColor = AppColors.accentGreen;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isAccent
            ? (isDark ? const Color(0xFF1A3A2E) : const Color(0xFFECFDF5))
            : (isDark
                  ? Theme.of(context).scaffoldBackgroundColor
                  : AppColors.grayBackground),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: isAccent
                ? accentColor
                : Theme.of(context).textTheme.bodyMedium?.color ??
                      AppColors.gray500,
            size: 18.sp,
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color:
                  Theme.of(context).textTheme.bodyMedium?.color ??
                  AppColors.gray500,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
                  color: isAccent
                  ? accentColor
                  : Theme.of(context).textTheme.titleLarge?.color ??
                        AppColors.charcoal,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
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

class _DepositFilterSheet extends StatefulWidget {
  const _DepositFilterSheet({required this.initialFilter});

  final DepositFilter initialFilter;

  @override
  State<_DepositFilterSheet> createState() => _DepositFilterSheetState();
}

enum _DepositSortType { rate, amount, term }

extension on _DepositSortType {
  String get label {
    switch (this) {
      case _DepositSortType.rate:
        return tr('deposit.interest_rate');
      case _DepositSortType.amount:
        return tr('deposit.amount');
      case _DepositSortType.term:
        return tr('deposit.term');
    }
  }

  String get icon {
    switch (this) {
      case _DepositSortType.rate:
        return '%';
      case _DepositSortType.amount:
        return '\$';
      case _DepositSortType.term:
        return '🕒';
    }
  }

  String get apiField {
    switch (this) {
      case _DepositSortType.rate:
        return 'rate';
      case _DepositSortType.amount:
        return 'amount';
      case _DepositSortType.term:
        return 'term';
    }
  }
}

class _DepositFilterSheetState extends State<_DepositFilterSheet> {
  _DepositSortType? _selectedSort;

  final Color _primaryBlue = const Color(0xFF008CF0);
  final Color _borderColor = const Color(0xFFE0E0E0);

  @override
  void initState() {
    super.initState();
    _selectedSort = _fromSortValue(widget.initialFilter.sort);
  }

  _DepositSortType? _fromSortValue(String? value) {
    if (value == null) return null;
    for (final type in _DepositSortType.values) {
      if (type.apiField == value) {
        return type;
      }
    }
    return null;
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
              tr('deposit.filters'),
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color:
                    Theme.of(context).textTheme.titleLarge?.color ??
                    Colors.black,
              ),
            ),
            SizedBox(height: 24.h),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                children: [
                  ..._DepositSortType.values.map(
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
    required _DepositSortType type,
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
            Text(
              type.icon,
              style: TextStyle(
                fontSize: 16.sp,
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              type.label,
              style: TextStyle(
                fontSize: 16.sp,
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
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
