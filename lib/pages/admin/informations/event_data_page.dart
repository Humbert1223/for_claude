import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:novacole/components/data_models/default_data_grid.dart';
import 'package:novacole/models/user_model.dart';
import 'package:novacole/utils/tools.dart';

class EventDataPage extends StatefulWidget {
  const EventDataPage({super.key});

  @override
  EventDataPageState createState() {
    return EventDataPageState();
  }
}

class EventDataPageState extends State<EventDataPage> {
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
    return user != null
        ? DefaultDataGrid(
            itemBuilder: (event) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Date: ${NovaTools.dateFormat(event['event_date'])}"),
                      Text("Importance: ${(event['priority']).toString().tr()}")
                    ],
                  ),
                ],
              );
            },
            dataModel: 'event',
            paginate: PaginationValue.paginated,
            title: 'Événements',
            data: {
              'filters': [
                {'field': 'school_id', 'operator': '=', 'value': user?.school}
              ],
            },
          )
        : Container();
  }
}
