import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:novacole/components/loading_indicator.dart';

class ExamSubjectList extends StatefulWidget {
  final Map<String, dynamic> exam;

  const ExamSubjectList({super.key, required this.exam});

  @override
  ExamSubjectListState createState() {
    return ExamSubjectListState();
  }
}

class ExamSubjectListState extends State<ExamSubjectList> {
  bool loading = false;

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
        title: const Text(
          "Matières",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Padding(
            padding: const EdgeInsets.only(
              top: 15.0,
              left: 15.0,
              bottom: 20,
              right: 15.0,
            ),
            child: Row(
              children: [
                Container(
                  height: 90,
                  width: 90,
                  margin: const EdgeInsets.only(right: 15.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(FontAwesomeIcons.peopleLine, size: 60),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${widget.exam['name']}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color:
                            Theme.of(
                              context,
                            ).primaryTextTheme.headlineLarge!.color,
                      ),
                    ),
                    Text(
                      "Niveau : ${widget.exam['level']?['name']}",
                      style: TextStyle(
                        fontSize: 16.0,
                        color:
                            Theme.of(
                              context,
                            ).primaryTextTheme.headlineLarge!.color,
                      ),
                    ),
                    Text(
                      "Période : ${widget.exam['period']?['name'] ?? '-'}",
                      style: TextStyle(
                        fontSize: 16.0,
                        color:
                            Theme.of(
                              context,
                            ).primaryTextTheme.headlineLarge!.color,
                      ),
                    ),
                    Text(
                      "Etablissement : ${List.from(widget.exam['school_ids'] ?? []).length}",
                      style: TextStyle(
                        fontSize: 16.0,
                        color:
                            Theme.of(
                              context,
                            ).primaryTextTheme.headlineLarge!.color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
        ),
        child: Visibility(
          visible: !loading,
          replacement: LoadingIndicator(),
          child: ListView(
            children: [
              ...List.from(widget.exam['subjects'] ?? []).map((subject) {
                return Card(
                  child: ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${subject['name']}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          "Titulaire: ${subject['charge_full_name'] ?? '-'}",
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Coefficient: ${subject['coefficient']}",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Discipline: ${subject['discipline']['name']}",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.more_vert_rounded),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(Icons.add),
      ),
    );
  }
}
