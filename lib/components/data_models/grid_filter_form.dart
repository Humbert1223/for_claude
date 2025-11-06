import 'package:flutter/material.dart';
import 'package:novacole/components/form_inputs/input_select.dart';
import 'package:novacole/components/json_schema.dart';
import 'package:novacole/components/loading_indicator.dart';
import 'package:novacole/core/extensions/list_extension.dart';
import 'package:novacole/models/form.dart';

class FilterTable extends StatefulWidget {
  final String model;
  final List<FilterRow>? filters;
  final Function? onFilterChange;

  const FilterTable({
    super.key,
    required this.model,
    this.filters = const [],
    this.onFilterChange,
  });

  @override
  FilterTableState createState() => FilterTableState();
}

class FilterTableState extends State<FilterTable> {
  final List<FilterRow> filters = [];
  List<Map<String, dynamic>> inputs = [];
  bool loading = true;

  @override
  void initState() {
    filters.addAll(widget.filters ?? []);
    CoreForm().get(entity: widget.model).then((form) {
      setState(() {
        inputs = List<Map<String, dynamic>>.from(form?['inputs'] ?? [])
            .where((input) {
          return input['hidden'] == null || input['hidden'] != true;
        }).toList();
        loading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha:0.1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha:0.05),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.filter_list_rounded,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Filtres actifs',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                if (filters.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${filters.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Liste des filtres
          if (filters.isNotEmpty)
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.all(12),
                itemCount: filters.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  return _buildCompactFilterChip(
                    context,
                    filters[index],
                        () {
                      setState(() {
                        filters.removeAt(index);
                        if (widget.onFilterChange != null) {
                          widget.onFilterChange!(filters);
                        }
                      });
                    },
                  );
                },
              ),
            ),

          // Formulaire d'ajout
          if (!loading)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha:0.1),
                  ),
                ),
              ),
              child: GridFilterForm(
                inputs: inputs,
                onAdd: (FilterRow filter) {
                  setState(() {
                    filters.add(filter);
                    if (widget.onFilterChange != null) {
                      widget.onFilterChange!(filters);
                    }
                  });
                },
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.all(20),
              child: LoadingIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _buildCompactFilterChip(
      BuildContext context,
      FilterRow filter,
      VoidCallback onDelete,
      ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha:0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha:0.2),
        ),
      ),
      child: Row(
        children: [
          // Icône
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.filter_alt,
              size: 14,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 10),

          // Infos du filtre
          Expanded(
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  filter.field.$1,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withValues(alpha:0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    filter.operator.$1,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ),
                Text(
                  "${filter.value.$2}",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface.withValues(alpha:0.8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Bouton supprimer
          InkWell(
            onTap: onDelete,
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.red,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FilterRow {
  (String, String) field;
  (String, String) operator;
  (String, dynamic) value;

  FilterRow({
    required this.field,
    required this.operator,
    required this.value,
  });
}

class GridFilterForm extends StatefulWidget {
  final List<Map<String, dynamic>> inputs;
  final Function? onAdd;

  const GridFilterForm({super.key, required this.inputs, this.onAdd});

  @override
  GridFilterFormState createState() {
    return GridFilterFormState();
  }
}

class GridFilterFormState extends State<GridFilterForm> {
  final TextEditingController _fieldController = TextEditingController();
  final TextEditingController _operatorController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  bool valueBoolController = false;

  Map<String, dynamic>? currentInput;

  final List<Map<String, dynamic>> operators = [
    {'label': '=', 'value': "="},
    {'label': '>', 'value': ">"},
    {'label': '<', 'value': "<"},
    {'label': '>=', 'value': ">="},
    {'label': '<=', 'value': "<="},
    {'label': '≠', 'value': "!="},
    {'label': 'Contient', 'value': "LIKE"},
    {'label': 'Date =', 'value': "DATE"},
    {'label': 'Date <', 'value': "DATEBEFOREQ"},
    {'label': 'Date >', 'value': "DATEAFTEREQ"},
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ajouter un filtre',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withValues(alpha:0.7),
          ),
        ),
        const SizedBox(height: 10),

        // Ligne 1: Champ et Opérateur
        Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Champ',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface.withValues(alpha:0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  ModelFormInputSelect(
                    item: {
                      'field': 'field',
                      'name': 'Champ',
                      'type': 'select',
                      'required': true,
                      'options': (widget.inputs).map((el) {
                        return {'label': el['name'], 'value': el['field']};
                      }).toList()
                    },
                    showPrefix: false,
                    onChange: (value) {
                      _fieldController.text = value;
                      setState(() {
                        currentInput = widget.inputs.firstWhereOrNull(
                              (input) => input['field'] == value,
                        );
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Opérateur',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface.withValues(alpha:0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  ModelFormInputSelect(
                    item: {
                      'field': 'operator',
                      'name': 'Opérateur',
                      'type': 'select',
                      'required': true,
                      'options': operators
                    },
                    showPrefix: false,
                    onChange: (value) {
                      _operatorController.text = value;
                    },
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Ligne 2: Valeur et Bouton
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Valeur',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface.withValues(alpha:0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (currentInput != null)
                    ModelInputMutator(
                      showPrefix: false,
                      showLabel: false,
                      key: Key(_fieldController.text),
                      item: currentInput!,
                      initialValue: currentInput?['type'] == 'boolean'
                          ? valueBoolController
                          : _valueController.text,
                      onChange: (value, name) {
                        if (currentInput?['type'] == 'boolean') {
                          setState(() {
                            valueBoolController = value;
                          });
                        } else {
                          _valueController.text = value;
                        }
                      },
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceVariant.withValues(alpha:0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(alpha:0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.arrow_upward_rounded,
                            size: 14,
                            color: theme.colorScheme.onSurface.withValues(alpha:0.4),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Sélectionner un champ',
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.colorScheme.onSurface.withValues(alpha:0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Bouton Ajouter
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withValues(alpha:0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha:0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    if (_fieldController.text.isEmpty ||
                        _operatorController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(
                                Icons.warning_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Veuillez remplir tous les champs',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: Colors.orange,
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.all(12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                      return;
                    }

                    setState(() {
                      if (widget.onAdd != null) {
                        String field = widget.inputs.firstWhereOrNull(
                              (input) => input['field'] == _fieldController.text,
                        )?['name'] ??
                            '';
                        String operator = operators.firstWhereOrNull(
                              (op) => op['value'] == _operatorController.text,
                        )?['label'] ??
                            '';
                        widget.onAdd!(FilterRow(
                          field: (field, _fieldController.text),
                          operator: (operator, _operatorController.text),
                          value: (
                          _valueController.text,
                          (currentInput?['type'] == 'boolean')
                              ? valueBoolController
                              : _valueController.text
                          ),
                        ));

                        // Réinitialiser le formulaire
                        _fieldController.clear();
                        _operatorController.clear();
                        _valueController.clear();
                        setState(() {
                          currentInput = null;
                          valueBoolController = false;
                        });
                      }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Ajouter',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}