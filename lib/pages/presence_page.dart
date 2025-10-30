// ============================================================================
// FICHIER 1: presence_page.dart
// ============================================================================
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // AppBar moderne avec gradient
          SliverAppBar(
            expandedHeight: 100,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withValues(alpha:0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: FlexibleSpaceBar(
                centerTitle: true,
                title: const Text(
                  'Présence',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            ),
          ),

          // Formulaire de filtre
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
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
          ),

          // En-tête de liste
          if (repartitions.isNotEmpty)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha:0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 18,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Nom & prénom(s)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'Présent(e)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.check_circle_outline,
                          size: 18,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          // Corps de la page
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: body(),
            ),
          ),
        ],
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
      response = List.from(response).map((el) {
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
        {'field': 'classe_id', 'operator': '=', 'value': filterForm['classeId']},
        {'field': 'irregularity_date', 'operator': 'date', 'value': filterForm['date']},
        {'field': 'subject_id', 'operator': '=', 'value': filterForm['subjectId']},
        {'field': 'type', 'operator': '=', 'value': 'absence'},
      ],
    );
  }

  Widget body() {
    if (isFetching) {
      return const SizedBox(
        height: 300,
        child: Center(child: LoadingIndicator()),
      );
    } else {
      if (repartitions.isNotEmpty) {
        return Column(
          children: repartitions
              .asMap()
              .entries
              .map<Widget>(
                (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: PresenceSwitch(
                filterForm: filterForm,
                repartition: entry.value,
                irregularityForm: irregularityForm ?? {},
                index: entry.key,
              ),
            ),
          )
              .toList(),
        );
      } else {
        return Container(
          height: 300,
          padding: const EdgeInsets.all(40),
          child: EmptyPage(
            sub: Text(
              'Sélectionnez une classe et une matière',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.italic,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.6),
              ),
            ),
            icon: Icon(
              Icons.school_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.3),
            ),
          ),
        );
      }
    }
  }
}