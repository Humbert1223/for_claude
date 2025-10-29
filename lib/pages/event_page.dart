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
  EventPageState createState() {
    return EventPageState();
  }
}

const List<Color> colorPalette = [
  Color(0xFF4E6E58), // Vert foncé doux
  Color(0xFF5676DC), // Bleu moyen
  Color(0xFFD9843B), // Orange terre
  Color(0xFF6A5ACD), // Bleu violacé
  Color(0xFFB56576), // Rose terre
  Color(0xFFA0522D), // Marron cannelle
  Color(0xFF008080), // Bleu sarcelle
  Color(0xFF708090), // Gris ardoise
  Color(0xFF5D576B), // Gris violet
  Color(0xFF9A8C98), // Mauve doux
  Color(0xFF808000), // Olive
  Color(0xFFDAA520), // Or foncé
  Color(0xFF4682B4), // Bleu acier
  Color(0xFF6B8E23), // Vert olive foncé
  Color(0xFF556B2F), // Vert forêt
  Color(0xFFBC8F8F), // Brun rosé
  Color(0xFFDB7093), // Rose profond
  Color(0xFF778899), // Gris bleuté
  Color(0xFF8B4513), // Brun chocolat
  Color(0xFF9C6644), // Brun terreux
  Color(0xFF7F8C8D), // Gris urbain
  Color(0xFF6495ED), // Bleu de cornflower
  Color(0xFF967BB6), // Lavande foncée
  Color(0xFF778899), // Gris acier
  Color(0xFFBC6C25), // Orange brûlé
  Color(0xFF468499), // Bleu cendré
  Color(0xFFB565A7), // Magenta doux
  Color(0xFFA67B5B), // Brun café
  Color(0xFFC2A878), // Beige doré
  Color(0xFF6C757D), // Gris neutre
];

class EventPageState extends State<EventPage> {
  final List<Appointment> events = <Appointment>[];
  List<Appointment>? _details;
  CalendarView currentView = CalendarView.month;
  bool isLoading = true;

  @override
  void initState() {
    _getDataSource().then((value) {
      setState(() {
        events.addAll(value);
        isLoading = false;
        _details = events.where((event) {
          return event.startTime.day == Jiffy.now().dateTime.day &&
              event.startTime.month == Jiffy.now().dateTime.month &&
              event.startTime.year == Jiffy.now().dateTime.year;
        }).toList();
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
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text(
          'Événements',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      body: isLoading
          ? const LoadingIndicator()
          : Column(
              children: [
                SfCalendar(
                  timeSlotViewSettings: const TimeSlotViewSettings(
                    startHour: 6,
                    endHour: 18,
                    timeFormat: 'HH:mm',
                    nonWorkingDays: <int>[],
                  ),
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  showTodayButton: true,
                  showNavigationArrow: true,
                  headerStyle: CalendarHeaderStyle(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                  ),
                  firstDayOfWeek: 1,
                  view: currentView,
                  dataSource: MeetingDataSource(events),
                  onTap: calendarTapped,
                  initialSelectedDate: Jiffy.now().dateTime,
                ),
                const SizedBox(height: 20),
                (_details != null)
                    ? Expanded(
                        child: (_details!.isNotEmpty)
                            ? ListView.separated(
                                padding: const EdgeInsets.all(2),
                                itemCount: _details!.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Container(
                                      padding: const EdgeInsets.all(2),
                                      height: 60,
                                      color: _details?[index].color,
                                      child: ListTile(
                                        leading: Column(
                                          children: <Widget>[
                                            Text(
                                              _details![index].isAllDay
                                                  ? ''
                                                  : DateFormat('HH:mm').format(
                                                      _details![index]
                                                          .startTime),
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                  height: 1.7),
                                            ),
                                            Text(
                                              _details![index].isAllDay
                                                  ? 'All day'
                                                  : 'à',
                                              style: const TextStyle(
                                                  height: 0.5,
                                                  color: Colors.white),
                                            ),
                                            Text(
                                              _details![index].isAllDay
                                                  ? ''
                                                  : DateFormat('HH:mm').format(
                                                      _details![index].endTime),
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                        title: Text(_details![index].subject,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white)),
                                      ));
                                },
                                separatorBuilder:
                                    (BuildContext context, int index) =>
                                        const Divider(
                                  height: 5,
                                ),
                              )
                            : const EmptyPage(
                                icon: Icon(FontAwesomeIcons.calendarXmark),
                                sub: Text("Aucun événement aujourd'hui"),
                              ),
                      )
                    : const Padding(
                        padding: EdgeInsets.only(top: 100.0),
                        child: EmptyPage(
                          icon: Icon(
                            Icons.calendar_month_outlined,
                            size: 32,
                          ),
                          sub: Text(
                            'Sélectionner une date pour voir les événements',
                          ),
                        ),
                      )
              ],
            ),
    );
  }

  void calendarTapped(CalendarTapDetails calendarTapDetails) {
    if (calendarTapDetails.targetElement == CalendarElement.calendarCell) {
      setState(() {
        _details = calendarTapDetails.appointments!.cast<Appointment>();
      });
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
