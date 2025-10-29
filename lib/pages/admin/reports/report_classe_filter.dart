import 'package:flutter/material.dart';
import 'package:novacole/components/loading_indicator.dart';
import 'package:novacole/models/master_crud_model.dart';

class ReportClasseFilterSelector extends StatefulWidget {
  final String? degree;
  final String? title;
  final Map<String, dynamic>? filters;
  final Function? onSelect;

  const ReportClasseFilterSelector(
      {super.key,
      required this.degree,
      this.filters,
      this.onSelect,
      this.title});

  @override
  ReportClasseFilterSelectorState createState() {
    return ReportClasseFilterSelectorState();
  }
}

class ReportClasseFilterSelectorState
    extends State<ReportClasseFilterSelector> {
  List<Map<String, dynamic>> classes = [];

  bool isLoading = true;

  @override
  void initState() {
    MasterCrudModel('classe').search(
      paginate: '0',
      filters: [
        if(widget.degree != null){
          'field': 'level.degree',
          'value': widget.degree,
        }
      ],
    ).then((response) {
      if (response != null) {
        setState(() {
          classes = List<Map<String, dynamic>>.from(response);
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
          children: classes
              .map<Widget>(
                (classe) => Card(
                  child: ListTile(
                    trailing: const Icon(Icons.arrow_forward_ios_rounded),
                    title: Text(classe['name']),
                    onTap: () {
                      if (widget.onSelect != null) {
                        widget.onSelect!(
                          {...(widget.filters ?? {}), 'classe_id': classe['id']},
                          classe,
                        );
                      }
                    },
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
