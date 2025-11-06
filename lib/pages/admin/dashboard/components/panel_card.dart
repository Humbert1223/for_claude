import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:novacole/components/loading_indicator.dart';
import 'package:novacole/components/permission_widgets.dart';
import 'package:novacole/models/master_crud_model.dart';
import 'package:novacole/utils/constants.dart';
import 'package:novacole/utils/permission_utils.dart';
import 'package:novacole/utils/tools.dart';

class PanelCardWidget extends StatelessWidget {
  final Widget icon;
  final String title;
  final Widget value;
  final Color? iconColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const PanelCardWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.iconColor,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Couleurs adaptatives
    final effectiveBackgroundColor =
        backgroundColor ??
        (isDark ? colorScheme.primaryContainer : colorScheme.surface);

    final titleColor = isDark
        ? colorScheme.onSurface.withValues(alpha: 0.7)
        : colorScheme.onSurface.withValues(alpha: 0.6);

    final valueColor = isDark ? colorScheme.onSurface : colorScheme.onSurface;

    final cardContent = Card(
      elevation: 0,
      shadowColor: colorScheme.shadow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark
              ? colorScheme.outline.withValues(alpha: 0.2)
              : colorScheme.outline.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      color: effectiveBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Icône avec conteneur moderne
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (iconColor ?? colorScheme.primary).withValues(
                  alpha: isDark ? 0.15 : 0.1,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: (iconColor ?? colorScheme.primary).withValues(
                    alpha: isDark ? 0.3 : 0.2,
                  ),
                  width: 1,
                ),
              ),
              child: IconTheme(
                data: IconThemeData(
                  color: iconColor ?? colorScheme.primary,
                  size: 28,
                ),
                child: icon,
              ),
            ),

            const SizedBox(width: 12),

            // Colonne avec titre et valeur
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      letterSpacing: 0.5,
                      color: titleColor,
                    ),
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  DefaultTextStyle(
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: valueColor,
                      letterSpacing: 0.3,
                    ),
                    child: value,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    // Si onTap est fourni, rendre la card cliquable
    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: cardContent,
      );
    }

    return cardContent;
  }
}

class FinancialPanelBar extends StatefulWidget {
  const FinancialPanelBar({super.key});

  @override
  FinancialPanelBarState createState() => FinancialPanelBarState();
}

class FinancialPanelBarState extends State<FinancialPanelBar> {
  Map<String, dynamic>? data;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final value = await MasterCrudModel.post('/resume/financials');
    if (value != null && mounted) {
      setState(() {
        data = value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (data != null) {
      return Column(
        children: [
          PanelCardWidget(
            icon: const Icon(FontAwesomeIcons.moneyBillTransfer),
            iconColor: Colors.amber.shade700,
            title: 'Dépenses engagées',
            value: Text(currency(data!['outgoing'])),
          ),
          PanelCardWidget(
            icon: const Icon(FontAwesomeIcons.sackDollar),
            iconColor: Colors.blue.shade600,
            title: 'Recettes engagées',
            value: Text(currency(data!['incoming'])),
          ),
          PanelCardWidget(
            icon: const Icon(FontAwesomeIcons.moneyCheck),
            iconColor: Colors.red.shade600,
            title: 'Décaissements',
            value: Text(currency(data!['real_outgoing'])),
          ),
          PanelCardWidget(
            icon: const Icon(FontAwesomeIcons.wallet),
            iconColor: Colors.green.shade600,
            title: 'Encaissements',
            value: Text(currency(data!['real_incoming'])),
          ),
        ],
      );
    } else {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 100),
        child: LoadingIndicator(),
      );
    }
  }
}

class AnalyticPanelBar extends StatelessWidget {
  const AnalyticPanelBar({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: MasterCrudModel.post('/resume/analysis'),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 100),
            child: LoadingIndicator(),
          );
        }

        if (snap.hasData && snap.data != null) {
          final data = snap.data!;
          return Column(
            children: [
              // Première ligne
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (context.hasPermission(
                          PermissionName.viewAny(Entity.student),
                        )) {
                          Navigator.pushNamed(context, '/registrations');
                        }
                      },
                      child: PanelCardWidget(
                        icon: const Icon(FontAwesomeIcons.peopleGroup),
                        iconColor: Colors.amber.shade700,
                        title: 'Élèves',
                        value: Text(number(data['students'] ?? 0)),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (context.hasPermission(
                          PermissionName.viewAny(Entity.teacher),
                        )) {
                          Navigator.pushNamed(context, '/teachers');
                        }
                      },
                      child: PanelCardWidget(
                        icon: const Icon(FontAwesomeIcons.chalkboardUser),
                        iconColor: Colors.blue.shade600,
                        title: 'Enseignants',
                        value: Text(number(data['teachers'] ?? 0)),
                      ),
                    ),
                  ),
                ],
              ),
              // Deuxième ligne
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (context.hasPermission(
                          PermissionName.viewAny(Entity.classe),
                        )) {
                          Navigator.pushNamed(context, '/classes');
                        }
                      },
                      child: PanelCardWidget(
                        icon: const Icon(FontAwesomeIcons.peopleLine),
                        iconColor: Colors.red.shade600,
                        title: 'Classes',
                        value: Text(number(data['classes'] ?? 0)),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                         if(context.hasPermission(PermissionName.viewAny(Entity.tutor))){
                           Navigator.pushNamed(context, '/tutors');
                         }
                      },
                      child: PanelCardWidget(
                        icon: const Icon(FontAwesomeIcons.handsHoldingChild),
                        iconColor: Colors.green.shade600,
                        title: 'Parents',
                        value: Text(number(data['tutors'] ?? 0)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class TeacherWelcomePanelBar extends StatelessWidget {
  const TeacherWelcomePanelBar({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: MasterCrudModel.post('/resume/teacher/analysis'),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 100),
            child: LoadingIndicator(),
          );
        }

        if (snap.hasData && snap.data != null) {
          final data = snap.data!;
          return Row(
            children: [
              Expanded(
                child: PanelCardWidget(
                  icon: const Icon(FontAwesomeIcons.book),
                  iconColor: Colors.amber.shade700,
                  title: 'Matières',
                  value: Text(number(data['subjects'] ?? 0)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PanelCardWidget(
                  icon: const Icon(FontAwesomeIcons.chalkboardUser),
                  iconColor: Colors.blue.shade600,
                  title: 'Classes',
                  value: Text(number(data['classes'] ?? 0)),
                ),
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class TutorWelcomePanelBar extends StatelessWidget {
  const TutorWelcomePanelBar({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: MasterCrudModel.post('/resume/tutor/analysis'),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 100),
            child: LoadingIndicator(),
          );
        }

        if (snap.hasData && snap.data != null) {
          final data = snap.data!;
          return Row(
            children: [
              Expanded(
                child: PanelCardWidget(
                  icon: const Icon(FontAwesomeIcons.children),
                  iconColor: Colors.amber.shade700,
                  title: 'Élèves',
                  value: Text(number(data['students'] ?? 0)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PanelCardWidget(
                  icon: const Icon(FontAwesomeIcons.moneyBill1),
                  iconColor: Colors.red.shade600,
                  title: 'Impayés',
                  value: Text(currency(data['overdue'] ?? 0)),
                ),
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
