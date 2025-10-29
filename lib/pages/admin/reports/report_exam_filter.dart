import 'package:flutter/material.dart';
import 'package:novacole/components/loading_indicator.dart';
import 'package:novacole/models/master_crud_model.dart';
import 'package:novacole/utils/tools.dart';

class ReportExamFilterSelector extends StatefulWidget {
  final String? title;
  final Map<String, dynamic> filters;
  final Function? onSelect;

  const ReportExamFilterSelector({
    super.key,
    required this.filters,
    this.onSelect,
    this.title,
  });

  @override
  ReportExamFilterSelectorState createState() {
    return ReportExamFilterSelectorState();
  }
}

class ReportExamFilterSelectorState extends State<ReportExamFilterSelector> {
  List<Map<String, dynamic>> exams = [];
  bool isLoading = true;

  @override
  void initState() {
    MasterCrudModel('exam').search(
      paginate: '0',
    ).then((response) {
      if (response != null) {
        setState(() {
          exams = List<Map<String, dynamic>>.from(response);
          isLoading = false;
        });
      }
    }).catchError((error) {
      isLoading = false;
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
        title: Text(
          widget.title ?? 'Rapport des examens',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: Visibility(
        visible: !isLoading,
        replacement: const Center(
          child: LoadingIndicator(),
        ),
        child: ListView(
            children: exams
                .map<Widget>((exam) => Card(
                  child: ListTile(
                    title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                    Text(
                      "${exam['name']}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width - 170,
                              child: Text(
                                "Niveau: ${exam['level']['name']}",
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            Text(
                              "Date: ${NovaTools.dateFormat(exam['start_at'])}",
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                                  ],
                                ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded),
                    onTap: () {
                      if (widget.onSelect != null) {
                        widget.onSelect!({
                          ...widget.filters,
                          'exam_id': exam['id']
                        }, exam);
                      }
                    }
                  ),
                ))
                .toList()),
      ),
    );
  }
}
