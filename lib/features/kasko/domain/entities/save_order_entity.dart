class SaveOrderEntity {
  final String orderId;
  final String? contractId; // Contract ID для payment link
  final double premium;
  final int carId;
  final String ownerName;
  final String ownerPhone;
  final String? status;
  final String? clickUrl; // Click payment URL
  final String? paymeUrl; // Payme payment URL
  final String? urlShartnoma; // Contract document URL

  SaveOrderEntity({
    required this.orderId,
    this.contractId,
    required this.premium,
    required this.carId,
    required this.ownerName,
    required this.ownerPhone,
    this.status,
    this.clickUrl,
    this.paymeUrl,
    this.urlShartnoma,
  });
}

