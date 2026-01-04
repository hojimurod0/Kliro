import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GuestSelectorDialog extends StatefulWidget {
  final int initialAdults;
  final int initialChildren;
  final int initialRooms;

  const GuestSelectorDialog({
    Key? key,
    this.initialAdults = 1,
    this.initialChildren = 0,
    this.initialRooms = 1,
  }) : super(key: key);

  @override
  State<GuestSelectorDialog> createState() => _GuestSelectorDialogState();
}

class _GuestSelectorDialogState extends State<GuestSelectorDialog> {
  late int _adults;
  late int _children;
  late int _rooms;

  @override
  void initState() {
    super.initState();
    _adults = widget.initialAdults;
    _children = widget.initialChildren;
    _rooms = widget.initialRooms;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      backgroundColor: theme.cardColor,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'hotel.search.guests_rooms'.tr(),
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.titleLarge?.color,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${_adults + _children} ${"hotel.search.person".tr()} • $_rooms ${"hotel.search.room".tr()}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: theme.textTheme.bodyMedium?.color
                            ?.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: theme.iconTheme.color),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            SizedBox(height: 24.h),

            SizedBox(height: 24.h),

            // Adults
            _buildGuestRow(
              context,
              title: 'hotel.search.adults'.tr(),
              subtitle: 'hotel.search.age_restrictions_adults'.tr(),
              value: _adults,
              onChanged: (val) => setState(() => _adults = val),
              min: 1,
            ),
            SizedBox(height: 24.h),

            // Children
            _buildGuestRow(
              context,
              title: 'hotel.search.children'.tr(),
              subtitle: 'hotel.search.age_restrictions_children'.tr(),
              value: _children,
              onChanged: (val) => setState(() => _children = val),
              min: 0,
            ),
            SizedBox(height: 24.h),

            // Rooms
            _buildGuestRow(
              context,
              title: 'hotel.search.rooms'.tr(),
              subtitle: '',
              value: _rooms,
              onChanged: (val) => setState(() => _rooms = val),
              min: 1,
            ),

            SizedBox(height: 32.h),

            // Buttons Row (Cancel / Apply)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      side: BorderSide(color: Colors.grey.shade600),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'hotel.common.close'.tr(), // "Bekor qilish" or "Yopish"
                      style: TextStyle(
                        color: theme.textTheme.bodyLarge?.color,
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, {
                        'adults': _adults,
                        'children': _children,
                        'rooms': _rooms,
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'hotel.common.apply'.tr(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestRow(
    BuildContext context, {
    required String title,
    required String subtitle,
    required int value,
    required Function(int) onChanged,
    required int min,
  }) {
    final theme = Theme.of(context);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.titleLarge?.color,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle.isNotEmpty) ...[
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        SizedBox(width: 16.w),
        Row(
          children: [
            // Minus Button
            _buildSquareButton(
              icon: Icons.remove,
              onPressed: value > min ? () => onChanged(value - 1) : null,
              isFilled: false,
              theme: theme,
            ),
            SizedBox(width: 16.w),
            // Value
            SizedBox(
              width: 24.w,
              child: Text(
                '$value',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
            ),
            SizedBox(width: 16.w),
            // Plus Button
            _buildSquareButton(
              icon: Icons.add,
              onPressed: () => onChanged(value + 1),
              isFilled: true,
              theme: theme,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSquareButton({
    required IconData icon,
    VoidCallback? onPressed,
    required bool isFilled,
    required ThemeData theme,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    
    // Filled (Plus) Style
    if (isFilled) {
      return SizedBox(
        width: 40.w,
        height: 40.w,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            elevation: 0,
          ),
          child: Icon(icon, color: Colors.white, size: 24.sp),
        ),
      );
    } 
    
    // Outlined/Ghost (Minus) Style
    else {
      return SizedBox(
        width: 40.w,
        height: 40.w,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.zero,
            backgroundColor: isDark ? Colors.grey[800] : Colors.grey[100],
            side: BorderSide(
              color: Colors.transparent, // No border as per screenshot usually, or very subtle
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          child: Icon(
            icon, 
            color: onPressed == null 
                ? theme.disabledColor 
                : (isDark ? Colors.white : Colors.black), 
            size: 24.sp
          ),
        ),
      );
    }
  }
}
