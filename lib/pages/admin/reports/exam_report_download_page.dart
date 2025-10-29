import 'package:flutter/material.dart';
import 'package:novacole/components/json_schema.dart';
import 'package:novacole/pages/admin/reports/widgets/report_download_widget.dart';
import 'package:novacole/pages/admin/reports/widgets/report_types.dart';
import 'package:novacole/utils/tools.dart';

class ExamReportDownloadPage extends StatelessWidget {
  final Map<String, dynamic> filters;
  final Map<String, dynamic> exam;

  ExamReportDownloadPage({
    super.key,
    required this.filters,
    required this.exam,
  });

  final List<ReportConfig> _reports = [
    /*const ReportConfig(
      title: "Relevés de notes",
      endpoint: '/reports/classe/exams/report',
      fileName: 'releve_de_notes',
      formConfig: FormConfig(
        inputs: [
          InputField(
            field: 'school_report',
            type: InputFieldType.boolean,
            name: 'Imprimer le rapport pour mon école uniquement',
            required: false,
            placeholder: '',
            description: '',
          ),
        ],
      ),
    ),*/
    const ReportConfig(
      title: "Liste des admis",
      endpoint: '/reports/classe/exams/admitted',
      fileName: 'liste_des_admis',
      formConfig: FormConfig(
        inputs: [
          InputField(
            field: 'school_report',
            type: InputFieldType.boolean,
            name: 'Imprimer le rapport pour mon école uniquement',
            required: false,
            placeholder: '',
            description: '',
          ),
        ],
      ),
    ),
    const ReportConfig(
      title: "Liste des ajournés",
      endpoint: '/reports/classe/exams/adjourned',
      fileName: 'liste_des_ajournes',
      formConfig: FormConfig(
        inputs: [
          InputField(
            field: 'school_report',
            type: InputFieldType.boolean,
            name: 'Imprimer le rapport pour mon école uniquement',
            required: false,
            placeholder: '',
            description: '',
          ),
        ],
      ),
    ),
    const ReportConfig(
      title: "Classement des moyennes",
      endpoint: '/reports/classe/exams/ranking',
      fileName: 'classement_de_moyennes',
      formConfig: FormConfig(
        inputs: [
          InputField(
            field: 'school_report',
            type: InputFieldType.boolean,
            name: 'Imprimer le rapport pour mon école uniquement',
            required: false,
            placeholder: '',
            description: '',
          ),
        ],
      ),
    ),
    const ReportConfig(
      title: "Classification des moyennes",
      endpoint: '/reports/classe/exams/classification',
      fileName: 'classification_des_moyennes',
      formConfig: FormConfig(
        inputs: [
          InputField(
            field: 'step',
            type: InputFieldType.number,
            name: 'Le pas des tranches de notes et moyennes',
            required: true,
            placeholder: 'Ex: 2',
            description: 'Entrez une valeur numérique',
          ),
          InputField(
            field: 'school_report',
            type: InputFieldType.boolean,
            name: 'Imprimer le rapport pour mon école uniquement',
            required: false,
            placeholder: '',
            description: '',
          ),
        ],
      ),
    ),
    const ReportConfig(
      title: "Récapitulatif des moyennes par matière",
      endpoint: '/reports/classe/exams/summary',
      fileName: 'recap_moyennes_matiere',
      formConfig: FormConfig(
        inputs: [
          InputField(
            field: 'school_report',
            type: InputFieldType.boolean,
            name: 'Imprimer le rapport pour mon école uniquement',
            required: false,
            placeholder: '',
            description: '',
          ),
        ],
      ),
    ),
    const ReportConfig(
      title: "Récapitulatif des moyennes & rangs",
      endpoint: '/reports/classe/exams/summary_avg_rang',
      fileName: 'recap_moyennes_rangs',
      formConfig: FormConfig(
        inputs: [
          InputField(
            field: 'school_report',
            type: InputFieldType.boolean,
            name: 'Imprimer le rapport pour mon école uniquement',
            required: false,
            placeholder: '',
            description: '',
          ),
        ],
      ),
    ),
  ];

  Future<void> _handleDownload(BuildContext context, ReportConfig report) async {
    if (report.formConfig != null) {
      final formData = await _showDynamicFormDialog(context, report.formConfig!);
      if (formData == null) return;
      filters.addAll(formData);
    }

    if (context.mounted) {
      NovaTools.showDownloadingDialog(context, message: 'Téléchargement en cours...');
    }

    try {
      await NovaTools.download(
        uri: report.endpoint,
        name: "${report.fileName}_${exam['name']}.pdf",
        data: filters,
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
                "inputs": formConfig.inputs.map((input) => input.toMap()).toList(),
              },
              saveButtonText: 'Télécharger',
              actionSave: (data) {
                formData = {};
                for (var input in List<Map<String, dynamic>>.from(data['inputs'])) {
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
        title: Text(
          "Rapports de ${exam['name']}",
          style: const TextStyle(
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
            ),
          );
        },
      ),
    );
  }
}
