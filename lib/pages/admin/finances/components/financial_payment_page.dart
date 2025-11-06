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
  FinancePaymentFormState createState() => FinancePaymentFormState();
}

class FinancePaymentFormState extends State<FinancePaymentForm> {
  Map<String, dynamic>? paymentForm;
  bool isLoading = true;

  @override
  void initState() {
    CoreForm().get(entity: 'payment').then((value) {
      if (value != null) {
        List inputs = List.from(value['inputs']).map((e) {
          if (e['field'] == 'payment_date') {
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
      setState(() => isLoading = false);
    });
    super.initState();
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[700] : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryColor,
                  primaryColor.withValues(alpha:0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha:0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha:0.25),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha:0.3),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.payment_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Nouveau paiement",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Enregistrez un nouveau paiement",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Operation info card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : Colors.grey[50],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha:0.1)
                    : Colors.black.withValues(alpha:0.05),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 18,
                      color: primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Opération concernée',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  operation['name'] ?? 'Sans nom',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.grey[900],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoChip(
                        'Montant',
                        currency(operation['amount']),
                        Icons.attach_money_rounded,
                        primaryColor,
                        isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoChip(
                        'Reste',
                        currency(operation['net_amount'] - operation['total_payment']),
                        Icons.pending_outlined,
                        Colors.orange,
                        isDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Form
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: FinancePaymentForm(
                operation: operation,
                onSave: onSave,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(
      String label,
      String value,
      IconData icon,
      Color color,
      bool isDark,
      ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha:0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.grey[900],
            ),
          ),
        ],
      ),
    );
  }
}

// Helper function (à ajouter si elle n'existe pas)
String currency(dynamic value) {
  if (value == null) return '0 FCFA';
  return '${value.toString()} FCFA';
}