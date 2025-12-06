import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class PeriodSelectionSheet extends StatelessWidget {
  final Function(String) onSelected;

  const PeriodSelectionSheet({
    super.key,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'insurance.osago.vehicle.select_period'.tr(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                  title: Text(
                    'insurance.osago.vehicle.period_6_months'.tr(),
                  ),
                  onTap: () {
                    final selectedValue =
                        'insurance.osago.vehicle.period_6_months'.tr();
                    onSelected(selectedValue);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text(
                    'insurance.osago.vehicle.period_12_months'.tr(),
                  ),
                  onTap: () {
                    final selectedValue =
                        'insurance.osago.vehicle.period_12_months'.tr();
                    onSelected(selectedValue);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

