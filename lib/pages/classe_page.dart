import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:novacole/components/data_models/default_data_grid.dart';
import 'package:novacole/controllers/auth_controller.dart';
import 'package:novacole/models/user_model.dart';
import 'package:novacole/pages/classe_details.dart';
import 'package:novacole/utils/constants.dart';
import 'package:novacole/utils/permission_utils.dart';

class ClasseListPage extends StatelessWidget {
  const ClasseListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultDataGrid(
      itemBuilder: (classe) {
        return ClasseInfoWidget(classe: classe);
      },
      dataModel: 'classe',
      paginate: PaginationValue.paginated,
      title: 'Classes scolaires',
      canEdit: (data) => false,
      canDelete: (data) => false,
      optionVisible: false,
      canAdd: false,
      onItemTap: (classe, updateLine) {
        final authController = Get.find<AuthController>();
        if (authController.currentUser.value!.hasPermissionSafe(
          PermissionName.view(Entity.classe),
        )) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return ClasseDetails(classe: classe);
              },
            ),
          );
        }
      },
    );
  }
}

class ClasseInfoWidget extends StatelessWidget {
  final Map<String, dynamic> classe;

  const ClasseInfoWidget({super.key, required this.classe});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${classe['name']} (Niveau ${classe['level']['name']})",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
            fontSize: 16,
          ),
        ),
        Text(
          'Titulaire : ${classe['titulaire_full_name'] ?? '-'}',
          style: const TextStyle(fontSize: 13),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Effectif : ${classe['effectif']}',
                style: const TextStyle(fontSize: 13),
              ),
              Text(
                'Capacité : ${classe['capacity'] ?? '-'}',
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
