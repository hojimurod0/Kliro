import 'package:flutter/material.dart';
import '../../../../../../core/utils/date_utils.dart' as DateUtils;

/// Поле для выбора даты в формате DD-MM-YYYY
class TravelDateField extends StatefulWidget {
  final String label;
  final String? initialValue;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const TravelDateField({
    super.key,
    required this.label,
    this.initialValue,
    this.validator,
    this.onChanged,
    this.firstDate,
    this.lastDate,
  });

  @override
  State<TravelDateField> createState() => _TravelDateFieldState();
}

class _TravelDateFieldState extends State<TravelDateField> {
  late TextEditingController _controller;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    if (widget.initialValue != null) {
      _selectedDate = DateUtils.DateUtils.parseDate(widget.initialValue!);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: widget.firstDate ?? DateTime(1900, 1, 1),
      lastDate: widget.lastDate ?? DateTime(2100),
      locale: const Locale('ru', 'RU'),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        final formattedDate = DateUtils.DateUtils.formatDate(picked);
        _controller.text = formattedDate;
        widget.onChanged?.call(formattedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      validator: widget.validator,
      readOnly: true,
      decoration: InputDecoration(
        labelText: widget.label,
        border: const OutlineInputBorder(),
        suffixIcon: const Icon(Icons.calendar_today),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue, width: 2),
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
      ),
      onTap: () => _selectDate(context),
    );
  }
}

