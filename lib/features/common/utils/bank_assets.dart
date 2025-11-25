const Map<String, String> _bankLogos = {
  'agro': 'assets/images/agroBank.webp',
  'aloqa': 'assets/images/aloqaBank.webp',
  'anor': 'assets/images/anorBank.webp',
  'apex': 'assets/images/apexBank.webp',
  'asaka': 'assets/images/asakaBank.webp',
  'asia alliance': 'assets/images/asiaAllianceBank.webp',
  'avo': 'assets/images/avoBank.webp',
  'brb': 'assets/images/BRBbank.webp',
  'davr': 'assets/images/davrBank.webp',
  'garant': 'assets/images/garantBank.webp',
  'hamkor': 'assets/images/hamkorBank.webp',
  'hayot': 'assets/images/hayotBank.webp',
  'humo': 'assets/images/humoCard.webp',
  'infin': 'assets/images/infinBank.webp',
  'ipak': 'assets/images/ipakYuliBanki.webp',
  'ipoteka': 'assets/images/ipotekaBank.webp',
  'kapital': 'assets/images/kapitalBank.webp',
  'kdb': 'assets/images/kdbBank.webp',
  'milliy': 'assets/images/uzbekistonMilliyBanki.webp',
  'orient': 'assets/images/orientFinansBank.webp',
  'poytaxt': 'assets/images/poytaxtBank.webp',
  'smart': 'assets/images/smartBank.webp',
  'tbc': 'assets/images/TBCbank.webp',
  'turon': 'assets/images/turonBank.webp',
  'universal': 'assets/images/universalBank.webp',
  'uzcard': 'assets/images/uzCard.webp',
  'uzum': 'assets/images/uzumBank.webp',
  'xalq': 'assets/images/xalqBanki.webp',
};

const Set<String> _containBanks = {
  'kapital',
  'kdb',
  'xalq',
  'apex',
  'hamkor',
  'hayot',
  'orient',
  'turon',
};

String? bankLogoAsset(String bankName) {
  final lower = bankName.toLowerCase();
  for (final entry in _bankLogos.entries) {
    if (lower.contains(entry.key)) return entry.value;
  }
  return null;
}

bool bankLogoUsesContainFit(String bankName) {
  final lower = bankName.toLowerCase();
  return _containBanks.any(lower.contains);
}

