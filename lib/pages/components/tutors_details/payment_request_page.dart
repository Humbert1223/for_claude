import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:novacole/components/data_models/default_data_grid.dart';
import 'package:novacole/components/tag_widget.dart';
import 'package:novacole/models/user_model.dart';
import 'package:novacole/utils/tools.dart';

class TutorPaymentRequestPage extends StatefulWidget {
  const TutorPaymentRequestPage({super.key});

  @override
  TutorPaymentRequestPageState createState() {
    return TutorPaymentRequestPageState();
  }
}

class TutorPaymentRequestPageState extends State<TutorPaymentRequestPage> {
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
          Color tagColor = Colors.amber;
          if (data['status'] == 'pending') {
            tagColor = Colors.amber;
          } else if (data['status'] == 'accepted') {
            tagColor = Colors.green;
          } else if (data['status'] == 'rejected') {
            tagColor = Colors.red;
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${data['method_name']}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "N°${data['reference']}",
                    style: const TextStyle(fontSize: 15),
                  ),
                  Text(
                    currency(data['amount']),
                    style: const TextStyle(fontSize: 15),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    NovaTools.dateFormat(data['payment_date']),
                    style: const TextStyle(fontSize: 15),
                  ),
                  TagWidget(
                    title: Text(
                      data['status'].toString().tr(),
                      style: const TextStyle(color: Colors.white),
                    ),
                    color: tagColor,
                  )
                ],
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
        dataModel: 'payment_request',
        paginate: PaginationValue.paginated,
        title: 'Mes demandes de paiement',
        canAdd: false,
        canDelete: (item) {
          if (item['status'] == 'pending') {
            return true;
          }
          return false;
        },
        canEdit: (item) {
          if (item['status'] == 'pending') {
            return true;
          }
          return false;
        },
        onBack: () {
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/home', (route) => false);
        },
        formInputsMutator: (inputs, data) {
          inputs = inputs.map<Map<String, dynamic>>((input) {
            if (input['field'] == 'operation_id') {
              input['hidden'] = true;
            }
            if (input['field'] == 'partner_id') {
              input['hidden'] = true;
            }
            if (input['field'] == 'position') {
              input['hidden'] = true;
            }
            return input;
          }).toList();
          return inputs;
        },
      );
    } else {
      return Container();
    }
  }
}
