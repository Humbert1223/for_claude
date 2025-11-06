import 'package:flutter/material.dart';
import 'package:novacole/components/data_models/default_data_grid.dart';
import 'package:novacole/controllers/auth_provider.dart';
import 'package:novacole/models/user_model.dart';
import 'package:novacole/pages/admin/finances/components/operation_entry_widget.dart';
import 'package:novacole/pages/admin/finances/operation_details.dart';
import 'package:novacole/utils/constants.dart';
import 'package:novacole/utils/permission_utils.dart';

class RegistrationFeesPage extends StatefulWidget {
  const RegistrationFeesPage({super.key});

  @override
  RegistrationFeesPageState createState() {
    return RegistrationFeesPageState();
  }
}

class RegistrationFeesPageState extends State<RegistrationFeesPage> {
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
      itemBuilder: (operation) {
        return OperationEntryWidget(
          title: operation['name'],
          balanced: operation['balanced'],
          amount: operation['amount'] * 1.0,
          payment: operation['total_payment'] * 1.0,
          date: operation['operation_date'],
        );
      },
      dataModel: 'operation',
      paginate: PaginationValue.paginated,
      title: "Frais d'inscription",
      data: {
        'relations': ['payments'],
        'filters': [
          {
            'field': 'operation_type',
            'operator': '=',
            'value': 'registration_fees'
          }
        ],
      },
      canAdd: false,
      canEdit: (item) => false,
      onItemTap: (item, updateLine) {
        if(authProvider.currentUser.hasPermissionSafe(PermissionName.view(Entity.operation))){
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return OperationDetailsPage(operation: item);
          }));
        }
      },
    );
  }
}
