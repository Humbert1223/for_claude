import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:novacole/components/loading_indicator.dart';
import 'package:novacole/models/master_crud_model.dart';
import 'package:novacole/utils/tools.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class WeeklyCashTrend extends StatefulWidget {
  const WeeklyCashTrend({super.key});

  @override
  WeeklyCashTrendState createState() => WeeklyCashTrendState();
}

class WeeklyCashTrendState extends State<WeeklyCashTrend> {
  Map<String, dynamic>? data;
  bool isChartMode = true;
  bool isLoading = true;

  static const List<Color> chartColors = [
    Color(0xff2196f3), // Bleu
    Color(0xffff5722), // Orange
    Color(0xfff44336), // Rouge
    Color(0xffffc107), // Amber
    Color(0xff4caf50), // Vert
    Color(0xff9c27b0), // Violet
    Color(0xff795548), // Marron
    Color(0xff673ab7), // Indigo
    Color(0xff00bcd4), // Cyan
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final value = await MasterCrudModel.post('/resume/operations/weekly/by-category');
      if (mounted && value != null) {
        setState(() {
          data = value;
          isLoading = false;
        });
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark
              ? colorScheme.outline.withValues(alpha:0.2)
              : colorScheme.outline.withValues(alpha:0.15),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // En-tête moderne
          _buildHeader(colorScheme, isDark),

          // Contenu
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 100),
              child: LoadingIndicator(),
            )
          else if (data != null)
            isChartMode
                ? _buildChart(colorScheme, isDark)
                : _buildTable(colorScheme, isDark)
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Icône et titre
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.trending_up_rounded,
                    color: colorScheme.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Flux réel de la semaine",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Toggle moderne entre graphique et tableau
          Container(
            decoration: BoxDecoration(
              color: isDark
                  ? colorScheme.surfaceContainerHighest
                  : colorScheme.surfaceContainerHighest.withValues(alpha:0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha:0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                _buildToggleButton(
                  icon: Icons.show_chart_rounded,
                  isSelected: isChartMode,
                  onTap: () => setState(() => isChartMode = true),
                  colorScheme: colorScheme,
                  isDark: isDark,
                  tooltip: 'Vue graphique',
                ),
                _buildToggleButton(
                  icon: Icons.table_chart_rounded,
                  isSelected: !isChartMode,
                  onTap: () => setState(() => isChartMode = false),
                  colorScheme: colorScheme,
                  isDark: isDark,
                  tooltip: 'Vue tableau',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
    required bool isDark,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primary.withValues(alpha:isDark ? 0.2 : 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isSelected
                ? colorScheme.primary
                : colorScheme.onSurface.withValues(alpha:0.6),
          ),
        ),
      ),
    );
  }

  Widget _buildChart(ColorScheme colorScheme, bool isDark) {
    final series = _buildChartSeries(colorScheme, isDark);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 8, right: 8),
      child: SfCartesianChart(
        primaryXAxis: CategoryAxis(
          labelStyle: TextStyle(
            color: colorScheme.onSurface.withValues(alpha:0.7),
            fontSize: 12,
          ),
          majorGridLines: const MajorGridLines(width: 0),
          axisLine: AxisLine(
            color: colorScheme.outline.withValues(alpha:0.2),
          ),
        ),
        primaryYAxis: NumericAxis(
          numberFormat: NumberFormat.simpleCurrency(
            decimalDigits: 0,
            locale: 'fr',
            name: 'F',
          ),
          labelStyle: TextStyle(
            color: colorScheme.onSurface.withValues(alpha:0.7),
            fontSize: 12,
          ),
          majorGridLines: MajorGridLines(
            color: colorScheme.outline.withValues(alpha:0.1),
            width: 1,
          ),
          axisLine: AxisLine(
            color: colorScheme.outline.withValues(alpha:0.2),
          ),
        ),
        legend: Legend(
          isVisible: true,
          position: LegendPosition.bottom,
          textStyle: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 12,
          ),
          overflowMode: LegendItemOverflowMode.wrap,
          padding: 8,
        ),
        tooltipBehavior: TooltipBehavior(
          enable: true,
          color: isDark ? colorScheme.primaryContainer : Colors.white,
          textStyle: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 12,
          ),
          borderColor: colorScheme.outline.withValues(alpha:0.3),
          borderWidth: 1,
        ),
        series: series,
      ),
    );
  }

  List<CartesianSeries> _buildChartSeries(ColorScheme colorScheme, bool isDark) {
    return List<Map<String, dynamic>>.from(data?['series'] ?? [])
        .asMap()
        .entries
        .map<CartesianSeries>((entry) {
      final index = entry.key;
      final element = entry.value;
      final color = chartColors[index % chartColors.length];

      return SplineSeries<ChartData, String>(
        splineType: SplineType.cardinal,
        cardinalSplineTension: 0.9,
        dataSource: List<Map<String, dynamic>>.from(element['trend'])
            .map((e) => ChartData(e['amount'], e['day_name']))
            .toList(),
        xValueMapper: (ChartData data, _) => data.x,
        yValueMapper: (ChartData data, _) => data.y,
        legendItemText: element['name'].toString().tr(),
        color: color,
        width: 2.5,
        markerSettings: MarkerSettings(
          isVisible: true,
          height: 8,
          width: 8,
          color: color,
          borderColor: isDark ? colorScheme.surface : Colors.white,
          borderWidth: 2,
        ),
        dataLabelSettings: DataLabelSettings(
          isVisible: true,
          alignment: ChartAlignment.near,
          labelAlignment: ChartDataLabelAlignment.top,
          textStyle: TextStyle(
            fontSize: 10,
            color: colorScheme.onSurface.withValues(alpha:0.8),
            fontWeight: FontWeight.w500,
          ),
          builder: (data, point, series, pointIndex, seriesIndex) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: (isDark ? colorScheme.primaryContainer : Colors.white)
                    .withValues(alpha:0.9),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: color.withValues(alpha:0.3),
                  width: 1,
                ),
              ),
              child: Text(
                NumberFormat.compact(locale: 'fr').format(data.y),
                style: TextStyle(
                  fontSize: 9,
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          },
        ),
      );
    }).toList();
  }

  Widget _buildTable(ColorScheme colorScheme, bool isDark) {
    final tableData = List<Map<String, dynamic>>.from(data!['series'] ?? []);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha:0.3),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Table(
            border: TableBorder(
              horizontalInside: BorderSide(
                color: colorScheme.outline.withValues(alpha:0.2),
                width: 1,
              ),
              verticalInside: BorderSide(
                color: colorScheme.outline.withValues(alpha:0.2),
                width: 1,
              ),
            ),
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(1),
            },
            children: [
              // En-tête
              TableRow(
                decoration: BoxDecoration(
                  color: isDark
                      ? colorScheme.surfaceContainerHighest
                      : colorScheme.primary.withValues(alpha:0.08),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      "Type d'opération",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      "Montant",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
              // Données
              ...tableData.asMap().entries.map((entry) {
                final index = entry.key;
                final element = entry.value;
                final value = List.from(element['trend'])
                    .map((el) => el['amount'])
                    .reduce((a, b) => a + b);
                final color = chartColors[index % chartColors.length];

                return TableRow(
                  decoration: BoxDecoration(
                    color: (index % 2 == 0)
                        ? (isDark
                        ? colorScheme.surface
                        : Colors.transparent)
                        : (isDark
                        ? colorScheme.primaryContainer.withValues(alpha:0.3)
                        : colorScheme.surfaceContainerHighest.withValues(alpha:0.3)),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              element['name'].toString().tr(),
                              style: TextStyle(
                                fontSize: 13,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        currency(value),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class ChartData {
  final num y;
  final String x;

  ChartData(this.y, this.x);
}