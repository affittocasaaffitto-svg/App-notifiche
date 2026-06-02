import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';
import 'sample_data.dart';
import 'ai_classifier.dart';

/// Stato globale dell'app gestito con Provider + persistenza Hive.
class AppState extends ChangeNotifier {
  static const _notifBox = 'notifications';
  static const _ruleBox = 'rules';
  static const _contactBox = 'contacts';
  static const _settingsBox = 'settings';

  final List<AppNotification> _notifications = [];
  final List<NotifRule> _rules = [];
  final List<FavoriteContact> _contacts = [];

  bool listenerPermissionGranted = false;
  bool focusModeOn = false;
  int focusDurationMin = 30;
  bool focusAllowFamily = true;
  bool focusAllowWork = true;
  bool focusAllowFavorites = true;
  int summaryIntervalMin = 60;
  ThemeMode themeMode = ThemeMode.system;

  List<AppNotification> get notifications => _notifications;
  List<NotifRule> get rules => _rules;
  List<FavoriteContact> get contacts => _contacts;

  Future<void> init() async {
    await Hive.initFlutter();
    final nBox = await Hive.openBox(_notifBox);
    final rBox = await Hive.openBox(_ruleBox);
    final cBox = await Hive.openBox(_contactBox);
    final sBox = await Hive.openBox(_settingsBox);

    // Carica impostazioni
    listenerPermissionGranted =
        sBox.get('listenerPermissionGranted', defaultValue: false) as bool;
    focusModeOn = sBox.get('focusModeOn', defaultValue: false) as bool;
    focusDurationMin = sBox.get('focusDurationMin', defaultValue: 30) as int;
    focusAllowFamily = sBox.get('focusAllowFamily', defaultValue: true) as bool;
    focusAllowWork = sBox.get('focusAllowWork', defaultValue: true) as bool;
    focusAllowFavorites =
        sBox.get('focusAllowFavorites', defaultValue: true) as bool;
    summaryIntervalMin = sBox.get('summaryIntervalMin', defaultValue: 60) as int;
    final tm = sBox.get('themeMode', defaultValue: 'system') as String;
    themeMode = _parseThemeMode(tm);

    // Carica o inizializza dati
    if (nBox.isEmpty) {
      for (final n in SampleData.notifications()) {
        await nBox.put(n.id, n.toMap());
      }
    }
    if (rBox.isEmpty) {
      for (final r in SampleData.rules()) {
        await rBox.put(r.id, r.toMap());
      }
    }
    if (cBox.isEmpty) {
      for (final c in SampleData.contacts()) {
        await cBox.put(c.id, c.toMap());
      }
    }

    _notifications
      ..clear()
      ..addAll(nBox.values.map((e) => AppNotification.fromMap(e as Map)));
    _notifications.sort((a, b) => b.time.compareTo(a.time));

    _rules
      ..clear()
      ..addAll(rBox.values.map((e) => NotifRule.fromMap(e as Map)));
    _rules.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    _contacts
      ..clear()
      ..addAll(cBox.values.map((e) => FavoriteContact.fromMap(e as Map)));

    notifyListeners();
  }

  ThemeMode _parseThemeMode(String s) {
    switch (s) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  // ---------- Notifiche ----------

  List<AppNotification> byCategory(NotifCategory cat) {
    if (cat == NotifCategory.all) {
      return _notifications.where((n) => !n.isSilenced).toList();
    }
    if (cat == NotifCategory.silenced) {
      return _notifications.where((n) => n.isSilenced).toList();
    }
    if (cat == NotifCategory.important) {
      return _notifications
          .where((n) => n.isImportant || n.tag == AiTag.high)
          .toList();
    }
    return _notifications
        .where((n) => n.category == cat && !n.isSilenced)
        .toList();
  }

  Future<void> markImportant(AppNotification n, bool value) async {
    n.isImportant = value;
    if (value) n.isSilenced = false;
    await _saveNotif(n);
    notifyListeners();
  }

  Future<void> silence(AppNotification n) async {
    n.isSilenced = true;
    n.isImportant = false;
    await _saveNotif(n);
    notifyListeners();
  }

  Future<void> unsilence(AppNotification n) async {
    n.isSilenced = false;
    await _saveNotif(n);
    notifyListeners();
  }

  Future<void> snooze(AppNotification n, int minutes) async {
    n.snoozedMinutes = minutes;
    await _saveNotif(n);
    notifyListeners();
  }

  Future<void> remove(AppNotification n) async {
    _notifications.removeWhere((x) => x.id == n.id);
    final box = Hive.box(_notifBox);
    await box.delete(n.id);
    notifyListeners();
  }

  Future<void> markRead(AppNotification n) async {
    if (!n.isRead) {
      n.isRead = true;
      await _saveNotif(n);
      notifyListeners();
    }
  }

  Future<void> _saveNotif(AppNotification n) async {
    final box = Hive.box(_notifBox);
    await box.put(n.id, n.toMap());
  }

  /// Simula l'arrivo di una nuova notifica classificata dall'AI
  Future<void> addIncoming(
      {required String appName,
      required String appIcon,
      required Color appColor,
      required String sender,
      required String text}) async {
    final (tag, cat) = AiClassifier.classify(
      appName: appName,
      sender: sender,
      text: text,
      familyContacts: _contacts.map((c) => c.name).toList(),
      workApps: const ['Slack', 'Outlook', 'Teams'],
    );
    final n = AppNotification(
      id: 'n${DateTime.now().millisecondsSinceEpoch}',
      appName: appName,
      appIcon: appIcon,
      appColor: appColor,
      sender: sender,
      text: text,
      time: DateTime.now(),
      tag: tag,
      category: cat,
      isImportant: tag == AiTag.high,
      isSilenced: tag == AiTag.promo,
    );
    _notifications.insert(0, n);
    await _saveNotif(n);
    notifyListeners();
  }

  int get unreadImportant =>
      byCategory(NotifCategory.important).where((n) => !n.isRead).length;

  // ---------- Regole ----------

  Future<void> saveRule(NotifRule rule) async {
    final idx = _rules.indexWhere((r) => r.id == rule.id);
    if (idx >= 0) {
      _rules[idx] = rule;
    } else {
      _rules.insert(0, rule);
    }
    final box = Hive.box(_ruleBox);
    await box.put(rule.id, rule.toMap());
    notifyListeners();
  }

  Future<void> deleteRule(NotifRule rule) async {
    _rules.removeWhere((r) => r.id == rule.id);
    final box = Hive.box(_ruleBox);
    await box.delete(rule.id);
    notifyListeners();
  }

  Future<void> toggleRule(NotifRule rule, bool enabled) async {
    rule.enabled = enabled;
    await saveRule(rule);
  }

  // ---------- Impostazioni ----------

  Future<void> _saveSetting(String key, dynamic value) async {
    final box = Hive.box(_settingsBox);
    await box.put(key, value);
  }

  Future<void> grantPermission() async {
    listenerPermissionGranted = true;
    await _saveSetting('listenerPermissionGranted', true);
    notifyListeners();
  }

  Future<void> setFocusMode(bool on) async {
    focusModeOn = on;
    await _saveSetting('focusModeOn', on);
    notifyListeners();
  }

  Future<void> setFocusDuration(int min) async {
    focusDurationMin = min;
    await _saveSetting('focusDurationMin', min);
    notifyListeners();
  }

  Future<void> setFocusException(String type, bool value) async {
    switch (type) {
      case 'family':
        focusAllowFamily = value;
        await _saveSetting('focusAllowFamily', value);
        break;
      case 'work':
        focusAllowWork = value;
        await _saveSetting('focusAllowWork', value);
        break;
      case 'favorites':
        focusAllowFavorites = value;
        await _saveSetting('focusAllowFavorites', value);
        break;
    }
    notifyListeners();
  }

  Future<void> setSummaryInterval(int min) async {
    summaryIntervalMin = min;
    await _saveSetting('summaryIntervalMin', min);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode = mode;
    await _saveSetting('themeMode', mode.name);
    notifyListeners();
  }

  // ---------- Statistiche ----------

  /// Conteggio notifiche per app
  Map<String, int> notifPerApp() {
    final map = <String, int>{};
    for (final n in _notifications) {
      map[n.appName] = (map[n.appName] ?? 0) + 1;
    }
    return map;
  }

  /// Punteggio stress per app (media)
  Map<String, double> stressPerApp() {
    final sums = <String, double>{};
    final counts = <String, int>{};
    for (final n in _notifications) {
      sums[n.appName] = (sums[n.appName] ?? 0) + AiClassifier.stressScore(n);
      counts[n.appName] = (counts[n.appName] ?? 0) + 1;
    }
    final result = <String, double>{};
    sums.forEach((k, v) => result[k] = v / counts[k]!);
    return result;
  }

  /// Notifiche per fascia oraria (0-23)
  List<int> notifPerHour() {
    final hours = List<int>.filled(24, 0);
    for (final n in _notifications) {
      hours[n.time.hour]++;
    }
    return hours;
  }

  int get filteredCount =>
      _notifications.where((n) => n.isSilenced).length;

  int get summaryCount =>
      _notifications.where((n) => n.isSilenced || n.tag == AiTag.low).length;

  List<AppNotification> get summaryNotifications =>
      _notifications.where((n) => n.isSilenced || n.tag == AiTag.low).toList();
}
