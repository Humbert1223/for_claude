import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:novacole/components/json_schema.dart';
import 'package:novacole/pages/admin/reports/widgets/report_download_widget.dart';
import 'package:novacole/pages/admin/reports/widgets/report_types.dart';
import 'package:novacole/utils/tools.dart';

class SchoolReportDownloadPage extends StatelessWidget {
  final Map<String, dynamic> filters;

  const SchoolReportDownloadPage({
    super.key,
    required this.filters,
  });

  List<ReportConfig> get _reports => [
        const ReportConfig(
          title: "Résultat de fin d'année",
          endpoint: '/reports/school/admitted',
          fileName: 'resultat_de_fin_annee',
        ),
        ReportConfig(
          title: "Analyse des résultats périodiques",
          endpoint: '/reports/school/review',
          fileName: 'analyse_des_resultats_periodiques',
          formConfig: FormConfig(
            inputs: [
              InputField(
                field: 'period_id',
                entity: 'period',
                type: InputFieldType.selectresource,
                name: 'Période scolaire',
                required: true,
                description: 'Sélectionner une période',
                resourceFilters: ResourceFilters(
                  filters: [
                    FilterCriteria(
                      field: 'degree',
                      value: filters['degree'],
                    ),
                    const FilterCriteria(
                      field: 'closed',
                      value: true,
                    ),
                    const FilterCriteria(
                      field: 'started_at',
                      operator: '!=',
                      value: null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        ReportConfig(
          title: "Synthèse des résultats périodiques",
          endpoint: '/reports/school/synthesis',
          fileName: 'synthese_des_resultats_periodiques',
          formConfig: FormConfig(
            inputs: [
              InputField(
                field: 'period_id',
                entity: 'period',
                type: InputFieldType.selectresource,
                name: 'Période scolaire',
                required: true,
                description: 'Sélectionner une période',
                resourceFilters: ResourceFilters(
                  filters: [
                    FilterCriteria(
                      field: 'degree',
                      value: filters['degree'],
                    ),
                    const FilterCriteria(
                      field: 'closed',
                      value: true,
                    ),
                    const FilterCriteria(
                      field: 'started_at',
                      operator: '!=',
                      value: null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ];

  Future<void> _handleDownload(
      BuildContext context, ReportConfig report) async {
    Map<String, dynamic> data = {...filters};
    if (report.formConfig != null) {
      final formData = await _showDynamicFormDialog(
        context,
        report.formConfig!,
      );
      if (formData == null) return;
      data.addAll(formData);
    }

    if (context.mounted) {
      NovaTools.showDownloadingDialog(context, message: 'Téléchargement en cours...');
    }

    try {
      await NovaTools.download(
        uri: report.endpoint,
        name: "${report.fileName}_annee_academic.xlsx",
        data: data,
        type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du téléchargement: $e')),
        );
      }
    } finally {
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<Map<String, dynamic>?> _showDynamicFormDialog(
    BuildContext context,
    FormConfig formConfig,
  ) async {
    Map<String, dynamic>? formData;

    await showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          children: [
            JsonSchema(
              form: {
                "inputs":
                    formConfig.inputs.map((input) => input.toMap()).toList(),
              },
              saveButtonText: 'Télécharger',
              actionSave: (data) {
                formData = {};
                for (var input
                    in List<Map<String, dynamic>>.from(data['inputs'])) {
                  formData![input['field']] = input['value'];
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    return formData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Rapports de l'année académique",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _reports.length,
        itemBuilder: (context, index) {
          final report = _reports[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: ReportDownloadWidget(
              title: report.title,
              onTap: () => _handleDownload(context, report),
              icon: const Icon(
                FontAwesomeIcons.fileExcel,
                color: Colors.green,
              ),
            ),
          );
        },
      ),
    );
  }
}
