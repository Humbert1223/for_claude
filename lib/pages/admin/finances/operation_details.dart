import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:novacole/models/master_crud_model.dart';
import 'package:novacole/pages/admin/finances/components/financial_discount_page.dart';
import 'package:novacole/pages/admin/finances/components/financial_payment_page.dart';
import 'package:novacole/utils/tools.dart';

class OperationDetailsPage extends StatefulWidget {
  final Map<String, dynamic> operation;

  const OperationDetailsPage({super.key, required this.operation});

  @override
  OperationDetailsPageState createState() {
    return OperationDetailsPageState();
  }
}

class OperationDetailsPageState extends State<OperationDetailsPage> {
  Map? partner;
  late Map<String, dynamic> operation;

  @override
  void initState() {
    operation = widget.operation;
    if (operation['partner_id'] != null &&
        operation['partner_entity'] != null) {
      MasterCrudModel(operation['partner_entity'])
          .get(operation['partner_id'])
          .then(
        (value) {
          setState(() {
            partner = value;
          });
        },
      );
    }
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
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text(
          "Détails de l'opération",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "${operation['name']}",
                      style:
                          const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text("Total à payer: ${currency(operation['amount'])}"),
                    Text(
                        "Total des paiements: ${currency(operation['total_payment'])}"),
                    Text("Remises: ${currency(operation['total_discount'])}"),
                    Text(
                        "Reste à payer : ${currency(operation['net_amount'] - operation['total_payment'])}"),
                  ],
                ),
              ),
              if (partner != null)
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "${partner!['full_name']}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          "${partner!['address']}",
                        ),
                        Text(
                          "Matricule: ${partner!['matricule'] ?? '-'}",
                        ),
                        Text(
                          "Téléphone: ${partner!['phone'] ?? '-'}",
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        isScrollControlled: true,
                        isDismissible: false,
                        context: context,
                        builder: (context) {
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom,
                            ),
                            child: DiscountPage(
                              operation: operation,
                              onSave: (value) {
                                _refresh();
                              },
                            ),
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.amber,
                    ),
                    child: const Text('Remise'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        isScrollControlled: true,
                        isDismissible: false,
                        context: context,
                        builder: (context) {
                          return Container(
                            padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).padding.bottom,
                            ),
                            child: PaymentFormPage(
                              operation: operation,
                              onSave: (value) {
                                _refresh();
                              },
                            ),
                          );
                        },
                      );
                    },
                    child: const Text('Payer'),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Table(
                border: TableBorder.all(),
                columnWidths: {4: FixedColumnWidth(40)},
                children: [
                  const TableRow(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Date',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Réf',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Moy.',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Montant',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      Text(''),
                    ],
                  ),
                  ...List.from(operation['payments']).map<TableRow>((e) {
                    return TableRow(children: [
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text(
                          NovaTools.dateFormat(e['payment_date']),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text(
                          "${e['reference'] ?? '-'}",
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text(
                          "${e['payment_method']}",
                          style: const TextStyle(fontSize: 12),
                        ).tr(),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text(
                          currency(e['amount']),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          MasterCrudModel.delete(e['id'], 'payment')
                              .then((value) {
                                _refresh();
                          });
                        },
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                      ),
                    ]);
                  })
                ],
              ),
              if (List.from(operation['payments']).isEmpty)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(
                    child: Text('Aucun payement...'),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  _refresh() {
    MasterCrudModel('operation').get(operation['id']).then((value) {
      if (value != null) {
        setState(() {
          operation = value;
        });
      }
    });
  }
}
