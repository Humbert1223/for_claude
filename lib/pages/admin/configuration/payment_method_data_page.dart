import 'package:flutter/material.dart';
import 'package:novacole/components/data_models/default_data_grid.dart';
import 'package:novacole/models/user_model.dart';

class PaymentMethodDataPage extends StatefulWidget {
  const PaymentMethodDataPage({super.key});

  @override
  PaymentMethodDataPageState createState() {
    return PaymentMethodDataPageState();
  }
}

class PaymentMethodDataPageState extends State<PaymentMethodDataPage> {
  UserModel? user;

  @override
  void initState() {
    UserModel.fromLocalStorage().then(
      (value) {
        setState(() {
          user = value;
        });
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return user != null
        ? DefaultDataGrid(
            itemBuilder: (method) {
              return ModernPaymentMethodItemWidget(methodData: method);
            },
            dataModel: 'payment_method',
            paginate: PaginationValue.none,
            title: 'Moyens de paiement',
          )
        : Container();
  }

}
class ModernPaymentMethodItemWidget extends StatelessWidget {
  final Map<String, dynamic> methodData;

  const ModernPaymentMethodItemWidget({
    super.key,
    required this.methodData,
  });

  IconData _getPaymentIcon(String? name) {
    if (name == null) return Icons.payment_rounded;

    final lowerName = name.toLowerCase();
    if (lowerName.contains('mobile') || lowerName.contains('momo')) {
      return Icons.phone_android_rounded;
    } else if (lowerName.contains('bank') || lowerName.contains('banque')) {
      return Icons.account_balance_rounded;
    } else if (lowerName.contains('card') || lowerName.contains('carte')) {
      return Icons.credit_card_rounded;
    } else if (lowerName.contains('cash') || lowerName.contains('espèce')) {
      return Icons.money_rounded;
    } else if (lowerName.contains('paypal')) {
      return Icons.paypal_rounded;
    }
    return Icons.payment_rounded;
  }

  Color _getPaymentColor(String? name) {
    if (name == null) return Colors.blue;

    final lowerName = name.toLowerCase();
    if (lowerName.contains('mobile') || lowerName.contains('momo')) {
      return Colors.orange;
    } else if (lowerName.contains('bank') || lowerName.contains('banque')) {
      return Colors.indigo;
    } else if (lowerName.contains('card') || lowerName.contains('carte')) {
      return Colors.purple;
    } else if (lowerName.contains('cash') || lowerName.contains('espèce')) {
      return Colors.green;
    } else if (lowerName.contains('paypal')) {
      return Colors.blue.shade700;
    }
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final name = methodData['name']?.toString() ?? 'Sans nom';
    final type = methodData['type']?.toString() ?? '';
    final accountNumber = methodData['account_number']?.toString() ?? 'N/A';

    final icon = _getPaymentIcon(type);
    final color = _getPaymentColor(type);

    return Row(
      children: [
        // Icône avec gradient
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color,
                color.withValues(alpha: 0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),

        // Informations de la méthode de paiement
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nom de la méthode
              Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: isDark ? Colors.white : Colors.black87,
                  letterSpacing: -0.3,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Numéro de compte avec icône
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.numbers_rounded,
                      size: 14,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      accountNumber,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.7)
                            : Colors.black.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w500,
                        fontFamily: 'monospace',
                        letterSpacing: 0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Badge ou indicateur visuel
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Icon(
            Icons.chevron_right_rounded,
            color: color,
            size: 20,
          ),
        ),
      ],
    );
  }
}
