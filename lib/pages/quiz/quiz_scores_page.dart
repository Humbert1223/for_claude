import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:novacole/pages/quiz/models/quiz_user_model.dart';
import 'package:novacole/pages/quiz/services/quiz_user_service.dart';
import 'package:novacole/pages/quiz/quiz_home_page.dart';
import 'package:novacole/pages/quiz/achievements_page.dart';

class QuizScoresPage extends StatefulWidget {
  const QuizScoresPage({super.key});

  @override
  QuizScoresPageState createState() => QuizScoresPageState();
}

class QuizScoresPageState extends State<QuizScoresPage>
    with SingleTickerProviderStateMixin {
  QuizUser? currentUser;
  List<QuizScore> scores = [];
  String filterBy = 'all'; // all, today, week, month
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadScores();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadScores() {
    setState(() {
      currentUser = QuizUserService.getCurrentUser();
      if (currentUser != null && currentUser!.scores != null) {
        scores = List.from(currentUser!.scores!);
        scores.sort((a, b) => b.playedAt.compareTo(a.playedAt));
        _applyFilter();
      }
    });
  }

  void _applyFilter() {
    final now = DateTime.now();
    final allScores = List<QuizScore>.from(currentUser?.scores ?? []);

    setState(() {
      switch (filterBy) {
        case 'today':
          scores = allScores.where((score) {
            return score.playedAt.year == now.year &&
                score.playedAt.month == now.month &&
                score.playedAt.day == now.day;
          }).toList();
          break;
        case 'week':
          final weekAgo = now.subtract(const Duration(days: 7));
          scores = allScores.where((score) {
            return score.playedAt.isAfter(weekAgo);
          }).toList();
          break;
        case 'month':
          scores = allScores.where((score) {
            return score.playedAt.year == now.year &&
                score.playedAt.month == now.month;
          }).toList();
          break;
        default:
          scores = allScores;
      }
      scores.sort((a, b) => b.playedAt.compareTo(a.playedAt));
    });
  }

  Map<String, dynamic> _calculateStats() {
    if (scores.isEmpty) {
      return {
        'total': 0,
        'average': 0.0,
        'best': 0,
        'totalQuestions': 0,
      };
    }

    final totalScore = scores.fold<int>(0, (sum, score) => sum + score.score);
    final totalQuestions = scores.fold<int>(
      0,
          (sum, score) => sum + score.totalQuestions,
    );
    final bestScore = scores.map((s) => s.percentage).reduce(
          (a, b) => a > b ? a : b,
    );

    return {
      'total': scores.length,
      'average': totalQuestions > 0 ? (totalScore / totalQuestions * 100) : 0.0,
      'best': bestScore,
      'totalQuestions': totalQuestions,
    };
  }

  @override
  Widget build(BuildContext context) {
    final stats = _calculateStats();

    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/quiz_background.jpeg"),
            fit: BoxFit.cover,
            opacity: 0.2,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header avec stats
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          child: Text(
                            currentUser?.name[0].toUpperCase() ?? '?',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentUser?.name ?? 'Joueur',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Historique des scores',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.emoji_events, size: 30),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const AchievementsPage(),
                              ),
                            );
                          },
                          tooltip: 'Succès',
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatCard(
                          'Parties',
                          '${stats['total']}',
                          Icons.gamepad,
                          context,
                        ),
                        _buildStatCard(
                          'Moyenne',
                          '${stats['average'].toStringAsFixed(1)}%',
                          Icons.trending_up,
                          context,
                        ),
                        _buildStatCard(
                          'Meilleur',
                          '${stats['best'].toStringAsFixed(1)}%',
                          Icons.star,
                          context,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Tabs
              TabBar(
                controller: _tabController,
                labelColor: Theme.of(context).colorScheme.primary,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Theme.of(context).colorScheme.primary,
                tabs: [
                  Tab(text: 'Graphique'),
                  Tab(text: 'Liste'),
                ],
              ),
              // Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildGraphView(),
                    _buildListView(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
        heroTag: "backBtn",
        onPressed: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const QuizHomePage()),
          );
        },
        child: const RotatedBox(
          quarterTurns: 2,
          child: Icon(
            FontAwesomeIcons.shareFromSquare,
            color: Colors.red,
          ),
        ),
      ),
    );
  }

  Widget _buildGraphView() {
    if (scores.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.show_chart,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 20),
            Text(
              'Pas de données',
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Évolution de vos performances',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey[300],
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() < scores.length) {
                          return Text(
                            '${value.toInt() + 1}',
                            style: const TextStyle(fontSize: 12),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 20,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}%',
                          style: const TextStyle(fontSize: 12),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.grey[300]!),
                ),
                minX: 0,
                maxX: (scores.length - 1).toDouble(),
                minY: 0,
                maxY: 100,
                lineBarsData: [
                  LineChartBarData(
                    spots: scores.asMap().entries.map((entry) {
                      return FlSpot(
                        entry.key.toDouble(),
                        entry.value.percentage,
                      );
                    }).toList(),
                    isCurved: true,
                    color: Theme.of(context).colorScheme.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Theme.of(context).colorScheme.primary,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.1),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                      return touchedBarSpots.map((barSpot) {
                        final score = scores[barSpot.x.toInt()];
                        return LineTooltipItem(
                          '${score.percentage.toStringAsFixed(1)}%\n${score.score}/${score.totalQuestions}',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          _buildInsights(),
        ],
      ),
    );
  }

  Widget _buildInsights() {
    if (scores.length < 2) return const SizedBox();

    final last5 = scores.take(5).toList();
    final avgLast5 = last5.fold<double>(0, (sum, s) => sum + s.percentage) /
        last5.length;

    final previous5 = scores.length > 5 ? scores.skip(5).take(5).toList() : [];
    final avgPrevious5 = previous5.isEmpty
        ? 0.0
        : previous5.fold<double>(0, (sum, s) => sum + s.percentage) /
        previous5.length;

    final trend = avgLast5 - avgPrevious5;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Analyse',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  trend > 0
                      ? Icons.trending_up
                      : trend < 0
                      ? Icons.trending_down
                      : Icons.trending_flat,
                  color: trend > 0
                      ? Colors.green
                      : trend < 0
                      ? Colors.red
                      : Colors.orange,
                  size: 30,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    trend > 0
                        ? 'En progression ! +${trend.toStringAsFixed(1)}% sur les 5 dernières parties'
                        : trend < 0
                        ? 'Légère baisse de ${trend.abs().toStringAsFixed(1)}% sur les 5 dernières parties'
                        : 'Performance stable',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView() {
    return Column(
      children: [
        // Filtres
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Tout', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip('Aujourd\'hui', 'today'),
                const SizedBox(width: 8),
                _buildFilterChip('7 jours', 'week'),
                const SizedBox(width: 8),
                _buildFilterChip('Ce mois', 'month'),
              ],
            ),
          ),
        ),
        // Liste des scores
        Expanded(
          child: scores.isEmpty
              ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.emoji_events_outlined,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 20),
                Text(
                  'Aucun score',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Jouez pour voir vos scores ici',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: scores.length,
            itemBuilder: (context, index) {
              return _buildScoreCard(scores[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String label,
      String value,
      IconData icon,
      BuildContext context,
      ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = filterBy == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          filterBy = value;
          _applyFilter();
        });
      },
      selectedColor: Theme.of(context).colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildScoreCard(QuizScore score) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final percentage = score.percentage;
    final color = percentage >= 80
        ? Colors.green
        : percentage >= 50
        ? Colors.orange
        : Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          _showScoreDetails(score);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Pourcentage circulaire
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.2),
                  border: Border.all(color: color, width: 3),
                ),
                child: Center(
                  child: Text(
                    '${percentage.toInt()}%',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Infos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${score.score}/${score.totalQuestions}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateFormat.format(score.playedAt),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (score.usedTimer)
                      Row(
                        children: [
                          Icon(
                            Icons.timer,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Avec chronomètre',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showScoreDetails(QuizScore score) {
    final dateFormat = DateFormat('dd/MM/yyyy à HH:mm');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Détails du score'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Score', '${score.score}/${score.totalQuestions}'),
            _buildDetailRow('Pourcentage', '${score.percentage.toStringAsFixed(1)}%'),
            _buildDetailRow('Date', dateFormat.format(score.playedAt)),
            _buildDetailRow(
              'Chronomètre',
              score.usedTimer ? 'Activé' : 'Désactivé',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}