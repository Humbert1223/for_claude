import 'dart:ui';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:novacole/components/app_bar_back_button.dart';
import 'package:novacole/components/data_models/default_data_form.dart';
import 'package:novacole/components/data_models/grid_filter_form.dart';
import 'package:novacole/components/loading_indicator.dart';
import 'package:novacole/components/permission_widgets.dart';
import 'package:novacole/models/master_crud_model.dart';

enum PaginationValue {
  paginated,
  none,
  infiniteScroll;

  @override
  String toString() => this == PaginationValue.none ? '0' : '1';
}

typedef DefaultGridEntry = Widget Function(Map<String, dynamic> item);

typedef DefaultGridOptions = List<Widget> Function(
    Map<String, dynamic> item,
    VoidCallback reload,
    Function(Map<String, dynamic>?) updateLine,
    );

typedef GridEntryOptionPermission = bool Function(Map<String, dynamic> item);

typedef OnItemTapCallback = void Function(
    Map<String, dynamic> item,
    Function(Map<String, dynamic>?) updateLine,
    );

class DefaultDataGrid extends StatefulWidget {
  const DefaultDataGrid({
    super.key,
    required this.itemBuilder,
    required this.dataModel,
    required this.paginate,
    required this.title,
    this.data,
    this.query,
    this.canAdd = true,
    this.canEdit,
    this.canDelete,
    this.formInputsMutator,
    this.formDefaultData,
    this.onItemTap,
    this.optionsBuilder,
    this.onBack,
    this.optionVisible = true,
    this.appBarVisible = true,
    this.onAdded,
  });

  final DefaultGridEntry itemBuilder;
  final String dataModel;
  final PaginationValue paginate;
  final String title;
  final Map<String, dynamic>? data;
  final Map<String, dynamic>? query;
  final bool canAdd;
  final GridEntryOptionPermission? canEdit;
  final GridEntryOptionPermission? canDelete;
  final InputItemMutator? formInputsMutator;
  final Map<String, dynamic>? formDefaultData;
  final OnItemTapCallback? onItemTap;
  final DefaultGridOptions? optionsBuilder;
  final VoidCallback? onBack;
  final bool optionVisible;
  final bool appBarVisible;
  final Function(Map<String, dynamic>)? onAdded;

  bool get isPaginated =>
      (paginate == PaginationValue.paginated ||
          paginate == PaginationValue.infiniteScroll);

  @override
  State<DefaultDataGrid> createState() => _DefaultDataGridState();
}

class _DefaultDataGridState extends State<DefaultDataGrid>
    with SingleTickerProviderStateMixin {
  int _currentPage = 1;
  int _perPage = 15;
  int? _total;
  int? _lastPage;

  final List<FilterRow> _filters = [];
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = false;
  bool _isLoadingMore = false;
  List<Map<String, dynamic>> _items = [];

  final ScrollController _scrollController = ScrollController();
  bool _hasMore = true;

  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  static const int _minSearchLength = 3;
  static const List<int> _perPageOptions = [
    15,
    20,
    30,
    50,
    80,
    100,
    150,
    200,
    250
  ];

  @override
  void initState() {
    super.initState();
    _loadItems();
    if (widget.paginate == PaginationValue.infiniteScroll) {
      _scrollController.addListener(_onScroll);
    }

    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.elasticOut,
    );
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _fabAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreItems();
    }
  }

  Future<void> _loadItems({bool isLoadMore = false}) async {
    if (!mounted) return;

    if (!isLoadMore) {
      setState(() {
        _isLoading = true;
        _hasMore = true;
      });
    } else {
      if (_isLoadingMore || !_hasMore) return;
      setState(() => _isLoadingMore = true);
    }

    try {
      final query = <String, dynamic>{
        ...?widget.query,
        if (_searchController.text.length >= _minSearchLength)
          'term': _searchController.text,
      };

      final mappedFilters = _filters
          .map((filter) =>
      {
        'field': filter.field.$2,
        'operator': filter.operator.$2,
        'value': filter.value.$2,
      })
          .toList();

      final result = await MasterCrudModel(widget.dataModel).search(
        paginate: widget.paginate.toString(),
        page: _currentPage,
        perPage: _perPage,
        query: query,
        filters: mappedFilters,
        data: widget.data,
      );

      if (!mounted) return;

      setState(() {
        if (result != null) {
          if (widget.isPaginated) {
            final newItems = List<Map<String, dynamic>>.from(
              result['data'] ?? [],
            );

            if (isLoadMore) {
              _items.addAll(newItems);
            } else {
              _items = newItems;
            }

            _lastPage = result['last_page'] as int?;
            _perPage = result['per_page'] as int? ?? _perPage;
            _total = result['total'] as int?;

            if (widget.paginate == PaginationValue.infiniteScroll) {
              _hasMore = _currentPage < (_lastPage ?? 0);
            }
          } else {
            _items = List<Map<String, dynamic>>.from(result ?? []);
          }
        }
        _isLoading = false;
        _isLoadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
      _showSnackBar('Erreur lors du chargement: $e', isError: true);
    }
  }

  Future<void> _loadMoreItems() async {
    if (widget.paginate != PaginationValue.infiniteScroll) return;
    if (_isLoadingMore || !_hasMore || _lastPage == null) return;
    if (_currentPage >= _lastPage!) return;

    _currentPage++;
    await _loadItems(isLoadMore: true);
  }

  void _updateLine(Map<String, dynamic>? data) {
    if (data == null || !mounted) return;

    setState(() {
      final existingIndex = _items.indexWhere((el) => el['id'] == data['id']);

      if (existingIndex != -1) {
        _items[existingIndex] = data;
      } else {
        _items.insert(0, data);
      }
    });
  }

  Future<void> _deleteItem(Map<String, dynamic> item) async {
    final confirmed = await _showDeleteConfirmation();
    if (confirmed != true) return;

    try {
      final result = await MasterCrudModel.delete(item['id'], widget.dataModel);

      if (result != null) {
        await _loadItems();
        if (mounted) {
          _showSnackBar('✓ Élément supprimé avec succès', isSuccess: true);
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Erreur lors de la suppression', isError: true);
      }
    }
  }

  Future<bool?> _showDeleteConfirmation() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) =>
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AlertDialog(
              backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28)),
              contentPadding: const EdgeInsets.all(32),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.red.shade400,
                          Colors.red.shade600,
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withValues(alpha: 0.4),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Confirmer la suppression',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Cette action est irréversible.\nÊtes-vous sûr de vouloir continuer ?',
                    style: TextStyle(
                      fontSize: 15,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            side: BorderSide(
                              color: theme.colorScheme.outline.withValues(
                                  alpha: 0.3),
                            ),
                          ),
                          child: const Text(
                            'Annuler',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Supprimer',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _showSnackBar(String message,
      {bool isError = false, bool isSuccess = false}) {
    if (!mounted) return;

    Color bgColor;
    IconData icon;

    if (isError) {
      bgColor = Colors.red.shade600;
      icon = Icons.error_outline_rounded;
    } else if (isSuccess) {
      bgColor = Colors.green.shade600;
      icon = Icons.check_circle_outline_rounded;
    } else {
      bgColor = Colors.blue.shade600;
      icon = Icons.info_outline_rounded;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _navigateToAddForm() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            DefaultDataForm(
              dataModel: widget.dataModel,
              title: widget.title,
              onSaved: (value) {
                widget.onAdded?.call(value);
                _loadItems();
              },
              inputsMutator: widget.formInputsMutator,
              defaultData: widget.formDefaultData,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 0.1);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;

          var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: offsetAnimation,
              child: child,
            ),
          );
        },
      ),
    );
  }

  void _navigateToEditForm(Map<String, dynamic> item) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            DefaultDataForm(
              dataModel: widget.dataModel,
              title: widget.title,
              data: item,
              inputsMutator: widget.formInputsMutator,
              defaultData: widget.formDefaultData,
              onSaved: (value) => _loadItems(),
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.1, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;

          var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: offsetAnimation,
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(
          0xFFF8F9FA),
      appBar: widget.appBarVisible ? _buildAppBar(theme, isDark) : null,
      body: RefreshIndicator(
        onRefresh: () async {
          _currentPage = 1;
          await _loadItems();
        },
        color: theme.colorScheme.primary,
        strokeWidth: 3,
        child: _buildBody(),
      ),
      floatingActionButton: widget.canAdd ? _buildFab(theme) : null,
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme, bool isDark) {
    return AppBar(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withValues(alpha: 0.85),
            ],
          ),
        ),
      ),
      leading: AppBarBackButton(onTap: widget.onBack),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.grid_view_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              widget.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      bottom: widget.isPaginated ? _buildAppBarBottom(theme, isDark) : null,
    );
  }

  PreferredSizeWidget _buildAppBarBottom(ThemeData theme, bool isDark) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(140),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withValues(alpha:0.0),
              Colors.black.withValues(alpha:0.05),
            ],
          ),
        ),
        child: Column(
          children: [
            // Barre de recherche avec filtres intégrés
            Container(
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha:isDark ? 0.95 : 1),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Icon(
                    Icons.search_rounded,
                    color: theme.colorScheme.primary,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.black87 : Colors.black87,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Rechercher...',
                        hintStyle: TextStyle(
                          color: Colors.black.withValues(alpha:0.4),
                          fontSize: 15,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (value) {
                        setState(() {});
                        if (value.isEmpty || value.length >= _minSearchLength) {
                          _loadItems();
                        }
                      },
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                        _loadItems();
                      },
                      icon: Icon(
                        Icons.close_rounded,
                        size: 20,
                        color: Colors.black.withValues(alpha:0.5),
                      ),
                    )
                  else
                    const SizedBox(width: 8),

                  // Divider vertical
                  Container(
                    height: 32,
                    width: 1,
                    color: theme.colorScheme.outline.withValues(alpha:0.2),
                  ),

                  // Bouton filtre
                  _buildCompactFilterButton(theme),
                ],
              ),
            ),

            // Contrôles de pagination compacts
            if (widget.paginate == PaginationValue.paginated) ...[
              const SizedBox(height: 12),
              _buildCompactPaginationRow(theme, isDark),
            ],
          ],
        ),
      ),
    );
  }

// Nouveau bouton de filtre compact
  Widget _buildCompactFilterButton(ThemeData theme) {
    final hasFilters = _filters.isNotEmpty;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: const EdgeInsets.all(8),
          child: Material(
            color: hasFilters
                ? theme.colorScheme.primary
                : theme.colorScheme.primary.withValues(alpha:0.1),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: _showFilterBottomSheet,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Icon(
                  Icons.tune_rounded,
                  color: hasFilters
                      ? Colors.white
                      : theme.colorScheme.primary,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
        if (hasFilters)
          Positioned(
            right: 2,
            top: 2,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.orange.shade500,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withValues(alpha:0.5),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                '${_filters.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

// Nouvelle ligne de pagination compacte
  Widget _buildCompactPaginationRow(ThemeData theme, bool isDark) {
    return Row(
      children: [
        // Info page actuelle
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha:isDark ? 0.95 : 1),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha:0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Page $_currentPage',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                Text(
                  ' / ${_lastPage ?? '?'}',
                  style: TextStyle(
                    color: Colors.black.withValues(alpha:0.5),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 5),
                VerticalDivider(width: 8, color: Colors.black.withValues(alpha:0.2)),
                const SizedBox(width: 5),
                Text(
                  "Total: ${_total ?? ''} ",
                  style: TextStyle(
                    color: Colors.black.withValues(alpha:0.5),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Sélecteur d'éléments par page
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha:isDark ? 0.95 : 1),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha:0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownSearch<int>(
            clickProps: ClickProps(borderRadius: BorderRadius.circular(12)),
            mode: Mode.custom,
            items: (f, cs) => _perPageOptions,
            compareFn: (item1, item2) => item1 == item2,
            selectedItem: _perPage,
            popupProps: const PopupProps.menu(
              menuProps: MenuProps(align: MenuAlign.bottomCenter),
              fit: FlexFit.loose,
            ),
            dropdownBuilder: (ctx, selectedItem) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.filter_list_rounded,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  '$selectedItem',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.expand_more_rounded,
                  size: 18,
                  color: Colors.black.withValues(alpha:0.6),
                ),
              ],
            ),
            onChanged: (value) {
              if (value != null) {
                setState(() => _perPage = value);
                _loadItems();
              }
            },
          ),
        ),

        const SizedBox(width: 8),

        // Boutons de navigation
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha:isDark ? 0.95 : 1),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha:0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCompactNavButton(
                theme: theme,
                icon: Icons.chevron_left_rounded,
                enabled: _currentPage > 1,
                onTap: () {
                  setState(() => _currentPage -= 1);
                  _loadItems();
                },
              ),
              Container(
                width: 1,
                height: 24,
                color: theme.colorScheme.outline.withValues(alpha:0.15),
              ),
              _buildCompactNavButton(
                theme: theme,
                icon: Icons.chevron_right_rounded,
                enabled: _lastPage != null && _currentPage < _lastPage!,
                onTap: () {
                  setState(() => _currentPage += 1);
                  _loadItems();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

// Bouton de navigation compact
  Widget _buildCompactNavButton({
    required ThemeData theme,
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Icon(
            icon,
            color: enabled
                ? theme.colorScheme.primary
                : Colors.black.withValues(alpha:0.2),
            size: 20,
          ),
        ),
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              margin: const EdgeInsets.only(top: 100),
              decoration: BoxDecoration(
                color: Theme
                    .of(context)
                    .scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(32)),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Theme
                          .of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme
                                    .of(context)
                                    .colorScheme
                                    .primary,
                                Theme
                                    .of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.filter_list_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'Filtres avancés',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: FilterTable(
                        model: widget.dataModel,
                        filters: _filters,
                        onFilterChange: (content) {
                          setState(() {
                            _filters.clear();
                            _filters.addAll(content);
                          });
                          _loadItems();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme
                        .of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.2),
                    Theme
                        .of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: LoadingIndicator(
                color: Theme
                    .of(context)
                    .colorScheme
                    .primary,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Chargement...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme
                    .of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

    if (_items.isEmpty) {
      return _buildEmptyState();
    }

    return _buildItemsList();
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => _loadItems(),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.15),
                    theme.colorScheme.primary.withValues(alpha: 0.05),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                Icons.inbox_rounded,
                size: 80,
                color: theme.colorScheme.primary.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Aucun élément trouvé',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Touchez pour actualiser',
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.15),
                    theme.colorScheme.primary.withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.refresh_rounded,
                size: 32,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.only(bottom: 100, top: 16),
        itemCount: _items.length +
            (widget.paginate == PaginationValue.infiniteScroll && _hasMore
                ? 1
                : 0),
        itemBuilder: (context, index) {
          if (widget.paginate == PaginationValue.infiniteScroll &&
              index == _items.length) {
            return _isLoadingMore
                ? const Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(
                child: LoadingIndicator(type: LoadingIndicatorType.waveDot),
              ),
            )
                : const SizedBox.shrink();
          }

          return TweenAnimationBuilder(
            duration: Duration(milliseconds: 350 + (index * 50)),
            tween: Tween<double>(begin: 0, end: 1),
            curve: Curves.easeOutCubic,
            builder: (context, double value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: Transform.scale(
                    scale: 0.95 + (0.05 * value),
                    child: child,
                  ),
                ),
              );
            },
            child: _buildListItem(_items[index]),
          );
        },
      ),
    );
  }

  Widget _buildListItem(Map<String, dynamic> item) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
            const Color(0xFF1E1E1E),
            const Color(0xFF1A1A1A),
          ]
              : [
            Colors.white,
            Colors.grey.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.06),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : theme.colorScheme.primary.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => widget.onItemTap?.call(item, _updateLine),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(child: widget.itemBuilder(item)),
                if (widget.optionVisible) ...[
                  const SizedBox(width: 12),
                  _buildModernOptionsButton(item, theme, isDark),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernOptionsButton(Map<String, dynamic> item,
      ThemeData theme,
      bool isDark,) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.15),
            theme.colorScheme.primary.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showOptionsBottomSheet(item),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(
              Icons.more_horiz_rounded,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  void _showOptionsBottomSheet(Map<String, dynamic> item) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final options = _buildOptionsList(item);

        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 16, bottom: 8),
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.primary.withValues(alpha: 0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withValues(
                                  alpha: 0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.tune_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Options',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 1,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: options.length,
                      separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                      itemBuilder: (context, index) => options[index],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildOptionsList(Map<String, dynamic> item) {
    final theme = Theme.of(context);

    return [
      if (widget.optionsBuilder != null)
        ...widget.optionsBuilder!(item, _loadItems, _updateLine),
      if (widget.canEdit?.call(item) ?? true)
        DisableIfNoPermission(
          permission: "update ${widget.dataModel}",
          child: _buildOptionItem(
            theme: theme,
            icon: Icons.edit_rounded,
            iconColor: Colors.blue.shade600,
            title: 'Modifier',
            onTap: () {
              Navigator.pop(context);
              _navigateToEditForm(item);
            },
          ),
        ),
      if (widget.canDelete?.call(item) ?? true)
        DisableIfNoPermission(
          permission: 'delete ${widget.dataModel}',
          child: _buildOptionItem(
            theme: theme,
            icon: Icons.delete_rounded,
            iconColor: Colors.red.shade600,
            title: 'Supprimer',
            onTap: () {
              Navigator.pop(context);
              _deleteItem(item);
            },
          ),
        ),
    ];
  }

  Widget _buildOptionItem({
    required ThemeData theme,
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {

    return OptionItem(icon: icon, iconColor: iconColor, title: title, onTap: onTap);
  }

  Widget _buildFab(ThemeData theme) {
    return ScaleTransition(
      scale: _fabAnimation,
      child: PermissionGuard(
        showFallback: false,
        permission: 'create ${widget.dataModel}',
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withValues(alpha: 0.8),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.5),
                blurRadius: 24,
                offset: const Offset(0, 12),
                spreadRadius: 2,
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            onPressed: _navigateToAddForm,
            backgroundColor: Colors.transparent,
            elevation: 0,
            icon: const Icon(Icons.add_rounded, size: 28),
            label: const Text(
              'Ajouter',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class OptionItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;

  const OptionItem({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: iconColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: iconColor,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
