import 'dart:ui';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
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

typedef DefaultGridOptions =
    List<Widget> Function(
      Map<String, dynamic> item,
      VoidCallback reload,
      Function(Map<String, dynamic>?) updateLine,
    );

typedef GridEntryOptionPermission = bool Function(Map<String, dynamic> item);

typedef OnItemTapCallback =
    void Function(
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
  // Paramètres de pagination
  int _currentPage = 1;
  int _perPage = 15;
  int? _lastPage;

  // Filtres et recherche
  final List<FilterRow> _filters = [];
  final TextEditingController _searchController = TextEditingController();

  // État
  bool _isLoading = false;
  bool _isLoadingMore = false;
  List<Map<String, dynamic>> _items = [];

  // Infinite scroll
  final ScrollController _scrollController = ScrollController();
  bool _hasMore = true;

  // Animation
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  // Constantes
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
    250,
  ];

  @override
  void initState() {
    super.initState();
    _loadItems();
    if (widget.paginate == PaginationValue.infiniteScroll) {
      _scrollController.addListener(_onScroll);
    }

    // Animation du FAB
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeOutBack,
    );
    Future.delayed(const Duration(milliseconds: 300), () {
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
          .map(
            (filter) => {
              'field': filter.field.$2,
              'operator': filter.operator.$2,
              'value': filter.value.$2,
            },
          )
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
      _showErrorSnackBar('Erreur lors du chargement: $e');
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
          _showSuccessSnackBar('Élément supprimé avec succès');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Erreur lors de la suppression: $e');
      }
    }
  }

  Future<bool?> _showDeleteConfirmation() {
    final theme = Theme.of(context);

    return showDialog<bool>(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.red,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Confirmer la suppression',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Text(
            'Voulez-vous vraiment supprimer cet élément ? Cette action est irréversible.',
            style: TextStyle(
              fontSize: 15,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Annuler',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Supprimer',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0.0, 0.1),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
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
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0.1, 0.0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
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
      backgroundColor: isDark ? theme.colorScheme.surface : Colors.grey.shade50,
      appBar: widget.appBarVisible ? _buildAppBar(theme, isDark) : null,
      body: RefreshIndicator(
        onRefresh: () async {
          _currentPage = 1;
          await _loadItems();
        },
        color: theme.colorScheme.primary,
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
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          onPressed: widget.onBack ?? () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          padding: EdgeInsets.zero,
        ),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              widget.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.3,
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
      preferredSize: Size.fromHeight(
        widget.paginate == PaginationValue.infiniteScroll ? 70 : 130,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Column(
          children: [
            _buildSearchBar(theme, isDark),
            if (widget.paginate == PaginationValue.paginated) ...[
              const SizedBox(height: 10),
              _buildPaginationControls(theme, isDark),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme, bool isDark) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
            : Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 18),
          Icon(
            Icons.search_rounded,
            color: theme.colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: 'Rechercher...',
                hintStyle: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
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
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          _buildFilterButton(theme, isDark),
          const SizedBox(width: 6),
        ],
      ),
    );
  }

  Widget _buildFilterButton(ThemeData theme, bool isDark) {
    final hasFilters = _filters.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        gradient: hasFilters
            ? LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withValues(alpha: 0.8),
                ],
              )
            : null,
        color: hasFilters
            ? null
            : theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            onPressed: _showFilterBottomSheet,
            icon: Icon(
              Icons.tune_rounded,
              color: hasFilters
                  ? Colors.white
                  : theme.colorScheme.onPrimaryContainer,
              size: 22,
            ),
          ),
          if (hasFilters)
            Positioned(
              right: 6,
              top: 6,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withValues(alpha: 0.4),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                child: Center(
                  child: Text(
                    '${_filters.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          margin: const EdgeInsets.only(top: 80),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
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

  Widget _buildPaginationControls(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.description_rounded,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Page $_currentPage',
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                ' / ${_lastPage ?? '-'}',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          Row(
            children: [
              _buildPerPageDropdown(theme, isDark),
              const SizedBox(width: 6),
              _buildPageNavigationButtons(theme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerPageDropdown(ThemeData theme, bool isDark) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
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
            Text(
              '$selectedItem',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.unfold_more_rounded,
              size: 18,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
    );
  }

  Widget _buildPageNavigationButtons(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildNavButton(
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
            color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
          ),
          _buildNavButton(
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
    );
  }

  Widget _buildNavButton({
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
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            color: enabled
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withValues(alpha: 0.3),
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: LoadingIndicator());
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
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                    theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inbox_rounded,
                size: 72,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Aucun élément trouvé',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Touchez pour actualiser',
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.refresh_rounded,
                size: 28,
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
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.only(bottom: 100, top: 12),
        itemCount:
            _items.length +
            (widget.paginate == PaginationValue.infiniteScroll && _hasMore
                ? 1
                : 0),
        itemBuilder: (context, index) {
          if (widget.paginate == PaginationValue.infiniteScroll &&
              index == _items.length) {
            return _isLoadingMore
                ? const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Center(
                      child: LoadingIndicator(
                        type: LoadingIndicatorType.waveDot,
                      ),
                    ),
                  )
                : const SizedBox.shrink();
          }

          return TweenAnimationBuilder(
            duration: Duration(milliseconds: 300 + (index * 40)),
            tween: Tween<double>(begin: 0, end: 1),
            curve: Curves.easeOutCubic,
            builder: (context, double value, child) {
              return Transform.translate(
                offset: Offset(0, 15 * (1 - value)),
                child: Opacity(opacity: value, child: child),
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
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => widget.onItemTap?.call(item, _updateLine),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(child: widget.itemBuilder(item)),
                if (widget.optionVisible)
                  _buildModernOptionsButton(item, theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernOptionsButton(Map<String, dynamic> item, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _showOptionsBottomSheet(item),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              Icons.more_horiz_rounded,
              color: theme.colorScheme.onPrimaryContainer,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }

  void _showOptionsBottomSheet(Map<String, dynamic> item) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final options = _buildOptionsList(item);

        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 4),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Titre
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.primary.withValues(alpha: 0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.tune_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Options',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 1,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                ),
                // Liste des options
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: options.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
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
      // Options personnalisées
      if (widget.optionsBuilder != null)
        ...widget.optionsBuilder!(item, _loadItems, _updateLine),

      // Option d'édition
      if (widget.canEdit?.call(item) ?? true)
        DisableIfNoPermission(
          permission: "update ${widget.dataModel}",
          child: _buildOptionItem(
            theme: theme,
            icon: Icons.edit_rounded,
            iconColor: Colors.blue,
            title: 'Modifier',
            onTap: () {
              Navigator.pop(context);
              _navigateToEditForm(item);
            },
          ),
        ),

      // Option de suppression
      if (widget.canDelete?.call(item) ?? true)
        DisableIfNoPermission(
          permission: 'delete ${widget.dataModel}',
          child: _buildOptionItem(
            theme: theme,
            icon: Icons.delete_rounded,
            iconColor: Colors.red,
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
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: title == 'Supprimer'
                          ? iconColor
                          : theme.colorScheme.onSurface,
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

  Widget _buildFab(ThemeData theme) {
    return ScaleTransition(
      scale: _fabAnimation,
      child: PermissionGuard(
        showFallback: false,
        permission: 'create ${widget.dataModel}',
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withValues(alpha: 0.85),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            onPressed: _navigateToAddForm,
            backgroundColor: Colors.transparent,
            elevation: 0,
            icon: const Icon(Icons.add_rounded, size: 26),
            label: const Text(
              'Ajouter',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
