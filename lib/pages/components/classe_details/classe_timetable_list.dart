import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:novacole/components/data_models/default_data_grid.dart';

class ClasseTimeTable extends StatefulWidget {
  final Map<String, dynamic> classe;

  const ClasseTimeTable({super.key, required this.classe});

  @override
  ClasseTimeTableState createState() {
    return ClasseTimeTableState();
  }
}

class ClasseTimeTableState extends State<ClasseTimeTable> {
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
      itemBuilder: (timetable) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${timetable['day']}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${timetable['subject']['name']}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  "${DateFormat.Hm('fr').format(DateTime.parse(timetable['end_at'])).toString()}"
                  " ~ ${DateFormat.Hm('fr').format(DateTime.parse(timetable['start_at'])).toString()}",
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            Text(
              "Par : ${timetable['subject']['charge_full_name']}",
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          ],
        );
      },
      dataModel: 'timetable',
      formDefaultData: {
        'classe_id': widget.classe['id']
      },
      canEdit: (item) => false,
      formInputsMutator: (inputs, data) {
        inputs = inputs.map<Map<String, dynamic>>((input) {
          if (input['field'] == 'subject_id') {
            input['filters'] = [
              {
                'field': 'classe_id',
                'operator': '=',
                'value': widget.classe['id']
              }
            ];
          }
          return input;
        }).toList();
        return inputs;
      },
      paginate: PaginationValue.none,
      title: 'Calendrier de cours ${widget.classe['name']}',
      query: {'order_by': 'name', 'order_direction': 'ASC'},
      data: {
        'filters': [
          {'field': 'classe_id', 'value': widget.classe['id']}
        ]
      },
    );
  }
}
