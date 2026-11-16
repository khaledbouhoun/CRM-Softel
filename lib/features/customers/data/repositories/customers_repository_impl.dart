import '../../../../core/network/api_response.dart';
import '../../../prospects/data/models/prospect.dart';
import '../../domain/customers_repository.dart';
import '../datasources/customers_remote_data_source.dart';
import '../models/customer_models.dart';

class CustomersRepositoryImpl implements CustomersRepository {
  const CustomersRepositoryImpl(this._remote);

  final CustomersRemoteDataSource _remote;

  @override
  Future<Paginated<Prospect>> getCustomers({
    String search = '',
    int page = 1,
    int perPage = 25,
  }) => _remote.getCustomers(search: search, page: page, perPage: perPage);

  @override
  Future<CustomerProfile> getCustomer(int id) => _remote.getCustomer(id);

  @override
  Future<Prospect> convertProspect(int prospectId, ConvertPayload payload) =>
      _remote.convert(prospectId, payload);

  @override
  Future<List<Trial>> getTrials(int prospectId) =>
      _remote.getTrials(prospectId);

  @override
  Future<Trial> activateTrial(int prospectId, TrialPayload payload) =>
      _remote.activateTrial(prospectId, payload);

  @override
  Future<Trial> revokeTrial(int trialId) => _remote.revokeTrial(trialId);
}
