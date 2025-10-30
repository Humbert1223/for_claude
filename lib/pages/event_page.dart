import 'dart:math';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:novacole/components/empty_page.dart';
import 'package:novacole/components/loading_indicator.dart';
import 'package:novacole/models/master_crud_model.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class EventPage extends StatefulWidget {
  const EventPage({super.key});

  @override
  EventPageState createState() => EventPageState();
}

const List<Color> colorPalette = [
  Color(0xFF4E6E58), Color(0xFF5676DC), Color(0xFFD9843B), Color(0xFF6A5ACD),
  Color(0xFFB56576), Color(0xFFA0522D), Color(0xFF008080), Color(0xFF708090),
  Color(0xFF5D576B), Color(0xFF9A8C98), Color(0xFF808000), Color(0xFFDAA520),
  Color(0xFF4682B4), Color(0xFF6B8E23), Color(0xFF556B2F), Color(0xFFBC8F8F),
  Color(0xFFDB7093), Color(0xFF778899), Color(0xFF8B4513), Color(0xFF9C6644),
  Color(0xFF7F8C8D), Color(0xFF6495ED), Color(0xFF967BB6), Color(0xFF778899),
  Color(0xFFBC6C25), Color(0xFF468499), Color(0xFFB565A7), Color(0xFFA67B5B),
  Color(0xFFC2A878), Color(0xFF6C757D),
];

class EventPageState extends State<EventPage> {
  final List<Appointment> events = <Appointment>[];
  List<Appointment>? _details;
  CalendarView currentView = CalendarView.month;
  bool isLoading = true;
  DateTime selectedDate = Jiffy.now().dateTime;

  @override
  void initState() {
    _getDataSource().then((value) {
      setState(() {
        events.addAll(value);
        isLoading = false;
        _updateDetailsForDate(selectedDate);
      });
    });
    super.initState();
  }

  void _updateDetailsForDate(DateTime date) {
    setState(() {
      selectedDate = date;
      _details = events.where((event) {
        return event.startTime.day == date.day &&
            event.startTime.month == date.month &&
            event.startTime.year == date.year;
      }).toList();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      body: isLoading
          ? const LoadingIndicator()
          : CustomScrollView(
        slivers: [
          // AppBar moderne avec gradient
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withValues(alpha:0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: FlexibleSpaceBar(
                centerTitle: true,
                title: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Événements',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMMM yyyy', 'fr_FR').format(selectedDate),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha:0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha:0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(
                    currentView == CalendarView.month
                        ? Icons.view_agenda_outlined
                        : Icons.calendar_month_outlined,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      currentView = currentView == CalendarView.month
                          ? CalendarView.week
                          : CalendarView.month;
                    });
                  },
                ),
              ),
            ],
          ),

          // Calendrier
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SfCalendar(
                  timeSlotViewSettings: const TimeSlotViewSettings(
                    startHour: 6,
                    endHour: 18,
                    timeFormat: 'HH:mm',
                    nonWorkingDays: <int>[],
                  ),
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  showTodayButton: true,
                  showNavigationArrow: true,
                  todayHighlightColor: Theme.of(context).colorScheme.primary,
                  headerStyle: CalendarHeaderStyle(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  viewHeaderStyle: ViewHeaderStyle(
                    dayTextStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.7),
                    ),
                    dateTextStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  cellBorderColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  firstDayOfWeek: 1,
                  view: currentView,
                  dataSource: MeetingDataSource(events),
                  onTap: calendarTapped,
                  initialSelectedDate: selectedDate,
                  monthViewSettings: MonthViewSettings(
                    appointmentDisplayMode: MonthAppointmentDisplayMode.indicator,
                    showAgenda: false,
                    monthCellStyle: MonthCellStyle(
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      textStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      trailingDatesTextStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.3),
                      ),
                      leadingDatesTextStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.3),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // En-tête de la liste d'événements
          if (_details != null && _details!.isNotEmpty)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primaryContainer.withValues(alpha:0.5),
                      Theme.of(context).colorScheme.primaryContainer.withValues(alpha:0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha:0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.event_outlined,
                        size: 18,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(selectedDate),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            '${_details!.length} événement${_details!.length > 1 ? 's' : ''}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Liste des événements
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: _details != null && _details!.isNotEmpty
                ? SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final event = _details![index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: event.color.withValues(alpha:0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Row(
                        children: [
                          // Barre de couleur
                          Container(
                            width: 6,
                            height: 100,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  event.color,
                                  event.color.withValues(alpha:0.7),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),

                          // Contenu
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  // Heure
                                  if (!event.isAllDay)
                                    Container(
                                      width: 70,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: event.color.withValues(alpha:0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            DateFormat('HH:mm').format(event.startTime),
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: event.color,
                                            ),
                                          ),
                                          Container(
                                            margin: const EdgeInsets.symmetric(vertical: 4),
                                            width: 20,
                                            height: 2,
                                            decoration: BoxDecoration(
                                              color: event.color.withValues(alpha:0.5),
                                              borderRadius: BorderRadius.circular(1),
                                            ),
                                          ),
                                          Text(
                                            DateFormat('HH:mm').format(event.endTime),
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: event.color,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                  if (!event.isAllDay) const SizedBox(width: 16),

                                  // Titre et badge
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (event.isAllDay)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: event.color.withValues(alpha:0.2),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.all_inclusive,
                                                  size: 14,
                                                  color: event.color,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Toute la journée',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                    color: event.color,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        SizedBox(height: event.isAllDay ? 8 : 0),
                                        Text(
                                          event.subject,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.access_time_rounded,
                                              size: 14,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withValues(alpha:0.6),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              _getDuration(event.startTime, event.endTime),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface
                                                    .withValues(alpha:0.6),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Icône
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: event.color.withValues(alpha:0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.event_available_rounded,
                                      color: event.color,
                                      size: 24,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: _details!.length,
              ),
            )
                : SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.only(top: 40),
                child: EmptyPage(
                  icon: Icon(
                    _details == null
                        ? Icons.calendar_month_outlined
                        : FontAwesomeIcons.calendarXmark,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.3),
                  ),
                  sub: Text(
                    _details == null
                        ? 'Sélectionnez une date pour voir les événements'
                        : "Aucun événement ce jour",
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.6),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Padding en bas
          const SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),
        ],
      ),
    );
  }

  String _getDuration(DateTime start, DateTime end) {
    final duration = end.difference(start);
    if (duration.inHours > 0) {
      return '${duration.inHours}h${duration.inMinutes % 60 > 0 ? ' ${duration.inMinutes % 60}min' : ''}';
    }
    return '${duration.inMinutes} minutes';
  }

  void calendarTapped(CalendarTapDetails calendarTapDetails) {
    if (calendarTapDetails.targetElement == CalendarElement.calendarCell) {
      _updateDetailsForDate(calendarTapDetails.date!);
    }
  }

  Future<List<Appointment>> _getDataSource() async {
    List<Appointment> data = [];
    List response = await MasterCrudModel('event').search(paginate: '0');
    for (int i = 0; i < response.length; i++) {
      final DateTime today = DateTime.parse(response[i]['event_date']);
      final DateTime startTime =
      DateTime.parse(response[i]['start_time']).copyWith(
        year: today.year,
        month: today.month,
        day: today.day,
      );
      final DateTime endTime = DateTime.parse(response[i]['end_time']).copyWith(
        year: today.year,
        month: today.month,
        day: today.day,
      );
      Color color;
      try {
        color = colorPalette[i];
      } catch (e) {
        color = colorPalette[Random().nextInt(colorPalette.length)];
      }
      data.add(
        Appointment(
          startTime: startTime,
          endTime: endTime,
          color: color,
          subject: response[i]['name'],
        ),
      );
    }

    return data;
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Appointment> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].to;
  }

  @override
  String getSubject(int index) {
    return appointments![index].eventName;
  }

  @override
  Color getColor(int index) {
    return appointments![index].background;
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].isAllDay;
  }
}