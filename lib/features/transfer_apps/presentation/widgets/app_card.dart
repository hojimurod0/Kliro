import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/transfer_app.dart';

class AppCard extends StatefulWidget {
  const AppCard({super.key, required this.app});

  final TransferApp app;

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF111827);
    final subtitleColor = isDark ? (Colors.grey[400] ?? const Color(0xFF6B7280)) : const Color(0xFF6B7280);
    final infoBg = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF9FAFB);

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
              Container(
                width: 56.w,
                height: 56.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF), // Light Blue
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Icon(
                  Icons.bolt_rounded,
                  color: const Color(0xFF0085FF),
                  size: 32.sp,
                ),
              ),
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
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: subtitleColor,
                      ),
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

          // 2. Rating Bar
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: infoBg,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.star_rounded,
                  color: const Color(0xFF0085FF),
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  "Reyting",
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 13.sp,
                  ),
                ),
                const Spacer(),
                Text(
                  widget.app.rating,
                  style: TextStyle(
                    color: const Color(0xFF0085FF),
                    fontWeight: FontWeight.w700,
                    fontSize: 15.sp,
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16.w),
                  width: 1.w,
                  height: 14.h,
                  color: const Color(0xFFD1D5DB),
                ),
                Icon(
                  Icons.people_alt_outlined,
                  color: const Color(0xFF9CA3AF),
                  size: 18.sp,
                ),
                SizedBox(width: 6.w),
                Text(
                  "${widget.app.users} foydalanuvchi",
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),

          // 3. Grid Info
          Row(
            children: [
              Expanded(
                child: _buildMiniCard(
                  icon: Icons.percent_rounded,
                  label: "Komissiya",
                  value: widget.app.commission,
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
                  value: widget.app.speed,
                  isBlue: false,
                  infoBg: infoBg,
                  subtitleColor: subtitleColor,
                  textColor: textColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // 4. Limit Row
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: infoBg,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  color: const Color(0xFF9CA3AF),
                  size: 20.sp,
                ),
                SizedBox(width: 10.w),
                Text(
                  "Maksimal limit",
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 13.sp,
                  ),
                ),
                const Spacer(),
                Text(
                  widget.app.limit,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.sp,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // 5. Tags
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "O'tkazma turlari",
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: subtitleColor,
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: widget.app.tags.map((tag) => _buildTag(tag)).toList(),
          ),

          SizedBox(height: 20.h),

          // 6. Accordion
          if (widget.app.advantages.isNotEmpty)
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
                    "Afzalliklar (${widget.app.advantages.length})",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                      color: textColor,
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

          if (_isExpanded && widget.app.advantages.isNotEmpty) ...[
            SizedBox(height: 12.h),
            ...widget.app.advantages.map(
              (advantage) => Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: const Color(0xFF0085FF),
                      size: 16.sp,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        advantage,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: subtitleColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          SizedBox(height: 20.h),

          // 7. Button
          SizedBox(
            width: double.infinity,
            height: 56.h,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Implement download functionality
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
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16.sp,
                ),
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
                style: TextStyle(
                  fontSize: 12.sp,
                  color: subtitleColor,
                ),
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

  Widget _buildTag(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: const Color(0xFF0085FF),
          fontSize: 12.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

