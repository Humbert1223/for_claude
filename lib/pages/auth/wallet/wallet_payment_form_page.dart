import 'package:flutter/material.dart';
import 'package:novacole/components/json_schema.dart';
import 'package:novacole/components/loading_indicator.dart';
import 'package:novacole/models/master_crud_model.dart';
import 'package:novacole/utils/tools.dart';

class WalletPaymentFormPage extends StatefulWidget {
  final String billingType;

  const WalletPaymentFormPage({
    super.key,
    required this.billingType,
  });

  @override
  WalletPaymentFormPageState createState() => WalletPaymentFormPageState();
}

class WalletPaymentFormPageState extends State<WalletPaymentFormPage> {
  final Map<String, dynamic> _paymentForm = {
    'inputs': [
      {
        'field': 'amount',
        'name': 'Montant',
        'type': 'number',
        'description': 'Minimum 200 FCFA',
        'min': 200,
        'placeholder': 'Entrer le montant',
        'required': true,
      },
      {
        'field': 'phone',
        'name': 'Numéro de téléphone',
        'type': 'tel',
        'description': 'Format: 90 XX XX XX',
        'placeholder': 'Ex: 90 12 34 56',
        'required': true,
      },
      {
        'field': 'method',
        'name': 'Méthode de paiement',
        'type': 'radio',
        'options': [
          {'label': 'Mix by Yas (Mixx By Yas)', 'value': 'TMONEY'},
          {'label': 'Moov Money (Flooz)', 'value': 'FLOOZ'},
        ],
        'description': 'Choisissez votre opérateur mobile',
        'required': true,
      },
    ],
  };

  bool get _isWalletRecharge => widget.billingType == 'wallet';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: JsonSchema(
                form: _paymentForm,
                actionSave: _handlePayment,
                saveButtonText: 'Continuer',
              ),
            ),
            _buildInfoCard(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        _isWalletRecharge
            ? 'Recharger le portefeuille'
            : 'Acheter du crédit SMS',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      elevation: 0,
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(alpha:0.8),
          ],
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha:0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isWalletRecharge
                  ? Icons.account_balance_wallet
                  : Icons.sms,
              size: 48,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _isWalletRecharge
                ? 'Rechargez votre portefeuille école'
                : 'Achetez vos crédits SMS',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Paiement sécurisé via Mobile Money',
            style: TextStyle(
              color: Colors.white.withValues(alpha:0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Informations importantes',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoItem(
              icon: Icons.check_circle_outline,
              text: 'Montant minimum: 200 FCFA',
            ),
            _buildInfoItem(
              icon: Icons.check_circle_outline,
              text: 'Frais: 3% (Mixx By Yas) / 2.6% (Flooz)',
            ),
            _buildInfoItem(
              icon: Icons.check_circle_outline,
              text: 'Confirmation instantanée',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePayment(dynamic data) async {
    final formData = _extractFormData(data);
    final paymentDetails = _calculatePaymentDetails(formData);

    final confirmed = await _showPaymentSummary(context, paymentDetails);
    if (confirmed != true) return;

    if (!mounted) return;
    _showLoadingDialog(context, 'Envoi de la requête en cours...');

    try {
      final billing = await _processPayment(formData);

      if (!mounted) return;
      Navigator.of(context).pop(); // Fermer le loading

      if (billing != null) {
        final success = await _showValidationDialog(context);

        if (success && mounted) {
          _showLoadingDialog(context, 'Vérification du paiement...');
          await _verifyPayment(billing['id']);

          if (mounted) {
            Navigator.of(context).pop(); // Fermer le loading
            _showSuccessDialog(context);
          }
        }
      } else {
        if (mounted) {
          _showErrorDialog(context, 'Échec de la création du paiement');
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Fermer le loading
        _showErrorDialog(context, 'Une erreur est survenue');
      }
    }
  }

  Map<String, dynamic> _extractFormData(dynamic data) {
    final formData = <String, dynamic>{};
    for (var input in List<Map<String, dynamic>>.from(data['inputs'])) {
      formData[input['field']] = input['value'];
    }
    return formData;
  }

  PaymentDetails _calculatePaymentDetails(Map<String, dynamic> formData) {
    final amount = double.parse(formData['amount'].toString());
    final rate = formData['method'] == 'FLOOZ' ? 0.026 : 0.03;
    final fees = amount * rate;
    final total = amount + fees;
    final methodName = formData['method'] == 'FLOOZ'
        ? 'Moov Money'
        : 'Mixx By Yas';

    return PaymentDetails(
      amount: amount,
      fees: fees,
      total: total,
      method: methodName,
      phone: formData['phone'],
    );
  }

  Future<bool?> _showPaymentSummary(
      BuildContext context,
      PaymentDetails details,
      ) {
    final theme = Theme.of(context);

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withValues(alpha:0.8),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.receipt_long,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Récapitulatif',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryRow(
                      'Méthode',
                      details.method,
                      isHighlight: false,
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryRow(
                      'Numéro',
                      details.phone,
                      isHighlight: false,
                    ),
                    const Divider(height: 32),
                    _buildSummaryRow(
                      'Montant de recharge',
                      currency(details.amount),
                      isHighlight: false,
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryRow(
                      'Frais de transaction',
                      currency(details.fees),
                      color: Colors.orange,
                      isHighlight: false,
                    ),
                    const Divider(height: 32),
                    _buildSummaryRow(
                      'TOTAL À PAYER',
                      currency(details.total),
                      isHighlight: true,
                    ),
                  ],
                ),
              ),

              // Actions
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Annuler'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Confirmer'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryRow(
      String label,
      String value, {
        Color? color,
        bool isHighlight = false,
      }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isHighlight ? 16 : 14,
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isHighlight ? 22 : 16,
            fontWeight: FontWeight.bold,
            color: color ?? (isHighlight ? Colors.green : Colors.black87),
          ),
        ),
      ],
    );
  }

  Future<bool> _showValidationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          icon: Icon(
            Icons.phone_android,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: const Text(
            'Validez le paiement',
            textAlign: TextAlign.center,
          ),
          content: const Text(
            'Composez votre code PIN sur votre téléphone pour valider le paiement, puis cliquez sur Terminer.',
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(true),
              icon: const Icon(Icons.check_circle),
              label: const Text('Terminer'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        );
      },
    ).then((value) => value ?? false);
  }

  Future<void> _showSuccessDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          icon: const Icon(
            Icons.check_circle,
            size: 64,
            color: Colors.green,
          ),
          title: const Text(
            'Paiement réussi !',
            textAlign: TextAlign.center,
          ),
          content: Text(
            _isWalletRecharge
                ? 'Votre portefeuille a été rechargé avec succès.'
                : 'Vos crédits SMS ont été ajoutés avec succès.',
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Terminer'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showErrorDialog(BuildContext context, String message) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          icon: const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          title: const Text(
            'Erreur',
            textAlign: TextAlign.center,
          ),
          content: Text(
            message,
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const LoadingIndicator(type: LoadingIndicatorType.inkDrop),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> _processPayment(Map<String, dynamic> data) async {
    data['entity'] = 'billing';
    data['name'] = widget.billingType;
    return await MasterCrudModel('billing').create(data);
  }

  Future<dynamic> _verifyPayment(String paymentId) async {
    return await MasterCrudModel.post(
      '/core/billing/verify-payment/$paymentId',
    );
  }
}

class PaymentDetails {
  final double amount;
  final double fees;
  final double total;
  final String method;
  final String phone;

  const PaymentDetails({
    required this.amount,
    required this.fees,
    required this.total,
    required this.method,
    required this.phone,
  });
}