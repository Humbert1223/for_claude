import 'package:flutter/material.dart';
import 'package:novacole/components/loading_indicator.dart';
import 'package:novacole/models/master_crud_model.dart';

class QuizSerieSelect extends StatefulWidget {
  const QuizSerieSelect({super.key}); // Added const constructor

  @override
  QuizSerieSelectState createState() =>
      QuizSerieSelectState(); // Simplified syntax
}

class QuizSerieSelectState extends State<QuizSerieSelect> {
  List<Map<String, dynamic>> series = [];
  bool isLoading = true; // Renamed for clarity

  @override
  void initState() {
    super.initState();
    _fetchLevels();
  }

  Future<void> _fetchLevels() async {
    try {
      final fetchedLevels =
          await MasterCrudModel('serie').search(paginate: '0');
      setState(() {
        series = List<Map<String, dynamic>>.from(fetchedLevels);
      });
    } finally {
      setState(() {
        isLoading = false;
      });
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
          ? const Center(child: LoadingIndicator()) // Added const
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  // Added const
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemCount: series.length,
                itemBuilder: (context, index) {
                  final level = series[index];
                  return _buildSerieCard(level);
                },
              ),
            ),
    );
  }

  Widget _buildSerieCard(Map<String, dynamic> level) {
    // Extracted card building to a separate method
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(10),
        /*image: const DecorationImage(
          image: AssetImage('assets/images/degree.png'),
        ),*/
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pop(level);
        },
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0x903C3C3C), // Added const
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              "${level['name']}",
              textAlign: TextAlign.center,
              style: const TextStyle(
                // Added const
                fontSize: 30.0,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
