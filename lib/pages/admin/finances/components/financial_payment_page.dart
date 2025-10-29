import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:novacole/components/json_schema.dart';
import 'package:novacole/components/loading_indicator.dart';
import 'package:novacole/models/form.dart';
import 'package:novacole/models/master_crud_model.dart';

class FinancePaymentForm extends StatefulWidget {
  final Map<String, dynamic> operation;
  final Function? onSave;

  const FinancePaymentForm({
    super.key,
    required this.operation,
    this.onSave,
  });

  @override
  FinancePaymentFormState createState() {
    return FinancePaymentFormState();
  }
}

class FinancePaymentFormState extends State<FinancePaymentForm> {
  Map<String, dynamic>? paymentForm;
  bool isLoading = true;

  @override
  void initState() {
    CoreForm().get(entity: 'payment').then((value) {
      if (value != null) {
        List inputs = List.from(value['inputs']).map((e) {
          if(e['field'] == 'payment_date'){
            e['value'] = Jiffy.now().format(pattern: 'yyyy-MM-dd');
          }
          if (['position', 'partner_id', 'operation_id'].contains(e['field'])) {
            e['hidden'] = true;
          }
          return e;
        }).toList();
        setState(() {
          paymentForm = value;
          paymentForm!['inputs'] = inputs;
        });
      }
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
    return isLoading
        ? const LoadingIndicator()
        : JsonSchema(
            form: paymentForm!,
            actionSave: (data) async {
              Map<String, dynamic> formData = {};
              for (var el in List.from(data['inputs'])) {
                formData[el['field']] = el['value'];
              }
              formData['entity'] = 'payment';
              formData['form_id'] = data['id'];
              formData['operation_id'] = widget.operation['id'];
              formData['partner_entity'] = widget.operation['partner_entity'];
              formData['partner_id'] = widget.operation['partner_id'];
              formData['position'] = widget.operation['position'];

              var result = await MasterCrudModel('payment').create(formData);
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

class PaymentFormPage extends StatelessWidget {
  final Map<String, dynamic> operation;
  final Function? onSave;

  const PaymentFormPage({
    super.key,
    required this.operation,
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text(
              "Ajouter un paiement",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          FinancePaymentForm(
            operation: operation,
            onSave: onSave,
          ),
        ],
      ),
    );
  }
}
