import 'package:flutter/material.dart';
import 'package:novacole/components/data_models/default_data_grid.dart';
import 'package:novacole/models/user_model.dart';

class SuggestionPage extends StatefulWidget {
  const SuggestionPage({super.key});

  @override
  SuggestionPageState createState() {
    return SuggestionPageState();
  }
}

class SuggestionPageState extends State<SuggestionPage> {
  UserModel? user;
  @override
  void initState() {
    UserModel.fromLocalStorage().then((value) {
      setState(() {
        user = value;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (user != null) {
      return DefaultDataGrid(
        itemBuilder: (data) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${data['name']}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                "${data['content']}",
                style: const TextStyle(fontSize: 15),
              )
            ],
          );
        },
        query: {'order_by': 'created_at', 'order_direction': 'DESC'},
        data: {
          "filters": [
            {'field': 'created_by', 'value': user?.id}
          ]
        },
        dataModel: 'suggestion',
        paginate: PaginationValue.paginated,
        title: 'Suggestions',
        canAdd: true,
        canEdit: (item) => false,
        onBack: () {
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/home', (route) => false);
        },
      );
    } else {
      return Container();
    }
  }
}
