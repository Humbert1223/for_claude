
class AppSpacing {
  AppSpacing._(); // Prevent instantiation

  /// Extra small spacing: 4.0
  static const double xs = 4.0;

  /// Small spacing: 8.0
  static const double sm = 8.0;

  /// Medium spacing: 16.0 (défaut recommandé)
  static const double md = 16.0;

  /// Large spacing: 24.0
  static const double lg = 24.0;

  /// Extra large spacing: 32.0
  static const double xl = 32.0;

  /// Extra extra large spacing: 40.0
  static const double xxl = 40.0;
}

class AppRadius {
  AppRadius._();

  /// Extra small radius: 4.0
  static const double xs = 4.0;

  /// Small radius: 8.0
  static const double sm = 8.0;

  /// Medium radius: 12.0
  static const double md = 12.0;

  /// Large radius: 16.0 (défaut recommandé)
  static const double lg = 16.0;

  /// Extra large radius: 20.0
  static const double xl = 20.0;

  /// Extra extra large radius: 24.0
  static const double xxl = 24.0;

  /// Full circle radius: 999.0
  static const double circle = 999.0;
}

class AppElevation {
  AppElevation._();

  /// No elevation
  static const double none = 0.0;

  /// Low elevation: 2.0
  static const double low = 2.0;

  /// Medium elevation: 4.0
  static const double medium = 4.0;

  /// High elevation: 8.0
  static const double high = 8.0;

  /// Extra high elevation: 12.0
  static const double extraHigh = 12.0;
}

class AppDuration {
  AppDuration._();

  /// Very fast animation: 150ms
  static const Duration veryFast = Duration(milliseconds: 150);

  /// Fast animation: 200ms
  static const Duration fast = Duration(milliseconds: 200);

  /// Normal animation: 300ms (défaut recommandé)
  static const Duration normal = Duration(milliseconds: 300);

  /// Slow animation: 400ms
  static const Duration slow = Duration(milliseconds: 400);

  /// Very slow animation: 600ms
  static const Duration verySlow = Duration(milliseconds: 600);
}

class AppIconSize {
  AppIconSize._();

  /// Small icon: 16.0
  static const double sm = 16.0;

  /// Medium icon: 24.0 (défaut)
  static const double md = 24.0;

  /// Large icon: 32.0
  static const double lg = 32.0;

  /// Extra large icon: 48.0
  static const double xl = 48.0;
}

class AppFontSize {
  AppFontSize._();

  /// Extra small: 10.0
  static const double xs = 10.0;

  /// Small: 12.0
  static const double sm = 12.0;

  /// Medium: 14.0
  static const double md = 14.0;

  /// Base: 16.0 (body text)
  static const double base = 16.0;

  /// Large: 18.0
  static const double lg = 18.0;

  /// Extra large: 20.0
  static const double xl = 20.0;

  /// Title: 24.0
  static const double title = 24.0;

  /// Heading: 28.0
  static const double heading = 28.0;
}

class AppBorderWidth {
  AppBorderWidth._();

  /// Thin border: 1.0
  static const double thin = 1.0;

  /// Normal border: 1.5
  static const double normal = 1.5;

  /// Thick border: 2.0
  static const double thick = 2.0;

  /// Extra thick border: 3.0
  static const double extraThick = 3.0;
}