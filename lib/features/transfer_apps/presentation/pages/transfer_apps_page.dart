import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/dio/singletons/service_locator.dart';
import '../../../../core/widgets/primary_back_button.dart';
import '../../../../core/widgets/primary_search_filter_bar.dart';
import '../../domain/entities/transfer_app.dart';
import '../../domain/entities/transfer_app_filter.dart';
import '../bloc/transfer_apps_bloc.dart';
import '../widgets/app_card.dart';

@RoutePage()
class TransferAppsPage extends StatefulWidget {
  const TransferAppsPage({super.key});

  @override
  State<TransferAppsPage> createState() => _TransferAppsPageState();
}

class _TransferAppsPageState extends State<TransferAppsPage> {
  late final TextEditingController _searchController;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  Future<void> _openFilterSheet(
    BuildContext context,
    TransferAppFilter filter,
    List<TransferApp> items,
  ) async {
    final result = await showModalBottomSheet<TransferAppFilter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _TransferAppsFilterSheet(initialFilter: filter, items: items),
      ),
    );

    if (result != null && mounted) {
      context.read<TransferAppsBloc>().add(TransferAppsFilterApplied(result));
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearchChanged(BuildContext context, String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      context.read<TransferAppsBloc>().add(
        TransferAppsSearchChanged(value.trim()),
      );
    });
  }

  Future<void> _handleRefresh(BuildContext context) {
    final bloc = context.read<TransferAppsBloc>();
    final completer = Completer<void>();
    late StreamSubscription<TransferAppsState> sub;

    sub = bloc.stream.listen((state) {
      final isLoadingState =
          state.status == TransferAppsStatus.refreshing ||
          state.status == TransferAppsStatus.loading;
      if (!isLoadingState) {
        if (!completer.isCompleted) {
          completer.complete();
        }
        sub.cancel();
      }
    });

    bloc.add(const TransferAppsRefreshed());
    return completer.future.timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        if (!completer.isCompleted) {
          completer.complete();
        }
        sub.cancel();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark
        ? Theme.of(context).scaffoldBackgroundColor
        : AppColors.background;

    return BlocProvider(
      create: (_) =>
          ServiceLocator.resolve<TransferAppsBloc>()
            ..add(const TransferAppsStarted()),
      child: Scaffold(
        backgroundColor: scaffoldBg,
        body: SafeArea(
          child: Column(
            children: [
              BlocBuilder<TransferAppsBloc, TransferAppsState>(
                builder: (context, state) {
                  return _buildHeader(
                    context,
                    isDark,
                    hasActiveFilter: state.filter.hasActiveFilters,
                    onFilterTap: () =>
                        _openFilterSheet(context, state.filter, state.items),
                  );
                },
              ),
              Expanded(
                child: BlocBuilder<TransferAppsBloc, TransferAppsState>(
                  builder: (context, state) {
                    if (state.status == TransferAppsStatus.loading ||
                        state.status == TransferAppsStatus.initial) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state.status == TransferAppsStatus.failure) {
                      return _StateMessage(
                        icon: Icons.error_outline,
                        title: tr('transfers.error_title'),
                        subtitle:
                            state.errorMessage ??
                            tr('transfers.error_subtitle'),
                        actionLabel: tr('transfers.retry'),
                        onAction: () => context.read<TransferAppsBloc>().add(
                          const TransferAppsStarted(),
                        ),
                      );
                    }

                    if (state.items.isEmpty) {
                      return _StateMessage(
                        icon: Icons.search_off_rounded,
                        title: tr('transfers.empty_title'),
                        subtitle: tr('transfers.empty_subtitle'),
                        actionLabel: tr('transfers.refresh'),
                        onAction: () => context.read<TransferAppsBloc>().add(
                          const TransferAppsStarted(),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () => _handleRefresh(context),
                      child: ListView.separated(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 20.h,
                        ),
                        itemCount: state.items.length,
                        separatorBuilder: (_, __) => SizedBox(height: 16.h),
                        itemBuilder: (context, index) {
                          return AppCard(app: state.items[index]);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    bool isDark, {
    required bool hasActiveFilter,
    required VoidCallback onFilterTap,
  }) {
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
      child: Column(
        children: [
          // Top Navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              PrimaryBackButton(onTap: () => context.router.pop()),
              Text(
                "O'tkazma ilovalar",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              SizedBox(width: 44.w),
            ],
          ),
          SizedBox(height: 20.h),

          // Search Bar & Filter
          PrimarySearchFilterBar(
            controller: _searchController,
            onSearchChanged: (value) => _handleSearchChanged(context, value),
            onFilterTap: onFilterTap,
            hasActiveFilter: hasActiveFilter,
            hintText: "Bank nomini qidiring...",
            padding: EdgeInsets.zero,
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
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48.sp, color: theme.colorScheme.primary),
            SizedBox(height: 16.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
            SizedBox(height: 20.h),
            ElevatedButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}

class _TransferAppsFilterSheet extends StatefulWidget {
  const _TransferAppsFilterSheet({
    required this.initialFilter,
    required this.items,
  });

  final TransferAppFilter initialFilter;
  final List<TransferApp> items;

  @override
  State<_TransferAppsFilterSheet> createState() =>
      _TransferAppsFilterSheetState();
}

class _RateOption {
  const _RateOption(this.label, {this.min, this.max});
  final String label;
  final double? min;
  final double? max;

  static const empty = _RateOption('');
}

class _TransferAppsFilterSheetState extends State<_TransferAppsFilterSheet> {
  List<String> get _speedOptions => [
    tr('transfers.fast'),
    tr('transfers.average'),
  ];
  late final List<_RateOption> _rateOptions;
  String? _selectedRateLabel;
  String? _selectedSpeedLabel;
  @override
  void initState() {
    super.initState();
    _rateOptions = _buildRateOptions(widget.items);
    _selectedRateLabel = _labelForRate(
      widget.initialFilter.commissionFrom,
      widget.initialFilter.commissionTo,
    );
    _selectedSpeedLabel = widget.initialFilter.speed;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      color: Colors.transparent,
      child: Container(
        height: size.height * 0.85,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.r),
            topRight: Radius.circular(24.r),
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 12.h),
            Container(
              width: 48.w,
              height: 5.h,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2.5.r),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 16.h, bottom: 20.h),
              child: Text(
                tr('transfers.filter'),
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).textTheme.titleLarge?.color ??
                      AppColors.charcoal,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      Icons.percent_rounded,
                      tr('transfers.commission_rate'),
                    ),
                    SizedBox(height: 12.h),
                    _buildChipWrap(
                      _rateOptions.map((option) => option.label).toList(),
                      _selectedRateLabel,
                      (value) => setState(() {
                        _selectedRateLabel = _selectedRateLabel == value
                            ? null
                            : value;
                      }),
                    ),
                    SizedBox(height: 28.h),
                    _buildSectionHeader(
                      Icons.bolt_outlined,
                      tr('transfers.speed'),
                    ),
                    SizedBox(height: 12.h),
                    _buildChipWrap(
                      _speedOptions,
                      _selectedSpeedLabel,
                      (value) => setState(() {
                        _selectedSpeedLabel = _selectedSpeedLabel == value
                            ? null
                            : value;
                      }),
                    ),
                    SizedBox(height: 28.h),
                    // Removed transfer method section
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 36.h),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
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
                          foregroundColor: Theme.of(context).textTheme.titleLarge?.color ??
                              AppColors.charcoal,
                        ),
                        child: Text(
                          tr('common.reset'),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16.sp,
                            color: Theme.of(context).textTheme.titleLarge?.color ??
                                AppColors.charcoal,
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
                          tr('transfers.sort'),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16.sp,
                            color: Colors.white,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Icon(
          icon,
          size: 20.sp,
          color: isDark
              ? AppColors.grayText
              : AppColors.gray500,
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

  void _reset() {
    setState(() {
      _selectedRateLabel = null;
      _selectedSpeedLabel = null;
    });
  }

  void _apply() {
    final rateOption = _rateOptions.firstWhere(
      (option) => option.label == _selectedRateLabel,
      orElse: () => _RateOption.empty,
    );
    final hasRate = rateOption.min != null || rateOption.max != null;

    final updated = widget.initialFilter.copyWith(
      commissionFrom: rateOption.min,
      commissionTo: rateOption.max,
      sort: hasRate ? 'commission' : null,
      direction: hasRate ? 'asc' : null,
      speed: _selectedSpeedLabel,
      page: 0,
      resetCommission: rateOption.min == null,
      resetCommissionTo: rateOption.max == null,
      resetSort: !hasRate,
      resetDirection: !hasRate,
      resetSpeed: _selectedSpeedLabel == null,
    );
    Navigator.of(context).pop(updated);
  }

  Widget _buildChipWrap(
    List<String> options,
    String? selected,
    ValueChanged<String> onTap,
  ) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: options.map((label) {
        final isSelected = selected == label;
        return GestureDetector(
          onTap: () => onTap(label),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
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
                color: Theme.of(context).textTheme.titleLarge?.color ??
                    AppColors.charcoal,
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

  List<_RateOption> _buildRateOptions(List<TransferApp> items) {
    final values =
        items
            .map((app) => _extractCommissionNumbers(app.commission))
            .expand((numbers) => numbers)
            .toList()
          ..sort();

    if (values.isEmpty) {
      return const [
        _RateOption('0%', min: 0, max: 0),
        _RateOption('0.1-0.5%', min: 0.1, max: 0.5),
        _RateOption('0.6%+', min: 0.6, max: null),
      ];
    }

    final min = values.first;
    final max = values.last;

    if ((max - min).abs() < 0.0001) {
      return [
        _RateOption('${_formatPercentValue(min)}%', min: min, max: min),
        _RateOption('${_formatPercentValue(min)}%+', min: min, max: null),
      ];
    }

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
      final key = '${option.min ?? 'null'}-${option.max ?? 'null'}';
      if (seen.add(key)) {
        result.add(option);
      }
    }
    return result;
  }

  String? _labelForRate(double? from, double? to) {
    if (from == null && to == null) return null;
    for (final option in _rateOptions) {
      if (_areDoublesEqual(option.min, from) &&
          _areDoublesEqual(option.max, to)) {
        return option.label;
      }
    }
    return null;
  }

  bool _areDoublesEqual(double? a, double? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    return (a - b).abs() < 0.0001;
  }

  List<double> _extractCommissionNumbers(String? raw) {
    if (raw == null || raw.isEmpty) return const [];
    final matches = RegExp(r'[\d.,]+').allMatches(raw);
    final values = matches
        .map(
          (match) => double.tryParse(
            match.group(0)!.replaceAll(' ', '').replaceAll(',', '.'),
          ),
        )
        .whereType<double>()
        .toList();
    if (values.isEmpty) return const [];
    return values;
  }

  String _formatPercentValue(double value) {
    return value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(1);
  }

  String _formatPercentRange(double from, double? to) {
    if (to == null || (to - from).abs() < 0.0001) {
      return '${_formatPercentValue(from)}%';
    }
    return '${_formatPercentValue(from)}-${_formatPercentValue(to)}%';
  }
}
