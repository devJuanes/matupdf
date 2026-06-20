import 'package:flutter/foundation.dart';

import '../../../core/matudb/matudb_client.dart';
import '../../../core/matudb/matudb_config.dart';
import '../../../core/matudb/matudb_result.dart';
import '../../../core/utils/merged_pdf_bytes.dart';
import '../../auth/presentation/controllers/auth_controller.dart';

class MergeHistoryEntry {
  const MergeHistoryEntry({
    required this.id,
    required this.fileCount,
    required this.fileNames,
    required this.createdAt,
    this.fileUrl,
    this.outputName,
  });

  final int id;
  final int fileCount;
  final String? fileNames;
  final DateTime? createdAt;
  final String? fileUrl;
  final String? outputName;
}

class MergeHistoryRepository {
  MergeHistoryRepository({MatuDbClient? client}) : _client = client ?? MatuDbClient();

  final MatuDbClient _client;

  /// Registra la combinación en `pdf_downloads` y sube el PDF al storage si hay sesión.
  Future<MatuDbResult<void>> logMerge({
    required AuthController auth,
    required int fileCount,
    required List<String> fileNames,
    required String outputPath,
  }) async {
    if (!MatuDbConfig.isConfigured) {
      return const MatuDbResult(error: 'MatuDB no configurado');
    }

    _client.setAccessToken(
      auth.isAuthenticated ? auth.session?.accessToken : null,
    );

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final outputName = 'matupdf_merged_$timestamp.pdf';
    String? storagePath;
    String? fileUrl;

    if (auth.isAuthenticated) {
      final bytes = await readMergedPdfBytes(outputPath);
      if (bytes != null && bytes.isNotEmpty) {
        storagePath = 'matupdf/${auth.user!.id}/$outputName';
        final upload = await _client.storage.uploadBytes(
          path: storagePath,
          bytes: bytes,
          fileName: outputName,
        );
        if (upload.isSuccess && upload.data != null) {
          fileUrl = upload.data!['publicUrl'] as String?;
          storagePath = upload.data!['name'] as String? ?? storagePath;
        } else if (kDebugMode) {
          debugPrint('MergeHistoryRepository upload: ${upload.error}');
        }
      }
    }

    final names = fileNames.take(20).join(', ');
    final row = <String, dynamic>{
      'event_type': 'merge',
      'file_count': fileCount,
      'file_names': names,
      'platform': kIsWeb ? 'web' : defaultTargetPlatform.name,
      'output_name': outputName,
      if (storagePath != null) 'storage_path': storagePath,
      if (fileUrl != null) 'file_url': fileUrl,
    };

    if (auth.isAuthenticated) {
      row['user_id'] = auth.user!.id;
    } else if (auth.guestId != null) {
      row['guest_id'] = auth.guestId;
    }

    final result = await _client.insert(MatuDbConfig.tableDownloads, row);
    if (!result.isSuccess) {
      if (kDebugMode) debugPrint('MergeHistoryRepository insert: ${result.error}');
      return MatuDbResult(error: result.error);
    }

    return const MatuDbResult(data: null);
  }

  Future<MatuDbResult<List<MergeHistoryEntry>>> fetchForUser(String userId) async {
    if (!MatuDbConfig.isConfigured) {
      return const MatuDbResult(error: 'MatuDB no configurado');
    }

    final result = await _client.select(
      MatuDbConfig.tableDownloads,
      eqFilters: {'user_id': userId},
      orderBy: 'created_at',
      ascending: false,
      limit: 50,
    );

    if (!result.isSuccess) {
      return MatuDbResult(error: result.error);
    }

    final entries = (result.data ?? []).map(_mapEntry).toList();
    return MatuDbResult(data: entries);
  }

  MergeHistoryEntry _mapEntry(Map<String, dynamic> row) {
    final createdRaw = row['created_at'];
    DateTime? createdAt;
    if (createdRaw is String) {
      createdAt = DateTime.tryParse(createdRaw);
    }

    return MergeHistoryEntry(
      id: row['id'] is int ? row['id'] as int : int.tryParse('${row['id']}') ?? 0,
      fileCount: row['file_count'] is int
          ? row['file_count'] as int
          : int.tryParse('${row['file_count']}') ?? 1,
      fileNames: row['file_names'] as String?,
      createdAt: createdAt,
      fileUrl: row['file_url'] as String?,
      outputName: row['output_name'] as String?,
    );
  }
}
