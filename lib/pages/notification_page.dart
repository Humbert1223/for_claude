import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:novacole/components/data_models/default_data_grid.dart';
import 'package:novacole/models/master_crud_model.dart';
import 'package:novacole/models/user_model.dart';
import 'package:novacole/utils/tools.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  NotificationPageState createState() {
    return NotificationPageState();
  }
}

class NotificationPageState extends State<NotificationPage> {
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
          Map<String, dynamic> notification = Map<String, dynamic>.from(
            data['data'],
          );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${notification['title']}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: data['read_at'] == null
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 16,
                ),
              ),
              Text(
                smallSentence(escapeHtmlString(notification['message']) ?? ''),
                style: const TextStyle(fontSize: 15),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Text(
                  "${data['human_created_at']}",
                  style: const TextStyle(fontSize: 13),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          );
        },
        query: {
          'order_by': 'created_at|read_at',
          'order_direction': 'DESC|ASC',
        },
        data: {
          "filters": [
            {'field': 'notifiable_id', 'value': user?.id}
          ],
        },
        appBarVisible: false,
        dataModel: 'notification',
        paginate: PaginationValue.infiniteScroll,
        title: 'Notification',
        canAdd: false,
        canEdit: (item) => false,
        onBack: () {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/home', (route) => false);
        },
        onItemTap: (data, updateLine) {
          Map<String, dynamic> notification = Map<String, dynamic>.from(
            data['data'],
          );
          showModalBottomSheet(
            context: context,
            builder: (context) {
              MasterCrudModel.patch('/notifications/${data['id']}', {}).then((
                value,
              ) {
                if (value != null) {
                  updateLine(value);
                }
              });
              return SingleChildScrollView(
                child: ListTile(
                  title: Text(
                    "${notification['title']}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    child: HtmlWidget("${notification['message']}"),
                  ),
                ),
              );
            },
          );
        },
      );
    } else {
      return Container();
    }
  }
}
