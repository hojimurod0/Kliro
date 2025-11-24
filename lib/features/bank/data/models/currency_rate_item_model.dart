import 'package:json_annotation/json_annotation.dart';

part 'currency_rate_item_model.g.dart';

/// Model for individual currency rate item from API
@JsonSerializable(fieldRename: FieldRename.snake)
class CurrencyRateItemModel {
  const CurrencyRateItemModel({
    required this.bank,
    required this.id,
    required this.rate,
    required this.updatedAt,
  });

  final String bank;
  @JsonKey(fromJson: _idFromJson)
  final int id;
  final String rate; // Format: "13 650 so'm" or "11 920 so'm"
  @JsonKey(name: 'updated_at')
  final String updatedAt;
  
  static int _idFromJson(dynamic value) {
    if (value is num) {
      return value.toInt();
    } else if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  factory CurrencyRateItemModel.fromJson(Map<String, dynamic> json) =>
      _$CurrencyRateItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$CurrencyRateItemModelToJson(this);

  /// Parse rate string to double (removes "so'm" and spaces)
  double get rateAsDouble {
    try {
      // Remove "so'm", spaces, and any other non-numeric characters except digits and dots
      var cleaned = rate
          .replaceAll('so\'m', '')
          .replaceAll('so\'m', '')
          .replaceAll(' ', '')
          .replaceAll(RegExp(r'[^\d.]'), '')
          .trim();
      
      // Handle cases like "13 650" -> "13650"
      cleaned = cleaned.replaceAll(' ', '');
      
      final parsed = double.tryParse(cleaned);
      if (parsed == null || parsed == 0.0) {
        // Try to extract number from string like "13 650 so'm"
        final match = RegExp(r'(\d+(?:\s*\d+)*)').firstMatch(rate);
        if (match != null) {
          final numberStr = match.group(1)?.replaceAll(' ', '') ?? '';
          return double.tryParse(numberStr) ?? 0.0;
        }
      }
      return parsed ?? 0.0;
    } catch (e) {
      return 0.0;
    }
  }
}

