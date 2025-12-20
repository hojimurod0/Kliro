class PassengerData {
  String name;
  String surname;
  String patronymic;
  String? returnDate;
  String gender; // 'Erkak' or 'Ayol'
  String passportSeries;
  String? passportExpiry;
  String? citizenship;
  String phone;
  String passengerType; // 'adult', 'child', 'baby'

  PassengerData({
    this.name = '',
    this.surname = '',
    this.patronymic = '',
    this.returnDate,
    this.gender = 'Erkak',
    this.passportSeries = '',
    this.passportExpiry,
    this.citizenship,
    this.phone = '',
    required this.passengerType,
  });

  bool get isPhoneValid {
    final digitsOnly = phone.replaceAll(RegExp(r'[^0-9]'), '');
    // Uzbekistan phone format: 998 + 9 digits (total 12 digits)
    return digitsOnly.length == 12 && digitsOnly.startsWith('998');
  }

  bool get isFilled {
    return name.isNotEmpty &&
        surname.isNotEmpty &&
        // patronymic (middle name) is optional - user can enter it or leave it empty
        (returnDate != null && returnDate!.isNotEmpty) && // Tug'ilgan sana majburiy
        passportSeries.isNotEmpty &&
        (passportExpiry != null && passportExpiry!.isNotEmpty) && // Pasport amal qilish muddati majburiy
        (citizenship != null && citizenship!.isNotEmpty) && // Fuqarolik majburiy
        phone.isNotEmpty &&
        isPhoneValid;
  }

  PassengerData copyWith({
    String? name,
    String? surname,
    String? patronymic,
    String? returnDate,
    String? gender,
    String? passportSeries,
    String? passportExpiry,
    String? citizenship,
    String? phone,
    String? passengerType,
  }) {
    return PassengerData(
      name: name ?? this.name,
      surname: surname ?? this.surname,
      patronymic: patronymic ?? this.patronymic,
      returnDate: returnDate ?? this.returnDate,
      gender: gender ?? this.gender,
      passportSeries: passportSeries ?? this.passportSeries,
      passportExpiry: passportExpiry ?? this.passportExpiry,
      citizenship: citizenship ?? this.citizenship,
      phone: phone ?? this.phone,
      passengerType: passengerType ?? this.passengerType,
    );
  }
}

