import '../../domain/entities/osago_order.dart';

class OsagoOrderModel extends OsagoOrder {
  const OsagoOrderModel({
    required super.vehicleNumber,
    required super.carMake,
    required super.carModel,
    required super.passportSeries,
    required super.passportNumber,
    required super.texPassportSeries,
    required super.texPassportNumber,
    required super.dateOfBirth,
    required super.isOwner,
    required super.companyId,
    required super.durationId,
    required super.typeId,
    required super.startDate,
    required super.phone,
    super.totalAmount,
    super.orderId,
  });

  factory OsagoOrderModel.fromJson(Map<String, dynamic> json) {
    return OsagoOrderModel(
      vehicleNumber: json['vehicleNumber'] as String,
      carMake: json['carMake'] as String,
      carModel: json['carModel'] as String,
      passportSeries: json['passportSeries'] as String,
      passportNumber: json['passportNumber'] as String,
      texPassportSeries: json['texPassportSeries'] as String,
      texPassportNumber: json['texPassportNumber'] as String,
      dateOfBirth: json['dateOfBirth'] as String,
      isOwner: json['isOwner'] as bool,
      companyId: json['companyId'] as String,
      durationId: json['durationId'] as String,
      typeId: json['typeId'] as String,
      startDate: json['startDate'] as String,
      phone: json['phone'] as String,
      totalAmount: json['totalAmount'] as String?,
      orderId: json['orderId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vehicleNumber': vehicleNumber,
      'carMake': carMake,
      'carModel': carModel,
      'passportSeries': passportSeries,
      'passportNumber': passportNumber,
      'texPassportSeries': texPassportSeries,
      'texPassportNumber': texPassportNumber,
      'dateOfBirth': dateOfBirth,
      'isOwner': isOwner,
      'companyId': companyId,
      'durationId': durationId,
      'typeId': typeId,
      'startDate': startDate,
      'phone': phone,
      if (totalAmount != null) 'totalAmount': totalAmount,
      if (orderId != null) 'orderId': orderId,
    };
  }
}

