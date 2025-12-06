import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/dio/singletons/service_locator.dart';
import '../../../../core/widgets/primary_search_filter_bar.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../common/utils/bank_assets.dart';
import '../../../common/utils/bank_data.dart';
import '../../domain/entities/card_filter.dart';
import '../../domain/entities/card_offer.dart';
import '../bloc/card_bloc.dart';

@RoutePage()
class CardsPage extends StatefulWidget {
  const CardsPage({super.key});

  @override
  State<CardsPage> createState() => _CardsPageState();
}

class _CardsPageState extends State<CardsPage> {
  late final TextEditingController _searchController;
  Timer? _searchDebounce;
  int _selectedFilterIndex = 0;

  // Bank nomlarini state'dan olish va sortlab berish
  List<String> _getBankNamesFromState(CardState state) {
    // Barcha bank nomlarini olish (null va bo'sh string'larni olib tashlash)
    // visibleItems'dan emas, items'dan olamiz, chunki filter qo'llanganidan keyin
    // barcha bank nomlari ko'rinmaydi
    final banks = state.items
        .map((offer) => offer.bankName.trim())
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList();

    // Alfavit bo'yicha sortlash (case-insensitive, UTF-8 to'g'ri ishlashi uchun)
    banks.sort((a, b) {
      // O'zbek tilidagi harflarni to'g'ri solishtirish uchun
      final aLower = a.toLowerCase().trim();
      final bLower = b.toLowerCase().trim();
      return aLower.compareTo(bLower);
    });

    return banks;
  }

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
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      context.read<CardBloc>().add(CardEvent.searchChanged(value));
    });
  }

  void _onFilterSelected(
    BuildContext context,
    int index,
    List<String> bankNames,
  ) {
    setState(() => _selectedFilterIndex = index);
    // Agar index 0 bo'lsa, barcha banklar (filter yo'q)
    // Aks holda, tanlangan bank
    final selectedBank = index == 0 ? null : bankNames[index - 1];

    // Bank nomini to'g'ri formatlash (trim qilish)
    final trimmedBank = selectedBank?.trim();

    final updatedFilter = context.read<CardBloc>().state.filter.copyWith(
      bank: trimmedBank?.isEmpty == true ? null : trimmedBank,
      resetBank: selectedBank == null || trimmedBank?.isEmpty == true,
    );
    context.read<CardBloc>().add(CardEvent.filterApplied(updatedFilter));
  }

  // Filter sheet olib tashlandi

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ServiceLocator.resolve<CardBloc>()..add(const CardEvent.started()),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: _buildAppBar(context),
        body: Column(
          children: [
            BlocBuilder<CardBloc, CardState>(
              builder: (context, state) {
                return PrimarySearchFilterBar(
                  controller: _searchController,
                  onSearchChanged: (value) => _onSearchChanged(context, value),
                  // Filter button olib tashlandi
                  hintText: tr('cards.search_hint'),
                );
              },
            ),
            Expanded(
              child: BlocBuilder<CardBloc, CardState>(
                builder: (context, state) {
                  if (state.isInitialLoading) {
                    return LoadingStateWidget(message: 'common.loading'.tr());
                  }

                  if (state.status == CardViewStatus.failure &&
                      state.items.isEmpty) {
                    return _StateMessage(
                      icon: Icons.error_outline,
                      title: tr('common.error'),
                      subtitle:
                          state.errorMessage ??
                          tr('common.something_went_wrong'),
                      actionLabel: tr('common.retry'),
                      onAction: () => context.read<CardBloc>().add(
                        const CardEvent.started(),
                      ),
                    );
                  }

                  if (state.items.isEmpty) {
                    return _StateMessage(
                      icon: Icons.credit_card_off_outlined,
                      title: tr('cards.empty'),
                      subtitle: tr('common.refresh'),
                      actionLabel: tr('common.refresh'),
                      onAction: () {
                        context.read<CardBloc>().add(
                          const CardEvent.refreshRequested(),
                        );
                      },
                    );
                  }

                  if (state.items.isNotEmpty && state.visibleItems.isEmpty) {
                    return _StateMessage(
                      icon: Icons.credit_card_off_outlined,
                      title: tr('cards.empty'),
                      subtitle: tr('cards.empty'),
                      actionLabel: tr('common.refresh'),
                      onAction: () {
                        context.read<CardBloc>().add(
                          const CardEvent.refreshRequested(),
                        );
                      },
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () {
                      final completer = Completer<void>();
                      context.read<CardBloc>().add(
                        CardEvent.refreshRequested(completer: completer),
                      );
                      return completer.future;
                    },
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        if (notification.metrics.pixels >=
                                notification.metrics.maxScrollExtent - 120 &&
                            state.hasMore &&
                            !state.isPaginating) {
                          context.read<CardBloc>().add(
                            const CardEvent.loadMoreRequested(),
                          );
                        }
                        return false;
                      },
                      child: _CardsContent(
                        state: state,
                        selectedFilterIndex: _selectedFilterIndex,
                        onFilterSelected: (index) {
                          final bankNames = _getBankNamesFromState(state);
                          _onFilterSelected(context, index, bankNames);
                        },
                        getBankNames: () => _getBankNamesFromState(state),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leadingWidth: 70,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(12.r),
          color: Theme.of(context).cardColor,
        ),
        child: BackButton(
          color:
              Theme.of(context).textTheme.titleLarge?.color ??
              AppColors.darkTextAutoCredit,
          onPressed: () => context.router.maybePop(),
        ),
      ),
      centerTitle: true,
      title: Text(
        tr('cards.title'),
        style: TextStyle(
          color:
              Theme.of(context).textTheme.titleLarge?.color ??
              AppColors.darkTextAutoCredit,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }
}

class _CardsContent extends StatelessWidget {
  const _CardsContent({
    required this.state,
    required this.selectedFilterIndex,
    required this.onFilterSelected,
    required this.getBankNames,
  });

  final CardState state;
  final int selectedFilterIndex;
  final ValueChanged<int> onFilterSelected;
  final List<String> Function() getBankNames;

  @override
  Widget build(BuildContext context) {
    // Tab bar'ni state'dan tashqarida saqlaymiz, shunda u o'zgarmaydi
    final bankNames = getBankNames();

    return Column(
      children: [
        // Tab bar - state'dan tashqarida, shuning uchun u o'zgarmaydi
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: _BankFilterListWidget(
            bankNames: bankNames,
            selectedIndex: selectedFilterIndex,
            onSelected: onFilterSelected,
          ),
        ),
        // Faqat pastdagi ro'yxat yangilanadi
        Expanded(
          child: BlocBuilder<CardBloc, CardState>(
            buildWhen: (previous, current) {
              // Faqat visibleItems yoki status o'zgarganda rebuild qilamiz
              // Tab bar o'zgarmasligi uchun boshqa fieldlar'ni tekshirmaymiz
              // Filter o'zgarganda ham rebuild qilish kerak
              return previous.visibleItems.length !=
                      current.visibleItems.length ||
                  previous.status != current.status ||
                  previous.filter != current.filter ||
                  (previous.isInitialLoading != current.isInitialLoading &&
                      current.visibleItems.isEmpty);
            },
            builder: (context, currentState) {
              // Faqat initial loading va kartalar bo'sh bo'lsa, loading ko'rsatamiz
              if (currentState.isInitialLoading &&
                  currentState.visibleItems.isEmpty) {
                return LoadingStateWidget(message: 'common.loading'.tr());
              }

              return AnimatedSwitcher(
                duration: const Duration(
                  milliseconds: 200,
                ), // Tezroq animatsiya
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(0.05, 0.0), // Qisqaro slide
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOut, // Tezroq animatsiya
                          ),
                        ),
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: _CardsList(
                  key: ValueKey<String>(
                    '${selectedFilterIndex}_${currentState.visibleItems.length}',
                  ),
                  state: currentState,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CardsList extends StatelessWidget {
  const _CardsList({super.key, required this.state});

  final CardState state;

  @override
  Widget build(BuildContext context) {
    // Loading holatida ham kartalarni ko'rsatamiz
    final isLoading =
        state.status == CardViewStatus.loading &&
        !state.isInitialLoading &&
        state.visibleItems.isEmpty;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (state.paginationErrorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _PaginationErrorBanner(
              message: state.paginationErrorMessage ?? '',
              onRetry: () => context.read<CardBloc>().add(
                const CardEvent.loadMoreRequested(),
              ),
            ),
          ),
        if (isLoading)
          // Loading holatida ham eski kartalarni ko'rsatamiz
          const SizedBox.shrink()
        else
          ...state.visibleItems.map(
            (offer) => Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _BankCardCard(offer: offer),
            ),
          ),
        if (state.hasMore) const _BottomLoader(),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _BankFilterListWidget extends StatelessWidget {
  const _BankFilterListWidget({
    required this.bankNames,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> bankNames;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    // "Barcha" tab'ini birinchi o'ringa qo'shamiz
    final allTabs = [tr('cards.all'), ...bankNames];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: allTabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final isSelected = selectedIndex == index;
          final tabName = allTabs[index];
          return GestureDetector(
            onTap: () => onSelected(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryBlue
                    : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryBlue
                      : Theme.of(context).dividerColor,
                ),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: AppColors.primaryBlue.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Text(
                tabName,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : (Theme.of(context).textTheme.titleLarge?.color ??
                            AppColors.darkTextAutoCredit),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BankCardCard extends StatefulWidget {
  const _BankCardCard({required this.offer});

  final CardOffer offer;

  @override
  State<_BankCardCard> createState() => _BankCardCardState();
}

class _BankCardCardState extends State<_BankCardCard> {
  CardOffer get offer => widget.offer;

  @override
  Widget build(BuildContext context) {
    final stats = _buildStats(context);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.15),
          width: 1,
        ),
        boxShadow: Theme.of(context).brightness == Brightness.dark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                  spreadRadius: 0,
                ),
              ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          Padding(
            padding: const EdgeInsets.all(16), // Qisqaro qilindi
            child: Column(
              children: [
                _buildCardInfoSection(context),
                const SizedBox(height: 16), // Qisqaro qilindi
                GridView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2.3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: stats.length,
                  itemBuilder: (context, index) =>
                      _StatItem(model: stats[index]),
                ),
                const SizedBox(height: 16), // Qisqaro qilindi
                _buildApplyButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final logoAsset = bankLogoAsset(offer.bankName);
    final useContainFit =
        logoAsset != null && bankLogoUsesContainFit(offer.bankName);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2BB7FF), Color(0xFF009BF2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (logoAsset != null) ...[
                    Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.r),
                        child: Padding(
                          padding: useContainFit
                              ? EdgeInsets.all(6.w)
                              : EdgeInsets.zero,
                          child: Image.asset(
                            logoAsset,
                            fit: useContainFit ? BoxFit.contain : BoxFit.cover,
                            filterQuality: FilterQuality.medium,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                  ],
                  Text(
                    offer.bankName,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.95),
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  (offer.cardNetwork ?? offer.cardType ?? 'CARD').toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10.sp,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            offer.cardName,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  // Debit badge olib tashlandi

  Widget _buildCardInfoSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: Theme.of(context).brightness == Brightness.dark
              ? [
                  Theme.of(context).scaffoldBackgroundColor,
                  Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
                ]
              : [Colors.white, const Color(0xFFF8F9FA)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBankInfoRow(
            context,
            context.tr('cards.bank_name'),
            offer.bankName,
          ),
          const SizedBox(height: 12), // Qisqaro qilindi
          _buildInfoRow(
            context,
            tr('cards.card_name'),
            offer.cardName,
            Icons.credit_card,
          ),
          const SizedBox(height: 12), // Qisqaro qilindi
          if (offer.cardNetwork != null && offer.cardNetwork!.isNotEmpty) ...[
            _buildInfoRow(
              context,
              tr('cards.payment_system'),
              offer.cardNetwork!.toUpperCase(),
              Icons.payment,
            ),
            const SizedBox(height: 12), // Qisqaro qilindi
          ],
          if (offer.opening != null && offer.opening!.isNotEmpty)
            _buildInfoRow(
              context,
              tr('cards.opening_type'),
              offer.opening!,
              Icons.lock_open,
            ),
          // Agar opening_type "online" yoki "onlayn" bo'lsa, "Onlayn" ni alohida ko'rsatish
          if (offer.opening != null &&
              offer.opening!.isNotEmpty &&
              (offer.opening!.toLowerCase().contains('online') ||
                  offer.opening!.toLowerCase().contains('onlayn'))) ...[
            const SizedBox(height: 12), // Qisqaro qilindi
            _buildInfoRow(context, '', 'Onlayn', Icons.language),
          ],
        ],
      ),
    );
  }

  Widget _buildBankInfoRow(
    BuildContext context,
    String label,
    String bankName,
  ) {
    final logoAsset = bankLogoAsset(bankName);
    final useContainFit = logoAsset != null && bankLogoUsesContainFit(bankName);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44.w,
          height: 44.w,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: logoAsset != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: useContainFit
                        ? EdgeInsets.all(6.w)
                        : EdgeInsets.zero,
                    child: Image.asset(
                      logoAsset,
                      fit: useContainFit ? BoxFit.contain : BoxFit.cover,
                      filterQuality: FilterQuality.medium,
                    ),
                  ),
                )
              : Icon(
                  Icons.account_balance,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color:
                      Theme.of(context).textTheme.bodySmall?.color ??
                      AppColors.grayText,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                bankName,
                style: TextStyle(
                  fontSize: 16.sp,
                  color:
                      Theme.of(context).textTheme.titleLarge?.color ??
                      AppColors.darkTextAutoCredit,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: AppColors.primaryBlue),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: label.isEmpty
              ? Text(
                  value,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color:
                        Theme.of(context).textTheme.titleLarge?.color ??
                        AppColors.darkTextAutoCredit,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color:
                            Theme.of(context).textTheme.bodySmall?.color ??
                            AppColors.grayText,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color:
                            Theme.of(context).textTheme.titleLarge?.color ??
                            AppColors.darkTextAutoCredit,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildApplyButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () async {
            final opened = await openBankApplication(offer.bankName);
            if (!opened && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(tr('common.error')),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: Text(
            tr('cards.order'),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  List<_CardStatModel> _buildStats(BuildContext context) {
    final stats = <_CardStatModel>[];
    void add(String labelKey, String? value, Color color, IconData icon) {
      final display = value?.trim();
      if (display == null || display.isEmpty) return;
      stats.add(
        _CardStatModel(
          label: tr(labelKey),
          value: display,
          valueColor: color,
          icon: icon,
        ),
      );
    }

    add('cards.cashback', offer.cashback, Colors.green, Icons.percent);
    add(
      'cards.service_fee',
      offer.serviceFee,
      Colors.black,
      Icons.calendar_today,
    );
    add(
      'cards.limit',
      offer.limitAmount,
      AppColors.primaryBlue,
      Icons.show_chart,
    );
    add('cards.grace_period', offer.gracePeriod, Colors.purple, Icons.flash_on);
    add(
      'cards.delivery',
      offer.delivery ?? offer.opening,
      Colors.green,
      Icons.delivery_dining_outlined,
    );

    if (stats.isEmpty && (offer.description ?? '').isNotEmpty) {
      stats.add(
        _CardStatModel(
          label: tr('cards.details'),
          value: offer.description!,
          valueColor: AppColors.primaryBlue,
          icon: Icons.info_outline,
        ),
      );
    }
    return stats;
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.model});

  final _CardStatModel model;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFFF8F9FA), const Color(0xFFF0F2F5)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: model.valueColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(model.icon, size: 16, color: model.valueColor),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  model.label,
                  style: TextStyle(
                    color:
                        Theme.of(context).textTheme.bodySmall?.color ??
                        AppColors.grayText,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            model.value,
            style: TextStyle(
              color: model.valueColor,
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
              letterSpacing: 0.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _CardStatModel {
  const _CardStatModel({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.icon,
  });

  final String label;
  final String value;
  final Color valueColor;
  final IconData icon;
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48.sp, color: theme.iconTheme.color),
            SizedBox(height: 16.h),
            Text(
              title,
              style: AppTypography.headingL.copyWith(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              subtitle,
              style: AppTypography.bodySecondary.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: 16.h),
              OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

class _BottomLoader extends StatelessWidget {
  const _BottomLoader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(child: CircularProgressIndicator()),
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
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.dangerRed.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.dangerRed.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.dangerRed),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySecondary.copyWith(
                color: AppColors.dangerRed,
              ),
            ),
          ),
          TextButton(onPressed: onRetry, child: Text(tr('common.retry'))),
        ],
      ),
    );
  }
}

enum _CardSortType { cashback, serviceFee, rating }

extension _CardSortTypeX on _CardSortType {
  String get label {
    switch (this) {
      case _CardSortType.cashback:
        return tr('cards.cashback_label');
      case _CardSortType.serviceFee:
        return tr('cards.service_fee_label');
      case _CardSortType.rating:
        return tr('cards.rating_label');
    }
  }

  String get icon {
    switch (this) {
      case _CardSortType.cashback:
        return '%';
      case _CardSortType.serviceFee:
        return '\$';
      case _CardSortType.rating:
        return '⭐';
    }
  }

  String get apiField {
    switch (this) {
      case _CardSortType.cashback:
        return 'cashback';
      case _CardSortType.serviceFee:
        return 'service_fee';
      case _CardSortType.rating:
        return 'rating';
    }
  }
}

class _CardFilterSheet extends StatefulWidget {
  const _CardFilterSheet({required this.initialFilter});

  final CardFilter initialFilter;

  @override
  State<_CardFilterSheet> createState() => _CardFilterSheetState();
}

class _CardFilterSheetState extends State<_CardFilterSheet> {
  late _CardSortType? _selectedSort;

  final Color _primaryBlue = const Color(0xFF008CF0);

  @override
  void initState() {
    super.initState();
    _selectedSort = _fromSortValue(widget.initialFilter.sort);
  }

  _CardSortType? _fromSortValue(String? value) {
    switch (value) {
      case 'cashback':
        return _CardSortType.cashback;
      case 'service_fee':
        return _CardSortType.serviceFee;
      case 'rating':
        return _CardSortType.rating;
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
              tr('cards.filters'),
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color:
                    Theme.of(context).textTheme.titleLarge?.color ??
                    Colors.black87,
              ),
            ),
            SizedBox(height: 24.h),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                children: [
                  ..._CardSortType.values.map(
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
                        side: BorderSide(color: Theme.of(context).dividerColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      child: Text(
                        tr('common.reset'),
                        style: TextStyle(
                          color:
                              Theme.of(context).textTheme.titleLarge?.color ??
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
    required _CardSortType type,
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
            color: isSelected ? _primaryBlue : Theme.of(context).dividerColor,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              type.icon,
              style: TextStyle(
                fontSize: 16.sp,
                color: isSelected
                    ? Colors.white
                    : (Theme.of(context).textTheme.titleLarge?.color ??
                          Colors.black87),
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              type.label,
              style: TextStyle(
                fontSize: 16.sp,
                color: isSelected
                    ? Colors.white
                    : (Theme.of(context).textTheme.titleLarge?.color ??
                          Colors.black87),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
