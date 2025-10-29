import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ModelFormInputText extends StatefulWidget {
  final Map<String, dynamic> item;
  final dynamic initialValue;
  final Function? onChange;
  final String? isRequired;
  final bool? showPrefix;

  const ModelFormInputText({
    super.key,
    required this.item,
    this.initialValue,
    this.onChange,
    this.isRequired,
    this.showPrefix = true,
  });

  @override
  State createState() => _ModelFormInputTextState();
}

class _ModelFormInputTextState extends State<ModelFormInputText> {
  dynamic _value;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _value = widget.item['value'];
  }

  String? _validateEmail(item, String value) {
    if (value.isEmpty) return null;

    const pattern =
        r"[a-zA-Z0-9+._%-+]{1,256}\@[a-zA-Z0-9][a-zA-Z0-9\-]{0,64}(\.[a-zA-Z0-9][a-zA-Z0-9\-]{0,25})+";
    final regExp = RegExp(pattern);

    return regExp.hasMatch(value) ? null : "L'e-mail n'est pas valide";
  }

  (TextInputType, Widget?, List<TextInputFormatter>?, bool) _getInputConfig() {
    TextInputType inputType = TextInputType.text;
    Widget? prefix;
    List<TextInputFormatter>? formatter;
    bool isPassword = false;

    switch (widget.item['type']) {
      case 'tel':
      case 'phone':
        inputType = TextInputType.phone;
        prefix = const Icon(Icons.phone_rounded);
        break;
      case 'email':
        inputType = TextInputType.emailAddress;
        prefix = const Icon(Icons.email_rounded);
        break;
      case 'number':
        inputType = TextInputType.number;
        prefix = const Icon(Icons.numbers_rounded);
        formatter = [
          FilteringTextInputFormatter.allow(RegExp(r'(^\d*[.,]?\d*)'))
        ];
        break;
      case 'currency':
        inputType = TextInputType.number;
        prefix = const Icon(Icons.monetization_on_rounded);
        formatter = [
          FilteringTextInputFormatter.allow(RegExp(r'(^\d*[.,]?\d*)'))
        ];
        break;
      case 'address':
        inputType = TextInputType.streetAddress;
        prefix = const Icon(Icons.location_on_rounded);
        break;
      case 'password':
        inputType = TextInputType.text;
        prefix = const Icon(Icons.lock_rounded);
        isPassword = true;
        break;
      case 'longtext':
      case 'richtext':
      case 'textarea':
        inputType = TextInputType.multiline;
        prefix = const Icon(Icons.text_fields_rounded);
        break;
      default:
        inputType = TextInputType.text;
        prefix = const Icon(Icons.text_fields_rounded);
    }

    return (inputType, prefix, formatter, isPassword);
  }

  @override
  Widget build(BuildContext context) {
    final config = _getInputConfig();
    final inputType = config.$1;
    final prefix = config.$2;
    final formatter = config.$3;
    final isPassword = config.$4;
    final isMultiline =
    ['longtext', 'textarea', 'richtext'].contains(widget.item['type']);

    return Container(
      margin: const EdgeInsets.only(top: 8.0),
      child: TextFormField(
        key: Key(widget.item['field']),
        enabled:
        widget.item['disabled'] == null || widget.item['disabled'] != true,
        keyboardType: inputType,
        initialValue: '${widget.initialValue ?? ''}',
        inputFormatters: formatter ?? [],
        maxLines: isMultiline ? 4 : 1,
        obscureText: isPassword && _obscurePassword,
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          hintText: widget.item['placeholder'] ?? widget.item['name'],
          label: Text(widget.item['name']),
          prefixIcon: widget.showPrefix == true
              ? prefix != null
              ? IconTheme(
            data: IconThemeData(
              color: Theme.of(context).primaryColor,
            ),
            child: prefix,
          )
              : null
              : null,
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_rounded
                  : Icons.visibility_off_rounded,
              color: Theme.of(context).primaryColor,
            ),
            onPressed: () {
              setState(() => _obscurePassword = !_obscurePassword);
            },
          )
              : widget.item['type'] == 'currency'
              ? Padding(
            padding: const EdgeInsets.only(right: 12, top: 14),
            child: Text(
              'F CFA',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
              : null,
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
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: isMultiline ? 16 : 14,
          ),
        ),
        onChanged: (String value) {
          _value = value;
          widget.onChange?.call(value);
        },
        validator: (value) {
          if (widget.item.containsKey('validator') &&
              widget.item['validator'] != null &&
              widget.item['validator'] is Function) {
            return widget.item['validator'](widget.item, value);
          }

          if (widget.item['type'] == 'email') {
            return _validateEmail(widget.item, value!);
          }

          if (widget.item.containsKey('required')) {
            if ((widget.item['required'] == true ||
                widget.item['required'] == 'True' ||
                widget.item['required'] == 'true') &&
                (_value == null || _value == '')) {
              return widget.isRequired ?? 'Ce champ est requis';
            }
          }

          return null;
        },
      ),
    );
  }
}