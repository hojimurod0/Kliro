class OsagoOrder {
  const OsagoOrder({
    required this.vehicleNumber,
    required this.carMake,
    required this.carModel,
    required this.passportSeries,
    required this.passportNumber,
    required this.texPassportSeries,
    required this.texPassportNumber,
    required this.dateOfBirth,
    required this.isOwner,
    required this.companyId,
    required this.durationId,
    required this.typeId,
    required this.startDate,
    required this.phone,
    this.totalAmount,
    this.orderId,
  });

  final String vehicleNumber;
  final String carMake;
  final String carModel;
  final String passportSeries;
  final String passportNumber;
  final String texPassportSeries;
  final String texPassportNumber;
  final String dateOfBirth;
  final bool isOwner;
  final String companyId;
  final String durationId;
  final String typeId;
  final String startDate;
  final String phone;
  final String? totalAmount;
  final String? orderId;
}

