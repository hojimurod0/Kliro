import 'package:intl/intl.dart';

final DateFormat _osagoDateFormat = DateFormat('dd.MM.yyyy');

DateTime parseOsagoDate(String value) => _osagoDateFormat.parse(value);

DateTime? parseNullableOsagoDate(String? value) =>
    value == null ? null : _osagoDateFormat.parse(value);

String formatOsagoDate(DateTime date) => _osagoDateFormat.format(date);

String? formatNullableOsagoDate(DateTime? date) =>
    date == null ? null : _osagoDateFormat.format(date);
