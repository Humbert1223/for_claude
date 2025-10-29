import 'package:flutter/material.dart';
import 'package:novacole/components/data_models/default_data_form.dart';
import 'package:novacole/components/loading_indicator.dart';
import 'package:novacole/models/master_crud_model.dart';
import 'package:novacole/models/user_model.dart';
import 'package:novacole/utils/constants.dart';

class FeesConfigForm extends StatefulWidget {
  final Map<String, dynamic> level;
  final Map<String, dynamic>? serie;

  const FeesConfigForm({super.key, required this.level, this.serie});

  @override
  FeesConfigFormState createState() {
    return FeesConfigFormState();
  }
}

class FeesConfigFormState extends State<FeesConfigForm> {
  UserModel? user;
  Map<String, dynamic>? tuition;
  bool isLoading = true;
  @override
  void initState() {
    UserModel.fromLocalStorage().then((u){
      setState(() {
        user = u;
      });
      loadData().then((value){
        setState(() {
          isLoading = false;
        });
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
    return Visibility(
      visible: !isLoading,
      replacement: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          title: Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        body: const LoadingIndicator(type: LoadingIndicatorType.progressiveDots,),
      ),
      child: DefaultDataForm(
        dataModel: Entity.tuition,
        data: tuition,
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
      ),
    );
  }

  Future<void> loadData() async {
    if(user == null) return;
    List? response = await MasterCrudModel(
      Entity.tuition,
    ).search(paginate: '0', filters: [
      {
        'field': 'level_id',
        'operator': '=',
        'value': widget.level['id'].toString(),
      },
      {
        'field': 'academic_id',
        'operator': '=',
        'value': user?.academic,
      },
      if (widget.serie != null)
        {
          'field': 'serie_id',
          'operator': '=',
          'value': widget.serie!['id'].toString(),
        }
    ]);
    if(response != null && response.isNotEmpty){
      setState(() {
        tuition = Map<String, dynamic>.from(response.first);
      });
    }
  }

}
