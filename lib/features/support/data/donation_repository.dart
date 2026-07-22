import '../../../core/matudb/matudb_client.dart';
import '../../../core/matudb/matudb_config.dart';
import '../../../core/matudb/matudb_result.dart';
import '../../../core/payments/payment_return_info.dart';

class DonationRepository {
  DonationRepository({MatuDbClient? client}) : _client = client ?? MatuDbClient();

  final MatuDbClient _client;

  Future<MatuDbResult<void>> recordPaymentReturn({
    required PaymentReturnInfo info,
    String? userId,
    String? sourcePage,
  }) async {
    if (!MatuDbConfig.isConfigured) {
      return const MatuDbResult(error: 'MatuDB no configurado');
    }
    if (info.reference.isEmpty) {
      return const MatuDbResult(error: 'Referencia de pago vacía');
    }

    final existing = await _client.select(
      MatuDbConfig.tableDonations,
      eqFilters: {'payment_reference': info.reference},
      limit: 1,
    );

    if (existing.isSuccess && (existing.data?.isNotEmpty ?? false)) {
      return const MatuDbResult(data: null);
    }

    final result = await _client.insert(MatuDbConfig.tableDonations, {
      'payment_reference': info.reference,
      if (info.linkId != null) 'link_id': info.linkId,
      if (info.transactionId != null) 'transaction_id': info.transactionId,
      'payment_status': info.status,
      'is_paid': info.isPaid,
      if (info.amountCop != null) 'amount_cop': info.amountCop,
      if (userId != null) 'user_id': userId,
      if (sourcePage != null) 'source_page': sourcePage,
    });

    if (!result.isSuccess) {
      return MatuDbResult(error: result.error);
    }
    return const MatuDbResult(data: null);
  }

  Future<MatuDbResult<void>> saveGreetingEmail({
    required String reference,
    required String email,
    String? userId,
  }) async {
    if (!MatuDbConfig.isConfigured) {
      return const MatuDbResult(error: 'MatuDB no configurado');
    }

    final trimmed = email.trim();
    if (trimmed.isEmpty || !trimmed.contains('@')) {
      return const MatuDbResult(error: 'Correo inválido');
    }

    final result = await _client.update(
      MatuDbConfig.tableDonations,
      {
        'email': trimmed,
        'wants_greeting': true,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
        if (userId != null) 'user_id': userId,
      },
      filters: {'payment_reference': reference},
    );

    if (!result.isSuccess) {
      return MatuDbResult(error: result.error);
    }
    return const MatuDbResult(data: null);
  }
}
