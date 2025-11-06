import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:novacole/components/loading_indicator.dart';
import 'package:novacole/models/master_crud_model.dart';
import 'package:novacole/pages/quiz/game_widgets.dart';

class QuizDisciplineSelect extends StatefulWidget {
  const QuizDisciplineSelect({super.key});

  @override
  QuizDisciplineSelectState createState() => QuizDisciplineSelectState();
}

class QuizDisciplineSelectState extends State<QuizDisciplineSelect> {
  List<Map<String, dynamic>> disciplines = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDisciplines();
  }

  Future<void> _fetchDisciplines() async {
    try {
      final fetchedDisciplines = await MasterCrudModel(
        'discipline',
      ).search(paginate: '0');
      setState(() {
        disciplines = List<Map<String, dynamic>>.from(fetchedDisciplines);
        isLoading = false;
      });
    } catch (e) {
      isLoading = false;
      if (kDebugMode) {
        debugPrint('Error fetching disciplines: $e');
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: LoadingIndicator())
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemCount: disciplines.length,
                itemBuilder: (context, index) {
                  final discipline = disciplines[index];
                  return ModernSelectionCard(
                    title: discipline['name'],
                    imageUrl: discipline['image_url'],
                    onTap: () => Navigator.of(context).pop(discipline),
                  );
                },
              ),
            ),
    );
  }
}
