import 'package:flutter/material.dart';
import 'package:novacole/components/loading_indicator.dart';
import 'package:novacole/hive/mark.dart';
import 'package:novacole/models/user_model.dart';
import 'package:novacole/services/mark_sync_service.dart';
import 'package:novacole/utils/hive-service.dart';

class HomeUnsyncedMarkWidget extends StatefulWidget {
  const HomeUnsyncedMarkWidget({super.key});

  @override
  HomeUnsyncedMarkWidgetState createState() {
    return HomeUnsyncedMarkWidgetState();
  }
}

class HomeUnsyncedMarkWidgetState extends State<HomeUnsyncedMarkWidget> {
  UserModel? user;
  bool syncing = false;
  int count = 0;

  @override
  void initState() {
    UserModel.fromLocalStorage().then((u) {
      setState(() {
        user = u;
      });
      if (u != null) {
        getMarkCount(u).then((marks) {
          setState(() {
            count = marks.length;
          });
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return count > 0
        ? Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 15.0,
                horizontal: 20,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("Vous avez "),
                      Text(
                        "$count",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      Text(" note(s) non synchrorisées"),
                    ],
                  ),
                  syncing
                      ? LoadingIndicator(
                          type: LoadingIndicatorType.inkDrop,
                          size: 30,
                        )
                      : IconButton(
                          onPressed: () async {
                            setState(() {
                              syncing = true;
                            });
                            try {
                              await MarkSyncService.syncAllNotesToApi();
                              setState(() async {
                                count = (await getMarkCount(user!)).length;
                              });
                            } finally {
                              setState(() {
                                syncing = false;
                              });
                            }
                          },
                          icon: Icon(
                            Icons.cloud_upload_outlined,
                            color: Theme.of(context).primaryColor,
                            size: 30,
                          ),
                        ),
                ],
              ),
            ),
          )
        : Container();
  }

  Future<List<Mark>> getMarkCount(UserModel u) async {
    return (await HiveService.marksBox(u)).values
        .where((mark) => mark.isSynced != false && mark.remoteId == null)
        .toList();
  }
}
