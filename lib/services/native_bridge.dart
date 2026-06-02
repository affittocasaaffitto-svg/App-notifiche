import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'app_state.dart';

/// Ponte tra il NotificationListenerService nativo Android e Flutter.
/// Su Web o piattaforme non supportate degrada silenziosamente (no-op),
/// così la preview funziona con i dati di esempio.
class NativeBridge {
  static const _method = MethodChannel('com.supernotify/notifications');
  static const _events = EventChannel('com.supernotify/notification_stream');

  static bool get _supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// Verifica se l'accesso alle notifiche è concesso a livello di sistema.
  static Future<bool> isPermissionGranted() async {
    if (!_supported) return false;
    try {
      return await _method.invokeMethod<bool>('isPermissionGranted') ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Apre le Impostazioni di sistema per l'accesso alle notifiche.
  static Future<void> openSettings() async {
    if (!_supported) return;
    try {
      await _method.invokeMethod('openSettings');
    } catch (_) {}
  }

  /// Avvia l'ascolto delle notifiche reali e le inoltra all'AppState.
  static void startListening(AppState state) {
    if (!_supported) return;
    try {
      _events.receiveBroadcastStream().listen((event) {
        if (event is Map) {
          final pkg = (event['package'] ?? '').toString();
          final title = (event['title'] ?? '').toString();
          final text = (event['text'] ?? '').toString();
          state.addIncoming(
            appName: _appNameFromPackage(pkg),
            appIcon: _iconFromPackage(pkg),
            appColor: _colorFromPackage(pkg),
            sender: title.isNotEmpty ? title : _appNameFromPackage(pkg),
            text: text,
          );
        }
      });
    } catch (_) {}
  }

  static String _appNameFromPackage(String pkg) {
    final map = {
      'com.whatsapp': 'WhatsApp',
      'org.telegram.messenger': 'Telegram',
      'com.google.android.gm': 'Gmail',
      'com.instagram.android': 'Instagram',
      'com.facebook.katana': 'Facebook',
      'com.amazon.mShop.android.shopping': 'Amazon',
      'com.microsoft.office.outlook': 'Outlook',
      'com.Slack': 'Slack',
      'com.google.android.youtube': 'YouTube',
    };
    return map[pkg] ?? pkg.split('.').last;
  }

  static String _iconFromPackage(String pkg) {
    if (pkg.contains('whatsapp')) return '💬';
    if (pkg.contains('telegram')) return '✈️';
    if (pkg.contains('gm') || pkg.contains('mail')) return '📧';
    if (pkg.contains('instagram')) return '📸';
    if (pkg.contains('amazon')) return '🛒';
    if (pkg.contains('slack')) return '💼';
    if (pkg.contains('youtube')) return '▶️';
    return '🔔';
  }

  static Color _colorFromPackage(String pkg) {
    if (pkg.contains('whatsapp')) return const Color(0xFF25D366);
    if (pkg.contains('telegram')) return const Color(0xFF229ED9);
    if (pkg.contains('instagram')) return const Color(0xFFE1306C);
    if (pkg.contains('amazon')) return const Color(0xFFFF9900);
    return const Color(0xFF2D6FFF);
  }
}
