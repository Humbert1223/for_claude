import 'package:flutter/material.dart';
import 'package:novacole/components/data_models/default_data_grid.dart';

class ExpenseLineDataPage extends StatefulWidget {
  const ExpenseLineDataPage({super.key});

  @override
  ExpenseLineDataPageState createState() {
    return ExpenseLineDataPageState();
  }
}

class ExpenseLineDataPageState extends State<ExpenseLineDataPage> {

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
          subtitle: method['description'] != null
              ? Text("${method['description'] ?? ''}")
              : null,
        );
      },
      dataModel: 'expense',
      paginate: PaginationValue.paginated,
      title: 'Types de dépense',
    );
  }
}
