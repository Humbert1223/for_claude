import 'package:hive/hive.dart';
import 'package:novacole/utils/hive-service.dart';
import 'package:uuid/uuid.dart';

import '../models/quiz_user_model.dart';

class QuizUserService {
  static const String _currentUserKey = 'quiz_current_user_id';
  static Box<QuizUser>? _userBox;
  static Box? _settingsBox;

  // Initialiser Hive
  static Future<void> init() async {
    _userBox = await HiveService.quizUserBox();
    _settingsBox = await HiveService.quizSettingBox();
  }

  // Créer un nouvel joueur
  static Future<QuizUser> createUser(String name, {String? avatarUrl}) async {
    final user = QuizUser(
      id: const Uuid().v4(),
      name: name,
      avatarUrl: avatarUrl,
      createdAt: DateTime.now(),
      preferences: {},
      scores: [],
    );
    await _userBox!.put(user.id, user);
    return user;
  }

  // Récupérer tous les joueurs
  static List<QuizUser> getAllUsers() {
    return _userBox!.values.toList();
  }

  // Récupérer un joueur par ID
  static QuizUser? getUserById(String id) {
    return _userBox!.get(id);
  }

  // Définir le joueur actuel
  static Future<void> setCurrentUser(String userId) async {
    await _settingsBox!.put(_currentUserKey, userId);
  }

  // Récupérer le joueur actuel
  static QuizUser? getCurrentUser() {
    final userId = _settingsBox!.get(_currentUserKey);
    if (userId != null) {
      return getUserById(userId);
    }
    return null;
  }

  // Supprimer un joueur
  static Future<void> deleteUser(String userId) async {
    await _userBox!.delete(userId);

    // Si c'était le joueur actuel, le retirer
    final currentUserId = _settingsBox!.get(_currentUserKey);
    if (currentUserId == userId) {
      await _settingsBox!.delete(_currentUserKey);
    }
  }

  // Mettre à jour un joueur
  static Future<void> updateUser(QuizUser user) async {
    await user.save();
  }

  // Vérifier si un joueur est sélectionné
  static bool hasCurrentUser() {
    return _settingsBox!.get(_currentUserKey) != null;
  }

  // Déconnecter (retirer le joueur actuel)
  static Future<void> logout() async {
    await _settingsBox!.delete(_currentUserKey);
  }
}