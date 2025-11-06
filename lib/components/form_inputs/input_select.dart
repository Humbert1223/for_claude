import 'dart:async';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:novacole/core/extensions/list_extension.dart';
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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Chargement...',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return DropdownSearch<(String?, dynamic)>(
      key: ObjectKey(widget.item['field']),
      enabled: widget.item['disabled'] != true,
      selectedItem: _value,
      clickProps: ClickProps(borderRadius: BorderRadius.circular(12)),
      items: (filter, infinite) => _options.map((dynamic data) {
        return ((data['label'] ?? data).toString(), (data['value'] ?? data));
      }).toList(),
      compareFn: (a, b) => a.$2 == b.$2,
      popupProps: PopupProps.modalBottomSheet(
        title: _buildDialogTitle(context),
        modalBottomSheetProps: ModalBottomSheetProps(
          backgroundColor: isDark ? colorScheme.surface : Colors.white,
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
            hintStyle: TextStyle(
              color: colorScheme.onSurface.withValues(alpha:0.5),
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: colorScheme.primary,
            ),
            filled: true,
            fillColor: isDark
                ? colorScheme.surfaceContainerHighest.withValues(alpha:0.3)
                : colorScheme.surfaceContainerHighest.withValues(alpha:0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
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
              Icon(
                Icons.inbox_outlined,
                size: 56,
                color: colorScheme.onSurface.withValues(alpha:0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'Aucun élément',
                style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha:0.6),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
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
            TextStyle(
              overflow: TextOverflow.ellipsis,
              fontSize: 15,
              color: colorScheme.onSurface,
            ),
      ),
      decoratorProps: DropDownDecoratorProps(
        decoration: InputDecoration(
          label: Text(
            widget.item['name'],
            style: widget.decorationTextStyle ??
                TextStyle(
                  overflow: TextOverflow.ellipsis,
                  fontSize: 15,
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          prefixIcon: widget.showPrefix == true
              ? Icon(
            Icons.playlist_add_check_rounded,
            color: colorScheme.primary,
          )
              : null,
          filled: true,
          fillColor: isDark
              ? colorScheme.surfaceContainerHighest.withValues(alpha:0.3)
              : colorScheme.surfaceContainerHighest.withValues(alpha:0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: colorScheme.outline.withValues(alpha:0.2),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: colorScheme.outline.withValues(alpha:0.2),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: colorScheme.primary,
              width: 2,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: colorScheme.outline.withValues(alpha:0.1),
            ),
          ),
        ),
      ),
      onChanged: _handleValueChange,
      validator: _validateValue,
    );
  }

  Widget _buildDialogTitle(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withValues(alpha:0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withValues(alpha:0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.item['name'],
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
              letterSpacing: -0.3,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final isCurrentValue = value.$2 == _value?.$2;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isCurrentValue
            ? colorScheme.primary.withValues(alpha:isDark ? 0.2 : 0.1)
            : isDark
            ? colorScheme.surface
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentValue
              ? colorScheme.primary
              : colorScheme.outline.withValues(alpha:isDark ? 0.2 : 0.15),
          width: isCurrentValue ? 2 : 1,
        ),
        boxShadow: isCurrentValue
            ? [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha:0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ]
            : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
        title: Text(
          value.$1 ?? '',
          style: TextStyle(
            fontSize: 14,
            fontWeight: isCurrentValue ? FontWeight.w600 : FontWeight.w500,
            color: isCurrentValue
                ? colorScheme.primary
                : colorScheme.onSurface,
            letterSpacing: -0.2,
          ),
        ),
        trailing: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            isCurrentValue
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            color: isCurrentValue
                ? colorScheme.primary
                : colorScheme.onSurface.withValues(alpha:0.4),
            size: 24,
          ),
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