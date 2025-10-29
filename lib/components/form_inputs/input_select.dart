import 'dart:async';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:novacole/models/master_crud_model.dart';
import 'package:novacole/models/user_model.dart';

class ModelFormInputSelect extends StatefulWidget {
  final Map<String, dynamic> item;
  final dynamic initialValue;
  final TextStyle? decorationTextStyle;
  final Function? onChange;
  final String? isRequired;
  final bool? showPrefix;

  const ModelFormInputSelect({
    super.key,
    required this.item,
    this.initialValue,
    this.onChange,
    this.isRequired,
    this.decorationTextStyle,
    this.showPrefix = true,
  });

  @override
  State createState() => _ModelFormInputSelectState();
}

class _ModelFormInputSelectState extends State<ModelFormInputSelect> {
  (String?, dynamic)? _value;
  UserModel? _user;
  List _options = [];
  Timer? _debounce;

  bool get _isResourceType => [
    'selectresource',
    'resource',
    'multiresource',
  ].contains(widget.item['type']);

  bool get _isStaticType =>
      ['select', 'radio', 'checkbox'].contains(widget.item['type']);

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _initializeUser() async {
    try {
      final user = await UserModel.fromLocalStorage();
      if (!mounted) return;

      setState(() => _user = user);
      await _loadInitialValue();
    } catch (e) {
      if (kDebugMode) debugPrint('Erreur initialisation: $e');
    }
  }

  Future<void> _loadInitialValue() async {
    final value =
        widget.item['value'] ?? widget.initialValue ?? widget.item['default'];

    if (_isResourceType) {
      await _loadResourceOptions();
      _setSelectedValue(value);
    } else if (_isStaticType) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        setState(() => _options = List.from(widget.item['options'] ?? []));
        _setSelectedValue(value);
      }
    }
  }

  void _setSelectedValue(dynamic value) {
    if (value == null || _options.isEmpty) return;

    final selected = _options.firstWhereOrNull((opt) => opt['value'] == value);

    if (mounted && selected != null) {
      setState(() => _value = (selected['label'], value));
    }
  }

  Future<void> _loadResourceOptions({String? searchTerm}) async {
    if (!mounted) return;
    try {
      final options = await _fetchResourceOptions(searchTerm: searchTerm);
      if (mounted && options != null) {
        setState(() => _options = options);
      }
    } catch (e) {
      debugPrint('Erreur chargement options: $e');
    }
  }

  Future<List?> _fetchResourceOptions({String? searchTerm}) async {
    final filters = _buildFilters();

    if (widget.initialValue != null) {
      filters.add({
        'field': 'id',
        'operator': 'in',
        'coordinator': 'or',
        'value': (widget.initialValue is List)
            ? widget.initialValue
            : [widget.initialValue],
      });
    }

    final data = {
      'filters': filters,
      'order_by': widget.item['order_by'] ?? 'created_at',
      'order_direction': widget.item['order_direction'] ?? 'ASC',
    };

    if (searchTerm != null && searchTerm.isNotEmpty) {
      data['term'] = searchTerm;
    }

    return await MasterCrudModel.load(
      '/metamorph/resources/entity/${widget.item['entity']}?paginate=0',
      data: data,
    );
  }

  List _buildFilters() {
    return List.from(widget.item['filters'] ?? []).map((filter) {
      filter['group'] = 'and_resourceFilterGroup';
      if (filter['value'] == '#user_academic') {
        filter['value'] = _user?.academic;
      }
      if (filter['value'] == '#user_school') {
        filter['value'] = _user?.school;
      }
      return filter;
    }).toList();
  }

  void _onSearchChanged(String searchTerm) {
    if (!_isResourceType) return;

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _loadResourceOptions(searchTerm: searchTerm);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8.0),
      child: _buildDropdown(context),
    );
  }

  Widget _buildLoadingWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Chargement...',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(BuildContext context) {
    return DropdownSearch<(String?, dynamic)>(
      key: ObjectKey(widget.item['field']),
      enabled: widget.item['disabled'] != true,
      selectedItem: _value,
      clickProps: ClickProps(borderRadius: BorderRadius.circular(16)),
      items: (filter, infinite) => _options.map((dynamic data) {
        return ((data['label'] ?? data).toString(), (data['value'] ?? data));
      }).toList(),
      compareFn: (a, b) => a.$2 == b.$2,
      popupProps: PopupProps.modalBottomSheet(
        title: _buildDialogTitle(context),
        modalBottomSheetProps: ModalBottomSheetProps(
          backgroundColor: Colors.white,
          barrierDismissible: false,
          clipBehavior: Clip.antiAlias,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
        ),
        showSearchBox: _isResourceType,
        searchFieldProps: _isResourceType
            ? TextFieldProps(
          decoration: InputDecoration(
            hintText: 'Rechercher...',
            prefixIcon: Icon(
              Icons.search_rounded,
              color: Theme.of(context).primaryColor,
            ),
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          onChanged: _onSearchChanged,
        )
            : const TextFieldProps(),
        emptyBuilder: (ctx, vl) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.inbox_outlined, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 12),
              Text(
                'Aucun élément',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        ),
        itemBuilder: _buildItemWidget,
        loadingBuilder: (ctx, txt) => _buildLoadingWidget(context),
        fit: FlexFit.loose,
      ),
      dropdownBuilder: (ctx, selectedItem) => Text(
        selectedItem?.$1 ?? '',
        style: widget.decorationTextStyle ??
            const TextStyle(overflow: TextOverflow.ellipsis, fontSize: 15),
      ),
      decoratorProps: DropDownDecoratorProps(
        decoration: InputDecoration(
          label: Text(
            widget.item['name'],
            style: widget.decorationTextStyle ??
                const TextStyle(overflow: TextOverflow.ellipsis, fontSize: 15),
          ),
          prefixIcon: widget.showPrefix == true
              ? Icon(
            Icons.playlist_add_check_rounded,
            color: Theme.of(context).primaryColor,
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
        ),
      ),
      onChanged: _handleValueChange,
      validator: _validateValue,
    );
  }

  Widget _buildDialogTitle(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.item['name'],
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemWidget(
      BuildContext ctx,
      (String?, dynamic) value,
      bool isDisabled,
      bool isSelected,
      ) {
    final isCurrentValue = value.$2 == _value?.$2;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isCurrentValue
            ? Theme.of(context).primaryColor.withValues(alpha:0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentValue
              ? Theme.of(context).primaryColor
              : Colors.grey[200]!,
          width: isCurrentValue ? 2 : 1,
        ),
      ),
      child: ListTile(
        title: Text(
          value.$1 ?? '',
          style: TextStyle(
            fontSize: 14,
            fontWeight: isCurrentValue ? FontWeight.w600 : FontWeight.normal,
            color: isCurrentValue
                ? Theme.of(context).primaryColor
                : Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        trailing: Icon(
          isCurrentValue
              ? Icons.check_circle_rounded
              : Icons.radio_button_unchecked_rounded,
          color: isCurrentValue
              ? Theme.of(context).primaryColor
              : Colors.grey[400],
          size: 24,
        ),
      ),
    );
  }

  void _handleValueChange((String?, dynamic)? value) {
    setState(() => _value = value);
    widget.onChange?.call(value?.$2);
  }

  String? _validateValue((String?, dynamic)? value) {
    if (widget.item.containsKey('validator') &&
        widget.item['validator'] != null &&
        widget.item['validator'] is Function) {
      return widget.item['validator'](widget.item, value);
    }

    if (widget.item.containsKey('required')) {
      final isRequired = widget.item['required'] == true ||
          widget.item['required'] == 'True' ||
          widget.item['required'] == 'true';

      if (isRequired && (_value == null || _value?.$2 == null)) {
        return widget.isRequired ?? 'Ce champ est requis';
      }
    }

    return null;
  }
}