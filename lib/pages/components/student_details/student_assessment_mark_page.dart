import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:novacole/models/master_crud_model.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class StudentAssessmentMarkPage extends StatefulWidget {
  final Map<String, dynamic> assessment;
  final Map<String, dynamic> student;

  const StudentAssessmentMarkPage({
    super.key,
    required this.assessment,
    required this.student,
  });

  @override
  StudentAssessmentMarkPageState createState() =>
      StudentAssessmentMarkPageState();
}

class StudentAssessmentMarkPageState extends State<StudentAssessmentMarkPage> {
  Future<List<Map<String, dynamic>>> _loadMarks() async {
    final response = await MasterCrudModel('mark').search(
      paginate: '0',
      filters: [
        {'field': 'assessment_id', 'value': widget.assessment['id']},
        {'field': 'student_id', 'value': widget.student['id']},
      ],
      query: {'relations': ['subject']},
    );

    if (response == null) return [];

    return List<Map<String, dynamic>>.from(response).map((mark) {
      final coeff = 1.0 * mark['subject']['coefficient'];
      final valueOn = 20.0 * coeff;
      mark['value_on'] = valueOn;
      mark['value_coeff'] = coeff * mark['value'];
      mark['percent'] = mark['value_coeff'] / valueOn;
      return mark;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _loadMarks(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 300,
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }

                final marks = snapshot.data ?? [];
                final sumMark =
                marks.fold(0.0, (sum, m) => m['value_coeff'] + sum);
                final sumCoeff = marks.fold(
                    0.0, (sum, m) => m['subject']['coefficient'] + sum);
                final globalPercent = sumCoeff > 0 ? sumMark / (20 * sumCoeff) : 0.0;

                return Column(
                  children: [
                    _buildStudentHeader(context, globalPercent, sumMark, sumCoeff),
                    const SizedBox(height: 16),
                    _buildMarksList(context, marks),
                    const SizedBox(height: 100),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha:0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_rounded,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16, right: 16),
        title: Text(
          widget.assessment['name'] ?? '',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withValues(alpha:0.8),
                  ],
                ),
              ),
            ),
            Positioned(
              right: -50,
              top: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha:0.1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentHeader(
      BuildContext context,
      double globalPercent,
      double sumMark,
      double sumCoeff,
      ) {
    final imageProvider = widget.student['photo_url'] != null
        ? CachedNetworkImageProvider(widget.student['photo_url'])
    as ImageProvider
        : const AssetImage('assets/images/person.jpeg');

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Hero(
                tag: 'student_photo_${widget.student['id']}',
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).primaryColor,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withValues(alpha:0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.student['last_name']?.toString().toUpperCase() ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.student['first_name'] ?? '',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoChip(
                      Icons.person_outline_rounded,
                      tr(widget.student['gender'] ?? 'unknown'),
                    ),
                    const SizedBox(height: 4),
                    _buildInfoChip(
                      Icons.badge_rounded,
                      widget.student['matricule'] ?? '-',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: globalPercent < 0.5
                    ? [Colors.red.shade50, Colors.orange.shade50]
                    : [
                  Theme.of(context).primaryColor.withValues(alpha:0.1),
                  Theme.of(context).primaryColor.withValues(alpha:0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      'Moyenne générale',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${sumMark.toStringAsFixed(2)} / ${(sumCoeff * 20).toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                CircularPercentIndicator(
                  radius: 50,
                  percent: globalPercent,
                  lineWidth: 10,
                  backgroundColor: Colors.grey[200]!,
                  circularStrokeCap: CircularStrokeCap.round,
                  progressColor: globalPercent < 0.5
                      ? Colors.red
                      : Theme.of(context).primaryColor,
                  center: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${(globalPercent * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        globalPercent < 0.5 ? 'Insuffisant' : 'Bien',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildMarksList(BuildContext context, List<Map<String, dynamic>> marks) {
    if (marks.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.grading_rounded, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Aucune note disponible',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notes par matière',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          ...marks.map((mark) => _buildMarkCard(context, mark)).toList(),
        ],
      ),
    );
  }

  Widget _buildMarkCard(BuildContext context, Map<String, dynamic> mark) {
    final percent = mark['percent'] as double;
    final disciplineName = mark['subject']['discipline']?['name'] ??
        mark['subject']['name'];
    final imageUrl = mark['subject']['discipline']?['image_url'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: percent < 0.5
              ? Colors.red.withValues(alpha:0.2)
              : Theme.of(context).primaryColor.withValues(alpha:0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(20),
              ),
              color: Colors.grey[100],
            ),
            child: imageUrl != null
                ? ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(20),
              ),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Icon(
                  Icons.book_rounded,
                  size: 32,
                  color: Colors.grey[400],
                ),
              ),
            )
                : Icon(
              Icons.book_rounded,
              size: 32,
              color: Colors.grey[400],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          disciplineName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: percent < 0.5
                              ? Colors.red.withValues(alpha:0.1)
                              : Theme.of(context)
                              .primaryColor
                              .withValues(alpha:0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${mark['value_coeff'].toStringAsFixed(2)} / ${mark['value_on'].toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: percent < 0.5
                                ? Colors.red
                                : Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Stack(
                    children: [
                      Container(
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: percent,
                        child: Container(
                          height: 24,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: percent < 0.5
                                  ? [Colors.red, Colors.red.shade300]
                                  : [
                                Theme.of(context).primaryColor,
                                Theme.of(context)
                                    .primaryColor
                                    .withValues(alpha:0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      Container(
                        height: 24,
                        alignment: Alignment.center,
                        child: Text(
                          '${(percent * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: percent > 0.3 ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}