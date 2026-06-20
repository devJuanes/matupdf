import '../constants/app_constants.dart';

class RouteHelpers {
  RouteHelpers._();

  static String account({
    String? redirect,
    bool register = false,
    bool mergeAfterAuth = false,
  }) {
    final params = <String, String>{};
    if (redirect != null && redirect.isNotEmpty) {
      params['redirect'] = redirect;
    }
    if (register) params['registro'] = '1';
    if (mergeAfterAuth) params['merge'] = '1';
    if (params.isEmpty) return AppRoutes.account;
    return Uri(path: AppRoutes.account, queryParameters: params).toString();
  }
}
