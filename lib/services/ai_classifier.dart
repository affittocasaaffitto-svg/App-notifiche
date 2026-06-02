import '../models/models.dart';

/// Motore di classificazione AI euristica (offline).
/// Analizza app sorgente, mittente e testo per assegnare un tag AI
/// e una categoria, simulando il comportamento di un modello AI.
class AiClassifier {
  // Parole chiave per categoria promozionale
  static const _promoKeywords = [
    'offerta', 'sconto', 'saldi', 'promo', 'gratis', '%', 'coupon',
    'spedizione', 'acquista', 'compra', 'black friday', 'occasione',
    'newsletter', 'iscriviti', 'ultimo giorno', 'risparmia', 'omaggio'
  ];

  // Parole chiave ad alta priorità
  static const _highKeywords = [
    'urgente', 'importante', 'subito', 'scadenza', 'pagamento',
    'codice', 'otp', 'verifica', 'accesso', 'sicurezza', 'allarme',
    'emergenza', 'banca', 'bonifico', 'fattura', 'riunione', 'meeting',
    'deadline', 'consegna', 'appuntamento'
  ];

  // App tipicamente di messaggistica/persone
  static const _messagingApps = [
    'whatsapp', 'telegram', 'messenger', 'messaggi', 'sms',
    'signal', 'gmail', 'email', 'mail', 'outlook'
  ];

  // App social/promozionali
  static const _socialPromoApps = [
    'instagram', 'facebook', 'tiktok', 'amazon', 'shop', 'store',
    'youtube', 'shein', 'temu', 'aliexpress', 'subito', 'wish'
  ];

  /// Classifica una notifica e ritorna tag + categoria suggerita.
  static (AiTag, NotifCategory) classify({
    required String appName,
    required String sender,
    required String text,
    List<String> familyContacts = const [],
    List<String> workApps = const [],
  }) {
    final app = appName.toLowerCase();
    final body = text.toLowerCase();
    final from = sender.toLowerCase();

    final isGroup = _looksLikeGroup(sender, text);

    // 1) Promozioni: app social/shop o keyword promozionali
    final promoScore = _countKeywords(body, _promoKeywords);
    final isPromoApp = _socialPromoApps.any((a) => app.contains(a));
    if (promoScore >= 1 || (isPromoApp && promoScore == 0 && !isGroup)) {
      // distinguiamo social puro da shop promozionale
      if (promoScore >= 1 || isPromoApp) {
        return (AiTag.promo, NotifCategory.silenced);
      }
    }

    // 2) Alta priorità: keyword forti
    final highScore = _countKeywords(body, _highKeywords);
    if (highScore >= 1) {
      // Se proviene da app di lavoro -> categoria Lavoro
      final cat = workApps.any((w) => app.contains(w.toLowerCase()))
          ? NotifCategory.work
          : NotifCategory.important;
      return (AiTag.high, cat);
    }

    // 3) Gruppo
    if (isGroup) {
      return (AiTag.group, NotifCategory.all);
    }

    // 4) Persona (messaggistica diretta)
    final isMsgApp = _messagingApps.any((a) => app.contains(a));
    if (isMsgApp) {
      // Famiglia?
      if (familyContacts.any((c) => from.contains(c.toLowerCase()))) {
        return (AiTag.person, NotifCategory.family);
      }
      // Lavoro?
      if (workApps.any((w) => app.contains(w.toLowerCase()))) {
        return (AiTag.person, NotifCategory.work);
      }
      return (AiTag.person, NotifCategory.important);
    }

    // 5) Default: bassa priorità
    return (AiTag.low, NotifCategory.all);
  }

  static bool _looksLikeGroup(String sender, String text) {
    final s = sender.toLowerCase();
    if (s.contains('gruppo') || s.contains('group') || s.contains('team')) {
      return true;
    }
    // Pattern "Nome: messaggio" tipico dei gruppi
    if (RegExp(r'^[A-Za-zÀ-ÿ ]+:\s').hasMatch(text) &&
        (s.contains('famiglia') || s.contains('amici') || s.contains('🏠'))) {
      return true;
    }
    return false;
  }

  static int _countKeywords(String text, List<String> keywords) {
    int count = 0;
    for (final k in keywords) {
      if (text.contains(k)) count++;
    }
    return count;
  }

  /// Restituisce un punteggio di "stress" 0-100 per una notifica,
  /// usato nelle statistiche emotive.
  static double stressScore(AppNotification n) {
    switch (n.tag) {
      case AiTag.high:
        return 85;
      case AiTag.group:
        return 55;
      case AiTag.person:
        return 40;
      case AiTag.promo:
        return 70; // le promo sono percepite come fastidiose
      case AiTag.low:
        return 20;
    }
  }
}
