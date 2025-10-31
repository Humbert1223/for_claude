import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:novacole/components/loading_indicator.dart';
import 'package:novacole/controllers/auth_controller.dart';
import 'package:novacole/models/master_crud_model.dart';

class SchoolSpaceSwitch extends StatefulWidget {

  const SchoolSpaceSwitch({super.key});

  @override
  SchoolSpaceSwitchState createState() => SchoolSpaceSwitchState();
}

class SchoolSpaceSwitchState extends State<SchoolSpaceSwitch>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> schools = [];
  List<Map<String, dynamic>> accounts = [];
  bool loading = true;
  final authController = Get.find<AuthController>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      if (!mounted) return;

      final schoolsData = await MasterCrudModel.load('/auth/user/schools');
      if (!mounted) return;

      setState(() {
        schools = List<Map<String, dynamic>>.from(schoolsData ?? []);
        accounts = (authController.currentUser.value.schools ?? []).where((ac){
          return schools.any((sc){
            return sc['id'] == ac['school_id'];
          });
        }).toList();
        loading = false;
      });

      _animationController.forward();
    } catch (e) {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return _buildLoadingState();
    }

    if (schools.isEmpty) {
      return _buildEmptyState();
    }

    return _buildSchoolsList();
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const LoadingIndicator(),
          const SizedBox(height: 16),
          Text(
            'Chargement...',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.6),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha:0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.school_outlined,
                  size: 80,
                  color: Colors.amber.shade700,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Aucun accès école",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                "Vous n'avez pas encore d'accès dans une école.",
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "Rapprochez-vous de votre établissement scolaire pour vous faire ajouter.",
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.5),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSchoolsList() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: CustomScrollView(
        shrinkWrap: true, // Important: permet au CustomScrollView de s'adapter à son contenu
        //physics: const NeverScrollableScrollPhysics(), // Désactive le scroll interne
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mes espaces scolaires',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sélectionnez l\'espace que vous souhaitez utiliser',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  return _buildSchoolCard(accounts[index], index);
                },
                childCount: accounts.length, // Utilisez la liste locale 'schools'
              ),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
        ],
      ),
    );
  }

  Widget _buildSchoolCard(Map<String, dynamic> account, int index) {
    final isActive = account['account_type'] == authController.currentUser.value.accountType &&
        account['school_id'] == authController.currentUser.value.school;
    final school = schools.firstWhereOrNull((sc){
      return sc['id'] == account['school_id'];
    });
    final schoolName = school!['name'] ?? 'École inconnue';

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isActive
                  ? Theme.of(context).colorScheme.primary.withValues(alpha:0.1)
                  : Colors.black.withValues(alpha:0.05),
              blurRadius: isActive ? 12 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () => _processChangeSpace(account),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _buildAvatar(school, isActive),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                "${account['account_type']}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ).tr(),
                            ),
                            if (isActive) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withValues(alpha:0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'ACTIF',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color:
                                    Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha:0.5),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                schoolName,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha:0.7),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildTrailingIcon(isActive),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(Map<String, dynamic> school, bool isActive) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isActive
              ? [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withValues(alpha:0.7),
          ]
              : [
            Colors.grey.shade300,
            Colors.grey.shade400,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: isActive
                ? Theme.of(context).colorScheme.primary.withValues(alpha:0.3)
                : Colors.black.withValues(alpha:0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: Visibility(
          visible: school['logo_url'] == null,
          replacement: CachedNetworkImage(imageUrl: school['logo_url'] ?? ''),
          child: Image.asset(
            'assets/images/person.jpeg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.person,
                size: 32,
                color: Colors.white,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTrailingIcon(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive
            ? Theme.of(context).colorScheme.primary
            : Colors.transparent,
        border: Border.all(
          color: isActive
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface.withValues(alpha:0.3),
          width: 2,
        ),
      ),
      child: Icon(
        isActive ? Icons.check : Icons.circle_outlined,
        size: 20,
        color: isActive
            ? Colors.white
            : Theme.of(context).colorScheme.onSurface.withValues(alpha:0.3),
      ),
    );
  }

  Future<void> _processChangeSpace(Map<String, dynamic> account) async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha:0.1),
                  shape: BoxShape.circle,
                ),
                child: LoadingIndicator(),
              ),
              const SizedBox(height: 20),
              Text(
                'Changement d\'espace',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Veuillez patienter...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha:0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final response = await authController.changeSpace(
        accountType: account['account_type'],
        schoolId: account['school_id'],
      );

      if (!mounted) return;

      if (response) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      } else {
        Navigator.of(context).pop();
        _showErrorSnackBar('Échec du changement d\'espace');
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        _showErrorSnackBar('Une erreur est survenue');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}