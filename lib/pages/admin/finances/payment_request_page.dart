import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:novacole/components/data_models/default_data_grid.dart';
import 'package:novacole/components/json_schema.dart';
import 'package:novacole/components/loading_indicator.dart';
import 'package:novacole/components/permission_widgets.dart';
import 'package:novacole/components/tag_widget.dart';
import 'package:novacole/controllers/auth_controller.dart';
import 'package:novacole/models/master_crud_model.dart';
import 'package:novacole/utils/constants.dart';
import 'package:novacole/utils/permission_utils.dart';
import 'package:novacole/utils/tools.dart';

class AdminPaymentRequestPage extends StatefulWidget {
  const AdminPaymentRequestPage({super.key});

  @override
  AdminPaymentRequestPageState createState() {
    return AdminPaymentRequestPageState();
  }
}

class AdminPaymentRequestPageState extends State<AdminPaymentRequestPage> {
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
      itemBuilder: (data) {
        Color tagColor = Colors.amber;
        if (data['status'] == 'pending') {
          tagColor = Colors.amber;
        } else if (data['status'] == 'accepted') {
          tagColor = Colors.green;
        } else if (data['status'] == 'rejected') {
          tagColor = Colors.red;
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${data['method_name']}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "N°${data['reference']}",
                  style: const TextStyle(fontSize: 15),
                ),
                Text(
                  currency(data['amount']),
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  NovaTools.dateFormat(data['payment_date']),
                  style: const TextStyle(fontSize: 15),
                ),
                TagWidget(
                  title: Text(
                    StringTranslateExtension(data['status'].toString()).tr(),
                    style: const TextStyle(color: Colors.white),
                  ),
                  color: tagColor,
                ),
              ],
            ),
          ],
        );
      },
      query: {'order_by': 'created_at', 'order_direction': 'DESC'},
      dataModel: 'payment_request',
      paginate: PaginationValue.paginated,
      title: 'Demandes de paiement',
      canAdd: false,
      optionVisible: false,
      canDelete: (item) => false,
      canEdit: (item) => false,
      onBack: () {
        Navigator.of(context).pop();
      },
      optionsBuilder: (item, reload, updateLine) {
        return [
          if (item['status'] != 'accepted')
            DisableIfNoPermission(
              permission: PermissionName.accept(Entity.paymentRequest),
              child: ListTile(
                leading: Icon(
                  Icons.check_box_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(
                  "Accepter",
                  style: TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  bool? result = await showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) {
                      return SimpleDialog(
                        contentPadding: const EdgeInsets.all(10),
                        children: [
                          const Text(
                            "Voulez vous vraiment valider cet paiement ?",
                            style: TextStyle(fontSize: 20),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  "Non",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                              const SizedBox(width: 20),
                              ElevatedButton(
                                onPressed: () async {
                                  Navigator.pop(context, true);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text("Accepter"),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  );
                  if (result == true) {
                    if (context.mounted) {
                      _showSavingDialog(context);
                    }
                    Map<String, dynamic>? response = await MasterCrudModel.post(
                      '/payment-request/accept/${item['id']}',
                    );
                    if (context.mounted) {
                      Navigator.pop(context, response);
                      if (response != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Demande de paiement acceptée !'),
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                        updateLine(response);
                      }
                    }
                  }
                },
              ),
            ),
          if (item['status'] != 'accepted' && item['status'] != 'rejected')
            DisableIfNoPermission(
              permission: PermissionName.reject(Entity.paymentRequest),
              child: ListTile(
                leading: const Icon(Icons.close_outlined, color: Colors.red),
                trailing: const Icon(Icons.chevron_right, color: Colors.red),
                title: const Text("Rejeter", style: TextStyle(color: Colors.red)),
                onTap: () async {
                  Navigator.pop(context);
                  Map<String, dynamic>? result = await showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) {
                      return SimpleDialog(
                        contentPadding: const EdgeInsets.all(10),
                        children: [
                          const Text(
                            "Voulez vous vraiment rejeter cet paiement ?",
                            style: TextStyle(fontSize: 20),
                            textAlign: TextAlign.center,
                          ),
                          JsonSchema(
                            saveButtonText: 'Rejeter',
                            form: {
                              'inputs': [
                                {
                                  "field": "message",
                                  "type": "textarea",
                                  "name": "Raison du rejet",
                                  "placeholder": "Saisir la raison du rejet",
                                  "required": true,
                                  "readOnly": true,
                                },
                              ],
                            },
                            actionSave: (data) async {
                              Map<String, dynamic>? formData = {};
                              List<Map<String, dynamic>>.from(data['inputs']).map(
                                (input) {
                                  formData[input['field']] = input['value'];
                                },
                              ).toList();
                              Navigator.pop(context, {
                                'form_data': formData,
                                'rejected': true,
                              });
                            },
                          ),
                        ],
                      );
                    },
                  );
                  if (result != null && result['rejected'] == true) {
                    _showSavingDialog(context);
                    Map<String, dynamic>? response = await MasterCrudModel.post(
                      '/payment-request/reject/${item['id']}',
                      data: result['form_data'],
                    );
                    Navigator.pop(context);

                    if (response != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Demande de paiement rejetée !'),
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                      reload();
                    }
                  }
                },
              ),
            ),
        ];
      },
    );
  }

  Future<void> _showSavingDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const SimpleDialog(
        children: [
          LoadingIndicator(type: LoadingIndicatorType.inkDrop),
          SizedBox(height: 16),
          Center(
            child: Text(
              "Traitement en cours...",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
