import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:novacole/components/empty_page.dart';
import 'package:novacole/components/loading_indicator.dart';
import 'package:novacole/models/form.dart';
import 'package:novacole/models/master_crud_model.dart';
import 'package:novacole/pages/components/presence/presence_filter_form.dart';
import 'package:novacole/pages/components/presence/presence_switch.dart';

class PresencePage extends StatefulWidget {
  const PresencePage({super.key});

  @override
  PresencePageState createState() => PresencePageState();
}

class PresencePageState extends State<PresencePage> {
  List<Map<String, dynamic>> repartitions = [];

  Map<String, dynamic> filterForm = {};
  Map<String, dynamic>? irregularityForm;

  bool isFetching = false;

  @override
  void initState() {
    CoreForm().get(entity: 'irregularity').then((value) => setState(() {
          irregularityForm = value;
        }));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text(
          'Présence',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(235),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: PresenceFilterForm(
                  onSearch: (form) async {
                    setState(() {
                      filterForm = form;
                    });
                    if (Map.from(form).values.contains(null)) {
                      setState(() {
                        repartitions = [];
                      });
                    } else {
                      setState(() {
                        isFetching = true;
                      });
                      await loadStudents();

                      setState(() {
                        isFetching = false;
                      });
                    }
                  },
                ),
              ),
              Container(
                color: Theme.of(context).colorScheme.surface,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Nom & prénom(s)',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Présent(e)',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: body(),
      ),
    );
  }

  Future loadStudents() async {
    List? response = await MasterCrudModel('registration').search(
      paginate: '0',
      filters: [
        {
          'field': 'classe_id',
          'operator': '=',
          'value': filterForm['classeId']
        },
      ],
      data: {
        'relations': ['student']
      }
    );
    if (response != null) {
      response = List.from(response).map((el){
        el['name'] = el['student']['full_name'];
        return el;
      }).toList();
      response.sort((a, b) {
        return a['name'].toLowerCase().compareTo(b['name'].toLowerCase());
      });
    }
    List? absenses = (await loadAbsences()) ?? [];
    response = response != null
        ? List<Map<String, dynamic>>.from(response as Iterable)
        : [];
    response = response.map((repartition) {
      repartition['absence'] = (absenses == null || absenses.isEmpty)
          ? null
          : absenses.firstWhereOrNull(
              (element) => element['student_id'] == repartition['student_id'],
            );
      return repartition;
    }).toList();

    setState(() {
      repartitions = List<Map<String, dynamic>>.from(response as Iterable);
    });
  }

  Future loadAbsences() async {
    return await MasterCrudModel('irregularity').search(
      paginate: '0',
      filters: [
        {
          'field': 'classe_id',
          'operator': '=',
          'value': filterForm['classeId']
        },
        {
          'field': 'irregularity_date',
          'operator': 'date',
          'value': filterForm['date']
        },
        {
          'field': 'subject_id',
          'operator': '=',
          'value': filterForm['subjectId']
        },
        {
          'field': 'type',
          'operator': '=',
          'value': 'absence'
        },
      ],
    );
  }

  Widget body() {
    if (isFetching) {
      return const LoadingIndicator();
    } else {
      if (repartitions.isNotEmpty) {
        return ListView(
          children: repartitions
              .map<Widget>(
                (repartition) => PresenceSwitch(
                  filterForm: filterForm,
                  repartition: repartition,
                  irregularityForm: irregularityForm ?? {},
                ),
              )
              .toList(),
        );
      } else {
        return const EmptyPage(
          sub: Text(
            'Sélectionnez une classe',
            style: TextStyle(
                fontWeight: FontWeight.w100, fontStyle: FontStyle.italic),
          ),
          icon: Icon(Icons.bookmark_add_outlined),
        );
      }
    }
  }
}
