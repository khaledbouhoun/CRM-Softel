import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:softel_crm/features/analytics/data/models/analytics_models.dart';
import 'package:softel_crm/features/analytics/domain/analytics_repository.dart';
import 'package:softel_crm/features/analytics/presentation/controllers/analytics_controller.dart';

class _FakeRepository implements AnalyticsRepository {
  final requested = <String>[];
  Object? failure;

  @override
  Future<AnalyticsData> getAnalytics({String range = 'month'}) async {
    requested.add(range);
    if (failure != null) throw failure!;
    return AnalyticsData(range: range);
  }
}

void main() {
  setUp(() => Get.testMode = true);
  tearDown(Get.reset);

  test('loads the current month on init and reloads when the range changes', () async {
    final repo = _FakeRepository();
    final c = Get.put(AnalyticsController(repository: repo));
    await pumpEventQueue();

    expect(repo.requested, ['month']);
    expect(c.state.isSuccess, isTrue);
    expect(c.data.value?.range, 'month');

    await c.setRange(AnalyticsRange.year);
    expect(repo.requested, ['month', 'year']);
    expect(c.data.value?.range, 'year');

    // Same or unknown ranges do not hit the API.
    await c.setRange(AnalyticsRange.year);
    await c.setRange('decade');
    expect(repo.requested, ['month', 'year']);
  });

  test('a failure is reported and the previous data is kept', () async {
    final repo = _FakeRepository();
    final c = Get.put(AnalyticsController(repository: repo));
    await pumpEventQueue();
    expect(c.data.value, isNotNull);

    repo.failure = Exception('offline');
    await c.load();
    expect(c.state.hasError, isTrue);
    expect(c.data.value, isNotNull);
  });
}
