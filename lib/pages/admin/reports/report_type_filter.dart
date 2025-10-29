import 'package:flutter/material.dart';
import 'package:novacole/pages/admin/reports/academic_report_download_page.dart';
import 'package:novacole/pages/admin/reports/assessment_report_download_page.dart';
import 'package:novacole/pages/admin/reports/classe_report_download_page.dart';
import 'package:novacole/pages/admin/reports/level_report_download_page.dart';
import 'package:novacole/pages/admin/reports/report_assessments_filter.dart';
import 'package:novacole/pages/admin/reports/report_classe_filter.dart';
import 'package:novacole/pages/admin/reports/report_level_filter.dart';
import 'package:novacole/pages/admin/reports/school_report_download_page.dart';

class ReportTypeFilterSelector extends StatelessWidget {
  final String degree;
  final Map<String, dynamic> filters;

  const ReportTypeFilterSelector(
      {super.key, required this.degree, required this.filters});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Rapports & États',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: ListView(
        children: [
          Card(
            child: ListTile(
              trailing: const Icon(Icons.arrow_forward_ios_rounded),
              title: const Text("Rapports d'évaluation"),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ReportClasseFilterSelector(
                      title: "Rapports d'évaluation",
                      degree: degree,
                      filters: {'degree': degree, ...filters},
                      onSelect: (filters, classe) {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return ReportAssessmentFilterSelector(
                            title: "Rapports d'évaluation",
                            classeId: filters['classe_id'],
                            filters: filters,
                            onSelect: (filters, assessment) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return AssessmentReportDownloadPage(
                                      filters: filters,
                                      assessment: assessment,
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        }));
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
                trailing: const Icon(Icons.arrow_forward_ios_rounded),
                title: const Text('Rapports de classe'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ReportClasseFilterSelector(
                        degree: degree,
                        filters: {'degree': degree, ...filters},
                        onSelect: (filters, classe) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return ClasseReportDownloadPage(
                                  filters: filters,
                                  classe: classe,
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }),
          ),
          Card(
            child: ListTile(
              trailing: const Icon(Icons.arrow_forward_ios_rounded),
              title: const Text('Rapports de niveau'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ReportLevelFilterSelector(
                      degree: degree,
                      filters: {'degree': degree, ...filters},
                      onSelect: (filters, level) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) {
                              return LevelReportDownloadPage(
                                title: "Rapports de niveau",
                                filters: filters,
                                level: level,
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              trailing: const Icon(Icons.arrow_forward_ios_rounded),
              title: const Text("Rapports de l'année scolaire"),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return AcademicReportDownloadPage(
                        filters: filters,
                      );
                    },
                  ),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              trailing: const Icon(Icons.arrow_forward_ios_rounded),
              title: const Text("Rapport de l'établissement"),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return SchoolReportDownloadPage(
                        filters: filters,
                      );
                    },
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
