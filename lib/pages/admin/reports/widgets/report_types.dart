enum InputFieldType { text, number, date, boolean, select, selectresource }

class ReportConfig {
  final String title;
  final String endpoint;
  final String fileName;
  final FormConfig? formConfig;

  const ReportConfig({
    required this.title,
    required this.endpoint,
    required this.fileName,
    this.formConfig,
  });
}

class FormConfig {
  final List<InputField> inputs;

  const FormConfig({
    required this.inputs,
  });
}

class InputField {
  final String field;
  final InputFieldType type;
  final String name;
  final String? entity;
  final bool required;
  final bool? hidden;
  final String description;
  final String? placeholder;
  final dynamic defaultValue;
  final ResourceFilters? resourceFilters;
  final List<SelectOption>? options;

  const InputField(  {
    required this.field,
    required this.type,
    required this.name,
    this.entity,
    this.placeholder,
    this.required = false,
    this.description = '',
    this.defaultValue,
    this.resourceFilters,
    this.options,
    this.hidden = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'field': field,
      'type': type.toString().split('.').last,
      'name': name,
      'entity': entity,
      'required': required,
      'hidden': hidden,
      'description': description,
      if (defaultValue != null) 'value': defaultValue,
      if (resourceFilters != null) 'filters': resourceFilters!.toMap(),
      if (options != null) 'options': options!.map((o) => o.toMap()).toList(),
    };
  }
}

class ResourceFilters {
  final List<FilterCriteria> filters;

  const ResourceFilters({
    required this.filters,
  });

  List<Map<String, dynamic>> toMap() {
    return filters.map((f) => f.toMap()).toList();
  }
}

class FilterCriteria {
  final String field;
  final String? operator;
  final dynamic value;

  const FilterCriteria({
    required this.field,
    required this.value,
    this.operator,
  });

  Map<String, dynamic> toMap() {
    return {
      'field': field,
      'value': value,
      'operator': operator,
    };
  }
}

class SelectOption {
  final String label;
  final dynamic value;

  const SelectOption({
    required this.label,
    required this.value,
  });

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'value': value,
    };
  }
}


dynamic parseInputValue(Map<String, dynamic> input) {
  final value = input['value'];
  final type = InputFieldType.values.firstWhere(
        (t) => t.toString() == 'InputFieldType.${input['type']}',
    orElse: () => InputFieldType.text,
  );

  switch (type) {
    case InputFieldType.number:
      return double.tryParse(value.toString()) ??
          int.tryParse(value.toString());
    case InputFieldType.boolean:
      return value == true || value.toString().toLowerCase() == 'true';
    case InputFieldType.date:
      return value;
    default:
      return value;
  }
}
