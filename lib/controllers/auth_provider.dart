import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:novacole/models/user_model.dart';
import 'package:novacole/models/master_crud_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:novacole/utils/api.dart';

class AuthProvider extends ChangeNotifier {
  // ==================== SINGLETON ====================

  static final AuthProvider _instance = AuthProvider._internal();
  factory AuthProvider() => _instance;
  static AuthProvider get instance => _instance;

  AuthProvider._internal() {
    _initialize();
  }

  // ==================== PROPERTIES ====================

  /// Utilisateur courant
  UserModel _currentUser = UserModel();
  UserModel get currentUser => _currentUser;

  /// État de chargement global
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Liste des permissions de l'utilisateur
  List<String> _permissions = [];
  List<String> get permissions => List.unmodifiable(_permissions);

  /// Comptes sauvegardés localement
  List<UserModel> _savedAccounts = [];
  List<UserModel> get savedAccounts => List.unmodifiable(_savedAccounts);

  /// École courante
  Map<String, dynamic> _currentSchool = {};
  Map<String, dynamic> get currentSchool => Map.unmodifiable(_currentSchool);

  /// Année académique courante
  Map<String, dynamic> _currentAcademic = {};
  Map<String, dynamic> get currentAcademic => Map.unmodifiable(_currentAcademic);

  /// Message d'erreur
  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  // ==================== INITIALIZATION ====================

  /// Initialisation du provider
  Future<void> _initialize() async {
    await loadUserFromStorage();
    await loadSavedAccounts();
  }

  // ==================== GETTERS ====================

  /// Vérifie si l'utilisateur est connecté
  bool get isLoggedIn => isAuthenticated();

  /// ID de l'utilisateur
  String? get userId => _currentUser.id;

  /// Token d'authentification
  String? get userToken => _currentUser.token;

  /// Nom de l'utilisateur
  String? get userName => _currentUser.name;

  /// Email de l'utilisateur
  String? get userEmail => _currentUser.email;

  /// Type de compte actuel
  String? get accountType => _currentUser.accountType;

  /// Vérifie si des comptes sont sauvegardés
  bool get hasSavedAccounts => _savedAccounts.isNotEmpty;

  /// Nombre de comptes sauvegardés
  int get savedAccountsCount => _savedAccounts.length;

  // ==================== PERMISSION CHECKS ====================

  /// Vérifie si l'utilisateur a une permission spécifique
  bool hasPermission(String permission) {
    return _currentUser.accountType != 'staff' ||
        _permissions.contains(permission);
  }

  /// Vérifie si l'utilisateur a AU MOINS UNE des permissions
  bool hasAny(List<String> perms) {
    return _currentUser.accountType != 'staff' ||
        perms.any((p) => _permissions.contains(p));
  }

  /// Vérifie si l'utilisateur a TOUTES les permissions
  bool hasAll(List<String> perms) {
    return _currentUser.accountType != 'staff' ||
        perms.every((p) => _permissions.contains(p));
  }

  /// Vérifie si l'utilisateur a un type de compte spécifique
  bool isAccountType(String type) {
    final user = _currentUser;
    if (user.schools == null) return false;

    return user.schools!.any((s) =>
    s['school_id'] == user.school &&
        s['account_type'] == type
    ) && user.accountType == type;
  }

  /// Vérifie si l'utilisateur est connecté
  bool isAuthenticated() {
    return _currentUser.token != null && _currentUser.token!.isNotEmpty;
  }

  // ==================== AUTHENTICATION ====================

  /// Connexion de l'utilisateur
  Future<bool> login(String login, String password) async {
    try {
      _setLoading(true);
      _setErrorMessage('');

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

      _setErrorMessage('Identifiants incorrects');
      return false;

    } catch (e) {
      _setErrorMessage(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Déconnexion
  Future<void> logout() async {
    try {
      _setLoading(true);

      final user = _currentUser;
      // Retirer des comptes sauvegardés
      await _removeFromSavedAccounts(user);

      // Nettoyer le stockage local
      SharedPreferences prefs = await Http().local();
      await prefs.remove('auth_user');

      // Réinitialiser les propriétés
      _currentUser = UserModel();
      _permissions = [];
      _currentSchool = {};
      _currentAcademic = {};
      _setErrorMessage('');

      notifyListeners();

      // Rediriger vers la page de connexion (sans context!)
      // Utilisez NavigationService ici

    } catch (e) {
      if (kDebugMode) {
        print('❌ Error during logout: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  /// Récupérer les données utilisateur depuis le serveur
  Future<Map<String, dynamic>?> fromServer() async {
    try {
      return await MasterCrudModel.find('/auth/user');
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching user from server: $e');
      }
      return null;
    }
  }

  /// Rafraîchir les données utilisateur depuis le serveur
  Future<bool> refreshUser() async {
    try {
      _setLoading(true);

      Map<String, dynamic>? response = await fromServer();

      if (response != null) {
        // Conserver le token actuel
        if(response['token'] == null || response['token'].toString().isEmpty) {
          String? currentToken = _currentUser.token;
          response['token'] = currentToken;
        }

        // Mettre à jour l'utilisateur)

        UserModel user = UserModel.fromMap(response);
        await setCurrentUser(user);
        await addToSavedAccounts(user);

        return true;
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error refreshing user: $e');
      }
      return false;
    } finally {
      _setLoading(false);
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
      if (kDebugMode) {
        print('❌ Error getting FCM token: $e');
      }
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
      if (kDebugMode) {
        print('ℹ️ Firebase not available: $e');
      }
    }
  }

  // ==================== ACCOUNT MANAGEMENT ====================

  /// Sélectionner un compte sauvegardé
  Future<bool> switchAccount(String userId) async {
    try {
      _setLoading(true);

      UserModel? account = _savedAccounts.firstWhere(
            (acc) => acc.id == userId,
        orElse: () => UserModel(),
      );

      if (account.id != null) {
        await setCurrentUser(account);
        return true;
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error switching account: $e');
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Changer d'espace (école/année académique)
  Future<bool> changeSpace({
    required String accountType,
    required String schoolId,
  }) async {
    try {
      _setLoading(true);

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
      if (kDebugMode) {
        print('❌ Error changing space: $e');
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Supprimer le compte
  Future<bool> deleteAccount(String password) async {
    try {
      _setLoading(true);

      var response = await MasterCrudModel.delete(
        userId ?? '__unknown__',
        'user',
        data: {'password': password},
      );

      if (response != null) {
        return true;
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error deleting account: $e');
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ==================== ACADEMIC & SCHOOL ====================

  /// Récupérer les informations de l'année académique
  Future<void> _getAcademic(UserModel? user) async {
    try {
      if (user == null || user.academic == null) {
        _currentAcademic = {};
        return;
      }

      // Vérifier le cache local
      final local = await Http().local();
      String? cached = local.getString('academic');

      if (cached != null) {
        final academic = jsonDecode(cached);
        if (user.academic == academic['id']) {
          _currentAcademic = Map<String, dynamic>.from(academic);
          return;
        }
      }

      // Récupérer depuis le serveur
      Map<String, dynamic>? response = await MasterCrudModel('academic')
          .get(user.academic!);

      if (response != null) {
        _currentAcademic = Map<String, dynamic>.from(response);
        await local.setString('academic', jsonEncode(response));
      } else {
        _currentAcademic = {};
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading academic: $e');
      }
      _currentAcademic = {};
    }
  }

  /// Récupérer les informations de l'école
  Future<void> _getSchool(UserModel? user) async {
    try {
      if (user == null || user.school == null) {
        _currentSchool = {};
        return;
      }

      // Vérifier le cache local
      final local = await Http().local();
      String? cached = local.getString('school');

      if (cached != null) {
        final school = jsonDecode(cached);
        if (user.school == school['id']) {
          _currentSchool = Map<String, dynamic>.from(school);
          return;
        }
      }

      // Récupérer depuis le serveur
      Map<String, dynamic>? response = await MasterCrudModel('school')
          .get(user.school!);

      if (response != null) {
        _currentSchool = Map<String, dynamic>.from(response);
        await local.setString('school', jsonEncode(response));
      } else {
        _currentSchool = {};
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading school: $e');
      }
      _currentSchool = {};
    }
  }

  // ==================== PRIVATE METHODS ====================

  /// Définir l'état de chargement
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Définir le message d'erreur
  void _setErrorMessage(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Définir l'utilisateur courant
  Future<void> setCurrentUser(UserModel user) async {
    try {
      // Conserver le token si nécessaire
      if (user.token == null || user.token!.isEmpty) {
        final u = user.toMap();
        u['token'] = _currentUser.token;
        user = UserModel.fromMap(u);
      }

      // Mettre à jour l'utilisateur et les permissions
      _currentUser = user;
      _permissions = user.permissions ?? [];

      // Sauvegarder dans le stockage local
      SharedPreferences prefs = await Http().local();
      await prefs.setString('auth_user', jsonEncode(user.toMap()));

      // Charger les données contextuelles en parallèle
      await Future.wait([
        _getAcademic(user),
        _getSchool(user),
      ]);

      notifyListeners();

    } catch (e) {
      if (kDebugMode) {
        print('❌ Error setting current user: $e');
      }
      rethrow;
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

        _currentUser = user;
        _permissions = user.permissions ?? [];

        // Charger les données contextuelles
        await Future.wait([
          _getAcademic(user),
          _getSchool(user),
        ]);

        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading user from storage: $e');
      }
      // En cas d'erreur, réinitialiser
      _currentUser = UserModel();
      _permissions = [];
      notifyListeners();
    }
  }

  /// Charger les comptes sauvegardés
  Future<void> loadSavedAccounts() async {
    try {
      SharedPreferences prefs = await Http().local();
      String? accountsData = prefs.getString('auth_user_list');

      if (accountsData != null && accountsData.isNotEmpty) {
        List<dynamic> accountsList = jsonDecode(accountsData);
        _savedAccounts = accountsList
            .map((acc) => UserModel.fromMap(acc))
            .toList();

        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading saved accounts: $e');
      }
      _savedAccounts = [];
      notifyListeners();
    }
  }

  /// Ajouter aux comptes sauvegardés
  Future<void> addToSavedAccounts(UserModel user) async {
    try {
      await loadSavedAccounts();

      int index = _savedAccounts.indexWhere((acc) => acc.id == user.id);
      if (index != -1) {
        // Mettre à jour le compte existant
        _savedAccounts[index] = user;
      } else {
        // Ajouter un nouveau compte
        _savedAccounts.add(user);
      }

      // Sauvegarder dans le stockage local
      SharedPreferences prefs = await Http().local();
      await prefs.setString(
        'auth_user_list',
        jsonEncode(_savedAccounts.map((e) => e.toMap()).toList()),
      );

      notifyListeners();

    } catch (e) {
      if (kDebugMode) {
        print('❌ Error adding to saved accounts: $e');
      }
    }
  }

  /// Retirer des comptes sauvegardés
  Future<void> _removeFromSavedAccounts(UserModel user) async {
    try {
      _savedAccounts.removeWhere((acc) => acc.id == user.id);

      SharedPreferences prefs = await Http().local();
      await prefs.setString(
        'auth_user_list',
        jsonEncode(_savedAccounts.map((e) => e.toMap()).toList()),
      );

      notifyListeners();

    } catch (e) {
      if (kDebugMode) {
        print('❌ Error removing from saved accounts: $e');
      }
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
      if (kDebugMode) {
        print('❌ Error getting device details: $e');
      }
      return null;
    }
    return null;
  }

  // ==================== HELPER METHODS ====================

  /// Vider toutes les données
  Future<void> clearAllData() async {
    _currentUser = UserModel();
    _permissions = [];
    _savedAccounts = [];
    _currentSchool = {};
    _currentAcademic = {};
    _setErrorMessage('');

    SharedPreferences prefs = await Http().local();
    await prefs.remove('auth_user');
    await prefs.remove('auth_user_list');
    await prefs.remove('school');
    await prefs.remove('academic');

    notifyListeners();
  }
}

final authProvider = AuthProvider.instance;