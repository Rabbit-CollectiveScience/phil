import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l3_service/settings_service.dart';
import '../l3_service/unit_converter.dart';

class ExerciseFormScreen extends StatefulWidget {
  final String exerciseId;
  final String exerciseName;
  final String category;
  final String muscleGroup;
  final Map<String, dynamic>? initialParameters;
  final int? exerciseNumber;
  final Function(Map<String, dynamic>) onSave;
  final VoidCallback? onDelete;
  final DateTime? workoutDateTime;
  final Function(DateTime)? onDateTimeChanged;

  const ExerciseFormScreen({
    super.key,
    required this.exerciseId,
    required this.exerciseName,
    required this.category,
    required this.muscleGroup,
    this.initialParameters,
    this.exerciseNumber,
    required this.onSave,
    this.onDelete,
    this.workoutDateTime,
    this.onDateTimeChanged,
  });

  bool get isEditMode => initialParameters != null;

  @override
  State<ExerciseFormScreen> createState() => _ExerciseFormScreenState();
}

class _ExerciseFormScreenState extends State<ExerciseFormScreen> {
  Map<String, dynamic>? _schema;
  bool _isLoading = true;
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, bool> _booleanValues = {};
  bool _hasChanges = false;
  String _weightUnit = 'lbs';
  String _distanceUnit = 'miles';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _loadSchema();
  }

  Future<void> _loadPreferences() async {
    final settings = await SettingsService.getInstance();
    setState(() {
      _weightUnit = settings.weightUnit;
      _distanceUnit = settings.distanceUnit;
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadSchema() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/data/exercises/schemas/${widget.muscleGroup}/${widget.exerciseId}.json',
      );
      final data = json.decode(response);

      setState(() {
        _schema = data;
        _isLoading = false;
      });

      // Initialize controllers and boolean values
      if (data['parameters'] != null) {
        for (var param in data['parameters']) {
          final key = param['key'] as String;
          if (param['type'] == 'boolean') {
            _booleanValues[key] = widget.initialParameters?[key] ?? false;
          } else {
            // For edit mode, convert stored base units to display units
            String initialValue = '';
            if (widget.initialParameters?[key] != null) {
              final storedValue = widget.initialParameters![key];
              if (key == 'weight' && storedValue is num) {
                final displayValue = UnitConverter.weightFromBase(
                  storedValue.toDouble(),
                  _weightUnit,
                );
                initialValue = displayValue.round().toString();
              } else if (key == 'distance' && storedValue is num) {
                final displayValue = UnitConverter.distanceFromBase(
                  storedValue.toDouble(),
                  _distanceUnit,
                );
                initialValue = displayValue >= 1
                    ? displayValue.round().toString()
                    : displayValue.toStringAsFixed(2);
              } else {
                initialValue = storedValue.toString();
              }
            }
            _controllers[key] = TextEditingController(text: initialValue);
            _controllers[key]!.addListener(() {
              if (widget.isEditMode && !_hasChanges) {
                setState(() {
                  _hasChanges = true;
                });
              }
            });
          }
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading exercise: $e')));
      }
    }
  }

  bool _validateForm() {
    final parameters = _schema?['parameters'] as List?;
    if (parameters != null) {
      for (var param in parameters) {
        if (param['required'] == true) {
          final key = param['key'] as String;
          if (param['type'] == 'boolean') {
            continue; // Booleans always have a value
          } else {
            final value = _controllers[key]?.text.trim() ?? '';
            if (value.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${param['label']} is required'),
                  backgroundColor: Colors.red[700],
                ),
              );
              return false;
            }
          }
        }
      }
    }
    return true;
  }

  void _saveExercise() {
    if (!_validateForm()) return;

    final exerciseData = <String, dynamic>{
      'exerciseId': widget.exerciseId,
      'name': widget.exerciseName,
      'category': widget.category,
      'muscleGroup': widget.muscleGroup,
    };

    final parameters = <String, dynamic>{};

    // Collect all parameter values
    final schemaParams = _schema?['parameters'] as List?;
    if (schemaParams != null) {
      for (var param in schemaParams) {
        final key = param['key'] as String;

        if (param['type'] == 'boolean') {
          parameters[key] = _booleanValues[key] ?? false;
        } else {
          final text = _controllers[key]?.text.trim() ?? '';
          if (text.isNotEmpty) {
            // Parse value based on type
            if (param['type'] == 'number') {
              final doubleValue = double.tryParse(text);
              if (doubleValue != null) {
                // Convert to base units (kg for weight, km for distance)
                if (key == 'weight') {
                  parameters[key] = UnitConverter.weightToBase(
                    doubleValue,
                    _weightUnit,
                  );
                } else if (key == 'distance') {
                  parameters[key] = UnitConverter.distanceToBase(
                    doubleValue,
                    _distanceUnit,
                  );
                } else {
                  // For other numeric values (sets, reps, etc.), store as-is
                  final intValue = int.tryParse(text);
                  parameters[key] = intValue ?? doubleValue;
                }
              }
            } else {
              parameters[key] = text;
            }
          }
        }
      }
    }

    exerciseData['parameters'] = parameters;
    widget.onSave(exerciseData);
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
          'Remove "${widget.exerciseName}" from this workout?',
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
              Navigator.pop(context); // Close form screen
              widget.onDelete?.call();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _showDateTimePicker() async {
    if (widget.workoutDateTime == null) return;

    // Show date picker
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: widget.workoutDateTime!,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: _getMuscleGroupColor(widget.muscleGroup),
              onPrimary: Colors.white,
              surface: Colors.grey[900]!,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null) return;

    // Show time picker
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(widget.workoutDateTime!),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: _getMuscleGroupColor(widget.muscleGroup),
              onPrimary: Colors.white,
              surface: Colors.grey[900]!,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime == null) return;

    // Combine date and time
    final newDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    widget.onDateTimeChanged?.call(newDateTime);
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);

    String dateStr;
    if (date == today) {
      dateStr = 'Today';
    } else if (date == yesterday) {
      dateStr = 'Yesterday';
    } else {
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      dateStr =
          '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
    }

    final hour = dateTime.hour == 0
        ? 12
        : (dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour);
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';

    return '$dateStr at $hour:$minute $period';
  }

  void _confirmDiscard() {
    if (widget.isEditMode && !_hasChanges) {
      Navigator.pop(context);
      return;
    }

    if (widget.isEditMode) {
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
                Navigator.pop(context); // Close form screen
              },
              child: const Text('Discard', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.isEditMode && _hasChanges) {
          _confirmDiscard();
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF3A3A3A),
        appBar: AppBar(
          backgroundColor: const Color(0xFF3A3A3A),
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              widget.isEditMode ? Icons.close : Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: _confirmDiscard,
          ),
          title: Text(
            widget.isEditMode ? 'Edit Exercise' : 'Add Exercise',
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            if (widget.onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: _confirmDelete,
                tooltip: 'Delete exercise',
              ),
            TextButton(
              onPressed: (!widget.isEditMode || _hasChanges)
                  ? _saveExercise
                  : null,
              child: Text(
                widget.isEditMode ? 'Save' : 'Add',
                style: TextStyle(
                  color: (!widget.isEditMode || _hasChanges)
                      ? Colors.blue
                      : Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Exercise Header
                        Row(
                          children: [
                            if (widget.exerciseNumber != null)
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: _getMuscleGroupColor(
                                    widget.muscleGroup,
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
                            if (widget.exerciseNumber != null)
                              const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.exerciseName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _capitalizeFirstLetter(widget.muscleGroup),
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

                        const SizedBox(height: 24),

                        // Workout Date & Time Section (if editing)
                        if (widget.workoutDateTime != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Workout Date & Time',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              InkWell(
                                onTap: _showDateTimePicker,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[900],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey[800]!,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        color: Colors.grey[400],
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          _formatDateTime(
                                            widget.workoutDateTime!,
                                          ),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        Icons.edit,
                                        color: Colors.grey[600],
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),

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
    final parameters = _schema?['parameters'] as List?;
    if (parameters == null || parameters.isEmpty) {
      return [
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

    final fields = <Widget>[];

    for (var param in parameters) {
      final key = param['key'] as String;
      final label = param['label'] as String;
      final type = param['type'] as String;
      final required = param['required'] == true;

      // Determine display unit based on user preference
      String? displayUnit;
      if (key == 'weight') {
        displayUnit = _weightUnit;
      } else if (key == 'distance') {
        displayUnit = _distanceUnit;
      } else {
        displayUnit = param['unit'] as String?;
      }

      if (type == 'boolean') {
        fields.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                Switch(
                  value: _booleanValues[key] ?? false,
                  onChanged: (value) {
                    setState(() {
                      _booleanValues[key] = value;
                      if (widget.isEditMode) {
                        _hasChanges = true;
                      }
                    });
                  },
                  activeColor: Colors.blue,
                ),
              ],
            ),
          ),
        );
      } else {
        fields.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (required)
                      const Text(
                        ' *',
                        style: TextStyle(color: Colors.red, fontSize: 14),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _controllers[key],
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  keyboardType: type == 'number'
                      ? const TextInputType.numberWithOptions(decimal: true)
                      : type == 'duration'
                      ? TextInputType.number
                      : TextInputType.text,
                  decoration: InputDecoration(
                    suffixText: displayUnit,
                    suffixStyle: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
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
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 2,
                      ),
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
      }
    }

    return fields;
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
