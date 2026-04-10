import 'package:url_launcher/url_launcher.dart';

/// Otwiera URL w przeglądarce / aplikacji zewnętrznej. Zwraca false przy błędzie.
Future<bool> launchLegalUrl(String url) async {
  final uri = Uri.tryParse(url.trim());
  if (uri == null || !uri.hasScheme) return false;
  if (uri.scheme != 'https' && uri.scheme != 'http') return false;
  try {
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    return false;
  }
}
