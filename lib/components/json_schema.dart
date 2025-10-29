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
  });

  final Map errorMessages;
  final Map<String, dynamic> form;
  final Function actionSave;
  final Function? actionDraft;
  final List<String>? hiddenFields;
  final String? saveButtonText;

  @override
  State createState() => CoreFormState();
}

class CoreFormState extends State<JsonSchema> {
  Map<String, dynamic> formGeneral = {};
  String? radioValue = '';

  @override
  void initState() {
    setState(() {
      formGeneral = widget.form;
    });
    super.initState();
  }

  // validators

  String? isRequired(item, value) {
    if (value.isEmpty) {
      return widget.errorMessages[item['field']] ??
          'Le champ ${item["name"]} est obligatoire';
    }
    return null;
  }

  // Return widgets

  List<Widget> jsonToForm() {
    List<Widget> listWidget = [];

    for (var count = 0; count < formGeneral['inputs'].length; count++) {
      Map<String, dynamic> item = formGeneral['inputs'][count];
      if ((widget.hiddenFields != null &&
              widget.hiddenFields!.contains(item['field'])) ||
          (item['hidden'] != null && item['hidden'] == true)) {
        continue;
      }
      if (item['type'] == 'boolean') {
        formGeneral['inputs'][count]['value'] = item['value'] ?? false;
      }
      listWidget.add(ModelInputMutator(
        initialValue: formGeneral['inputs'][count]['value'],
        item: item,
        onChange: (value, name) {
          setState(() {
            formGeneral['inputs'][count]['value'] = value;
            if (['file', 'photo'].contains(item['type'])) {
              formGeneral['inputs'][count]['inputLabel'] = name;
            }
          });
        },
      ));
    }

    if (formGeneral['inputs'].isNotEmpty) {
      listWidget.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.actionDraft != null)
              Container(
                width: 150.0,
                margin: const EdgeInsets.only(top: 30.0),
                child: Padding(
                  padding: const EdgeInsets.all(0),
                  child: TextButton(
                      style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                  width: 1, style: BorderStyle.solid),
                              borderRadius: BorderRadius.circular(10)),
                          backgroundColor: Colors.grey),
                      onPressed: () {
                        widget.actionDraft!(formGeneral);
                      },
                      child: const Text('Brouillon')),
                ),
              ),
            Container(
              //width: 150.0,
              margin: const EdgeInsets.only(top: 30.0),
              child: Padding(
                padding: const EdgeInsets.all(0),
                child: MyButton(onTap: (){
                  if (_formKey.currentState?.validate() == true) {
                    widget.actionSave(formGeneral);
                  }
                }, buttonText: widget.saveButtonText ?? "Enregistrer"),
              ),
            )
          ],
        ),
      );
    }

    return listWidget;
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var inputs = jsonToForm()
        .map<Widget>(
            (e) => Padding(padding: const EdgeInsets.only(top: 15), child: e))
        .toList();
    return Form(
      autovalidateMode: AutovalidateMode.disabled,
      key: _formKey,
      child: Container(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: inputs,
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
    this.showLabel=true,
  });

  @override
  Widget build(BuildContext context) {
    if ([
      'text',
      'tel',
      'phone',
      'email',
      'number',
      'password',
      'longtext',
      'currency',
      'textarea',
      'richtext',
      'stringArray',
      'address'
    ].contains(item['type'])) {
      return ModelFormInputText(
        item: item,
        showPrefix: showPrefix,
        initialValue: item['value'] ?? '',
        isRequired: 'Le champ ${item["name"]} est obligatoire',
        onChange: (String value) {
          if (onChange != null) {
            onChange!(value, null);
          }
        },
      );
    }

    /**
     * For switches
     */
    if (item['type'] == "boolean") {
      item['value'] = initialValue ?? false;
      return ModelFormInputBool(
        item: item,
        showLabel: showLabel,
        onChange: (bool value) {
          if (onChange != null) {
            onChange!(value, null);
          }
        },
      );
    }

    /**
     * For checkbox
     */
    if (item['type'] == "multiselect") {
      List<Widget> checkboxes = [];
      checkboxes.add(Text(item['name'],
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)));
      for (var i = 0; i < item['options'].length; i++) {
        checkboxes.add(
          Row(
            children: <Widget>[
              Expanded(child: Text(item['options'][i])),
              Checkbox(
                key: ObjectKey(item['field']),
                value: item['options'][i],
                onChanged: (value) {
                  if (onChange != null) {
                    onChange!(value, null);
                  }
                },
              ),
            ],
          ),
        );
      }
      return Container(
        margin: const EdgeInsets.only(top: 5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: checkboxes,
        ),
      );
    }

    /**
     * For selects
     */
    if (["select", "selectresource", 'resource', 'multiresource', 'radio']
        .contains(item['type'])) {
      if ((item['multiple'] != null && item['multiple'] == true) ||
          item['type'] == 'multiresource') {
        return ModelFormInputMultiSelect(
          item: item,
          initialValue: item['value'],
          isRequired: 'Le champ ${item["name"]} est obligatoire',
          onChange: (List value) {
            if (onChange != null) {
              onChange!(value, null);
            }
          },
        );
      } else {
        return ModelFormInputSelect(
          showPrefix: showPrefix,
          item: item,
          initialValue: item['value'],
          isRequired: 'Le champ ${item["name"]} est obligatoire',
          onChange: (dynamic value) {
            if (onChange != null) {
              onChange!(value, null);
            }
          },
        );
      }
    }
    if (item['type'] == "date") {
      return ModelFormInputDate(
        key: Key(item['field']),
        isRequired: 'Le champ ${item["name"]} est obligatoire',
        onChange: (value) {
          if (onChange != null) {
            onChange!(value, null);
          }
        },
        item: item,
      );
    }

    if (item['type'] == "datetime") {
      return ModelFormInputDateTime(
        key: Key(item['field']),
        isRequired: 'Le champ ${item["name"]} est obligatoire',
        onChange: (value) {
          if (onChange != null) {
            onChange!(value, null);
          }
        },
        item: item,
      );
    }

    if (item['type'] == "time") {
      return ModelFormInputTime(
        key: Key(item['field']),
        isRequired: 'Le champ ${item["name"]} est obligatoire',
        onChange: (value) {
          if (onChange != null) {
            onChange!(value, null);
          }
        },
        item: item,
      );
    }

    if (item['type'] == "photo") {
      return ModelFormInputUpload(
        item: item,
        initialValue: initialValue,
        onChange: (value, String name) {
          if (onChange != null) {
            onChange!(value, name);
          }
        },
      );
    }

    if (item['type'] == "file") {
      return ModelFormInputFile(
        item: item,
        initialValue: initialValue,
        onChange: (file) {
          if (onChange != null) {
            onChange!(file, null);
          }
        },
      );
    }

    if (item['type'] == "upload") {
      return ModelFormInputUpload(
        item: item,
        initialValue: initialValue,
        onChange: (file) {
          if (onChange != null) {
            onChange!(file, null);
          }
        },
      );
    }

    return Container();
  }
}
