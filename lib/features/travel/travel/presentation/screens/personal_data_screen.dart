import 'package:flutter/material.dart';

enum PaymentOption { payme, click }

class PersonalDataScreen extends StatefulWidget {
  const PersonalDataScreen({super.key});

  @override
  State<PersonalDataScreen> createState() => _PersonalDataScreenState();
}

class _PersonalDataScreenState extends State<PersonalDataScreen> {
  PaymentOption _selectedPayment = PaymentOption.payme;
  final String _totalAmount = "750 000";

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? const Color(0xFF121212) : Colors.white;
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : _PersonalDataScreenColors.kTextMain;
    final textSubColor = isDark ? Colors.grey[400]! : _PersonalDataScreenColors.kTextSub;
    final borderColor = isDark ? Colors.grey[700]! : _PersonalDataScreenColors.kBorderColor;
    final cardBlueBg = isDark ? const Color(0xFF1E3A5C) : _PersonalDataScreenColors.kCardBlueBg;
    final iconBg = isDark ? Colors.grey[800]! : Colors.white;
    final iconBg2 = isDark ? Colors.grey[800]! : const Color(0xFFF1F5F9);

    return Scaffold(
      backgroundColor: scaffoldBg,
      // --- APP BAR ---
      appBar: AppBar(
        backgroundColor: scaffoldBg,
        elevation: 0,
        toolbarHeight: 56,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black, size: 24),
          onPressed: () => Navigator.of(context).pop(),
          splashRadius: 24,
        ),
        title: Text(
          "Sayohat sug'urtasi",
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
                    "Shaxsiy ma'lumotlar",
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
                    "Sug'urtalovchi va sayohatchi ma'lumotlari",
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
                      border: Border.all(color: _PersonalDataScreenColors.kPrimaryBlue.withOpacity(0.08)),
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
                              child: const Icon(Icons.person_outline_rounded, color: _PersonalDataScreenColors.kPrimaryBlue, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "Sug'urtalovchi",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: isDark ? _PersonalDataScreenColors.kPrimaryBlue : _PersonalDataScreenColors.kPrimaryBlue,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Inputlar
                        _buildLabel("To'liq ism sharif"),
                        _buildTextField(initialValue: "Chevrolete"),

                        const SizedBox(height: 16),
                        _buildLabel("Passport seriyasi va raqami"),
                        _buildPassportRow(series: "AA", number: "1234567"),

                        const SizedBox(height: 16),
                        _buildLabel("Tugilgan kun sanasi"),
                        _buildIconInput(value: "dd/mm/yyyy", icon: Icons.calendar_today_outlined, isPlaceholder: true),

                        const SizedBox(height: 16),
                        _buildLabel("Telefon raqami"),
                        _buildIconInput(value: "+998 -- --- -- --", icon: Icons.phone_outlined, isPlaceholder: true),
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
                          color: Colors.black.withOpacity(isDark ? 0.3 : 0.02),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        )
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
                              child: Icon(Icons.people_outline_rounded, color: textColor, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "Sayohatchi",
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

                        // Inputlar
                        _buildLabel("Passport seriyasi va raqami"),
                        _buildPassportRow(series: "AA", number: "1234567"),

                        const SizedBox(height: 16),
                        _buildLabel("Tugilgan kun sanasi"),
                        _buildIconInput(value: "dd/mm/yyyy", icon: Icons.calendar_today_outlined, isPlaceholder: true),

                        const SizedBox(height: 20),

                        // Chet el fuqarosi (Custom Button)
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {},
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: borderColor),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.language, color: textSubColor, size: 22),
                                  const SizedBox(width: 12),
                                  Text(
                                    "Chet el fuqarosi",
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

                  const SizedBox(height: 24),

                  // --- 3. TO'LOV TURI ---
                  Text(
                    "To'lov turi",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Payme kartasi
                  _buildPaymentCard(
                    context,
                    PaymentOption.payme,
                    'Payme',
                    _buildPaymeLogo(_selectedPayment == PaymentOption.payme, isDark),
                    isDark,
                    cardBg,
                    borderColor,
                    textColor,
                  ),
                  const SizedBox(height: 12),

                  // Click kartasi
                  _buildPaymentCard(
                    context,
                    PaymentOption.click,
                    'click',
                    _buildClickLogo(_selectedPayment == PaymentOption.click, isDark),
                    isDark,
                    cardBg,
                    borderColor,
                    textColor,
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
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Jami summa",
                          style: TextStyle(
                            fontSize: 14,
                            color: textSubColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              _totalAmount,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: textColor,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "so'm",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 160,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _PersonalDataScreenColors.kPrimaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        "To'lov",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
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
  }

  // --- YORDAMCHI WIDGETLAR ---

  Widget _buildLabel(String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSubColor = isDark ? Colors.grey[400]! : _PersonalDataScreenColors.kTextSub;
    
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
    final textColor = isDark ? Colors.white : _PersonalDataScreenColors.kTextMain;
    
    return TextFormField(
      initialValue: initialValue,
      style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 15),
      decoration: InputDecoration(
        fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        filled: true,
      ),
    );
  }

  Widget _buildPassportRow({required String series, required String number}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : _PersonalDataScreenColors.kTextMain;
    
    return Row(
      children: [
        // Seriya
        SizedBox(
          width: 70,
          child: TextFormField(
            initialValue: series,
            textAlign: TextAlign.center,
            style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 15),
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
            style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 15),
            decoration: InputDecoration(
              fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              filled: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIconInput({required String value, required IconData icon, bool isPlaceholder = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : _PersonalDataScreenColors.kTextMain;
    
    return TextFormField(
      initialValue: value,
      readOnly: true, // Klaviatura chiqmasligi uchun (sana kabi)
      style: TextStyle(
        color: isPlaceholder ? (isDark ? Colors.grey[500]! : const Color(0xFF94A3B8)) : textColor,
        fontWeight: isPlaceholder ? FontWeight.w400 : FontWeight.w600,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: _PersonalDataScreenColors.kPrimaryBlue, size: 20),
        prefixIconConstraints: const BoxConstraints(minWidth: 46),
        fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        filled: true,
      ),
    );
  }

  Widget _buildPaymentCard(
    BuildContext context,
    PaymentOption option,
    String title,
    Widget logo,
    bool isDark,
    Color cardBg,
    Color borderColor,
    Color textColor,
  ) {
    final isSelected = _selectedPayment == option;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedPayment = option;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? _PersonalDataScreenColors.kPrimaryBlue
                : borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Logo (circular)
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? Colors.grey[800] : Colors.white,
              ),
              child: logo,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
            // Radio button
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? _PersonalDataScreenColors.kPrimaryBlue
                      : borderColor,
                  width: 2,
                ),
                color: isSelected
                    ? _PersonalDataScreenColors.kPrimaryBlue
                    : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymeLogo(bool isSelected, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? Colors.grey[800] : Colors.white,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'pay',
              style: TextStyle(
                color: isSelected ? _PersonalDataScreenColors.kPrimaryBlue : (isDark ? Colors.white : Colors.black),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'me',
              style: TextStyle(
                color: isSelected ? _PersonalDataScreenColors.kPrimaryBlue : const Color(0xFF00D4AA),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClickLogo(bool isSelected, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? _PersonalDataScreenColors.kPrimaryBlue : const Color(0xFF0066FF),
      ),
      child: Center(
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: Center(
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? _PersonalDataScreenColors.kPrimaryBlue : const Color(0xFF0066FF),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- MUKAMMAL RANGLAR PALITRASI ---
class _PersonalDataScreenColors {
  static const Color kPrimaryBlue = Color(0xFF0085FF); // Asosiy ko'k
  static const Color kCardBlueBg = Color(0xFFF0F9FF);  // Sug'urtalovchi foni
  static const Color kTextMain = Color(0xFF0F172A);    // Asosiy matn (Slate 900)
  static const Color kTextSub = Color(0xFF64748B);     // Yordamchi matn (Slate 500)
  static const Color kBorderColor = Color(0xFFE2E8F0); // Hoshiya (Slate 200)
}

