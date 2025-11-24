import '../models/osago_company_model.dart';
import '../models/osago_duration_model.dart';
import '../models/osago_type_model.dart';

class OsagoLocalDataSource {
  const OsagoLocalDataSource();

  Future<List<OsagoCompanyModel>> fetchCompanies() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const [
      OsagoCompanyModel(id: '1', name: 'Kapital Insurance'),
      OsagoCompanyModel(id: '2', name: 'Uzagrosugurta'),
      OsagoCompanyModel(id: '3', name: 'Alfa Insurance'),
      OsagoCompanyModel(id: '4', name: 'Asia Insurance'),
    ];
  }

  Future<List<OsagoDurationModel>> fetchDurations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const [
      OsagoDurationModel(id: '1', label: '3 oy', months: 3),
      OsagoDurationModel(id: '2', label: '6 oy', months: 6),
      OsagoDurationModel(id: '3', label: '12 oy', months: 12),
    ];
  }

  Future<List<OsagoTypeModel>> fetchTypes() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const [
      OsagoTypeModel(id: '1', name: 'Individual'),
      OsagoTypeModel(id: '2', name: 'Corporate'),
    ];
  }
}

