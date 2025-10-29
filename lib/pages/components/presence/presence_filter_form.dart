import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:novacole/components/form_inputs/input_date.dart';
import 'package:novacole/components/form_inputs/input_select.dart';
import 'package:novacole/components/form_inputs/input_time.dart';

class PresenceFilterForm extends StatefulWidget {
  final Function onSearch;

  const PresenceFilterForm({
    super.key,
    required this.onSearch,
  });

  @override
  PresenceFilterFormState createState() {
    return PresenceFilterFormState();
  }
}

class PresenceFilterFormState extends State<PresenceFilterForm> {
  String? todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String? todayTime = DateFormat('HH:mm').format(DateTime.now());
  String? classId;
  String? subjectId;

  Key subjectKey = Key(Random().nextInt(1000).toString());

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  search(){
    widget.onSearch({
      'classeId': classId,
      'subjectId': subjectId,
      'date': todayDate,
      'time': todayTime,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: ModelFormInputSelect(
              decorationTextStyle: const TextStyle(
                  overflow: TextOverflow.ellipsis
              ),
              onChange: (value) async {
                setState(() {
                  classId = value;
                  subjectId = null;
                  subjectKey = Key(Random().nextInt(1000).toString());
                  search();
                });
              },
              item: {
                'field': 'classe_id',
                'type': 'selectresource',
                'entity': 'classe',
                'name': 'Classe',
                'placeholder': 'Sélectionner une classe',
                'value': classId,
                'order_by': 'name',
                'order_direction': 'ASC'
              },
            ),
          ),
          const SizedBox(height: 5),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: ModelFormInputSelect(
              key: subjectKey,
              onChange: (value) async {
                setState(() {
                  subjectId = value;
                });
                search();
              },
              item: {
                'field': 'subject_id',
                'type': 'selectresource',
                'entity': 'subject',
                'name': 'Matière',
                'placeholder': 'Selectionner une matière',
                'filters': [
                  {'field': 'classe_id', 'operator': '=', 'value': classId}
                ]
              },
            ),
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.55,
                child: ModelFormInputDate(
                  onChange: (value) {
                    setState(() {
                      todayDate = value;
                    });
                    search();
                  },
                  item: {
                    'field': 'presence_date',
                    'type': 'date',
                    'name': '',
                    'placeholder': 'Sélectionner une date',
                    'value': todayDate
                  },
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.35,
                child: ModelFormInputTime(
                  onChange: (value) {

                    setState(() {
                      todayTime = value;
                    });
                    search();
                  },
                  item: {
                    'field': 'presence_time',
                    'type': 'time',
                    'name': '',
                    'placeholder': 'Heure',
                    'value': todayTime
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
