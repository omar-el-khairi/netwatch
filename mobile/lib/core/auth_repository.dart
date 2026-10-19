import 'package:supervision_mobile/core/api_client.dart';

class AuthRepository {
  AuthRepository(this.api);
  final ApiClient api;

  Future<void> init() => api.loadSettings();

  Future<void> setBaseUrl(String url) => api.saveBaseUrl(url);

  String get baseUrl => api.baseUrl;

  Future<Map<String, dynamic>> login(String email, String password) async {
    final data = await api.post(
      '/api/auth/login',
      body: {'email': email, 'password': password},
    ) as Map<String, dynamic>;
    await api.saveToken(data['token'] as String);
    return data;
  }

  Future<void> logout() => api.saveToken(null);

  Future<Map<String, dynamic>?> me() async {
    await api.loadSettings();
    if (api.token == null) return null;
    try {
      return await api.get('/api/auth/me') as Map<String, dynamic>;
    } catch (_) {
      await api.saveToken(null);
      return null;
    }
  }

}
