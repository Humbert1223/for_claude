import 'package:flutter/material.dart';
import 'package:novacole/components/json_schema.dart';
import 'package:novacole/models/master_crud_model.dart';
import 'package:novacole/utils/tools.dart';

class FinanceDiscountForm extends StatefulWidget {
  final Map<String, dynamic> operation;
  final Function? onSave;

  const FinanceDiscountForm({
    super.key,
    required this.operation,
    this.onSave,
  });

  @override
  FinanceDiscountFormState createState() {
    return FinanceDiscountFormState();
  }
}

class FinanceDiscountFormState extends State<FinanceDiscountForm> {
  List discountForm = [
    {
      'field': 'discount_date',
      'type': 'date',
      'name': 'Date',
      'description': 'Date de la remise',
      'placeholder': 'Saisir la date',
      'required': true
    },
    {
      'field': 'amount',
      'type': 'currency',
      'name': 'Montant',
      'description': 'Montant de la remise',
      'placeholder': 'Saisir le montant',
      'required': true
    }
  ];

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
    return JsonSchema(
      form: {'inputs': discountForm},
      actionSave: (data) async {
        Map<String, dynamic> formData = {};
        for (var el in List.from(data['inputs'])) {
          formData[el['field']] = el['value'];
        }
        var result = await MasterCrudModel.post(
          '/operations/discount/create/${widget.operation['id']}',
          data: formData,
        );
        if (result != null) {
          if (widget.onSave != null) {
            widget.onSave!(result);
          }
          Navigator.pop(context);
        }
      },
    );
  }
}

class DiscountPage extends StatelessWidget {
  final Map<String, dynamic> operation;
  final Function? onSave;

  const DiscountPage({
    super.key,
    required this.operation,
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Remises",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Table(
              border: TableBorder.all(),
              children: [
                const TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Date',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Montant',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
                ...List.from(operation['discounts'] ?? []).map((e) {
                  return TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child:
                            Text(NovaTools.dateFormat(e['discount_date'])),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(currency(e['amount'])),
                      ),
                    ],
                  );
                })
              ],
            ),
          ),
          if (List.from(operation['discounts'] ?? []).isEmpty)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(
                child: Text('Aucune remise'),
              ),
            ),
          FinanceDiscountForm(
            operation: operation,
            onSave: onSave,
          )
        ],
      ),
    );
  }
}
