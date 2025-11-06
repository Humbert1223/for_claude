
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:novacole/controllers/auth_provider.dart';
import 'package:novacole/models/master_crud_model.dart';
import 'package:novacole/models/user_model.dart';
import 'package:novacole/pages/auth/wallet/transaction_history_page.dart';
import 'package:novacole/pages/auth/wallet/wallet_payment_form_page.dart';
import 'package:novacole/pages/components/school_details_info_page.dart';
import 'package:novacole/utils/tools.dart';

class SchoolUserWallet extends StatefulWidget {
  const SchoolUserWallet({super.key});

  @override
  SchoolUserWalletState createState() => SchoolUserWalletState();
}

class SchoolUserWalletState extends State<SchoolUserWallet> {
  Map<String, dynamic>? school;
  UserModel? user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final data = await authProvider.fromServer();
      if (data != null && mounted) {
        setState(() => user = UserModel.fromMap(data));
        final schoolData = authProvider.currentSchool;
        if (mounted) {
          setState(() => school = schoolData);
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool get _canAccessWallet {
    return (user != null &&
        school != null &&
        user?.school != null &&
        school!['created_by'] == user?.id) ||
        user?.accountType == 'admin';
  }

  @override
  Widget build(BuildContext context) {
    return SchoolDetailsInfoPage(
      title: 'Portefeuille',
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : school != null && user != null
          ? RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              _buildCompactBalanceCard(context),
              const SizedBox(height: 12),
              _buildCompactTransactionHistory(context),
            ],
          ),
        ),
      )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildCompactBalanceCard(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha:0.85),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha:0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Motif décoratif
          Positioned(
            right: -40,
            top: -40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha:0.05),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.account_balance_wallet_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Soldes',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha:0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _loadData,
                          icon: Icon(
                            Icons.refresh_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Soldes
                Row(
                  children: [
                    if (_canAccessWallet)
                      Expanded(
                        child: _buildCompactBalance(
                          icon: Icons.account_balance_wallet,
                          label: 'École',
                          amount: school!['wallet'] ?? 0,
                        ),
                      ),
                    if (_canAccessWallet) const SizedBox(width: 10),
                    Expanded(
                      child: _buildCompactBalance(
                        icon: Icons.sms,
                        label: 'SMS',
                        amount: user!.smsWallet ?? 0,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Boutons d'action
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _showPaymentTypeDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: theme.colorScheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.add_circle_outline, size: 18),
                        label: const Text(
                          'Déposer',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _navigateToFullHistory,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha:0.2),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Icon(Icons.history, size: 18),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactBalance({
    required IconData icon,
    required String label,
    required num amount,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha:0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha:0.8),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            currency(amount),
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactTransactionHistory(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha:0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.receipt_long_rounded,
                      color: theme.colorScheme.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Transactions',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: _navigateToFullHistory,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Tout',
                        style: TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 2),
                      Icon(Icons.arrow_forward_rounded, size: 14),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: theme.colorScheme.outline.withValues(alpha:0.1)),
          FutureBuilder(
            future: _fetchTransactions(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 40,
                          color: Colors.red.withValues(alpha:0.5),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Erreur',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface.withValues(alpha:0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (snapshot.hasData && List.from(snapshot.data!).isNotEmpty) {
                final transactions = List.from(snapshot.data!);
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(10),
                  itemCount: transactions.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 16,
                    color: theme.colorScheme.outline.withValues(alpha:0.1),
                  ),
                  itemBuilder: (context, index) {
                    return _buildCompactTransactionCard(
                      context,
                      transactions[index],
                    );
                  },
                );
              }

              return Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 40,
                        color: theme.colorScheme.onSurface.withValues(alpha:0.3),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Aucune transaction',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withValues(alpha:0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCompactTransactionCard(BuildContext context, dynamic data) {
    final transactionInfo = _getTransactionInfo(data['status']);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: transactionInfo.color.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              transactionInfo.icon,
              color: transactionInfo.color,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['name'],
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ).tr(),
                const SizedBox(height: 2),
                Text(
                  NovaTools.dateFormat(data['billing_date']),
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.colorScheme.onSurface.withValues(alpha:0.5),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                currency(data['amount']),
                style: TextStyle(
                  color: transactionInfo.color,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
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
        ],
      ),
    );
  }

  TransactionInfo _getTransactionInfo(int status) {
    switch (status) {
      case 0:
        return TransactionInfo(
          color: Colors.green,
          label: 'Succès',
          icon: Icons.check_circle_rounded,
        );
      case 2:
        return TransactionInfo(
          color: Colors.amber,
          label: 'En cours',
          icon: Icons.pending_rounded,
        );
      default:
        return TransactionInfo(
          color: Colors.red,
          label: 'Annulé',
          icon: Icons.cancel_rounded,
        );
    }
  }

  Future<dynamic> _fetchTransactions() {
    return MasterCrudModel('billing').search(
      paginate: '0',
      filters: [
        {'field': 'school_id', 'value': school!['id']},
        {'field': 'created_by', 'value': user?.id},
      ],
      query: {'limit': 5},
    );
  }

  Future<void> _showPaymentTypeDialog() async {
    final billingType = await showDialog<String>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha:0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.payment_rounded,
                    color: theme.colorScheme.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Type de paiement',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                if (_canAccessWallet)
                  _buildCompactPaymentOption(
                    context,
                    icon: Icons.account_balance_wallet_rounded,
                    title: "Dépôt d'argent",
                    subtitle: "Portefeuille école",
                    color: theme.colorScheme.primary,
                    onTap: () => Navigator.of(context).pop('wallet'),
                  ),
                if (_canAccessWallet) const SizedBox(height: 10),
                _buildCompactPaymentOption(
                  context,
                  icon: Icons.sms_rounded,
                  title: "Crédit SMS",
                  subtitle: "Recharger SMS",
                  color: theme.colorScheme.secondary,
                  onTap: () => Navigator.of(context).pop('sms_wallet'),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (billingType != null && mounted) {
      final success = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (context) => WalletPaymentFormPage(
            billingType: billingType,
          ),
        ),
      );

      if (success == true && mounted) {
        _loadData();
      }
    }
  }

  Widget _buildCompactPaymentOption(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required Color color,
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha:0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha:0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha:0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha:0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: color.withValues(alpha:0.5),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToFullHistory() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TransactionHistoryPage(
          school: school,
          user: user,
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