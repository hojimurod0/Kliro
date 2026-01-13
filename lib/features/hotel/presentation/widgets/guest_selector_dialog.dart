import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';

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
  late int _rooms;

  @override
  void initState() {
    super.initState();
    _adults = widget.initialAdults;
    _rooms = widget.initialRooms;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'hotel.search.guests_rooms'.tr(),
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: theme.textTheme.titleLarge?.color,
              ),
            ),
            SizedBox(height: 24.h),
            // Adults
            _buildCounter(
              context,
              'hotel.search.adults'.tr(),
              'hotel.search.age_restrictions_adults'.tr(),
              _adults,
              (value) => setState(() => _adults = value),
            ),
            SizedBox(height: 16.h),
            // Rooms
            _buildCounter(
              context,
              'hotel.search.rooms'.tr(),
              '',
              _rooms,
              (value) => setState(() => _rooms = value),
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size(0, 56.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text('hotel.common.close'.tr()),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop({
                        'adults': _adults,
                        'children': 0,
                        'rooms': _rooms,
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: AppColors.white,
                      minimumSize: Size(0, 56.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'hotel.common.apply'.tr(),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
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

  Widget _buildCounter(
    BuildContext context,
    String title,
    String subtitle,
    int value,
    ValueChanged<int> onChanged,
  ) {
    final theme = Theme.of(context);
    final min = title.contains('room') ? 1 : 1; // Rooms min is 1, adults min is 1
    
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
              ),
              if (subtitle.isNotEmpty) ...[
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7) ?? Colors.grey,
                  ),
                ),
              ],
            ],
          ),
        ),
        Row(
          children: [
            IconButton(
              onPressed: value > min ? () => onChanged(value - 1) : null,
              icon: Icon(Icons.remove),
              style: IconButton.styleFrom(
                backgroundColor: theme.dividerColor.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: theme.textTheme.titleLarge?.color,
              ),
            ),
            SizedBox(width: 16.w),
            IconButton(
              onPressed: () => onChanged(value + 1),
              icon: Icon(Icons.add),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
