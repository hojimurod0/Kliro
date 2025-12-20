import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../common/utils/bank_assets.dart';
import '../../../common/utils/bank_data.dart';
import '../../domain/entities/transfer_app.dart';

class AppCard extends StatefulWidget {
  const AppCard({super.key, required this.app});

  final TransferApp app;

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _isExpanded = false;

  List<String> _buildAdvantages() {
    if (widget.app.advantages.isNotEmpty) {
      return widget.app.advantages;
    }

    final generated = <String>[];
    final commission = widget.app.displayCommission;
    final speed = widget.app.displaySpeed;
    final rating = widget.app.displayRating;

    if (commission.isNotEmpty && commission != '—') {
      generated.add('Komissiya $commission');
    }
    if (speed.isNotEmpty && speed != '—') {
      generated.add('Tezlik $speed');
    }
    if (rating.isNotEmpty && rating != '—') {
      generated.add('Reyting $rating');
    }

    if (generated.isEmpty) {
      generated.add("Bank tomonidan tasdiqlangan o'tkazmalar");
    }

    return generated;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF111827);
    final subtitleColor = isDark
        ? (Colors.grey[400] ?? const Color(0xFF6B7280))
        : const Color(0xFF6B7280);
    final infoBg = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF9FAFB);
    final advantages = _buildAdvantages();
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(28.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF101828).withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 1. Logo & Name
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LogoBox(app: widget.app, isDark: isDark),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.app.name,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      widget.app.bank,
                      style: TextStyle(fontSize: 13.sp, color: subtitleColor),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  "Past",
                  style: TextStyle(
                    color: const Color(0xFF0085FF),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // 2. Grid Info
          Row(
            children: [
              Expanded(
                child: _buildMiniCard(
                  icon: Icons.percent_rounded,
                  label: "Komissiya",
                  value: widget.app.displayCommission,
                  isBlue: true,
                  infoBg: infoBg,
                  subtitleColor: subtitleColor,
                  textColor: textColor,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildMiniCard(
                  icon: Icons.speed_rounded,
                  label: "Tezlik",
                  value: widget.app.displaySpeed,
                  isBlue: false,
                  infoBg: infoBg,
                  subtitleColor: subtitleColor,
                  textColor: textColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // 4. Accordion styled like deposits page
          if (advantages.isNotEmpty)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor
                    .withOpacity(isDark ? 0.35 : 0.3),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: theme.dividerColor,
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
                        Expanded(
                          child: Text(
                            context.tr('transfers.advantages_count', namedArgs: {'count': advantages.length.toString()}),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14.sp,
                              color: theme.textTheme.titleLarge?.color ??
                                  textColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
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
                              color: theme.colorScheme.primary,
                              size: 16.sp,
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                advantage,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: theme.textTheme.bodyMedium?.color ??
                                      subtitleColor,
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

          SizedBox(height: 20.h),

          // 7. Button
          SizedBox(
            width: double.infinity,
            height: 56.h,
            child: ElevatedButton(
              onPressed: () async {
                await openPaymentServiceApp(widget.app.name);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0085FF),
                foregroundColor: Colors.white,
                shadowColor: const Color(0xFF0085FF).withOpacity(0.4),
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              child: Text(
                "Yuklab olish",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniCard({
    required IconData icon,
    required String label,
    required String value,
    required bool isBlue,
    required Color infoBg,
    required Color subtitleColor,
    required Color textColor,
  }) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: infoBg,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16.sp, color: const Color(0xFF9CA3AF)),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(fontSize: 12.sp, color: subtitleColor),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
              color: isBlue ? const Color(0xFF0085FF) : textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoBox extends StatelessWidget {
  const _LogoBox({required this.app, required this.isDark});

  final TransferApp app;
  final bool isDark;

  bool _isAbsoluteUrl(String value) {
    final uri = Uri.tryParse(value);
    return uri != null && uri.hasScheme;
  }

  String? _resolveLogoPath() {
    final logo = app.logo?.trim();
    if (logo != null && logo.isNotEmpty) {
      if (_isAbsoluteUrl(logo)) return logo;
      if (logo.startsWith('assets/')) return logo;
      if (logo.contains('/')) return 'assets/$logo';
      return 'assets/images/$logo';
    }
    return bankLogoAsset(app.bank) ?? bankLogoAsset(app.name);
  }

  bool _shouldUseContainFit() {
    return bankLogoUsesContainFit(app.bank) || bankLogoUsesContainFit(app.name);
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFEFF6FF);
    final iconColor = isDark ? Colors.white : const Color(0xFF0085FF);
    final resolvedLogo = _resolveLogoPath();
    final isNetworkLogo = resolvedLogo != null && _isAbsoluteUrl(resolvedLogo);
    final shouldContain = _shouldUseContainFit();

    return Container(
      width: 48.w,
      height: 48.h,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: Builder(
        builder: (context) {
          Widget wrapIfNeeded(Widget child) {
            if (shouldContain) {
              return Padding(padding: EdgeInsets.all(6.w), child: child);
            }
            return child;
          }

          if (resolvedLogo != null && isNetworkLogo) {
            final image = CachedNetworkImage(
              imageUrl: resolvedLogo,
              fit: shouldContain ? BoxFit.contain : BoxFit.cover,
              placeholder: (context, url) => Container(
                color: bgColor,
                child: Center(
                  child: SizedBox(
                    width: 16.sp,
                    height: 16.sp,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: iconColor,
                    ),
                  ),
                ),
              ),
              errorWidget: (_, __, ___) =>
                  Icon(Icons.apps, color: iconColor, size: 24.sp),
            );
            return wrapIfNeeded(image);
          }

          if (resolvedLogo != null) {
            final image = Image.asset(
              resolvedLogo,
              fit: shouldContain ? BoxFit.contain : BoxFit.cover,
              filterQuality: FilterQuality.high,
            );
            return wrapIfNeeded(image);
          }

          return Icon(Icons.apps, color: iconColor, size: 24.sp);
        },
      ),
    );
  }
}
