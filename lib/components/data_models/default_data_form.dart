import 'package:flutter/material.dart';
import 'package:novacole/components/empty_page.dart';
import 'package:novacole/components/json_schema.dart';
import 'package:novacole/components/loading_indicator.dart';
import 'package:novacole/models/form.dart';
import 'package:novacole/models/master_crud_model.dart';

/// Type pour la fonction de mutation des inputs
typedef InputItemMutator = List<Map<String, dynamic>> Function(
    List<Map<String, dynamic>> inputs,
    Map<String, dynamic>? data,
    );

/// Callback pour la sauvegarde réussie
typedef OnSavedCallback = void Function(Map<String, dynamic> result);

/// États possibles du formulaire
enum FormState {
  loading,
  loaded,
  empty,
  error,
}

/// Widget de formulaire générique pour la création et modification de données
///
/// Charge dynamiquement un formulaire JSON et gère la soumission des données
class DefaultDataForm extends StatefulWidget {
  const DefaultDataForm({
    super.key,
    required this.dataModel,
    required this.title,
    this.inputsMutator,
    this.defaultData,
    this.data,
    this.onSaved,
  });

  /// Nom du modèle de données (entity)
  final String dataModel;

  /// Titre affiché dans l'AppBar
  final String title;

  /// Fonction pour transformer les inputs avant affichage
  final InputItemMutator? inputsMutator;

  /// Données par défaut à inclure lors de la soumission
  final Map<String, dynamic>? defaultData;

  /// Données existantes (mode édition)
  final Map<String, dynamic>? data;

  /// Callback appelé après une sauvegarde réussie
  final OnSavedCallback? onSaved;

  /// Détermine si on est en mode édition
  bool get isEditMode => data != null && data!['id'] != null;

  @override
  State<DefaultDataForm> createState() => _DefaultDataFormState();
}

class _DefaultDataFormState extends State<DefaultDataForm> {
  FormState _formState = FormState.loading;
  Map<String, dynamic>? _formSchema;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadForm();
  }

  /// Charge le schéma du formulaire depuis l'API
  Future<void> _loadForm() async {
    if (!mounted) return;

    setState(() {
      _formState = FormState.loading;
      _errorMessage = null;
    });

    try {
      final result = await CoreForm().get(entity: widget.dataModel);

      if (!mounted) return;

      if (result == null) {
        setState(() {
          _formState = FormState.empty;
          _errorMessage = 'Aucun formulaire disponible';
        });
        return;
      }

      // Préparer les inputs du formulaire
      List<Map<String, dynamic>> inputs =
      List<Map<String, dynamic>>.from(result['inputs']);

      // Appliquer la mutation personnalisée si fournie
      if (widget.inputsMutator != null) {
        inputs = widget.inputsMutator!(inputs, widget.data);
      }


      // Pré-remplir avec les données par default
      if (widget.defaultData != null) {
        inputs = _populateInputsDefaultData(inputs, widget.defaultData!);
      }

      // Pré-remplir avec les données existantes (mode édition)
      if (widget.data != null) {
        inputs = _populateInputsWithData(inputs, widget.data!);
      }

      setState(() {
        _formSchema = {
          ...result,
          'inputs': inputs,
        };
        _formState = FormState.loaded;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _formState = FormState.error;
        _errorMessage = 'Erreur lors du chargement du formulaire: $e';
      });
    }
  }

  /// Remplit les inputs avec les données existantes
  List<Map<String, dynamic>> _populateInputsWithData(
      List<Map<String, dynamic>> inputs,
      Map<String, dynamic> data,
      ) {
    return inputs.map((input) {
      final fieldName = input['field'] as String?;
      if (fieldName != null && data.containsKey(fieldName)) {
        return {
          ...input,
          'value': data[fieldName],
        };
      }
      return input;
    }).toList();
  }

  /// Remplit les inputs avec les données existantes
  List<Map<String, dynamic>> _populateInputsDefaultData(
      List<Map<String, dynamic>> inputs,
      Map<String, dynamic> data,
      ) {
    return inputs.map((input) {
      final fieldName = input['field'] as String?;
      if (fieldName != null && data.containsKey(fieldName)) {
        return {
          ...input,
          'value': input[fieldName] ?? data[fieldName],
        };
      }
      return input;
    }).toList();
  }

  /// Prépare les données du formulaire pour la soumission
  Map<String, dynamic> _prepareFormData(Map<String, dynamic> filledForm) {
    final formData = <String, dynamic>{
      'form_id': filledForm['id'],
      'entity': filledForm['entity'],
    };

    // Ajouter les données par défaut
    if (widget.defaultData != null) {
      formData.addAll(widget.defaultData!);
    }

    // Ajouter les valeurs des inputs
    final inputs = List<Map<String, dynamic>>.from(filledForm['inputs']);
    for (final input in inputs) {
      final field = input['field'] as String?;
      if (field == null) continue;

      final value = input['value'];
      if (value != null) {
        formData[field] = value;
      } else if (widget.defaultData?.containsKey(field) ?? false) {
        formData[field] = widget.defaultData![field];
      }
    }

    return formData;
  }

  /// Gère la sauvegarde du formulaire (création ou mise à jour)
  Future<void> _handleSave(Map<String, dynamic> filledForm) async {
    final formData = _prepareFormData(filledForm);
    final entity = filledForm['entity'] as String;
    final model = MasterCrudModel(entity);

    // Afficher le loading
    _showLoadingDialog();

    try {
      Map<String, dynamic>? result;

      if (widget.isEditMode) {
        // Mode édition
        result = await model.update(widget.data!['id'], formData);
      } else {
        // Mode création
        result = await model.create(formData);
      }

      // Fermer le loading
      if (mounted) Navigator.of(context).pop();

      if (result != null) {
        // Notifier le callback si fourni
        widget.onSaved?.call(result);

        // Fermer le formulaire
        if (mounted) {
          Navigator.of(context).pop(result);
        }
      } else {
        // Afficher un message d'erreur si la sauvegarde a échoué
        if (mounted) {
          _showErrorSnackBar('Échec de l\'enregistrement');
        }
      }
    } catch (e) {
      // Fermer le loading
      if (mounted) Navigator.of(context).pop();

      // Afficher l'erreur
      if (mounted) {
        _showErrorSnackBar('Erreur: $e');
      }
    }
  }

  /// Affiche une boîte de dialogue de chargement
  void _showLoadingDialog() {
    showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => const _LoadingBottomSheet(),
    );
  }

  /// Affiche un message d'erreur via SnackBar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _loadForm,
        child: SafeArea(
          child: _buildBody(),
        ),
      ),
    );
  }

  /// Construit l'AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      centerTitle: true,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      title: Text(
        widget.title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// Construit le corps du widget selon l'état
  Widget _buildBody() {
    switch (_formState) {
      case FormState.loading:
        return const Center(child: LoadingIndicator());

      case FormState.loaded:
        return _buildFormContent();

      case FormState.empty:
        return _buildEmptyState();

      case FormState.error:
        return _buildErrorState();
    }
  }

  /// Construit le contenu du formulaire
  Widget _buildFormContent() {
    if (_formSchema == null) return const EmptyPage();

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        child: JsonSchema(
          form: _formSchema!,
          actionSave: _handleSave,
        ),
      ),
    );
  }

  /// Construit l'état vide
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const EmptyPage(),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _errorMessage!,
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadForm,
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
          ),
        ],
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
              onPressed: _loadForm,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget de la bottom sheet de chargement
class _LoadingBottomSheet extends StatelessWidget {
  const _LoadingBottomSheet();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: const Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LoadingIndicator(),
            SizedBox(height: 16),
            Text(
              'Enregistrement en cours...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}