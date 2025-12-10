import 'dart:io';
import 'package:url_launcher/url_launcher_string.dart';

/// Bank data with website URLs and app store links
class BankData {
  const BankData({
    required this.name,
    required this.url,
    this.androidUrl,
    this.iosUrl,
  });

  final String name;
  final String url;
  final String? androidUrl;
  final String? iosUrl;
}

/// Payment service data with website URLs and app store links
class PaymentServiceData {
  const PaymentServiceData({
    required this.name,
    required this.url,
    this.androidUrl,
    this.iosUrl,
  });

  final String name;
  final String url;
  final String? androidUrl;
  final String? iosUrl;
}

/// Bank website URLs
const Map<String, BankData> _bankData = {
  "Ipak Yo'li Banki": BankData(
    name: "Ipak Yo'li Banki",
    url: 'https://ipakyulibank.uz',
    androidUrl: 'https://play.google.com/store/apps/details?id=com.ipakyulibank.mobile&hl=ru',
    iosUrl: 'https://apps.apple.com/uz/app/ipak-yoli-mobile/id1436677359',
  ),
  'Asaka Bank': BankData(
    name: 'Asaka Bank',
    url: 'https://asakabank.uz',
    androidUrl: 'https://play.google.com/store/apps/details?id=uz.asakabank.myasaka&hl=ru',
    iosUrl: 'https://apps.apple.com/uz/app/asakabank/id1574165416',
  ),
  "O'zbekiston Milliy Banki": BankData(
    name: "O'zbekiston Milliy Banki",
    url: 'https://nbu.uz',
  ),
  'Ipoteka Bank': BankData(
    name: 'Ipoteka Bank',
    url: 'https://ipotekabank.uz',
    androidUrl: 'https://play.google.com/store/apps/details?id=com.bss.ipotekabank.retail.lite&hl=ru',
    iosUrl: 'https://apps.apple.com/ru/app/ipoteka-retail/id1637057203',
  ),
  'Saderat Bank': BankData(
    name: 'Saderat Bank',
    url: 'https://saderatbank.uz',
  ),
  'Trast Bank': BankData(
    name: 'Trast Bank',
    url: 'https://trastbank.uz',
  ),
  'Xalq Banki': BankData(
    name: 'Xalq Banki',
    url: 'https://xb.uz',
  ),
  "O'zsanoatqurilish Bank": BankData(
    name: "O'zsanoatqurilish Bank",
    url: 'https://ofb.uz',
  ),
  'MK Bank': BankData(
    name: 'MK Bank',
    url: 'https://mkbank.uz',
  ),
  'Infin Bank': BankData(
    name: 'Infin Bank',
    url: 'https://www.infinbank.com/ru/',
    androidUrl: 'https://play.google.com/store/apps/details?id=uz.xsoft.myinfin&hl=ru',
    iosUrl: 'https://apps.apple.com/ru/app/infinbank/id1454367354',
  ),
  'BRB': BankData(
    name: 'BRB',
    url: 'https://brb.uz',
    androidUrl: 'https://play.google.com/store/apps/details?id=com.qqb.quant&hl=ru',
    iosUrl: 'https://apps.apple.com/uz/app/brb/id1524422825',
  ),
  'Orient Finans Bank': BankData(
    name: 'Orient Finans Bank',
    url: 'https://ofb.uz',
  ),
  'Davr Bank': BankData(
    name: 'Davr Bank',
    url: 'https://davrbank.uz',
    androidUrl: 'https://play.google.com/store/apps/details?id=uz.davrbank.mobile&hl=ru',
    iosUrl: 'https://apps.apple.com/uz/app/davr-mobile-2-0/id6483247810',
  ),
  'Agro Bank': BankData(
    name: 'Agro Bank',
    url: 'https://agrobank.uz',
    androidUrl: 'https://play.google.com/store/apps/details?id=uz.agrobank.mobile&hl=ru',
    iosUrl: 'https://apps.apple.com/ru/app/agrobank-mobile/id1638716474',
  ),
  'Ziraat Bank': BankData(
    name: 'Ziraat Bank',
    url: 'https://ziraatbank.uz',
  ),
  'Asia Alliance Bank': BankData(
    name: 'Asia Alliance Bank',
    url: 'https://aab.uz',
  ),
  'Tenge Bank': BankData(
    name: 'Tenge Bank',
    url: 'https://tengebank.uz',
  ),
  'Turon Bank': BankData(
    name: 'Turon Bank',
    url: 'https://turonbank.uz',
  ),
  'Universal Bank': BankData(
    name: 'Universal Bank',
    url: 'https://universalbank.uz',
    androidUrl: 'https://play.google.com/store/apps/details?id=uz.fido.universaldigital',
    iosUrl: 'https://apps.apple.com/uz/app/universalbank/id6453759395',
  ),
  'Hamkor Bank': BankData(
    name: 'Hamkor Bank',
    url: 'https://hamkorbank.uz/',
    androidUrl: 'https://play.google.com/store/apps/details?id=uz.hamkorbank.mobile&hl=ru',
    iosUrl: 'https://apps.apple.com/us/app/hamkor-%D0%BE%D0%BD%D0%BB%D0%B0%D0%B9%D0%BD-%D0%B1%D0%B0%D0%BD%D0%BA-%D1%83%D0%B7%D0%B1%D0%B5%D0%BA%D0%B8%D1%81%D1%82%D0%B0%D0%BD%D0%B0/id1602323485',
  ),
  'Anor Bank': BankData(
    name: 'Anor Bank',
    url: 'https://anorbank.uz',
    androidUrl: 'https://play.google.com/store/apps/details?id=uz.anormobile.retail&hl=uz',
    iosUrl: 'https://apps.apple.com/uz/app/anorbank/id1579623268',
  ),
  'Aloqa Bank': BankData(
    name: 'Aloqa Bank',
    url: 'https://aloqabank.uz',
    androidUrl: 'https://play.google.com/store/apps/details?id=uz.aloqabank.zoomrad&hl=ru',
    iosUrl: 'https://apps.apple.com/uz/app/zoomrad/id1522419775',
  ),
  'Poytaxt Bank': BankData(
    name: 'Poytaxt Bank',
    url: 'https://poytaxtbank.uz',
  ),
  'Garant Bank': BankData(
    name: 'Garant Bank',
    url: 'https://garantbank.uz',
    androidUrl: 'https://play.google.com/store/apps/details?id=uz.comsa.garant.mobile&hl=ru',
    iosUrl: 'https://apps.apple.com/uz/app/garant-bank-%D1%83%D0%B7%D0%B1%D0%B5%D0%BA%D0%B8%D1%81%D1%82%D0%B0%D0%BD/id6476410628',
  ),
  'Kapital Bank': BankData(
    name: 'Kapital Bank',
    url: 'https://kapitalbank.uz/uz/welcome.php',
  ),
  'TBC Bank': BankData(
    name: 'TBC Bank',
    url: 'https://tbcbank.uz',
    androidUrl: 'https://play.google.com/store/apps/details?id=ge.space.app.uzbekistan&hl=uz',
    iosUrl: 'https://apps.apple.com/ru/app/tbc-uz-%D0%BC%D0%BE%D0%B1%D0%B8%D0%BB%D1%8C%D0%BD%D1%8B%D0%B9-o%D0%BD%D0%BB%D0%B0%D0%B9%D0%BD-%D0%B1%D0%B0%D0%BD%D0%BA/id1450503714',
  ),
  'KDB Bank Uzbekiston': BankData(
    name: 'KDB Bank Uzbekiston',
    url: 'https://kdb.uz',
  ),
  'Octo Bank': BankData(
    name: 'Octo Bank',
    url: 'https://octobank.uz',
    androidUrl: 'https://play.google.com/store/apps/details?id=com.ravnaqbank.rbkmobile&hl=ru',
    iosUrl: 'https://apps.apple.com/uz/app/octo-mobile/id1460141475',
  ),
  'Hayot Bank': BankData(
    name: 'Hayot Bank',
    url: 'https://hayotbank.uz',
    androidUrl: 'https://play.google.com/store/apps/details?id=uz.cbssolutions.mobile&hl=ru',
    iosUrl: 'https://apps.apple.com/uz/app/hayot-bank/id6468219656',
  ),
  'Uzum Bank': BankData(
    name: 'Uzum Bank',
    url: 'https://uzumbank.uz',
    androidUrl: 'https://play.google.com/store/apps/details?id=uz.kapitalbank.android&hl=uz',
    iosUrl: 'https://apps.apple.com/uz/app/uzum-bank-onlayn-ozbekiston/id1492307726',
  ),
  'AVO Bank': BankData(
    name: 'AVO Bank',
    url: 'https://avobank.uz',
    androidUrl: 'https://play.google.com/store/apps/details?id=uz.avo.app&hl=ru',
    iosUrl: 'https://apps.apple.com/ru/app/avo-%D0%BE%D0%BD%D0%BB%D0%B0%D0%B9%D0%BD-%D0%B1%D0%B0%D0%BD%D0%BA-%D1%83%D0%B7%D0%B1%D0%B5%D0%BA%D0%B8%D1%81%D1%82%D0%B0%D0%BD%D0%B0/id6463799850',
  ),
  'My Bank': BankData(
    name: 'My Bank',
    url: 'https://my-bank.uz/en',
  ),
  'APEX Bank': BankData(
    name: 'APEX Bank',
    url: 'https://apexbank.uz',
  ),
  'Smart Bank': BankData(
    name: 'Smart Bank',
    url: 'https://smartbank.uz',
    androidUrl: 'https://play.google.com/store/apps/details?id=uz.smartbank&hl=ru',
    iosUrl: 'https://apps.apple.com/uz/app/smartbank-uz-onlayn-bank/id6446754221',
  ),
  'Yangi Bank': BankData(
    name: 'Yangi Bank',
    url: 'https://yangi.uz/',
  ),
};

/// Payment services with app store links
const Map<String, PaymentServiceData> _paymentServices = {
  'Paynet': PaymentServiceData(
    name: 'Paynet',
    url: 'https://paynet.uz',
    androidUrl: 'https://play.google.com/store/apps/details?id=uz.paynet.app',
    iosUrl: 'https://apps.apple.com/uz/app/paynet-%D0%B4%D0%B5%D0%BD%D0%B5%D0%B6%D0%BD%D1%8B%D0%B5-%D0%BF%D0%B5%D1%80%D0%B5%D0%B2%D0%BE%D0%B4%D1%8B/id1307888692',
  ),
  'Xazna': PaymentServiceData(
    name: 'Xazna',
    url: 'https://xazna.uz',
    androidUrl: 'https://play.google.com/store/apps/details?id=uz.tune.xazna&hl=ru',
    iosUrl: 'https://apps.apple.com/uz/app/xazna/id1642489915',
  ),
  'Mavrid': PaymentServiceData(
    name: 'Mavrid',
    url: 'https://mavrid.uz',
    androidUrl: 'https://play.google.com/store/apps/details?id=uz.tune.mkbdbo&hl=uz',
    iosUrl: 'https://apps.apple.com/uz/app/mavrid/id6445884560',
  ),
  'Milliy': PaymentServiceData(
    name: 'Milliy',
    url: 'https://milliy.uz',
    androidUrl: 'https://play.google.com/store/apps/details?id=com.tune.milliy&hl=uz',
    iosUrl: 'https://apps.apple.com/uz/app/milliy/id1297283006',
  ),
  'Sqb Mobile': PaymentServiceData(
    name: 'Sqb Mobile',
    url: 'https://sqb.uz',
    androidUrl: 'https://play.google.com/store/apps/details?id=com.uzpsb.olam&hl=uz',
    iosUrl: 'https://apps.apple.com/uz/app/sqb-mobile/id1499606946',
  ),
  'Sello Superapp': PaymentServiceData(
    name: 'Sello Superapp',
    url: 'https://sello.uz',
    androidUrl: 'https://play.google.com/store/apps/details?id=com.tune.sello&hl=ru',
    iosUrl: 'https://apps.apple.com/uz/app/sello-superapp/id1603818062',
  ),
  'Alif Mobi': PaymentServiceData(
    name: 'Alif Mobi',
    url: 'https://alif.mobi',
    androidUrl: 'https://play.google.com/store/apps/details?id=tj.alif.mobi&hl=ru',
    iosUrl: 'https://apps.apple.com/us/app/alif-%D0%BF%D0%B5%D1%80%D0%B5%D0%B2%D0%BE%D0%B4%D1%8B-%D0%BE%D0%BF%D0%BB%D0%B0%D1%82%D1%8B-%D0%BD%D0%B0%D1%81%D0%B8%D1%8F/id1331374853?l=ru',
  ),
  'Chakanapay': PaymentServiceData(
    name: 'Chakanapay',
    url: 'https://chakanapay.uz',
    androidUrl: 'https://play.google.com/store/apps/details?id=uz.agrobank.chakanapay&hl=ru',
    iosUrl: 'https://apps.apple.com/us/app/chakanapay/id6474964370',
  ),
  'Oq': PaymentServiceData(
    name: 'Oq',
    url: 'https://oq.uz',
    androidUrl: 'https://play.google.com/store/apps/details?id=com.veon.oq&hl=uz',
    iosUrl: 'https://apps.apple.com/uz/app/oq/id6443854848',
  ),
  'Humans': PaymentServiceData(
    name: 'Humans',
    url: 'https://humans.uz',
    androidUrl: 'https://play.google.com/store/apps/details?id=net.humans.fintech_uz',
    iosUrl: 'https://apps.apple.com/uz/app/humans-uz/id1508198703',
  ),
  'Infin Bank': PaymentServiceData(
    name: 'Infin Bank',
    url: 'https://www.infinbank.com/ru/',
    androidUrl: 'https://play.google.com/store/apps/details?id=uz.xsoft.myinfin&hl=ru',
    iosUrl: 'https://apps.apple.com/ru/app/infinbank/id1454367354',
  ),
  'Hamkor Mobile': PaymentServiceData(
    name: 'Hamkor Mobile',
    url: 'https://hamkorbank.uz/',
    androidUrl: 'https://play.google.com/store/apps/details?id=uz.hamkorbank.mobile&hl=ru',
    iosUrl: 'https://apps.apple.com/us/app/hamkor-%D0%BE%D0%BD%D0%BB%D0%B0%D0%B9%D0%BD-%D0%B1%D0%B0%D0%BD%D0%BA-%D1%83%D0%B7%D0%B1%D0%B5%D0%BA%D0%B8%D1%81%D1%82%D0%B0%D0%BD%D0%B0/id1602323485',
  ),
  'Universal Bank': PaymentServiceData(
    name: 'Universal Bank',
    url: 'https://universalbank.uz',
    androidUrl: 'https://play.google.com/store/apps/details?id=uz.fido.universaldigital',
    iosUrl: 'https://apps.apple.com/uz/app/universalbank/id6453759395',
  ),
  'Multicard': PaymentServiceData(
    name: 'Multicard',
    url: 'https://multicard.uz',
    androidUrl: 'https://play.google.com/store/apps/details?id=uz.owl.multicard',
    iosUrl: 'https://apps.apple.com/uz/app/multicard-jett-%D0%B8%D0%BD%D0%B2%D0%B5%D1%81%D1%82%D0%B8%D1%86%D0%B8%D0%B8/id1530741420',
  ),
  'Tenge24': PaymentServiceData(
    name: 'Tenge24',
    url: 'https://tengebank.uz',
    androidUrl: 'https://play.google.com/store/apps/details?id=uz.tune.tenge',
    iosUrl: 'https://apps.apple.com/uz/app/tenge24/id1586139053',
  ),
  'Trastpay': PaymentServiceData(
    name: 'Trastpay',
    url: 'https://trastbank.uz',
    androidUrl: 'https://play.google.com/store/apps/details?id=trastpay.uz&hl=ru',
    iosUrl: 'https://apps.apple.com/uz/app/trastpay/id6443658536',
  ),
  'Agro Bank Mobile': PaymentServiceData(
    name: 'Agro Bank Mobile',
    url: 'https://agrobank.uz',
    androidUrl: 'https://play.google.com/store/apps/details?id=uz.agrobank.mobile&hl=ru',
    iosUrl: 'https://apps.apple.com/ru/app/agrobank-mobile/id1638716474',
  ),
  'Myturon': PaymentServiceData(
    name: 'Myturon',
    url: 'https://turonbank.uz',
    androidUrl: 'https://play.google.com/store/apps/details?id=com.colvir.turon.mobile&hl=ru',
    iosUrl: 'https://apps.apple.com/uz/app/my-turon/id1639122039',
  ),
  "Ipak Yo'Li Mobile": PaymentServiceData(
    name: "Ipak Yo'Li Mobile",
    url: 'https://ipakyulibank.uz',
    androidUrl: 'https://play.google.com/store/apps/details?id=com.ipakyulibank.mobile&hl=ru',
    iosUrl: 'https://apps.apple.com/uz/app/ipak-yoli-mobile/id1436677359',
  ),
  'Zoomrad': PaymentServiceData(
    name: 'Zoomrad',
    url: 'https://aloqabank.uz',
    androidUrl: 'https://play.google.com/store/apps/details?id=uz.aloqabank.zoomrad&hl=ru',
    iosUrl: 'https://apps.apple.com/uz/app/zoomrad/id1522419775',
  ),
  'Octo Mobile': PaymentServiceData(
    name: 'Octo Mobile',
    url: 'https://octobank.uz',
    androidUrl: 'https://play.google.com/store/apps/details?id=com.ravnaqbank.rbkmobile&hl=ru',
    iosUrl: 'https://apps.apple.com/uz/app/octo-mobile/id1460141475',
  ),
  'Beepul': PaymentServiceData(
    name: 'Beepul',
    url: 'https://beepul.uz',
    androidUrl: 'https://play.google.com/store/apps/details?id=com.olsoft.mats.prod',
    iosUrl: 'https://apps.apple.com/uz/app/beepul/id1168589903',
  ),
  'Alliance': PaymentServiceData(
    name: 'Alliance',
    url: 'https://aab.uz',
    androidUrl: 'https://play.google.com/store/apps/details?id=uz.fb.cib.mobile.aab',
    iosUrl: 'https://apps.apple.com/uz/app/alliance-pay/id6469618319',
  ),
  'Oson': PaymentServiceData(
    name: 'Oson',
    url: 'https://oson.uz',
    androidUrl: 'https://play.google.com/store/apps/details?id=com.oson&hl=ru',
    iosUrl: 'https://apps.apple.com/us/app/oson-%D0%BF%D0%BB%D0%B0%D1%82%D0%B5%D0%B6%D0%B8-%D0%B8-%D0%BF%D0%B5%D1%80%D0%B5%D0%B2%D0%BE%D0%B4%D1%8B/id1207834182',
  ),
  'Unired': PaymentServiceData(
    name: 'Unired',
    url: 'https://unired.uz',
    androidUrl: 'https://play.google.com/store/apps/details?id=itunisoftgroup.uz&hl=ru',
    iosUrl: 'https://apps.apple.com/lv/app/unired-money-transfers/id1547412944',
  ),
  'Ipoteka Retail': PaymentServiceData(
    name: 'Ipoteka Retail',
    url: 'https://ipotekabank.uz',
    androidUrl: 'https://play.google.com/store/apps/details?id=com.bss.ipotekabank.retail.lite&hl=ru',
    iosUrl: 'https://apps.apple.com/ru/app/ipoteka-retail/id1637057203',
  ),
  'Garant Bank': PaymentServiceData(
    name: 'Garant Bank',
    url: 'https://garantbank.uz',
    androidUrl: 'https://play.google.com/store/apps/details?id=uz.comsa.garant.mobile&hl=ru',
    iosUrl: 'https://apps.apple.com/uz/app/garant-bank-%D1%83%D0%B7%D0%B1%D0%B5%D0%BA%D0%B8%D1%81%D1%82%D0%B0%D0%BD/id6476410628',
  ),
  'Plum': PaymentServiceData(
    name: 'Plum',
    url: 'https://uzcard.uz',
    androidUrl: 'https://play.google.com/store/apps/details?id=mobile.uzcard.uz.uzcard',
    iosUrl: 'https://apps.apple.com/uz/app/plum-uz/id1447849889',
  ),
  'Ofb': PaymentServiceData(
    name: 'Ofb',
    url: 'https://ofb.uz',
    androidUrl: 'https://play.google.com/store/apps/details?id=uz.ofbmobile.android&hl=ru',
    iosUrl: 'https://apps.apple.com/uz/app/ofb/id6443708765',
  ),
  'Hayot Bank': PaymentServiceData(
    name: 'Hayot Bank',
    url: 'https://hayotbank.uz',
    androidUrl: 'https://play.google.com/store/apps/details?id=uz.cbssolutions.mobile&hl=ru',
    iosUrl: 'https://apps.apple.com/uz/app/hayot-bank/id6468219656',
  ),
  'Hambi': PaymentServiceData(
    name: 'Hambi',
    url: 'https://beeline.uz',
    androidUrl: 'https://play.google.com/store/apps/details?id=uz.beeline.odp&hl=uz',
    iosUrl: 'https://apps.apple.com/us/app/hambi-beeline-uzbekistan/id722072887',
  ),
  'Digital Pay': PaymentServiceData(
    name: 'Digital Pay',
    url: 'https://digitalpay.uz',
    androidUrl: 'https://play.google.com/store/apps/details?id=uz.dpay.payment&hl=ru',
    iosUrl: 'https://apps.apple.com/uz/app/digital-pay/id1668041807',
  ),
  'Payway': PaymentServiceData(
    name: 'Payway',
    url: 'https://payway.uz',
    androidUrl: 'https://play.google.com/store/apps/details?id=uz.payway',
    iosUrl: 'https://apps.apple.com/uz/developer/pay-way-mchj/id1618972816',
  ),
  'Iwon': PaymentServiceData(
    name: 'Iwon',
    url: 'https://iwon.uz',
    androidUrl: 'https://play.google.com/store/apps/details?id=com.iwon.client&hl=ru',
    iosUrl: 'https://apps.apple.com/us/app/iwon/id1526657521',
  ),
  'My Uztelecom': PaymentServiceData(
    name: 'My Uztelecom',
    url: 'https://uztelecom.uz',
    androidUrl: 'https://play.google.com/store/apps/details?id=uz.uztelecom.telecom&hl=uz',
    iosUrl: 'https://apps.apple.com/us/app/myuztelecom/id1440173415',
  ),
  'Payme': PaymentServiceData(
    name: 'Payme',
    url: 'https://payme.uz',
    androidUrl: 'https://play.google.com/store/apps/details?id=uz.dida.payme&hl=ru',
    iosUrl: 'https://apps.apple.com/us/app/payme-%D0%BF%D0%B5%D1%80%D0%B5%D0%B2%D0%BE%D0%B4%D1%8B-%D0%B8-%D0%BF%D0%BB%D0%B0%D1%82%D0%B5%D0%B6%D0%B8/id1093525667',
  ),
  'Click Up': PaymentServiceData(
    name: 'Click Up',
    url: 'https://click.uz',
    androidUrl: 'https://play.google.com/store/apps/details?id=air.com.ssdsoftwaresolutions.clickuz',
    iosUrl: 'https://apps.apple.com/uz/app/click-superapp/id768132591',
  ),
  'Paylov': PaymentServiceData(
    name: 'Paylov',
    url: 'https://paylov.uz',
    androidUrl: 'https://play.google.com/store/apps/details?id=uz.octagram.paylov',
    iosUrl: 'https://apps.apple.com/uz/developer/octagram-llc/id1657209387',
  ),
  'A Pay': PaymentServiceData(
    name: 'A Pay',
    url: 'https://apay.uz',
    androidUrl: 'https://play.google.com/store/apps/details?id=uz.uzkassa.apay.app',
    iosUrl: 'https://apps.apple.com/uz/app/a-pay-%D0%BA%D0%B5%D1%88%D0%B1%D1%8D%D0%BA-%D0%B4%D0%BE-3-%D0%B2%D1%81%D0%B5%D0%BC/id1660729012',
  ),
  'Limon Pay': PaymentServiceData(
    name: 'Limon Pay',
    url: 'https://limonpay.uz',
    androidUrl: 'https://play.google.com/store/apps/details?id=uz.limonpay.app.limon_pay&hl=ru',
    iosUrl: 'https://apps.apple.com/uz/app/limon-pay/id1660046783',
  ),
  'Anor Bank': PaymentServiceData(
    name: 'Anor Bank',
    url: 'https://anorbank.uz',
    androidUrl: 'https://play.google.com/store/apps/details?id=uz.anormobile.retail&hl=uz',
    iosUrl: 'https://apps.apple.com/uz/app/anorbank/id1579623268',
  ),
  'Asaka Bank': PaymentServiceData(
    name: 'Asaka Bank',
    url: 'https://asakabank.uz',
    androidUrl: 'https://play.google.com/store/apps/details?id=uz.asakabank.myasaka&hl=ru',
    iosUrl: 'https://apps.apple.com/uz/app/asakabank/id1574165416',
  ),
  'Avo': PaymentServiceData(
    name: 'Avo',
    url: 'https://avobank.uz',
    androidUrl: 'https://play.google.com/store/apps/details?id=uz.avo.app&hl=ru',
    iosUrl: 'https://apps.apple.com/ru/app/avo-%D0%BE%D0%BD%D0%BB%D0%B0%D0%B9%D0%BD-%D0%B1%D0%B0%D0%BD%D0%BA-%D1%83%D0%B7%D0%B1%D0%B5%D0%BA%D0%B8%D1%81%D1%82%D0%B0%D0%BD%D0%B0/id6463799850',
  ),
  'BRB': PaymentServiceData(
    name: 'BRB',
    url: 'https://brb.uz',
    androidUrl: 'https://play.google.com/store/apps/details?id=com.qqb.quant&hl=ru',
    iosUrl: 'https://apps.apple.com/uz/app/brb/id1524422825',
  ),
  'Davr Mobile 2.0': PaymentServiceData(
    name: 'Davr Mobile 2.0',
    url: 'https://davrbank.uz',
    androidUrl: 'https://play.google.com/store/apps/details?id=uz.davrbank.mobile&hl=ru',
    iosUrl: 'https://apps.apple.com/uz/app/davr-mobile-2-0/id6483247810',
  ),
  'Smart Bank': PaymentServiceData(
    name: 'Smart Bank',
    url: 'https://smartbank.uz',
    androidUrl: 'https://play.google.com/store/apps/details?id=uz.smartbank&hl=ru',
    iosUrl: 'https://apps.apple.com/uz/app/smartbank-uz-onlayn-bank/id6446754221',
  ),
  'Tbc Uz': PaymentServiceData(
    name: 'Tbc Uz',
    url: 'https://tbcbank.uz',
    androidUrl: 'https://play.google.com/store/apps/details?id=ge.space.app.uzbekistan&hl=uz',
    iosUrl: 'https://apps.apple.com/ru/app/tbc-uz-%D0%BC%D0%BE%D0%B1%D0%B8%D0%BB%D1%8C%D0%BD%D1%8B%D0%B9-o%D0%BD%D0%BB%D0%B0%D0%B9%D0%BD-%D0%B1%D0%B0%D0%BD%D0%BA/id1450503714',
  ),
  'Uzum Bank': PaymentServiceData(
    name: 'Uzum Bank',
    url: 'https://uzumbank.uz',
    androidUrl: 'https://play.google.com/store/apps/details?id=uz.kapitalbank.android&hl=uz',
    iosUrl: 'https://apps.apple.com/uz/app/uzum-bank-onlayn-ozbekiston/id1492307726',
  ),
};

/// Get bank data by name (fuzzy matching)
BankData? getBankData(String bankName) {
  final lower = bankName.toLowerCase();
  for (final entry in _bankData.entries) {
    if (lower.contains(entry.key.toLowerCase()) || 
        entry.key.toLowerCase().contains(lower)) {
      return entry.value;
    }
  }
  return null;
}

/// Get payment service data by name (fuzzy matching)
PaymentServiceData? getPaymentServiceData(String serviceName) {
  final lower = serviceName.toLowerCase();
  for (final entry in _paymentServices.entries) {
    if (lower.contains(entry.key.toLowerCase()) || 
        entry.key.toLowerCase().contains(lower)) {
      return entry.value;
    }
  }
  return null;
}

/// Open bank website URL
/// If [bankNameOrUrl] is a valid URL, it will be opened directly
/// Otherwise, it will be treated as a bank name and looked up
Future<bool> openBankWebsite(String bankNameOrUrl) async {
  // Check if it's already a URL
  final uri = Uri.tryParse(bankNameOrUrl);
  if (uri != null && uri.hasScheme) {
    try {
      return await launchUrlString(
        bankNameOrUrl,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      return false;
    }
  }
  
  // Otherwise, treat as bank name
  final bankData = getBankData(bankNameOrUrl);
  if (bankData == null) return false;
  
  try {
    return await launchUrlString(
      bankData.url,
      mode: LaunchMode.externalApplication,
    );
  } catch (e) {
    return false;
  }
}

/// Open app store link (Play Store or App Store based on platform)
Future<bool> openAppStoreLink(String? androidUrl, String? iosUrl) async {
  String? url;
  if (Platform.isAndroid && androidUrl != null) {
    url = androidUrl;
  } else if (Platform.isIOS && iosUrl != null) {
    url = iosUrl;
  } else if (androidUrl != null) {
    url = androidUrl; // Fallback to Android if platform not detected
  } else if (iosUrl != null) {
    url = iosUrl; // Fallback to iOS if platform not detected
  }
  
  if (url == null) return false;
  
  try {
    return await launchUrlString(
      url,
      mode: LaunchMode.externalApplication,
    );
  } catch (e) {
    return false;
  }
}

/// Open payment service app store link
Future<bool> openPaymentServiceApp(String serviceName) async {
  final serviceData = getPaymentServiceData(serviceName);
  if (serviceData == null) return false;
  
  return await openAppStoreLink(serviceData.androidUrl, serviceData.iosUrl);
}

/// Open bank application in app store (Play Store for Android, App Store for iOS)
/// Falls back to bank website if app store link is not available
/// Shows error message if bank is not found
Future<bool> openBankApplication(String bankName) async {
  // Try to find bank in bankData first
  final bankData = getBankData(bankName);
  if (bankData != null) {
    // If bank has app store links, use them
    if (bankData.androidUrl != null || bankData.iosUrl != null) {
      final opened = await openAppStoreLink(bankData.androidUrl, bankData.iosUrl);
      if (opened) return true;
    }
    // Fallback to website
    if (bankData.url.isNotEmpty) {
      try {
        return await launchUrlString(
          bankData.url,
          mode: LaunchMode.externalApplication,
        );
      } catch (e) {
        return false;
      }
    }
  }
  
  // Try to find in payment services as fallback
  final serviceData = getPaymentServiceData(bankName);
  if (serviceData != null) {
    if (serviceData.androidUrl != null || serviceData.iosUrl != null) {
      return await openAppStoreLink(serviceData.androidUrl, serviceData.iosUrl);
    }
    // Fallback to website
    if (serviceData.url.isNotEmpty) {
      try {
        return await launchUrlString(
          serviceData.url,
          mode: LaunchMode.externalApplication,
        );
      } catch (e) {
        return false;
      }
    }
  }
  
  // If nothing found, return false
  return false;
}

