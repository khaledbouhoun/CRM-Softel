import 'package:dio/dio.dart';

import '../utils/json_utils.dart';
import '../../app/l10n/l10n.dart';

/// Every failure coming out of the network layer is one of these types.
///
/// Controllers catch [ApiException] and display [message]; they never need to
/// know about Dio.
sealed class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => '$runtimeType($statusCode): $message';

  /// Converts any error thrown while talking to the API into an [ApiException].
  static ApiException from(Object error, {String? baseUrl}) {
    if (error is ApiException) return error;
    if (error is DioException) return _fromDio(error, baseUrl: baseUrl);
    if (error is FormatException || error is TypeError) {
      return UnexpectedResponseException(
        tr.errUnexpectedResponse(error.toString()),
      );
    }
    return UnknownApiException(tr.errUnexpected(error));
  }

  static ApiException _fromDio(DioException e, {String? baseUrl}) {
    final server = baseUrl ?? e.requestOptions.baseUrl;
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutApiException(tr.errTimeout(server));
      case DioExceptionType.connectionError:
        return NetworkException(tr.errConnection(server));
      case DioExceptionType.badCertificate:
        return NetworkException(tr.errCertificate(server));
      case DioExceptionType.cancel:
        return CancelledApiException(tr.errCancelled);
      case DioExceptionType.badResponse:
        return _fromResponse(e.response);
      case DioExceptionType.transformTimeout:
        return UnexpectedResponseException(tr.errReceiveTimeout(server));
      case DioExceptionType.unknown:
        if (e.error is FormatException) {
          return UnexpectedResponseException(
            (e.error as FormatException).message,
          );
        }
        // On Windows a refused socket often surfaces as `unknown` with a
        // SocketException inside.
        if (e.error != null && e.error.toString().contains('SocketException')) {
          return NetworkException(tr.errConnectionShort(server));
        }
        return UnknownApiException(
          tr.errCommunication(e.message ?? e.error ?? ''),
        );
    }
  }

  static ApiException _fromResponse(Response<dynamic>? response) {
    final status = response?.statusCode ?? 0;
    final body = asMapOrNull(response?.data);
    final serverMessage = asStringOrNull(body?['message']);

    switch (status) {
      case 400:
        return BadRequestException(
          serverMessage ?? tr.errBadRequest,
          statusCode: status,
        );
      case 404:
        return NotFoundException(
          serverMessage ?? tr.errNotFound,
          statusCode: status,
        );
      case 405:
        return NotSupportedException(
          serverMessage ?? tr.errNotSupported,
          statusCode: status,
        );
      case 409:
        return ConflictException(
          serverMessage ?? tr.errConflict,
          statusCode: status,
        );
      case 422:
        // Plain field validation carries a generic English message; business
        // rule refusals (INVALID_STAGE_TRANSITION, ...) carry a specific one.
        final isFieldValidation = body?['error_code'] == 'VALIDATION_FAILED';
        return ValidationException(
          isFieldValidation || serverMessage == null
              ? tr.errValidation
              : serverMessage,
          fieldErrors: _parseFieldErrors(body?['errors']),
        );
      default:
        if (status >= 500) {
          return ServerException(
            serverMessage ?? tr.errServer(status),
            statusCode: status,
          );
        }
        return UnknownApiException(
          serverMessage ?? tr.errUnexpectedStatus(status),
          statusCode: status,
        );
    }
  }

  static Map<String, List<String>> _parseFieldErrors(Object? raw) {
    final map = asMapOrNull(raw);
    if (map == null) return const {};
    return map.map((field, messages) {
      final list = messages is List
          ? messages.map((m) => m.toString()).toList()
          : <String>[messages.toString()];
      return MapEntry(field, list);
    });
  }
}

/// Server unreachable (no route, refused connection, DNS, ...).
class NetworkException extends ApiException {
  const NetworkException(super.message);
}

class TimeoutApiException extends ApiException {
  const TimeoutApiException(super.message);
}

class CancelledApiException extends ApiException {
  const CancelledApiException(super.message);
}

class BadRequestException extends ApiException {
  const BadRequestException(super.message, {super.statusCode});
}

class NotFoundException extends ApiException {
  const NotFoundException(super.message, {super.statusCode});
}

class NotSupportedException extends ApiException {
  const NotSupportedException(super.message, {super.statusCode});
}

class ConflictException extends ApiException {
  const ConflictException(super.message, {super.statusCode});
}

/// HTTP 422 from a Laravel FormRequest.
class ValidationException extends ApiException {
  const ValidationException(super.message, {this.fieldErrors = const {}})
    : super(statusCode: 422);

  /// Field name (Laravel dot notation) → messages.
  final Map<String, List<String>> fieldErrors;

  /// First error for [field], also matching nested keys such as `field.0`.
  String? errorFor(String field) {
    final direct = fieldErrors[field];
    if (direct != null && direct.isNotEmpty) return direct.first;
    for (final entry in fieldErrors.entries) {
      if (entry.key.startsWith('$field.') && entry.value.isNotEmpty) {
        return entry.value.first;
      }
    }
    return null;
  }

  /// All messages flattened, useful when the form has no matching field.
  List<String> get allMessages =>
      fieldErrors.values.expand((m) => m).toList(growable: false);

  /// Messages of fields the form cannot display next to an input, so they
  /// are shown in the form's general error instead of being lost. A key
  /// matches when its first segment (`product_ids.0` → `product_ids`) is in
  /// [displayedFields].
  List<String> messagesOutside(Set<String> displayedFields) => [
    for (final entry in fieldErrors.entries)
      if (!displayedFields.contains(entry.key.split('.').first)) ...entry.value,
  ];

  /// [message] followed by [messagesOutside], one per line.
  String describeFor(Set<String> displayedFields) =>
      [message, ...messagesOutside(displayedFields)].join('\n');
}

class ServerException extends ApiException {
  const ServerException(super.message, {super.statusCode});
}

class UnexpectedResponseException extends ApiException {
  const UnexpectedResponseException(super.message);
}

class UnknownApiException extends ApiException {
  const UnknownApiException(super.message, {super.statusCode});
}
