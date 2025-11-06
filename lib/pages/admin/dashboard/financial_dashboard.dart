import 'package:flutter/material.dart';
import 'package:novacole/components/permission_widgets.dart';
import 'package:novacole/pages/admin/dashboard/components/incoming_by_type_pie.dart';
import 'package:novacole/pages/admin/dashboard/components/outgoing_by_type_pie.dart';
import 'package:novacole/pages/admin/dashboard/components/overdue_payment_by_academic_pie.dart';
import 'package:novacole/pages/admin/dashboard/components/panel_card.dart';
import 'package:novacole/pages/admin/dashboard/components/weekly_cash_trend.dart';
import 'package:novacole/pages/admin/dashboard/components/weekly_operation_trend.dart';
import 'package:novacole/utils/constants.dart';
import 'package:novacole/utils/permission_utils.dart';

class FinancialDashboardPage extends StatefulWidget {
  const FinancialDashboardPage({super.key});

  @override
  FinancialDashboardPageState createState() => FinancialDashboardPageState();
}

class FinancialDashboardPageState extends State<FinancialDashboardPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Animation setup
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    // Start animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _refreshDashboard() {
    setState(() {
      _controller.reset();
      _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: false,
      backgroundColor: isDark
          ? theme.colorScheme.surface
          : Colors.grey.shade50,
      appBar: _buildModernAppBar(theme, isDark),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header section with gradient
              SliverToBoxAdapter(
                child: _buildHeaderSection(theme, isDark),
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: Column(
                    children: [
                      // Financial Panel Bar
                      PermissionGuard(
                        anyOf: [
                          PermissionName.viewAny(Entity.operation),
                          PermissionName.viewAny(Entity.payment)
                        ],
                        child: const FinancialPanelBar(),
                      ),

                      const SizedBox(height: 16),

                      // Weekly Operation Trend
                      PermissionGuard(
                        anyOf: [
                          PermissionName.viewAny(Entity.operation),
                          PermissionName.viewAny(Entity.payment)
                        ],
                        child: const WeeklyOperationTrend(),
                      ),

                      // Weekly Cash Trend
                      HideIfNoPermission(
                        permission: PermissionName.viewAny(Entity.payment),
                        child: const WeeklyCashTrend(),
                      ),

                      // Section: Paiements
                      HideIfNoPermission(
                        permission: PermissionName.viewAny(Entity.payment),
                        child: _buildSectionHeader(
                          theme,
                          isDark,
                          icon: Icons.payment_rounded,
                          title: 'Paiements',
                          subtitle: 'Analyse des encaissements',
                        ),
                      ),

                      // Overdue Payment Pie
                      HideIfNoPermission(
                        permission: PermissionName.viewAny(Entity.payment),
                        child: const OverduePaymentByAcademicPie(),
                      ),

                      // Section: Opérations
                      HideIfNoPermission(
                        permission: PermissionName.viewAny(Entity.operation),
                        child: _buildSectionHeader(
                          theme,
                          isDark,
                          icon: Icons.swap_horiz_rounded,
                          title: 'Opérations',
                          subtitle: 'Recettes et dépenses',
                        ),
                      ),

                      // Incoming by Type Pie
                      HideIfNoPermission(
                        permission: PermissionName.viewAny(Entity.operation),
                        child: const IncomingByTypePie(),
                      ),

                      // Outgoing by Type Pie
                      HideIfNoPermission(
                        permission: PermissionName.viewAny(Entity.operation),
                        child: const OutgoingByTypePie(),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildScrollToTopButton(theme, isDark),
    );
  }

  PreferredSizeWidget _buildModernAppBar(ThemeData theme, bool isDark) {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: isDark
          ? theme.colorScheme.surface
          : Colors.white,
      surfaceTintColor: Colors.transparent,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha:0.1)
              : theme.colorScheme.primary.withValues(alpha:0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: theme.colorScheme.primary,
            size: 20,
          ),
          padding: EdgeInsets.zero,
        ),
      ),
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.green.shade700,
                  Colors.green.shade500,
                ],
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withValues(alpha:0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tableau de bord',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'Financier',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.green.shade700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha:0.1)
                : theme.colorScheme.primary.withValues(alpha:0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: _refreshDashboard,
            icon: Icon(
              Icons.refresh_rounded,
              color: theme.colorScheme.primary,
              size: 22,
            ),
            tooltip: 'Actualiser',
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHeaderSection(ThemeData theme, bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
            Colors.green.withValues(alpha:0.2),
            Colors.green.withValues(alpha:0.05),
          ]
              : [
            Colors.green.withValues(alpha:0.1),
            Colors.green.withValues(alpha:0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha:0.1)
              : Colors.green.withValues(alpha:0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha:0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha:0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.trending_up_rounded,
                  color: Colors.green.shade700,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vue d\'ensemble financière',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Suivi des flux financiers et tendances',
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.onSurface.withValues(alpha:0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha:0.05)
                        : Colors.white.withValues(alpha:0.7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 16,
                        color: theme.colorScheme.onSurface.withValues(alpha:0.6),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Mis à jour maintenant',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withValues(alpha:0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withValues(alpha:0.5),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
      ThemeData theme,
      bool isDark, {
        required IconData icon,
        required String title,
        required String subtitle,
      }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 24, 8, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                  theme.colorScheme.primary.withValues(alpha:0.3),
                  theme.colorScheme.primary.withValues(alpha:0.1),
                ]
                    : [
                  theme.colorScheme.primary.withValues(alpha:0.15),
                  theme.colorScheme.primary.withValues(alpha:0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withValues(alpha:0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 2,
            width: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withValues(alpha:0),
                ],
              ),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollToTopButton(ThemeData theme, bool isDark) {
    return AnimatedBuilder(
      animation: _scrollController,
      builder: (context, child) {
        final showButton = _scrollController.hasClients &&
            _scrollController.offset > 200;

        return AnimatedScale(
          scale: showButton ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: FloatingActionButton(
            onPressed: () {
              _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            },
            backgroundColor: theme.colorScheme.primary,
            child: const Icon(
              Icons.arrow_upward_rounded,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}