import 'package:flutter/material.dart';

class ModelFormInputBool extends StatefulWidget {
  final Map<String, dynamic> item;
  final Function? onChange;
  final bool? showLabel;

  const ModelFormInputBool({
    super.key,
    required this.item,
    this.onChange,
    this.showLabel = true,
  });

  @override
  State createState() => _ModelFormInputBoolState();
}

class _ModelFormInputBoolState extends State<ModelFormInputBool> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (widget.showLabel == true)
            Expanded(
              child: Text(
                widget.item['name'],
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          Switch(
            key: ObjectKey(widget.item['field']),
            value: widget.item['value'] ?? false,
            onChanged: (bool value) {
              widget.onChange?.call(value);
            },
            activeThumbColor: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }
}