import 'package:flutter/material.dart';
import 'package:novacole/components/app_bar_back_button.dart';
import 'package:novacole/pages/admin/reports/academic_report_download_page.dart';
import 'package:novacole/pages/admin/reports/assessment_report_download_page.dart';
import 'package:novacole/pages/admin/reports/classe_report_download_page.dart';
import 'package:novacole/pages/admin/reports/level_report_download_page.dart';
import 'package:novacole/pages/admin/reports/report_assessments_filter.dart';
import 'package:novacole/pages/admin/reports/report_classe_filter.dart';
import 'package:novacole/pages/admin/reports/report_level_filter.dart';
import 'package:novacole/pages/admin/reports/school_report_download_page.dart';

class ReportTypeFilterSelector extends StatelessWidget {
  final String degree;
  final Map<String, dynamic> filters;

  const ReportTypeFilterSelector({
    super.key,
    required this.degree,
    required this.filters,
  });

  String _getDegreeName(String degree) {
    if (degree == 'high_school') return 'Lycée';
    if (degree == 'college') return 'Collège';
    if (degree == 'primary') return 'Primaire';
    return degree;
  }

  Color _getDegreeColor(String degree) {
    if (degree == 'high_school') return Colors.purple;
    if (degree == 'college') return Colors.indigo;
    if (degree == 'primary') return Colors.orange;
    return Colors.blue;
  }

  IconData _getDegreeIcon(String degree) {
    if (degree == 'high_school') return Icons.science_rounded;
    if (degree == 'college') return Icons.menu_book_rounded;
    if (degree == 'primary') return Icons.child_care_rounded;
    return Icons.school_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final degreeColor = _getDegreeColor(degree);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      appBar: _buildAppBar(theme, context),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header section
          _buildHeader(theme, isDark, degreeColor),
          const SizedBox(height: 24),

          // Cards de types de rapports
          _buildReportTypeCard(
            context: context,
            theme: theme,
            isDark: isDark,
            icon: Icons.assessment_rounded,
            title: "Rapports d'évaluation",
            subtitle: 'Notes et résultats par évaluation',
            color: Colors.blue,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ReportClasseFilterSelector(
                    title: "Rapports d'évaluation",
                    degree: degree,
                    filters: {'degree': degree, ...filters},
                    onSelect: (filters, classe) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return ReportAssessmentFilterSelector(
                              title: "Rapports d'évaluation",
                              classeId: filters['classe_id'],
                              filters: filters,
                              onSelect: (filters, assessment) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return AssessmentReportDownloadPage(
                                        filters: filters,
                                        assessment: assessment,
                                      );
                                    },
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          _buildReportTypeCard(
            context: context,
            theme: theme,
            isDark: isDark,
            icon: Icons.class_rounded,
            title: 'Rapports de classe',
            subtitle: 'Statistiques et résultats par classe',
            color: Colors.teal,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ReportClasseFilterSelector(
                    degree: degree,
                    filters: {'degree': degree, ...filters},
                    onSelect: (filters, classe) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return ClasseReportDownloadPage(
                              filters: filters,
                              classe: classe,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          _buildReportTypeCard(
            context: context,
            theme: theme,
            isDark: isDark,
            icon: Icons.layers_rounded,
            title: 'Rapports de niveau',
            subtitle: 'Vue d\'ensemble par niveau scolaire',
            color: Colors.deepPurple,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ReportLevelFilterSelector(
                    degree: degree,
                    filters: {'degree': degree, ...filters},
                    onSelect: (filters, level) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return LevelReportDownloadPage(
                              title: "Rapports de niveau",
                              filters: filters,
                              level: level,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          _buildReportTypeCard(
            context: context,
            theme: theme,
            isDark: isDark,
            icon: Icons.calendar_today_rounded,
            title: "Rapports de l'année scolaire",
            subtitle: 'Bilan annuel et statistiques globales',
            color: Colors.amber.shade700,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return AcademicReportDownloadPage(
                      filters: filters,
                    );
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          _buildReportTypeCard(
            context: context,
            theme: theme,
            isDark: isDark,
            icon: Icons.account_balance_rounded,
            title: "Rapport de l'établissement",
            subtitle: 'Vue complète de l\'établissement',
            color: Colors.cyan.shade700,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return SchoolReportDownloadPage(
                      filters: filters,
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
      ThemeData theme,
      BuildContext context,
      ) {
    return AppBar(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withValues(alpha: 0.85),
            ],
          ),
        ),
      ),
      leading: AppBarBackButton(),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getDegreeIcon(degree),
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Rapports & États',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _getDegreeName(degree),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, bool isDark, Color degreeColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            degreeColor.withValues(alpha: 0.15),
            degreeColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: degreeColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  degreeColor,
                  degreeColor.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: degreeColor.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              _getDegreeIcon(degree),
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getDegreeName(degree),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: degreeColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Choisissez le type de rapport',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportTypeCard({
    required BuildContext context,
    required ThemeData theme,
    required bool isDark,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 300),
      tween: Tween<double>(begin: 0, end: 1),
      curve: Curves.easeOutCubic,
      builder: (context, double value, child) {
        return Transform.scale(
          scale: 0.95 + (0.05 * value),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
              const Color(0xFF1E1E1E),
              const Color(0xFF1A1A1A),
            ]
                : [
              Colors.white,
              Colors.grey.shade50,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.06),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
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

                  // Texte
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isDark ? Colors.white : Colors.black87,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.6)
                                : Colors.black.withValues(alpha: 0.5),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Flèche
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: color,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}