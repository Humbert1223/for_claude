import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:novacole/models/master_crud_model.dart';
import 'package:novacole/utils/tools.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../utils/constants.dart';


class OverduePaymentByAcademicPie extends StatefulWidget {
  const OverduePaymentByAcademicPie({super.key});

  @override
  OverduePaymentByAcademicPieState createState() =>
      OverduePaymentByAcademicPieState();
}

class OverduePaymentByAcademicPieState extends State<OverduePaymentByAcademicPie>
    with SingleTickerProviderStateMixin {
  bool isChartMode = true;
  bool isLoading = true;
  Map<String, num>? data;
  late List<Color> palette;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Animation setup
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    palette = [...colorPalette];
    palette.shuffle();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final value = await MasterCrudModel.post('/resume/payments/overdue');
      if (mounted && value != null) {
        setState(() {
          data = Map<String, num>.from(value);
          isLoading = false;
        });
        _animationController.forward();
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha:0.1)
                : Colors.black.withValues(alpha:0.05),
            width: 1,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                theme.colorScheme.surface,
                theme.colorScheme.surface.withValues(alpha:0.8),
              ]
                  : [
                Colors.white,
                Colors.green.withValues(alpha:0.02),
              ],
            ),
          ),
          child: Column(
            children: [
              _buildHeader(theme, isDark),
              if (isLoading)
                _buildLoadingState()
              else if (data != null && data!.isNotEmpty)
                _buildContent(theme, isDark)
              else
                _buildEmptyState(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        gradient: LinearGradient(
          colors: isDark
              ? [
            Colors.green.withValues(alpha:0.2),
            Colors.green.withValues(alpha:0.05),
          ]
              : [
            Colors.green.withValues(alpha:0.1),
            Colors.green.withValues(alpha:0.02),
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha:0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.payments_rounded,
                    color: Colors.green.shade700,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Paiements encaissés",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                          letterSpacing: -0.5,
                          overflow: TextOverflow.ellipsis
                        ),
                      ),
                      Text(
                        data != null
                            ? "${data!.length} années scolaires"
                            : "Répartition par année",
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withValues(alpha:0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildModernSwitch(theme),
        ],
      ),
    );
  }

  Widget _buildModernSwitch(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildSwitchButton(
            icon: Icons.pie_chart_rounded,
            isSelected: isChartMode,
            onTap: () => setState(() => isChartMode = true),
            theme: theme,
            tooltip: 'Vue graphique',
          ),
          _buildSwitchButton(
            icon: Icons.table_chart_rounded,
            isSelected: !isChartMode,
            onTap: () => setState(() => isChartMode = false),
            theme: theme,
            tooltip: 'Vue tableau',
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchButton({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required ThemeData theme,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(30),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.green.shade700
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? Colors.white
                    : theme.colorScheme.onSurface.withValues(alpha:0.5),
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 300,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.green.shade700,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Chargement des données...",
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.6),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Container(
      height: 300,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.payments_rounded,
            size: 64,
            color: theme.colorScheme.onSurface.withValues(alpha:0.3),
          ),
          const SizedBox(height: 16),
          Text(
            "Aucune donnée disponible",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface.withValues(alpha:0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Les paiements encaissés apparaîtront ici",
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onSurface.withValues(alpha:0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme, bool isDark) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.95, end: 1.0).animate(animation),
              child: child,
            ),
          );
        },
        child: isChartMode
            ? _buildChartView(theme, isDark)
            : _buildTableView(theme, isDark),
      ),
    );
  }

  Widget _buildChartView(ThemeData theme, bool isDark) {
    final pieData = data!.entries
        .map((entry) => _PieData(entry.key, entry.value, entry.key))
        .toList();

    final total = data!.values.reduce((a, b) => a + b);

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SfCircularChart(
        palette: palette,
        legend: Legend(
          isVisible: true,
          orientation: LegendItemOrientation.horizontal,
          position: LegendPosition.bottom,
          overflowMode: LegendItemOverflowMode.wrap,
          textStyle: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        tooltipBehavior: TooltipBehavior(
          enable: true,
          color: isDark ? theme.colorScheme.primaryContainer : Colors.white,
          textStyle: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          borderColor: theme.colorScheme.outline.withValues(alpha:0.3),
          borderWidth: 1,
        ),
        series: <PieSeries<_PieData, String>>[
          PieSeries<_PieData, String>(
            explode: true,
            explodeIndex: 0,
            explodeOffset: '8%',
            dataSource: pieData,
            xValueMapper: (_PieData data, _) => data.text?.tr(),
            yValueMapper: (_PieData data, _) => data.yData,
            dataLabelMapper: (_PieData data, _) {
              final percentage = ((data.yData / total) * 100).round();
              return "${currency(data.yData)}\n$percentage%";
            },
            dataLabelSettings: DataLabelSettings(
              isVisible: true,
              labelPosition: ChartDataLabelPosition.outside,
              connectorLineSettings: ConnectorLineSettings(
                type: ConnectorType.curve,
                color: theme.colorScheme.onSurface.withValues(alpha:0.3),
              ),
              textStyle: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            strokeColor: theme.colorScheme.surface,
            strokeWidth: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildTableView(ThemeData theme, bool isDark) {
    final total = data!.values.reduce((a, b) => a + b);

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha:0.1)
                : Colors.black.withValues(alpha:0.08),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(1),
            },
            children: [
              _buildTableHeader(theme, isDark),
              ...data!.entries.toList().asMap().entries.map((entry) {
                final index = entry.key;
                final dataEntry = entry.value;
                final color = palette[index % palette.length];

                return _buildTableRow(
                  dataEntry.key.tr(),
                  currency(dataEntry.value),
                  theme,
                  isDark,
                  false,
                  color: color,
                );
              }),
              _buildTableRow(
                "TOTAL",
                currency(total),
                theme,
                isDark,
                true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  TableRow _buildTableHeader(ThemeData theme, bool isDark) {
    return TableRow(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.green.withValues(alpha:0.15)
            : Colors.green.withValues(alpha:0.08),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Année scolaire",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Montant",
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  TableRow _buildTableRow(
      String label,
      String value,
      ThemeData theme,
      bool isDark,
      bool isTotal, {
        Color? color,
      }) {
    return TableRow(
      decoration: BoxDecoration(
        color: isTotal
            ? (isDark
            ? Colors.green.withValues(alpha:0.1)
            : Colors.green.withValues(alpha:0.05))
            : null,
        border: !isTotal
            ? Border(
          bottom: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha:0.05)
                : Colors.black.withValues(alpha:0.05),
          ),
        )
            : null,
      ),
      children: [
        Padding(
          padding: EdgeInsets.all(isTotal ? 16.0 : 14.0),
          child: Row(
            children: [
              if (color != null) ...[
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: isTotal ? 15 : 14,
                    fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.all(isTotal ? 16.0 : 14.0),
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: isTotal ? 15 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: isTotal
                  ? Colors.green.shade700
                  : theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

class _PieData {
  final String xData;
  final num yData;
  String? text;

  _PieData(this.xData, this.yData, [this.text]);
}