import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:novacole/components/empty_page.dart';
import 'package:novacole/components/tag_widget.dart';
import 'package:novacole/controllers/auth_controller.dart';
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
  final authController = Get.find<AuthController>();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final data = await authController.fromServer();
      if (data != null && mounted) {
        setState(() => user = UserModel.fromMap(data));
        final schoolData = await authController.getSchool();
        if (schoolData != null && mounted) {
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
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildBalanceCard(context),
                    const SizedBox(height: 16),
                    _buildTransactionHistory(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildBalanceCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary,
              colorScheme.primary.withValues(alpha:0.8),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'SOLDE DISPONIBLE',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha:0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.2,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: _loadData,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_canAccessWallet) ...[
                _buildBalanceItem(
                  context,
                  icon: Icons.account_balance_wallet,
                  label: 'Portefeuille école',
                  amount: school!['wallet'] ?? 0,
                ),
                const SizedBox(height: 16),
              ],
              _buildBalanceItem(
                context,
                icon: Icons.sms,
                label: 'Crédit SMS',
                amount: user!.smsWallet ?? 0,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _showPaymentTypeDialog,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.white,
                    foregroundColor: colorScheme.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_circle_outline, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        'Faire un dépôt',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceItem(
      BuildContext context, {
        required IconData icon,
        required String label,
        required num amount,
      }) {
    final isPositive = amount > 0;
    final color = isPositive ? Colors.greenAccent : Colors.redAccent;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha:0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha:0.8),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  currency(amount),
                  style: TextStyle(
                    color: color,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionHistory(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.history,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Historique',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => _navigateToFullHistory(),
                  child: Row(
                    children: [
                      Text('Voir tout'),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward, size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          SizedBox(
            height: 400,
            child: FutureBuilder(
              future: _fetchTransactions(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Erreur de chargement'),
                      ],
                    ),
                  );
                }

                if (snapshot.hasData && List.from(snapshot.data!).isNotEmpty) {
                  final transactions = List.from(snapshot.data!);
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: transactions.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      return _buildTransactionCard(
                        context,
                        transactions[index],
                      );
                    },
                  );
                }

                return Center(
                  child: EmptyPage(
                    sub: const Text('Aucune transaction'),
                    icon: const Icon(Icons.receipt_long_outlined, size: 64),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(BuildContext context, dynamic data) {
    final transactionInfo = _getTransactionInfo(data['status']);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: transactionInfo.color.withValues(alpha:0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          transactionInfo.icon,
          color: transactionInfo.color,
          size: 24,
        ),
      ),
      title: Text(
        data['name'],
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ).tr(),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              NovaTools.dateFormat(data['billing_date']),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            Text(
              'Ref: ${data['reference'] ?? '-'}',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            currency(data['amount']),
            style: TextStyle(
              color: transactionInfo.color,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          TagWidget(
            title: Text(
              transactionInfo.label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            color: transactionInfo.color,
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
          icon: Icons.check_circle,
        );
      case 2:
        return TransactionInfo(
          color: Colors.amber,
          label: 'En cours',
          icon: Icons.pending,
        );
      default:
        return TransactionInfo(
          color: Colors.red,
          label: 'Annulé',
          icon: Icons.cancel,
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
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.payment,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              const Text('Type de paiement'),
            ],
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_canAccessWallet)
                _buildPaymentOption(
                  context,
                  icon: Icons.account_balance_wallet,
                  title: "Dépôt d'argent",
                  subtitle: "Recharger le portefeuille école",
                  onTap: () => Navigator.of(context).pop('wallet'),
                ),
              _buildPaymentOption(
                context,
                icon: Icons.sms,
                title: "Achat de crédit SMS",
                subtitle: "Recharger vos crédits SMS",
                onTap: () => Navigator.of(context).pop('sms_wallet'),
              ),
            ],
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

  Widget _buildPaymentOption(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
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