class CalcResponse {
  const CalcResponse({
    required this.sessionId,
    this.amount = 0.0,
    this.currency = 'UZS',
    this.provider,
    this.availableProviders = const [],
  });

  final String sessionId;
  final double amount;
  final String currency;
  final String? provider;
  final List<Map<String, dynamic>> availableProviders;

  factory CalcResponse.fromJson(
    Map<String, dynamic> json, {
    String? programId,
  }) {
    // Response format: {result: {apex: {programs: [...]}}, success: true}
    final result = json['result'] as Map<String, dynamic>?;
    String? provider;
    double amount = 0.0;
    
    if (result != null) {
      // Provider nomini topish (apex, va hokazo)
      provider = result.keys.isNotEmpty ? result.keys.first : null;
      
      if (provider != null) {
        final providerData = result[provider] as Map<String, dynamic>?;
        final programs = providerData?['programs'] as List?;
        
        // ✅ Tanlangan programId ga mos program'dan amount olish
        if (programs != null && programs.isNotEmpty) {
          Map<String, dynamic>? selectedProgram;
          
          // Agar programId berilgan bo'lsa, shu programId ga mos program'ni topish
          if (programId != null && programId.isNotEmpty) {
            for (var program in programs) {
              final programMap = program as Map<String, dynamic>?;
              final programIdValue = programMap?['program_id']?.toString() ?? 
                                     programMap?['programId']?.toString();
              if (programIdValue == programId) {
                selectedProgram = programMap;
                break;
              }
            }
          }
          
          // Agar tanlangan program topilmasa, birinchi program'dan olish
          selectedProgram ??= programs[0] as Map<String, dynamic>?;
          
          // ✅ Amount ni to'g'ri olish: avval stoimost_UZS, keyin stoimost_USD, oxirida amount
          if (selectedProgram != null) {
            // stoimost_UZS ni olish (masalan: "10 000,00 UZS" -> 10000.0)
            final stoimostUzs = selectedProgram['stoimost_UZS'];
            if (stoimostUzs != null) {
              if (stoimostUzs is num) {
                amount = stoimostUzs.toDouble();
              } else if (stoimostUzs is String) {
                // String formatni number'ga o'tkazish (masalan: "10 000,00 UZS" -> 10000.0)
                final cleaned = stoimostUzs
                    .replaceAll(' ', '')
                    .replaceAll(',', '.')
                    .replaceAll(RegExp(r'[^0-9.]'), '');
                amount = double.tryParse(cleaned) ?? 0.0;
              }
            } else {
              // stoimost_USD ni tekshirish
              final stoimostUsd = selectedProgram['stoimost_USD'];
              if (stoimostUsd != null) {
                if (stoimostUsd is num) {
                  amount = stoimostUsd.toDouble();
                } else if (stoimostUsd is String) {
                  final cleaned = stoimostUsd
                      .replaceAll(' ', '')
                      .replaceAll(',', '.')
                      .replaceAll(RegExp(r'[^0-9.]'), '');
                  amount = double.tryParse(cleaned) ?? 0.0;
                }
              } else {
                // Fallback: amount maydoni
                amount = (selectedProgram['amount'] as num?)?.toDouble() ?? 0.0;
              }
            }
          }
        }
      }
    }
    
    return CalcResponse(
      sessionId: json['session_id'] as String? ?? '',
      amount: amount,
      currency: json['currency'] as String? ?? 'UZS',
      provider: provider,
      availableProviders: [],
    );
  }
}

