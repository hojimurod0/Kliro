import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  const UserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.regionId,
    this.email,
    this.phone,
    this.regionName,
  });

  final int id;
  final String firstName;
  final String lastName;
  final int regionId;
  final String? email;
  final String? phone;
  final String? regionName;

  String get fullName => '$firstName $lastName'.trim();

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        regionId,
        email,
        phone,
        regionName,
      ];
}

