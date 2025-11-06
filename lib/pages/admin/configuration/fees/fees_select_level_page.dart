import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:novacole/components/data_models/default_data_grid.dart';
import 'package:novacole/models/master_crud_model.dart';
import 'package:novacole/models/user_model.dart';
import 'package:novacole/pages/admin/configuration/fees/fees_config_form.dart';
import 'package:novacole/utils/constants.dart';

class FeesSelectLevelPage extends StatefulWidget {
  const FeesSelectLevelPage({super.key});

  @override
  State<FeesSelectLevelPage> createState() => _FeesSelectLevelPageState();
}

class _FeesSelectLevelPageState extends State<FeesSelectLevelPage> {
  List<Map<String, dynamic>> _tuitions = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    // Nettoyage des ressources si nécessaire
    super.dispose();
  }

  void _navigateToConfig(
    BuildContext context,
    Map<String, dynamic> data,
    List<Map<String, dynamic>> tuitions,
    Map<String, dynamic>? serie,
  ) {
    if (data['degree'] == 'high_school') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => FeesConfigForm(
            level: data,
            serie: serie,
            tuition: tuitions
                .where(
                  (t) =>
                      t['level_id'] == data['id'] && serie != null &&
                      t['serie_id'] == serie['id'],
                )
                .firstOrNull,
          ),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => FeesConfigForm(
            level: data,
            tuition: tuitions
                .where((t) => t['level_id'] == data['id'])
                .firstOrNull,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultDataGrid(
      itemBuilder: (data) {
        final tuitions = _tuitions
            .where((t) => t['level_id'] == data['id'])
            .toList();
        return ModernFeesLevelItemWidget(
          tuitions: tuitions,
          levelData: data,
          onTap: (serie) => _navigateToConfig(context, data, tuitions, serie),
        );
      },
      dataModel: Entity.level,
      paginate: PaginationValue.none,
      optionVisible: false,
      canAdd: false,
      canDelete: (data) => false,
      canEdit: (data) => false,
      title: "Sélectionner un niveau",
    );
  }

  Future<void> _loadData() async {
    UserModel? user = await UserModel.fromLocalStorage();
    if (user == null) return;

    try {
      List? response = await MasterCrudModel(Entity.tuition).search(
        paginate: '0',
        data: {
          "relations": ['serie'],
        },
        filters: [
          {'field': 'academic_id', 'operator': '=', 'value': user.academic},
        ],
      );

      if (response != null && response.isNotEmpty) {
        setState(() {
          _tuitions = response
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        });
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement des frais: $e');
    }
  }
}

class ModernFeesLevelItemWidget extends StatefulWidget {
  final Map<String, dynamic> levelData;
  final List<Map<String, dynamic>> tuitions;
  final Function(Map<String, dynamic>?) onTap;

  const ModernFeesLevelItemWidget({
    super.key,
    required this.levelData,
    required this.onTap,
    required this.tuitions,
  });

  @override
  State<ModernFeesLevelItemWidget> createState() =>
      _ModernFeesLevelItemWidgetState();
}

class _ModernFeesLevelItemWidgetState extends State<ModernFeesLevelItemWidget> {
  bool _isExpanded = false;
  UserModel? user;
  final NumberFormat _currencyFormat = NumberFormat('#,###', 'fr_FR');

  @override
  void initState() {
    super.initState();
  }

  IconData _getLevelIcon(String? degree) {
    if (degree == null) return Icons.school_rounded;

    if (degree == 'high_school') {
      return Icons.science_rounded;
    } else if (degree == 'college') {
      return Icons.menu_book_rounded;
    } else if (degree == 'primary') {
      return Icons.child_care_rounded;
    }
    return Icons.school_rounded;
  }

  Color _getLevelColor(String? degree) {
    if (degree == null) return Colors.blue;

    if (degree == 'high_school') {
      return Colors.purple;
    } else if (degree == 'college') {
      return Colors.indigo;
    } else if (degree == 'primary') {
      return Colors.orange;
    }
    return Colors.blue;
  }

  String _getDegreeName(String? degree) {
    if (degree == null) return '';

    if (degree == 'high_school') {
      return 'Lycée';
    } else if (degree == 'college') {
      return 'Collège';
    } else if (degree == 'primary') {
      return 'Primaire';
    }
    return degree;
  }

  String _formatAmount(dynamic amount) {
    if (amount == null) return '0';
    final value = amount is int ? amount : int.tryParse(amount.toString()) ?? 0;
    return _currencyFormat.format(value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final name = widget.levelData['name']?.toString() ?? 'Sans nom';
    final degree = widget.levelData['degree']?.toString();

    final icon = _getLevelIcon(degree);
    final color = _getLevelColor(degree);
    final degreeName = _getDegreeName(degree);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1E1E1E), const Color(0xFF1A1A1A)]
              : [Colors.white, Colors.grey.shade50],
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
      child: Column(
        children: [
          // En-tête cliquable
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                if (widget.tuitions.isEmpty) {
                  widget.onTap(null);
                } else {
                  setState(() => _isExpanded = !_isExpanded);
                }
              },
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(16),
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
                          colors: [color, color.withValues(alpha: 0.7)],
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
                      child: Icon(icon, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),

                    // Informations du niveau
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nom du niveau
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
                          const SizedBox(height: 6),

                          // Type (Lycée, Collège, etc.)
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.category_rounded,
                                  size: 14,
                                  color: color,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                degreeName,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: color,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${widget.tuitions.length}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Indicateur
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        widget.tuitions.isEmpty
                            ? Icons.chevron_right_rounded
                            : _isExpanded
                            ? Icons.expand_less_rounded
                            : Icons.expand_more_rounded,
                        color: color,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Section détails (expandable)
          if (_isExpanded && widget.tuitions.isNotEmpty)
            Column(
              children: [
                Divider(
                  height: 1,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Titre de la section
                      Row(
                        children: [
                          Icon(
                            Icons.receipt_long_rounded,
                            size: 18,
                            color: color,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Frais de scolarité',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Liste des frais par série/sexe
                      ...widget.tuitions.map((tuition) {
                        return _buildTuitionCard(
                          context,
                          theme,
                          isDark,
                          color,
                          tuition,
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTuitionCard(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    Color color,
    Map<String, dynamic> tuition,
  ) {
    final maleFees = tuition['male_school_fees'];
    final femaleFees = tuition['female_school_fees'];
    final registrationFees = tuition['registration_fees'];
    final serie = tuition['serie'];
    final serieName = serie != null ? serie['name']?.toString() : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header avec le nom de la série (si présent)
          if (serieName != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withValues(alpha: 0.15),
                    color.withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.bookmark_rounded, size: 16, color: color),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      serieName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: color,
                        letterSpacing: 0.3,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: color.withValues(alpha: 0.2)),
          ],

          // Contenu des frais
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Frais garçons
                Row(
                  children: [
                    Icon(
                      Icons.male_rounded,
                      color: Colors.blue.shade600,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Garçons:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${_formatAmount(maleFees)} FCFA',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Frais filles
                Row(
                  children: [
                    Icon(
                      Icons.female_rounded,
                      color: Colors.pink.shade400,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Filles:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${_formatAmount(femaleFees)} FCFA',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.pink.shade600,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),

                // Frais d'inscription (si différent de 0)
                if (registrationFees != null && registrationFees > 0) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.orange.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.app_registration_rounded,
                          color: Colors.orange.shade700,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Inscription:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange.shade800,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${_formatAmount(registrationFees)} FCFA',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade800,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      widget.onTap(serie);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: color, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: Icon(Icons.settings_rounded, size: 18, color: color),
                    label: Text(
                      'Configurer les frais',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: color,
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
  }
}
