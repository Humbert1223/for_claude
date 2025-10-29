import 'dart:convert';

import 'package:get/get.dart';
import 'package:novacole/controllers/auth_controller.dart';

class UserModel {
  final String? gender;
  final String? name;
  final String? title;
  final String? email;
  final String? phone;
  final String? photo;
  final String? avatar;
  final String? id;
  final String? accountType;
  final String? academic;
  final String? school;
  final String? countryIso;
  final List<Map<String, dynamic>>? schools;
  final String? token;
  final int? smsWallet;
  final List<String>? preferredChannels;
  final List<String>? permissions; // NOUVEAU: Propriété pour les permissions

  const UserModel({
    this.academic,
    this.school,
    this.gender,
    this.name,
    this.title,
    this.email,
    this.id,
    this.accountType,
    this.avatar,
    this.token,
    this.phone,
    this.photo,
    this.preferredChannels,
    this.smsWallet,
    this.schools,
    this.countryIso,
    this.permissions, // NOUVEAU
  });

  /// Créer un UserModel depuis une Map (réponse API)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      gender: map['gender'],
      name: map['name'],
      title: map['title'],
      email: map['email'],
      avatar: map['avatar'],
      accountType: map['account_type'],
      phone: map['phone'],
      photo: map['photo'],
      id: map['id'],
      token: map['token'],
      academic: map['academic_id'],
      countryIso: map['country_iso'],
      school: map['school_id'],
      smsWallet: map['sms_wallet'],
      schools: map['schools'] != null
          ? List<Map<String, dynamic>>.from(map['schools'])
          : null,
      preferredChannels: map['preferred_channels'] != null
          ? List<String>.from(map['preferred_channels'])
          : null,
      // IMPORTANT: Parser les permissions depuis 'permission_names'
      permissions: map['permission_names'] != null
          ? List<String>.from(map['permission_names'])
          : null,
    );
  }

  /// Convertir le UserModel en Map (pour stockage local)
  Map<String, dynamic> toMap() {
    return {
      'gender': gender,
      'name': name,
      'title': title,
      'email': email,
      'id': id,
      'account_type': accountType,
      'avatar': avatar,
      'token': token,
      'phone': phone,
      'photo': photo,
      'academic_id': academic,
      'school_id': school,
      'preferred_channels': preferredChannels,
      'schools': schools,
      'sms_wallet': smsWallet,
      'country_iso': countryIso,
      'permission_names': permissions, // Sauvegarder les permissions
    };
  }

  /// Créer une copie avec des modifications
  UserModel copyWith({
    String? gender,
    String? name,
    String? title,
    String? email,
    String? phone,
    String? photo,
    String? avatar,
    String? id,
    String? accountType,
    String? academic,
    String? school,
    String? countryIso,
    List<Map<String, dynamic>>? schools,
    String? token,
    int? smsWallet,
    List<String>? preferredChannels,
    List<String>? permissions,
  }) {
    return UserModel(
      gender: gender ?? this.gender,
      name: name ?? this.name,
      title: title ?? this.title,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photo: photo ?? this.photo,
      avatar: avatar ?? this.avatar,
      id: id ?? this.id,
      accountType: accountType ?? this.accountType,
      academic: academic ?? this.academic,
      school: school ?? this.school,
      countryIso: countryIso ?? this.countryIso,
      schools: schools ?? this.schools,
      token: token ?? this.token,
      smsWallet: smsWallet ?? this.smsWallet,
      preferredChannels: preferredChannels ?? this.preferredChannels,
      permissions: permissions ?? this.permissions,
    );
  }

  /// Vérifier si l'utilisateur a une permission spécifique
  bool hasPermission(String permission) {
    return !isAccountType('staff') || (permissions?.contains(permission) ?? false);
  }

  /// Vérifier si l'utilisateur a au moins une permission parmi la liste
  bool hasAnyPermission(List<String> perms) {
    return !isAccountType('staff') || perms.any((p) => permissions?.contains(p) ?? false);
  }

  /// Vérifier si l'utilisateur a toutes les permissions de la liste
  bool hasAllPermissions(List<String> perms) {
    return !isAccountType('staff') || perms.every((p) => permissions?.contains(p) ?? false);
  }

  /// Vérifier si l'utilisateur a un type de compte spécifique
  bool isAccountType(String type) {
    return accountType == type;
  }

  /// Vérifier si l'utilisateur appartient à une école spécifique
  bool belongsToSchool(String schoolId) {
    if (schools == null) return false;
    return schools!.any((s) => s['school_id'] == schoolId);
  }

  /// Obtenir tous les types de comptes de l'utilisateur
  List<String> getAccountTypes() {
    if (schools == null) return [];
    return schools!
        .map((s) => s['account_type'] as String?)
        .whereType<String>()
        .toSet()
        .toList();
  }

  /// Obtenir toutes les écoles de l'utilisateur
  List<String> getSchoolIds() {
    if (schools == null) return [];
    return schools!
        .map((s) => s['school_id'] as String?)
        .whereType<String>()
        .toList();
  }

  /// Vérifier si l'utilisateur est admin
  bool get isAdmin {
    return hasAnyPermission([
      'access_admin',
      'manage_permissions',
      'super_admin',
    ]);
  }

  /// Vérifier si l'utilisateur a un token valide
  bool get hasValidToken {
    return token != null && token!.isNotEmpty;
  }

  /// Obtenir le nombre de permissions
  int get permissionCount {
    return permissions?.length ?? 0;
  }

  /// Obtenir les initiales de l'utilisateur
  String get initials {
    if (name == null || name!.isEmpty) return '?';
    final parts = name!.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name![0].toUpperCase();
  }

  /// Obtenir le nom complet formaté
  String get fullName {
    if (title != null && title!.isNotEmpty) {
      return '$title $name';
    }
    return name ?? 'Utilisateur';
  }

  /// Obtenir l'URL de l'avatar ou photo
  String? get profileImageUrl {
    return avatar ?? photo;
  }

  /// Vérifier si l'utilisateur est complet (toutes les infos requises)
  bool get isComplete {
    return name != null &&
        email != null &&
        id != null &&
        token != null;
  }

  /// Convertir en JSON String
  String toJson() {
    return jsonEncode(toMap());
  }

  /// Créer depuis JSON String
  factory UserModel.fromJson(String jsonStr) {
    return UserModel.fromMap(jsonDecode(jsonStr));
  }

  /// Méthode toString pour le debug
  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, '
        'accountType: $accountType, permissions: ${permissions?.length ?? 0}, '
        'schools: ${schools?.length ?? 0})';
  }

  /// Méthode pour comparer deux utilisateurs
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  /// Créer un utilisateur vide (pour les tests)
  factory UserModel.empty() {
    return const UserModel(
      id: null,
      name: null,
      email: null,
      token: null,
      permissions: [],
    );
  }

  static Future<UserModel?> fromLocalStorage() async {
    final authController = Get.find<AuthController>();
    return authController.currentUser.value;
  }

}

/// Extension pour faciliter l'utilisation du UserModel
extension UserModelExtension on UserModel? {
  /// Vérifier si l'utilisateur existe et est valide
  bool get isValid {
    return this != null && this!.isComplete;
  }

  /// Obtenir le nom ou une valeur par défaut
  String nameOr(String defaultValue) {
    return this?.name ?? defaultValue;
  }

  /// Obtenir l'email ou une valeur par défaut
  String emailOr(String defaultValue) {
    return this?.email ?? defaultValue;
  }

  /// Vérifier une permission de manière sûre
  bool hasPermissionSafe(String permission) {
    return this?.hasPermission(permission) ?? false;
  }
}
