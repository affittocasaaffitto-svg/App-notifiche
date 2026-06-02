import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

/// Genera dati di esempio realistici per la preview e il primo avvio.
class SampleData {
  static List<AppNotification> notifications() {
    final now = DateTime.now();
    int i = 0;
    String id() => 'n${i++}';

    return [
      AppNotification(
        id: id(),
        appName: 'WhatsApp',
        appIcon: '💬',
        appColor: const Color(0xFF25D366),
        sender: 'Mamma',
        text: 'Ci vediamo a pranzo domenica? Porto il dolce 🍰',
        time: now.subtract(const Duration(minutes: 3)),
        tag: AiTag.person,
        category: NotifCategory.family,
        isImportant: true,
      ),
      AppNotification(
        id: id(),
        appName: 'Gmail',
        appIcon: '📧',
        appColor: const Color(0xFFEA4335),
        sender: 'Banca Intesa',
        text: 'Codice OTP per accesso: 884213. Non condividerlo con nessuno.',
        time: now.subtract(const Duration(minutes: 8)),
        tag: AiTag.high,
        category: NotifCategory.important,
        isImportant: true,
      ),
      AppNotification(
        id: id(),
        appName: 'Amazon',
        appIcon: '🛒',
        appColor: const Color(0xFFFF9900),
        sender: 'Amazon Offerte',
        text: 'Sconto del 40% solo per oggi! Approfitta dei saldi lampo 🔥',
        time: now.subtract(const Duration(minutes: 12)),
        tag: AiTag.promo,
        category: NotifCategory.silenced,
        isSilenced: true,
      ),
      AppNotification(
        id: id(),
        appName: 'Slack',
        appIcon: '💼',
        appColor: const Color(0xFF4A154B),
        sender: 'Team Marketing',
        text: 'Marco: la riunione è spostata alle 15:00, importante esserci',
        time: now.subtract(const Duration(minutes: 18)),
        tag: AiTag.high,
        category: NotifCategory.work,
        isImportant: true,
      ),
      AppNotification(
        id: id(),
        appName: 'WhatsApp',
        appIcon: '💬',
        appColor: const Color(0xFF25D366),
        sender: 'Gruppo Famiglia 🏠',
        text: 'Luca: Qualcuno ha visto le mie chiavi? 😅',
        time: now.subtract(const Duration(minutes: 25)),
        tag: AiTag.group,
        category: NotifCategory.family,
      ),
      AppNotification(
        id: id(),
        appName: 'Instagram',
        appIcon: '📸',
        appColor: const Color(0xFFE1306C),
        sender: 'Instagram',
        text: 'Hai 3 nuove notifiche dai tuoi amici',
        time: now.subtract(const Duration(minutes: 34)),
        tag: AiTag.low,
        category: NotifCategory.all,
      ),
      AppNotification(
        id: id(),
        appName: 'Telegram',
        appIcon: '✈️',
        appColor: const Color(0xFF229ED9),
        sender: 'Gruppo Lavoro',
        text: 'Giulia: Ho caricato i file sul drive, controllate per favore',
        time: now.subtract(const Duration(minutes: 47)),
        tag: AiTag.group,
        category: NotifCategory.work,
      ),
      AppNotification(
        id: id(),
        appName: 'SHEIN',
        appIcon: '👗',
        appColor: const Color(0xFF222222),
        sender: 'SHEIN',
        text: 'Spedizione gratis sul tuo prossimo ordine! Coupon esclusivo 🎁',
        time: now.subtract(const Duration(hours: 1, minutes: 5)),
        tag: AiTag.promo,
        category: NotifCategory.silenced,
        isSilenced: true,
      ),
      AppNotification(
        id: id(),
        appName: 'Messaggi',
        appIcon: '💌',
        appColor: const Color(0xFF34C759),
        sender: 'Papà',
        text: 'Tutto ok? Chiamami quando puoi',
        time: now.subtract(const Duration(hours: 1, minutes: 20)),
        tag: AiTag.person,
        category: NotifCategory.family,
        isImportant: true,
      ),
      AppNotification(
        id: id(),
        appName: 'Outlook',
        appIcon: '📨',
        appColor: const Color(0xFF0078D4),
        sender: 'HR Aziendale',
        text: 'Promemoria: scadenza consegna report trimestrale venerdì',
        time: now.subtract(const Duration(hours: 2)),
        tag: AiTag.high,
        category: NotifCategory.work,
      ),
      AppNotification(
        id: id(),
        appName: 'YouTube',
        appIcon: '▶️',
        appColor: const Color(0xFFFF0000),
        sender: 'YouTube',
        text: 'Un canale che segui ha pubblicato un nuovo video',
        time: now.subtract(const Duration(hours: 2, minutes: 30)),
        tag: AiTag.low,
        category: NotifCategory.all,
      ),
      AppNotification(
        id: id(),
        appName: 'Telegram',
        appIcon: '✈️',
        appColor: const Color(0xFF229ED9),
        sender: 'Sara',
        text: 'Hai tempo stasera per una chiamata veloce?',
        time: now.subtract(const Duration(hours: 3)),
        tag: AiTag.person,
        category: NotifCategory.important,
      ),
    ];
  }

  static List<NotifRule> rules() {
    final now = DateTime.now();
    return [
      NotifRule(
        id: 'r1',
        name: 'Silenzia promo Amazon',
        conditionType: RuleConditionType.app,
        conditionValue: 'Amazon',
        actionType: RuleActionType.silence,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      NotifRule(
        id: 'r2',
        name: 'Mamma sempre prioritaria',
        conditionType: RuleConditionType.contact,
        conditionValue: 'Mamma',
        actionType: RuleActionType.showNow,
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      NotifRule(
        id: 'r3',
        name: 'Lavoro nel riepilogo serale',
        conditionType: RuleConditionType.app,
        conditionValue: 'Slack',
        actionType: RuleActionType.addToSummary,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    ];
  }

  static List<FavoriteContact> contacts() {
    return [
      FavoriteContact(
          id: 'c1', name: 'Mamma', avatarEmoji: '👩', color: AppColors.catFamily),
      FavoriteContact(
          id: 'c2', name: 'Papà', avatarEmoji: '👨', color: AppColors.primary),
      FavoriteContact(
          id: 'c3', name: 'Sara', avatarEmoji: '👧', color: AppColors.secondary),
    ];
  }
}
