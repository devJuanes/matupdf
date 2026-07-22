import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/payments/payment_return_info.dart';
import '../../core/router/app_router.dart';
import '../auth/presentation/controllers/auth_controller.dart';
import 'data/donation_repository.dart';
import 'widgets/donation_thank_you_dialog.dart';

/// Detecta el retorno de PayMatuByte y muestra el modal de agradecimiento.
class TipReturnScope extends StatefulWidget {
  const TipReturnScope({super.key, required this.child});

  final Widget child;

  @override
  State<TipReturnScope> createState() => _TipReturnScopeState();
}

class _TipReturnScopeState extends State<TipReturnScope> {
  static final _handledReferences = <String>{};
  final _repo = DonationRepository();
  Uri? _lastUri;

  @override
  void initState() {
    super.initState();
    AppRouter.router.routerDelegate.addListener(_onRouteChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onRouteChanged());
  }

  @override
  void dispose() {
    AppRouter.router.routerDelegate.removeListener(_onRouteChanged);
    super.dispose();
  }

  void _onRouteChanged() {
    final uri = AppRouter.router.routerDelegate.currentConfiguration.uri;
    if (uri == _lastUri) return;
    _lastUri = uri;
    _handleUri(uri);
  }

  Future<void> _handleUri(Uri uri) async {
    final info = PaymentReturnInfo.fromQuery(uri.queryParameters);
    if (info == null) return;

    final refKey = info.reference.isNotEmpty ? info.reference : uri.toString();
    if (_handledReferences.contains(refKey)) {
      _stripQueryParams(uri);
      return;
    }
    _handledReferences.add(refKey);

    final auth = context.read<AuthController>();
    await _repo.recordPaymentReturn(
      info: info,
      userId: auth.user?.id,
      sourcePage: uri.path,
    );

    if (!mounted) return;
    _stripQueryParams(uri);

    if (info.isPaid) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        DonationThankYouDialog.show(context, info);
      });
    }
  }

  void _stripQueryParams(Uri uri) {
    if (uri.queryParameters.isEmpty) return;
    final clean = uri.replace(queryParameters: {});
    if (clean.toString() != uri.toString()) {
      AppRouter.router.go(clean.path.isEmpty ? '/' : clean.path);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
