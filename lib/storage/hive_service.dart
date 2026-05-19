import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String favoriteBoxName = 'favorites_box';

  static Future<void> init() async {
    await Hive.openBox<Map>(favoriteBoxName);
  }

  static Box<Map> get _box => Hive.box<Map>(favoriteBoxName);

  static ValueListenable<Box<Map>> favoritesListenable() {
    return _box.listenable();
  }

  static List<Map<String, dynamic>> getFavorites() {
    return _box.values.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  static bool isFavorite(int id) => _box.containsKey(id.toString());

  static Future<void> addFavorite(Map<String, dynamic> show) async {
    await _box.put(show['id'].toString(), show);
  }

  static Future<void> removeFavorite(int id) async {
    await _box.delete(id.toString());
  }

  static String _favoriteKey(String username, int id) => '$username:$id';

  static List<Map<String, dynamic>> getFavoritesFor(String username) {
    return _box.values
        .where((item) => item['owner'] == username)
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  static bool isFavoriteFor(String username, int id) {
    return _box.containsKey(_favoriteKey(username, id));
  }

  static Future<void> addFavoriteFor(
    String username,
    Map<String, dynamic> show,
  ) async {
    final payload = Map<String, dynamic>.from(show);
    payload['owner'] = username;
    await _box.put(_favoriteKey(username, show['id'] as int), payload);
  }

  static Future<void> removeFavoriteFor(String username, int id) async {
    await _box.delete(_favoriteKey(username, id));
  }
}
