import 'package:bid/main.dart';
import 'package:get_storage/get_storage.dart';

class BidLocalStorage {
  static final BidLocalStorage _instance = BidLocalStorage._internal();

  // Factory constructor for singleton pattern
  factory BidLocalStorage() {
    return _instance;
  }

  // Private constructor
  BidLocalStorage._internal();

  // Create an instance of GetStorage
  final _storage = GetStorage();

  // Generic method to save data
  Future<void> saveData<T>(String key, T value) async {
    await _storage.write(key, value);
  }

  // Generic method to read data
  Bid? readData<T>(String key) {
    return _storage.read<Bid>(key);
  }

  // Generic method to remove data
  Future<void> removeData(String key) async {
    await _storage.remove(key);
  }

// Clear all data in storage
  Future<void> clearAll() async {
    await _storage.erase();
  }
}
