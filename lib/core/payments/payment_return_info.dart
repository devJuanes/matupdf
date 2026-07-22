class PaymentReturnInfo {
  const PaymentReturnInfo({
    required this.reference,
    required this.status,
    required this.isPaid,
    this.transactionId,
    this.linkId,
    this.amountCop,
    this.isTipReturn = false,
  });

  final String reference;
  final String status;
  final bool isPaid;
  final String? transactionId;
  final String? linkId;
  final int? amountCop;
  final bool isTipReturn;

  static PaymentReturnInfo? fromQuery(Map<String, String> params) {
    final isTip = params['tip'] == 'thanks';
    final reference = params['reference'] ?? '';
    final status = params['status'] ?? '';
    final paidParam = (params['paid'] ?? '').toLowerCase();
    final hasPaymentParams = reference.isNotEmpty || status.isNotEmpty || paidParam.isNotEmpty;

    if (!isTip && !hasPaymentParams) return null;

    final normalizedStatus = status.toUpperCase();
    final isPaid = paidParam == 'true' ||
        normalizedStatus == 'PAID' ||
        normalizedStatus.contains('APPROVED') ||
        normalizedStatus.contains('APROBAD');

    final amount = int.tryParse(params['amount'] ?? '');

    return PaymentReturnInfo(
      reference: reference,
      status: status.isNotEmpty ? status : (isPaid ? 'PAID' : 'PENDING'),
      isPaid: isPaid,
      transactionId: params['transaction_id'],
      linkId: params['link_id'],
      amountCop: amount,
      isTipReturn: isTip,
    );
  }
}
