import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:novacole/components/data_models/default_data_grid.dart';
import 'package:novacole/components/permission_widgets.dart';
import 'package:novacole/models/master_crud_model.dart';
import 'package:novacole/models/user_model.dart';
import 'package:novacole/utils/constants.dart';
import 'package:novacole/utils/permission_utils.dart';

class PeriodDataPage extends StatefulWidget {
  const PeriodDataPage({super.key});

  @override
  PeriodDataPageState createState() {
    return PeriodDataPageState();
  }
}

class PeriodDataPageState extends State<PeriodDataPage> {
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
            itemBuilder: (period) {
              return PeriodInfoWidget(period: period);
            },
            dataModel: 'period',
            paginate: PaginationValue.paginated,
            title: 'Périodes scolaires',
            data: {
              'filters': [
                {'field': 'school_id', 'operator': '=', 'value': user?.school},
                {
                  'field': 'academic_id',
                  'operator': '=',
                  'value': user?.academic
                },
              ],
            },
            optionsBuilder: (period, reload, updateLine) {
              return [
                if (period['started_at'] == null)
                  DisableIfNoPermission(
                    permission: PermissionName.start(Entity.period),
                    child: ListTile(
                      onTap: () {
                        Navigator.pop(context);
                        _startPeriod(period, updateLine);
                      },
                      title: const Text("Démarrer"),
                      leading: const Icon(Icons.not_started_outlined),
                    ),
                  ),
                if (period['closed'] == true && period['started_at'] != null)
                  DisableIfNoPermission(
                    permission: PermissionName.open(Entity.period),
                    child: ListTile(
                      onTap: () {
                        Navigator.pop(context);
                        _periodOpen(period, updateLine);
                      },
                      title: const Text("Ouvrir"),
                      leading: const Icon(Icons.lock_open_outlined),
                    ),
                  ),
                if ([null, false, ''].contains(period['closed']) &&
                    period['started_at'] != null)
                  DisableIfNoPermission(
                    permission: PermissionName.close(Entity.period),
                    child: ListTile(
                      onTap: () {
                        Navigator.pop(context);
                        _periodClose(period, updateLine);
                      },
                      title: const Text("Clôturer"),
                      leading: const Icon(Icons.lock),
                    ),
                  )
              ];
            },
          )
        : Container();
  }

  _periodClose(Map<String, dynamic> period, updateLine) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clôturer la période'),
          content: const Text('Voulez-vous clôturer cette période scolaire ?'),
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
                  "/periods/close/${period['id']}",
                  data: {
                    'status': true,
                  },
                );
                if (res != null) {
                  updateLine(res);
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

  _periodOpen(Map<String, dynamic> period, updateLine) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ouvrir la période'),
          content: const Text('Voulez-vous ouvrir cette période scolaire ?'),
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
                  "/periods/close/${period['id']}",
                  data: {
                    'status': false,
                  },
                );
                if (res != null) {
                  updateLine(res);
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

  _startPeriod(Map<String, dynamic> period, updateLine) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: const Icon(Icons.question_mark_outlined),
          title: const Text('Démarrer la période'),
          content: const Text('Voulez-vous démarrer cette période scolaire ?'),
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
                  "/periods/start/${period['id']}",
                );
                if (res != null) {
                  updateLine(res);
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

class PeriodInfoWidget extends StatelessWidget {
  final Map<String, dynamic> period;

  const PeriodInfoWidget({super.key, required this.period});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Déterminer le statut de la période
    final statusData = _getStatusData();

    return Row(
      children: [
        // Icône avec gradient et badge de statut
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 52,
              height: 52,
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
                Icons.schedule_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),

            // Badge de statut
            Positioned(
              right: -6,
              top: -6,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      statusData['color'],
                      statusData['color'].withValues(alpha:0.8),
                    ],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: statusData['color'].withValues(alpha:0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  statusData['icon'],
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 14),

        // Contenu
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre de la période avec tag de statut inline
              Row(
                children: [
                  Expanded(
                    child: Text(
                      period['name'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: -0.3,
                        height: 1.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Tag de statut compact
                  _buildStatusChip(statusData),
                ],
              ),
              const SizedBox(height: 10),

              // Degré
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.indigo.shade400.withValues(alpha:0.15),
                      Colors.indigo.shade500.withValues(alpha:0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.indigo.shade300.withValues(alpha:0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade600.withValues(alpha:0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.school_rounded,
                        size: 16,
                        color: Colors.indigo.shade700,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Degré',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.indigo.shade600.withValues(alpha:0.7),
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            period['degree'].toString().tr(),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo.shade700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Widget pour le chip de statut
  Widget _buildStatusChip(Map<String, dynamic> statusData) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            statusData['color'],
            statusData['color'].withValues(alpha:0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withValues(alpha:0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: statusData['color'].withValues(alpha:0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusData['icon'],
            size: 12,
            color: Colors.white,
          ),
          const SizedBox(width: 5),
          Text(
            statusData['label'],
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  // Fonction pour déterminer les données du statut
  Map<String, dynamic> _getStatusData() {
    if (period['started_at'] == null) {
      return {
        'color': Colors.orange.shade600,
        'icon': Icons.schedule_rounded,
        'label': 'Non démarrée'.tr(),
      };
    } else if (period['closed'] == true) {
      return {
        'color': Colors.red.shade600,
        'icon': Icons.lock_rounded,
        'label': 'closed'.tr(),
      };
    } else {
      return {
        'color': Colors.green.shade600,
        'icon': Icons.lock_open_rounded,
        'label': 'opened'.tr(),
      };
    }
  }
}