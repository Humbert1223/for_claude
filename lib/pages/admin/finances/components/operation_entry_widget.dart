import 'package:flutter/material.dart';
import 'package:novacole/utils/tools.dart';

class OperationEntryWidget extends StatefulWidget {
  final String? title;
  final String? date;
  final num? amount;
  final num? payment;
  final bool? balanced;
  final VoidCallback? onTap;

  const OperationEntryWidget({
    super.key,
    required this.title,
    this.date,
    required this.amount,
    this.payment,
    this.balanced = false,
    this.onTap,
  });

  @override
  OperationEntryWidgetState createState() => OperationEntryWidgetState();
}

class OperationEntryWidgetState extends State<OperationEntryWidget> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final remaining = (widget.amount ?? 0) - (widget.payment ?? 0);
    final progress = widget.amount != null && widget.amount! > 0
        ? ((widget.payment ?? 0) / widget.amount!).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status indicator
            Container(
              width: 4,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: widget.balanced == true
                      ? [Colors.green, Colors.green.shade700]
                      : [Colors.orange, Colors.orange.shade700],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.title ?? 'Sans titre',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.grey[900],
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildCompactBadge(isDark),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Date
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 14,
                        color: isDark ? Colors.grey[500] : Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        NovaTools.dateFormat(widget.date),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Amounts row
                  Row(
                    children: [
                      Expanded(
                        child: _buildAmountChip(
                          'Total',
                          widget.amount ?? 0,
                          primaryColor,
                          isDark,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildAmountChip(
                          'Payé',
                          widget.payment ?? 0,
                          Colors.green,
                          isDark,
                        ),
                      ),
                      if (remaining > 0) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildAmountChip(
                            'Reste',
                            remaining,
                            Colors.orange,
                            isDark,
                            isHighlight: true,
                          ),
                        ),
                      ],
                    ],
                  ),

                  // Progress bar
                  if (widget.amount != null && widget.amount! > 0) ...[
                    const SizedBox(height: 10),
                    _buildCompactProgressBar(progress, isDark),
                  ],
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompactBadge(bool isDark) {
    final isBalanced = widget.balanced == true;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isBalanced ? Colors.green : Colors.orange,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: (isBalanced ? Colors.green : Colors.orange).withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isBalanced ? Icons.check_circle : Icons.pending,
            color: Colors.white,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            isBalanced ? 'Soldé' : 'En cours',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountChip(
      String label,
      num amount,
      Color color,
      bool isDark, {
        bool isHighlight = false,
      }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            currency(amount),
            style: TextStyle(
              fontSize: isHighlight ? 13 : 12,
              fontWeight: FontWeight.bold,
              color: isHighlight ? color : (isDark ? Colors.white : Colors.grey[900]),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCompactProgressBar(double progress, bool isDark) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progression',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey[500] : Colors.grey[600],
              ),
            ),
            Text(
              '${(progress * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: widget.balanced == true ? Colors.green : Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Container(
            height: 6,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.grey[200],
            ),
            child: Stack(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  width: MediaQuery.of(context).size.width * progress,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: widget.balanced == true
                          ? [Colors.green, Colors.green.shade600]
                          : [Colors.orange, Colors.orange.shade600],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Version ultra-compacte alternative (une seule ligne)
class CompactOperationEntryWidget extends StatelessWidget {
  final String? title;
  final String? date;
  final num? amount;
  final num? payment;
  final bool? balanced;

  const CompactOperationEntryWidget({
    super.key,
    required this.title,
    this.date,
    required this.amount,
    this.payment,
    this.balanced = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final remaining = (amount ?? 0) - (payment ?? 0);
    final progress = amount != null && amount! > 0
        ? ((payment ?? 0) / amount!).clamp(0.0, 1.0)
        : 0.0;

    return Row(
      children: [
        // Status dot
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: balanced == true ? Colors.green : Colors.orange,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: (balanced == true ? Colors.green : Colors.orange)
                    .withOpacity(0.4),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),

        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and date
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title ?? 'Sans titre',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.grey[900],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    NovaTools.dateFormat(date),
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[500] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Progress bar with amounts
              Stack(
                children: [
                  // Progress bar background
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 28,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : Colors.grey[200],
                      ),
                      child: Row(
                        children: [
                          // Progress fill
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 600),
                            width: MediaQuery.of(context).size.width * progress,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: balanced == true
                                    ? [Colors.green.withOpacity(0.3), Colors.green.withOpacity(0.15)]
                                    : [Colors.orange.withOpacity(0.3), Colors.orange.withOpacity(0.15)],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Amounts overlay
                  Container(
                    height: 28,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildInlineAmount(
                          'Payé',
                          payment ?? 0,
                          Colors.green,
                          isDark,
                        ),
                        if (remaining > 0)
                          _buildInlineAmount(
                            'Reste',
                            remaining,
                            Colors.orange,
                            isDark,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInlineAmount(String label, num amount, Color color, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey[500] : Colors.grey[600],
          ),
        ),
        Text(
          currency(amount),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

// Helper function
String currency(dynamic value) {
  if (value == null) return '0 FCFA';
  final numberFormat = value.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]} ',
  );
  return '$numberFormat F';
}