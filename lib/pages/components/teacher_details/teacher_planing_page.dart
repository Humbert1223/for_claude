import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:novacole/components/empty_page.dart';
import 'package:novacole/components/loading_indicator.dart';
import 'package:novacole/models/master_crud_model.dart';
import 'package:timelines_plus/timelines_plus.dart';

class TeacherPlaningPage extends StatefulWidget {
  final Map<String, dynamic> teacher;

  const TeacherPlaningPage({super.key, required this.teacher});

  @override
  TeacherPlaningPageState createState() {
    return TeacherPlaningPageState();
  }
}

class TeacherPlaningPageState extends State<TeacherPlaningPage> {
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 130,
          child: EasyDateTimeLine(
            locale: 'fr',
            initialDate: DateTime.now(),
            onDateChange: (selected) {
              setState(() {
                selectedDate = selected;
              });
            },
            activeColor: Theme.of(context).colorScheme.primary,
            headerProps: EasyHeaderProps(
              dateFormatter: const DateFormatter.fullDateDMonthAsStrY(' '),
              selectedDateStyle: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              monthPickerType: MonthPickerType.switcher,
              monthStyle: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            dayProps: EasyDayProps(
              height: 56.0,
              width: 56.0,
              dayStructure: DayStructure.dayNumDayStr,
              inactiveDayStyle: const DayStyle(
                borderRadius: 48.0,
                dayNumStyle: TextStyle(
                  fontSize: 16.0,
                ),
              ),
              todayStyle: DayStyle(
                borderRadius: 48,
                dayNumStyle: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              activeDayStyle: const DayStyle(
                dayNumStyle: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height - 350,
          child: SingleChildScrollView(
            child: FutureBuilder(
                future: MasterCrudModel('timetable').search(
                  paginate: '0',
                  filters: [
                    {
                      'field': 'name',
                      'operator': '=',
                      'value': (selectedDate.weekday - 1).toString()
                    },
                    {
                      'field': 'subject.teacher_id',
                      'operator': '=',
                      'value': widget.teacher['id']
                    },
                  ],
                  query: {'order_by': 'start_at'},
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.waiting) {
                    if (snapshot.hasData && List.from(snapshot.data).isNotEmpty) {
                      List<Map<String, dynamic>> timetables =
                          List<Map<String, dynamic>>.from(snapshot.data);
                      return FixedTimeline(
                        theme: TimelineThemeData().copyWith(
                          color: Theme.of(context).primaryColor,
                        ),
                        children: timetables.map((timeline) {
                          return TimelineTile(
                            nodeAlign: TimelineNodeAlign.basic,
                            oppositeContents: Container(
                              padding: const EdgeInsets.only(right: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  const Icon(Icons.watch_later_outlined),
                                  Text(
                                    "${DateFormat('HH:mm').format(DateTime.parse(timeline['start_at']))} ~ ${DateFormat('HH:mm').format(DateTime.parse(timeline['end_at']))}",
                                  ),
                                ],
                              ),
                            ),
                            node: TimelineNode.simple(),
                            contents: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${timeline['subject_name']}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text("Classe de ${timeline['classe_name']}"),
                                  Text(
                                      "Par ${timeline['subject']['charge_full_name']}"),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    } else {
                      return const Padding(
                        padding: EdgeInsets.only(top: 20.0),
                        child: SizedBox(
                          height: 100,
                          child: EmptyPage(
                            size: 32,
                            icon: Icon(
                              FontAwesomeIcons.book,
                              color: Colors.grey,
                            ),
                            sub: Text(
                              "Aucun cours aujourd'hui",
                              style: TextStyle(
                                  fontStyle: FontStyle.italic, color: Colors.grey),
                            ),
                          ),
                        ),
                      );
                    }
                  } else {
                    return const LoadingIndicator();
                  }
                }),
          ),
        )
      ],
    );
  }
}
