import 'package:flutter/material.dart';

class ModelFormInputTime extends StatefulWidget {
  final Map<String, dynamic> item;
  final dynamic initialValue;
  final Function? onChange;
  final String? isRequired;

  const ModelFormInputTime({
    super.key,
    required this.item,
    this.initialValue,
    this.onChange,
    this.isRequired,
  });

  @override
  State createState() => ModelFormInputTimeState();
}

class ModelFormInputTimeState extends State<ModelFormInputTime> {
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
          label: Text(widget.item['name']),
          hintText: widget.item['placeholder'] ?? widget.item['name'],
          prefixIcon: Icon(
            Icons.access_time_rounded,
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
          final pickedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(
                    primary: Theme.of(context).primaryColor,
                  ),
                ),
                child: child!,
              );
            },
          );

          if (pickedTime != null) {
            final hour = pickedTime.hour.toString().padLeft(2, '0');
            final minute = pickedTime.minute.toString().padLeft(2, '0');
            final value = '$hour:$minute';
            setState(() => _controller.text = value);
            widget.onChange?.call(_controller.text);
          }
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