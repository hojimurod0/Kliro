import 'package:equatable/equatable.dart';

/// City Entity with ID
class City extends Equatable {
  const City({
    required this.id,
    required this.name,
    this.names,
  });

  final int id;
  final String name;
  final Map<String, String>? names; // Multi-language names: {"uz": "...", "ru": "...", "en": "..."}

  String getDisplayName(String locale) {
    if (names != null) {
      return names![locale] ?? names!['uz'] ?? names!['ru'] ?? names!['en'] ?? name;
    }
    return name;
  }

  @override
  List<Object?> get props => [id, name, names];
}

