import 'package:novacole/main.dart';

class NavigationService {
  static Future<dynamic> navigateTo(String routeName) {
    return navigatorKey.currentState!.pushNamed(routeName);
  }

  static void goBack() {
    return navigatorKey.currentState!.pop();
  }

  static Future<dynamic> navigateAndReplace(String routeName) {
    return navigatorKey.currentState!.pushReplacementNamed(routeName);
  }

  static void navigateAndRemoveUntil(String routeName) {
    navigatorKey.currentState!.pushNamedAndRemoveUntil(
      routeName,
          (route) => false,
    );
  }
}