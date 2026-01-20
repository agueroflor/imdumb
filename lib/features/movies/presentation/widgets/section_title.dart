import 'package:flutter/material.dart';

/// Widget reutilizable para títulos de secciones
///
/// Muestra un título con estilo destacado y opcionalmente un botón de acción.
/// Usado en pantallas de categorías, favoritos, etc.
class SectionTitle extends StatelessWidget {
  final String title;
  final VoidCallback? onActionPressed;
  final String? actionText;

  const SectionTitle({
    super.key,
    required this.title,
    this.onActionPressed,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          if (onActionPressed != null)
            TextButton(
              onPressed: onActionPressed,
              child: Text(actionText ?? 'Ver más'),
            ),
        ],
      ),
    );
  }
}
