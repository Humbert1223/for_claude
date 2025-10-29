import 'package:flutter/material.dart';
import 'package:novacole/components/data_models/default_data_grid.dart';
import 'package:novacole/models/user_model.dart';
import 'package:novacole/pages/admin/finances/components/operation_entry_widget.dart';
import 'package:novacole/pages/admin/finances/operation_details.dart';
import 'package:novacole/utils/constants.dart';
import 'package:novacole/utils/permission_utils.dart';

class SalaryFeesPage extends StatefulWidget {
  const SalaryFeesPage({super.key});

  @override
  SalaryFeesPageState createState() {
    return SalaryFeesPageState();
  }
}

class SalaryFeesPageState extends State<SalaryFeesPage> {
  UserModel? currentUser;

  @override
  void initState() {
    super.initState();
    UserModel.fromLocalStorage().then((u) {
      setState(() {
        currentUser = u;
      });
    });
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
      title: "Salaires",
      query: {'order_by': 'created_at', 'order_direction': 'DESC'},
      data: {
        'relations': ['payments'],
        'filters': [
          {
            'field': 'operation_type',
            'operator': '=',
            'value': 'salary',
          }
        ],
      },
      formDefaultData: {
        'operation_type': 'salary',
        'position': 'outgoing',
        'partner_entity': 'user',
      },
      formInputsMutator: (inputs, datum) {
        inputs = inputs.map((el) {
          if (['operation_type', 'position'].contains(el['field'])) {
            el['hidden'] = true;
          }
          if (el['field'] == 'name') {
            el['hidden'] = false;
          }
          if (el['field'] == 'partner_id') {
            el['type'] = 'selectresource';
            el['entity'] = 'user';
            el['hidden'] = false;
            el['filters'] = [
              {
                'field': 'schools.account_type',
                'operator': 'in',
                'value': ['admin', 'staff']
              },
              {
                'field': 'schools.school_id',
                'operator': '=',
                'value': currentUser?.school
              }
            ];
          }
          return el;
        }).toList();
        return inputs;
      },
      onItemTap: (item, updateLine) {
        if(currentUser!.hasPermissionSafe(PermissionName.view(Entity.operation))){
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return OperationDetailsPage(operation: item);
          }));
        }
      },
    );
  }
}
