import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';

class PassengerSelectorDialog extends StatefulWidget {
  final int initialAdults;
  final int initialChildren;
  final int initialInfants;
  final int initialInfantsWithSeat;

  const PassengerSelectorDialog({
    super.key,
    this.initialAdults = 1,
    this.initialChildren = 0,
    this.initialInfants = 0,
    this.initialInfantsWithSeat = 0,
  });

  @override
  State<PassengerSelectorDialog> createState() => _PassengerSelectorDialogState();
}

class _PassengerSelectorDialogState extends State<PassengerSelectorDialog> {
  late int _adults;
  late int _children;
  late int _infants;
  late int _infantsWithSeat;
  String? _selectedPassengerType;

  @override
  void initState() {
    super.initState();
    _adults = widget.initialAdults;
    _children = widget.initialChildren;
    _infants = widget.initialInfants;
    _infantsWithSeat = widget.initialInfantsWithSeat;
    _selectedPassengerType = 'adult'; // Default selected
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
              'Yo\'lovchilar',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: theme.textTheme.titleLarge?.color,
              ),
            ),
            SizedBox(height: 24.h),
            // Header row
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Yo\'lovchi turi',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Text(
                    'Miqdor',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            // Passenger types list
            _buildPassengerTypeRow(
              context,
              'adult',
              'Kattalar (ADT)',
              '12+ yosh',
              _adults,
              (value) => setState(() {
                _adults = value;
                _selectedPassengerType = 'adult';
              }),
            ),
            SizedBox(height: 12.h),
            _buildPassengerTypeRow(
              context,
              'child',
              'Bolalar (CHD)',
              '2-11 yosh',
              _children,
              (value) => setState(() {
                _children = value;
                _selectedPassengerType = 'child';
              }),
            ),
            SizedBox(height: 12.h),
            _buildPassengerTypeRow(
              context,
              'infant_seat',
              'Chaqaloqlar (o\'rindiq bilan) (INS)',
              '2 yoshgacha, alohida o\'rindiq bilan',
              _infantsWithSeat,
              (value) => setState(() {
                _infantsWithSeat = value;
                _selectedPassengerType = 'infant_seat';
              }),
            ),
            SizedBox(height: 12.h),
            _buildPassengerTypeRow(
              context,
              'infant',
              'Chaqaloqlar (INF)',
              '2 yoshgacha',
              _infants,
              (value) => setState(() {
                _infants = value;
                _selectedPassengerType = 'infant';
              }),
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size(0, 48.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text('Bekor qilish'),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop({
                        'adults': _adults,
                        'children': _children,
                        'infants': _infants,
                        'infantsWithSeat': _infantsWithSeat,
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: AppColors.white,
                      minimumSize: Size(0, 48.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Qo\'llash',
                      style: TextStyle(
                        fontSize: 14.sp,
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

  Widget _buildPassengerTypeRow(
    BuildContext context,
    String type,
    String title,
    String subtitle,
    int value,
    ValueChanged<int> onChanged,
  ) {
    final theme = Theme.of(context);
    final isSelected = _selectedPassengerType == type;
    
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedPassengerType = type;
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
              decoration: BoxDecoration(
                color: isSelected 
                    ? AppColors.primaryBlue.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (isSelected)
                        Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue,
                            shape: BoxShape.circle,
                          ),
                        ),
                      if (isSelected) SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: theme.textTheme.titleLarge?.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7) ?? Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: _buildQuantitySelector(
            context,
            value,
            onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildQuantitySelector(
    BuildContext context,
    int value,
    ValueChanged<int> onChanged,
  ) {
    final theme = Theme.of(context);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: value > 0 ? () => onChanged(value - 1) : null,
          icon: Icon(Icons.remove, size: 16.sp),
          style: IconButton.styleFrom(
            backgroundColor: theme.dividerColor.withValues(alpha: 0.1),
            shape: CircleBorder(),
            padding: EdgeInsets.all(6.w),
            minimumSize: Size(36.w, 36.w),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: theme.textTheme.titleLarge?.color,
          ),
        ),
        IconButton(
          onPressed: () => onChanged(value + 1),
          icon: Icon(Icons.add, size: 16.sp),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: AppColors.white,
            shape: CircleBorder(),
            padding: EdgeInsets.all(6.w),
            minimumSize: Size(36.w, 36.w),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
    );
  }

}

