// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CreateRequestImpl _$$CreateRequestImplFromJson(Map<String, dynamic> json) =>
    _$CreateRequestImpl(
      provider: json['provider'] as String,
      sessionId: json['session_id'] as String,
      drivers: (json['drivers'] as List<dynamic>)
          .map((e) => DriverModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      applicantIsDriver: json['applicant_is_driver'] as bool? ?? false,
      phoneNumber: json['phone_number'] as String,
      ownerInn: json['owner__inn'] as String?,
      applicantLicenseSeria: json['applicant__license_seria'] as String?,
      applicantLicenseNumber: json['applicant__license_number'] as String?,
      numberDriversId: json['number_drivers_id'] as String,
      startDate: parseOsagoDate(json['start_date'] as String),
    );

Map<String, dynamic> _$$CreateRequestImplToJson(_$CreateRequestImpl instance) =>
    <String, dynamic>{
      'provider': instance.provider,
      'session_id': instance.sessionId,
      'drivers': instance.drivers,
      'applicant_is_driver': instance.applicantIsDriver,
      'phone_number': instance.phoneNumber,
      'owner__inn': instance.ownerInn,
      'applicant__license_seria': instance.applicantLicenseSeria,
      'applicant__license_number': instance.applicantLicenseNumber,
      'number_drivers_id': instance.numberDriversId,
      'start_date': formatOsagoDate(instance.startDate),
    };
