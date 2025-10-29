import 'package:flutter/material.dart';
import 'package:novacole/components/loading_indicator.dart';
import 'package:novacole/models/master_crud_model.dart';
import 'package:novacole/utils/constants.dart';

/// États possibles de la page de sélection de chapitres
enum ChapterLoadState {
  loading,
  loaded,
  error,
  empty,
}

/// Page de sélection de chapitres pour le quiz
///
/// Permet de sélectionner plusieurs chapitres basés sur la discipline,
/// la série et le niveau choisis
class QuizChaptersSelect extends StatefulWidget {
  const QuizChaptersSelect({
    super.key,
    this.disciplineId,
    this.serieId,
    this.levelId,
    this.values
  });

  /// ID de la discipline sélectionnée
  final String? disciplineId;

  /// ID de la série sélectionnée
  final String? serieId;

  /// ID du niveau sélectionné
  final String? levelId;

  final List<Map<String, dynamic>>? values;

  @override
  State<QuizChaptersSelect> createState() => _QuizChaptersSelectState();
}

class _QuizChaptersSelectState extends State<QuizChaptersSelect> {
  ChapterLoadState _loadState = ChapterLoadState.loading;
  List<Map<String, dynamic>> _chapters = [];
  List<Map<String, dynamic>> _selectedChapters = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchChapters();
    _selectedChapters = widget.values ?? [];
  }

  Future<void> _fetchChapters() async {
    if (!mounted) return;

    setState(() {
      _loadState = ChapterLoadState.loading;
      _errorMessage = null;
    });

    try {
      final filters = _buildFilters();
      final result = await MasterCrudModel(Entity.chapter).search(
        paginate: '0',
        filters: filters,
      );

      if (!mounted) return;

      // Fix: Ensure all maps are properly typed
      final chapters = List<Map<String, dynamic>>.from(result);

      setState(() {
        _chapters = chapters;
        _loadState = chapters.isEmpty
            ? ChapterLoadState.empty
            : ChapterLoadState.loaded;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loadState = ChapterLoadState.error;
        _errorMessage = 'Erreur lors du chargement des chapitres: $e';
      });

      debugPrint('Error fetching chapters: $e');
    }
  }

  /// Construit les filtres pour la requête
  List<Map<String, dynamic>> _buildFilters() {
    final filters = <Map<String, dynamic>>[];

    if (widget.disciplineId != null) {
      filters.add({
        'field': 'discipline_id',
        'value': widget.disciplineId,
      });
    }

    if (widget.serieId != null) {
      filters.add({
        'field': 'serie_id',
        'value': widget.serieId,
      });
    }

    if (widget.levelId != null) {
      filters.add({
        'field': 'level_id',
        'value': widget.levelId,
      });
    }

    return filters;
  }

  /// Bascule la sélection d'un chapitre
  void _toggleChapterSelection(Map<String, dynamic> chapter, bool isSelected) {
    setState(() {
      if (isSelected) {
        if (!_selectedChapters.any((c) => c['id'] == chapter['id'])) {
          _selectedChapters.add(Map<String, dynamic>.from(chapter));
        }
      } else {
        _selectedChapters.removeWhere((c) => c['id'] == chapter['id']);
      }
    });
  }

  /// Bascule entre tout sélectionner et tout désélectionner
  void _toggleSelectAll() {
    setState(() {
      if (_selectedChapters.length == _chapters.length) {
        _selectedChapters.clear();
      } else {
        _selectedChapters = _chapters.map((e) => Map<String, dynamic>.from(e)).toList();
      }
    });
  }

  /// Valide et retourne les chapitres sélectionnés
  void _validateSelection() {
    if (_selectedChapters.isEmpty) {
      _showErrorSnackBar('Veuillez sélectionner au moins un chapitre');
      return;
    }

    Navigator.of(context).pop(_selectedChapters);
  }

  /// Affiche un message d'erreur
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  /// Construit l'AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Sélectionner les chapitres'),
      centerTitle: true,
    );
  }

  /// Construit le corps de la page selon l'état
  Widget _buildBody() {
    switch (_loadState) {
      case ChapterLoadState.loading:
        return const Center(child: LoadingIndicator());

      case ChapterLoadState.loaded:
        return _buildChapterSelection();

      case ChapterLoadState.empty:
        return _buildEmptyState();

      case ChapterLoadState.error:
        return _buildErrorState();
    }
  }

  /// Construit l'interface de sélection des chapitres
  Widget _buildChapterSelection() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: _buildCheckboxGroup(),
          ),
        ),
        _buildValidateButton(),
      ],
    );
  }

  /// Construit le groupe de checkboxes
  Widget _buildCheckboxGroup() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Chapitres',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: _toggleSelectAll,
                child: Text(
                  _selectedChapters.length == _chapters.length
                      ? 'Tout désélectionner'
                      : 'Tout sélectionner',
                ),
              ),
            ],
          ),
        ),
        if (_chapters.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text('Aucun chapitre disponible'),
            ),
          )
        else
          ..._chapters.map<Widget>((chapter) => _buildCheckboxItem(chapter)),
      ],
    );
  }

  /// Construit un élément checkbox individuel
  Widget _buildCheckboxItem(Map<String, dynamic> chapter) {
    final chapterId = chapter['id'];
    final isSelected = _selectedChapters.any((c) => c['id'] == chapterId);
    final chapterName = chapter['name'] as String? ?? 'Sans nom';

    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: CheckboxListTile(
        title: Text(chapterName),
        value: isSelected,
        onChanged: (bool? value) {
          _toggleChapterSelection(chapter, value ?? false);
        },
        activeColor: Theme.of(context).colorScheme.primary,
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }

  /// Construit le bouton de validation
  Widget _buildValidateButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: _validateSelection,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          'Valider (${_selectedChapters.length} sélectionné${_selectedChapters.length > 1 ? 's' : ''})',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// Construit l'état vide
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun chapitre disponible',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Il n\'y a pas de chapitres pour les critères sélectionnés',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchChapters,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  /// Construit l'état d'erreur
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Une erreur est survenue',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchChapters,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}