import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:novacole/components/empty_page.dart';
import 'package:novacole/components/loading_indicator.dart';
import 'package:novacole/models/master_crud_model.dart';
import 'package:novacole/models/user_model.dart';
import 'package:novacole/pages/event_page.dart';
import 'package:novacole/utils/tools.dart';

class HomeTodayEvent extends StatefulWidget {
  const HomeTodayEvent({super.key});

  @override
  HomeTodayEventState createState() => HomeTodayEventState();
}

class HomeTodayEventState extends State<HomeTodayEvent> {
  UserModel? user;
  List events = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final value = await UserModel.fromLocalStorage();
    if (!mounted) return;

    setState(() {
      user = value;
    });

    if ((value?.schools ?? []).isNotEmpty) {
      await _loadEvents();
    } else {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> _loadEvents() async {
    try {
      final evs = await MasterCrudModel('event').search(
        paginate: '0',
        filters: [
          {
            'field': 'event_date',
            'operator': 'date',
            'value': DateFormat('yyyy-MM-dd').format(DateTime.now())
          }
        ],
        query: {'order_by': 'start_time'},
      );

      if (mounted) {
        setState(() {
          events = evs;
          loading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    if (user == null || (user?.schools ?? []).isEmpty) {
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
            // En-tête moderne
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha:0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.event_available_rounded,
                        color: colorScheme.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Événements du jour',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EventPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: const Text(
                    'Voir tous',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Contenu des événements
            _buildEventContent(colorScheme, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildEventContent(ColorScheme colorScheme, bool isDark) {
    if (loading) {
      return const SizedBox(
        height: 140,
        child: Center(
          child: LoadingIndicator(
            type: LoadingIndicatorType.progressiveDots,
          ),
        ),
      );
    }

    if (events.isEmpty) {
      return SizedBox(
        height: 140,
        child: EmptyPage(
          size: 40,
          icon: Icon(
            Icons.event_busy_rounded,
            color: colorScheme.onSurface.withValues(alpha:0.3),
          ),
          sub: Text(
            "Aucun événement aujourd'hui",
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: colorScheme.onSurface.withValues(alpha:0.5),
              fontSize: 13,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: events.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return _buildEventCard(
            List<Map<String, dynamic>>.from(events)[index],
            colorScheme,
            isDark,
          );
        },
      ),
    );
  }

  Widget _buildEventCard(
      Map<String, dynamic> event,
      ColorScheme colorScheme,
      bool isDark,
      ) {
    final startTime = DateFormat('HH:mm').format(DateTime.parse(event['start_time']));
    final endTime = DateFormat('HH:mm').format(DateTime.parse(event['end_time']));

    return Container(
      width: MediaQuery.of(context).size.width * 0.75,
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.primaryContainer
            : colorScheme.surfaceContainerHighest.withValues(alpha:0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? colorScheme.outline.withValues(alpha:0.2)
              : colorScheme.outline.withValues(alpha:0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha:0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre de l'événement
            Expanded(
              child: Text(
                capitalize(event['name']),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: colorScheme.onSurface,
                  height: 1.3,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(height: 12),

            // Nom de l'école
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                event['school_name'].toString().toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                  letterSpacing: 0.5,
                  color: colorScheme.primary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(height: 12),

            // Horaire
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark
                    ? colorScheme.surfaceContainerHighest
                    : Colors.white.withValues(alpha:0.7),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha:0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 16,
                    color: colorScheme.onSurface.withValues(alpha:0.7),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "$startTime - $endTime",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}