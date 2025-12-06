import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class SelectInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final VoidCallback? onTap;
  final bool enabled;

  const SelectInput({
    super.key,
    required this.controller,
    required this.hint,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      enabled: enabled,
      onTap: enabled ? onTap : null,
      validator: (v) => v!.isEmpty
          ? 'insurance.osago.vehicle.errors.not_selected'.tr()
          : null,
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: Icon(
          Icons.keyboard_arrow_down,
          color: Theme.of(context).textTheme.bodySmall?.color,
        ),
      ),
    );
  }
}

