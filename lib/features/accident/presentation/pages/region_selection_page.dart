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
import '../../domain/entities/region_entity.dart';

class RegionSelectionPage extends StatefulWidget {
  final Function(RegionEntity) onRegionSelected;

  const RegionSelectionPage({super.key, required this.onRegionSelected});

  @override
  State<RegionSelectionPage> createState() => _RegionSelectionPageState();
}

class _RegionSelectionPageState extends State<RegionSelectionPage> {
  @override
  void initState() {
    super.initState();
    // Bloc ochiqligini tekshirib, event qo'shamiz
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && context.mounted) {
        try {
          context.read<AccidentBloc>().add(const FetchRegions());
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
      key: ValueKey('region_selection_${currentLocale.toString()}'),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('insurance.accident.region_selection.title'.tr()),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0,
      ),
      body: BlocBuilder<AccidentBloc, AccidentState>(
        buildWhen: (previous, current) {
          // Faqat regions bilan bog'liq state larni qabul qil
          return current is AccidentRegionsLoading ||
              current is AccidentRegionsLoaded ||
              (current is AccidentError && previous is AccidentRegionsLoading);
        },
        builder: (context, state) {
          if (state is AccidentRegionsLoading) {
            return LoadingStateWidget(
              message: 'insurance.accident.region_selection.loading'.tr(),
            );
          }

          if (state is AccidentError) {
            return ErrorStateWidget(
              message: state.message,
              onRetry: () {
                try {
                  context.read<AccidentBloc>().add(const FetchRegions());
                } catch (e) {
                  debugPrint(
                    '⚠️ AccidentBloc retry event qo\'shishda xatolik: $e',
                  );
                }
              },
            );
          }

          if (state is AccidentRegionsLoaded) {
            if (state.regions.isEmpty) {
              return Center(
                child: Text(
                  'insurance.accident.region_selection.not_found'.tr(),
                  style: TextStyle(fontSize: 16.sp, color: AppColors.grayText),
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: state.regions.length,
              itemBuilder: (context, index) {
                final region = state.regions[index];
                return _RegionCard(
                  region: region,
                  onTap: () {
                    widget.onRegionSelected(region);
                    Navigator.of(context).pop(region); // Regionni qaytaradi
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

class _RegionCard extends StatelessWidget {
  final RegionEntity region;
  final VoidCallback onTap;

  const _RegionCard({required this.region, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = AppColors.getCardBg(isDark);
    final textColor = AppColors.getTextColor(isDark);

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      color: cardBg,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: ListTile(
        title: Text(
          region.name,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: AppColors.primaryBlue),
        onTap: onTap,
      ),
    );
  }
}
