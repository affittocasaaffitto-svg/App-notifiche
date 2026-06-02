import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

/// Chip che mostra il tag AI con colore e icona
class AiTagChip extends StatelessWidget {
  final AiTag tag;
  final bool small;
  const AiTagChip({super.key, required this.tag, this.small = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: small ? 8 : 10, vertical: small ? 3 : 5),
      decoration: BoxDecoration(
        color: tag.color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(tag.icon, size: small ? 12 : 14, color: tag.color),
          const SizedBox(width: 4),
          Text(
            tag.label,
            style: TextStyle(
              color: tag.color,
              fontSize: small ? 10 : 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Avatar dell'app (emoji su sfondo colorato)
class AppAvatar extends StatelessWidget {
  final String emoji;
  final Color color;
  final double size;
  const AppAvatar(
      {super.key, required this.emoji, required this.color, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.85), color.withValues(alpha: 0.55)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.32),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(emoji, style: TextStyle(fontSize: size * 0.45)),
      ),
    );
  }
}

/// Pulsante con gradiente principale
class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool expanded;
  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final child = Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: BoxDecoration(
        gradient: AppColors.mainGradient,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 10),
          ],
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );

    return GestureDetector(
      onTap: onPressed,
      child: expanded
          ? SizedBox(width: double.infinity, child: child)
          : child,
    );
  }
}

/// Card con bordo gradiente sottile
class GradientCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const GradientCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: padding,
      child: child,
    );
  }
}

/// Formattazione orario relativo
String formatTime(DateTime time) {
  final now = DateTime.now();
  final diff = now.difference(time);
  if (diff.inMinutes < 1) return 'Ora';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min fa';
  if (diff.inHours < 24) return '${diff.inHours} h fa';
  return DateFormat('dd/MM HH:mm').format(time);
}
