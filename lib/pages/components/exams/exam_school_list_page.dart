import 'package:flutter/material.dart';
import 'package:novacole/components/data_models/default_data_grid.dart';
import 'package:novacole/components/form_inputs/input_multi_select.dart';
import 'package:novacole/models/master_crud_model.dart';

class ExamSchoolListPage extends StatefulWidget {
  final Map<String, dynamic> exam;

  const ExamSchoolListPage({super.key, required this.exam});

  @override
  ExamSchoolListPageState createState() {
    return ExamSchoolListPageState();
  }
}

class ExamSchoolListPageState extends State<ExamSchoolListPage> {
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
    return Scaffold(
      body: DefaultDataGrid(
        itemBuilder: (school) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                school['name'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "N°: ${school['registration_number']}",
                    style: const TextStyle(fontSize: 13),
                  ),
                  Text(
                    "Tél: ${school['phone']}",
                    style: const TextStyle(fontSize: 13),
                  ),
                  Text(
                    "Adresse: ${school['address']}",
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ],
          );
        },
        dataModel: 'school',
        paginate: PaginationValue.none,
        title: widget.exam['name'],
        canAdd: false,
        canDelete: (data) => false,
        canEdit: (data) => false,
        data: {
          'filters': [
            {
              'field': 'id',
              'operator': 'in',
              'value': widget.exam['school_ids'],
            },
          ],
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add),
        onPressed: () async {
          List<String>? schoolIds = await showDialog(
            context: context,
            builder: (context) {
              return SimpleDialog(
                children: [
                  ModelFormInputMultiSelect(
                    item: {
                      'field': 'school_ids',
                      'type': 'selectresource',
                      'name': 'Etablissement scolaire',
                      'placeholder': 'Selectionner les établissement scolaires',
                      'entity': 'school',
                      'required': true,
                    },
                    initialValue: List<String>.from(
                      widget.exam['school_ids'] ?? [],
                    ),
                    onChange: (value) {
                      Navigator.of(context).pop(value);
                    },
                  ),
                ],
              );
            },
          );
          if (schoolIds != null && schoolIds.isNotEmpty) {
            Map<String, dynamic>? response = await MasterCrudModel.post(
              "/exam/school/create/${widget.exam['id']}",
              data: {'school_ids': schoolIds},
            );
            if (response != null && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Etablissement scolaire ajouté avec succès'),
                ),
              );
            }
          }
        },
      ),
    );
  }
}
