import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:novacole/components/permission_widgets.dart';
import 'package:novacole/pages/components/classe_details/card_dowload_page.dart';
import 'package:novacole/pages/components/classe_details/classe_assessment_list.dart';
import 'package:novacole/pages/components/classe_details/classe_exam_result.dart';
import 'package:novacole/pages/components/classe_details/classe_lot_bulletin_page.dart';
import 'package:novacole/pages/components/classe_details/classe_student_list_page.dart';
import 'package:novacole/pages/components/classe_details/classe_subject_list.dart';
import 'package:novacole/pages/components/classe_details/classe_timetable_list.dart';
import 'package:novacole/utils/constants.dart';
import 'package:novacole/utils/permission_utils.dart';

class ClasseDetails extends StatefulWidget {
  final Map<String, dynamic> classe;

  const ClasseDetails({super.key, required this.classe});

  @override
  ClasseDetailsState createState() => ClasseDetailsState();
}

class ClasseDetailsState extends State<ClasseDetails> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, colorScheme),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(context),
                  const SizedBox(height: 24),
                  _buildActionsList(context),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, ColorScheme colorScheme) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.classe['name'] ?? 'Classe',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primary,
                colorScheme.primary.withValues(alpha:0.8),
              ],
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 60),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha:0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      FontAwesomeIcons.peopleLine,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.classe['level']?['name'] ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Informations',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildInfoRow(
              context,
              Icons.class_,
              'Nom de la classe',
              widget.classe['name'],
            ),
            _buildDivider(),
            _buildInfoRow(
              context,
              Icons.layers,
              'Niveau',
              widget.classe['level']?['name'] ?? '-',
            ),
            _buildDivider(),
            _buildInfoRow(
              context,
              Icons.person_outline,
              'Titulaire',
              widget.classe['titulaire_full_name'] ?? '-',
            ),
            _buildDivider(),
            _buildInfoRow(
              context,
              Icons.groups,
              'Effectif',
              '${widget.classe['effectif'] ?? '-'} / ${widget.classe['capacity'] ?? '-'}',
            ),
            _buildDivider(),
            _buildInfoRow(
              context,
              Icons.category,
              'Série',
              widget.classe['serie']?['name'] ?? '-',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: theme.colorScheme.primary.withValues(alpha:0.7),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: Colors.grey.withValues(alpha:0.2),
    );
  }

  Widget _buildActionsList(BuildContext context) {
    final actions = _getActionItems();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Actions rapides',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...actions.map((action) => _buildActionCard(context, action)),
      ],
    );
  }

  List<ActionItem> _getActionItems() {
    final items = <ActionItem>[
      ActionItem(
        icon: Icons.calendar_today,
        title: 'Calendrier',
        color: Colors.blue,
        permission: PermissionName.viewAny(Entity.timetable),
        onTap: () => _navigate(ClasseTimeTable(classe: widget.classe)),
      ),
      ActionItem(
        icon: Icons.people,
        title: 'Élèves',
        color: Colors.green,
        permission: PermissionName.viewAny(Entity.registration),
        onTap: () => _navigate(ClasseStudentListPage(classe: widget.classe)),
      ),
      ActionItem(
        icon: Icons.book,
        title: 'Matières',
        color: Colors.orange,
        permission: PermissionName.viewAny(Entity.subject),
        onTap: () => _navigate(ClasseSubjectList(classe: widget.classe)),
      ),
      ActionItem(
        icon: Icons.assignment,
        title: 'Évaluations',
        color: Colors.purple,
        permission: PermissionName.viewAny(Entity.assessment),
        onTap: () => _navigate(ClasseAssessmentList(classe: widget.classe)),
      ),
    ];

    if (widget.classe['level']?['is_exam'] == true) {
      items.add(
        ActionItem(
          icon: Icons.emoji_events,
          title: "Résultats d'examen ${widget.classe['level']?['exam_name'] ?? ''}",
          color: Colors.amber,
          permission: PermissionName.viewAny(Entity.registration),
          onTap: () => _navigate(ClasseExamResult(classe: widget.classe)),
        ),
      );
    }

    items.addAll([
      ActionItem(
        icon: Icons.description,
        title: 'Lots de bulletins',
        color: Colors.teal,
        permission: PermissionName.viewAny(Entity.lotBulletin),
        onTap: () => _navigate(ClasseLotBulletin(classe: widget.classe)),
      ),
      ActionItem(
        icon: Icons.card_membership,
        title: 'Carte scolaire',
        color: Colors.indigo,
        permission: PermissionName.viewAny(Entity.registration),
        onTap: () => _navigate(ClasseCardDownloadPage(classe: widget.classe)),
      ),
    ]);

    return items;
  }

  Widget _buildActionCard(BuildContext context, ActionItem action) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: DisableIfNoPermission(
        permission: action.permission,
        child: Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: action.onTap,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: action.color.withValues(alpha:0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      action.icon,
                      color: action.color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      action.title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigate(Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => page),
    );
  }
}

class ActionItem {
  final IconData icon;
  final String title;
  final Color color;
  final String permission;
  final VoidCallback onTap;

  const ActionItem({
    required this.icon,
    required this.title,
    required this.color,
    required this.permission,
    required this.onTap,
  });
}