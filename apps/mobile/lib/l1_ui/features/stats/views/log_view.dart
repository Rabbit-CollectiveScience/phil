import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../../l2_domain/use_cases/workout_sets/get_workout_sets_by_date_use_case.dart';
import '../../../../l2_domain/use_cases/workout_sets/get_today_completed_list_use_case.dart';
import '../../../../l2_domain/models/exercise.dart';
import '../../../../l2_domain/models/field_type_enum.dart';

class LogView extends StatefulWidget {
  const LogView({super.key});

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  DateTime _selectedDate = DateTime.now();
  List<WorkoutSetWithDetails> _sets = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadWorkoutSetsForDate();
  }

  Future<void> _loadWorkoutSetsForDate() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final useCase = GetIt.instance<GetWorkoutSetsByDateUseCase>();
      final sets = await useCase.execute(date: _selectedDate);

      setState(() {
        _sets = sets;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  String _formatDate(DateTime date) {
    final monthNames = [
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
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final selectedDay = DateTime(date.year, date.month, date.day);

    if (selectedDay == today) {
      return 'Today - ${monthNames[date.month - 1]} ${date.day}, ${date.year}';
    } else if (selectedDay == yesterday) {
      return 'Yesterday - ${monthNames[date.month - 1]} ${date.day}, ${date.year}';
    } else {
      return '${monthNames[date.month - 1]} ${date.day}, ${date.year}';
    }
  }

  void _previousDay() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    });
    _loadWorkoutSetsForDate();
  }

  void _nextDay() {
    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 1));
    });
    _loadWorkoutSetsForDate();
  }

  bool _isToday() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );
    return selected == today;
  }

  @override
  Widget build(BuildContext context) {
    // Loading state
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.limeGreen),
      );
    }

    // Error state
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: AppColors.error, size: 48),
              const SizedBox(height: 16),
              Text(
                'Error loading sets',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.offWhite,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.offWhite.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final hasSets = _sets.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: _previousDay,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.boldGrey,
                    borderRadius: BorderRadius.zero,
                  ),
                  child: Icon(
                    Icons.chevron_left,
                    color: AppColors.offWhite,
                    size: 20,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.dark(
                            primary: AppColors.limeGreen,
                            onPrimary: AppColors.pureBlack,
                            surface: AppColors.boldGrey,
                            onSurface: AppColors.offWhite,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedDate = picked;
                    });
                    _loadWorkoutSetsForDate();
                  }
                },
                child: Text(
                  _formatDate(_selectedDate),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.offWhite,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _isToday() ? null : _nextDay,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _isToday()
                        ? AppColors.boldGrey.withOpacity(0.3)
                        : AppColors.boldGrey,
                    borderRadius: BorderRadius.zero,
                  ),
                  child: Icon(
                    Icons.chevron_right,
                    color: _isToday()
                        ? AppColors.offWhite.withOpacity(0.3)
                        : AppColors.offWhite,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Sets list or empty state
          if (hasSets) ...[
            ..._buildGroupedSets(),
            const SizedBox(height: 20),
            _buildAddButton(),
          ] else
            _buildEmptyState(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  List<Widget> _buildGroupedSets() {
    final List<Widget> widgets = [];
    String? currentExercise;

    for (int i = 0; i < _sets.length; i++) {
      final setWithDetails = _sets[i];
      final exerciseName = setWithDetails.exerciseName;

      // Add exercise header if this is a new exercise
      if (exerciseName != currentExercise) {
        if (currentExercise != null) {
          widgets.add(const SizedBox(height: 20));
        }
        widgets.add(_buildExerciseHeader(exerciseName));
        widgets.add(const SizedBox(height: 8));
        currentExercise = exerciseName;
      }

      // Add set row with dynamic fields
      widgets.add(_buildSetRow(setWithDetails, i));
    }

    return widgets;
  }

  Widget _buildExerciseHeader(String exerciseName) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        exerciseName,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w900,
          color: AppColors.offWhite,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  String _formatSetValues(Exercise? exercise, Map<String, dynamic>? values) {
    if (exercise == null || values == null || values.isEmpty) {
      return 'No data';
    }

    // Build display string based on exercise field definitions
    final parts = <String>[];

    for (final field in exercise.fields) {
      if (values.containsKey(field.name)) {
        final value = values[field.name];
        final unit = field.unit;

        // Format based on field type
        String formattedValue;
        if (field.type == FieldTypeEnum.number) {
          formattedValue = '${value}${unit.isNotEmpty ? " $unit" : ""}';
        } else if (field.type == FieldTypeEnum.duration) {
          formattedValue = '${value}${unit.isNotEmpty ? " $unit" : ""}';
        } else {
          formattedValue = '$value${unit.isNotEmpty ? " $unit" : ""}';
        }

        parts.add(formattedValue);
      }
    }

    return parts.isEmpty ? 'No data' : parts.join(' × ');
  }

  Widget _buildSetRow(WorkoutSetWithDetails setWithDetails, int index) {
    // Calculate set number by counting previous sets of same exercise
    int setNumber = 1;
    for (int i = 0; i < index; i++) {
      if (_sets[i].exerciseName == setWithDetails.exerciseName) {
        setNumber++;
      }
    }

    final displayString = _formatSetValues(
      setWithDetails.exercise,
      setWithDetails.workoutSet.values,
    );
    return Dismissible(
      key: Key('set_$index'),
      background: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.blue[400],
          borderRadius: BorderRadius.zero,
        ),
        alignment: Alignment.centerLeft,
        child: Icon(Icons.edit, color: Colors.white, size: 20),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red[400],
          borderRadius: BorderRadius.zero,
        ),
        alignment: Alignment.centerRight,
        child: Icon(Icons.delete, color: Colors.white, size: 20),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          // Delete - show confirmation
          return await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: AppColors.boldGrey,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                title: Text(
                  'Delete Set',
                  style: TextStyle(
                    color: AppColors.offWhite,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                content: Text(
                  'Are you sure you want to delete this set?',
                  style: TextStyle(color: AppColors.offWhite),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: AppColors.offWhite),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(
                      'Delete',
                      style: TextStyle(color: Colors.red[300]),
                    ),
                  ),
                ],
              );
            },
          );
        } else {
          // Edit - just return false to not dismiss
          // TODO: Open edit dialog
          return false;
        }
      },
      onDismissed: (direction) {
        // TODO: Handle actual deletion
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.zero,
          border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.limeGreen.withOpacity(0.15),
                borderRadius: BorderRadius.zero,
              ),
              alignment: Alignment.center,
              child: Text(
                '$setNumber',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: AppColors.darkText,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                displayString,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: () {
        _showAddSetDialog();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.limeGreen,
          borderRadius: BorderRadius.zero,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: AppColors.pureBlack, size: 20),
            const SizedBox(width: 8),
            Text(
              'Add Set',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: AppColors.pureBlack,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddSetDialog() {
    final TextEditingController exerciseController = TextEditingController();
    final TextEditingController repsController = TextEditingController();
    final TextEditingController weightController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: AppColors.boldGrey,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Set',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.offWhite,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatDate(_selectedDate),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.offWhite.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 24),
                // Exercise name field
                Text(
                  'EXERCISE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: AppColors.offWhite.withOpacity(0.7),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: exerciseController,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.offWhite,
                  ),
                  decoration: InputDecoration(
                    hintText: 'e.g., Bench Press',
                    hintStyle: TextStyle(
                      color: AppColors.offWhite.withOpacity(0.3),
                    ),
                    filled: true,
                    fillColor: AppColors.deepCharcoal,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Reps and Weight row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'REPS',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: AppColors.offWhite.withOpacity(0.7),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: repsController,
                            keyboardType: TextInputType.number,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.offWhite,
                            ),
                            decoration: InputDecoration(
                              hintText: '10',
                              hintStyle: TextStyle(
                                color: AppColors.offWhite.withOpacity(0.3),
                              ),
                              filled: true,
                              fillColor: AppColors.deepCharcoal,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.zero,
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'WEIGHT (KG)',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: AppColors.offWhite.withOpacity(0.7),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: weightController,
                            keyboardType: TextInputType.number,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.offWhite,
                            ),
                            decoration: InputDecoration(
                              hintText: '80',
                              hintStyle: TextStyle(
                                color: AppColors.offWhite.withOpacity(0.3),
                              ),
                              filled: true,
                              fillColor: AppColors.deepCharcoal,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.zero,
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.deepCharcoal,
                            borderRadius: BorderRadius.zero,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: AppColors.offWhite,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          // TODO: Save the set
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.limeGreen,
                            borderRadius: BorderRadius.zero,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Add Set',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: AppColors.pureBlack,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fitness_center,
              size: 64,
              color: AppColors.offWhite.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No sets logged for this day',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.offWhite.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
