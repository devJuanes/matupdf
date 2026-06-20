import 'package:flutter/foundation.dart';

import '../../../core/matudb/matudb_client.dart';
import '../../../core/matudb/matudb_config.dart';
import '../../../core/matudb/matudb_result.dart';
import '../../auth/presentation/controllers/auth_controller.dart';

class ContactRepository {
  ContactRepository({MatuDbClient? client}) : _client = client ?? MatuDbClient();

  final MatuDbClient _client;

  Future<MatuDbResult<void>> submit({
    required String name,
    required String email,
    required String subject,
    required String message,
    String? userId,
  }) async {
    if (!MatuDbConfig.isConfigured) {
      return const MatuDbResult(error: 'Servicio de contacto no disponible.');
    }

    final result = await _client.insert(MatuDbConfig.tableContacts, {
      'name': name.trim(),
      'email': email.trim(),
      'subject': subject.trim(),
      'message': message.trim(),
      if (userId != null) 'user_id': userId,
    });

    if (!result.isSuccess) {
      return MatuDbResult(error: result.error);
    }
    return const MatuDbResult(data: null);
  }
}

class DownloadLogger {
  DownloadLogger({MatuDbClient? client}) : _client = client ?? MatuDbClient();

  final MatuDbClient _client;

  /// Registra cada combinación/descarga, con o sin cuenta.
  Future<void> logMerge({
    required AuthController auth,
    required int fileCount,
    required List<String> fileNames,
  }) async {
    if (!MatuDbConfig.isConfigured) return;

    _client.setAccessToken(
      auth.isAuthenticated ? auth.session?.accessToken : null,
    );

    final names = fileNames.take(20).join(', ');
    final row = <String, dynamic>{
      'event_type': 'merge',
      'file_count': fileCount,
      'file_names': names,
      'platform': kIsWeb ? 'web' : defaultTargetPlatform.name,
    };

    if (auth.isAuthenticated) {
      row['user_id'] = auth.user!.id;
    } else if (auth.guestId != null) {
      row['guest_id'] = auth.guestId;
    }

    final result = await _client.insert(MatuDbConfig.tableDownloads, row);

    if (!result.isSuccess && kDebugMode) {
      debugPrint('DownloadLogger: ${result.error}');
    }
  }
}
