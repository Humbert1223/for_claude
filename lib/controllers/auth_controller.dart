import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:novacole/models/user_model.dart';
import 'package:novacole/models/master_crud_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:novacole/utils/api.dart';

class AuthController extends GetxController {
  // ==================== OBSERVABLES ====================

  /// Utilisateur courant
  final Rx<UserModel> currentUser = UserModel().obs;

  /// État de chargement global
  final RxBool isLoading = false.obs;

  /// Liste des permissions de l'utilisateur
  final RxList<String> permissions = <String>[].obs;

  /// Comptes sauvegardés localement
  final RxList<UserModel> savedAccounts = <UserModel>[].obs;

  /// École courante (utilise RxMap pour la réactivité)
  final RxMap<String, dynamic> currentSchool = <String, dynamic>{}.obs;

  /// Année académique courante
  final RxMap<String, dynamic> currentAcademic = <String, dynamic>{}.obs;

  /// Message d'erreur (pour affichage réactif)
  final RxString errorMessage = ''.obs;

  // ==================== LIFECYCLE ====================

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  /// Initialisation du controller
  Future<void> _initialize() async {
    await loadUserFromStorage();
    await loadSavedAccounts();
  }

  @override
  void onClose() {
    // Nettoyage si nécessaire
    super.onClose();
  }

  // ==================== GETTERS RÉACTIFS ====================

  /// Vérifie si l'utilisateur est connecté
  bool get isLoggedIn => isAuthenticated();

  /// ID de l'utilisateur
  String? get userId => currentUser.value.id;

  /// Token d'authentification
  String? get userToken => currentUser.value.token;

  /// Nom de l'utilisateur
  String? get userName => currentUser.value.name;

  /// Email de l'utilisateur
  String? get userEmail => currentUser.value.email;

  /// Type de compte actuel
  String? get accountType => currentUser.value.accountType;

  /// Vérifie si des comptes sont sauvegardés
  bool get hasSavedAccounts => savedAccounts.isNotEmpty;

  /// Nombre de comptes sauvegardés
  int get savedAccountsCount => savedAccounts.length;

  // ==================== PERMISSION CHECKS ====================

  /// Vérifie si l'utilisateur a une permission spécifique
  bool hasPermission(String permission) {
    return currentUser.value.accountType != 'staff' ||
        permissions.contains(permission);
  }

  /// Vérifie si l'utilisateur a AU MOINS UNE des permissions
  bool hasAny(List<String> perms) {
    return currentUser.value.accountType != 'staff' ||
        perms.any((p) => permissions.contains(p));
  }

  /// Vérifie si l'utilisateur a TOUTES les permissions
  bool hasAll(List<String> perms) {
    return currentUser.value.accountType != 'staff' ||
        perms.every((p) => permissions.contains(p));
  }

  /// Vérifie si l'utilisateur a un type de compte spécifique
  bool isAccountType(String type) {
    final user = currentUser.value;
    if (user.schools == null) return false;

    return user.schools!.any((s) =>
    s['school_id'] == user.school &&
        s['account_type'] == type
    ) && user.accountType == type;
  }

  /// Vérifie si l'utilisateur est connecté
  bool isAuthenticated() {
    return currentUser.value.token != null &&
        currentUser.value.token!.isNotEmpty;
  }

  // ==================== AUTHENTICATION ====================

  /// Connexion de l'utilisateur
  Future<bool> login(String login, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      Map<String, dynamic>? device = await _getDeviceDetails();
      Map<String, String?> data = {
        'login': login,
        'password': password,
        'device_name': device?['deviceName'],
      };

      Map<String, dynamic>? response = await MasterCrudModel.post(
        '/auth/login',
        data: data,
      );

      if (response != null && response['user'] != null) {
        var userData = Map<String, dynamic>.from(response['user']);
        UserModel user = UserModel.fromMap(userData);

        // Sauvegarder l'utilisateur
        await setCurrentUser(user);
        await addToSavedAccounts(user);

        // Mettre à jour le token FCM
        await updateFcmToken();

        return true;
      }

      errorMessage.value = 'Identifiants incorrects';
      _showError('Erreur', 'Erreur de connexion !');
      return false;

    } catch (e) {
      errorMessage.value = e.toString();
      _showError('Erreur', e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Déconnexion
  Future<void> logout() async {
    try {
      isLoading.value = true;

      final user = currentUser.value;

      // Supprimer le token FCM côté serveur
      try {
        await MasterCrudModel.patch('/auth/user/update-fcm-token', {
          'device_fcm_token': null,
        });
      } catch (e) {
        // Ignorer les erreurs de suppression du token
      }

      // Retirer des comptes sauvegardés
      await _removeFromSavedAccounts(user);

      // Nettoyer le stockage local
      SharedPreferences prefs = await Http().local();
      await prefs.remove('auth_user');

      // Réinitialiser les observables
      currentUser.value = UserModel();
      permissions.clear();
      currentSchool.clear();
      currentAcademic.clear();
      errorMessage.value = '';

      // Rediriger vers la page de connexion
      Get.offAllNamed('/login');

    } catch (e) {
      _showError('Erreur', 'Erreur lors de la déconnexion');
    } finally {
      isLoading.value = false;
    }
  }

  /// Récupérer les données utilisateur depuis le serveur
  Future<Map<String, dynamic>?> fromServer() async {
    try {
      return await MasterCrudModel.find('/auth/user');
    } catch (e) {
      print('❌ Error fetching user from server: $e');
      return null;
    }
  }

  /// Rafraîchir les données utilisateur depuis le serveur
  Future<bool> refreshUser() async {
    try {
      isLoading.value = true;

      Map<String, dynamic>? response = await fromServer();

      if (response != null) {
        // Conserver le token actuel
        String? currentToken = currentUser.value.token;
        response['token'] = currentToken;

        UserModel user = UserModel.fromMap(response);
        await setCurrentUser(user);
        await addToSavedAccounts(user);

        return true;
      }

      return false;
    } catch (e) {
      print('❌ Error refreshing user: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Récupérer le token FCM actuel
  Future<String?> getCurrentFcmToken() async {
    try {
      Map<String, dynamic>? token = await MasterCrudModel.post(
        '/auth/user/sanctum/token',
      );
      return token?['device_fcm_token'];
    } catch (e) {
      print('❌ Error getting FCM token: $e');
      return null;
    }
  }

  /// Mettre à jour le token FCM
  Future<void> updateFcmToken() async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        await MasterCrudModel.patch('/auth/user/update-fcm-token', {
          'device_fcm_token': fcmToken,
        });
      }
    } catch (e) {
      // Firebase non disponible sur cette plateforme
      print('ℹ️ Firebase not available: $e');
    }
  }

  // ==================== ACCOUNT MANAGEMENT ====================

  /// Sélectionner un compte sauvegardé
  Future<bool> switchAccount(String userId) async {
    try {
      isLoading.value = true;

      UserModel? account = savedAccounts.firstWhereOrNull(
            (acc) => acc.id == userId,
      );

      if (account != null) {
        await setCurrentUser(account);
        return true;
      }

      return false;
    } catch (e) {
      _showError('Erreur', 'Impossible de changer de compte');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Changer d'espace (école/année académique)
  Future<bool> changeSpace({
    required String accountType,
    required String schoolId,
  }) async {
    try {
      isLoading.value = true;

      Map<String, dynamic>? response = await MasterCrudModel.patch(
        '/auth/user/school/update',
        {'school_id': schoolId, 'account_type': accountType},
      );

      if (response != null) {
        UserModel user = UserModel.fromMap(response);
        await setCurrentUser(user);
        await addToSavedAccounts(user);
        return true;
      }

      return false;
    } catch (e) {
      _showError('Erreur', 'Impossible de changer d\'espace');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Supprimer le compte
  Future<bool> deleteAccount(String password) async {
    try {
      isLoading.value = true;

      var response = await MasterCrudModel.delete(
        userId ?? '__unknown__',
        'user',
        data: {'password': password},
      );

      if (response != null) {
        await logout();
        return true;
      }

      return false;
    } catch (e) {
      _showError('Erreur', 'Impossible de supprimer le compte');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== ACADEMIC & SCHOOL ====================

  /// Récupérer les informations de l'année académique
  Future<void> _getAcademic(UserModel? user) async {
    try {
      if (user == null || user.academic == null) {
        currentAcademic.clear();
        return;
      }

      // Vérifier le cache local
      final local = await Http().local();
      String? cached = local.getString('academic');

      if (cached != null) {
        final academic = jsonDecode(cached);
        if (user.academic == academic['id']) {
          currentAcademic.assignAll(academic);
          return;
        }
      }

      // Récupérer depuis le serveur
      Map<String, dynamic>? response = await MasterCrudModel('academic')
          .get(user.academic!);

      if (response != null) {
        currentAcademic.assignAll(response);
        await local.setString('academic', jsonEncode(response));
      } else {
        currentAcademic.clear();
      }
    } catch (e) {
      print('❌ Error loading academic: $e');
      currentAcademic.clear();
    }
  }

  /// Récupérer les informations de l'école
  Future<void> _getSchool(UserModel? user) async {
    try {
      if (user == null || user.school == null) {
        currentSchool.clear();
        return;
      }

      // Vérifier le cache local
      final local = await Http().local();
      String? cached = local.getString('school');

      if (cached != null) {
        final school = jsonDecode(cached);
        if (user.school == school['id']) {
          currentSchool.assignAll(school);
          return;
        }
      }

      // Récupérer depuis le serveur
      Map<String, dynamic>? response = await MasterCrudModel('school')
          .get(user.school!);

      if (response != null) {
        currentSchool.assignAll(response);
        await local.setString('school', jsonEncode(response));
      } else {
        currentSchool.clear();
      }
    } catch (e) {
      print('❌ Error loading school: $e');
      currentSchool.clear();
    }
  }

  // ==================== PRIVATE METHODS ====================

  /// Définir l'utilisateur courant
  Future<void> setCurrentUser(UserModel user) async {
    try {
      // Conserver le token si nécessaire
      if (user.token == null || user.token!.isEmpty) {
        final u = user.toMap();
        u['token'] = currentUser.value.token;
        user = UserModel.fromMap(u);
      }

      // Mettre à jour l'utilisateur et les permissions
      currentUser.value = user;
      permissions.value = user.permissions ?? [];

      // Sauvegarder dans le stockage local
      SharedPreferences prefs = await Http().local();
      await prefs.setString('auth_user', jsonEncode(user.toMap()));

      // Charger les données contextuelles en parallèle
      await Future.wait([
        _getAcademic(user),
        _getSchool(user),
      ]);

      // Forcer la mise à jour de l'interface
      currentUser.refresh();
      permissions.refresh();

    } catch (e) {
      print('❌ Error setting current user: $e');
      throw e;
    }
  }

  /// Charger l'utilisateur depuis le stockage
  Future<void> loadUserFromStorage() async {
    try {
      SharedPreferences prefs = await Http().local();
      String? userData = prefs.getString('auth_user');

      if (userData != null && userData.isNotEmpty && userData != '{}') {
        Map<String, dynamic> userMap = jsonDecode(userData);
        UserModel user = UserModel.fromMap(userMap);

        currentUser.value = user;
        permissions.value = user.permissions ?? [];

        // Charger les données contextuelles
        await Future.wait([
          _getAcademic(user),
          _getSchool(user),
        ]);

        // Forcer le rafraîchissement
        currentUser.refresh();
        permissions.refresh();
      }
    } catch (e) {
      print('❌ Error loading user from storage: $e');
      // En cas d'erreur, réinitialiser
      currentUser.value = UserModel();
      permissions.clear();
    }
  }

  /// Charger les comptes sauvegardés
  Future<void> loadSavedAccounts() async {
    try {
      SharedPreferences prefs = await Http().local();
      String? accountsData = prefs.getString('auth_user_list');

      if (accountsData != null && accountsData.isNotEmpty) {
        List<dynamic> accountsList = jsonDecode(accountsData);
        savedAccounts.value = accountsList
            .map((acc) => UserModel.fromMap(acc))
            .toList();

        savedAccounts.refresh();
      }
    } catch (e) {
      print('❌ Error loading saved accounts: $e');
      savedAccounts.clear();
    }
  }

  /// Ajouter aux comptes sauvegardés
  Future<void> addToSavedAccounts(UserModel user) async {
    try {
      await loadSavedAccounts();

      int index = savedAccounts.indexWhere((acc) => acc.id == user.id);
      if (index != -1) {
        // Mettre à jour le compte existant
        savedAccounts[index] = user;
      } else {
        // Ajouter un nouveau compte
        savedAccounts.add(user);
      }

      // Sauvegarder dans le stockage local
      SharedPreferences prefs = await Http().local();
      await prefs.setString(
        'auth_user_list',
        jsonEncode(savedAccounts.map((e) => e.toMap()).toList()),
      );

      savedAccounts.refresh();

    } catch (e) {
      print('❌ Error adding to saved accounts: $e');
    }
  }

  /// Retirer des comptes sauvegardés
  Future<void> _removeFromSavedAccounts(UserModel user) async {
    try {
      savedAccounts.removeWhere((acc) => acc.id == user.id);

      SharedPreferences prefs = await Http().local();
      await prefs.setString(
        'auth_user_list',
        jsonEncode(savedAccounts.map((e) => e.toMap()).toList()),
      );

      savedAccounts.refresh();

    } catch (e) {
      print('❌ Error removing from saved accounts: $e');
    }
  }

  /// Récupérer les détails du périphérique
  Future<Map<String, dynamic>?> _getDeviceDetails() async {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        var build = await deviceInfoPlugin.androidInfo;
        return {
          'deviceName': "${build.model} - ${build.id}",
          'deviceVersion': build.version.toString(),
          'identifier': build.id,
        };
      } else if (Platform.isIOS) {
        var data = await deviceInfoPlugin.iosInfo;
        return {
          'deviceName': "${data.name} - ${data.identifierForVendor}",
          'deviceVersion': data.systemVersion,
          'identifier': data.identifierForVendor!,
        };
      }
    } on PlatformException catch (e) {
      print('❌ Error getting device details: $e');
      return null;
    }
    return null;
  }

  // ==================== HELPER METHODS ====================

  /// Afficher un message d'erreur
  void _showError(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Vider toutes les données
  Future<void> clearAllData() async {
    currentUser.value = UserModel();
    permissions.clear();
    savedAccounts.clear();
    currentSchool.clear();
    currentAcademic.clear();
    errorMessage.value = '';

    SharedPreferences prefs = await Http().local();
    await prefs.remove('auth_user');
    await prefs.remove('auth_user_list');
    await prefs.remove('school');
    await prefs.remove('academic');
  }
}