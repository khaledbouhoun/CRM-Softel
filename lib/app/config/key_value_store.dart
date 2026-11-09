import 'package:get_storage/get_storage.dart';

/// Minimal persistence abstraction so settings can be tested without the
/// GetStorage platform plugin.
abstract interface class KeyValueStore {
  T? read<T>(String key);
  Future<void> write(String key, Object? value);
}

class GetStorageStore implements KeyValueStore {
  GetStorageStore([GetStorage? box]) : _box = box ?? GetStorage();

  final GetStorage _box;

  @override
  T? read<T>(String key) => _box.read<T>(key);

  @override
  Future<void> write(String key, Object? value) => _box.write(key, value);
}

class InMemoryStore implements KeyValueStore {
  InMemoryStore([Map<String, Object?>? initial]) : _values = {...?initial};

  final Map<String, Object?> _values;

  @override
  T? read<T>(String key) => _values[key] as T?;

  @override
  Future<void> write(String key, Object? value) async => _values[key] = value;
}
