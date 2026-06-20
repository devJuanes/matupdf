import 'dart:convert';

import 'package:http/http.dart' as http;

import 'matudb_config.dart';
import 'matudb_result.dart';

class MatuDbSession {
  const MatuDbSession({
    required this.accessToken,
    required this.expiresAt,
    required this.user,
  });

  final String accessToken;
  final int expiresAt;
  final MatuDbUser user;

  bool get isExpired => DateTime.now().millisecondsSinceEpoch ~/ 1000 >= expiresAt;

  Map<String, dynamic> toJson() => {
        'access_token': accessToken,
        'expires_at': expiresAt,
        'user': user.toJson(),
      };

  factory MatuDbSession.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] as Map<String, dynamic>? ?? {};
    return MatuDbSession(
      accessToken: json['access_token'] as String? ?? '',
      expiresAt: json['expires_at'] as int? ?? 0,
      user: MatuDbUser.fromJson(userJson),
    );
  }
}

class MatuDbUser {
  const MatuDbUser({
    required this.id,
    required this.email,
    this.name,
  });

  final String id;
  final String email;
  final String? name;

  String get displayName =>
      (name != null && name!.trim().isNotEmpty) ? name!.trim() : email.split('@').first;

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
      };

  factory MatuDbUser.fromJson(Map<String, dynamic> json) {
    return MatuDbUser(
      id: '${json['id'] ?? json['user_id'] ?? ''}',
      email: json['email'] as String? ?? '',
      name: json['name'] as String?,
    );
  }
}

class MatuDbClient {
  MatuDbClient({
    String? accessToken,
  }) : _accessToken = accessToken;

  String? _accessToken;

  String get _authBase =>
      '${MatuDbConfig.url}/api/projects/${MatuDbConfig.projectId}/auth';

  String _dataUrl(String table) =>
      '${MatuDbConfig.url}/api/projects/${MatuDbConfig.projectId}/data/$table';

  Map<String, String> _headers({bool withAuth = false}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'apikey': MatuDbConfig.apiKey,
    };
    if (withAuth && _accessToken != null && _accessToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }
    return headers;
  }

  void setAccessToken(String? token) => _accessToken = token;

  Future<MatuDbResult<MatuDbSession>> signUp({
    required String email,
    required String password,
    String? name,
  }) async {
    if (!MatuDbConfig.isConfigured) {
      return const MatuDbResult(error: 'MatuDB no está configurado.');
    }

    try {
      final response = await http.post(
        Uri.parse('$_authBase/register'),
        headers: _headers(),
        body: jsonEncode({
          'email': email.trim(),
          'password': password,
          if (name != null && name.trim().isNotEmpty) 'name': name.trim(),
        }),
      );

      return _parseAuthResponse(response);
    } catch (e) {
      return MatuDbResult(error: e.toString());
    }
  }

  Future<MatuDbResult<MatuDbSession>> signIn({
    required String email,
    required String password,
  }) async {
    if (!MatuDbConfig.isConfigured) {
      return const MatuDbResult(error: 'MatuDB no está configurado.');
    }

    try {
      final response = await http.post(
        Uri.parse('$_authBase/login'),
        headers: _headers(),
        body: jsonEncode({
          'email': email.trim(),
          'password': password,
        }),
      );

      return _parseAuthResponse(response);
    } catch (e) {
      return MatuDbResult(error: e.toString());
    }
  }

  MatuDbResult<MatuDbSession> _parseAuthResponse(http.Response response) {
    final body = _decodeBody(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return MatuDbResult(
        error: body['message'] as String? ?? 'Error de autenticación',
      );
    }

    final data = body['data'] as Map<String, dynamic>? ?? body;
    final token = data['token'] as String? ?? data['access_token'] as String?;
    final userJson = data['user'] as Map<String, dynamic>? ?? data;

    if (token == null || token.isEmpty) {
      return const MatuDbResult(error: 'Respuesta de auth inválida');
    }

    final user = MatuDbUser.fromJson(userJson);
    final expiresAt = _tokenExpiry(token);
    final session = MatuDbSession(
      accessToken: token,
      expiresAt: expiresAt,
      user: user,
    );
    _accessToken = token;
    return MatuDbResult(data: session);
  }

  int _tokenExpiry(String token) {
    try {
      final parts = token.split('.');
      if (parts.length < 2) {
        return DateTime.now().add(const Duration(hours: 24)).millisecondsSinceEpoch ~/ 1000;
      }
      final normalized = base64Url.normalize(parts[1]);
      final payload = jsonDecode(utf8.decode(base64Url.decode(normalized)));
      if (payload is Map && payload['exp'] != null) {
        return payload['exp'] as int;
      }
    } catch (_) {}
    return DateTime.now().add(const Duration(hours: 24)).millisecondsSinceEpoch ~/ 1000;
  }

  Future<MatuDbResult<List<Map<String, dynamic>>>> insert(
    String table,
    Map<String, dynamic> row,
  ) async {
    return insertMany(table, [row]);
  }

  Future<MatuDbResult<List<Map<String, dynamic>>>> insertMany(
    String table,
    List<Map<String, dynamic>> rows,
  ) async {
    if (!MatuDbConfig.isConfigured) {
      return const MatuDbResult(error: 'MatuDB no está configurado.');
    }

    try {
      final uri = Uri.parse('${_dataUrl(table)}?apikey=${MatuDbConfig.apiKey}');
      final response = await http.post(
        uri,
        headers: _headers(withAuth: true),
        body: jsonEncode(rows.length == 1 ? rows.first : rows),
      );

      final body = _decodeBody(response.body);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return MatuDbResult(
          error: body['message'] as String? ?? 'Error al guardar datos',
        );
      }

      final data = body['data'];
      if (data is Map && data['rows'] is List) {
        return MatuDbResult(
          data: (data['rows'] as List).cast<Map<String, dynamic>>(),
        );
      }
      if (data is List) {
        return MatuDbResult(data: data.cast<Map<String, dynamic>>());
      }
      if (data is Map) {
        return MatuDbResult(data: [data.cast<String, dynamic>()]);
      }

      return const MatuDbResult(data: []);
    } catch (e) {
      return MatuDbResult(error: e.toString());
    }
  }

  Map<String, dynamic> _decodeBody(String raw) {
    if (raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return decoded.cast<String, dynamic>();
    } catch (_) {}
    return {'message': raw};
  }
}
