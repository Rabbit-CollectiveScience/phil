import 'package:flutter/material.dart';
import '../l2_domain/models/workout.dart';

class ExerciseEditScreen extends StatefulWidget {
  final WorkoutExercise exercise;
  final int exerciseNumber;
  final Function(WorkoutExercise) onSave;
  final VoidCallback onDelete;

  const ExerciseEditScreen({
    super.key,
    required this.exercise,
    required this.exerciseNumber,
    required this.onSave,
    required this.onDelete,
  });

  @override
  State<ExerciseEditScreen> createState() => _ExerciseEditScreenState();
}

class _ExerciseEditScreenState extends State<ExerciseEditScreen> {
  late Map<String, TextEditingController> _controllers;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _controllers = {};

    // Initialize controllers for all parameters
    widget.exercise.parameters.forEach((key, value) {
      if (!key.endsWith('Unit') && key != 'bodyweight') {
        _controllers[key] = TextEditingController(text: value.toString());
        _controllers[key]!.addListener(() {
          setState(() {
            _hasChanges = true;
          });
        });
      }
    });
  }

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  void _saveChanges() {
    final updatedParameters = Map<String, dynamic>.from(
      widget.exercise.parameters,
    );

    _controllers.forEach((key, controller) {
      final text = controller.text.trim();
      if (text.isNotEmpty) {
        // Try to parse as int first, then double, otherwise keep as string
        final intValue = int.tryParse(text);
        if (intValue != null) {
          updatedParameters[key] = intValue;
        } else {
          final doubleValue = double.tryParse(text);
          if (doubleValue != null) {
            updatedParameters[key] = doubleValue;
          } else {
            updatedParameters[key] = text;
          }
        }
      }
    });

    final updatedExercise = WorkoutExercise(
      exerciseId: widget.exercise.exerciseId,
      name: widget.exercise.name,
      category: widget.exercise.category,
      muscleGroup: widget.exercise.muscleGroup,
      parameters: updatedParameters,
    );

    widget.onSave(updatedExercise);
    Navigator.pop(context);
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Delete Exercise',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Remove "${widget.exercise.name}" from this workout?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close edit screen
              widget.onDelete();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _confirmDiscard() {
    if (!_hasChanges) {
      Navigator.pop(context);
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Discard Changes',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'You have unsaved changes. Discard them?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Editing'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close edit screen
            },
            child: const Text('Discard', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_hasChanges) {
          _confirmDiscard();
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: _confirmDiscard,
          ),
          title: const Text(
            'Edit Exercise',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: _confirmDelete,
              tooltip: 'Delete exercise',
            ),
            TextButton(
              onPressed: _hasChanges ? _saveChanges : null,
              child: Text(
                'Save',
                style: TextStyle(
                  color: _hasChanges ? Colors.blue : Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Exercise Header
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _getMuscleGroupColor(
                            widget.exercise.muscleGroup,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${widget.exerciseNumber}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
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
                              widget.exercise.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _capitalizeFirstLetter(
                                widget.exercise.muscleGroup,
                              ),
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Parameters Section
                  const Text(
                    'Parameters',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Parameter Fields
                  ..._buildParameterFields(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildParameterFields() {
    final fields = <Widget>[];

    widget.exercise.parameters.forEach((key, value) {
      // Skip unit parameters and other meta fields
      if (key.endsWith('Unit') || key == 'bodyweight') return;

      final controller = _controllers[key];
      if (controller == null) return;

      final displayName = _formatParameterName(key);
      final unit = _getParameterUnit(key);

      fields.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                keyboardType: _getKeyboardType(key),
                decoration: InputDecoration(
                  suffixText: unit,
                  suffixStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[800]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[800]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });

    return fields.isNotEmpty
        ? fields
        : [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'No parameters for this exercise',
                style: TextStyle(color: Colors.grey[500], fontSize: 14),
              ),
            ),
          ];
  }

  String _formatParameterName(String key) {
    // Convert camelCase to Title Case
    final result = key.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => ' ${match.group(1)}',
    );
    return result[0].toUpperCase() + result.substring(1);
  }

  String? _getParameterUnit(String key) {
    final unitKey = '${key}Unit';
    if (widget.exercise.parameters.containsKey(unitKey)) {
      return widget.exercise.parameters[unitKey].toString();
    }

    if (key == 'holdDuration' || key == 'restBetweenSets') {
      return 'sec';
    }
    if (key == 'duration') {
      return 'min';
    }
    return null;
  }

  TextInputType _getKeyboardType(String key) {
    if (key == 'pace') {
      return TextInputType.text;
    }
    return const TextInputType.numberWithOptions(decimal: true);
  }

  Color _getMuscleGroupColor(String muscleGroup) {
    switch (muscleGroup.toLowerCase()) {
      case 'chest':
        return Colors.blue;
      case 'back':
        return Colors.green;
      case 'shoulders':
        return Colors.orange;
      case 'arms':
        return Colors.red;
      case 'legs':
        return Colors.purple;
      case 'core':
        return Colors.yellow.shade700;
      case 'cardio':
        return Colors.pink;
      case 'flexibility':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
