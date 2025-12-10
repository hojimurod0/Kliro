import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../data/api/api_client.dart';
import '../../../../data/services/auto_credit_service.dart';
import '../../../common/utils/bank_assets.dart';
import '../../../common/utils/bank_data.dart';
import '../../../common/utils/text_localizer.dart';
import '../../data/datasources/auto_credit_local_data_source.dart';
import '../../data/repositories/auto_credit_repository_impl.dart';
import '../../domain/entities/auto_credit_filter.dart';
import '../../domain/entities/auto_credit_offer.dart';
import '../../domain/usecases/get_auto_credit_offers.dart';
import '../../../../core/widgets/primary_back_button.dart';
import '../../../../core/widgets/primary_search_filter_bar.dart';

@RoutePage()
class AutoCreditPage extends StatefulWidget {
  const AutoCreditPage({super.key});

  @override
  State<AutoCreditPage> createState() => _AutoCreditPageState();
}

class _AutoCreditPageState extends State<AutoCreditPage> {
  late final GetAutoCreditOffers _getAutoCreditOffers;
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;
  AutoCreditFilter _filter = AutoCreditFilter.empty.copyWith(
    sort: 'rate',
    direction: 'asc', // Самый низкий процент сверху
  );
  List<AutoCreditOffer> _offers = [];
  bool _isLoading = true;

  void _safeSetState(VoidCallback fn) {
    if (!mounted) return;
    setState(fn);
  }

  @override
  void initState() {
    super.initState();
    final apiClient = ApiClient();
    _getAutoCreditOffers = GetAutoCreditOffers(
      AutoCreditRepositoryImpl(
        localDataSource: const AutoCreditLocalDataSource(),
        remoteService: AutoCreditService(apiClient),
      ),
    );
    _loadOffers();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadOffers() async {
    _safeSetState(() {
      _isLoading = true;
    });

    try {
      final offers = await _getAutoCreditOffers(filter: _filter);
      _safeSetState(() {
        _offers = offers;
        _isLoading = false;
      });
    } catch (e) {
      _safeSetState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'common.error_occurred'.tr().replaceAll('{0}', e.toString()),
            ),
          ),
        );
      }
    }
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      final trimmed = value.trim();
      _safeSetState(() {
        if (trimmed.isEmpty) {
          _filter = _filter.copyWith(resetSearch: true);
        } else {
          _filter = _filter.copyWith(search: trimmed);
        }
      });
      _loadOffers();
    });
  }

  Future<void> _openFilterSheet() async {
    if (!mounted) return;
    final result = await showModalBottomSheet<AutoCreditFilter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AutoCreditFilterSheet(initialFilter: _filter),
    );

    if (!mounted || result == null) {
      return;
    }

    _safeSetState(() {
      _filter = result;
    });
    _loadOffers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        title: Text(
          tr('auto_credit.title'),
          style: TextStyle(
            color:
                Theme.of(context).textTheme.titleLarge?.color ??
                AppColors.darkTextAutoCredit,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Qidiruv va Filtr
          PrimarySearchFilterBar(
            controller: _searchController,
            onSearchChanged: _onSearchChanged,
            onFilterTap: _openFilterSheet,
            hasActiveFilter: _filter.hasActiveFilters,
            hintText: tr('auto_credit.search_hint'),
          ),
          // Takliflar Ro'yxati
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    itemCount: _offers.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 16.h),
                        child: AutoCreditOfferCard(offer: _offers[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _AutoCreditFilterSheet extends StatefulWidget {
  const _AutoCreditFilterSheet({required this.initialFilter});

  final AutoCreditFilter initialFilter;

  @override
  State<_AutoCreditFilterSheet> createState() => _AutoCreditFilterSheetState();
}

class _AutoCreditFilterSheetState extends State<_AutoCreditFilterSheet> {
  String? _selectedRateLabel;
  String? _selectedTermLabel;
  String? _selectedPaymentLabel;

  @override
  void initState() {
    super.initState();
    _selectedRateLabel = _labelForRate(
      widget.initialFilter.rateFrom,
      _getRateOptions(),
    );
    _selectedTermLabel = _labelForTerm(
      widget.initialFilter.termMonthsFrom,
      _getTermOptions(),
    );
    _selectedPaymentLabel = _labelForPayment(
      widget.initialFilter.opening,
      _getPaymentOptions(),
    );
  }

  void _reset() {
    setState(() {
      _selectedRateLabel = null;
      _selectedTermLabel = null;
      _selectedPaymentLabel = null;
    });
  }

  void _apply() {
    final rateOption = _getRateOptions().firstWhere(
      (o) => o.label == _selectedRateLabel,
      orElse: () => _RateOption.empty,
    );
    final termOption = _getTermOptions().firstWhere(
      (o) => o.label == _selectedTermLabel,
      orElse: () => _TermOption.empty,
    );
    final paymentOption = _getPaymentOptions().firstWhere(
      (o) => o.label == _selectedPaymentLabel,
      orElse: () => _PaymentOption.empty,
    );

    final updated = widget.initialFilter.copyWith(
      rateFrom: rateOption.value,
      termMonthsFrom: termOption.months,
      amountFrom: null,
      opening: paymentOption.opening,
      resetRate: rateOption.value == null,
      resetTerm: termOption.months == null,
      resetAmount: true,
      resetOpening: paymentOption.opening == null,
    );
    Navigator.of(context).pop(updated);
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
              tr('auto_credit.filters'),
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
                    _buildSectionHeader(Icons.percent_rounded, tr('auto_credit.interest_rate_label')),
                    SizedBox(height: 12.h),
                    _buildChipRow(
                      options: _getRateOptions().map((e) => e.label).toList(),
                      selected: _selectedRateLabel,
                      onSelected: (value) =>
                          setState(() => _selectedRateLabel = value),
                    ),
                    SizedBox(height: 28.h),
                    _buildSectionHeader(
                      Icons.calendar_today_outlined,
                      tr('auto_credit.term_label'),
                    ),
                    SizedBox(height: 12.h),
                    _buildChipRow(
                      options: _getTermOptions().map((e) => e.label).toList(),
                      selected: _selectedTermLabel,
                      onSelected: (value) =>
                          setState(() => _selectedTermLabel = value),
                    ),
                    SizedBox(height: 28.h),
                    _buildSectionHeader(
                      Icons.credit_card_outlined,
                      tr('auto_credit.payment_type_label'),
                    ),
                    SizedBox(height: 12.h),
                    _buildChipRow(
                      options: _getPaymentOptions().map((e) => e.label).toList(),
                      selected: _selectedPaymentLabel,
                      onSelected: (value) =>
                          setState(() => _selectedPaymentLabel = value),
                    ),
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
                    color: Colors.grey.withValues(alpha: 0.1),
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
                  SizedBox(width: 16.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _apply,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        backgroundColor: Theme.of(context).colorScheme.primary,
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

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 20.sp, color: const Color(0xFF6B7280)),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color:
                Theme.of(context).textTheme.titleLarge?.color ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildChipRow({
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
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isSelected
                    ? Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.5)
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: const Color(0xFF4B5563),
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String? _labelForRate(double? value, List<_RateOption> options) {
    if (value == null) return null;
    for (final option in options) {
      if ((option.value ?? -1) == value) return option.label;
    }
    return null;
  }

  String? _labelForTerm(int? value, List<_TermOption> options) {
    if (value == null) return null;
    for (final option in options) {
      if ((option.months ?? -1) == value) return option.label;
    }
    return null;
  }

  String? _labelForPayment(String? opening, List<_PaymentOption> options) {
    if (opening == null) return null;
    for (final option in options) {
      if (option.opening == opening) return option.label;
    }
    return null;
  }
}

class _RateOption {
  const _RateOption(this.label, this.value);
  final String label;
  final double? value;
  static const empty = _RateOption('', null);
}

class _TermOption {
  const _TermOption(this.label, this.months);
  final String label;
  final int? months;
  static const empty = _TermOption('', null);
}

class _PaymentOption {
  const _PaymentOption(this.label, this.opening);
  final String label;
  final String? opening;
  static const empty = _PaymentOption('', null);
}

List<_RateOption> _getRateOptions() {
  return [
    _RateOption(tr('auto_credit.rate_option_16_20'), 16),
    _RateOption(tr('auto_credit.rate_option_21_25'), 21),
    _RateOption(tr('auto_credit.rate_option_26_plus'), 26),
  ];
}

List<_TermOption> _getTermOptions() {
  return [
    _TermOption(tr('auto_credit.term_option_5_years'), 60),
    _TermOption(tr('auto_credit.term_option_7_years'), 84),
    _TermOption(tr('auto_credit.term_option_8_plus_years'), 96),
  ];
}

List<_PaymentOption> _getPaymentOptions() {
  return [
    _PaymentOption(tr('auto_credit.online'), 'online'),
    _PaymentOption(tr('auto_credit.bank_branch'), 'bank'),
  ];
}

class AutoCreditOfferCard extends StatefulWidget {
  const AutoCreditOfferCard({super.key, required this.offer});

  final AutoCreditOffer offer;

  @override
  State<AutoCreditOfferCard> createState() => _AutoCreditOfferCardState();
}

class _AutoCreditOfferCardState extends State<AutoCreditOfferCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final applicationIcon = widget.offer.applicationIcon;
    final applicationColor = widget.offer.applicationColor;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Theme.of(context).dividerColor, width: 1),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.05),
                  spreadRadius: 0,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopInfoRow(applicationIcon, applicationColor),
          SizedBox(height: 12.h),
          _buildMonthlyPaymentRow(),
          SizedBox(height: 16.h),
          _buildMetricsGrid(applicationIcon, applicationColor),
          SizedBox(height: 16.h),
          _buildAdvantagesSection(),
          SizedBox(height: 16.h),
          _buildActionButton(),
        ],
      ),
    );
  }

  Widget _buildTopInfoRow(IconData applicationIcon, Color applicationColor) {
    final logoAsset = bankLogoAsset(widget.offer.bankName);
    final useContainFit =
        logoAsset != null && bankLogoUsesContainFit(widget.offer.bankName);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: 48.w,
          height: 48.w,
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14.r),
          ),
          clipBehavior: Clip.antiAlias,
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
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.offer.bankName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color:
                      Theme.of(context).textTheme.titleLarge?.color ??
                      AppColors.darkTextAutoCredit,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyPaymentRow() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 18.sp,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                tr('auto_credit.monthly_payment'),
                style: TextStyle(
                  fontSize: 13.sp,
                  color:
                      Theme.of(context).textTheme.bodyMedium?.color ??
                      AppColors.mutedText,
                ),
              ),
            ],
          ),
          Text(
            widget.offer.monthlyPayment.replaceAll(' ${tr('auto_credit.per_month')}', ''),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(IconData applicationIcon, Color applicationColor) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AutoCreditMetricBox(
                label: tr('auto_credit.interest'),
                value: localizeApiText(widget.offer.interestRate),
                valueColor: AppColors.accentGreen,
                icon: Icons.percent,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: AutoCreditMetricBox(
                label: tr('auto_credit.term'),
                value: localizeApiText(widget.offer.term),
                icon: Icons.calendar_today_outlined,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: AutoCreditMetricBox(
                label: tr('auto_credit.max_amount'),
                value: localizeApiText(widget.offer.maxSum),
                icon: Icons.credit_card_outlined,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: AutoCreditMetricBox(
                label: tr('auto_credit.application_method'),
                value: widget.offer.applicationMethod,
                icon: applicationIcon,
                valueColor: applicationColor,
                isApplicationType: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAdvantagesSection() {
    final advantages = widget.offer.advantages;
    if (advantages.isEmpty) return const SizedBox.shrink();

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
                Text(
                  tr('auto_credit.advantages_count', namedArgs: {'count': advantages.length.toString()}),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.sp,
                    color:
                        Theme.of(context).textTheme.titleLarge?.color ??
                        AppColors.darkTextAutoCredit,
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
          if (_isExpanded) ...[
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
                              const Color(0xFF6B7280),
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

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      height: 48.h,
      child: ElevatedButton(
        onPressed: () async {
          final opened = await openBankWebsite(widget.offer.bankName);
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 0,
        ),
        child: Text(
          tr('auto_credit.apply_button'),
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

class AutoCreditMetricBox extends StatelessWidget {
  const AutoCreditMetricBox({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
    this.isApplicationType = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;
  final bool isApplicationType;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 70.h,
      padding: EdgeInsets.only(left: 12.w, right: 12.w, top: 8.h, bottom: 8.h),
      decoration: BoxDecoration(
        color: isDark
            ? Theme.of(context).scaffoldBackgroundColor
            : AppColors.metricBoxBackground,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Expanded(
                child: Builder(
                  builder: (context) {
                    // Проверяем, содержит ли значение ключи локализации и переводим их
                    String displayValue = value;
                    if (value.contains('auto_credit.')) {
                      // Заменяем ключи локализации на переведенные значения
                      displayValue = value.replaceAllMapped(
                        RegExp(r'auto_credit\.(\w+)'),
                        (match) => context.tr('auto_credit.${match.group(1)}'),
                      );
                    }
                    return Text(
                      displayValue,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color:
                            valueColor ??
                            (Theme.of(context).textTheme.titleLarge?.color ??
                                AppColors.darkTextAutoCredit),
                      ),
                    );
                  },
                ),
              ),
              if (isApplicationType && value == tr('auto_credit.online'))
                Padding(
                  padding: EdgeInsets.only(left: 4.w),
                  child: Icon(
                    Icons.check_circle_outline,
                    color: AppColors.accentGreen,
                    size: 14.sp,
                  ),
                ),
            ],
          ),
          Row(
            children: [
              Icon(
                icon,
                color:
                    Theme.of(context).textTheme.bodySmall?.color ??
                    AppColors.veryMutedText,
                size: 14.sp,
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  label.startsWith('auto_credit.') ? tr(label) : label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color:
                        Theme.of(context).textTheme.bodySmall?.color ??
                        AppColors.veryMutedText,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
