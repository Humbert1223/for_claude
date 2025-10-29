import 'package:flutter/material.dart';
import 'package:novacole/components/loading_indicator.dart';
import 'package:novacole/models/master_crud_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class StudentByGenderLevelBarChart extends StatefulWidget {
  const StudentByGenderLevelBarChart({super.key});

  @override
  StudentByGenderLevelBarChartState createState() =>
      StudentByGenderLevelBarChartState();
}

class StudentByGenderLevelBarChartState
    extends State<StudentByGenderLevelBarChart> {
  String selectedAge = '-1';

  // Définition des tranches d'âge
  static const List<AgeRange> ageRanges = [
    AgeRange(value: '-1', label: 'Tous', icon: Icons.groups_rounded),
    AgeRange(value: '0-5', label: '0-5 ans', icon: Icons.child_care_rounded),
    AgeRange(value: '5-10', label: '5-10 ans', icon: Icons.school_rounded),
    AgeRange(value: '10-15', label: '10-15 ans', icon: Icons.menu_book_rounded),
    AgeRange(value: '15-20', label: '15-20 ans', icon: Icons.auto_stories_rounded),
    AgeRange(value: '20-25', label: '20-25 ans', icon: Icons.psychology_rounded),
    AgeRange(value: '25-30', label: '25-30 ans', icon: Icons.work_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return FutureBuilder(
      future: MasterCrudModel.load(
        '/resume/students-by-gender-and-level',
        data: {'age': selectedAge},
      ),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: 450,
            child: Card(
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
              child: const Center(child: LoadingIndicator()),
            ),
          );
        }

        if (!snap.hasData || snap.data == null) {
          return const SizedBox.shrink();
        }

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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête
                _buildHeader(colorScheme),

                const SizedBox(height: 16),

                // Graphique
                _buildChart(snap.data!, colorScheme, isDark),

                const SizedBox(height: 24),

                // Filtres d'âge
                _buildAgeFilters(colorScheme, isDark),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha:0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.bar_chart_rounded,
            color: colorScheme.primary,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Répartition par genre",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                "Nombre d'élèves par sexe et par niveau",
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurface.withValues(alpha:0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChart(
      List<dynamic> data,
      ColorScheme colorScheme,
      bool isDark,
      ) {
    final maleColor = const Color(0xff2196f3); // Bleu
    final femaleColor = const Color(0xffec407a); // Rose/Magenta

    return SfCartesianChart(
      primaryXAxis: CategoryAxis(
        labelStyle: TextStyle(
          color: colorScheme.onSurface.withValues(alpha:0.7),
          fontSize: 11,
        ),
        majorGridLines: const MajorGridLines(width: 0),
        axisLine: AxisLine(
          color: colorScheme.outline.withValues(alpha:0.2),
        ),
      ),
      primaryYAxis: NumericAxis(
        labelStyle: TextStyle(
          color: colorScheme.onSurface.withValues(alpha:0.7),
          fontSize: 11,
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
          fontSize: 13,
        ),
        padding: 12,
        iconHeight: 12,
        iconWidth: 12,
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
      series: <CartesianSeries>[
        // Garçons
        ColumnSeries<ChartData, String>(
          dataSource: List<Map<String, dynamic>>.from(data)
              .map((e) => ChartData(e['male'], e['label']))
              .toList(),
          xValueMapper: (ChartData data, _) => data.x,
          yValueMapper: (ChartData data, _) => data.y,
          legendItemText: "Garçons",
          name: "Garçons",
          color: maleColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(6),
          ),
          dataLabelSettings: DataLabelSettings(
            isVisible: true,
            textStyle: TextStyle(
              fontSize: 11,
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        // Filles
        ColumnSeries<ChartData, String>(
          dataSource: List<Map<String, dynamic>>.from(data)
              .map((e) => ChartData(e['female'], e['label']))
              .toList(),
          xValueMapper: (ChartData data, _) => data.x,
          yValueMapper: (ChartData data, _) => data.y,
          legendItemText: "Filles",
          name: "Filles",
          color: femaleColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(6),
          ),
          dataLabelSettings: DataLabelSettings(
            isVisible: true,
            textStyle: TextStyle(
              fontSize: 11,
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAgeFilters(ColorScheme colorScheme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            "Filtrer par tranche d'âge",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface.withValues(alpha:0.7),
            ),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ageRanges.map((range) {
            final isSelected = selectedAge == range.value;

            return InkWell(
              onTap: () {
                setState(() {
                  selectedAge = range.value;
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primary
                      : (isDark
                      ? colorScheme.surfaceContainerHighest
                      : colorScheme.surfaceContainerHighest.withValues(alpha:0.5)),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.outline.withValues(alpha:0.3),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha:0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      range.icon,
                      size: 18,
                      color: isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface.withValues(alpha:0.7),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      range.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected
                            ? colorScheme.onPrimary
                            : colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class ChartData {
  final num y;
  final String x;

  ChartData(this.y, this.x);
}

class AgeRange {
  final String value;
  final String label;
  final IconData icon;

  const AgeRange({
    required this.value,
    required this.label,
    required this.icon,
  });
}