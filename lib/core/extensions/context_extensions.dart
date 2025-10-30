import 'package:flutter/material.dart';

/// Extensions utiles pour BuildContext
/// Simplifie l'accès aux propriétés du thème et à la navigation
extension BuildContextExtensions on BuildContext {
  // ==================== THEME ====================

  /// Accès rapide au ThemeData
  ThemeData get theme => Theme.of(this);

  /// Accès rapide au ColorScheme
  ColorScheme get colors => theme.colorScheme;

  /// Accès rapide au TextTheme
  TextTheme get textTheme => theme.textTheme;

  /// Vérifie si le thème est en mode sombre
  bool get isDarkMode => theme.brightness == Brightness.dark;

  // ==================== DIMENSIONS ====================

  /// Largeur de l'écran
  double get width => MediaQuery.of(this).size.width;

  /// Hauteur de l'écran
  double get height => MediaQuery.of(this).size.height;

  /// Orientation de l'écran
  Orientation get orientation => MediaQuery.of(this).orientation;

  /// Vérifie si l'écran est en mode paysage
  bool get isLandscape => orientation == Orientation.landscape;

  /// Vérifie si l'écran est en mode portrait
  bool get isPortrait => orientation == Orientation.portrait;

  /// Padding des safe areas
  EdgeInsets get padding => MediaQuery.of(this).padding;

  /// ViewInsets (ex: hauteur du clavier)
  EdgeInsets get viewInsets => MediaQuery.of(this).viewInsets;

  // ==================== NAVIGATION ====================

  /// Navigation simplifiée avec push
  Future<T?> push<T>(Widget page) {
    return Navigator.of(this).push<T>(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  /// Navigation simplifiée avec pushReplacement
  Future<T?> pushReplacement<T, TO>(Widget page, {TO? result}) {
    return Navigator.of(this).pushReplacement<T, TO>(
      MaterialPageRoute(builder: (_) => page),
      result: result,
    );
  }

  /// Navigation simplifiée avec pushAndRemoveUntil
  Future<T?> pushAndRemoveUntil<T>(
      Widget page,
      bool Function(Route<dynamic>) predicate,
      ) {
    return Navigator.of(this).pushAndRemoveUntil<T>(
      MaterialPageRoute(builder: (_) => page),
      predicate,
    );
  }

  /// Pop de la route actuelle
  void pop<T>([T? result]) {
    Navigator.of(this).pop(result);
  }

  /// Vérifie si on peut pop
  bool get canPop => Navigator.of(this).canPop();

  // ==================== SNACKBARS ====================

  /// Affiche un SnackBar de succès
  void showSuccessSnackBar(String message, {Duration? duration}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: duration ?? const Duration(seconds: 3),
      ),
    );
  }

  /// Affiche un SnackBar d'erreur
  void showErrorSnackBar(String message, {Duration? duration}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: duration ?? const Duration(seconds: 3),
      ),
    );
  }

  /// Affiche un SnackBar d'information
  void showInfoSnackBar(String message, {Duration? duration}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.blue.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: duration ?? const Duration(seconds: 3),
      ),
    );
  }

  /// Affiche un SnackBar d'avertissement
  void showWarningSnackBar(String message, {Duration? duration}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.orange.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: duration ?? const Duration(seconds: 3),
      ),
    );
  }

  // ==================== DIALOGS ====================

  /// Affiche un dialog de confirmation
  Future<bool> showConfirmDialog({
    required String title,
    required String content,
    String confirmText = 'Confirmer',
    String cancelText = 'Annuler',
  }) async {
    final result = await showDialog<bool>(
      context: this,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Cache le clavier
  void hideKeyboard() {
    FocusScope.of(this).unfocus();
  }
}