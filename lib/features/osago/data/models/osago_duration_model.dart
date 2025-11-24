import '../../domain/entities/osago_duration.dart';

class OsagoDurationModel extends OsagoDuration {
  const OsagoDurationModel({
    required super.id,
    required super.label,
    required super.months,
  });

  factory OsagoDurationModel.fromJson(Map<String, dynamic> json) {
    return OsagoDurationModel(
      id: json['id'] as String,
      label: json['label'] as String,
      months: json['months'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'months': months,
    };
  }
}

