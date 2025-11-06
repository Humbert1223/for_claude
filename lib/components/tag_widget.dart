import 'package:flutter/material.dart';

enum TagStyle {
  filled,      // Fond plein (défaut)
  outlined,    // Bordure uniquement
  soft,        // Fond léger avec texte coloré
  gradient,    // Dégradé
}

enum TagSize {
  small,
  medium,
  large,
}

class TagWidget extends StatelessWidget {
  final Widget title;
  final Color? color;
  final EdgeInsets? padding;
  final TagStyle style;
  final TagSize size;
  final IconData? icon;
  final bool showDot;
  final VoidCallback? onTap;
  final bool animated;

  const TagWidget({
    super.key,
    required this.title,
    this.color,
    this.padding,
    this.style = TagStyle.soft,
    this.size = TagSize.medium,
    this.icon,
    this.showDot = false,
    this.onTap,
    this.animated = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.primary;
    final effectivePadding = padding ?? _getPaddingForSize();

    Widget content = Container(
      padding: effectivePadding,
      decoration: _getDecoration(effectiveColor),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: _getContentColor(effectiveColor),
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: _getIconSpacing()),
          ],
          if (icon != null) ...[
            Icon(
              icon,
              size: _getIconSize(),
              color: _getContentColor(effectiveColor),
            ),
            SizedBox(width: _getIconSpacing()),
          ],
          DefaultTextStyle(
            style: TextStyle(
              color: _getContentColor(effectiveColor),
              fontSize: _getFontSize(),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
            child: title,
          ),
        ],
      ),
    );

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(_getBorderRadius()),
          child: content,
        ),
      );
    }

    if (animated) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: content,
      );
    }

    return content;
  }

  BoxDecoration _getDecoration(Color baseColor) {
    switch (style) {
      case TagStyle.filled:
        return BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(_getBorderRadius()),
          boxShadow: [
            BoxShadow(
              color: baseColor.withValues(alpha:0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        );

      case TagStyle.outlined:
        return BoxDecoration(
          color: Colors.transparent,
          border: Border.all(
            color: baseColor,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(_getBorderRadius()),
        );

      case TagStyle.soft:
        return BoxDecoration(
          color: baseColor.withValues(alpha:0.12),
          borderRadius: BorderRadius.circular(_getBorderRadius()),
          border: Border.all(
            color: baseColor.withValues(alpha:0.2),
            width: 1,
          ),
        );

      case TagStyle.gradient:
        return BoxDecoration(
          gradient: LinearGradient(
            colors: [
              baseColor,
              _darkenColor(baseColor, 0.15),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(_getBorderRadius()),
          boxShadow: [
            BoxShadow(
              color: baseColor.withValues(alpha:0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        );
    }
  }

  Color _getContentColor(Color baseColor) {
    switch (style) {
      case TagStyle.filled:
      case TagStyle.gradient:
        return Colors.white;
      case TagStyle.outlined:
      case TagStyle.soft:
        return baseColor;
    }
  }

  double _getBorderRadius() {
    switch (size) {
      case TagSize.small:
        return 6;
      case TagSize.medium:
        return 8;
      case TagSize.large:
        return 10;
    }
  }

  EdgeInsets _getPaddingForSize() {
    switch (size) {
      case TagSize.small:
        return const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
      case TagSize.medium:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
      case TagSize.large:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    }
  }

  double _getFontSize() {
    switch (size) {
      case TagSize.small:
        return 10;
      case TagSize.medium:
        return 12;
      case TagSize.large:
        return 14;
    }
  }

  double _getIconSize() {
    switch (size) {
      case TagSize.small:
        return 12;
      case TagSize.medium:
        return 14;
      case TagSize.large:
        return 16;
    }
  }

  double _getIconSpacing() {
    switch (size) {
      case TagSize.small:
        return 4;
      case TagSize.medium:
        return 6;
      case TagSize.large:
        return 8;
    }
  }

  Color _darkenColor(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }
}
