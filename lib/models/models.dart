import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Categorie principali delle notifiche (corrispondono ai tab della Home)
enum NotifCategory { all, important, family, work, silenced }

extension NotifCategoryX on NotifCategory {
  String get label {
    switch (this) {
      case NotifCategory.all:
        return 'Tutte';
      case NotifCategory.important:
        return 'Importanti';
      case NotifCategory.family:
        return 'Famiglia';
      case NotifCategory.work:
        return 'Lavoro';
      case NotifCategory.silenced:
        return 'Silenziate';
    }
  }

  IconData get icon {
    switch (this) {
      case NotifCategory.all:
        return Icons.all_inbox_rounded;
      case NotifCategory.important:
        return Icons.star_rounded;
      case NotifCategory.family:
        return Icons.favorite_rounded;
      case NotifCategory.work:
        return Icons.work_rounded;
      case NotifCategory.silenced:
        return Icons.notifications_off_rounded;
    }
  }
}

/// Tipo di tag generato dall'AI
enum AiTag { high, person, group, promo, low }

extension AiTagX on AiTag {
  String get label {
    switch (this) {
      case AiTag.high:
        return 'Alta priorità';
      case AiTag.person:
        return 'Persona';
      case AiTag.group:
        return 'Gruppo';
      case AiTag.promo:
        return 'Promozione';
      case AiTag.low:
        return 'Bassa priorità';
    }
  }

  Color get color {
    switch (this) {
      case AiTag.high:
        return AppColors.tagHigh;
      case AiTag.person:
        return AppColors.tagPerson;
      case AiTag.group:
        return AppColors.tagGroup;
      case AiTag.promo:
        return AppColors.tagPromo;
      case AiTag.low:
        return AppColors.tagLow;
    }
  }

  IconData get icon {
    switch (this) {
      case AiTag.high:
        return Icons.priority_high_rounded;
      case AiTag.person:
        return Icons.person_rounded;
      case AiTag.group:
        return Icons.groups_rounded;
      case AiTag.promo:
        return Icons.local_offer_rounded;
      case AiTag.low:
        return Icons.low_priority_rounded;
    }
  }

  static AiTag fromName(String name) =>
      AiTag.values.firstWhere((e) => e.name == name, orElse: () => AiTag.low);
}

/// Modello notifica
class AppNotification {
  final String id;
  final String appName;
  final String appIcon; // emoji o lettera per la preview
  final Color appColor;
  final String sender;
  final String text;
  final DateTime time;
  AiTag tag;
  NotifCategory category;
  bool isImportant;
  bool isSilenced;
  bool isRead;
  int? snoozedMinutes;

  AppNotification({
    required this.id,
    required this.appName,
    required this.appIcon,
    required this.appColor,
    required this.sender,
    required this.text,
    required this.time,
    required this.tag,
    required this.category,
    this.isImportant = false,
    this.isSilenced = false,
    this.isRead = false,
    this.snoozedMinutes,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'appName': appName,
        'appIcon': appIcon,
        'appColor': appColor.toARGB32(),
        'sender': sender,
        'text': text,
        'time': time.toIso8601String(),
        'tag': tag.name,
        'category': category.name,
        'isImportant': isImportant,
        'isSilenced': isSilenced,
        'isRead': isRead,
        'snoozedMinutes': snoozedMinutes,
      };

  factory AppNotification.fromMap(Map map) => AppNotification(
        id: map['id'] as String,
        appName: map['appName'] as String,
        appIcon: map['appIcon'] as String,
        appColor: Color(map['appColor'] as int),
        sender: map['sender'] as String,
        text: map['text'] as String,
        time: DateTime.parse(map['time'] as String),
        tag: AiTagX.fromName(map['tag'] as String? ?? 'low'),
        category: NotifCategory.values.firstWhere(
          (e) => e.name == (map['category'] as String? ?? 'all'),
          orElse: () => NotifCategory.all,
        ),
        isImportant: map['isImportant'] as bool? ?? false,
        isSilenced: map['isSilenced'] as bool? ?? false,
        isRead: map['isRead'] as bool? ?? false,
        snoozedMinutes: map['snoozedMinutes'] as int?,
      );
}

/// Tipo di condizione per le regole
enum RuleConditionType { app, contact, group, time, weekday }

extension RuleConditionTypeX on RuleConditionType {
  String get label {
    switch (this) {
      case RuleConditionType.app:
        return 'App specifica';
      case RuleConditionType.contact:
        return 'Contatto specifico';
      case RuleConditionType.group:
        return 'Gruppi';
      case RuleConditionType.time:
        return 'Orario';
      case RuleConditionType.weekday:
        return 'Giorno della settimana';
    }
  }

  IconData get icon {
    switch (this) {
      case RuleConditionType.app:
        return Icons.apps_rounded;
      case RuleConditionType.contact:
        return Icons.person_rounded;
      case RuleConditionType.group:
        return Icons.groups_rounded;
      case RuleConditionType.time:
        return Icons.schedule_rounded;
      case RuleConditionType.weekday:
        return Icons.calendar_today_rounded;
    }
  }
}

/// Tipo di azione per le regole
enum RuleActionType { showNow, delay, addToSummary, silence }

extension RuleActionTypeX on RuleActionType {
  String get label {
    switch (this) {
      case RuleActionType.showNow:
        return 'Mostra subito';
      case RuleActionType.delay:
        return 'Ritarda';
      case RuleActionType.addToSummary:
        return 'Inserisci nel riepilogo';
      case RuleActionType.silence:
        return 'Silenzia';
    }
  }

  IconData get icon {
    switch (this) {
      case RuleActionType.showNow:
        return Icons.visibility_rounded;
      case RuleActionType.delay:
        return Icons.snooze_rounded;
      case RuleActionType.addToSummary:
        return Icons.summarize_rounded;
      case RuleActionType.silence:
        return Icons.notifications_off_rounded;
    }
  }
}

/// Modello regola IF -> THEN
class NotifRule {
  final String id;
  String name;
  RuleConditionType conditionType;
  String conditionValue;
  RuleActionType actionType;
  int delayMinutes; // usato se actionType == delay
  bool enabled;
  DateTime createdAt;

  NotifRule({
    required this.id,
    required this.name,
    required this.conditionType,
    required this.conditionValue,
    required this.actionType,
    this.delayMinutes = 15,
    this.enabled = true,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'conditionType': conditionType.name,
        'conditionValue': conditionValue,
        'actionType': actionType.name,
        'delayMinutes': delayMinutes,
        'enabled': enabled,
        'createdAt': createdAt.toIso8601String(),
      };

  factory NotifRule.fromMap(Map map) => NotifRule(
        id: map['id'] as String,
        name: map['name'] as String,
        conditionType: RuleConditionType.values.firstWhere(
          (e) => e.name == map['conditionType'],
          orElse: () => RuleConditionType.app,
        ),
        conditionValue: map['conditionValue'] as String? ?? '',
        actionType: RuleActionType.values.firstWhere(
          (e) => e.name == map['actionType'],
          orElse: () => RuleActionType.showNow,
        ),
        delayMinutes: map['delayMinutes'] as int? ?? 15,
        enabled: map['enabled'] as bool? ?? true,
        createdAt: DateTime.parse(map['createdAt'] as String),
      );
}

/// Contatto preferito
class FavoriteContact {
  final String id;
  String name;
  String avatarEmoji;
  Color color;

  FavoriteContact({
    required this.id,
    required this.name,
    required this.avatarEmoji,
    required this.color,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'avatarEmoji': avatarEmoji,
        'color': color.toARGB32(),
      };

  factory FavoriteContact.fromMap(Map map) => FavoriteContact(
        id: map['id'] as String,
        name: map['name'] as String,
        avatarEmoji: map['avatarEmoji'] as String? ?? '🙂',
        color: Color(map['color'] as int),
      );
}
