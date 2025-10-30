import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

ColorScheme lightThemeColors(context) {
  return const ColorScheme.light(
    primary: Color(0xff5b8c11),
    onPrimary: Colors.white,
    surface: Colors.white,
    onSurface: Color(0xff1a1a1a),
    onPrimaryContainer: Color(0xff9a9a9a),
    primaryContainer: Color(0xffefefef),
    secondaryContainer: Color(0xfffafafa),
    surfaceContainerHighest: Color(0xffe8e8e8),
    outline: Color(0xffe0e0e0),
    shadow: Color(0x1a000000),
  );
}

ColorScheme darkThemeColors(context) {
  return const ColorScheme.dark(
    primary: Color(0xff5b8c11),
    onPrimary: Colors.white,
    surface: Color(0xff0b141b),
    onSurface: Color(0xffe8e8e8),
    primaryContainer: Color(0xff1f2c34),
    secondaryContainer: Color(0xff2a2a2a),
    surfaceContainerHighest: Color(0xff2d3a42),
    outline: Color(0xff3a3a3a),
    shadow: Color(0x33000000),
  );
}

ThemeData lightTheme(BuildContext context) {
  final colors = lightThemeColors(context);

  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: colors.surface,

    // AppBar moderne avec style épuré
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 2,
      backgroundColor: colors.primary,
      foregroundColor: colors.onPrimary,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: colors.onPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 20,
        letterSpacing: 0.15,
      ),
      iconTheme: IconThemeData(color: colors.onPrimary, size: 24),
      actionsIconTheme: IconThemeData(color: colors.onPrimary, size: 24),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    ),

    // Boutons modernes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.primary,
        side: BorderSide(color: colors.primary, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),

    // Inputs modernes avec bordures subtiles
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colors.surfaceContainerHighest.withValues(alpha:0.5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),

      // Bordure par défaut
      border: OutlineInputBorder(
        borderSide: BorderSide(color: colors.outline, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),

      // Bordure quand activé
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: colors.outline, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),

      // Bordure quand focus
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: colors.primary, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),

      // Bordure en erreur
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),

      // Style des labels
      labelStyle: TextStyle(
        color: colors.onSurface.withValues(alpha:0.6),
        fontSize: 16,
      ),

      floatingLabelStyle: TextStyle(
        color: colors.primary,
        fontSize: 14,
      ),

      hintStyle: TextStyle(
        color: colors.onSurface.withValues(alpha:0.5),
        fontSize: 16,
      ),
    ),

    colorScheme: colors,

    // Cards modernes avec ombres douces
    cardTheme: CardThemeData(
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shadowColor: colors.shadow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.outline.withValues(alpha:0.2), width: 1),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // ListTile moderne
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      iconColor: colors.primary,
    ),

    // Menu popup moderne
    popupMenuTheme: PopupMenuThemeData(
      elevation: 8,
      surfaceTintColor: Colors.transparent,
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    // Dialogues modernes
    dialogTheme: DialogThemeData(
      surfaceTintColor: Colors.transparent,
      backgroundColor: colors.surface,
      elevation: 24,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      titleTextStyle: TextStyle(
        color: colors.onSurface,
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
      contentTextStyle: TextStyle(
        color: colors.onSurface.withValues(alpha:0.8),
        fontSize: 16,
        height: 1.5,
      ),
    ),

    // DatePicker moderne
    datePickerTheme: DatePickerThemeData(
      surfaceTintColor: Colors.transparent,
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      headerBackgroundColor: colors.primary,
      headerForegroundColor: colors.onPrimary,
    ),

    // BottomSheet moderne
    bottomSheetTheme: BottomSheetThemeData(
      surfaceTintColor: Colors.transparent,
      backgroundColor: colors.surface,
      elevation: 8,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      modalBackgroundColor: colors.surface,
      modalElevation: 8,
    ),

    // Divider subtil
    dividerTheme: DividerThemeData(
      color: colors.outline.withValues(alpha:0.3),
      thickness: 1,
      space: 1,
    ),

    // Chips modernes
    chipTheme: ChipThemeData(
      backgroundColor: colors.surfaceContainerHighest,
      deleteIconColor: colors.onSurface,
      labelStyle: TextStyle(color: colors.onSurface),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),

    // FAB moderne
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colors.primary,
      foregroundColor: colors.onPrimary,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    // Navigation moderne
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: colors.surface,
      elevation: 0,
      indicatorColor: colors.primary.withValues(alpha:0.15),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return TextStyle(color: colors.primary, fontSize: 12, fontWeight: FontWeight.w600);
        }
        return TextStyle(color: colors.onSurface.withValues(alpha:0.6), fontSize: 12);
      }),
    ),

    // Switch moderne
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colors.primary;
        }
        return colors.outline;
      }),
    ),

    // Checkbox moderne
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    ),

    // Radio moderne
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colors.primary;
        }
        return colors.outline;
      }),
    ),
  );
}

ThemeData darkTheme(BuildContext context) {
  final colors = darkThemeColors(context);

  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: colors.surface,

    // AppBar moderne pour le dark mode
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 2,
      backgroundColor: colors.surface,
      foregroundColor: colors.onSurface,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: colors.onSurface,
        fontWeight: FontWeight.w600,
        fontSize: 20,
        letterSpacing: 0.15,
      ),
      iconTheme: IconThemeData(color: colors.onSurface, size: 24),
      actionsIconTheme: IconThemeData(color: colors.onSurface, size: 24),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    ),

    // Boutons modernes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.primary,
        side: BorderSide(color: colors.primary, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),

    // Inputs modernes pour dark mode
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colors.primaryContainer.withValues(alpha:0.5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),

      border: OutlineInputBorder(
        borderSide: BorderSide(color: colors.outline, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),

      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: colors.outline, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),

      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: colors.primary, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),

      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),

      labelStyle: TextStyle(
        color: colors.onSurface.withValues(alpha:0.6),
        fontSize: 16,
      ),

      floatingLabelStyle: TextStyle(
        color: colors.primary,
        fontSize: 14,
      ),

      hintStyle: TextStyle(
        color: colors.onSurface.withValues(alpha:0.5),
        fontSize: 16,
      ),
    ),

    colorScheme: colors,

    // Cards modernes pour dark mode
    cardTheme: CardThemeData(
      surfaceTintColor: Colors.transparent,
      color: colors.primaryContainer,
      elevation: 0,
      shadowColor: colors.shadow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.outline.withValues(alpha:0.2), width: 1),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // ListTile moderne
    listTileTheme: ListTileThemeData(
      tileColor: Colors.transparent,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      iconColor: colors.primary,
    ),

    // Menu popup moderne
    popupMenuTheme: PopupMenuThemeData(
      elevation: 8,
      surfaceTintColor: Colors.transparent,
      color: colors.primaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    // Dialogues modernes
    dialogTheme: DialogThemeData(
      surfaceTintColor: Colors.transparent,
      backgroundColor: colors.primaryContainer,
      elevation: 24,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      titleTextStyle: TextStyle(
        color: colors.onSurface,
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
      contentTextStyle: TextStyle(
        color: colors.onSurface.withValues(alpha:0.8),
        fontSize: 16,
        height: 1.5,
      ),
    ),

    // DatePicker moderne
    datePickerTheme: DatePickerThemeData(
      surfaceTintColor: Colors.transparent,
      backgroundColor: colors.primaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      headerBackgroundColor: colors.primary,
      headerForegroundColor: colors.onPrimary,
    ),

    // BottomSheet moderne
    bottomSheetTheme: BottomSheetThemeData(
      surfaceTintColor: Colors.transparent,
      backgroundColor: colors.primaryContainer,
      elevation: 8,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      modalBackgroundColor: colors.primaryContainer,
      modalElevation: 8,
    ),

    // Divider subtil
    dividerTheme: DividerThemeData(
      color: colors.outline.withValues(alpha:0.3),
      thickness: 1,
      space: 1,
    ),

    // Chips modernes
    chipTheme: ChipThemeData(
      backgroundColor: colors.surfaceContainerHighest,
      deleteIconColor: colors.onSurface,
      labelStyle: TextStyle(color: colors.onSurface),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),

    // FAB moderne
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colors.primary,
      foregroundColor: colors.onPrimary,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    // Navigation moderne
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: colors.surface,
      elevation: 0,
      indicatorColor: colors.primary.withValues(alpha:0.2),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return TextStyle(color: colors.primary, fontSize: 12, fontWeight: FontWeight.w600);
        }
        return TextStyle(color: colors.onSurface.withValues(alpha:0.6), fontSize: 12);
      }),
    ),

    // Switch moderne
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colors.primary;
        }
        return colors.outline;
      }),
    ),

    // Checkbox moderne
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    ),

    // Radio moderne
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colors.primary;
        }
        return colors.outline;
      }),
    ),
  );
}