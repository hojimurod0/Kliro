import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/dio/singletons/service_locator.dart';
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
  final List<int> _pageSizes = [5, 10, 20];

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
                return _SearchAndActionsBar(
                  controller: _searchController,
                  onSearchChanged: (value) => _onSearchChanged(context, value),
                  onClearSearch: () {
                    _searchController.clear();
                    context.read<DepositBloc>().add(
                      const DepositSearchChanged(''),
                    );
                  },
                  onOpenFilter: () => _openFilterSheet(context, state.filter),
                  selectedPageSize: state.pageSize,
                  pageSizes: _pageSizes,
                  onPageSizeChanged: (size) {
                    context.read<DepositBloc>().add(
                      DepositPageSizeChanged(size),
                    );
                  },
                  hasActiveFilter: state.filter.hasActiveFilters,
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

class _SearchAndActionsBar extends StatelessWidget {
  const _SearchAndActionsBar({
    required this.controller,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onOpenFilter,
    required this.selectedPageSize,
    required this.pageSizes,
    required this.onPageSizeChanged,
    required this.hasActiveFilter,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final VoidCallback onOpenFilter;
  final int selectedPageSize;
  final List<int> pageSizes;
  final ValueChanged<int> onPageSizeChanged;
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
                  height: 48.h,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 42.w,
                        child: Icon(
                          Icons.search,
                          color: Theme.of(context).colorScheme.primary,
                          size: 22.sp,
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: controller,
                          onChanged: onSearchChanged,
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                          decoration: InputDecoration(
                            hintText: tr('deposit.search_hint'),
                            hintStyle: TextStyle(
                              color:
                                  Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.color ??
                                  const Color(0xFF9CA3AF),
                              fontSize: 14.sp,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      if (controller.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          color:
                              Theme.of(context).textTheme.bodySmall?.color ??
                              Colors.grey,
                          onPressed: onClearSearch,
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              _PageSizeSelector(
                pageSizes: pageSizes,
                selected: selectedPageSize,
                onChanged: onPageSizeChanged,
              ),
              SizedBox(width: 12.w),
              InkWell(
                onTap: onOpenFilter,
                borderRadius: BorderRadius.circular(12.r),
                child: Container(
                  width: 48.h,
                  height: 48.h,
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
                    color: hasActiveFilter
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.primary,
                    size: 24.sp,
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

class _DepositCard extends StatelessWidget {
  const _DepositCard({required this.item});

  final DepositEntity item;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                child: Icon(
                  Icons.account_balance,
                  color: Theme.of(context).colorScheme.primary,
                  size: 22.sp,
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
                        fontWeight: FontWeight.w700,
                        color:
                            Theme.of(context).textTheme.titleLarge?.color ??
                            const Color(0xFF111827),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      item.description,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color:
                            Theme.of(context).textTheme.bodyMedium?.color ??
                            const Color(0xFF6B7280),
                      ),
                    ),
                    if (item.currency != null) ...[
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Text(
                            item.currency!,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color:
                                  Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.color ??
                                  const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ],
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
                  value: item.rate,
                  isAccent: true,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _InfoBlock(
                  icon: Icons.calendar_month_outlined,
                  label: tr('deposit.term'),
                  value: item.term,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _InfoBlock(
                  icon: Icons.payments_outlined,
                  label: tr('deposit.amount'),
                  value: item.amount,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            height: 46.h,
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
    final Color accentColor = const Color(0xFF10B981);

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isAccent
            ? (isDark ? const Color(0xFF1A3A2E) : const Color(0xFFECFDF5))
            : (isDark
                  ? Theme.of(context).scaffoldBackgroundColor
                  : const Color(0xFFF9FAFB)),
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
                      const Color(0xFF6B7280),
            size: 18.sp,
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color:
                  Theme.of(context).textTheme.bodyMedium?.color ??
                  const Color(0xFF6B7280),
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
                        const Color(0xFF111827),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _PageSizeSelector extends StatelessWidget {
  const _PageSizeSelector({
    required this.pageSizes,
    required this.selected,
    required this.onChanged,
  });

  final List<int> pageSizes;
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      initialValue: selected,
      onSelected: onChanged,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      itemBuilder: (_) => pageSizes
          .map(
            (e) => PopupMenuItem<int>(
              value: e,
              child: Text('${tr('deposit.page_size')} $e'),
            ),
          )
          .toList(),
      child: Container(
        width: 48.h,
        height: 48.h,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        alignment: Alignment.center,
        child: Text(
          '$selected',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color:
                Theme.of(context).textTheme.titleLarge?.color ??
                Theme.of(context).colorScheme.primary,
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

class _DepositFilterSheet extends StatefulWidget {
  const _DepositFilterSheet({required this.initialFilter});

  final DepositFilter initialFilter;

  @override
  State<_DepositFilterSheet> createState() => _DepositFilterSheetState();
}

class _DepositFilterSheetState extends State<_DepositFilterSheet> {
  late final TextEditingController _bankController;
  late final TextEditingController _rateController;
  late final TextEditingController _termController;
  late final TextEditingController _amountController;
  String? _sort;
  String? _direction;

  @override
  void initState() {
    super.initState();
    _bankController = TextEditingController(
      text: widget.initialFilter.bank ?? '',
    );
    _rateController = TextEditingController(
      text: widget.initialFilter.rateFrom?.toString() ?? '',
    );
    _termController = TextEditingController(
      text: widget.initialFilter.termMonthsFrom?.toString() ?? '',
    );
    _amountController = TextEditingController(
      text: widget.initialFilter.amountFrom?.toString() ?? '',
    );
    _sort = widget.initialFilter.sort;
    _direction = widget.initialFilter.direction;
  }

  @override
  void dispose() {
    _bankController.dispose();
    _rateController.dispose();
    _termController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _reset() {
    _bankController.clear();
    _rateController.clear();
    _termController.clear();
    _amountController.clear();
    setState(() {
      _sort = null;
      _direction = null;
    });
  }

  void _apply() {
    Navigator.of(context).pop(
      DepositFilter(
        bank: _bankController.text.trim().isEmpty
            ? null
            : _bankController.text.trim(),
        rateFrom: double.tryParse(_rateController.text.replaceAll(',', '.')),
        termMonthsFrom: int.tryParse(_termController.text),
        amountFrom: double.tryParse(_amountController.text),
        sort: _sort,
        direction: _direction,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 24.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 46.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor,
              borderRadius: BorderRadius.circular(100.r),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            tr('deposit.filters'),
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 16.h),
          _FilterField(
            label: tr('deposit.bank_filter'),
            controller: _bankController,
            hint: 'AgroBank',
          ),
          SizedBox(height: 12.h),
          _FilterField(
            label: tr('deposit.rate_from'),
            controller: _rateController,
            hint: '18',
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 12.h),
          _FilterField(
            label: tr('deposit.term_months_from'),
            controller: _termController,
            hint: '6',
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 12.h),
          _FilterField(
            label: tr('deposit.amount_from'),
            controller: _amountController,
            hint: '1000000',
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 12.h),
          _DropdownField(
            label: tr('deposit.sort_field'),
            value: _sort,
            items: const [
              DropdownMenuItem(value: 'bank_name', child: Text('Bank nomi')),
              DropdownMenuItem(value: 'rate', child: Text('Foiz')),
              DropdownMenuItem(value: 'amount', child: Text('Summasi')),
              DropdownMenuItem(
                value: 'created_at',
                child: Text('Oxirgi yangilanish'),
              ),
            ],
            onChanged: (value) => setState(() => _sort = value),
          ),
          SizedBox(height: 12.h),
          _DropdownField(
            label: tr('deposit.sort_direction'),
            value: _direction,
            items: [
              DropdownMenuItem(value: 'asc', child: Text(tr('deposit.asc'))),
              DropdownMenuItem(value: 'desc', child: Text(tr('deposit.desc'))),
            ],
            onChanged: (value) => setState(() => _direction = value),
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _reset,
                  child: Text(tr('common.reset')),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: _apply,
                  child: Text(tr('common.apply')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterField extends StatelessWidget {
  const _FilterField({
    required this.label,
    required this.controller,
    required this.hint,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 6.h),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        ),
      ],
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 6.h),
        DropdownButtonFormField<String>(
          value: value,
          items: items,
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        ),
      ],
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
