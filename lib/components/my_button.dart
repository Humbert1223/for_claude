import 'package:flutter/material.dart';

/// Types de couleurs prédéfinies pour les boutons
enum ButtonColorType {
  primary,    // Couleur principale du thème
  success,    // Vert pour actions positives
  danger,     // Rouge pour actions destructives
  warning,    // Orange pour avertissements
  info,       // Bleu pour informations
  secondary,  // Gris pour actions secondaires
}

class MyButton extends StatelessWidget {
  final String buttonText;
  final double? heightBtn;
  final double? widthBtn;
  final VoidCallback? onTap;
  final bool isLoading;
  final IconData? icon;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? textColor;
  final ButtonColorType colorType;

  const MyButton({
    super.key,
    required this.onTap,
    required this.buttonText,
    this.heightBtn,
    this.widthBtn,
    this.isLoading = false,
    this.icon,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
    this.colorType = ButtonColorType.primary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Obtenir la couleur selon le type
    final buttonColor = _getColorFromType(context, colorType);

    // Couleurs adaptatives
    final effectiveBackgroundColor = backgroundColor ??
        (isOutlined ? Colors.transparent : buttonColor);
    final effectiveTextColor = textColor ??
        (isOutlined ? buttonColor : Colors.white);

    // Désactiver le bouton si loading ou onTap null
    final isDisabled = onTap == null || isLoading;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: buttonColor.withValues(alpha:0.2),
          highlightColor: buttonColor.withValues(alpha:0.1),
          child: Ink(
            height: heightBtn ?? 56,
            width: widthBtn ?? double.infinity,
            decoration: BoxDecoration(
              color: isDisabled
                  ? (isDark ? colorScheme.surfaceContainerHighest : Colors.grey.shade300)
                  : effectiveBackgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: isOutlined
                  ? Border.all(
                color: isDisabled
                    ? Colors.grey.shade400
                    : buttonColor,
                width: 2,
              )
                  : null,
              boxShadow: !isOutlined && !isDisabled
                  ? [
                BoxShadow(
                  color: buttonColor.withValues(alpha:0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
                  : null,
            ),
            child: Center(
              child: isLoading
                  ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isOutlined ? buttonColor : Colors.white,
                  ),
                ),
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      color: isDisabled
                          ? Colors.grey.shade600
                          : effectiveTextColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      buttonText,
                      style: TextStyle(
                        color: isDisabled
                            ? Colors.grey.shade600
                            : effectiveTextColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Obtient la couleur selon le type de bouton
  Color _getColorFromType(BuildContext context, ButtonColorType type) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (type) {
      case ButtonColorType.primary:
        return colorScheme.primary;
      case ButtonColorType.success:
        return isDark ? const Color(0xff4caf50) : const Color(0xff2e7d32);
      case ButtonColorType.danger:
        return isDark ? const Color(0xfff44336) : const Color(0xffc62828);
      case ButtonColorType.warning:
        return isDark ? const Color(0xffff9800) : const Color(0xffe65100);
      case ButtonColorType.info:
        return isDark ? const Color(0xff2196f3) : const Color(0xff1565c0);
      case ButtonColorType.secondary:
        return isDark ? const Color(0xff757575) : const Color(0xff616161);
    }
  }
}

/// Bouton secondaire (outlined)
class MyOutlinedButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback? onTap;
  final double? heightBtn;
  final double? widthBtn;
  final IconData? icon;
  final bool isLoading;
  final ButtonColorType colorType;

  const MyOutlinedButton({
    super.key,
    required this.buttonText,
    required this.onTap,
    this.heightBtn,
    this.widthBtn,
    this.icon,
    this.isLoading = false,
    this.colorType = ButtonColorType.primary,
  });

  @override
  Widget build(BuildContext context) {
    return MyButton(
      buttonText: buttonText,
      onTap: onTap,
      heightBtn: heightBtn,
      widthBtn: widthBtn,
      icon: icon,
      isLoading: isLoading,
      isOutlined: true,
      colorType: colorType,
    );
  }
}

/// Bouton texte simple
class MyTextButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback? onTap;
  final IconData? icon;

  const MyTextButton({
    super.key,
    required this.buttonText,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDisabled = onTap == null;

    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20),
            const SizedBox(width: 8),
          ],
          Text(
            buttonText,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: isDisabled ? Colors.grey : null,
            ),
          ),
        ],
      ),
    );
  }
}