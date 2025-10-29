import 'package:flutter/material.dart';
import 'package:novacole/components/json_schema.dart';
import 'package:novacole/pages/admin/reports/widgets/report_download_widget.dart';
import 'package:novacole/pages/admin/reports/widgets/report_types.dart';
import 'package:novacole/utils/tools.dart';

class FinanceReportDownloadPage extends StatelessWidget {
  final Map<String, dynamic> filters;
  final String? title;

  const FinanceReportDownloadPage({
    super.key,
    required this.filters,
    this.title,
  });

  List<ReportConfig> get _reports => [
    const ReportConfig(
      title: "Rapport par classe",
      endpoint: '/reports/financial/classe_report',
      fileName: 'rapport_par_classe',
      formConfig: FormConfig(
        inputs: [
          InputField(
            field: 'classe_id',
            entity: 'classe',
            type: InputFieldType.selectresource,
            name: 'Classe scolaire',
            required: true,
            description: 'Sélectionner une classe'
          ),
        ],
      ),
    ),
    const ReportConfig(
      title: "Journal des entrées",
      endpoint: '/reports/financial/incoming_diary',
      fileName: 'journal_des_entree',
      formConfig: FormConfig(
        inputs: [
          InputField(
            field: 'start_at',
            type: InputFieldType.date,
            name: "Date d'opération de:",
            required: true,
            description: 'Sélectionner une date'
          ),
          InputField(
              field: 'end_at',
              type: InputFieldType.date,
              name: 'au:',
              required: true,
              description: 'Sélectionner une date',
          ),
        ],
      ),
    ),
    const ReportConfig(
      title: "Journal des encaissements",
      endpoint: '/reports/financial/cash_diary',
      fileName: 'journal_des_encaissement',
      formConfig: FormConfig(
        inputs: [
          InputField(
            field: 'start_at',
            type: InputFieldType.date,
            name: "Date d'opération de:",
            required: true,
            description: 'Sélectionner une date'
          ),
          InputField(
              field: 'end_at',
              type: InputFieldType.date,
              name: 'au:',
              required: true,
              description: 'Sélectionner une date',
          ),
        ],
      ),
    ),
    const ReportConfig(
      title: "Rapport des entrées",
      endpoint: '/reports/financial/incoming_report',
      fileName: 'rapport_des_entree',
      formConfig: FormConfig(
        inputs: [
          InputField(
            field: 'start_at',
            type: InputFieldType.date,
            name: "Date d'opération de:",
            required: true,
            description: 'Sélectionner une date'
          ),
          InputField(
              field: 'end_at',
              type: InputFieldType.date,
              name: 'au:',
              required: true,
              description: 'Sélectionner une date',
          ),
        ],
      ),
    ),
    const ReportConfig(
      title: "Journal des dépenses",
      endpoint: '/reports/financial/outgoing_diary',
      fileName: 'journal_des_depense',
      formConfig: FormConfig(
        inputs: [
          InputField(
            field: 'start_at',
            type: InputFieldType.date,
            name: "Date d'opération de:",
            required: true,
            description: 'Sélectionner une date'
          ),
          InputField(
              field: 'end_at',
              type: InputFieldType.date,
              name: 'au:',
              required: true,
              description: 'Sélectionner une date',
          ),
        ],
      ),
    ),
    const ReportConfig(
      title: "Journal des décaissements",
      endpoint: '/reports/financial/payment_diary',
      fileName: 'journal_des_decaissements',
      formConfig: FormConfig(
        inputs: [
          InputField(
            field: 'start_at',
            type: InputFieldType.date,
            name: "Date d'opération de:",
            required: true,
            description: 'Sélectionner une date'
          ),
          InputField(
              field: 'end_at',
              type: InputFieldType.date,
              name: 'au:',
              required: true,
              description: 'Sélectionner une date',
          ),
        ],
      ),
    ),
    const ReportConfig(
      title: "Rapport des dépenses",
      endpoint: '/reports/financial/outgoing_report',
      fileName: 'rapport_des_depense',
      formConfig: FormConfig(
        inputs: [
          InputField(
            field: 'start_at',
            type: InputFieldType.date,
            name: "Date d'opération de:",
            required: true,
            description: 'Sélectionner une date'
          ),
          InputField(
              field: 'end_at',
              type: InputFieldType.date,
              name: 'au:',
              required: true,
              description: 'Sélectionner une date',
          ),
        ],
      ),
    ),
    const ReportConfig(
      title: "Bilan des opérations",
      endpoint: '/reports/financial/review',
      fileName: 'bilan_des_operations'
    ),
    const ReportConfig(
      title: "Bilan des flux de trésorerie",
      endpoint: '/reports/financial/financial_review',
      fileName: 'bilan_des_flux_de_tresorerie'
    ),
    const ReportConfig(
      title: "Rapport par degré scolaire",
      endpoint: '/reports/financial/degree_report',
      fileName: 'rapport_par_degre_scolaire',
      formConfig: FormConfig(
        inputs: [
          InputField(
              field: 'degree',
              type: InputFieldType.select,
              options: [
                SelectOption(label: "Primaire", value: 'primary'),
                SelectOption(label: "Collège", value: 'college'),
                SelectOption(label: "Lycée", value: 'high_school'),
              ],
              name: 'Degré scolaire',
              required: true,
              description: 'Sélectionner un degré'
          ),
          InputField(
              field: 'start_at',
              type: InputFieldType.date,
              name: "Date d'opération de:",
              required: true,
              description: 'Sélectionner une date'
          ),
          InputField(
            field: 'end_at',
            type: InputFieldType.date,
            name: 'au:',
            required: true,
            description: 'Sélectionner une date',
          ),
        ],
      ),
    ),
  ];

  Future<void> _handleDownload(
      BuildContext context,
      ReportConfig report,
      ) async {
    try {
      Map<String, dynamic> data = Map<String, dynamic>.from(filters);
      if (report.formConfig != null && report.formConfig!.inputs.isNotEmpty ) {
        final formData = await _showDynamicFormDialog(
          context,
          report.formConfig!,
        );
        if (formData == null) return;
        data.addAll(formData);
      }
      if (!context.mounted) return;
      NovaTools.showDownloadingDialog(context, message: 'Téléchargement en cours...');
      await NovaTools.download(
        uri: report.endpoint,
        name: _generateFileName(report),
        data: data,
      );
    } catch (e) {
      if (!context.mounted) return;
      _showErrorSnackBar(context, e);
    } finally {
      if (context.mounted && Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
    }
  }

  String _generateFileName(ReportConfig report) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return "${report.fileName}_$timestamp.pdf";
  }

  void _showErrorSnackBar(BuildContext context, Object error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Erreur lors du téléchargement: $error'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<Map<String, dynamic>?> _showDynamicFormDialog(
      BuildContext context,
      FormConfig formConfig,
      ) async {
    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => SimpleDialog(
        children: [
          SingleChildScrollView(
            child: JsonSchema(
              form: _buildFormData(formConfig),
              saveButtonText: 'Télécharger',
              actionSave: (data) => _handleFormSubmit(context, data),
            ),
          )
        ],
      ),
    );
  }

  Map<String, dynamic> _buildFormData(FormConfig config) {
    return {
      "inputs": config.inputs.map((input) => input.toMap()).toList(),
    };
  }

  Future<void> _handleFormSubmit(
      BuildContext context,
      Map<String, dynamic> data,
      ) async {
    final formData = <String, dynamic>{};
    for (var input in List<Map<String, dynamic>>.from(data['inputs'])) {
      formData[input['field']] = parseInputValue(input);
    }
    if(context.mounted){
      Navigator.of(context).pop(formData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Rapports financiers",
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
      body: SafeArea(
        child: ListView.builder(
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
      ),
    );
  }
}
