import '../../../core/matudb/matudb_client.dart';
import '../../../core/matudb/matudb_config.dart';
import '../../../core/matudb/matudb_result.dart';

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
