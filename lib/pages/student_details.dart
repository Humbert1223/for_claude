import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:novacole/components/loading_indicator.dart';
import 'package:novacole/components/model_photo_widget.dart';
import 'package:novacole/models/master_crud_model.dart';
import 'package:novacole/models/user_model.dart';
import 'package:novacole/pages/components/student_details/student_absence_list.dart';
import 'package:novacole/pages/components/student_details/student_assessment_list.dart';
import 'package:novacole/pages/components/student_details/student_details_info_page.dart';
import 'package:novacole/pages/components/student_details/student_fees_list.dart';
import 'package:novacole/pages/components/student_details/student_leave_list.dart';
import 'package:novacole/pages/components/student_details/student_planing_page.dart';
import 'package:novacole/pages/components/student_details/student_tutor_list_page.dart';
import 'package:novacole/utils/tools.dart';

class StudentDetails extends StatefulWidget {
  final Map<String, dynamic> student;

  const StudentDetails({super.key, required this.student});

  @override
  StudentDetailsState createState() {
    return StudentDetailsState();
  }
}

class StudentDetailsState extends State<StudentDetails> with SingleTickerProviderStateMixin {
  Map<String, dynamic>? repartition;
  bool isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _loadRepartition();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: isLoading
                ? const SizedBox(
              height: 400,
              child: Center(child: LoadingIndicator()),
            )
                : FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoCard(),
                      const SizedBox(height: 20),
                      _buildQuickStats(),
                      const SizedBox(height: 20),
                      _buildSectionTitle('Accès rapide'),
                      const SizedBox(height: 12),
                      _buildMenuGrid(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 190,
      pinned: true,
      elevation: 0,
      title: Text(
        "${widget.student['full_name']}",
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          shadows: [
            Shadow(
              color: Colors.black26,
              offset: Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
      ) ,
      backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.9),
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha:0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha:0.3)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            ),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Gradient de fond
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                    Theme.of(context).colorScheme.tertiary,
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
                  color: Colors.white.withValues(alpha:0.1),
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              left: -30,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha:0.08),
                ),
              ),
            ),
            // Contenu
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  ModelPhotoWidget(
                    model: widget.student,
                    width: 90,
                    height: 90,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildInfoChip(
                          icon: Icons.badge_outlined,
                          text: widget.student['matricule'] ?? '-',
                        ),
                        const SizedBox(height: 4),
                        _buildInfoChip(
                          icon: Icons.school_outlined,
                          text: repartition?['classe_name'] ??
                              widget.student['level']?['name'] ?? '-',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha:0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha:0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primaryContainer,
                  Theme.of(context).colorScheme.secondaryContainer,
                ],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 12),
                Text(
                  'Informations personnelles',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoRow(
                  icon: Icons.cake_outlined,
                  label: 'Date de naissance',
                  value: widget.student['birthdate'] != null
                      ? DateFormat('dd MMM yyyy').format(
                    DateTime.parse(widget.student['birthdate']),
                  )
                      : '-',
                ),
                _buildInfoRow(
                  icon: Icons.location_on_outlined,
                  label: 'Lieu de naissance',
                  value: widget.student['birth_city'] ?? '-',
                ),
                _buildInfoRow(
                  icon: Icons.person_outline,
                  label: 'Sexe',
                  value: widget.student['gender'] ?? '-',
                  translate: true,
                ),
                _buildInfoRow(
                  icon: Icons.school_outlined,
                  label: 'Classe',
                  value: repartition?['classe_name'] ?? '-',
                ),
                _buildInfoRow(
                  icon: Icons.stairs_outlined,
                  label: 'Niveau',
                  value: widget.student['level']?['name'] ?? '-',
                ),
                _buildInfoRow(
                  icon: Icons.badge_outlined,
                  label: 'Matricule',
                  value: widget.student['matricule'] ?? '-',
                ),
                _buildInfoRow(
                  icon: Icons.phone_outlined,
                  label: 'Téléphone',
                  value: widget.student['phone'] ?? '-',
                ),
                _buildInfoRow(
                  icon: Icons.fingerprint_outlined,
                  label: 'NIU',
                  value: widget.student['niu'] ?? '-',
                ),
                _buildInfoRow(
                  icon: Icons.home_outlined,
                  label: 'Adresse',
                  value: widget.student['address'] ?? '-',
                  isLast: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool translate = false,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha:0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    translate
                        ? Text(value, style: _valueTextStyle()).tr()
                        : Text(value, style: _valueTextStyle()),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha:0.3),
          ),
      ],
    );
  }

  TextStyle _valueTextStyle() {
    return TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  Widget _buildQuickStats() {
    return FutureBuilder(
      future: MasterCrudModel.post('/student/stats/quick-stats/${widget.student['id']}'),
      builder: (context, snapshot){
        if(snapshot.hasData && snapshot.data != null && snapshot.data!.isNotEmpty){
          return Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.event_available_rounded,
                  label: 'Absences',
                  value: "${snapshot.data!['absences']}",
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.assignment_turned_in,
                  label: 'Permissions',
                  value: "${snapshot.data!['leaves']}",
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.payments_rounded,
                  label: 'Frais',
                  value: currency(snapshot.data!['fees']),
                  color: Colors.orange,
                ),
              ),
            ],
          );
        }else{
          return SizedBox.shrink();
        }
      }
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha:0.1),
            color.withValues(alpha:0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha:0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuGrid() {
    final menuItems = [
      if (true)
        _MenuItemData(
          icon: Icons.people_alt_outlined,
          title: 'Parents',
          color: Colors.purple,
          onTap: () => _navigateToPage(
            'Parents',
            StudentTutorListPage(student: widget.student),
          ),
        ),
      if (repartition != null)
        _MenuItemData(
          icon: Icons.calendar_month_outlined,
          title: 'Emploi du temps',
          color: Colors.blue,
          onTap: () => _navigateToPage(
            'Emploi du temps',
            StudentPlaningPage(classe: repartition!['classe']),
          ),
        ),
      if (repartition != null)
        _MenuItemData(
          icon: Icons.check_circle_outlined,
          title: 'Évaluations',
          color: Colors.green,
          onTap: () => _navigateToPage(
            'Évaluations',
            StudentAssessmentList(repartition: repartition!),
          ),
        ),
      if (repartition != null)
        _MenuItemData(
          icon: Icons.person_remove_alt_1_outlined,
          title: 'Absences',
          color: Colors.red,
          onTap: () => _navigateToPage(
            'Absences',
            StudentAbsenceList(repartition: repartition!),
          ),
        ),
      if (repartition != null)
        _MenuItemData(
          icon: Icons.back_hand_outlined,
          title: 'Permissions',
          color: Colors.orange,
          onTap: () => _navigateToPage(
            'Demandes de permission',
            StudentLeaveList(repartition: repartition!),
          ),
        ),
      _MenuItemData(
        icon: Icons.payments_outlined,
        title: 'Frais à payer',
        color: Colors.teal,
        onTap: () => _navigateToPage(
          'Frais non soldé',
          StudentFeesList(repartition: repartition!),
        ),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return _buildMenuItem(
          icon: item.icon,
          title: item.title,
          color: item.color,
          onTap: item.onTap,
          delay: index * 100,
        );
      },
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
    int delay = 0,
  }) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 400 + delay),
      tween: Tween<double>(begin: 0, end: 1),
      curve: Curves.easeOutCubic,
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha:0.15),
              blurRadius: 12,
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
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          color.withValues(alpha:0.2),
                          color.withValues(alpha:0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: color, size: 32),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToPage(String title, Widget child) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return StudentDetailsInfoPage(
            title: title,
            student: widget.student,
            child: child,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(position: animation.drive(tween), child: child);
        },
      ),
    );
  }

  _loadRepartition() async {
    setState(() => isLoading = true);

    UserModel? user = await UserModel.fromLocalStorage();
    final data = await MasterCrudModel('registration').search(
      filters: [
        {'field': 'student_id', 'value': widget.student['id']},
        {'field': 'academic_id', 'value': user?.academic}
      ],
      paginate: '0',
      data: {'relations': ['student']},
    );

    if (mounted) {
      setState(() {
        if (data != null && List.from(data).isNotEmpty) {
          repartition = data[0];
        }
        isLoading = false;
      });
      _animationController.forward();
    }
  }
}

class _MenuItemData {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  _MenuItemData({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });
}