import '../entities/bank_service.dart';
import '../repositories/bank_repository.dart';

class GetBankServices {
  const GetBankServices(this.repository);

  final BankRepository repository;

  List<BankService> call() => repository.getServices();
  
  Future<List<BankService>> callFromApi() => repository.getBankServicesFromApi();
}
