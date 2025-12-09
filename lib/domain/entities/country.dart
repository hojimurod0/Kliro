import 'package:equatable/equatable.dart';

/// Сущность страны
class Country extends Equatable {
  final String code;
  final String name;
  final String? flag;

  const Country({
    required this.code,
    required this.name,
    this.flag,
  });

  @override
  List<Object?> get props => [code, name, flag];
}

