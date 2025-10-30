import 'package:flutter/material.dart';
import 'package:novacole/components/form_inputs/input_bool.dart';
import 'package:novacole/components/form_inputs/input_date.dart';
import 'package:novacole/components/form_inputs/input_date_time.dart';
import 'package:novacole/components/form_inputs/input_file.dart';
import 'package:novacole/components/form_inputs/input_multi_select.dart';
import 'package:novacole/components/form_inputs/input_select.dart';
import 'package:novacole/components/form_inputs/input_text.dart';
import 'package:novacole/components/form_inputs/input_time.dart';
import 'package:novacole/components/form_inputs/input_upload.dart';
import 'package:novacole/components/my_button.dart';

class JsonSchema extends StatefulWidget {
  const JsonSchema({
    super.key,
    required this.form,
    this.errorMessages = const {},
    required this.actionSave,
    this.actionDraft,
    this.hiddenFields,
    this.saveButtonText,
    this.draftButtonText,
  });

  final Map<String, dynamic> errorMessages;
  final Map<String, dynamic> form;
  final Function actionSave;
  final Function? actionDraft;
  final List<String>? hiddenFields;
  final String? saveButtonText;
  final String? draftButtonText;

  @override
  State<JsonSchema> createState() => _JsonSchemaState();
}

class _JsonSchemaState extends State<JsonSchema> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, dynamic> _formData;

  @override
  void initState() {
    super.initState();
    _formData = Map<String, dynamic>.from(widget.form);
  }

  @override
  void didUpdateWidget(JsonSchema oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.form != widget.form) {
      setState(() {
        _formData = Map<String, dynamic>.from(widget.form);
      });
    }
  }

  /// Vérifie si un champ doit être affiché
  bool _shouldShowField(Map<String, dynamic> item) {
    // Masquer si dans hiddenFields
    if (widget.hiddenFields?.contains(item['field']) ?? false) {
      return false;
    }
    // Masquer si hidden = true
    if (item['hidden'] == true) {
      return false;
    }
    return true;
  }

  /// Met à jour la valeur d'un input
  void _updateInputValue(int index, dynamic value, String? name) {
    if (!mounted) return;

    setState(() {
      _formData['inputs'][index]['value'] = value;

      // Pour les fichiers/photos, mettre à jour le label
      if (name != null && ['file', 'photo', 'upload'].contains(_formData['inputs'][index]['type'])) {
        _formData['inputs'][index]['inputLabel'] = name;
      }
    });
  }

  /// Construit la liste des widgets de formulaire
  List<Widget> _buildFormInputs() {
    final List<Widget> widgets = [];
    final inputs = _formData['inputs'] as List;

    for (int i = 0; i < inputs.length; i++) {
      final item = inputs[i] as Map<String, dynamic>;

      if (!_shouldShowField(item)) {
        continue;
      }

      // Initialiser la valeur pour les booléens
      if (item['type'] == 'boolean' && item['value'] == null) {
        _formData['inputs'][i]['value'] = false;
      }

      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: ModelInputMutator(
            key: ValueKey('${item['field']}_$i'),
            initialValue: _formData['inputs'][i]['value'],
            item: item,
            onChange: (value, name) => _updateInputValue(i, value, name),
          ),
        ),
      );
    }

    return widgets;
  }

  /// Construit les boutons d'action
  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Bouton Brouillon (optionnel)
          if (widget.actionDraft != null) ...[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: OutlinedButton(
                  onPressed: () => widget.actionDraft!(_formData),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14.0),
                  ),
                  child: Text(
                    widget.draftButtonText ?? 'Brouillon',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ],

          // Bouton Enregistrer
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: widget.actionDraft != null ? 8.0 : 0,
              ),
              child: MyButton(
                onTap: _handleSave,
                buttonText: widget.saveButtonText ?? "Enregistrer",
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Gère la sauvegarde du formulaire
  void _handleSave() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.actionSave(_formData);
    }
  }

  @override
  Widget build(BuildContext context) {
    final inputs = _buildFormInputs();

    // Si aucun input visible, ne rien afficher
    if (inputs.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'Aucun champ disponible',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.disabled,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            ...inputs,
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }
}

class ModelInputMutator extends StatelessWidget {
  final Function? onChange;
  final Map<String, dynamic> item;
  final dynamic initialValue;
  final bool? showPrefix;
  final bool? showLabel;

  const ModelInputMutator({
    super.key,
    this.onChange,
    required this.item,
    this.initialValue,
    this.showPrefix = true,
    this.showLabel = true,
  });

  /// Détermine le type d'input et retourne le widget approprié
  @override
  Widget build(BuildContext context) {
    final inputType = item['type'] as String?;

    if (inputType == null) {
      return const SizedBox.shrink();
    }

    // Inputs textuels
    if (_isTextInput(inputType)) {
      return _buildTextInput();
    }

    // Input booléen (switch)
    if (inputType == 'boolean') {
      return _buildBooleanInput();
    }

    // Multi-sélection (checkboxes)
    if (inputType == 'multiselect') {
      return _buildMultiSelectInput();
    }

    // Sélecteurs (select, radio, resource)
    if (_isSelectInput(inputType)) {
      return _buildSelectInput();
    }

    // Input date
    if (inputType == 'date') {
      return _buildDateInput();
    }

    // Input datetime
    if (inputType == 'datetime') {
      return _buildDateTimeInput();
    }

    // Input time
    if (inputType == 'time') {
      return _buildTimeInput();
    }

    // Input fichier/photo
    if (inputType == 'photo' || inputType == 'upload') {
      return _buildUploadInput();
    }

    if (inputType == 'file') {
      return _buildFileInput();
    }

    // Type inconnu
    return const SizedBox.shrink();
  }

  /// Vérifie si c'est un input textuel
  bool _isTextInput(String type) {
    return [
      'text', 'tel', 'phone', 'email', 'number',
      'password', 'longtext', 'currency', 'textarea',
      'richtext', 'stringArray', 'address'
    ].contains(type);
  }

  /// Vérifie si c'est un input de sélection
  bool _isSelectInput(String type) {
    return [
      'select', 'selectresource', 'resource',
      'multiresource', 'radio'
    ].contains(type);
  }

  /// Construit un input textuel
  Widget _buildTextInput() {
    return ModelFormInputText(
      item: item,
      showPrefix: showPrefix,
      initialValue: item['value'] ?? '',
      isRequired: 'Le champ ${item["name"]} est obligatoire',
      onChange: (String value) => onChange?.call(value, null),
    );
  }

  /// Construit un input booléen
  Widget _buildBooleanInput() {
    return ModelFormInputBool(
      item: {
        ...item,
        'value': initialValue ?? false,
      },
      showLabel: showLabel,
      onChange: (bool value) => onChange?.call(value, null),
    );
  }

  /// Construit un multi-select (checkboxes)
  Widget _buildMultiSelectInput() {
    final options = item['options'] as List? ?? [];

    return Container(
      margin: const EdgeInsets.only(top: 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item['name'] ?? '',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
          const SizedBox(height: 8),
          ...options.map((option) => CheckboxListTile(
            title: Text(option.toString()),
            value: (initialValue as List?)?.contains(option) ?? false,
            onChanged: (bool? value) {
              final currentValues = List.from((initialValue as List?) ?? []);
              if (value == true) {
                if (!currentValues.contains(option)) {
                  currentValues.add(option);
                }
              } else {
                currentValues.remove(option);
              }
              onChange?.call(currentValues, null);
            },
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          )),
        ],
      ),
    );
  }

  /// Construit un select
  Widget _buildSelectInput() {
    final isMultiple = (item['multiple'] == true) ||
        (item['type'] == 'multiresource');

    if (isMultiple) {
      return ModelFormInputMultiSelect(
        item: item,
        initialValue: item['value'],
        isRequired: 'Le champ ${item["name"]} est obligatoire',
        onChange: (List value) => onChange?.call(value, null),
      );
    } else {
      return ModelFormInputSelect(
        showPrefix: showPrefix,
        item: item,
        initialValue: item['value'],
        isRequired: 'Le champ ${item["name"]} est obligatoire',
        onChange: (dynamic value) => onChange?.call(value, null),
      );
    }
  }

  /// Construit un input date
  Widget _buildDateInput() {
    return ModelFormInputDate(
      key: Key(item['field'] ?? ''),
      isRequired: 'Le champ ${item["name"]} est obligatoire',
      onChange: (value) => onChange?.call(value, null),
      item: item,
    );
  }

  /// Construit un input datetime
  Widget _buildDateTimeInput() {
    return ModelFormInputDateTime(
      key: Key(item['field'] ?? ''),
      isRequired: 'Le champ ${item["name"]} est obligatoire',
      onChange: (value) => onChange?.call(value, null),
      item: item,
    );
  }

  /// Construit un input time
  Widget _buildTimeInput() {
    return ModelFormInputTime(
      key: Key(item['field'] ?? ''),
      isRequired: 'Le champ ${item["name"]} est obligatoire',
      onChange: (value) => onChange?.call(value, null),
      item: item,
    );
  }

  /// Construit un input upload (photo)
  Widget _buildUploadInput() {
    return ModelFormInputUpload(
      item: item,
      initialValue: initialValue,
      onChange: (value, String? name) => onChange?.call(value, name),
    );
  }

  /// Construit un input fichier
  Widget _buildFileInput() {
    return ModelFormInputFile(
      item: item,
      initialValue: initialValue,
      onChange: (file) => onChange?.call(file, null),
    );
  }
}