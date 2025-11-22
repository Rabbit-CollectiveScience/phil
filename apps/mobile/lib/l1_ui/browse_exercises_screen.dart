import 'package:flutter/material.dart';
import 'exercise_list_screen.dart';

class BrowseExercisesScreen extends StatelessWidget {
  const BrowseExercisesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Browse Exercises',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select a category',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildCategoryCard(
                      context,
                      'Chest',
                      Icons.fitness_center,
                      Colors.blue[700]!,
                      'chest',
                    ),
                    _buildCategoryCard(
                      context,
                      'Back',
                      Icons.accessibility_new,
                      Colors.green[700]!,
                      'back',
                    ),
                    _buildCategoryCard(
                      context,
                      'Shoulders',
                      Icons.work_outline,
                      Colors.orange[700]!,
                      'shoulders',
                    ),
                    _buildCategoryCard(
                      context,
                      'Arms',
                      Icons.sports_martial_arts,
                      Colors.red[700]!,
                      'arms',
                    ),
                    _buildCategoryCard(
                      context,
                      'Legs',
                      Icons.directions_run,
                      Colors.purple[700]!,
                      'legs',
                    ),
                    _buildCategoryCard(
                      context,
                      'Core',
                      Icons.square,
                      Colors.yellow[700]!,
                      'core',
                    ),
                    _buildCategoryCard(
                      context,
                      'Cardio',
                      Icons.favorite,
                      Colors.pink[700]!,
                      'cardio',
                    ),
                    _buildCategoryCard(
                      context,
                      'Flexibility',
                      Icons.self_improvement,
                      Colors.teal[700]!,
                      'flexibility',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    String category,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExerciseListScreen(category: category),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
