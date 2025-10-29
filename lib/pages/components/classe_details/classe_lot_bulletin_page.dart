import 'package:flutter/material.dart';
import 'package:novacole/components/data_models/default_data_grid.dart';
import 'package:novacole/components/loading_indicator.dart';
import 'package:novacole/components/permission_widgets.dart';
import 'package:novacole/utils/constants.dart';
import 'package:novacole/utils/permission_utils.dart';
import 'package:novacole/utils/tools.dart';

class ClasseLotBulletin extends StatefulWidget {
  final Map<String, dynamic> classe;

  const ClasseLotBulletin({super.key, required this.classe});

  @override
  ClasseLotBulletinState createState() {
    return ClasseLotBulletinState();
  }
}

class ClasseLotBulletinState extends State<ClasseLotBulletin> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultDataGrid(
        itemBuilder: (lot) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${lot['name']}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Période: ${lot['period']['name']}",
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    "Effectif: ${lot['effectif']}",
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Text(
                "Taux de réussite: ${lot['success_rate']} %",
                style: const TextStyle(
                  fontSize: 12,
                ),
              ),
              Text(
                "Forte moyenne: ${lot['highest_avg'].toStringAsFixed(2) ?? '-'}",
                style: const TextStyle(
                  fontSize: 12,
                ),
              ),
              Text(
                "Faible moyenne: ${lot['lower_avg'].toStringAsFixed(2) ?? '-'}",
                style: const TextStyle(
                  fontSize: 12,
                ),
              ),
            ],
          );
        },
        dataModel: 'lot_bulletin',
        canEdit: (data) => false,
        paginate: PaginationValue.paginated,
        formDefaultData: {'classe_id': widget.classe['id']},
        optionsBuilder: (data, reload, updateLine) {
          return [
            DisableIfNoPermission(
              permission: PermissionName.view(Entity.bulletin),
              child: ListTile(
                title: const Text('Télécharger'),
                leading: const Icon(Icons.cloud_download_outlined),
                onTap: () async {
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const SimpleDialog(
                      children: [
                        LoadingIndicator(type: LoadingIndicatorType.inkDrop),
                        SizedBox(height: 16),
                        Center(
                          child: Text(
                            "Téléchargement en cours...",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  );
                  await NovaTools.download(
                      uri: '/reports/classe/bulletins',
                      name: 'lot_bulletin_${widget.classe['name']}.pdf',
                      data: {
                        'lot_id': data['id'],
                      },
                      type: 'application/pdf');
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
              ),
            )
          ];
        },
        formInputsMutator: (inputs, data) {
          inputs = inputs.map<Map<String, dynamic>>((input) {
            if (input['field'] == 'classe_id') {
              input['value'] = widget.classe['id'];
              input['hidden'] = true;
            }
            if (input['field'] == 'period_id') {
              input['filters'] = input['filters'] ?? [] ;
              input['filters'].add({
                'field': 'degree',
                'value': widget.classe['level']['degree'],
              });
            }
            return input;
          }).toList();
          return inputs;
        },
        title: 'Lot de bulletin de ${widget.classe['name']}',
        query: {'order_by': 'created_at', 'order_direction': 'DESC'},
        data: {
          'filters': [
            {'field': 'classe_id', 'value': widget.classe['id']}
          ]
        });
  }
}
