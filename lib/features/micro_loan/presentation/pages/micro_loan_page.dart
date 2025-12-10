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
import '../../../common/utils/text_localizer.dart';
import '../../domain/entities/microcredit_entity.dart';
import '../../domain/entities/microcredit_filter.dart';
import '../bloc/microcredit_bloc.dart';

@RoutePage()
class MicroLoanPage extends StatefulWidget {
  const MicroLoanPage({super.key});

  @override
  State<MicroLoanPage> createState() => _MicroLoanPageState();
}

class _MicroLoanPageState extends State<MicroLoanPage> {
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
      debugPrint('[MicroLoanPage] Search changed -> "$trimmed"');
      context.read<MicrocreditBloc>().add(MicrocreditSearchChanged(trimmed));
    });
  }

  Future<void> _openFilterSheet(
    BuildContext context,
    MicrocreditFilter filter,
  ) async {
    debugPrint('[MicroLoanPage] Opening filter sheet');
    final result = await showModalBottomSheet<MicrocreditFilter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _MicrocreditFilterSheet(initialFilter: filter),
      ),
    );

    if (result != null) {
      debugPrint(
        '[MicroLoanPage] Filter applied: ${result.toQueryParameters()}',
      );
      context.read<MicrocreditBloc>().add(MicrocreditFilterApplied(result));
    } else {
      debugPrint('[MicroLoanPage] Filter sheet dismissed without changes');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ServiceLocator.resolve<MicrocreditBloc>()
            ..add(const MicrocreditStarted()),
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
            tr('micro_loan.title'),
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
            BlocBuilder<MicrocreditBloc, MicrocreditState>(
              builder: (context, state) {
                return PrimarySearchFilterBar(
                  controller: _searchController,
                  onSearchChanged: (value) =>
                      _onSearchChanged(context, value),
                  onFilterTap: () =>
                      _openFilterSheet(context, state.filter),
                  hasActiveFilter: state.filter.hasActiveFilters,
                  hintText: tr('micro_loan.search_hint'),
                );
              },
            ),
            Expanded(
              child: BlocListener<MicrocreditBloc, MicrocreditState>(
                listener: (context, state) {
                  debugPrint('[MicroLoanPage] BlocListener: State changed!');
                  debugPrint('  - Status: ${state.status}');
                  debugPrint('  - Items: ${state.items.length}');
                  debugPrint('  - isInitialLoading: ${state.isInitialLoading}');
                  debugPrint('  - isPaginating: ${state.isPaginating}');
                  debugPrint('  - hasMore: ${state.hasMore}');
                  if (state.items.isNotEmpty) {
                    debugPrint('  - First item: ${state.items.first.bankName}');
                  }
                },
                child: BlocBuilder<MicrocreditBloc, MicrocreditState>(
                  builder: (context, state) {
                    debugPrint(
                      '[MicroLoanPage] BlocBuilder: Building UI - status: ${state.status}, '
                      'items: ${state.items.length}, isInitialLoading: ${state.isInitialLoading}',
                    );

                    debugPrint(
                      '[MicroLoanPage] State check: status=${state.status}, '
                      'items=${state.items.length}, error=${state.errorMessage}',
                    );

                    if (state.isInitialLoading) {
                      debugPrint('[MicroLoanPage] Showing initial loader');
                      return const _CenteredLoader();
                    }

                    // Agar error bo'lsa ham, items bo'sh bo'lmasa list ko'rsatish
                    if (state.status == MicrocreditViewStatus.failure &&
                        state.items.isEmpty) {
                      debugPrint(
                        '[MicroLoanPage] Showing error state: ${state.errorMessage}',
                      );
                      return _StateMessage(
                        icon: Icons.error_outline,
                        title: tr('common.error'),
                        subtitle:
                            state.errorMessage ??
                            tr('common.something_went_wrong'),
                        actionLabel: tr('common.retry'),
                        onAction: () async {
                          context.read<MicrocreditBloc>().add(
                            const MicrocreditStarted(),
                          );
                        },
                      );
                    }

                    // Agar items bo'sh bo'lsa va error bo'lmasa
                    if (state.items.isEmpty &&
                        state.status != MicrocreditViewStatus.failure) {
                      debugPrint(
                        '[MicroLoanPage] Items are empty, showing empty state',
                      );
                      return _StateMessage(
                        icon: Icons.search_off_rounded,
                        title: tr('micro_loan.empty_title'),
                        subtitle: tr('micro_loan.empty_subtitle'),
                        actionLabel: tr('common.refresh'),
                        onAction: () async {
                          context.read<MicrocreditBloc>().add(
                            const MicrocreditRefreshRequested(),
                          );
                        },
                      );
                    }

                    debugPrint(
                      '[MicroLoanPage] Rendering list with ${state.items.length} items',
                    );

                    return RefreshIndicator(
                      onRefresh: () {
                        final completer = Completer<void>();
                        context.read<MicrocreditBloc>().add(
                          MicrocreditRefreshRequested(completer: completer),
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
                              '[MicroLoanPage] Scroll reached threshold, requesting more',
                            );
                            context.read<MicrocreditBloc>().add(
                              const MicrocreditLoadMoreRequested(),
                            );
                          }
                          debugPrint(
                            '[MicroLoanPage] Scroll update position=${notification.metrics.pixels}',
                          );
                          return false;
                        },
                        child: _MicrocreditList(
                          state: state,
                          onRetryPagination: () {
                            context.read<MicrocreditBloc>().add(
                              const MicrocreditLoadMoreRequested(),
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

class _MicrocreditList extends StatelessWidget {
  const _MicrocreditList({
    required this.state,
    required this.onRetryPagination,
  });

  final MicrocreditState state;
  final VoidCallback onRetryPagination;

  @override
  Widget build(BuildContext context) {
    debugPrint('[MicrocreditList] Building list widget');
    debugPrint('[MicrocreditList] State items: ${state.items.length}');
    debugPrint('[MicrocreditList] State status: ${state.status}');
    debugPrint('[MicrocreditList] State hasMore: ${state.hasMore}');
    debugPrint(
      '[MicrocreditList] State isInitialLoading: ${state.isInitialLoading}',
    );
    debugPrint('[MicrocreditList] State isPaginating: ${state.isPaginating}');

    final hasPaginationError = state.paginationErrorMessage != null;
    final extraSlots = (state.hasMore ? 1 : 0) + (hasPaginationError ? 1 : 0);
    final itemCount = state.items.length + extraSlots;

    debugPrint(
      '[MicrocreditList] Item count: $itemCount (items: ${state.items.length}, extra: $extraSlots)',
    );

    return ListView.separated(
      padding: EdgeInsets.all(20.w),
      itemCount: itemCount,
      separatorBuilder: (_, __) => SizedBox(height: 16.h),
      itemBuilder: (context, index) {
        debugPrint('[MicrocreditList] Building item at index: $index');

        if (hasPaginationError && index == 0) {
          debugPrint('[MicrocreditList] Showing pagination error banner');
          return _PaginationErrorBanner(
            message: state.paginationErrorMessage ?? '',
            onRetry: onRetryPagination,
          );
        }

        final adjustedIndex = hasPaginationError ? index - 1 : index;
        if (adjustedIndex >= state.items.length) {
          debugPrint(
            '[MicrocreditList] Index $adjustedIndex >= items.length ${state.items.length}, showing loader',
          );
          return state.hasMore
              ? const _BottomLoader()
              : const SizedBox.shrink();
        }

        final item = state.items[adjustedIndex];
        debugPrint(
          '[MicrocreditList] Building card for item: ${item.bankName}',
        );
        return _MicrocreditCard(item: item);
      },
    );
  }
}

class _MicrocreditCard extends StatefulWidget {
  const _MicrocreditCard({required this.item});

  final MicrocreditEntity item;

  @override
  State<_MicrocreditCard> createState() => _MicrocreditCardState();
}

class _MicrocreditCardState extends State<_MicrocreditCard> {
  bool _isExpanded = false;

  List<String> _getAdvantages() {
    final advantages = <String>[];
    if (widget.item.rate.isNotEmpty) {
      advantages.add('${tr('micro_loan.interest_rate_label')} ${localizeApiText(widget.item.rate)}');
    }
    if (widget.item.term.isNotEmpty) {
      advantages.add('${tr('micro_loan.term_label')} ${localizeApiText(widget.item.term)}');
    }
    if (widget.item.amount.isNotEmpty) {
      advantages.add('${tr('micro_loan.max_amount_label')} ${widget.item.amount}');
    }
    if (advantages.isEmpty) {
      advantages.add(tr('micro_loan.default_advantages'));
    }
    return advantages;
  }

  Color _channelColor(BuildContext context) {
    if (widget.item.isOnline) {
      return const Color(0xFF10B981);
    }
    return Theme.of(context).colorScheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[MicrocreditCard] Building card for: ${widget.item.bankName}');
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
                          padding:
                              useContainFit ? EdgeInsets.all(6.w) : EdgeInsets.zero,
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
                            AppColors.charcoal,
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
                              : tr('micro_loan.updated_recently'),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color ??
                                AppColors.gray500,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: _channelColor(context).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(100.r),
                          ),
                          child: Text(
                            widget.item.channel,
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: _channelColor(context),
                            ),
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
                  label: tr('micro_loan.interest_rate'),
                  value: localizeApiText(widget.item.rate),
                  isAccent: true,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _InfoBlock(
                  icon: Icons.calendar_month_outlined,
                  label: tr('micro_loan.term'),
                  value: localizeApiText(widget.item.term),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _InfoBlock(
                  icon: Icons.payments_outlined,
                  label: tr('micro_loan.amount'),
                  value: formattedAmount,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          // Afzalliklar section
          if (advantages.isNotEmpty)
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12.r),
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
                          tr('micro_loan.advantages_count', namedArgs: {'count': advantages.length.toString()}),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14.sp,
                            color:
                                Theme.of(context).textTheme.titleLarge?.color ??
                                AppColors.charcoal,
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
                final opened = await openBankWebsite(widget.item.bankName);
                if (!opened) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          tr('common.error'),
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
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
                tr('micro_loan.apply'),
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
                    AppColors.grayText,
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

enum _MicrocreditSortType { percent, amount, duration }

extension _MicrocreditSortTypeX on _MicrocreditSortType {
  String get label {
    switch (this) {
      case _MicrocreditSortType.percent:
        return tr('micro_loan.interest_rate_label');
      case _MicrocreditSortType.amount:
        return tr('micro_loan.amount_label');
      case _MicrocreditSortType.duration:
        return tr('micro_loan.term_label');
    }
  }

  String get icon {
    switch (this) {
      case _MicrocreditSortType.percent:
        return '%';
      case _MicrocreditSortType.amount:
        return '\$';
      case _MicrocreditSortType.duration:
        return '🕒';
    }
  }

  String get apiField {
    switch (this) {
      case _MicrocreditSortType.percent:
        return 'rate';
      case _MicrocreditSortType.amount:
        return 'amount';
      case _MicrocreditSortType.duration:
        return 'term';
    }
  }
}

class _MicrocreditFilterSheet extends StatefulWidget {
  const _MicrocreditFilterSheet({required this.initialFilter});

  final MicrocreditFilter initialFilter;

  @override
  State<_MicrocreditFilterSheet> createState() =>
      _MicrocreditFilterSheetState();
}

class _MicrocreditFilterSheetState extends State<_MicrocreditFilterSheet> {
  late _MicrocreditSortType? _selectedSort;
  late bool _onlyOnline;

  final Color _primaryBlue = const Color(0xFF008CF0);
  final Color _borderColor = const Color(0xFFE0E0E0);

  @override
  void initState() {
    super.initState();
    _selectedSort = _fromSortValue(widget.initialFilter.sort);
    _onlyOnline = widget.initialFilter.opening == 'online';
  }

  _MicrocreditSortType? _fromSortValue(String? value) {
    switch (value) {
      case 'rate':
        return _MicrocreditSortType.percent;
      case 'amount':
        return _MicrocreditSortType.amount;
      case 'term':
        return _MicrocreditSortType.duration;
      default:
        return null;
    }
  }

  void _reset() {
    setState(() {
      _selectedSort = null;
      _onlyOnline = false;
    });
  }

  void _apply() {
    final updated = widget.initialFilter.copyWith(
      opening: _onlyOnline ? 'online' : null,
      sort: _selectedSort?.apiField,
      direction: _selectedSort == null ? null : 'asc',
      resetOpening: !_onlyOnline,
      resetSort: _selectedSort == null,
      resetDirection: _selectedSort == null,
    );
    Navigator.of(context).pop(updated);
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
              tr('micro_loan.filters'),
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.titleLarge?.color ??
                    Colors.black87,
              ),
            ),
            SizedBox(height: 24.h),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                children: [
                  ..._MicrocreditSortType.values.map(
                    (type) => Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: _buildSortOption(
                        type: type,
                        isSelected: _selectedSort == type,
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  _buildToggleOption(),
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
                          color: Theme.of(context).textTheme.titleLarge?.color ??
                              AppColors.charcoal,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
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
                        tr('common.sort'),
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
    required _MicrocreditSortType type,
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
          border: Border.all(
            color: isSelected ? _primaryBlue : _borderColor,
          ),
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

  Widget _buildToggleOption() {
    return InkWell(
      onTap: () => setState(() => _onlyOnline = !_onlyOnline),
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: _borderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              tr('micro_loan.only_online_applications'),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.titleLarge?.color ??
                    Colors.black87,
              ),
            ),
            Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _onlyOnline ? _primaryBlue : Colors.grey[400]!,
                  width: 2,
                ),
                color: _onlyOnline ? _primaryBlue : Colors.transparent,
              ),
              child: _onlyOnline
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
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
