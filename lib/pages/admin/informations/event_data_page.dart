import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:novacole/components/data_models/default_data_grid.dart';
import 'package:novacole/models/user_model.dart';
import 'package:novacole/utils/tools.dart';

class EventDataPage extends StatefulWidget {
  const EventDataPage({super.key});

  @override
  EventDataPageState createState() {
    return EventDataPageState();
  }
}

class EventDataPageState extends State<EventDataPage> {
  UserModel? user;

  @override
  void initState() {
    UserModel.fromLocalStorage().then((value) {
      setState(() {
        user = value;
      });
    });
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
            itemBuilder: (event) {
              return EventInfoWidget(event: event);
            },
            dataModel: 'event',
            paginate: PaginationValue.paginated,
            title: 'Événements',
            data: {
              'filters': [
                {'field': 'school_id', 'operator': '=', 'value': user?.school}
              ],
            },
          )
        : Container();
  }
}

class EventInfoWidget extends StatelessWidget {
  final Map<String, dynamic> event;

  const EventInfoWidget({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Déterminer la couleur et l'icône de la priorité
    final priorityData = _getPriorityData(event['priority'].toString());

    return Row(
      children: [
        // Icône avec gradient et badge de priorité
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
                Icons.event_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),

            // Badge de priorité
            Positioned(
              right: -6,
              top: -6,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      priorityData['color'],
                      priorityData['color'].withValues(alpha:0.8),
                    ],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: priorityData['color'].withValues(alpha:0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  priorityData['icon'],
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
              // Titre de l'événement
              Text(
                event['name'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: -0.3,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),

              // Métadonnées
              Row(
                children: [
                  // Date de l'événement
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.purple.shade400.withValues(alpha:0.15),
                            Colors.purple.shade500.withValues(alpha:0.08),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.purple.shade300.withValues(alpha:0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 14,
                            color: Colors.purple.shade700,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              NovaTools.dateFormat(event['event_date']),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple.shade700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Priorité
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          priorityData['color'].withValues(alpha:0.2),
                          priorityData['color'].withValues(alpha:0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: priorityData['color'].withValues(alpha:0.4),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: priorityData['color'].withValues(alpha:0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          priorityData['icon'],
                          size: 14,
                          color: priorityData['color'],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          event['priority'].toString().tr(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: priorityData['color'],
                          ),
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

  // Fonction pour déterminer la couleur et l'icône selon la priorité
  Map<String, dynamic> _getPriorityData(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
      case 'haute':
      case 'élevée':
      case 'urgent':
        return {
          'color': Colors.red.shade600,
          'icon': Icons.priority_high_rounded,
        };
      case 'medium':
      case 'moyenne':
      case 'normal':
        return {
          'color': Colors.orange.shade600,
          'icon': Icons.drag_handle_rounded,
        };
      case 'low':
      case 'basse':
      case 'faible':
        return {
          'color': Colors.green.shade600,
          'icon': Icons.arrow_downward_rounded,
        };
      case 'critical':
      case 'critique':
        return {
          'color': Colors.purple.shade700,
          'icon': Icons.warning_rounded,
        };
      default:
        return {
          'color': Colors.blue.shade600,
          'icon': Icons.info_rounded,
        };
    }
  }
}