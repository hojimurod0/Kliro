import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/loading_state_widget.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../bloc/accident_bloc.dart';
import '../bloc/accident_event.dart';
import '../bloc/accident_state.dart';
import '../../domain/entities/tariff_entity.dart';

class TariffSelectionPage extends StatefulWidget {
  final Function(TariffEntity) onTariffSelected;

  const TariffSelectionPage({super.key, required this.onTariffSelected});

  @override
  State<TariffSelectionPage> createState() => _TariffSelectionPageState();
}

class _TariffSelectionPageState extends State<TariffSelectionPage> {
  @override
  void initState() {
    super.initState();
    // Tariffs ni yuklash
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && context.mounted) {
        try {
          context.read<AccidentBloc>().add(const FetchTariffs());
        } catch (e) {
          // Bloc topilmagan bo'lsa, e'tiborsiz qoldiramiz
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Locale o'zgarishini kuzatish uchun context.locale ni ishlatamiz
    // Bu locale o'zgarganda widget'ni qayta build qiladi
    final currentLocale = context.locale;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      key: ValueKey('tariff_selection_${currentLocale.toString()}'),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('insurance.accident.tariff_selection.title'.tr()),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0,
      ),
      body: BlocBuilder<AccidentBloc, AccidentState>(
        buildWhen: (previous, current) {
          // Faqat tariffs bilan bog'liq state larni qabul qil
          return current is AccidentTariffsLoading ||
              current is AccidentTariffsLoaded ||
              (current is AccidentError && previous is AccidentTariffsLoading);
        },
        builder: (context, state) {
          if (state is AccidentTariffsLoading) {
            return LoadingStateWidget(
              message: 'insurance.accident.tariff_selection.loading'.tr(),
            );
          }

          if (state is AccidentError) {
            return ErrorStateWidget(
              message: state.message,
              onRetry: () {
                context.read<AccidentBloc>().add(const FetchTariffs());
              },
            );
          }

          if (state is AccidentTariffsLoaded) {
            if (state.tariffs.isEmpty) {
              return Center(
                child: Text(
                  'insurance.accident.tariff_selection.not_found'.tr(),
                  style: TextStyle(fontSize: 16.sp, color: AppColors.grayText),
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: state.tariffs.length,
              itemBuilder: (context, index) {
                final tariff = state.tariffs[index];
                return _TariffCard(
                  tariff: tariff,
                  onTap: () {
                    widget.onTariffSelected(tariff);
                    Navigator.of(context).pop(tariff); // Tarifni qaytaradi
                  },
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _TariffCard extends StatelessWidget {
  final TariffEntity tariff;
  final VoidCallback onTap;

  const _TariffCard({required this.tariff, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = AppColors.getCardBg(isDark);
    final textColor = AppColors.getTextColor(isDark);
    final subtitleColor = AppColors.getSubtitleColor(isDark);

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      color: cardBg,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'insurance.accident.tariff_selection.tariff'.tr(
                  namedArgs: {'id': tariff.id.toString()},
                ),
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'insurance.accident.tariff_selection.insurance_premium'
                            .tr(),
                        style: TextStyle(fontSize: 12.sp, color: subtitleColor),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${tariff.insurancePremium.toStringAsFixed(2)} ${'insurance.kasko.tariff.som'.tr()}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'insurance.accident.tariff_selection.otv'.tr(),
                        style: TextStyle(fontSize: 12.sp, color: subtitleColor),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${tariff.insuranceOtv.toStringAsFixed(2)} ${'insurance.kasko.tariff.som'.tr()}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
