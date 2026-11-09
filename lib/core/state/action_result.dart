import '../network/api_exceptions.dart';

/// Outcome of a user action (save, toggle, transition...). Controllers return
/// it; views decide how to present it.
class ActionResult<T> {
  const ActionResult.success([this.value]) : error = null;
  const ActionResult.failure(ApiException this.error) : value = null;

  final T? value;
  final ApiException? error;

  bool get isSuccess => error == null;

  static Future<ActionResult<T>> guard<T>(Future<T> Function() task) async {
    try {
      return ActionResult.success(await task());
    } catch (e) {
      return ActionResult.failure(ApiException.from(e));
    }
  }
}
