class PurposeRequest {
  const PurposeRequest({
    required this.purposeId,
    required this.destinations,
  });

  final int purposeId;
  final List<String> destinations;

  Map<String, dynamic> toJson() => {
        'purpose_id': purposeId,
        'destinations': destinations,
      };
}

