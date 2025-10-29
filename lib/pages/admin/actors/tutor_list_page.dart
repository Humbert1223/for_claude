import 'package:flutter/material.dart';
import 'package:novacole/components/data_models/default_data_grid.dart';
import 'package:novacole/components/model_photo_widget.dart';
import 'package:novacole/models/user_model.dart';
import 'package:novacole/pages/admin/actors/tutor_details.dart';
import 'package:novacole/utils/constants.dart';
import 'package:novacole/utils/permission_utils.dart';

class TutorListPage extends StatefulWidget {
  const TutorListPage({super.key});

  @override
  TutorListPageState createState() {
    return TutorListPageState();
  }
}

class TutorListPageState extends State<TutorListPage> {
  UserModel? user;

  @override
  void initState() {
    UserModel.fromLocalStorage().then(
      (value) {
        setState(() {
          user = value;
        });
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Container();
    } else {
      return DefaultDataGrid(
        itemBuilder: (tutor) {
          return TutorInfoWidget(tutor: tutor);
        },
        dataModel: 'tutor',
        paginate: PaginationValue.paginated,
        title: 'Tuteurs',
        query: {'order_by': 'last_name'},
        data: {
          'filters': [
            {
              'field': 'students.current_school_id',
              'operator': '=',
              'value': user?.school
            },
          ],
        },
        canDelete: (data) => false,
        onItemTap: (tutor, updateLine) {
          if(user!.hasPermissionSafe(PermissionName.view(Entity.tutor))){
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return TutorDetails(tutor: tutor);
            }));
          }
        },
      );
    }
  }
}
class TutorInfoWidget extends StatelessWidget {
  final Map<String, dynamic> tutor;
  const TutorInfoWidget({super.key, required this.tutor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ModelPhotoWidget(
          model: tutor,
          width: 60,
          height: 60,
          editIconSize: 9.0,
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width - 185,
              child: Text(
                "${tutor['full_name']}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            Text(
              'Tél : ${tutor['phone'] ?? '-'}',
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
            Text(
              '${tutor['address']}',
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
