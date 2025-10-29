import 'package:flutter/material.dart';
import 'package:novacole/components/loading_indicator.dart';
import 'package:novacole/models/master_crud_model.dart';

class ReportAssessmentFilterSelector extends StatefulWidget {
  final String classeId;
  final String? title;
  final Map<String, dynamic> filters;
  final Function? onSelect;

  const ReportAssessmentFilterSelector({super.key, required this.classeId, required this.filters, this.onSelect, this.title});

  @override
  ReportAssessmentFilterSelectorState createState() {
    return ReportAssessmentFilterSelectorState();
  }
}

class ReportAssessmentFilterSelectorState
    extends State<ReportAssessmentFilterSelector> {
  List<Map<String, dynamic>> assessments = [];
  bool isLoading = true;
  @override
  void initState() {
    MasterCrudModel('assessment').search(
      paginate: '0',
      filters: [
        {
          'field': 'classe_ids',
          'value': widget.classeId,
        }
      ],
    ).then((response) {
      if (response != null) {
        setState(() {
          assessments = List<Map<String, dynamic>>.from(response);
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
          widget.title ?? 'Rapports & États',
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
            children: assessments
                .map<Widget>((assessment) => Card(
                      child: ListTile(
                        trailing: const Icon(Icons.arrow_forward_ios_rounded),
                        title: Text(assessment['name']),
                        onTap: (){
                          if(widget.onSelect != null) {
                            widget.onSelect!({
                              ...widget.filters,
                              'assessment_id': assessment['id']
                            }, assessment);
                          }
                        },
                      ),
                    ))
                .toList()),
      ),
    );
  }
}
