import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReviewHelper {
  static final InAppReview _inAppReview = InAppReview.instance;

  static Future<void> requestReview() async {
    if (await _inAppReview.isAvailable()) {
      await _inAppReview.requestReview();
    } else {
      openPlayStore();
    }
  }

  static void openPlayStore() {
    const String appId = "com.novacole.app";
    _inAppReview.openStoreListing(appStoreId: appId);
  }


  Future<void> saveReviewDate() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt("last_review", DateTime.now().millisecondsSinceEpoch);
  }

  Future<bool> shouldAskForReview() async {
    final prefs = await SharedPreferences.getInstance();
    final lastReview = prefs.getInt("last_review") ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    return (now - lastReview) > (30 * 24 * 60 * 60 * 1000);
  }
}
