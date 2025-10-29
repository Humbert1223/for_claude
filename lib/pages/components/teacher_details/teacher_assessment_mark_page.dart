import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:novacole/components/loading_indicator.dart';
import 'package:novacole/components/model_photo_widget.dart';
import 'package:novacole/models/master_crud_model.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class TeacherAssessmentMarkPage extends StatefulWidget {
  final Map<String, dynamic> assessment;
  final Map<String, dynamic> teacher;

  const TeacherAssessmentMarkPage({
    super.key,
    required this.assessment,
    required this.teacher,
  });

  @override
  TeacherAssessmentMarkPageState createState() {
    return TeacherAssessmentMarkPageState();
  }
}

class TeacherAssessmentMarkPageState extends State<TeacherAssessmentMarkPage> {
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
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(
          "${widget.assessment['name']}",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
      body: FutureBuilder(
          future: MasterCrudModel.load(
              '/assessment/mark-achievement/${widget.teacher['id']}/${widget.assessment['id']}'),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const LoadingIndicator();
            } else {
              List<Map<String, dynamic>> achievements =
                  List<Map<String, dynamic>>.from(snap.data ?? []);
              int totalMark = (achievements.map((el) => el['mark_count']).reduce(
                      (prev, curr) => prev + curr  ));
              int totalStudent = (achievements.map((el) => el['student_count']).reduce(
                      (prev, curr) => prev + curr  ));
              double globalPercent = totalStudent > 0 ? totalMark / totalStudent : 0.0 ;
              return Scaffold(
                appBar: AppBar(
                  leading: Container(),
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(
                      80,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20.0,
                        horizontal: 15.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              ModelPhotoWidget(model: widget.teacher),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.teacher['last_name'].toString().toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "${widget.teacher['first_name']}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "Sexe : ${tr(widget.teacher['gender'])}",
                                    style: const TextStyle(fontSize: 12.0),
                                  ),
                                  Text(
                                    "N° mle: ${widget.teacher['matricule'] ?? '-'}",
                                    style: const TextStyle(fontSize: 12.0),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          CircularPercentIndicator(
                            radius: 40,
                            percent: globalPercent,
                            lineWidth: 8,
                            progressColor: globalPercent < 0.5
                                ? Colors.red
                                : Theme.of(context).colorScheme.primary,
                            center: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "${(globalPercent * 100).toStringAsFixed(0)}%",
                                ),
                                Text(
                                  "${totalMark.toStringAsFixed(0)}/${totalStudent.toStringAsFixed(0)}",
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                body: ListView(
                  children: achievements.map<Widget>((achievement) {
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      margin: const EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 15.0,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 60,
                            width: 80,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: CachedNetworkImageProvider(
                                    achievement['subject']['discipline']
                                        ?['image_url']),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width - 130,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            width: MediaQuery.of(context).size.width - 210,
                                            child: Text(
                                              achievement['subject']['discipline']
                                                      ?['name'] ??
                                                  achievement['subject']['name'],
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            "${(achievement['mark_count']).toStringAsFixed(0)} / ${achievement['student_count'].toStringAsFixed(0)}",
                                          )
                                        ],
                                      ),
                                      Text("${achievement['subject']['classe']['name']}")
                                    ],
                                  ),
                                ),
                                LinearPercentIndicator(
                                  percent: (achievement['percent'] * 1.0),
                                  lineHeight: 20,
                                  barRadius: const Radius.circular(15),
                                  center: Text(
                                      "${(achievement['percent'] * 100).toStringAsFixed(0)}%"),
                                  progressColor: achievement['percent'] < 0.5
                                      ? Colors.red
                                      : Theme.of(context).colorScheme.primary,
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  }).toList(),
                ),
              );
            }
          }),
    );
  }
}
