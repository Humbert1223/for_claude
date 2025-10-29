import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:novacole/components/empty_page.dart';
import 'package:novacole/components/loading_indicator.dart';
import 'package:novacole/models/master_crud_model.dart';
import 'package:novacole/pages/components/commons/offline_payment_method.dart';
import 'package:novacole/utils/tools.dart';

class StudentFeesList extends StatefulWidget {
  final Map<String, dynamic> repartition;

  const StudentFeesList({super.key, required this.repartition});

  @override
  StudentFeesListState createState() {
    return StudentFeesListState();
  }
}

class StudentFeesListState extends State<StudentFeesList> {
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
    return FutureBuilder(
      future: MasterCrudModel('operation').search(
        paginate: '0',
        filters: [
          {'field': 'partner_id', 'value': widget.repartition['student_id']},
          {'field': 'balanced', 'value': false},
        ],
      ),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const LoadingIndicator();
        } else {
          if (snap.hasData && List.from(snap.data).isNotEmpty) {
            List<Map<String, dynamic>> fees =
                List<Map<String, dynamic>>.from(snap.data).where((fee) {
                  return fee['net_amount'] > fee['total_payment'];
                }).toList();
            return SingleChildScrollView(
              child: Column(
                children: fees.map<Widget>((fee) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 5.0),
                    child: ListTile(
                      subtitle: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Date: ${DateFormat('dd MMM yyyy').format(DateTime.parse(fee['operation_date']))}",
                          ),
                          Text("Total : ${currency(fee['net_amount'])}"),
                          Text(
                            "A payer : ${currency(fee['net_amount'] - fee['total_payment'])}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      title: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: Text(
                          fee['operation_type'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ).tr(),
                      ),
                      trailing: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return OfflinePaymentMethod(operation: fee);
                              },
                            ),
                          );
                        },
                        child: const Text("Payer"),
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          } else {
            return InkWell(
              child: const EmptyPage(),
              onTap: () {
                setState(() {});
              },
            );
          }
        }
      },
    );
  }
}
