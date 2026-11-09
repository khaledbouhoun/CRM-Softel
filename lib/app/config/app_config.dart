/// Static application defaults.
class AppConfig {
  const AppConfig._();

  static const appName = 'SOFTEL CRM';

  /// Shown on first launch. Employees must replace it with the central
  /// computer's LAN address (never `localhost` on employee machines).
  static const defaultApiBaseUrl = 'http://192.168.1.100:8000/api/v1';

  static const defaultTimeoutSeconds = 15;
  static const minTimeoutSeconds = 3;
  static const maxTimeoutSeconds = 120;

  /// Timeout used by the connection test / status indicator.
  static const connectionCheckTimeout = Duration(seconds: 5);

  /// How often the top bar re-checks that the server is reachable.
  static const connectionCheckInterval = Duration(seconds: 60);

  static const defaultPageSize = 25;
  static const pageSizes = [10, 25, 50, 100];

  /// Page size used when a whole small list is needed (pipeline columns,
  /// prospect timeline).
  static const largePageSize = 100;
}
