import 'package:flutter/material.dart';
import 'package:novacole/components/loading_indicator.dart';
import 'package:novacole/models/master_crud_model.dart';

class ReportLevelFilterSelector extends StatefulWidget {
  final String degree;
  final String? title;
  final Map<String, dynamic> filters;
  final Function? onSelect;

  const ReportLevelFilterSelector({
    super.key,
    required this.degree,
    required this.filters,
    this.title,
    this.onSelect,
  });

  @override
  ReportLevelFilterSelectorState createState() {
    return ReportLevelFilterSelectorState();
  }
}

class ReportLevelFilterSelectorState extends State<ReportLevelFilterSelector> {
  List<Map<String, dynamic>> levels = [];
  bool isLoading = true;

  @override
  void initState() {
    MasterCrudModel('level').search(
      paginate: '0',
      filters: [
        {
          'field': 'degree',
          'value': widget.degree,
        }
      ],
    ).then((response) {
      if (response != null) {
        setState(() {
          levels = List<Map<String, dynamic>>.from(response);
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
            children: levels
                .map<Widget>((level) => Card(
                      child: ListTile(
                        trailing: const Icon(Icons.arrow_forward_ios_rounded),
                        title: Text(level['name']),
                        onTap: (){
                          if(widget.onSelect != null){
                            widget.onSelect!(
                              {...widget.filters, 'level_id': level['id']},
                              level,
                            );
                          }
                        },
                      ),
                    ))
                .toList()),
      ),
    );
  }
}
