import 'package:flutter/material.dart';
import 'package:novacole/components/json_schema.dart';
import 'package:novacole/pages/admin/reports/widgets/report_download_widget.dart';
import 'package:novacole/pages/admin/reports/widgets/report_types.dart';
import 'package:novacole/utils/tools.dart';

class AcademicReportDownloadPage extends StatelessWidget {
  final Map<String, dynamic> filters;

  const AcademicReportDownloadPage({super.key, required this.filters});

  InputField get _classeInputField => InputField(
    field: 'classe_id',
    type: InputFieldType.selectresource,
    entity: 'classe',
    name: 'Classe scolaire',
    resourceFilters: ResourceFilters(
      filters: [
        FilterCriteria(field: 'level.degree', value: filters['degree']),
      ],
    ),
  );

  List<ReportConfig> get _reports => [
    ReportConfig(
      title: "Liste des admis",
      endpoint: '/reports/academic/admitted',
      fileName: 'liste_des_admis',
      formConfig: FormConfig(
        inputs: [
          _classeInputField,
        ],
      ),
    ),
    ReportConfig(
      title: "Liste des ajournés",
      endpoint: '/reports/academic/adjourned',
      fileName: 'liste_des_ajournes',
      formConfig: FormConfig(
        inputs: [
          _classeInputField,
        ],
      ),
    ),
    ReportConfig(
      title: "Classement des moyennes",
      endpoint: '/reports/academic/ranking',
      fileName: 'classement_de_moyennes',
      formConfig: FormConfig(
        inputs: [
          _classeInputField,
        ],
      ),
    ),
    ReportConfig(
      title: "Classification des moyennes",
      endpoint: '/reports/academic/classification',
      fileName: 'classification_des_moyennes',
      formConfig: FormConfig(
        inputs: [
          _classeInputField,
          InputField(
            field: 'step',
            type: InputFieldType.number,
            name: 'Le pas des tranches de notes et moyennes',
            required: true,
            placeholder: 'Ex: 2',
            description: 'Entrez une valeur numérique',
          ),
        ],
      ),
    ),
    ReportConfig(
      title: "Récapitulatif des moyennes par matière",
      endpoint: '/reports/academic/summary',
      fileName: 'recap_moyennes_matiere',
      formConfig: FormConfig(
        inputs: [
          _classeInputField,
        ],
      ),
    ),
    ReportConfig(
      title: "Récapitulatif des moyennes & rangs",
      endpoint: '/reports/academic/summary_avg_rang',
      fileName: 'recap_moyennes_rangs',
      formConfig: FormConfig(
        inputs: [
          _classeInputField,
        ],
      ),
    ),
  ];

  Future<void> _handleDownload(
    BuildContext context,
    ReportConfig report,
  ) async {
    Map<String, dynamic> data = {...filters};
    if (report.formConfig != null) {
      Map<String, dynamic>? formData = await _showDynamicFormDialog(
        context,
        report.formConfig!,
      );
      if (formData == null) return;
      data = {...formData, ...data};
    }

    if (context.mounted) {
      NovaTools.showDownloadingDialog(context, message: 'Téléchargement en cours...');
    }

    try {
      await NovaTools.download(
        uri: report.endpoint,
        name: "${report.fileName}_annee_academic.pdf",
        data: data,
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
                for (var input in List<Map<String, dynamic>>.from(
                  data['inputs'],
                )) {
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
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
            ),
          );
        },
      ),
    );
  }
}
