import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:novacole/components/form_inputs/input_select.dart';
import 'package:novacole/components/json_schema.dart';
import 'package:novacole/components/loading_indicator.dart';
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
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Champ",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              Text("Opérateur",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              Text("Valeur",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              Text("",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold))
            ],
          ),
          ...filters.map((filter) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    filter.field.$1,
                    style: const TextStyle(fontSize: 10),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(
                    width: 20,
                    child: Text(
                      filter.operator.$1,
                      style: const TextStyle(fontSize: 10),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(
                    width: 50,
                    child: Text(
                      "${filter.value.$2}",
                      style: const TextStyle(fontSize: 10),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                      size: 32,
                    ),
                    onPressed: () {
                      setState(() {
                        filters.remove(filter);
                        if (widget.onFilterChange != null) {
                          widget.onFilterChange!(filters);
                        }
                      });
                    },
                  ),
                ],
              )),
          if (!loading)
            GridFilterForm(
              inputs: inputs,
              onAdd: (FilterRow filter) {
                setState(() {
                  filters.add(filter);
                  if (widget.onFilterChange != null) {
                    widget.onFilterChange!(filters);
                  }
                });
              },
            )
          else
            const LoadingIndicator(),
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
    {'label': 'Différent de', 'value': "!="},
    {'label': 'Contient', 'value': "LIKE"},
    {'label': 'Date égale à', 'value': "DATE"},
    {'label': 'Date avant le', 'value': "DATEBEFOREQ"},
    {'label': 'Date après le', 'value': "DATEAFTEREQ"},
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.25,
          child: ModelFormInputSelect(
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
                currentInput = widget.inputs
                    .firstWhereOrNull((input) => input['field'] == value);
              });
            },
          ),
        ),
        const SizedBox(width: 0),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.25,
          child: ModelFormInputSelect(
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
        ),
        const SizedBox(width: 0),
        if (currentInput != null)
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.25,
            child: ModelInputMutator(
              showPrefix: false,
              showLabel: false,
              key: Key(_fieldController.text),
              item: currentInput!,
              initialValue: currentInput?['type'] == 'boolean' ? valueBoolController : _valueController.text,
              onChange: (value, name) {
                if(currentInput?['type'] == 'boolean'){
                  setState(() {
                    valueBoolController = value;
                  });
                }else{
                  _valueController.text = value;
                }
              },
            ),
          )
        else
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.25,
            child: const Text(
              'Sélectionner un champ',
              style: TextStyle(fontSize: 11),
            ),
          ),
        const SizedBox(width: 0),
        IconButton(
          onPressed: () {
            setState(() {
              if (widget.onAdd != null) {
                String field = widget.inputs.firstWhereOrNull((input) =>
                        input['field'] == _fieldController.text)?['name'] ??
                    '';
                String operator = operators.firstWhereOrNull((op) =>
                        op['value'] == _operatorController.text)?['label'] ??
                    '';
                widget.onAdd!(FilterRow(
                  field: (field, _fieldController.text),
                  operator: (operator, _operatorController.text),
                  value: (_valueController.text, (currentInput?['type'] == 'boolean') ? valueBoolController : _valueController.text),
                ));
              }
            });
          },
          icon: Icon(
            Icons.add_box,
            color: Theme.of(context).colorScheme.primary,
            size: 32,
          ),
        ),
      ],
    );
  }
}
