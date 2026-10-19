
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  /// Émulateur Android : http://10.0.2.2:4000
  /// Téléphone (même Wi‑Fi) : http://IP_DU_PC:4000  ex. http://192.168.1.119:4000
  static const String fallbackBaseUrl = 'http://192.168.1.135:4000';

  String baseUrl;
  String? token;

  ApiClient({this.baseUrl = fallbackBaseUrl});

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    final saved = prefs.getString('apiBaseUrl') ?? fallbackBaseUrl;
    baseUrl = _normalizeUrl(saved);
  }

  Future<void> saveBaseUrl(String url) async {
    baseUrl = _normalizeUrl(url);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('apiBaseUrl', baseUrl);
  }

  static String _normalizeUrl(String url) {
    var u = url.trim().replaceAll(RegExp(r'/$'), '');
    if (u.contains('0.0.0.0')) {
      u = u.replaceAll('0.0.0.0', '192.168.1.135');
    }
    return u;
  }

  static String? validateBaseUrl(String url) {
    final u = url.trim();
    if (u.isEmpty) return 'URL API requise';
    if (u.contains('0.0.0.0')) {
      return '0.0.0.0 est invalide. Utilisez l’IP du PC (ex. 192.168.1.135)';
    }
    if (!u.startsWith('http://') && !u.startsWith('https://')) {
      return 'L’URL doit commencer par http://';
    }
    return null;
  }

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
  }

  Future<void> saveToken(String? value) async {
    token = value;
    final prefs = await SharedPreferences.getInstance();
    if (value == null) {
      await prefs.remove('token');
    } else {
      await prefs.setString('token', value);
    }
  }

  Future<dynamic> get(String path) async {
    final res = await http.get(
      Uri.parse('$baseUrl$path'),
      headers: _headers(),
    );
    return _decode(res);
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    final res = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: _headers(),
      body: body == null ? null : jsonEncode(body),
    );
    return _decode(res);
  }

  Map<String, String> _headers() {
    final h = <String, String>{'Content-Type': 'application/json'};
    if (token != null) h['Authorization'] = 'Bearer $token';
    return h;
  }

  dynamic _decode(http.Response res) {
    final data = res.body.isEmpty ? null : jsonDecode(res.body);
    if (res.statusCode >= 400) {
      final msg = data is Map && data['error'] != null
          ? data['error'].toString()
          : 'Erreur HTTP ${res.statusCode}';
      throw Exception(msg);
    }
    return data;
  }
}
