import 'package:equatable/equatable.dart';

class PriceCheckModel extends Equatable {
  final bool? isPriceChanged;

  const PriceCheckModel({
    this.isPriceChanged,
  });

  factory PriceCheckModel.fromJson(Map<String, dynamic> json) {
    return PriceCheckModel(
      isPriceChanged: json['is_price_changed'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
        'is_price_changed': isPriceChanged,
      };

  PriceCheckModel copyWith({
    bool? isPriceChanged,
  }) {
    return PriceCheckModel(
      isPriceChanged: isPriceChanged ?? this.isPriceChanged,
    );
  }

  @override
  List<Object?> get props => [isPriceChanged];
}




