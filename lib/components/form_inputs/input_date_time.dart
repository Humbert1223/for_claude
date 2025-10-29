import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';

class ModelFormInputDateTime extends StatefulWidget {
  final Map<String, dynamic> item;
  final dynamic initialValue;
  final Function onChange;
  final String? isRequired;

  const ModelFormInputDateTime({
    super.key,
    required this.item,
    this.initialValue,
    required this.onChange,
    this.isRequired,
  });

  @override
  State createState() => ModelFormInputDateTimeState();
}

class ModelFormInputDateTimeState extends State<ModelFormInputDateTime> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.item['value'] ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8.0),
      child: TextFormField(
        key: Key(widget.item['field']),
        controller: _controller,
        readOnly: true,
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          label: Text(widget.item['placeholder'] ?? widget.item['name']),
          hintText: widget.item['placeholder'] ?? widget.item['name'],
          prefixIcon: Icon(
            Icons.date_range_rounded,
            color: Theme.of(context).primaryColor,
          ),
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 2,
            ),
          ),
        ),
        onTap: () async {
          final picked = await DatePicker.showDateTimePicker(
            context,
            showTitleActions: true,
            minTime: DateTime.now().add(const Duration(days: -36500)),
            maxTime: DateTime.now().add(const Duration(days: 3650)),
            onConfirm: (date) {
              setState(() {
                _controller.text = DateFormat('yyyy-MM-dd HH:mm').format(date);
              });
              widget.onChange(_controller.text);
            },
            currentTime: DateTime.now(),
            locale: LocaleType.fr,
          );
        },
        validator: (value) {
          if (widget.item.containsKey('validator') &&
              widget.item['validator'] != null &&
              widget.item['validator'] is Function) {
            return widget.item['validator'](widget.item, value);
          }

          if (widget.item.containsKey('required')) {
            if ((widget.item['required'] == true ||
                widget.item['required'] == 'True' ||
                widget.item['required'] == 'true') &&
                _controller.text.isEmpty) {
              return widget.isRequired ?? 'Ce champ est requis';
            }
          }
          return null;
        },
      ),
    );
  }
}