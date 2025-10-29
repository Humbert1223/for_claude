import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:novacole/models/master_crud_model.dart';
import 'package:novacole/models/user_model.dart';

class ModelFormInputMultiSelect extends StatefulWidget {
  final Map<String, dynamic> item;
  final dynamic initialValue;
  final Function? onChange;
  final String? isRequired;

  const ModelFormInputMultiSelect({
    super.key,
    required this.item,
    this.initialValue,
    this.onChange,
    this.isRequired,
  });

  @override
  State createState() => _ModelFormInputMultiSelectState();
}

class _ModelFormInputMultiSelectState
    extends State<ModelFormInputMultiSelect> {
  List<(String, dynamic)> _value = [];
  UserModel? _user;
  List _options = [];
  bool _loadingOption = true;
  Timer? _debounce;
  final TextEditingController _searchController = TextEditingController();

  bool get _isResourceType => [
    'selectresource',
    'resource',
    'multiresource',
  ].contains(widget.item['type']);

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeUser() async {
    try {
      final user = await UserModel.fromLocalStorage();
      if (!mounted) return;

      setState(() {
        _user = user;
        _options = widget.item['options'] ?? [];
      });

      final initialValues = List.from(
        widget.item['value'] ?? widget.initialValue ?? [],
      );

      if (_isResourceType) {
        await _loadResourceOptions();
        _setInitialValues(initialValues);
      } else {
        if (mounted) {
          setState(() => _loadingOption = false);
          _setInitialValues(initialValues);
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Erreur initialisation: $e');
      if (mounted) setState(() => _loadingOption = false);
    }
  }

  void _setInitialValues(List initialValues) {
    if (initialValues.isEmpty || _options.isEmpty) return;

    final selectedItems = <(String, dynamic)>[];

    for (final value in initialValues) {
      final option = _options.firstWhere(
            (opt) => (opt['value'] ?? opt) == value,
        orElse: () => <String, dynamic>{},
      );

      if (option.isNotEmpty) {
        final label = (option['label'] ?? option).toString();
        selectedItems.add((label, value));
      } else {
        selectedItems.add((value.toString(), value));
      }
    }

    if (mounted) setState(() => _value = selectedItems);
  }

  Future<void> _loadResourceOptions({String? searchTerm}) async {
    if (!mounted) return;

    setState(() => _loadingOption = true);

    try {
      final response = await _fetchResourceOptions(searchTerm: searchTerm);
      if (mounted && response != null) {
        setState(() {
          _options = response;
          _loadingOption = false;
        });
      }
    } catch (e) {
      debugPrint('Erreur chargement options: $e');
      if (mounted) setState(() => _loadingOption = false);
    }
  }

  Future<List<Map<String, dynamic>>?> _fetchResourceOptions({
    String? searchTerm,
  }) async {
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

  void _handleChipRemove((String, dynamic) item) {
    setState(() {
      _value = _value.where((element) => element.$2 != item.$2).toList();
    });
    widget.onChange?.call(_value.map((e) => e.$2).toList());
  }

  void _handleConfirm() {
    widget.onChange?.call(_value.map((e) => e.$2).toList());
  }

  Future<void> _openMultiSelectDialog() async {
    _searchController.clear();
    if (_isResourceType) await _loadResourceOptions();

    if (!mounted) return;

    await showModalBottomSheet(
      context: context,
      isDismissible: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SafeArea(child: _buildCustomMultiSelectDialog(ctx)),
    );
  }

  Widget _buildCustomMultiSelectDialog(BuildContext ctx) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: StatefulBuilder(
        builder: (context, setDialogState) {
          return Column(
            children: [
              _buildDialogTitle(context),
              if (_isResourceType)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Rechercher...',
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: Theme.of(context).primaryColor,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          setDialogState(() => _searchController.clear());
                          _onSearchChanged('');
                        },
                      )
                          : null,
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
                    onChanged: (value) {
                      setDialogState(() {});
                      _onSearchChanged(value);
                    },
                  ),
                ),
              const SizedBox(height: 16),
              Expanded(
                child: _loadingOption
                    ? _buildLoadingWidget(context)
                    : _options.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.inbox_outlined,
                          size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      Text(
                        'Aucun élément',
                        style: TextStyle(
                            color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _options.length,
                  itemBuilder: (context, index) {
                    final data = _options[index];
                    final value = (data['value'] ?? data);
                    final label = (data['label'] ?? data).toString();
                    final isSelected =
                    _value.any((item) => item.$2 == value);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context)
                            .primaryColor
                            .withValues(alpha:0.1)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.grey[200]!,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: CheckboxListTile(
                        title: Text(
                          label,
                          style: TextStyle(
                            fontSize: 14,
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.color,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        value: isSelected,
                        activeColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        onChanged: (bool? checked) {
                          setDialogState(() {
                            if (checked == true) {
                              _value.add((label, value));
                            } else {
                              _value = _value
                                  .where((item) => item.$2 != value)
                                  .toList();
                            }
                          });
                          setState(() {});
                        },
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha:0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                        child: const Text('Annuler'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          _handleConfirm();
                          Navigator.of(ctx).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Confirmer (${_value.length})',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildMultiSelect(context);
  }

  Widget _buildLoadingWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            strokeWidth: 2,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 12),
          Text(
            'Chargement...',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildMultiSelect(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey[50],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap:
          widget.item['disabled'] == true ? null : _openMultiSelectDialog,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.item['placeholder'] ?? widget.item['name'],
                        style: TextStyle(
                          fontSize: 15,
                          color: _value.isEmpty
                              ? Colors.grey[600]
                              : Theme.of(context).textTheme.bodyLarge?.color,
                          fontWeight: _value.isEmpty
                              ? FontWeight.normal
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down_rounded,
                      color: Theme.of(context).primaryColor,
                    ),
                  ],
                ),
                if (_value.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _value.map((item) {
                      return Chip(
                        label: Text(item.$1),
                        onDeleted: widget.item['disabled'] == true
                            ? null
                            : () => _handleChipRemove(item),
                        deleteIcon:
                        const Icon(Icons.close_rounded, size: 18),
                        backgroundColor: Theme.of(context)
                            .primaryColor
                            .withValues(alpha:0.15),
                        labelStyle: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: Theme.of(context)
                                .primaryColor
                                .withValues(alpha:0.3),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDialogTitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
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
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Sélectionner les éléments',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}