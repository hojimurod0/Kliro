import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';
import '../logic/bloc/travel_bloc.dart';
import '../logic/bloc/travel_state.dart';
import '../logic/bloc/travel_event.dart';
import '../../domain/entities/travel_person.dart';
import '../../domain/entities/travel_insurance.dart';
import 'travel_order_information_screen.dart';

// TravelInsurance entity'da sessionId, amount, programId field'lar mavjud

class PersonalDataScreen extends StatefulWidget {
  const PersonalDataScreen({super.key});

  @override
  State<PersonalDataScreen> createState() => _PersonalDataScreenState();
}

class _PersonalDataScreenState extends State<PersonalDataScreen> {
  bool _isLoading = false;

  // Tug'ilgan sana uchun state
  DateTime? _insurerBirthDate;
  DateTime? _travelerBirthDate;

  // Telefon raqami uchun controller
  final TextEditingController _phoneController = TextEditingController();
  bool _phoneControllerInitialized = false;

  // Tug'ilgan sana uchun controllerlar
  final TextEditingController _insurerBirthDateController =
      TextEditingController();
  final TextEditingController _travelerBirthDateController =
      TextEditingController();

  // Shaxsiy ma'lumotlar uchun controllerlar
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _pinflController = TextEditingController();
  final TextEditingController _insurerPassportSeriesController =
      TextEditingController();
  final TextEditingController _insurerPassportNumberController =
      TextEditingController();
  final TextEditingController _travelerPassportSeriesController =
      TextEditingController();
  final TextEditingController _travelerPassportNumberController =
      TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _insurerBirthDateController.dispose();
    _travelerBirthDateController.dispose();
    _fullNameController.dispose();
    _pinflController.dispose();
    _insurerPassportSeriesController.dispose();
    _insurerPassportNumberController.dispose();
    _travelerPassportSeriesController.dispose();
    _travelerPassportNumberController.dispose();
    // ❌ Duplicate dispose qatorlar o'chirildi
    super.dispose();
  }

  String _formatPrice(dynamic price) {
    if (price == null) return '0';
    if (price is num) {
      return NumberFormat('#,###').format(price).replaceAll(',', ' ');
    }
    return price.toString();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TravelBloc, TravelState>(
      listener: (context, state) {
        if (state is TravelCreateSuccess) {
          // To'lov muvaffaqiyatli yaratildi
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Polis muvaffaqiyatli yaratildi!'),
              backgroundColor: Colors.green,
            ),
          );
          // Keyingi sahifaga o'tish
          Navigator.of(context).pop();
          setState(() {
            _isLoading = false;
          });
        } else if (state is TravelFailure) {
          // Xatolik yuz berdi
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Xatolik yuz berdi'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _isLoading = false;
          });
        } else if (state is TravelCalcSuccess && _isLoading) {
          // ✅ Hisob-kitob muvaffaqiyatli yakunlandi - Order Information sahifasiga o'tish
          setState(() {
            _isLoading = false;
          });
          // TravelBloc ni o'tkazish kerak
          final travelBloc = context.read<TravelBloc>();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => BlocProvider.value(
                value: travelBloc,
                child: const TravelOrderInformationScreen(),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final scaffoldBg = isDark ? const Color(0xFF121212) : Colors.white;
        final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
        final textColor = isDark
            ? Colors.white
            : _PersonalDataScreenColors.kTextMain;
        final textSubColor = isDark
            ? Colors.grey[400]!
            : _PersonalDataScreenColors.kTextSub;
        final borderColor = isDark
            ? Colors.grey[700]!
            : _PersonalDataScreenColors.kBorderColor;
        final cardBlueBg = isDark
            ? const Color(0xFF1E3A5C)
            : _PersonalDataScreenColors.kCardBlueBg;
        final iconBg = isDark ? Colors.grey[800]! : Colors.white;
        final iconBg2 = isDark ? Colors.grey[800]! : const Color(0xFFF1F5F9);

        // TravelBloc state dan ma'lumotlarni olish
        final persons = state.persons;
        final insurance = state.insurance;
        final calcResponse = state.calcResponse;

        // Birinchi person (sug'urtalovchi)
        final insurer = persons.isNotEmpty ? persons.first : null;

        // Tug'ilgan sanalarni olish (state dan yoki person dan)
        final insurerBirthDate = _insurerBirthDate ?? insurer?.birthDate;
        final travelerBirthDate =
            _travelerBirthDate ??
            (persons.length > 1 ? persons[1].birthDate : null);

        // Tug'ilgan sanalarni controller ga o'rnatish
        if (insurerBirthDate != null) {
          final formattedDate = DateFormat(
            'dd/MM/yyyy',
          ).format(insurerBirthDate);
          if (_insurerBirthDateController.text != formattedDate) {
            _insurerBirthDateController.text = formattedDate;
          }
        } else if (_insurerBirthDateController.text.isNotEmpty &&
            _insurerBirthDate == null &&
            insurer?.birthDate == null) {
          _insurerBirthDateController.clear();
        }

        if (travelerBirthDate != null) {
          final formattedDate = DateFormat(
            'dd/MM/yyyy',
          ).format(travelerBirthDate);
          if (_travelerBirthDateController.text != formattedDate) {
            _travelerBirthDateController.text = formattedDate;
          }
        } else if (_travelerBirthDateController.text.isNotEmpty &&
            _travelerBirthDate == null &&
            (persons.length <= 1 || persons[1].birthDate == null)) {
          _travelerBirthDateController.clear();
        }

        // Telefon raqamini olish va controller ga o'rnatish (faqat birinchi marta)
        final phoneNumber = insurance?.phoneNumber ?? '';
        if (!_phoneControllerInitialized && phoneNumber.isNotEmpty) {
          // Agar +998 bilan boshlanmasa, qo'shamiz
          if (phoneNumber.startsWith('+998')) {
            _phoneController.text = phoneNumber;
          } else if (phoneNumber.startsWith('998')) {
            _phoneController.text = '+$phoneNumber';
          } else {
            _phoneController.text = '+998$phoneNumber';
          }
          _phoneControllerInitialized = true;
        } else if (phoneNumber.isEmpty && _phoneController.text.isEmpty) {
          // Avtomatik +998 qo'shish
          _phoneController.text = '+998';
          _phoneControllerInitialized = true;
        }

        return Scaffold(
          backgroundColor: scaffoldBg,
          // --- APP BAR ---
          appBar: AppBar(
            backgroundColor: scaffoldBg,
            elevation: 0,
            toolbarHeight: 56,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: isDark ? Colors.white : Colors.black,
                size: 24,
              ),
              onPressed: () => Navigator.of(context).pop(),
              splashRadius: 24,
            ),
            title: Text(
              "travel.personal_data.title".tr(),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            centerTitle: true,
          ),

          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sarlavha
                      Text(
                        "travel.personal_data.personal_info".tr(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                          letterSpacing: -0.5,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "travel.personal_data.subtitle".tr(),
                        style: TextStyle(
                          fontSize: 15,
                          color: textSubColor,
                          fontWeight: FontWeight.w400,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // --- 1. SUG'URTALOVCHI KARTASI (Moviy) ---
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: cardBlueBg,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: _PersonalDataScreenColors.kPrimaryBlue
                                .withOpacity(0.08),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: iconBg,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.person_outline_rounded,
                                    color:
                                        _PersonalDataScreenColors.kPrimaryBlue,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  "travel.personal_data.insurer".tr(),
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? _PersonalDataScreenColors.kPrimaryBlue
                                        : _PersonalDataScreenColors
                                              .kPrimaryBlue,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Inputlar
                            _buildLabel("travel.personal_data.full_name".tr()),
                            _buildTextFieldWithController(
                              controller: _fullNameController,
                              initialValue: insurer != null
                                  ? "${insurer.firstName} ${insurer.lastName}"
                                        .trim()
                                  : null,
                            ),

                            const SizedBox(height: 16),
                            _buildLabel("travel.personal_data.pinfl".tr()),
                            _buildTextFieldWithController(
                              controller: _pinflController,
                              initialValue: insurer?.pinfl,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(14),
                              ],
                            ),

                            const SizedBox(height: 16),
                            _buildLabel(
                              "travel.personal_data.passport_series_number"
                                  .tr(),
                            ),
                            _buildPassportRowWithControllers(
                              seriesController:
                                  _insurerPassportSeriesController,
                              numberController:
                                  _insurerPassportNumberController,
                              series: insurer?.passportSeria ?? "",
                              number: insurer?.passportNumber ?? "",
                            ),

                            const SizedBox(height: 16),
                            _buildLabel("travel.personal_data.birth_date".tr()),
                            _buildDateInputWithController(
                              controller: _insurerBirthDateController,
                              hintText: "dd/mm/yyyy",
                              icon: Icons.calendar_today_outlined,
                              onTap: () => _selectBirthDate(true),
                            ),

                            const SizedBox(height: 16),
                            _buildLabel(
                              "travel.personal_data.phone_number".tr(),
                            ),
                            _buildPhoneInput(
                              controller: _phoneController,
                              hintText: "+998 -- --- -- --",
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // --- 2. SAYOHATCHI KARTASI (Oq) ---
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: borderColor),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(
                                isDark ? 0.3 : 0.02,
                              ),
                              blurRadius: 15,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: iconBg2,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.people_outline_rounded,
                                    color: textColor,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  "travel.personal_data.traveler".tr(),
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: textColor,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Inputlar - birinchi sayohatchi (sug'urtalovchi bilan bir xil bo'lishi mumkin)
                            _buildLabel(
                              "travel.personal_data.passport_series_number"
                                  .tr(),
                            ),
                            _buildPassportRowWithControllers(
                              seriesController:
                                  _travelerPassportSeriesController,
                              numberController:
                                  _travelerPassportNumberController,
                              series: insurer?.passportSeria ?? "",
                              number: insurer?.passportNumber ?? "",
                            ),
                            const SizedBox(height: 16),
                            _buildLabel("travel.personal_data.birth_date".tr()),
                            _buildDateInputWithController(
                              controller: _travelerBirthDateController,
                              hintText: "dd/mm/yyyy",
                              icon: Icons.calendar_today_outlined,
                              onTap: () => _selectBirthDate(false),
                            ),

                            const SizedBox(height: 20),

                            // Chet el fuqarosi (Custom Button)
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {},
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: borderColor),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.language,
                                        color: textSubColor,
                                        size: 22,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        "travel.personal_data.foreign_citizen"
                                            .tr(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                          color: textColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),

              // --- BOTTOM BAR ---
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                decoration: BoxDecoration(
                  color: scaffoldBg,
                  border: Border(top: BorderSide(color: borderColor)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: Builder(
                            builder: (context) {
                              final isLoading =
                                  state is TravelLoading || _isLoading;
                              return ElevatedButton(
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        setState(() {
                                          _isLoading = true;
                                        });

                                        final travelBloc = context
                                            .read<TravelBloc>();
                                        final currentState = travelBloc.state;

                                        // Shaxsiy ma'lumotlarni olish
                                        final fullName = _fullNameController
                                            .text
                                            .trim();
                                        // FIO format: FAMILIYA ISM OTASINING ISMI (masalan: "YUSUPOV AKMAL ABDURASULOVICH")
                                        final nameParts = fullName
                                            .split(' ')
                                            .where((part) => part.isNotEmpty)
                                            .toList();

                                        // Birinchi so'z = Familiya, Ikkinchi = Ism, Uchinchi = Otasining ismi
                                        final lastName = nameParts.isNotEmpty
                                            ? nameParts
                                                  .first // Familiya
                                            : '';
                                        final firstName = nameParts.length > 1
                                            ? nameParts[1] // Ism
                                            : '';
                                        final middleName = nameParts.length > 2
                                            ? nameParts
                                                  .sublist(2)
                                                  .join(' ') // Otasining ismi
                                            : '';

                                        final insurerPassportSeries =
                                            _insurerPassportSeriesController
                                                .text
                                                .trim();
                                        final insurerPassportNumber =
                                            _insurerPassportNumberController
                                                .text
                                                .trim();
                                        final travelerPassportSeries =
                                            _travelerPassportSeriesController
                                                .text
                                                .trim();
                                        final travelerPassportNumber =
                                            _travelerPassportNumberController
                                                .text
                                                .trim();
                                        // Telefon raqamidan +998 ni olib tashlash
                                        var phoneNumber = _phoneController.text
                                            .trim();
                                        if (phoneNumber.startsWith('+998')) {
                                          phoneNumber = phoneNumber.substring(
                                            4,
                                          ); // +998 ni olib tashlash
                                        } else if (phoneNumber.startsWith(
                                          '998',
                                        )) {
                                          phoneNumber = phoneNumber.substring(
                                            3,
                                          ); // 998 ni olib tashlash
                                        }

                                        // Telefon raqami validatsiyasi
                                        if (phoneNumber.isEmpty ||
                                            phoneNumber.length < 9) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                "travel.personal_data.enter_phone"
                                                    .tr(),
                                              ),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                          setState(() => _isLoading = false);
                                          return;
                                        }

                                        // Validatsiya
                                        if (fullName.isEmpty) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                "travel.personal_data.enter_full_name"
                                                    .tr(),
                                              ),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                          setState(() => _isLoading = false);
                                          return;
                                        }

                                        final pinfl = _pinflController.text
                                            .trim();
                                        if (pinfl.isEmpty) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                "travel.personal_data.enter_pinfl"
                                                    .tr(),
                                              ),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                          setState(() => _isLoading = false);
                                          return;
                                        }

                                        if (insurerPassportSeries.isEmpty ||
                                            insurerPassportNumber.isEmpty) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                "travel.personal_data.enter_passport"
                                                    .tr(),
                                              ),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                          setState(() => _isLoading = false);
                                          return;
                                        }

                                        if (_insurerBirthDate == null) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                "travel.personal_data.select_birth_date"
                                                    .tr(),
                                              ),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                          setState(() => _isLoading = false);
                                          return;
                                        }

                                        // TravelPerson list yaratish
                                        final updatedPersons = <TravelPerson>[];

                                        // Birinchi person (sug'urtalovchi)
                                        if (currentState.persons.isNotEmpty) {
                                          final firstPerson =
                                              currentState.persons.first;
                                          updatedPersons.add(
                                            TravelPerson(
                                              firstName: firstName,
                                              lastName: lastName,
                                              middleName: middleName.isNotEmpty
                                                  ? middleName
                                                  : null,
                                              pinfl: pinfl.isNotEmpty
                                                  ? pinfl
                                                  : null,
                                              passportSeria:
                                                  insurerPassportSeries
                                                      .toUpperCase(),
                                              passportNumber:
                                                  insurerPassportNumber,
                                              birthDate:
                                                  _insurerBirthDate ??
                                                  firstPerson.birthDate,
                                            ),
                                          );

                                          // Qolgan sayohatchilar
                                          for (
                                            int i = 1;
                                            i < currentState.persons.length;
                                            i++
                                          ) {
                                            final person =
                                                currentState.persons[i];
                                            updatedPersons.add(
                                              TravelPerson(
                                                firstName: person.firstName,
                                                lastName: person.lastName,
                                                middleName: person.middleName,
                                                passportSeria:
                                                    i == 1 &&
                                                        travelerPassportSeries
                                                            .isNotEmpty
                                                    ? travelerPassportSeries
                                                          .toUpperCase()
                                                    : person.passportSeria,
                                                passportNumber:
                                                    i == 1 &&
                                                        travelerPassportNumber
                                                            .isNotEmpty
                                                    ? travelerPassportNumber
                                                    : person.passportNumber,
                                                birthDate:
                                                    i == 1 &&
                                                        _travelerBirthDate !=
                                                            null
                                                    ? _travelerBirthDate!
                                                    : person.birthDate,
                                              ),
                                            );
                                          }
                                        }

                                        // TravelInsurance yangilash
                                        final existingInsurance =
                                            currentState.insurance;
                                        if (existingInsurance == null) {
                                          log(
                                            '[PERSONAL_DATA] ❌ Xatolik: Insurance ma\'lumotlari mavjud emas!',
                                            name: 'TRAVEL',
                                          );
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Sug\'urta ma\'lumotlari topilmadi. Iltimos, qayta urinib ko\'ring.',
                                              ),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                          setState(() => _isLoading = false);
                                          return;
                                        }

                                        final updatedInsurance = TravelInsurance(
                                          provider: existingInsurance.provider,
                                          companyName:
                                              existingInsurance.companyName,
                                          startDate:
                                              existingInsurance.startDate,
                                          endDate: existingInsurance.endDate,
                                          phoneNumber: phoneNumber,
                                          email: existingInsurance
                                              .email, // Email o'zgarmaydi
                                          // TravelInsurance entity'da sessionId, amount, programId field'lar mavjud
                                          sessionId:
                                              existingInsurance.sessionId,
                                          amount: existingInsurance.amount,
                                          programId:
                                              existingInsurance.programId,
                                          countryName:
                                              existingInsurance.countryName,
                                          purposeName:
                                              existingInsurance.purposeName,
                                        );

                                        // Ma'lumotlarni state ga saqlash
                                        travelBloc.add(
                                          LoadPersonsData(
                                            persons: updatedPersons,
                                            insurance: updatedInsurance,
                                          ),
                                        );

                                        // Sug'urtani ham yangilash
                                        travelBloc.add(
                                          LoadInsuranceData(updatedInsurance),
                                        );

                                        log(
                                          '[PERSONAL_DATA] ✅ Ma\'lumotlar saqlandi:\n'
                                          '  - Sug\'urtalovchi: $firstName $lastName\n'
                                          '  - Telefon: $phoneNumber\n'
                                          '  - Passport: ${insurerPassportSeries.toUpperCase()} $insurerPassportNumber\n'
                                          '  - Sayohatchilar soni: ${updatedPersons.length}\n'
                                          '  - Session ID: ${existingInsurance.sessionId ?? "yo'q"}\n'
                                          '  - CalcResponse: ${currentState.calcResponse != null ? "mavjud" : "yo'q"}',
                                          name: 'TRAVEL',
                                        );

                                        // "Davom etish" - Order Information sahifasiga o'tish
                                        // Avval hisob-kitob qilish kerak bo'lsa
                                        if (currentState.calcResponse == null) {
                                          log(
                                            '[PERSONAL_DATA] 🔄 "Davom etish" bosildi - CalcRequested event yuborilmoqda...',
                                            name: 'TRAVEL',
                                          );
                                          travelBloc.add(const CalcRequested());
                                          // TravelCalcSuccess state listener orqali sahifaga o'tish
                                        } else {
                                          log(
                                            '[PERSONAL_DATA] ➡️ "Davom etish" bosildi - Order Information sahifasiga o\'tish...',
                                            name: 'TRAVEL',
                                          );
                                          // Order Information sahifasiga o'tish
                                          // TravelBloc ni o'tkazish kerak
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  BlocProvider.value(
                                                    value: travelBloc,
                                                    child:
                                                        const TravelOrderInformationScreen(),
                                                  ),
                                            ),
                                          );
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isLoading
                                      ? _PersonalDataScreenColors.kPrimaryBlue
                                            .withOpacity(0.6)
                                      : _PersonalDataScreenColors.kPrimaryBlue,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    : Text(
                                        "travel.personal_data.continue".tr(),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- YORDAMCHI WIDGETLAR ---

  Widget _buildLabel(String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSubColor = isDark
        ? Colors.grey[400]!
        : _PersonalDataScreenColors.kTextSub;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        text,
        style: TextStyle(
          color: textSubColor,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTextField({String? initialValue}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? Colors.white
        : _PersonalDataScreenColors.kTextMain;

    return TextFormField(
      initialValue: initialValue,
      style: TextStyle(
        color: textColor,
        fontWeight: FontWeight.w600,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        filled: true,
      ),
    );
  }

  Widget _buildTextFieldWithController({
    required TextEditingController controller,
    String? initialValue,
    TextInputType? keyboardType,
    String? hintText,
    List<TextInputFormatter>? inputFormatters,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? Colors.white
        : _PersonalDataScreenColors.kTextMain;

    // Initial value ni controller ga o'rnatish (faqat birinchi marta)
    if (initialValue != null && controller.text.isEmpty) {
      controller.text = initialValue;
    }

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: TextStyle(
        color: textColor,
        fontWeight: FontWeight.w600,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        filled: true,
        hintText: hintText,
        hintStyle: TextStyle(
          color: isDark ? Colors.grey[400] : Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildPassportRow({required String series, required String number}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? Colors.white
        : _PersonalDataScreenColors.kTextMain;

    return Row(
      children: [
        // Seriya
        SizedBox(
          width: 70,
          child: TextFormField(
            initialValue: series,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              filled: true,
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Raqam
        Expanded(
          child: TextFormField(
            initialValue: number,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              filled: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPassportRowWithControllers({
    required TextEditingController seriesController,
    required TextEditingController numberController,
    required String series,
    required String number,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? Colors.white
        : _PersonalDataScreenColors.kTextMain;

    // Initial value larni controller ga o'rnatish (faqat birinchi marta)
    if (series.isNotEmpty && seriesController.text.isEmpty) {
      seriesController.text = series;
    }
    if (number.isNotEmpty && numberController.text.isEmpty) {
      numberController.text = number;
    }

    return Row(
      children: [
        // Seriya
        SizedBox(
          width: 70,
          child: TextFormField(
            controller: seriesController,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(r'[A-Z]'),
              ), // Faqat katta harflar
              LengthLimitingTextInputFormatter(2), // Faqat 2 ta harf
            ],
            textCapitalization:
                TextCapitalization.characters, // Avtomatik katta harf
            onChanged: (value) {
              // Katta harflarga o'tkazish va 2 ta harf bilan cheklash
              final upperValue = value.toUpperCase();
              if (upperValue != value) {
                seriesController.value = TextEditingValue(
                  text: upperValue,
                  selection: TextSelection.collapsed(offset: upperValue.length),
                );
              }
            },
            decoration: InputDecoration(
              fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              filled: true,
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Raqam
        Expanded(
          child: TextFormField(
            controller: numberController,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              filled: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIconInput({
    required String value,
    required IconData icon,
    bool isPlaceholder = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? Colors.white
        : _PersonalDataScreenColors.kTextMain;

    return TextFormField(
      initialValue: value,
      readOnly: true, // Klaviatura chiqmasligi uchun (sana kabi)
      style: TextStyle(
        color: isPlaceholder
            ? (isDark ? Colors.grey[500]! : const Color(0xFF94A3B8))
            : textColor,
        fontWeight: isPlaceholder ? FontWeight.w400 : FontWeight.w600,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(
          icon,
          color: _PersonalDataScreenColors.kPrimaryBlue,
          size: 20,
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 46),
        fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        filled: true,
      ),
    );
  }

  Widget _buildDateInput({
    required String value,
    required IconData icon,
    required bool isPlaceholder,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? Colors.white
        : _PersonalDataScreenColors.kTextMain;

    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        child: TextFormField(
          initialValue: value,
          readOnly: true,
          style: TextStyle(
            color: isPlaceholder
                ? (isDark ? Colors.grey[500]! : const Color(0xFF94A3B8))
                : textColor,
            fontWeight: isPlaceholder ? FontWeight.w400 : FontWeight.w600,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: _PersonalDataScreenColors.kPrimaryBlue,
              size: 20,
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 46),
            fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            filled: true,
          ),
        ),
      ),
    );
  }

  Widget _buildDateInputWithController({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? Colors.white
        : _PersonalDataScreenColors.kTextMain;
    final isPlaceholder = controller.text.isEmpty;

    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        child: TextFormField(
          controller: controller,
          readOnly: true,
          style: TextStyle(
            color: isPlaceholder
                ? (isDark ? Colors.grey[500]! : const Color(0xFF94A3B8))
                : textColor,
            fontWeight: isPlaceholder ? FontWeight.w400 : FontWeight.w600,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: _PersonalDataScreenColors.kPrimaryBlue,
              size: 20,
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 46),
            fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            filled: true,
            hintText: hintText,
            hintStyle: TextStyle(
              color: isDark ? Colors.grey[500]! : const Color(0xFF94A3B8),
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneInput({
    required TextEditingController controller,
    required String hintText,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? Colors.white
        : _PersonalDataScreenColors.kTextMain;

    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      style: TextStyle(
        color: textColor,
        fontWeight: FontWeight.w600,
        fontSize: 15,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          RegExp(r'[0-9+]'),
        ), // + belgisini ham ruxsat berish
        LengthLimitingTextInputFormatter(
          13,
        ), // +998 (4 ta belgi) + 9 ta raqam = 13 ta belgi
      ],
      onChanged: (value) {
        // +998 ni har doim saqlab qolish
        if (!value.startsWith('+998')) {
          if (value.isEmpty) {
            controller.text = '+998';
            controller.selection = TextSelection.collapsed(offset: 4);
          } else if (value.startsWith('998')) {
            // Agar 998 bilan boshlansa, + qo'shamiz
            controller.text = '+$value';
            controller.selection = TextSelection.collapsed(
              offset: controller.text.length,
            );
          } else {
            // Boshqa hollarda +998 ni qo'shamiz va faqat raqamlarni qoldiramiz
            final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
            controller.text = '+998$digitsOnly';
            // +998 dan keyin maksimal 9 ta raqam
            if (controller.text.length > 13) {
              controller.text = controller.text.substring(0, 13);
            }
            controller.selection = TextSelection.collapsed(
              offset: controller.text.length,
            );
          }
        } else {
          // Agar +998 bilan boshlansa, faqat +998 dan keyin 9 ta raqam bo'lishini ta'minlaymiz
          if (value.length > 13) {
            controller.text = value.substring(0, 13);
            controller.selection = TextSelection.collapsed(offset: 13);
          }
        }
      },
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.phone_outlined,
          color: _PersonalDataScreenColors.kPrimaryBlue,
          size: 20,
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 46),
        fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        filled: true,
        hintText: hintText,
        hintStyle: TextStyle(
          color: isDark ? Colors.grey[500]! : const Color(0xFF94A3B8),
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Future<void> _selectBirthDate(bool isInsurer) async {
    final now = DateTime.now();
    final firstDate = DateTime(1900, 1, 1);
    final lastDate = now;

    final picked = await showDatePicker(
      context: context,
      initialDate: isInsurer
          ? (_insurerBirthDate ?? DateTime(now.year - 30, 1, 1))
          : (_travelerBirthDate ?? DateTime(now.year - 30, 1, 1)),
      firstDate: firstDate,
      lastDate: lastDate,
      locale: const Locale('uz', 'UZ'),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _PersonalDataScreenColors.kPrimaryBlue,
              onPrimary: Colors.white,
              surface: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              onSurface: isDark
                  ? Colors.white
                  : _PersonalDataScreenColors.kTextMain,
            ),
            dialogBackgroundColor: isDark
                ? const Color(0xFF1E1E1E)
                : Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        final formattedDate = DateFormat('dd/MM/yyyy').format(picked);
        if (isInsurer) {
          _insurerBirthDate = picked;
          _insurerBirthDateController.text = formattedDate;
        } else {
          _travelerBirthDate = picked;
          _travelerBirthDateController.text = formattedDate;
        }
      });
    }
  }
}

// --- MUKAMMAL RANGLAR PALITRASI ---
class _PersonalDataScreenColors {
  static const Color kPrimaryBlue = Color(0xFF0085FF); // Asosiy ko'k
  static const Color kCardBlueBg = Color(0xFFF0F9FF); // Sug'urtalovchi foni
  static const Color kTextMain = Color(0xFF0F172A); // Asosiy matn (Slate 900)
  static const Color kTextSub = Color(0xFF64748B); // Yordamchi matn (Slate 500)
  static const Color kBorderColor = Color(0xFFE2E8F0); // Hoshiya (Slate 200)
}
