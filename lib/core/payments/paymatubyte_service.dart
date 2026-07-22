import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/app_constants.dart';
import 'paymatubyte_config.dart';

class PayMatuByteService {
  PayMatuByteService._();

  static Future<String> createVoluntaryTipLink({
    required int amountCop,
    String? description,
  }) async {
    if (!PayMatuByteConfig.isConfigured) {
      throw StateError('PayMatuByte no está configurado');
    }
    if (amountCop < 1000) {
      throw ArgumentError('El monto mínimo es \$1.000 COP');
    }

    final uri = Uri.parse('${PayMatuByteConfig.baseUrl}/v1/payment');
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${PayMatuByteConfig.apiKey}',
      },
      body: jsonEncode({
        'amount': amountCop,
        'currency': 'COP',
        'description':
            description ?? 'Apoyo voluntario a ${AppConstants.appName}',
        'returnUrl': '${AppConstants.siteUrl}/combinar?tip=thanks',
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('No se pudo iniciar el pago (${response.statusCode})');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final url = data['url'] ??
        data['payment_url'] ??
        (data['data'] is Map ? (data['data'] as Map)['url'] : null);

    if (url is! String || url.isEmpty) {
      throw Exception('Respuesta de pago sin URL');
    }
    return url;
  }
}
