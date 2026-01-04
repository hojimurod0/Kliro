import 'package:equatable/equatable.dart';

/// Helper function to get locale variants for lookup
/// Returns list of possible locale keys to try in order
List<String> _getLocaleVariants(String locale) {
  final variants = <String>[];
  final localeLower = locale.toLowerCase();
  
  // Add exact match first (preserve original case)
  variants.add(locale);
  
  // Handle Cyrillic Uzbek - try all possible formats
  // context.locale.toString() returns 'uz_CYR' (with underscore and uppercase)
  if (localeLower == 'uz_cyr' || localeLower == 'uz-cyr') {
    // Try all possible formats for Cyrillic
    variants.add('uz_CYR');  // Most common in API
    variants.add('uz-CYR');  // Alternative format
    variants.add('uz_cyr');  // Lowercase variant
    variants.add('uz-cyr'); // Lowercase with dash
  }
  
  // Normalize locale (remove country code) - only if not Cyrillic
  if (localeLower != 'uz_cyr' && localeLower != 'uz-cyr') {
    if (locale.contains('-') || locale.contains('_')) {
      final normalized = locale.split(RegExp(r'[-_]')).first.toLowerCase();
      if (normalized != localeLower && normalized.isNotEmpty) {
        variants.add(normalized);
      }
    }
  }
  
  return variants;
}

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
      // Try all locale variants
      final variants = _getLocaleVariants(locale);
      for (final variant in variants) {
        if (names!.containsKey(variant)) {
          return names![variant]!;
        }
      }
      
      // Fallback to common locales
      return names!['uz'] ?? 
             names!['ru'] ?? 
             names!['en'] ?? 
             name;
    }
    return name;
  }

  @override
  List<Object?> get props => [id, name, names];
}

