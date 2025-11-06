import 'package:flutter/material.dart';
import 'package:novacole/components/app_bar_back_button.dart';
import 'package:novacole/components/json_schema.dart';
import 'package:novacole/pages/admin/reports/widgets/report_download_widget.dart';
import 'package:novacole/pages/admin/reports/widgets/report_types.dart';
import 'package:novacole/utils/tools.dart';

class LevelReportDownloadPage extends StatelessWidget {
  final Map<String, dynamic> filters;
  final Map<String, dynamic> level;
  final String? title;

  const LevelReportDownloadPage({
    super.key,
    required this.filters,
    required this.level,
    this.title,
  });

  List<ReportConfig> get _reports => [
        ReportConfig(
          title: "Liste des admis",
          endpoint: '/reports/levels/admitted',
          fileName: 'liste_des_admis',
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
              InputField(
                field: 'serie_id',
                entity: 'serie',
                type: InputFieldType.selectresource,
                name: 'Série',
                required: true,
                description: 'Sélectionner une série',
                hidden: filters['degree'] != 'high_school'
              ),
            ],
          ),
        ),
        ReportConfig(
          title: "Liste des ajournés",
          endpoint: '/reports/levels/adjourned',
          fileName: 'liste_des_journes',
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
              InputField(
                  field: 'serie_id',
                  entity: 'serie',
                  type: InputFieldType.selectresource,
                  name: 'Série',
                  required: true,
                  description: 'Sélectionner une série',
                  hidden: filters['degree'] != 'high_school'
              ),
            ],
          ),
        ),
        ReportConfig(
          title: "Classement des moyennes",
          endpoint: '/reports/levels/ranking',
          fileName: 'classement_de_moyennes',
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
              InputField(
                  field: 'serie_id',
                  entity: 'serie',
                  type: InputFieldType.selectresource,
                  name: 'Série',
                  required: true,
                  description: 'Sélectionner une série',
                  hidden: filters['degree'] != 'high_school'
              ),
            ],
          ),
        ),
        ReportConfig(
          title: "Classification des moyennes",
          endpoint: '/reports/levels/classification',
          fileName: 'classification_des_moyennes',
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
              InputField(
                  field: 'serie_id',
                  entity: 'serie',
                  type: InputFieldType.selectresource,
                  name: 'Série',
                  required: true,
                  description: 'Sélectionner une série',
                  hidden: filters['degree'] != 'high_school'
              ),
              const InputField(
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
          endpoint: '/reports/levels/summary',
          fileName: 'recap_moyennes_matiere',
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
              InputField(
                  field: 'serie_id',
                  entity: 'serie',
                  type: InputFieldType.selectresource,
                  name: 'Série',
                  required: true,
                  description: 'Sélectionner une série',
                  hidden: filters['degree'] != 'high_school'
              ),
            ],
          ),
        ),
        ReportConfig(
          title: "Récapitulatif des moyennes & rangs",
          endpoint: '/reports/levels/summary_avg_rang',
          fileName: 'recap_moyennes_rangs',
          formConfig: FormConfig(
            inputs: [
              InputField(
                  field: 'serie_id',
                  entity: 'serie',
                  type: InputFieldType.selectresource,
                  name: 'Série',
                  required: true,
                  description: 'Sélectionner une série',
                  hidden: filters['degree'] != 'high_school'
              ),
            ]
          )
        ),
      ];

  Future<void> _handleDownload(
    BuildContext context,
    ReportConfig report,
  ) async {
    try {
      if (report.formConfig != null && report.formConfig!.inputs.isNotEmpty ) {
        final formData = await _showDynamicFormDialog(
          context,
          report.formConfig!,
        );
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
    return "${report.fileName}_${level['name']}_$timestamp.pdf";
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
        title: Text(
          "Rapports du niveau ${level['name']}",
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: AppBarBackButton(),
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
