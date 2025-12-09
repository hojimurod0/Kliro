class TarifRequest {
  const TarifRequest({required this.country});

  final String country;

  Map<String, dynamic> toJson() => {
        'country': country,
      };
}

