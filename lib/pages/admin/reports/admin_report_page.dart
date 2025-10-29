import 'package:flutter/material.dart';
import 'package:novacole/pages/admin/reports/exam_report_download_page.dart';
import 'package:novacole/pages/admin/reports/finance_report_download_page.dart';
import 'package:novacole/pages/admin/reports/primary_report_download_page.dart';
import 'package:novacole/pages/admin/reports/report_classe_filter.dart';
import 'package:novacole/pages/admin/reports/report_exam_filter.dart';
import 'package:novacole/pages/admin/reports/report_type_filter.dart';

class AdminReportPage extends StatelessWidget {
  const AdminReportPage({super.key});

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
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/home',
              (route) => false,
            );
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: ListView(
        children: [
          Card(
            child: ListTile(
                trailing: const Icon(Icons.arrow_forward_ios_rounded),
                title: const Text('Primaire'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) {
                      return ReportClasseFilterSelector(
                        degree: 'primary',
                        filters: {'degree': 'primary'},
                        onSelect: (filters, classe) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                filters['classe_id'] = classe['id'];
                                return PrimaryReportDownloadPage(
                                  filters: filters,
                                  classe: classe,
                                );
                              },
                            ),
                          );
                        },
                      );
                    }),
                  );
                }),
          ),
          Card(
            child: ListTile(
              trailing: const Icon(Icons.arrow_forward_ios_rounded),
              title: const Text('Collège'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) {
                    return const ReportTypeFilterSelector(
                      degree: 'college',
                      filters: {'degree': 'college'},
                    );
                  }),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              trailing: const Icon(Icons.arrow_forward_ios_rounded),
              title: const Text('Lycée'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) {
                    return const ReportTypeFilterSelector(
                      degree: 'high_school',
                      filters: {'degree': 'high_school'},
                    );
                  }),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              trailing: const Icon(Icons.arrow_forward_ios_rounded),
              title: const Text('Finances'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) {
                    return const FinanceReportDownloadPage(
                      filters: {},
                    );
                  }),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              trailing: const Icon(Icons.arrow_forward_ios_rounded),
              title: const Text('Examens'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return ReportExamFilterSelector(
                        title: "Rapports d'examen",
                        filters: {},
                        onSelect: (filters, assessment) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return ExamReportDownloadPage(
                                  filters: filters,
                                  exam: assessment,
                                );
                              },
                            ),
                          );
                        },
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
