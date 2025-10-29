import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:novacole/components/json_schema.dart';
import 'package:novacole/pages/admin/reports/widgets/report_download_widget.dart';
import 'package:novacole/pages/admin/reports/widgets/report_types.dart';
import 'package:novacole/utils/tools.dart';

class ClasseReportDownloadPage extends StatelessWidget {
  final Map<String, dynamic> filters;
  final Map<String, dynamic> classe;

  const ClasseReportDownloadPage({
    super.key,
    required this.filters,
    required this.classe,
  });

  List<ReportConfig> get _reports => [
        ReportConfig(
          title: "Fiche de présence",
          endpoint: '/reports/classe/attendance-list',
          fileName: 'fiche_de_presence',
          formConfig: FormConfig(
            inputs: [
              InputField(
                field: 'start_at',
                type: InputFieldType.date,
                name: 'Semaine du',
                required: true,
                description: 'Sélectionner une date',
                defaultValue: Jiffy.now().format(pattern: 'yyyy-MM-dd'),
              ),
            ],
          ),
        ),
        ReportConfig(
          title: "Fiche de notes",
          endpoint: '/reports/classe/mark-file',
          fileName: 'fiche_de_note',
          formConfig: FormConfig(
            inputs: [
              InputField(
                field: 'subject_id',
                type: InputFieldType.selectresource,
                name: 'Matière',
                entity: 'subject',
                required: true,
                description: 'Sélectionner une matière',
                resourceFilters: ResourceFilters(
                  filters: [
                    FilterCriteria(
                      field: 'classe_id',
                      value: classe['id'],
                    ),
                  ],
                ),
              ),
              InputField(
                field: 'period_id',
                type: InputFieldType.selectresource,
                name: 'Période scolaire',
                entity: 'period',
                required: true,
                description: 'Sélectionner une période',
                resourceFilters: ResourceFilters(
                  filters: [
                    FilterCriteria(
                      field: 'degree',
                      value: filters['degree'],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        ReportConfig(
          title: "Bulletins périodiques",
          endpoint: '/reports/classe/bulletins',
          fileName: 'lot_de_bulletin',
          formConfig: FormConfig(
            inputs: [
              InputField(
                field: 'lot_id',
                entity: 'lot_bulletin',
                type: InputFieldType.selectresource,
                name: 'Lot de bulletin',
                required: true,
                description: 'Sélectionner le lot de bulletin',
                resourceFilters: ResourceFilters(
                  filters: [
                    FilterCriteria(
                      field: 'classe_id',
                      value: classe['id'],
                    ),
                  ],
                ),
              ),
              InputField(
                field: 'order',
                type: InputFieldType.boolean,
                name:
                    "Voulez-vous commander l'impression des bulletins par les services de Novacole",
                required: true,
                description: '',
              ),
            ],
          ),
        ),
        ReportConfig(
          title: "Classement des moyennes",
          endpoint: '/reports/classe/periods/ranking',
          fileName: 'classement_de_moyennes',
          formConfig: FormConfig(
            inputs: [
              InputField(
                field: 'lot_id',
                entity: 'lot_bulletin',
                type: InputFieldType.selectresource,
                name: 'Lot de bulletin',
                required: true,
                description: 'Sélectionner une matière',
                resourceFilters: ResourceFilters(
                  filters: [
                    FilterCriteria(
                      field: 'classe_id',
                      value: classe['id'],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        ReportConfig(
          title: "Classification des moyennes",
          endpoint: '/reports/classe/periods/classification',
          fileName: 'classification_des_moyennes',
          formConfig: FormConfig(
            inputs: [
              InputField(
                field: 'lot_id',
                entity: 'lot_bulletin',
                type: InputFieldType.selectresource,
                name: 'Lot de bulletin',
                required: true,
                description: 'Sélectionner une matière',
                resourceFilters: ResourceFilters(
                  filters: [
                    FilterCriteria(
                      field: 'classe_id',
                      value: classe['id'],
                    ),
                  ],
                ),
              ),
              InputField(
                field: 'step',
                type: InputFieldType.number,
                name: 'Le pas des tranches de notes et moyennes',
                required: true,
                description: 'Entrez une valeur numérique',
                defaultValue: '2',
              ),
            ],
          ),
        ),
        ReportConfig(
          title: "Récapitulatif des moyennes par matière",
          endpoint: '/reports/classe/periods/summary',
          fileName: 'recap_moyennes_matiere',
          formConfig: FormConfig(
            inputs: [
              InputField(
                field: 'lot_id',
                entity: 'lot_bulletin',
                type: InputFieldType.selectresource,
                name: 'Lot de bulletin',
                required: true,
                description: 'Sélectionner une matière',
                resourceFilters: ResourceFilters(
                  filters: [
                    FilterCriteria(
                      field: 'classe_id',
                      value: classe['id'],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        ReportConfig(
          title: "Récapitulatif des moyennes & rangs",
          endpoint: '/reports/classe/periods/summary_avg_rang',
          fileName: 'recap_moyennes_rangs',
          formConfig: FormConfig(
            inputs: [
              InputField(
                field: 'lot_id',
                entity: 'lot_bulletin',
                type: InputFieldType.selectresource,
                name: 'Lot de bulletin',
                required: true,
                description: 'Sélectionner une matière',
                resourceFilters: ResourceFilters(
                  filters: [
                    FilterCriteria(
                      field: 'classe_id',
                      value: classe['id'],
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
    try {
      if (report.formConfig != null) {
        final formData =
            await _showDynamicFormDialog(context, report.formConfig!);
        if (formData == null) return;
        filters.addAll(formData);
      }

      if (!context.mounted) return;
      NovaTools.showDownloadingDialog(context, message: 'Téléchargement en cours...');

      await NovaTools.download(
        uri: report.endpoint,
        name: _generateFileName(report),
        data: filters,
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
    return "${report.fileName}_${classe['name']}_$timestamp.pdf";
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
    await Future.delayed(const Duration(milliseconds: 500));
    if (context.mounted) {
      Navigator.of(context).pop(formData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Rapports de la classe de ${classe['name']}",
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
