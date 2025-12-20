import 'package:equatable/equatable.dart';

class Invoice extends Equatable {
  final String uuid;
  final String checkoutUrl;

  const Invoice({
    required this.uuid,
    required this.checkoutUrl,
  });

  @override
  List<Object?> get props => [uuid, checkoutUrl];
}
