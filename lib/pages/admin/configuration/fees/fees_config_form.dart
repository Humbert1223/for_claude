import 'package:flutter/material.dart';
import 'package:novacole/components/data_models/default_data_form.dart';
import 'package:novacole/models/user_model.dart';
import 'package:novacole/utils/constants.dart';

class FeesConfigForm extends StatefulWidget {
  final Map<String, dynamic> level;
  final Map<String, dynamic>? serie;
  final Map<String, dynamic>? tuition;

  const FeesConfigForm({super.key, required this.level, this.serie, this.tuition});

  @override
  FeesConfigFormState createState() {
    return FeesConfigFormState();
  }
}

class FeesConfigFormState extends State<FeesConfigForm> {
  UserModel? user;
  @override
  void initState() {
    UserModel.fromLocalStorage().then((u){
      setState(() {
        user = u;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String title = "Frais Scolaires ${widget.level['name']} ${widget.serie?['name'] ?? ''}";
    return DefaultDataForm(
        dataModel: Entity.tuition,
        data: widget.tuition,
        title: title,
        defaultData: {
          'level_id': widget.level['id'],
          if (widget.serie != null) 'serie_id': widget.serie!['id'],
        },
        inputsMutator: (inputs, data) {
          inputs = inputs.map((input) {
            if (input['field'] == 'level_id') {
              input['disabled'] = true;
              input['value'] = widget.level['id'];
            }
            if (input['field'] == 'serie_id') {
              input['disabled'] = true;
              if (widget.level['degree'] != 'high_school') {
                input['hidden'] = true;
              }
              input['value'] = widget.serie?['id'];
            }
            return input;
          }).toList();
          return inputs;
        }
    );
  }
}
