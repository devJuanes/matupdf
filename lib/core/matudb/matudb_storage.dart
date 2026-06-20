import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'matudb_config.dart';
import 'matudb_result.dart';

class MatuDbStorage {
  MatuDbStorage({String? accessToken}) : _accessToken = accessToken;

  String? _accessToken;

  void setAccessToken(String? token) => _accessToken = token;

  String get _baseUrl =>
      '${MatuDbConfig.url}/api/projects/${MatuDbConfig.projectId}/storage';

  Map<String, String> _headers() {
    final headers = <String, String>{'apikey': MatuDbConfig.apiKey};
    if (_accessToken != null && _accessToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }
    return headers;
  }

  Future<MatuDbResult<Map<String, dynamic>>> uploadBytes({
    required String path,
    required Uint8List bytes,
    String? fileName,
  }) async {
    if (!MatuDbConfig.isConfigured) {
      return const MatuDbResult(error: 'MatuDB no está configurado.');
    }

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/upload'),
      );
      request.headers.addAll(_headers());
      final safeName = fileName ?? path.split('/').last;
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: safeName,
        ),
      );
      request.fields['path'] = path;

      final streamed = await request.send();
      final body = await streamed.stream.bytesToString();
      final json = _decodeBody(body);

      if (streamed.statusCode >= 400) {
        return MatuDbResult(
          error: json['message'] as String? ?? 'Error al subir archivo',
        );
      }

      final data = json['data'];
      final fileData = data is Map
          ? (data['file'] as Map<String, dynamic>? ?? data.cast<String, dynamic>())
          : <String, dynamic>{'name': path};

      final name = fileData['name'] as String? ?? path;
      return MatuDbResult(
        data: {
          ...fileData,
          'publicUrl': getPublicUrl(name),
        },
      );
    } catch (e) {
      return MatuDbResult(error: e.toString());
    }
  }

  String getPublicUrl(String filename) {
    return '$_baseUrl/${Uri.encodeComponent(filename)}';
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
