import 'package:flutter/material.dart';
import 'package:novacole/components/json_schema.dart';
import 'package:novacole/components/loading_indicator.dart';
import 'package:novacole/models/master_crud_model.dart';
import 'package:novacole/models/user_model.dart';

class CustomizeBulletinTemplatePage extends StatefulWidget {
  final Map<String, dynamic> bulletinData;
  final String degree;

  const CustomizeBulletinTemplatePage({
    super.key,
    required this.bulletinData,
    required this.degree,
  });

  @override
  CustomizeBulletinTemplatePageState createState() {
    return CustomizeBulletinTemplatePageState();
  }
}

class CustomizeBulletinTemplatePageState
    extends State<CustomizeBulletinTemplatePage> {
  Map<String, dynamic> get bulletinData => widget.bulletinData;
  List<Map<String, dynamic>> inputs = [
    {
      'field': 'show_teacher_column',
      'type': 'boolean',
      'name': 'Afficher la colonne de signature des enseignants',
      'default': true,
    },
    {
      'field': 'show_absence_count',
      'type': 'boolean',
      'name': "Afficher le nombre d'heure d'absence des élèves",
      'default': true,
    },
    {
      'field': 'show_delay_count',
      'type': 'boolean',
      'name': 'Afficher le nombre de retard des élèves',
      'default': true,
    },
    {
      'field': 'show_director_signature',
      'type': 'boolean',
      'name': "Afficher la signature du responsable de l'établissement",
      'default': true,
    },
    {
      'field': 'show_titulaire_signature',
      'type': 'boolean',
      'name': 'Afficher la signature du titulaire de la classe',
      'default': true,
    },
    {
      'field': 'show_school_logo',
      'type': 'radio',
      'options': [
        {'label': 'Ne pas afficher', 'value': 'none'},
        {'label': "Logo de l'établissement", 'value': 'logo'},
        {'label': "Photo de l'élève", 'value': 'student'},
      ],
      'name': "Afficher le logo de l'établissement / Photo de l'élève (si disponible)",
      'default': 'logo',
    },
    {
      'field': 'director_title',
      'type': 'text',
      'name': "Titre du responsable de l'établissement",
      'placeholder':
          "Titre du responsable de l'établissement qui précède sa signature",
      'default': "Le Responsable de l'établissement",
    },
    {
      'field': 'titulaire_title',
      'type': 'text',
      'name': 'Titre du titulaire',
      'placeholder': 'Titre du titulaire qui précède sa signature',
      'default': 'Le Titulaire',
    },
    {
      'field': 'watermark',
      'type': 'radio',
      'options': [
        {'label': 'Ne pas afficher', 'value': 'none'},
        {'label': 'Nom', 'value': 'name'},
        {'label': 'Logo', 'value': 'logo'},
      ],
      'name':
          "Afficher le logo ou le nom de l'établissement en filigrane du bulletin",
      'placeholder':
          "Afficher le logo ou le nom de l'établissement en fond du bulletin",
      'default': 'none',
    },
  ];
  Key formKey = Key(DateTime.now().millisecondsSinceEpoch.toString());
  UserModel? user;
  bool isLoading = true;

  @override
  void initState() {
    UserModel.fromLocalStorage().then((usr) {
      setState(() {
        user = usr;
      });
      loadData();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(
          "Personaliser le modèle [${bulletinData['name']}]",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Visibility(
        visible: !isLoading,
        replacement: const Center(child: LoadingIndicator()),
        child: SingleChildScrollView(
          child: Column(
            children: [
              JsonSchema(
                key: formKey,
                form: {'inputs': inputs},
                actionSave: (data) async {
                  Map<String, dynamic> updatedData = {
                    'degree': widget.degree,
                    'template_name': bulletinData['value'],
                  };
                  for (var e in List<Map<String, dynamic>>.from(
                    data['inputs'],
                  )) {
                    updatedData['${e['field']}'] = e['value'];
                  }
                  _showBottomSheet();
                  Map<String, dynamic>? response = await MasterCrudModel.post(
                    '/settings/bulletin',
                    data: updatedData,
                  );
                  if (response != null) {
                    updateValue(response);
                  }
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                  setState(() {
                    formKey = Key(DateTime.now().millisecondsSinceEpoch.toString());
                  });
                },
              ),
              SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  _showBottomSheet() {
    return showModalBottomSheet<bool>(
      context: context,
      builder: (context) {
        return const Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [LoadingIndicator(), Text('Activation en cours ...')],
          ),
        );
      },
      isDismissible: false,
    );
  }

  loadData() async {
    if (user == null) return;
    Map<String, dynamic>? sc = await MasterCrudModel.find(
      '/settings/bulletin/${user?.school}/${user?.academic}/${widget.degree}/${bulletinData['value']}',
    );
    if (mounted) {
      updateValue(sc);
    }
    setState(() {
      isLoading = false;
    });
  }

  updateValue(response) {
    setState(() {
      if (response != null) {
        inputs = inputs.map((input) {
          input['value'] = response[input['field']] ?? input['default'];
          return input;
        }).toList();
      } else {
        inputs = inputs.map((input) {
          input['value'] = input['default'];
          return input;
        }).toList();
      }
    });
  }
}
