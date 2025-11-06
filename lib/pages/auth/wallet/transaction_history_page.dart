import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:novacole/components/data_models/default_data_grid.dart';
import 'package:novacole/components/loading_indicator.dart';
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
      itemBuilder: (data) => _buildCompactTransactionItem(context, data),
      canEdit: (data) => false,
      canDelete: (data) => false,
      canAdd: false,
      dataModel: 'billing',
      paginate: PaginationValue.paginated,
      title: "Historique",
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

  Widget _buildCompactTransactionItem(BuildContext context, dynamic data) {
    final theme = Theme.of(context);
    final transactionInfo = _getTransactionInfo(data['status']);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha:0.1),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showCompactTransactionDetails(context, data),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Icône compacte
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: transactionInfo.color.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  transactionInfo.icon,
                  color: transactionInfo.color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),

              // Informations
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            data['name'],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ).tr(),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: transactionInfo.color,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            transactionInfo.label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 11,
                          color: theme.colorScheme.onSurface.withValues(alpha:0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          NovaTools.dateFormat(data['billing_date']),
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.colorScheme.onSurface.withValues(alpha:0.6),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '•',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withValues(alpha:0.4),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            data['reference'] ?? 'N/A',
                            style: TextStyle(
                              fontSize: 10,
                              color: theme.colorScheme.onSurface.withValues(alpha:0.4),
                              fontFamily: 'monospace',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Montant
              Text(
                currency(data['amount']),
                style: TextStyle(
                  color: transactionInfo.color,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
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
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha:0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(
            Icons.refresh,
            color: Colors.blue,
            size: 18,
          ),
        ),
        title: const Text(
          'Vérifier le paiement',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: const Text(
          'Actualiser le statut',
          style: TextStyle(fontSize: 11),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
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

    _showCompactLoadingDialog(
      context,
      title: 'Vérification',
      message: 'Vérification en cours...',
    );

    try {
      final response = await MasterCrudModel.post(
        '/core/billing/verify-payment/${data['id']}',
      );

      if (context.mounted) {
        Navigator.pop(context);

        if (response != null) {
          updateLine(response);
          _showSuccessSnackbar(context, 'Paiement vérifié');
        } else {
          _showErrorSnackbar(context, 'Échec de la vérification');
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        _showErrorSnackbar(context, 'Erreur de vérification');
      }
    }
  }

  void _showCompactTransactionDetails(BuildContext context, dynamic data) {
    final transactionInfo = _getTransactionInfo(data['status']);
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha:0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header avec icône
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
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
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Détails',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                'Transaction',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.onSurface.withValues(alpha:0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: transactionInfo.color,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            transactionInfo.label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Divider
                    Divider(
                      color: theme.colorScheme.outline.withValues(alpha:0.1),
                    ),

                    const SizedBox(height: 16),

                    // Détails compacts
                    _buildCompactDetailRow(
                      theme,
                      Icons.receipt_long,
                      'Nom',
                      data['name'],
                    ),
                    const SizedBox(height: 12),
                    _buildCompactDetailRow(
                      theme,
                      Icons.calendar_today,
                      'Date',
                      NovaTools.dateFormat(data['billing_date']),
                    ),
                    const SizedBox(height: 12),
                    _buildCompactDetailRow(
                      theme,
                      Icons.tag,
                      'Référence',
                      data['reference'] ?? 'N/A',
                    ),
                    const SizedBox(height: 16),

                    // Divider
                    Divider(
                      color: theme.colorScheme.outline.withValues(alpha:0.1),
                    ),

                    const SizedBox(height: 16),

                    // Montant en grand
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'Montant',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurface.withValues(alpha:0.6),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currency(data['amount']),
                            style: TextStyle(
                              color: transactionInfo.color,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Bouton fermer
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Fermer',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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

  Widget _buildCompactDetailRow(
      ThemeData theme,
      IconData icon,
      String label,
      String value,
      ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.primary.withValues(alpha:0.6),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: theme.colorScheme.onSurface.withValues(alpha:0.6),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  TransactionInfo _getTransactionInfo(int status) {
    switch (status) {
      case 0:
        return const TransactionInfo(
          color: Colors.green,
          label: 'Succès',
          icon: Icons.check_circle_rounded,
        );
      case 2:
        return const TransactionInfo(
          color: Colors.amber,
          label: 'En cours',
          icon: Icons.pending_rounded,
        );
      default:
        return const TransactionInfo(
          color: Colors.red,
          label: 'Annulé',
          icon: Icons.cancel_rounded,
        );
    }
  }

  Future<void> _showCompactLoadingDialog(
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
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const LoadingIndicator(type: LoadingIndicatorType.inkDrop),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
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
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 2),
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