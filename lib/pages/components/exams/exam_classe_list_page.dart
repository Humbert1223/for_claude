import 'package:flutter/material.dart';
import 'package:novacole/components/data_models/default_data_grid.dart';
import 'package:novacole/pages/classe_page.dart';

class ExamClasseListPage extends StatefulWidget {
  final Map<String, dynamic> exam;

  const ExamClasseListPage({super.key, required this.exam});

  @override
  ExamClasseListPageState createState() {
    return ExamClasseListPageState();
  }
}

class ExamClasseListPageState extends State<ExamClasseListPage> {
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
    return DefaultDataGrid(
      itemBuilder: (classe) {
        return ClasseInfoWidget(classe: classe);
      },
      dataModel: 'classe',
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
            'value': widget.exam['classe_ids'],
          },
        ],
      },
    );
  }
}
