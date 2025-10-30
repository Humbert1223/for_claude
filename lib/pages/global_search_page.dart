import 'package:flutter/material.dart';
import 'package:novacole/models/user_model.dart';
import 'package:novacole/pages/components/home/home_search_widget.dart';
import 'package:novacole/pages/components/search/classe_search_list.dart';
import 'package:novacole/pages/components/search/student_search_list.dart';
import 'package:novacole/pages/components/search/teacher_search_list.dart';
import 'package:novacole/pages/components/search/tutor_search_list.dart';

class GlobalSearchPage extends StatefulWidget {
  final String? term;

  const GlobalSearchPage({super.key, this.term});

  @override
  GlobalSearchPageState createState() => GlobalSearchPageState();
}

class GlobalSearchPageState extends State<GlobalSearchPage>
    with SingleTickerProviderStateMixin {
  String? term;
  UserModel? user;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<String> _categories = ['Tous', 'Élèves', 'Enseignants', 'Parents', 'Classes'];
  String _selectedCategory = 'Tous';

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    UserModel.fromLocalStorage().then((value) {
      if (mounted) {
        setState(() {
          user = value;
        });
      }
    });

    setState(() {
      term = widget.term;
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? theme.colorScheme.surface : Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          _buildModernAppBar(theme, isDark),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildSearchBar(theme, isDark),
                  const SizedBox(height: 20),
                  _buildCategoryTabs(theme, isDark),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          _buildSearchResults(theme, isDark),
        ],
      ),
    );
  }

  Widget _buildModernAppBar(ThemeData theme, bool isDark) {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      elevation: 0,
      backgroundColor: theme.colorScheme.primary,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        ),
        child: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            // Gradient de fond
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),
            // Motif décoratif
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ),
            // Titre
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.search_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Recherche Globale',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Trouvez rapidement ce que vous cherchez',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: HomeSearchWidget(
          value: term,
          onSearch: (query) {
            setState(() {
              term = query;
            });
          },
        ),
      ),
    );
  }

  Widget _buildCategoryTabs(ThemeData theme, bool isDark) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
                borderRadius: BorderRadius.circular(25),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withValues(alpha: 0.8),
                      ],
                    )
                        : null,
                    color: isSelected
                        ? null
                        : isDark
                        ? theme.colorScheme.surfaceContainerHighest
                        : Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : theme.colorScheme.outline.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                    boxShadow: isSelected
                        ? [
                      BoxShadow(
                        color: theme.colorScheme.primary
                            .withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                        : [],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getCategoryIcon(category),
                        size: 18,
                        color: isSelected
                            ? Colors.white
                            : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        category,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Tous':
        return Icons.apps_rounded;
      case 'Élèves':
        return Icons.school_rounded;
      case 'Enseignants':
        return Icons.person_rounded;
      case 'Parents':
        return Icons.family_restroom_rounded;
      case 'Classes':
        return Icons.class_rounded;
      default:
        return Icons.search_rounded;
    }
  }

  Widget _buildSearchResults(ThemeData theme, bool isDark) {
    if (term == null || term!.isEmpty) {
      return SliverFillRemaining(
        child: _buildEmptyState(theme, isDark),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          if (_selectedCategory == 'Tous' || _selectedCategory == 'Élèves')
            _buildSectionWrapper(
              'Élèves',
              Icons.school_rounded,
              Colors.blue,
              StudentSearchResultList(term: term),
              theme,
              isDark,
            ),
          if ((_selectedCategory == 'Tous' || _selectedCategory == 'Enseignants') &&
              user != null &&
              ['admin', 'staff'].contains(user!.accountType))
            _buildSectionWrapper(
              'Enseignants',
              Icons.person_rounded,
              Colors.green,
              TeacherSearchResultList(term: term),
              theme,
              isDark,
            ),
          if ((_selectedCategory == 'Tous' || _selectedCategory == 'Parents') &&
              user != null &&
              ['admin', 'staff', 'teacher'].contains(user!.accountType))
            _buildSectionWrapper(
              'Parents',
              Icons.family_restroom_rounded,
              Colors.orange,
              TutorSearchResultList(term: term),
              theme,
              isDark,
            ),
          if ((_selectedCategory == 'Tous' || _selectedCategory == 'Classes') &&
              user != null &&
              ['admin', 'staff', 'teacher'].contains(user!.accountType))
            _buildSectionWrapper(
              'Classes',
              Icons.class_rounded,
              Colors.purple,
              ClasseSearchResultList(term: term),
              theme,
              isDark,
            ),
          const SizedBox(height: 100),
        ]),
      ),
    );
  }

  Widget _buildSectionWrapper(
      String title,
      IconData icon,
      Color color,
      Widget child,
      ThemeData theme,
      bool isDark,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.2),
                      color.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark
                ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? theme.colorScheme.outline.withValues(alpha: 0.2)
                  : theme.colorScheme.outline.withValues(alpha: 0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: child,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.1),
                  theme.colorScheme.primary.withValues(alpha: 0.05),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 80,
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Commencez votre recherche',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48.0),
            child: Text(
              'Tapez au moins 3 caractères pour rechercher des élèves, enseignants, parents ou classes',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 32),
          _buildQuickSearchChips(theme),
        ],
      ),
    );
  }

  Widget _buildQuickSearchChips(ThemeData theme) {
    final suggestions = ['2024', 'CI', 'CM1', 'Maths', 'Français'];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: suggestions.map((suggestion) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              setState(() {
                term = suggestion;
              });
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.search_rounded,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    suggestion,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}