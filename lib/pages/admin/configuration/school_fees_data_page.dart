import 'package:flutter/material.dart';
import 'package:novacole/components/data_models/default_data_grid.dart';

class SchoolFeesDataPage extends StatefulWidget {
  const SchoolFeesDataPage({super.key});

  @override
  SchoolFeesDataPageState createState() {
    return SchoolFeesDataPageState();
  }
}

class SchoolFeesDataPageState extends State<SchoolFeesDataPage> {
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
    return DefaultDataGrid(
      itemBuilder: (method) {
        return ListTile(
          title: Text("${method['name']}"),
          subtitle: Text("N°: ${method['account_number']}"),
        );
      },
      dataModel: 'level',
      paginate: PaginationValue.none,
      title: 'Frais de scolarité',
    );
  }
}
