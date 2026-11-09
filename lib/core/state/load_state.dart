import 'package:get/get.dart';

import '../network/api_exceptions.dart';

enum LoadStatus { initial, loading, success, error }

/// Observable loading state shared by list/detail controllers.
///
/// Keeps the previous data visible while refreshing (`isRefreshing`) and
/// exposes the last error message for error states.
class LoadState {
  final status = LoadStatus.initial.obs;
  final errorMessage = RxnString();

  /// The last error, kept so views can distinguish connection errors.
  ApiException? lastError;

  bool get isLoading => status.value == LoadStatus.loading;
  bool get hasError => status.value == LoadStatus.error;
  bool get isSuccess => status.value == LoadStatus.success;

  bool get isConnectionError =>
      lastError is NetworkException || lastError is TimeoutApiException;

  void loading() {
    status.value = LoadStatus.loading;
    errorMessage.value = null;
    lastError = null;
  }

  void success() {
    status.value = LoadStatus.success;
    errorMessage.value = null;
    lastError = null;
  }

  void error(ApiException e) {
    lastError = e;
    errorMessage.value = e.message;
    status.value = LoadStatus.error;
  }

  /// Runs [task] and records the outcome. Returns false on failure.
  Future<bool> run(Future<void> Function() task) async {
    loading();
    try {
      await task();
      success();
      return true;
    } catch (e) {
      error(ApiException.from(e));
      return false;
    }
  }
}
