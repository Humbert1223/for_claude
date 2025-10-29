import 'package:flutter/material.dart';
import 'package:novacole/components/tag_widget.dart';
import 'package:novacole/utils/tools.dart';

class OperationEntryWidget extends StatefulWidget {
  final String? title;
  final String? date;
  final num? amount;
  final num? payment;
  final bool? balanced;

  const OperationEntryWidget({
    super.key,
    required this.title,
    this.date,
    required this.amount,
    this.payment,
    this.balanced = false,
  });

  @override
  OperationEntryWidgetState createState() {
    return OperationEntryWidgetState();
  }
}

class OperationEntryWidgetState extends State<OperationEntryWidget> {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            widget.title ?? '',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Text(
          "Date: ${NovaTools.dateFormat(widget.date)}",
          style: const TextStyle(fontSize: 14),
        ),
        Text(
          "Payé: ${currency(widget.payment)}",
          style: const TextStyle(fontSize: 14),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Montant: ${currency(widget.amount)}",
              style: const TextStyle(fontSize: 14),
            ),
            widget.balanced == true
                ? const TagWidget(
                    title: Text(
                      'Soldé',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.white,
                      ),
                    ),
                  )
                : const TagWidget(
                    title: Text(
                      'Non soldé',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.white,
                      ),
                    ),
                    color: Colors.red,
                  ),
          ],
        ),
      ],
    );
  }
}
