import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:novacole/components/data_models/default_data_grid.dart';
import 'package:novacole/components/loading_indicator.dart';
import 'package:novacole/components/tag_widget.dart';
import 'package:novacole/models/master_crud_model.dart';
import 'package:novacole/models/user_model.dart';
import 'package:novacole/utils/tools.dart';

class TransactionHistoryPage extends StatelessWidget {
  final Map<String, dynamic>? school;
  final UserModel? user;

  const TransactionHistoryPage({
    super.key,
    this.school,
    this.user,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultDataGrid(
      itemBuilder: (data) => _buildTransactionItem(context, data),
      canEdit: (data) => false,
      canDelete: (data) => false,
      canAdd: false,
      dataModel: 'billing',
      paginate: PaginationValue.paginated,
      title: "Historique des paiements",
      data: {
        'filters': [
          {'field': 'school_id', 'value': school?['id']},
          {'field': 'created_by', 'value': user?.id},
        ],
      },
      optionsBuilder: (data, reload, updateLine) {
        return _buildOptions(context, data, updateLine);
      },
    );
  }

  Widget _buildTransactionItem(BuildContext context, dynamic data) {
    final theme = Theme.of(context);
    final transactionInfo = _getTransactionInfo(data['status']);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showTransactionDetails(context, data),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icône de transaction
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: transactionInfo.color.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  transactionInfo.icon,
                  color: transactionInfo.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // Informations de transaction
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            data['name'],
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ).tr(),
                        ),
                        TagWidget(
                          title: Text(
                            transactionInfo.label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          color: transactionInfo.color,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Date
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          NovaTools.dateFormat(data['billing_date']),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Référence
                    Row(
                      children: [
                        Icon(
                          Icons.tag,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            "Ref: ${data['reference'] ?? 'N/A'}",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Montant
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Montant',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          currency(data['amount']),
                          style: TextStyle(
                            color: transactionInfo.color,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildOptions(
      BuildContext context,
      dynamic data,
      updateLine,
      ) {
    if (data['status'] == 0) return [];

    return [
      ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha:0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.refresh,
            color: Colors.blue,
            size: 20,
          ),
        ),
        title: const Text(
          'Vérifier le paiement',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: const Text(
          'Actualiser le statut de la transaction',
          style: TextStyle(fontSize: 12),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
        onTap: () => _verifyPayment(context, data, updateLine),
      ),
    ];
  }

  Future<void> _verifyPayment(
      BuildContext context,
      dynamic data,
      updateLine,
      ) async {
    Navigator.pop(context);

    _showLoadingDialog(
      context,
      title: 'Vérification',
      message: 'Vérification du statut du paiement en cours...',
    );

    try {
      final response = await MasterCrudModel.post(
        '/core/billing/verify-payment/${data['id']}',
      );

      if (context.mounted) {
        Navigator.pop(context);

        if (response != null) {
          updateLine(response);
          _showSuccessSnackbar(context, 'Paiement vérifié avec succès');
        } else {
          _showErrorSnackbar(context, 'Échec de la vérification');
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        _showErrorSnackbar(context, 'Erreur lors de la vérification');
      }
    }
  }

  void _showTransactionDetails(BuildContext context, dynamic data) {
    final transactionInfo = _getTransactionInfo(data['status']);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Titre
              Row(
                children: [
                  Icon(
                    transactionInfo.icon,
                    color: transactionInfo.color,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Détails de la transaction',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Détails
              _buildDetailRow('Nom', data['name']),
              _buildDetailRow(
                'Date',
                NovaTools.dateFormat(data['billing_date']),
              ),
              _buildDetailRow('Référence', data['reference'] ?? 'N/A'),
              _buildDetailRow('Montant', currency(data['amount']), isAmount: true),
              _buildDetailRow('Statut', transactionInfo.label, isStatus: true),

              const SizedBox(height: 24),

              // Bouton fermer
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Fermer'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isAmount = false, bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isAmount || isStatus ? _getTransactionInfo(0).color : null,
            ),
          ),
        ],
      ),
    );
  }

  TransactionInfo _getTransactionInfo(int status) {
    switch (status) {
      case 0:
        return const TransactionInfo(
          color: Colors.green,
          label: 'Succès',
          icon: Icons.check_circle,
        );
      case 2:
        return const TransactionInfo(
          color: Colors.amber,
          label: 'En cours',
          icon: Icons.pending,
        );
      default:
        return const TransactionInfo(
          color: Colors.red,
          label: 'Annulé',
          icon: Icons.cancel,
        );
    }
  }

  Future<void> _showLoadingDialog(
      BuildContext context, {
        required String title,
        required String message,
      }) {
    return showDialog(
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
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

class TransactionInfo {
  final Color color;
  final String label;
  final IconData icon;

  const TransactionInfo({
    required this.color,
    required this.label,
    required this.icon,
  });
}