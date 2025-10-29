import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jiffy/jiffy.dart';
import 'package:novacole/components/empty_page.dart';
import 'package:novacole/components/json_schema.dart';
import 'package:novacole/components/loading_indicator.dart';
import 'package:novacole/components/model_photo_widget.dart';
import 'package:novacole/models/master_crud_model.dart';
import 'package:novacole/utils/tools.dart';

class OfflinePaymentMethod extends StatefulWidget {
  final Map<String, dynamic> operation;

  const OfflinePaymentMethod({super.key, required this.operation});

  @override
  OfflinePaymentMethodState createState() {
    return OfflinePaymentMethodState();
  }
}

class OfflinePaymentMethodState extends State<OfflinePaymentMethod> {
  List<Map<String, dynamic>> paymentMethods = [];
  Map<String, dynamic>? school;

  List<Map<String, dynamic>> paymentRequestForm = [
    {
      "field": "payment_date",
      "type": "date",
      "name": "Date",
      "placeholder": "Entrer la date de l'opération",
      "required": true,
      "readOnly": true,
      "value": Jiffy.now().format(pattern: 'yyyy-MM-dd'),
    },
    {
      "field": "reference",
      "type": "text",
      "name": "Référence du paiement",
      "placeholder": "Saisir la référence du paiement",
      "required": true,
      "readOnly": true
    },
    {
      "field": "amount",
      "type": "currency",
      "name": "Montant",
      "placeholder": "Entrer le montant",
      "required": true,
      "readOnly": true
    },
    {
      "field": "details",
      "type": "textarea",
      "name": "Détails",
      "placeholder": "Saisir les détails de la transaction",
      "required": false,
      "readOnly": true
    },
  ];

  bool isLoading = true;

  @override
  void initState() {
    MasterCrudModel('school').get(widget.operation['school_id']).then((sc) {
      setState(() {
        if (sc != null) {
          school = Map<String, dynamic>.from(sc);
        }
      });
    });
    MasterCrudModel('payment_method').search(
      paginate: '0',
      filters: [],
    ).then((list) {
      setState(() {
        paymentMethods = List<Map<String, dynamic>>.from(list);
      });
      isLoading = false;
    }).catchError((err) {
      isLoading = false;
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Méthodes de paiement'),
        ),
        body: SafeArea(
          child: isLoading
              ? const LoadingIndicator()
              : (paymentMethods.isEmpty)
                  ? const EmptyPage()
                  : body(),
        ));
  }

  Widget body() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (school != null)
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  children: [
                    ModelPhotoWidget(
                      model: school!,
                      editable: false,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          school!['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          school!['address'],
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          "Tél: ${school!['phone'] ?? '-'}",
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            const SizedBox(height: 20),
            const Text(
              "Avertissement !",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const Text(
              "Ces moyens de paiement fournis par l'etablissement ne vous "
              "permettent pas de payer "
              "directement sur Novacole. Utilisez le numéro de compte pour "
              "faire le paiement (dépôt, virement ...) puis enregistrer"
              " les références de l'opération en cliquant sur "
              "le bouton Ajouter.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      "Opération: ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(widget.operation['operation_type'].toString().tr()),
                  ],
                ),
                Row(
                  children: [
                    const Text(
                      "Montant: ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(currency(widget.operation['net_amount'])),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...paymentMethods.map((method) {
              return Card(
                child: ListTile(
                  onTap: () {
                    Clipboard.setData(
                            ClipboardData(text: method['account_number']))
                        .then((_) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text("Numéro de compte copié"),
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                          ),
                        );
                      }
                    });
                  },
                  title: Text(
                    method['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    method['account_number'],
                    style: const TextStyle(fontSize: 18),
                  ),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      Map<String, dynamic>? formData =
                          await showModalBottomSheet(
                        isDismissible: false,
                        isScrollControlled: true,
                        context: context,
                        builder: (context) {
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                JsonSchema(
                                  form: {
                                    'inputs': paymentRequestForm,
                                  },
                                  actionSave: (data) {
                                    Map<String, dynamic> formData = {};
                                    for (var input in data['inputs']) {
                                      formData[input['field']] = input['value'];
                                    }
                                    Navigator.pop(context, formData);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                      if (formData != null) {
                        if (context.mounted) {
                          _showSavingDialog(context);
                        }
                        formData['entity'] = 'payment_request';
                        formData['school_id'] = widget.operation['school_id'];
                        formData['operation_id'] = widget.operation['id'];
                        formData['payment_method_id'] = method['id'];
                        formData['partner_id'] = widget.operation['partner_id'];
                        formData['partner_entity'] =
                            widget.operation['partner_entity'];
                        formData['position'] = widget.operation['position'];
                        Map<String, dynamic>? response =
                            await MasterCrudModel('payment_request')
                                .create(formData);
                        Navigator.pop(context);
                        if (response != null) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  "Le paiment a été enregistré",
                                ),
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                              ),
                            );
                            Navigator.pop(context);
                          }
                        }
                      }
                    },
                    child: const Text('Ajouter'),
                  ),
                ),
              );
            })
          ],
        ),
      ),
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
              "Enregistrement en cours...",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
