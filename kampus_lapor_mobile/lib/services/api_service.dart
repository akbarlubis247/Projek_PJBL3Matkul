import 'package:http/http.dart' as http;

class ApiService {
  final List<String> apiBases;
  String token = '';

  ApiService({required this.apiBases});

  Future<http.Response> postAuth(Map<String, String> body, bool registerMode) async {
    Object? lastError;
    for (final base in apiBases) {
      try {
        return await http
            .post(
              Uri.parse(
                '$base/api/${registerMode ? 'civitas/register' : 'auth/login/civitas'}',
              ),
              headers: {'Accept': 'application/json'},
              body: body,
            )
            .timeout(const Duration(seconds: 4));
      } catch (error) {
        lastError = error;
      }
    }
    throw lastError ?? Exception('Server tidak dapat dihubungi');
  }

  Future<http.Response> post(String path, Map<String, dynamic> body) async {
    Object? lastError;
    for (final base in apiBases) {
      try {
        return await http
            .post(
              Uri.parse('$base/api/$path'),
              headers: {
                'Accept': 'application/json',
                if (token.isNotEmpty) 'Authorization': 'Bearer $token',
              },
              body: body,
            )
            .timeout(const Duration(seconds: 4));
      } catch (error) {
        lastError = error;
      }
    }
    throw lastError ?? Exception('Server tidak dapat dihubungi');
  }

  Future<http.Response> get(String path) async {
    Object? lastError;
    for (final base in apiBases) {
      try {
        return await http
            .get(
              Uri.parse('$base/api/$path'),
              headers: {
                'Accept': 'application/json',
                if (token.isNotEmpty) 'Authorization': 'Bearer $token',
              },
            )
            .timeout(const Duration(seconds: 4));
      } catch (error) {
        lastError = error;
      }
    }
    throw lastError ?? Exception('Server tidak dapat dihubungi');
  }

  Future<http.Response> patch(String path, [Map<String, dynamic>? body]) async {
    Object? lastError;
    for (final base in apiBases) {
      try {
        return await http
            .patch(
              Uri.parse('$base/api/$path'),
              headers: {
                'Accept': 'application/json',
                if (token.isNotEmpty) 'Authorization': 'Bearer $token',
              },
              body: body,
            )
            .timeout(const Duration(seconds: 4));
      } catch (error) {
        lastError = error;
      }
    }
    throw lastError ?? Exception('Server tidak dapat dihubungi');
  }
}
