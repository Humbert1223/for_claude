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
  // Observables
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxList<String> permissions = <String>[].obs;
  final RxList<UserModel> savedAccounts = <UserModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadUserFromStorage();
    loadSavedAccounts();
  }

  // Getters
  bool get isLoggedIn => isAuthenticated();
  String? get userId => currentUser.value?.id;
  String? get userToken => currentUser.value?.token;
  String? get userName => currentUser.value?.name;
  String? get userEmail => currentUser.value?.email;

  // ==================== PERMISSION CHECKS ====================

  /// Vérifie si l'utilisateur a une permission spécifique
  bool hasPermission(String permission) {
    return currentUser.value?.accountType != 'staff' || permissions.contains(permission);
  }

  /// Vérifie si l'utilisateur a AU MOINS UNE des permissions
  bool hasAny(List<String> perms) {
    return  currentUser.value?.accountType != 'staff' || perms.any((p) => permissions.contains(p));
  }

  /// Vérifie si l'utilisateur a TOUTES les permissions
  bool hasAll(List<String> perms) {
    return  currentUser.value?.accountType != 'staff' || perms.every((p) => permissions.contains(p));
  }

  /// Vérifie si l'utilisateur a un type de compte spécifique
  bool isAccountType(String type) {
    final user = currentUser.value;
    if (user == null || user.schools == null) return false;

    return user.schools!.any((s) =>
    s['school_id'] == user.school &&
        s['account_type'] == type) &&
        user.accountType == type;
  }

  /// Vérifie si l'utilisateur est connecté
  bool isAuthenticated() {
    return currentUser.value != null && currentUser.value?.token != null && currentUser.value?.token!.isNotEmpty == true;
  }

  // ==================== AUTHENTICATION ====================

  /// Connexion de l'utilisateur
  Future<bool> login(String login, String password) async {
    try {
      isLoading.value = true;

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

      if (response != null) {
        var userData = Map<String, dynamic>.from(response['user']);
        UserModel user = UserModel.fromMap(userData);

        // Sauvegarder l'utilisateur
        await setCurrentUser(user);
        await addToSavedAccounts(user);

        return true;
      }

      Get.snackbar(
        'Erreur',
        'Erreur de connexion !',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;

    } catch (e) {
      Get.snackbar(
        'Erreur',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Déconnexion
  Future<void> logout() async {
    try {
      final user = currentUser.value;
      if (user != null) {
        await _removeFromSavedAccounts(user);
      }

      SharedPreferences prefs = await Http().local();
      await prefs.remove('auth_user');

      currentUser.value = null;
      permissions.clear();

      Get.offAllNamed('/login');

    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de la déconnexion');
    }
  }

  Future<Map<String, dynamic>?> fromServer() async {
    return await MasterCrudModel.find('/auth/user');
  }

  /// Rafraîchir les données utilisateur depuis le serveur
  Future<bool> refreshUser() async {
    try {
      Map<String, dynamic>? response = await fromServer();

      if (response != null) {
        // Conserver le token actuel
        String? currentToken = currentUser.value?.token;
        response['token'] = currentToken;

        UserModel user = UserModel.fromMap(response);
        await setCurrentUser(user);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<String?> getCurrentFcmToken() async {
    Map<String, dynamic>? token = await MasterCrudModel.post(
      '/auth/user/sanctum/token',
    );
    return token?['device_fcm_token'];
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
    }
  }

  // ==================== ACCOUNT MANAGEMENT ====================

  /// Sélectionner un compte sauvegardé
  Future<bool> switchAccount(String userId) async {
    try {
      UserModel? account = savedAccounts.where(
            (acc) => acc.id == userId,
      ).firstOrNull;

      if (account != null) {
        await setCurrentUser(account);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Changer d'espace (école/année académique)
  Future<bool> changeSpace({
    required String accountType,
    required String schoolId,
  }) async {
    try {
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
      return false;
    }
  }

  /// Supprimer le compte
  Future<bool> deleteAccount(String password) async {
    try {
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
      return false;
    }
  }

  // ==================== ACADEMIC & SCHOOL ====================

  /// Récupérer les informations de l'année académique
  Future<Map<String, dynamic>?> getAcademic() async {
    try {
      final user = currentUser.value;
      if (user == null || user.academic == null) return null;

      SharedPreferences prefs = await Http().local();
      String? cached = prefs.getString('academic');

      if (cached != null) {
        return Map<String, dynamic>.from(jsonDecode(cached));
      }

      Map<String, dynamic>? response = await MasterCrudModel('academic')
          .get(user.academic!);

      if (response != null) {
        await prefs.setString('academic', jsonEncode(response));
      }

      return response;
    } catch (e) {
      return null;
    }
  }

  /// Récupérer les informations de l'école
  Future<Map<String, dynamic>?> getSchool() async {
    try {
      final user = currentUser.value;
      if (user == null || user.school == null) return null;

      SharedPreferences prefs = await Http().local();
      String? cached = prefs.getString('school');

      if (cached != null) {
        return Map<String, dynamic>.from(jsonDecode(cached));
      }

      Map<String, dynamic>? response = await MasterCrudModel('school')
          .get(user.school!);

      if (response != null) {
        await prefs.setString('school', jsonEncode(response));
      }

      return response;
    } catch (e) {
      return null;
    }
  }

  // ==================== PRIVATE METHODS ====================

  /// Définir l'utilisateur courant
  Future<void> setCurrentUser(UserModel user) async {
    if(user.token == null || user.token!.isEmpty){
      final u = user.toMap();
      u['token'] = currentUser.value?.token;
      user = UserModel.fromMap(u);
    }
    currentUser.value = user;
    permissions.value = user.permissions ?? [];
    // Sauvegarder dans le stockage local
    SharedPreferences prefs = await Http().local();
    await prefs.setString('auth_user', jsonEncode(user.toMap()));
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
      }
    } catch (e) {
      // Erreur de chargement
    }
  }

  /// Charger les comptes sauvegardés
  Future<void> loadSavedAccounts() async {
    try {
      SharedPreferences prefs = await Http().local();
      String? accountsData = prefs.getString('auth_user_list');

      if (accountsData != null) {
        List<dynamic> accountsList = jsonDecode(accountsData);
        savedAccounts.value = accountsList
            .map((acc) => UserModel.fromMap(acc))
            .toList();
      }
    } catch (e) {
      // Erreur de chargement
    }
  }

  /// Ajouter aux comptes sauvegardés
  Future<void> addToSavedAccounts(UserModel user) async {
    try {
      await loadSavedAccounts();

      int index = savedAccounts.indexWhere((acc) => acc.id == user.id);
      if (index != -1) {
        savedAccounts[index] = user;
      } else {
        savedAccounts.add(user);
      }

      SharedPreferences prefs = await Http().local();
      await prefs.setString(
        'auth_user_list',
        jsonEncode(savedAccounts.map((e) => e.toMap()).toList()),
      );
    } catch (e) {
      // Erreur de sauvegarde
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
    } catch (e) {
      // Erreur de suppression
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
    } on PlatformException {
      return null;
    }
    return null;
  }
}