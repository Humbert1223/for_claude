import 'package:flutter/material.dart';
import 'package:novacole/components/data_models/default_data_grid.dart';
import 'package:novacole/controllers/auth_provider.dart';
import 'package:novacole/models/user_model.dart';
import 'package:novacole/pages/admin/finances/components/operation_entry_widget.dart';
import 'package:novacole/pages/admin/finances/operation_details.dart';
import 'package:novacole/utils/constants.dart';
import 'package:novacole/utils/permission_utils.dart';

class OtherOutgoingPage extends StatefulWidget {
  const OtherOutgoingPage({super.key});

  @override
  OtherOutgoingPageState createState() {
    return OtherOutgoingPageState();
  }
}

class OtherOutgoingPageState extends State<OtherOutgoingPage> {
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
      title: "Autres charges",
      query: {'order_by': 'created_at', 'order_direction': 'DESC'},
      data: {
        'relations': ['payments'],
        'filters': [
          {
            'field': 'operation_type',
            'operator': 'notin',
            'value': ['salary', 'school_fees', 'registration_fees']
          },
          {'field': 'position', 'operator': '=', 'value': 'outgoing'}
        ],
      },
      formDefaultData: {'position': 'outgoing', 'operation_type': 'other_outgoing'},
      formInputsMutator: (inputs, datum) {
        inputs = inputs.map((el) {
          if(el['field'] == 'expense_id'){
            el['hidden'] = false;
          }
          if (['position', 'partner_id'].contains(el['field'])) {
            el['hidden'] = true;
          }
          if(el['field'] == 'operation_type'){
            el['options'] = List.from(el['options']).where((option){
              return option['orientation'] == 'outgoing'
                  && !['salary'].contains(option['value']);
            }).toList();
          }
          return el;
        }).toList();
        return inputs;
      },
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
