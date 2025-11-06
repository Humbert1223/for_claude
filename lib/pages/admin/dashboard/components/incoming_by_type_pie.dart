import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:novacole/models/master_crud_model.dart';
import 'package:novacole/utils/tools.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../utils/constants.dart';

class IncomingByTypePie extends StatefulWidget {
  const IncomingByTypePie({super.key});

  @override
  IncomingByTypePieState createState() => IncomingByTypePieState();
}

class IncomingByTypePieState extends State<IncomingByTypePie>
    with SingleTickerProviderStateMixin {
  bool charMode = true;
  Map<String, num>? data;
  List<Color> palette = [...colorPalette];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isLoading = true;

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

    palette.shuffle();
    _loadData();
  }

  Future<void> _loadData() async {
    final value = await MasterCrudModel.post('/resume/operations/incoming');
    if (value != null && mounted) {
      setState(() {
        data = Map<String, num>.from(value);
        _isLoading = false;
      });
      _animationController.forward();
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
                theme.colorScheme.primary.withValues(alpha:0.02),
              ],
            ),
          ),
          child: Column(
            children: [
              _buildHeader(theme, isDark),
              if (_isLoading)
                _buildLoadingState()
              else if (data != null)
                _buildContent(theme, isDark)
              else
                _buildEmptyState(),
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
            theme.colorScheme.primary.withValues(alpha:0.2),
            theme.colorScheme.primary.withValues(alpha:0.05),
          ]
              : [
            theme.colorScheme.primary.withValues(alpha:0.1),
            theme.colorScheme.primary.withValues(alpha:0.02),
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
                    color: theme.colorScheme.primary.withValues(alpha:0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.pie_chart_rounded,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Recettes par type",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                          letterSpacing: -0.5,
                          overflow: TextOverflow.ellipsis
                        ),
                      ),
                      if (data != null)
                        Text(
                          "${data!.length} catégories",
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
            isSelected: charMode,
            onTap: () => setState(() => charMode = true),
            theme: theme,
          ),
          _buildSwitchButton(
            icon: Icons.table_chart_rounded,
            isSelected: !charMode,
            onTap: () => setState(() => charMode = false),
            theme: theme,
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
  }) {
    return AnimatedContainer(
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
                  ? theme.colorScheme.primary
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
                Theme.of(context).colorScheme.primary,
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

  Widget _buildEmptyState() {
    return Container(
      height: 300,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_rounded,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.3),
          ),
          const SizedBox(height: 16),
          Text(
            "Aucune donnée disponible",
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.6),
              fontSize: 16,
              fontWeight: FontWeight.w500,
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
        child: charMode
            ? _buildChartView(theme)
            : _buildTableView(theme, isDark),
      ),
    );
  }

  Widget _buildChartView(ThemeData theme) {
    List<_PieData> pieData = [];
    data?.entries.map((entry) => pieData.add(_PieData(
      entry.key,
      entry.value,
      entry.key,
    ))).toList();

    num total = 0;
    data!.forEach((key, value) => total += value);

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
        series: <PieSeries<_PieData, String>>[
          PieSeries<_PieData, String>(
            explode: true,
            explodeIndex: 0,
            explodeOffset: '8%',
            dataSource: pieData,
            xValueMapper: (_PieData data, _) => data.text?.tr(),
            yValueMapper: (_PieData data, _) => data.yData,
            dataLabelMapper: (_PieData data, _) =>
            "${currency(data.yData)}\n${((data.yData / total) * 100).round()}%",
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
    num total = 0;
    data!.forEach((key, value) => total += value);

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
              ...data!.entries.map((e) => _buildTableRow(
                e.key.tr(),
                currency(e.value),
                theme,
                isDark,
                false,
              )),
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
            ? theme.colorScheme.primary.withValues(alpha:0.15)
            : theme.colorScheme.primary.withValues(alpha:0.08),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Type de recette",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
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
              color: theme.colorScheme.primary,
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
      bool isTotal,
      ) {
    return TableRow(
      decoration: BoxDecoration(
        color: isTotal
            ? (isDark
            ? theme.colorScheme.primary.withValues(alpha:0.1)
            : theme.colorScheme.primary.withValues(alpha:0.05))
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
          child: Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 15 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
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
                  ? theme.colorScheme.primary
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