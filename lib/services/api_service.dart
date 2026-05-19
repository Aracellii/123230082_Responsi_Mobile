import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // static const String showsUrl ='https://www.themealdb.com/api/json/v1/1/search.php?s=';
  // static const String showsUrl = 'https://api.tvmaze.com/shows';
  static const String showsUrl = 'https://www.freetogame.com/api/games';
  Future<dynamic> _fetchJson(String url) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception('Failed to load data from $url');
    }

    return jsonDecode(response.body);
  }

  Map<String, dynamic> _toMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return {'value': value};
  }

  List<dynamic> _extractList(dynamic decoded, {String? dataKey}) {
    if (decoded is List) {
      return decoded.map((e) => _toMap(e)).toList();
    }

    if (decoded is Map) {
      final map = Map<String, dynamic>.from(decoded);

      if (dataKey != null && map[dataKey] is List) {
        return (map[dataKey] as List).map((e) => _toMap(e)).toList();
      }

      for (final value in map.values) {
        if (value is List) {
          return value.map((e) => _toMap(e)).toList();
        }
      }
    }

    return [];
  }

  Map<String, dynamic> _extractMap(dynamic decoded, {String? dataKey}) {
    if (decoded is Map<String, dynamic>) {
      /// kalau nested array
      if (dataKey != null && decoded[dataKey] is List) {
        final list = decoded[dataKey] as List;

        if (list.isNotEmpty) {
          return _toMap(list.first);
        }
      }

      return decoded;
    }

    if (decoded is List && decoded.isNotEmpty) {
      return _toMap(decoded.first);
    }

    return {};
  }

  /// GENERIC FETCH LIST
  Future<List<dynamic>> fetchList(String url, {String? dataKey}) async {
    final decoded = await _fetchJson(url);

    return _extractList(decoded, dataKey: dataKey);
  }

  /// GENERIC FETCH DETAIL
  Future<Map<String, dynamic>> fetchDetail(
    String url, {
    String? dataKey,
  }) async {
    final decoded = await _fetchJson(url);

    return _extractMap(decoded, dataKey: dataKey);
  }

  /// Fetch and normalize shows/meals into a list of maps the app expects.
  Future<List<Map<String, dynamic>>> fetchShows(String url) async {
    final raw = await fetchList(url);

    return raw.map<Map<String, dynamic>>((data) {
      return {
        // 'id': int.tryParse(data['idMeal']?.toString() ?? '0') ?? 0,
        // 'name': data['strMeal'] ?? '',
        // 'imageUrl': data['strMealThumb'] ?? '',
        // 'rating': 0.0,
        // 'genres':
        //     data['strCategory'] is String &&
        //         (data['strCategory'] as String).isNotEmpty
        //     ? [data['strCategory'] as String]
        //     : [],
        // 'summary': data['strInstructions'] ?? '',
          'id': int.tryParse(data['id']?.toString() ?? '0') ?? 0,
          'name': data['title'] ?? '',
          'imageUrl': data['thumbnail'] ?? '',
          'rating': data['release_date'] ?? '',
          'genres':
            data['genre'] is String &&
                (data['genre'] as String).isNotEmpty
            ? [data['genre'] as String]
            : [],      
          'summary': data['short_description'] ?? '',
          'date':data['release_date']??'',
          'platform':data['platform']??'',
      };
    }).toList();
  }
} 
