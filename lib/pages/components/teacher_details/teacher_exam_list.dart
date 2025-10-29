import 'package:flutter/material.dart';
import 'package:novacole/components/data_models/default_data_grid.dart';
import 'package:novacole/pages/components/exams/exam_marks_page.dart';
import 'package:novacole/utils/constants.dart';
import 'package:novacole/utils/tools.dart';

class TeacherExamList extends StatelessWidget {

  const TeacherExamList({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultDataGrid(
      itemBuilder: (assessment) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${assessment['name']}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 170,
                      child: Text(
                        assessment['level']['name'],
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    Text(
                      "Date: ${NovaTools.dateFormat(assessment['start_at'])}",
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
      dataModel: Entity.exam,
      paginate: PaginationValue.none,
      title: "Saisie des notes d'Examens",
      canDelete: (data) => false,
      canAdd: false,
      optionVisible: false,
      canEdit: (data) => false,
      onItemTap: (exam, updateLine) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return ExamMarksPage(exam: exam);
            },
          ),
        );
      },
      data: {
        'filters': [
          {'field': 'started_at', 'operator': '!=', 'value': null},
          {'field': 'closed', 'operator': '!=', 'value': true},
        ],
      },
    );
  }
}
