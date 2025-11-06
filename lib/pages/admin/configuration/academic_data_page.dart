import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:novacole/components/data_models/default_data_grid.dart';
import 'package:novacole/components/permission_widgets.dart';
import 'package:novacole/models/master_crud_model.dart';
import 'package:novacole/models/user_model.dart';
import 'package:novacole/utils/constants.dart';
import 'package:novacole/utils/permission_utils.dart';
import 'package:novacole/utils/tools.dart';

class AcademicDataPage extends StatefulWidget {
  const AcademicDataPage({super.key});

  @override
  AcademicDataPageState createState() {
    return AcademicDataPageState();
  }
}

class AcademicDataPageState extends State<AcademicDataPage> {
  UserModel? user;

  bool isLoading = false;

  List<Map<String, dynamic>>? items = [];

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
            itemBuilder: (academic) {
              return AcademicYearInfoWidget(academic: academic);
            },
            dataModel: 'academic',
            paginate: PaginationValue.paginated,
            title: 'Années scolaires',
            data: {
              'filters': [
                {'field': 'school_id', 'operator': '=', 'value': user?.school},
              ],
            },
            formInputsMutator: (inputs, datum) {
              inputs = inputs.map((el) {
                if (el['field'] == 'director_id') {
                  el['filters'] = [
                    {
                      'field': 'account_type',
                      'operator': 'in',
                      'value': ['staff', 'admin']
                    }
                  ];
                }
                if (datum != null) {
                  if (el['field'] == 'parent_id') {
                    el['hidden'] = true;
                  }
                }
                return el;
              }).toList();
              return inputs;
            },
            optionsBuilder: (academic, reload, updateLine) {
              return [
                if (academic['started_at'] == null)
                  DisableIfNoPermission(
                    permission: PermissionName.start(Entity.academic),
                    child: OptionItem(
                        icon: Icons.not_started_outlined,
                        iconColor: Colors.green,
                        title: "Démarrer",
                        onTap: () {
                          Navigator.pop(context);
                          _startAcademic(academic, updateLine);
                        },
                    )
                  ),
                if (academic['closed'] == true &&
                    academic['started_at'] != null)
                  DisableIfNoPermission(
                    permission: PermissionName.open(Entity.academic),
                    child: OptionItem(
                      icon: Icons.lock_open_outlined,
                      iconColor: Colors.green,
                      title: "Ouvrir",
                      onTap: () {
                        Navigator.pop(context);
                        _academicOpen(academic, updateLine);
                      },
                    ),
                  ),
                if ([null, false, ''].contains(academic['closed']) &&
                    academic['started_at'] != null)
                  DisableIfNoPermission(
                    permission: PermissionName.close(Entity.academic),
                    child: OptionItem(
                      icon: Icons.lock,
                      iconColor: Colors.red,
                      title: "Clôturer",
                      onTap: () {
                        Navigator.pop(context);
                        _academicClose(academic, updateLine);
                      },
                    ),
                  )
              ];
            },
          )
        : Container();
  }

  _academicOpen(Map<String, dynamic> academic, updateLine) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Ouvrir l'année scolaire"),
          content: const Text('Voulez-vous ouvrir cette année scolaire ?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Non'),
            ),
            TextButton(
              onPressed: () async {
                var res = await MasterCrudModel.post(
                  "/academics/close/${academic['id']}",
                  data: {
                    'status': false,
                  },
                );
                if(res != null){
                  updateLine(res);
                }
                Navigator.pop(context);
              },
              child: const Text(
                'Oui',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  _academicClose(Map<String, dynamic> academic, reload) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Clôturer l'année scolaire"),
          content: const Text('Voulez-vous clôturer cette année scolaire ?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Non'),
            ),
            TextButton(
              onPressed: () async {
                var res = await MasterCrudModel.post(
                  "/academics/close/${academic['id']}",
                  data: {
                    'status': true,
                  },
                );
                if(res != null){
                  reload();
                }
                Navigator.pop(context);
              },
              child: const Text(
                'Oui',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  _startAcademic(Map<String, dynamic> academic, reload) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Démarrer l'année scolaire"),
          content: const Text('Voulez-vous démarrer cette année scolaire ?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Non'),
            ),
            TextButton(
              onPressed: () async {
                var res = await MasterCrudModel.post(
                  "/academics/start/${academic['id']}",
                );
                if(res != null){
                  reload();
                }
                Navigator.pop(context);
              },
              child: const Text('Oui'),
            ),
          ],
        );
      },
    );
  }
}

class AcademicYearInfoWidget extends StatelessWidget {
  final Map<String, dynamic> academic;

  const AcademicYearInfoWidget({super.key, required this.academic});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Déterminer les statuts
    final startedStatusData = _getStartedStatusData();
    final closedStatusData = _getClosedStatusData();

    return Row(
      children: [
        // Icône avec gradient et badges de statut multiples
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withValues(alpha:0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha:0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.calendar_month_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),

            // Badge "Démarré/Non démarré" en haut à droite
            Positioned(
              right: -8,
              top: -8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      startedStatusData['color'],
                      startedStatusData['color'].withValues(alpha:0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: startedStatusData['color'].withValues(alpha:0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  startedStatusData['icon'],
                  color: Colors.white,
                  size: 12,
                ),
              ),
            ),

            // Badge "Ouvert/Fermé" en bas à droite
            Positioned(
              right: -8,
              bottom: -8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      closedStatusData['color'],
                      closedStatusData['color'].withValues(alpha:0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: closedStatusData['color'].withValues(alpha:0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  closedStatusData['icon'],
                  color: Colors.white,
                  size: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),

        // Contenu
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre de l'année académique
              Text(
                academic['name'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: -0.3,
                  height: 1.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Période avec icônes
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.teal.shade400.withValues(alpha:0.15),
                      Colors.teal.shade500.withValues(alpha:0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.teal.shade300.withValues(alpha:0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.play_arrow_rounded,
                      size: 16,
                      color: Colors.teal.shade700,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        NovaTools.dateFormat(academic['start_at']),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: 20,
                      height: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.teal.shade400,
                            Colors.teal.shade600,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        NovaTools.dateFormat(academic['end_at']),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade700,
                        ),
                        textAlign: TextAlign.right,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.stop_rounded,
                      size: 16,
                      color: Colors.teal.shade700,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Tags de statut
              Row(
                children: [
                  Expanded(
                    child: _buildStatusChip(
                      label: startedStatusData['label'],
                      icon: startedStatusData['icon'],
                      color: startedStatusData['color'],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatusChip(
                      label: closedStatusData['label'],
                      icon: closedStatusData['icon'],
                      color: closedStatusData['color'],
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

  // Widget pour les chips de statut
  Widget _buildStatusChip({
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha:0.2),
            color.withValues(alpha:0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withValues(alpha:0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha:0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // Fonction pour déterminer le statut de démarrage
  Map<String, dynamic> _getStartedStatusData() {
    if (academic['started_at'] != null) {
      return {
        'color': Colors.green.shade600,
        'icon': Icons.check_circle_rounded,
        'label': 'Démarrée',
      };
    } else {
      return {
        'color': Colors.amber.shade700,
        'icon': Icons.schedule_rounded,
        'label': 'Non démarrée'.tr(),
      };
    }
  }

  // Fonction pour déterminer le statut d'ouverture
  Map<String, dynamic> _getClosedStatusData() {
    if (academic['closed'] == true) {
      return {
        'color': Colors.orange.shade600,
        'icon': Icons.lock_rounded,
        'label': 'closed'.tr(),
      };
    } else {
      return {
        'color': Colors.blue.shade600,
        'icon': Icons.lock_open_rounded,
        'label': 'opened'.tr(),
      };
    }
  }
}