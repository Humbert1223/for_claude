import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:novacole/pages/quiz/models/quiz_user_model.dart';
import 'package:novacole/pages/quiz/quiz_chapters_select.dart';
import 'package:novacole/pages/quiz/quiz_discipline_select.dart';
import 'package:novacole/pages/quiz/quiz_home_page.dart';
import 'package:novacole/pages/quiz/quiz_level_select.dart';
import 'package:novacole/pages/quiz/quiz_serie_select.dart';
import 'package:novacole/pages/quiz/quiz_user_selection_page.dart';
import 'package:novacole/pages/quiz/services/quiz_user_service.dart';

/// Clés des préférences joueur
class PreferenceKeys {
  static const level = 'level';
  static const series = 'series';
  static const discipline = 'discipline';
  static const chapters = 'chapters';
  static const isTimerEnabled = 'isTimerEnabled';
  static const isSoundEnabled = 'isSoundEnabled';
}

/// Page de configuration du quiz
///
/// Permet à le joueur de sélectionner ses préférences de jeu
class QuizSettingPage extends StatefulWidget {
  const QuizSettingPage({super.key});

  @override
  State<QuizSettingPage> createState() => _QuizSettingPageState();
}

class _QuizSettingPageState extends State<QuizSettingPage> {
  // Sélections de le joueur
  Map<String, dynamic>? _selectedLevel;
  Map<String, dynamic>? _selectedSeries;
  Map<String, dynamic>? _selectedDiscipline;
  List<Map<String, dynamic>> _selectedChapters = [];

  // Options
  bool _isTimerEnabled = false;
  bool _isSoundEnabled = false;

  // joueur actuel
  QuizUser? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  /// Charge le joueur actuel et ses préférences
  void _loadCurrentUser() {
    _currentUser = QuizUserService.getCurrentUser();
    if (_currentUser != null) {
      _loadPreferencesFromUser();
    }
  }

  /// Charge les préférences depuis le joueur
  void _loadPreferencesFromUser() {
    if (_currentUser?.preferences == null) return;

    final prefs = _currentUser!.preferences!;

    setState(() {
      _selectedLevel = _getPreference<Map<String, dynamic>>(
        prefs,
        PreferenceKeys.level,
      );
      _selectedSeries = _getPreference<Map<String, dynamic>>(
        prefs,
        PreferenceKeys.series,
      );
      _selectedDiscipline = _getPreference<Map<String, dynamic>>(
        prefs,
        PreferenceKeys.discipline,
      );
      for (var el
          in (_getPreference<List>(prefs, PreferenceKeys.chapters) ?? [])) {
        _selectedChapters.add(Map<String, dynamic>.from(el));
      }
      _isTimerEnabled = prefs[PreferenceKeys.isTimerEnabled] as bool? ?? false;
      _isSoundEnabled = prefs[PreferenceKeys.isSoundEnabled] as bool? ?? false;
    });
  }

  /// Récupère une préférence avec le type approprié
  T? _getPreference<T>(Map<String, dynamic> prefs, String key) {
    final value = prefs[key];
    if (value == null) return null;

    // Gérer spécialement les Maps pour faire une copie
    if (value is Map && T.toString().contains('Map')) {
      return Map<String, dynamic>.from(value) as T;
    }

    return value is T ? value : null;
  }

  /// Sauvegarde les préférences de le joueur
  Future<void> _savePreferences() async {
    if (_currentUser == null) return;

    final prefs = Map<String, dynamic>.from(_currentUser!.preferences ?? {});

    // Sauvegarder les sélections
    if (_selectedLevel != null) {
      prefs[PreferenceKeys.level] = _selectedLevel;
    }
    if (_selectedSeries != null) {
      prefs[PreferenceKeys.series] = _selectedSeries;
    }
    if (_selectedDiscipline != null) {
      prefs[PreferenceKeys.discipline] = _selectedDiscipline;
    }
    prefs[PreferenceKeys.chapters] = _selectedChapters;

    // Retirer la série si le niveau n'est pas lycée
    if (_selectedLevel != null && _selectedLevel!['degree'] != 'high_school') {
      prefs.remove(PreferenceKeys.series);
      _selectedSeries = null;
    }

    // Sauvegarder les options
    prefs[PreferenceKeys.isTimerEnabled] = _isTimerEnabled;
    prefs[PreferenceKeys.isSoundEnabled] = _isSoundEnabled;

    _currentUser!.preferences = prefs;
    await QuizUserService.updateUser(_currentUser!);

    if (mounted) {
      setState(() {});
    }
  }

  /// Met à jour le niveau sélectionné
  Future<void> _updateSelectedLevel(Map<String, dynamic> level) async {
    setState(() => _selectedLevel = level);
    await _savePreferences();
  }

  /// Met à jour la série sélectionnée
  Future<void> _updateSelectedSeries(Map<String, dynamic> series) async {
    setState(() => _selectedSeries = series);
    await _savePreferences();
  }

  /// Met à jour la discipline sélectionnée
  Future<void> _updateSelectedDiscipline(
    Map<String, dynamic> discipline,
  ) async {
    setState(() => _selectedDiscipline = discipline);
    await _savePreferences();
  }

  /// Met à jour les chapitres sélectionnés
  Future<void> _updateSelectedChapters(
    List<Map<String, dynamic>> chapters,
  ) async {
    setState(() => _selectedChapters = chapters);
    await _savePreferences();
  }

  /// Change d'joueur
  Future<void> _changeUser() async {
    await QuizUserService.logout();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const QuizUserSelectionPage()),
      );
    }
  }

  /// Bascule le chronomètre
  Future<void> _toggleTimer() async {
    setState(() => _isTimerEnabled = !_isTimerEnabled);
    await _savePreferences();
  }

  /// Bascule le son
  Future<void> _toggleSound() async {
    setState(() => _isSoundEnabled = !_isSoundEnabled);
    await _savePreferences();
  }

  /// Navigation vers la sélection de niveau
  Future<void> _navigateToLevelSelect() async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(builder: (context) => const QuizLevelSelect()),
    );
    if (result != null) {
      await _updateSelectedLevel({'id': result['id'], 'name': result['name']});
      await _updateSelectedChapters([]);
    }
  }

  /// Navigation vers la sélection de série
  Future<void> _navigateToSeriesSelect() async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(builder: (context) => const QuizSerieSelect()),
    );
    if (result != null) {
      await _updateSelectedSeries({'id': result['id'], 'name': result['name']});
      await _updateSelectedChapters([]);
    }
  }

  /// Navigation vers la sélection de discipline
  Future<void> _navigateToDisciplineSelect() async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(builder: (context) => const QuizDisciplineSelect()),
    );
    if (result != null) {
      await _updateSelectedDiscipline({'id': result['id'], 'name': result['name']});
      await _updateSelectedChapters([]);
    }
  }

  /// Navigation vers la sélection de chapitres
  Future<void> _navigateToChaptersSelect() async {
    final result = await Navigator.of(context).push<List<Map<String, dynamic>>>(
      MaterialPageRoute(
        builder: (context) => QuizChaptersSelect(
          disciplineId: _selectedDiscipline?['id'],
          serieId: _selectedSeries?['id'],
          levelId: _selectedLevel?['id'],
          values: _selectedChapters,
        ),
      ),
    );
    if (result != null) {
      await _updateSelectedChapters(_mapResult(result));
    }
  }

  List<Map<String, dynamic>> _mapResult(result) {
    return (result ?? [])
        .map<Map<String, dynamic>>(
          (e) => Map<String, dynamic>.from({'id': e['id'], 'name': e['name']}),
        )
        .toList();
  }

  /// Retour à la page d'accueil
  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const QuizHomePage()),
    );
  }

  /// Vérifie si le niveau sélectionné est lycée
  bool get _isHighSchoolLevel => _selectedLevel?['degree'] == 'high_school';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: _buildBackButton(),
    );
  }

  /// Construit le corps de la page
  Widget _buildBody() {
    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/quiz_background.jpeg'),
          fit: BoxFit.cover,
          opacity: 0.2,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            if (_currentUser != null) _buildUserHeader(),
            const Divider(),
            Expanded(child: _buildSettings()),
          ],
        ),
      ),
    );
  }

  /// Construit l'en-tête joueur
  Widget _buildUserHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          _buildUserAvatar(),
          const SizedBox(width: 12),
          Expanded(child: _buildUserInfo()),
          _buildChangeUserButton(),
        ],
      ),
    );
  }

  /// Construit l'avatar de le joueur
  Widget _buildUserAvatar() {
    return CircleAvatar(
      radius: 30,
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: Text(
        _currentUser!.name[0].toUpperCase(),
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  /// Construit les informations de le joueur
  Widget _buildUserInfo() {
    final gamesCount = _currentUser!.scores?.length ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _currentUser!.name,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          '$gamesCount ${gamesCount <= 1 ? "partie jouée" : "parties jouées"}',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  /// Construit le bouton de changement d'joueur
  Widget _buildChangeUserButton() {
    return IconButton(
      onPressed: _changeUser,
      icon: const Icon(Icons.swap_horiz, size: 30),
      tooltip: 'Changer de joueur',
    );
  }

  /// Construit la section des paramètres
  Widget _buildSettings() {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLevelButton(),
              if (_isHighSchoolLevel) ...[
                const SizedBox(height: 20),
                _buildSeriesButton(),
              ],
              const SizedBox(height: 20),
              _buildDisciplineButton(),
              const SizedBox(height: 20),
              _buildChaptersButton(),
              const SizedBox(height: 20),
              _buildTimerButton(),
              const SizedBox(height: 20),
              _buildSoundButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// Construit le bouton de sélection de niveau
  Widget _buildLevelButton() {
    return QuizGameButton(
      onPressed: _navigateToLevelSelect,
      child: _buildSettingTile(
        title: 'NIVEAU',
        subtitle: _selectedLevel?['name'] ?? '[Sélectionner un niveau]',
      ),
    );
  }

  /// Construit le bouton de sélection de série
  Widget _buildSeriesButton() {
    return QuizGameButton(
      onPressed: _navigateToSeriesSelect,
      child: _buildSettingTile(
        title: 'SÉRIE',
        subtitle: _selectedSeries?['name'] ?? '[Sélectionner une série]',
        titleSize: 16,
      ),
    );
  }

  /// Construit le bouton de sélection de discipline
  Widget _buildDisciplineButton() {
    return QuizGameButton(
      onPressed: _navigateToDisciplineSelect,
      child: _buildSettingTile(
        title: 'DISCIPLINE',
        subtitle:
            _selectedDiscipline?['name'] ?? '[Sélectionner une discipline]',
        titleSize: 16,
      ),
    );
  }

  /// Construit le bouton de sélection de chapitres
  Widget _buildChaptersButton() {
    final subtitle = _selectedChapters.isNotEmpty
        ? "${_selectedChapters.length} sélectionné${_selectedChapters.length > 1 ? 's' : ''}"
        : '[Sélectionner les chapitres]';

    return QuizGameButton(
      onPressed: _navigateToChaptersSelect,
      child: _buildSettingTile(
        title: 'CHAPITRES',
        subtitle: subtitle,
        titleSize: 16,
      ),
    );
  }

  /// Construit le bouton du chronomètre
  Widget _buildTimerButton() {
    return QuizGameButton(
      onPressed: _toggleTimer,
      child: _buildToggleTile(
        title: 'CHRONOMÈTRER',
        value: _isTimerEnabled,
        onChanged: (value) async {
          setState(() => _isTimerEnabled = value);
          await _savePreferences();
        },
      ),
    );
  }

  /// Construit le bouton du son
  Widget _buildSoundButton() {
    return QuizGameButton(
      onPressed: _toggleSound,
      child: _buildToggleTile(
        title: 'SON ET MUSIQUE',
        value: _isSoundEnabled,
        onChanged: (value) async {
          setState(() => _isSoundEnabled = value);
          await _savePreferences();
        },
      ),
    );
  }

  /// Construit une tile de paramètre standard
  Widget _buildSettingTile({
    required String title,
    required String subtitle,
    double titleSize = 20,
  }) {
    return ListTile(
      leading: const Icon(Icons.double_arrow, color: Colors.white, size: 30),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: titleSize,
        ),
      ),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white)),
    );
  }

  /// Construit une tile avec toggle
  Widget _buildToggleTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: const Icon(Icons.double_arrow, color: Colors.white),
      title: Row(
        children: [
          Expanded(
            child: Text(title, style: const TextStyle(color: Colors.white)),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
          ),
        ],
      ),
    );
  }

  /// Construit le bouton de retour
  Widget _buildBackButton() {
    return FloatingActionButton(
      heroTag: 'backBtn',
      onPressed: _navigateToHome,
      child: const RotatedBox(
        quarterTurns: 2,
        child: Icon(FontAwesomeIcons.shareFromSquare, color: Colors.red),
      ),
    );
  }
}
