// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DriverModelImpl _$$DriverModelImplFromJson(Map<String, dynamic> json) =>
    _$DriverModelImpl(
      passportSeria: json['passport__seria'] as String,
      passportNumber: json['passport__number'] as String,
      driverBirthday: parseOsagoDate(json['driver_birthday'] as String),
      relative: (json['relative'] as num?)?.toInt() ?? 0,
      name: json['name'] as String?,
      licenseSeria: json['license__seria'] as String?,
      licenseNumber: json['license__number'] as String?,
    );

Map<String, dynamic> _$$DriverModelImplToJson(_$DriverModelImpl instance) {
  final val = <String, dynamic>{
    'passport__seria': instance.passportSeria,
    'passport__number': instance.passportNumber,
    'driver_birthday': formatOsagoDate(instance.driverBirthday),
    'relative': instance.relative,
    'name': instance.name,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('license__seria', instance.licenseSeria);
  writeNotNull('license__number', instance.licenseNumber);
  return val;
}
