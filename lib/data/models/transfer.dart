class TransferServiceInfo {
  const TransferServiceInfo({
    required this.app,
    this.commission,
  });

  final String app;
  final double? commission;

  factory TransferServiceInfo.fromJson(Map<String, dynamic> json) =>
      TransferServiceInfo(
        app: json['app'] as String? ?? '',
        commission: (json['commission'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'app': app,
        'commission': commission,
      };
}

