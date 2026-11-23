import '../../../core/network/api_response.dart';
import '../../prospects/data/models/prospect.dart';
import '../data/models/customer_models.dart';

/// Customers are converted prospects (same record and id). Conversion is an
/// explicit, audited business transition: the prospect, its activities and
/// its stage history are preserved.
abstract interface class CustomersRepository {
  Future<Paginated<Prospect>> getCustomers({
    String search = '',
    int page = 1,
    int perPage = 25,
    int? productId,
    CustomerMaintenanceFilter maintenance = CustomerMaintenanceFilter.all,
    CustomerPortalFilter portal = CustomerPortalFilter.all,
    CustomerSort sort = CustomerSort.convertedAt,
    bool ascending = false,
  });

  Future<CustomerProfile> getCustomer(int id);

  /// `409 ALREADY_CUSTOMER` when the prospect was converted before.
  Future<Prospect> convertProspect(int prospectId, ConvertPayload payload);

  Future<List<Trial>> getTrials(int prospectId);

  /// `409 TRIAL_OVERLAP` when a trial for this product overlaps.
  Future<Trial> activateTrial(int prospectId, TrialPayload payload);
  Future<Trial> revokeTrial(int trialId);
}
