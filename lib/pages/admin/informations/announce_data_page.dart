import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:novacole/components/data_models/default_data_grid.dart';
import 'package:novacole/models/user_model.dart';
import 'package:novacole/pages/announces/announces_details_pages.dart';
import 'package:novacole/utils/tools.dart';

class AnnounceDataPage extends StatefulWidget {
  const AnnounceDataPage({super.key});

  @override
  AnnounceDataPageState createState() {
    return AnnounceDataPageState();
  }
}

class AnnounceDataPageState extends State<AnnounceDataPage> {
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
            itemBuilder: (post) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Modifié le: ${NovaTools.dateFormat(post['updated_at'])}"),
                      Text("Status: ${(post['status']).toString().tr()}")
                    ],
                  ),
                ],
              );
            },
            dataModel: 'post',
            paginate: PaginationValue.paginated,
            title: 'Annonces',
            data: {
              'filters': [
                {'field': 'school_id', 'operator': '=', 'value': user?.school}
              ],
            },
            onItemTap: (post, updateLine) {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return AnnounceDetailsPage(announce: post);
              }));
            },
          )
        : Container();
  }
}
