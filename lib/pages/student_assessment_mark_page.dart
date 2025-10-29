import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:novacole/components/loading_indicator.dart';
import 'package:novacole/models/master_crud_model.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class StudentAssessmentMarkPage extends StatefulWidget {
  final Map<String, dynamic> assessment;
  final Map<String, dynamic> student;

  const StudentAssessmentMarkPage({
    super.key,
    required this.assessment,
    required this.student,
  });

  @override
  StudentAssessmentMarkPageState createState() {
    return StudentAssessmentMarkPageState();
  }
}

class StudentAssessmentMarkPageState extends State<StudentAssessmentMarkPage> {
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
          future: MasterCrudModel('mark').search(paginate: '0', filters: [
            {'field': 'assessment_id', 'value': widget.assessment['id']},
            {'field': 'student_id', 'value': widget.student['id']}
          ], query: {
            'relations': ['subject']
          }),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const LoadingIndicator();
            } else {
              List<Map<String, dynamic>> marks = [];
              if (snap.hasData && snap.data != null) {
                marks = List<Map<String, dynamic>>.from(snap.data);
              }
              marks = marks.map((mark) {
                double coeff = 1.0 * mark['subject']['coefficient'];
                double valueOn = 20.0 * coeff;
                mark['value_on'] = valueOn;
                mark['value_coeff'] = coeff * mark['value'];
                mark['percent'] = mark['value_coeff'] / valueOn;
                return mark;
              }).toList();
              double sumMark =
                  marks.fold(0.0, (sum, m) => m['value_coeff'] + sum);
              double sumCoeff = marks.fold(
                  0.0, (sum, m) => m['subject']['coefficient'] + sum);
              double globalPercent = sumMark / (20 * sumCoeff);
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
                              Container(
                                height: 80,
                                width: 80,
                                margin: const EdgeInsets.only(right: 15.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  image: (widget.student['photo_url'] != null)
                                      ? DecorationImage(
                                          image: NetworkImage(
                                              widget.student['photo_url']))
                                      : const DecorationImage(
                                          image: AssetImage(
                                              'assets/images/person.jpeg')),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.student['last_name'].toString().toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "${widget.student['first_name']}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "Sexe : ${tr(widget.student['gender'])}",
                                    style: const TextStyle(fontSize: 12.0),
                                  ),
                                  Text(
                                    "N° mle: ${widget.student['matricule']}",
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
                                  "${sumMark.toStringAsFixed(0)}/${(sumCoeff * 20).toStringAsFixed(0)}",
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
                  children: marks.map<Widget>((mark) {
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
                                image: CachedNetworkImageProvider(mark['subject']['discipline']?['image_url']),
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
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        width: MediaQuery.of(context).size.width - 230,
                                        child: Text(
                                          mark['subject']['discipline']
                                                  ?['name'] ??
                                              mark['subject']['name'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        "${(mark['value_coeff']).toStringAsFixed(2)} / ${mark['value_on'].toStringAsFixed(0)}",
                                      )
                                    ],
                                  ),
                                ),
                                LinearPercentIndicator(
                                  percent: mark['percent'],
                                  lineHeight: 20,
                                  barRadius: const Radius.circular(15),
                                  center: Text(
                                      "${(mark['percent'] * 100).toStringAsFixed(0)}%"),
                                  progressColor: mark['percent'] < 0.5
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
