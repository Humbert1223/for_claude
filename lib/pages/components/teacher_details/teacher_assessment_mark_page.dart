import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:novacole/components/app_bar_back_button.dart';
import 'package:novacole/components/loading_indicator.dart';
import 'package:novacole/components/model_photo_widget.dart';
import 'package:novacole/models/master_crud_model.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class TeacherAssessmentMarkPage extends StatefulWidget {
  final Map<String, dynamic> assessment;
  final Map<String, dynamic> teacher;

  const TeacherAssessmentMarkPage({
    super.key,
    required this.assessment,
    required this.teacher,
  });

  @override
  TeacherAssessmentMarkPageState createState() {
    return TeacherAssessmentMarkPageState();
  }
}

class TeacherAssessmentMarkPageState extends State<TeacherAssessmentMarkPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Color _getPerformanceColor(double percent) {
    if (percent >= 0.75) return Colors.green;
    if (percent >= 0.5) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        leading: AppBarBackButton(),
        title: Text(
          "${widget.assessment['name']}",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: FutureBuilder(
        future: MasterCrudModel.load(
          '/assessment/mark-achievement/${widget.teacher['id']}/${widget.assessment['id']}',
        ),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator();
          }

          List<Map<String, dynamic>> achievements =
              List<Map<String, dynamic>>.from(snap.data ?? []);

          int totalMark = achievements.isEmpty
              ? 0
              : achievements
                    .map((el) => el['mark_count'] as int)
                    .reduce((prev, curr) => prev + curr);

          int totalStudent = achievements.isEmpty
              ? 0
              : achievements
                    .map((el) => el['student_count'] as int)
                    .reduce((prev, curr) => prev + curr);

          double globalPercent = totalStudent > 0
              ? totalMark / totalStudent
              : 0.0;

          return CustomScrollView(
            slivers: [
              // Header avec les infos du professeur
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.1),
                        Theme.of(
                          context,
                        ).colorScheme.primaryContainer.withValues(alpha: 0.2),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Photo avec border moderne
                      ModelPhotoWidget(
                        model: widget.teacher,
                        height: 90,
                        width: 90,
                      ),
                      const SizedBox(width: 16),

                      // Infos du professeur
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.teacher['last_name']
                                  .toString()
                                  .toUpperCase(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              "${widget.teacher['first_name']}",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.8),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.person_outline,
                                  size: 14,
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  tr(widget.teacher['gender']),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Icon(
                                  Icons.badge_outlined,
                                  size: 14,
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.teacher['matricule'] ?? '-',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Indicateur circulaire moderne
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: CircularPercentIndicator(
                          radius: 35,
                          percent: globalPercent,
                          lineWidth: 6,
                          circularStrokeCap: CircularStrokeCap.round,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          progressColor: _getPerformanceColor(globalPercent),
                          center: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "${(globalPercent * 100).toStringAsFixed(0)}%",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: _getPerformanceColor(globalPercent),
                                ),
                              ),
                              Text(
                                "$totalMark/$totalStudent",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Liste des matières
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final achievement = achievements[index];
                    final percent = achievement['percent'] * 1.0;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Row(
                          children: [
                            // Image de la discipline
                            Container(
                              height: 100,
                              width: 100,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: CachedNetworkImageProvider(
                                    achievement['subject']['discipline']?['image_url'],
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withValues(alpha: 0.3),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                            ),

                            // Contenu
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Nom de la discipline
                                    Text(
                                      achievement['subject']['discipline']?['name'] ??
                                          achievement['subject']['name'],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),

                                    // Classe
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.school_outlined,
                                          size: 14,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withValues(alpha: 0.6),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          "${achievement['subject']['classe']['name']}",
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withValues(alpha: 0.6),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),

                                    // Barre de progression moderne
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .surfaceContainerHighest,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: FractionallySizedBox(
                                              alignment: Alignment.centerLeft,
                                              widthFactor: percent,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      _getPerformanceColor(
                                                        percent,
                                                      ),
                                                      _getPerformanceColor(
                                                        percent,
                                                      ).withValues(alpha: 0.7),
                                                    ],
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color:
                                                          _getPerformanceColor(
                                                            percent,
                                                          ).withValues(
                                                            alpha: 0.3,
                                                          ),
                                                      blurRadius: 4,
                                                      spreadRadius: 1,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),

                                        // Pourcentage et nombre
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              "${(percent * 100).toStringAsFixed(0)}%",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: _getPerformanceColor(
                                                  percent,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              "${achievement['mark_count']} / ${achievement['student_count']}",
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface
                                                    .withValues(alpha: 0.6),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }, childCount: achievements.length),
                ),
              ),

              // Padding en bas
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
            ],
          );
        },
      ),
    );
  }
}
