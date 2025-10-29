import 'package:flutter/material.dart';
import 'package:novacole/components/data_models/default_data_grid.dart';
import 'package:novacole/models/user_model.dart';

class PaymentMethodDataPage extends StatefulWidget {
  const PaymentMethodDataPage({super.key});

  @override
  PaymentMethodDataPageState createState() {
    return PaymentMethodDataPageState();
  }
}

class PaymentMethodDataPageState extends State<PaymentMethodDataPage> {
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
    return user != null
        ? DefaultDataGrid(
            itemBuilder: (method) {
              return ListTile(
                title: Text("${method['name']}"),
                subtitle: Text("N°: ${method['account_number']}"),
              );
            },
            dataModel: 'payment_method',
            paginate: PaginationValue.none,
            title: 'Moyens de paiement',
          )
        : Container();
  }
}
