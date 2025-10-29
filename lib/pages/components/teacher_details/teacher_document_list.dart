import 'package:flutter/material.dart';
import 'package:novacole/components/form_inputs/input_select.dart';

class TeacherDocumentList extends StatelessWidget {
  const TeacherDocumentList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/home',
              (route) => false,
            );
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text(
          'Documents',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: ListTile(
                  onTap: () {

                  },
                  leading: const Icon(Icons.app_registration_sharp),
                  title: const Text(
                    'Fiches de note',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: const Text(
                    'Fiches de notes des évaluations',
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MarkFileForm extends StatefulWidget {
  const MarkFileForm({super.key});

  @override
  MarkFileFormState createState() {
    return MarkFileFormState();
  }
}

class MarkFileFormState extends State<MarkFileForm> {
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
    return Column(
      children: [
        const ModelFormInputSelect(item: {
          'field': 'period_id',
          'type': 'selectresource',
          'entity': 'period',
          'name': 'Période',
          'placeholder': 'Sélectionner une période'
        }),
        const ModelFormInputSelect(item: {
          'field': 'classe_id',
          'type': 'selectresource',
          'entity': 'classe',
          'name': 'Classe',
          'placeholder': 'Sélectionner une classe'
        }),
        const ModelFormInputSelect(item: {
          'field': 'subject_id',
          'type': 'selectresource',
          'entity': 'subject',
          'name': 'Matière',
          'placeholder': 'Sélectionner une matière'
        }),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 18.0),
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Télécharger'),
          ),
        )
      ],
    );
  }
}
