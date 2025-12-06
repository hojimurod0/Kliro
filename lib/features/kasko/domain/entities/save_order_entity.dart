class SaveOrderEntity {
  final String orderId;
  final double premium;
  final int carId;
  final String ownerName;
  final String ownerPhone;
  final String? status;

  SaveOrderEntity({
    required this.orderId,
    required this.premium,
    required this.carId,
    required this.ownerName,
    required this.ownerPhone,
    this.status,
  });
}

