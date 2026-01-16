import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/providers/preferences_provider.dart';
import '../../../shared/utils/unit_formatters.dart';
import '../../../../l2_domain/use_cases/workout_sets/get_workout_sets_by_date_use_case.dart'
    as byDate;
import '../../../../l2_domain/use_cases/workout_sets/remove_workout_set_use_case.dart';
import '../../../../l2_domain/use_cases/workout_sets/record_workout_set_use_case.dart';
import '../../../../l2_domain/use_cases/exercises/search_exercises_use_case.dart';
import '../../../../l2_domain/models/exercises/exercise.dart';
import '../../../../l2_domain/models/exercises/strength_exercise.dart';
import '../../../../l2_domain/models/exercises/bodyweight_exercise.dart';
import '../../../../l2_domain/models/exercises/free_weight_exercise.dart';
import '../../../../l2_domain/models/exercises/machine_exercise.dart';
import '../../../../l2_domain/models/exercises/assisted_machine_exercise.dart';
import '../../../../l2_domain/models/exercises/isometric_exercise.dart';
import '../../../../l2_domain/models/exercises/distance_cardio_exercise.dart';
import '../../../../l2_domain/models/exercises/duration_cardio_exercise.dart';
import '../../../../l2_domain/models/workout_sets/workout_set.dart';
import '../../../../l2_domain/models/workout_sets/weighted_workout_set.dart';
import '../../../../l2_domain/models/workout_sets/bodyweight_workout_set.dart';
import '../../../../l2_domain/models/workout_sets/assisted_machine_workout_set.dart';
import '../../../../l2_domain/models/workout_sets/isometric_workout_set.dart';
import '../../../../l2_domain/models/workout_sets/distance_cardio_workout_set.dart';
import '../../../../l2_domain/models/workout_sets/duration_cardio_workout_set.dart';
import 'package:uuid/uuid.dart';

class LogView extends StatefulWidget {
  const LogView({super.key});

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  DateTime _selectedDate = DateTime.now();
  List<byDate.WorkoutSetWithDetails> _sets = [];
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
      final useCase = GetIt.instance<byDate.GetWorkoutSetsByDateUseCase>();
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

    // Calculate approximate content height
    // Each set row ~60px, header ~30px, spacing ~28px per exercise group
    double estimatedContentHeight = 0;
    if (hasSets) {
      String? lastExercise;
      for (var set in _sets) {
        if (set.exerciseName != lastExercise) {
          estimatedContentHeight += 30; // Header
          estimatedContentHeight += 8; // Spacing after header
          if (lastExercise != null) {
            estimatedContentHeight += 20; // Spacing between groups
          }
          lastExercise = set.exerciseName;
        }
        estimatedContentHeight += 60; // Set row with margin
      }
      estimatedContentHeight += 20; // Bottom spacing before button
    }

    final screenHeight = MediaQuery.of(context).size.height;
    final availableHeight =
        screenHeight - 250; // Account for date nav + padding
    final useBottomLayout =
        !hasSets || estimatedContentHeight < availableHeight;

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
          if (useBottomLayout)
            // Short list or empty - button at bottom
            SizedBox(
              height: availableHeight,
              child: Column(
                children: [
                  if (hasSets) ..._buildGroupedSets(),
                  if (!hasSets)
                    Expanded(child: Center(child: _buildEmptyState())),
                  if (hasSets) Expanded(child: SizedBox()),
                  _buildAddButton(),
                ],
              ),
            )
          else
          // Long list - button after list
          ...[
            ..._buildGroupedSets(),
            const SizedBox(height: 20),
            _buildAddButton(),
          ],
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

  /// Format workout set values for display based on workout set type
  String _formatSetValues(byDate.WorkoutSetWithDetails setDetails) {
    final formatters = context.read<PreferencesProvider>().formatters;
    final workoutSet = setDetails.workoutSet;
    final baseFormat = workoutSet.formatForDisplay();

    // Add units back based on workout set type
    if (workoutSet is WeightedWorkoutSet) {
      final weight = workoutSet.weight;
      if (weight != null) {
        final parts = baseFormat.split(' × ');
        if (parts.length == 2) {
          return '${formatters.formatWeight(weight)} × ${parts[1]}';
        }
      }
    } else if (workoutSet is BodyweightWorkoutSet) {
      final additionalWeight = workoutSet.additionalWeight;
      if (additionalWeight != null && additionalWeight.kg > 0) {
        final parts = baseFormat.split(' + ');
        if (parts.length == 2) {
          return '${parts[0]} + ${formatters.formatWeight(additionalWeight)}';
        }
      }
    } else if (workoutSet is AssistedMachineWorkoutSet) {
      final assistanceWeight = workoutSet.assistanceWeight;
      if (assistanceWeight != null) {
        final parts = baseFormat.split(' · ');
        if (parts.length == 2) {
          final assistanceParts = parts[1].split(' assistance');
          if (assistanceParts.length == 2) {
            return '${parts[0]} · ${formatters.formatWeight(assistanceWeight)} assistance';
          }
        }
      }
    } else if (workoutSet is DistanceCardioWorkoutSet) {
      final distance = workoutSet.distance;
      if (distance != null) {
        final parts = baseFormat.split(' · ');
        if (parts.length == 2) {
          return '${formatters.formatDistance(distance)} · ${parts[1]}';
        }
      }
    } else if (workoutSet is IsometricWorkoutSet) {
      final weight = workoutSet.weight;
      if (weight != null && weight.kg > 0) {
        final parts = baseFormat.split(' · ');
        if (parts.length == 2) {
          if (parts[1].startsWith('BW + ')) {
            return '${parts[0]} · BW + ${formatters.formatWeight(weight)}';
          } else {
            return '${parts[0]} · ${formatters.formatWeight(weight)}';
          }
        }
      }
    }

    return baseFormat;
  }

  Widget _buildSetRow(byDate.WorkoutSetWithDetails setWithDetails, int index) {
    // Calculate set number by counting previous sets of same exercise
    int setNumber = 1;
    for (int i = 0; i < index; i++) {
      if (_sets[i].exerciseName == setWithDetails.exerciseName) {
        setNumber++;
      }
    }

    final displayString = _formatSetValues(setWithDetails);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Slidable(
        key: Key('set_${setWithDetails.workoutSet.id}'),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.25,
          children: [
            CustomSlidableAction(
              onPressed: (context) async {
                await _deleteSet(setWithDetails.workoutSet.id);
              },
              backgroundColor: AppColors.error,
              borderRadius: BorderRadius.zero,
              padding: EdgeInsets.zero,
              child: const Icon(Icons.delete, color: Colors.white, size: 24),
            ),
          ],
        ),
        child: Container(
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

  Future<void> _deleteSet(String setId) async {
    try {
      final removeUseCase = GetIt.instance<RemoveWorkoutSetUseCase>();
      await removeUseCase.execute(setId);

      // Reload data after deletion
      await _loadWorkoutSetsForDate();

      // Show success snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Set deleted',
              style: TextStyle(color: AppColors.offWhite),
            ),
            backgroundColor: AppColors.error,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error deleting workout set: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete set'),
            backgroundColor: AppColors.error,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _showAddSetDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _AddSetDialog(
          selectedDate: _selectedDate,
          onSetAdded: () {
            // Reload the list after a set is added
            _loadWorkoutSetsForDate();
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Column(
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
    );
  }
}

class _AddSetDialog extends StatefulWidget {
  final DateTime selectedDate;
  final VoidCallback onSetAdded;

  const _AddSetDialog({required this.selectedDate, required this.onSetAdded});

  @override
  State<_AddSetDialog> createState() => _AddSetDialogState();
}

class _AddSetDialogState extends State<_AddSetDialog> {
  final TextEditingController _searchController = TextEditingController();
  Exercise? _selectedExercise;
  final Map<String, TextEditingController> _fieldControllers = {};
  bool _showSuggestions = false;
  List<Exercise> _searchResults = [];
  bool _isSearching = false;
  bool _isSaving = false;

  // Remove mock exercises - we'll load from database

  @override
  void dispose() {
    _searchController.dispose();
    for (var controller in _fieldControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _searchExercises(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _showSuggestions = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _showSuggestions = true;
    });

    try {
      final searchUseCase = GetIt.instance<SearchExercisesUseCase>();
      final results = await searchUseCase.execute(searchQuery: query);

      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      debugPrint('Error searching exercises: $e');
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
    }
  }

  List<Exercise> get _filteredExercises => _searchResults;

  void _selectExercise(Exercise exercise) {
    setState(() {
      _selectedExercise = exercise;
      _searchController.text = exercise.name;
      _showSuggestions = false;

      // Create controllers based on exercise type
      _fieldControllers.clear();
      if (exercise is IsometricExercise) {
        _fieldControllers['duration'] = TextEditingController();
        _fieldControllers['weight'] = TextEditingController();
      } else if (exercise is AssistedMachineExercise) {
        _fieldControllers['assistanceWeight'] = TextEditingController();
        _fieldControllers['reps'] = TextEditingController();
      } else if (exercise is BodyweightExercise) {
        _fieldControllers['reps'] = TextEditingController();
        _fieldControllers['weight'] = TextEditingController();
      } else if (exercise is StrengthExercise) {
        _fieldControllers['weight'] = TextEditingController();
        _fieldControllers['reps'] = TextEditingController();
      } else if (exercise is DistanceCardioExercise) {
        _fieldControllers['distance'] = TextEditingController();
        _fieldControllers['duration'] = TextEditingController();
      } else if (exercise is DurationCardioExercise) {
        _fieldControllers['duration'] = TextEditingController();
      }
    });
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

  List<Widget> _buildInputFields(UnitFormatters formatters) {
    final exercise = _selectedExercise!;
    final widgets = <Widget>[];

    widgets.add(const SizedBox(height: 20));

    if (exercise is IsometricExercise) {
      // Duration field
      widgets.add(
        _buildInputField(
          label: 'DURATION',
          controller: _fieldControllers['duration']!,
          hint: 'Enter duration',
          suffix: 'sec',
        ),
      );

      // Weight field
      widgets.add(
        _buildInputField(
          label: 'WEIGHT',
          controller: _fieldControllers['weight']!,
          hint: 'Enter weight (optional)',
          suffix: formatters.getWeightUnit(),
        ),
      );
    } else if (exercise is BodyweightExercise) {
      // Reps field
      widgets.add(
        _buildInputField(
          label: 'REPS',
          controller: _fieldControllers['reps']!,
          hint: 'Enter reps',
          suffix: null,
        ),
      );

      // Weight field (optional additional weight)
      widgets.add(
        _buildInputField(
          label: 'WEIGHT',
          controller: _fieldControllers['weight']!,
          hint: 'Enter additional weight (optional)',
          suffix: formatters.getWeightUnit(),
        ),
      );
    } else if (exercise is AssistedMachineExercise) {
      // Assistance Weight field
      widgets.add(
        _buildInputField(
          label: 'ASSISTANCE',
          controller: _fieldControllers['assistanceWeight']!,
          hint: 'Enter assistance weight',
          suffix: formatters.getWeightUnit(),
        ),
      );

      // Reps field
      widgets.add(
        _buildInputField(
          label: 'REPS',
          controller: _fieldControllers['reps']!,
          hint: 'Enter reps',
          suffix: null,
        ),
      );
    } else if (exercise is StrengthExercise) {
      // Weight field
      widgets.add(
        _buildInputField(
          label: 'WEIGHT',
          controller: _fieldControllers['weight']!,
          hint: 'Enter weight',
          suffix: formatters.getWeightUnit(),
        ),
      );

      // Reps field
      widgets.add(
        _buildInputField(
          label: 'REPS',
          controller: _fieldControllers['reps']!,
          hint: 'Enter reps',
          suffix: null,
        ),
      );
    } else if (exercise is DistanceCardioExercise) {
      // Distance field
      widgets.add(
        _buildInputField(
          label: 'DISTANCE',
          controller: _fieldControllers['distance']!,
          hint: 'Enter distance',
          suffix: formatters.getDistanceUnit(),
        ),
      );

      // Duration field
      widgets.add(
        _buildInputField(
          label: 'DURATION',
          controller: _fieldControllers['duration']!,
          hint: 'Enter duration',
          suffix: 'min',
        ),
      );
    } else if (exercise is DurationCardioExercise) {
      // Duration field
      widgets.add(
        _buildInputField(
          label: 'DURATION',
          controller: _fieldControllers['duration']!,
          hint: 'Enter duration',
          suffix: 'min',
        ),
      );
    }

    return widgets;
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required String? suffix,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: AppColors.offWhite.withOpacity(0.7),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.offWhite,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: AppColors.offWhite.withOpacity(0.3)),
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
              suffixText: suffix,
              suffixStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.offWhite.withOpacity(0.5),
              ),
            ),
            onChanged: (value) {
              setState(() {}); // Rebuild to update button state
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formatters = context.watch<PreferencesProvider>().formatters;
    final canSubmit = _selectedExercise != null;

    return Dialog(
      backgroundColor: AppColors.boldGrey,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
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
              _formatDate(widget.selectedDate),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.offWhite.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),

            // Exercise search field
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
              controller: _searchController,
              autofocus: true,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.offWhite,
              ),
              decoration: InputDecoration(
                hintText: 'Search exercises...',
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
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: AppColors.offWhite.withOpacity(0.5),
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _selectedExercise = null;
                            _fieldControllers.clear();
                            _showSuggestions = false;
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _showSuggestions = value.isNotEmpty;
                  if (_selectedExercise != null &&
                      _selectedExercise!.name != value) {
                    _selectedExercise = null;
                    _fieldControllers.clear();
                  }
                });
                // Search as user types
                _searchExercises(value);
              },
            ),

            // Autocomplete suggestions
            if (_showSuggestions) ...[
              const SizedBox(height: 8),
              if (_isSearching)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.deepCharcoal,
                    borderRadius: BorderRadius.zero,
                  ),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.limeGreen,
                      strokeWidth: 2,
                    ),
                  ),
                )
              else if (_filteredExercises.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.deepCharcoal,
                    borderRadius: BorderRadius.zero,
                  ),
                  child: Center(
                    child: Text(
                      'No exercises found',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.offWhite.withOpacity(0.5),
                      ),
                    ),
                  ),
                )
              else
                Container(
                  constraints: BoxConstraints(maxHeight: 200),
                  decoration: BoxDecoration(
                    color: AppColors.deepCharcoal,
                    borderRadius: BorderRadius.zero,
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _filteredExercises.length,
                    itemBuilder: (context, index) {
                      final exercise = _filteredExercises[index];

                      // Generate field preview based on exercise type
                      String fieldPreview = '';
                      final weightUnit = formatters.getWeightUnit();
                      final distanceUnit = formatters.getDistanceUnit();
                      if (exercise is IsometricExercise) {
                        fieldPreview = 'sec · $weightUnit';
                      } else if (exercise is AssistedMachineExercise) {
                        fieldPreview = 'reps · $weightUnit assistance';
                      } else if (exercise is FreeWeightExercise ||
                          exercise is MachineExercise) {
                        fieldPreview = '$weightUnit · reps';
                      } else if (exercise is BodyweightExercise) {
                        fieldPreview = 'reps · $weightUnit';
                      } else if (exercise is DistanceCardioExercise) {
                        fieldPreview = '$distanceUnit · min';
                      } else if (exercise is DurationCardioExercise) {
                        fieldPreview = 'min';
                      }

                      return InkWell(
                        onTap: () => _selectExercise(exercise),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: AppColors.boldGrey.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                exercise.name,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.offWhite,
                                ),
                              ),
                              if (fieldPreview.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  fieldPreview,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.offWhite.withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],

            // Dynamic fields based on selected exercise
            if (_selectedExercise != null) ..._buildInputFields(formatters),

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
                    onTap: canSubmit && !_isSaving
                        ? () async {
                            setState(() {
                              _isSaving = true;
                            });

                            try {
                              // Create the appropriate WorkoutSet based on exercise type
                              final exercise = _selectedExercise!;
                              final WorkoutSet workoutSet;

                              if (exercise is IsometricExercise) {
                                final durationText =
                                    _fieldControllers['duration']!.text.trim();
                                final weightText = _fieldControllers['weight']
                                    ?.text
                                    .trim();

                                final duration = durationText.isNotEmpty
                                    ? Duration(seconds: int.parse(durationText))
                                    : null;
                                final weight =
                                    weightText != null && weightText.isNotEmpty
                                    ? formatters.parseWeight(weightText)
                                    : null;

                                final isBodyweightBased =
                                    exercise.isBodyweightBased;

                                workoutSet = IsometricWorkoutSet(
                                  id: const Uuid().v4(),
                                  exerciseId: exercise.id,
                                  timestamp: widget.selectedDate,
                                  duration: duration,
                                  weight: weight,
                                  isBodyweightBased: isBodyweightBased,
                                );
                              } else if (exercise is AssistedMachineExercise) {
                                final assistanceWeightText =
                                    _fieldControllers['assistanceWeight']!.text
                                        .trim();
                                final repsText = _fieldControllers['reps']!.text
                                    .trim();

                                final assistanceWeight = formatters.parseWeight(
                                  assistanceWeightText,
                                );
                                final reps = int.parse(repsText);

                                workoutSet = AssistedMachineWorkoutSet(
                                  id: const Uuid().v4(),
                                  exerciseId: exercise.id,
                                  timestamp: widget.selectedDate,
                                  assistanceWeight: assistanceWeight,
                                  reps: reps,
                                );
                              } else if (exercise is FreeWeightExercise ||
                                  exercise is MachineExercise) {
                                final weightText = _fieldControllers['weight']!
                                    .text
                                    .trim();
                                final repsText = _fieldControllers['reps']!.text
                                    .trim();

                                final weight = formatters.parseWeight(
                                  weightText,
                                );
                                final reps = int.parse(repsText);

                                workoutSet = WeightedWorkoutSet(
                                  id: const Uuid().v4(),
                                  exerciseId: exercise.id,
                                  timestamp: widget.selectedDate,
                                  weight: weight,
                                  reps: reps,
                                );
                              } else if (exercise is BodyweightExercise) {
                                final repsText = _fieldControllers['reps']!.text
                                    .trim();
                                final weightText = _fieldControllers['weight']
                                    ?.text
                                    .trim();

                                final reps = int.parse(repsText);
                                final additionalWeight =
                                    weightText != null && weightText.isNotEmpty
                                    ? formatters.parseWeight(weightText)
                                    : null;

                                workoutSet = BodyweightWorkoutSet(
                                  id: const Uuid().v4(),
                                  exerciseId: exercise.id,
                                  timestamp: widget.selectedDate,
                                  reps: reps,
                                  additionalWeight: additionalWeight,
                                );
                              } else if (exercise is DistanceCardioExercise) {
                                final distanceText =
                                    _fieldControllers['distance']!.text.trim();
                                final durationText =
                                    _fieldControllers['duration']!.text.trim();

                                final distance = formatters.parseDistance(
                                  distanceText,
                                );
                                final durationMin = int.parse(durationText);

                                workoutSet = DistanceCardioWorkoutSet(
                                  id: const Uuid().v4(),
                                  exerciseId: exercise.id,
                                  timestamp: widget.selectedDate,
                                  distance: distance,
                                  duration: Duration(minutes: durationMin),
                                );
                              } else if (exercise is DurationCardioExercise) {
                                final durationText =
                                    _fieldControllers['duration']!.text.trim();

                                final durationMin = int.parse(durationText);

                                workoutSet = DurationCardioWorkoutSet(
                                  id: const Uuid().v4(),
                                  exerciseId: exercise.id,
                                  timestamp: widget.selectedDate,
                                  duration: Duration(minutes: durationMin),
                                );
                              } else {
                                throw Exception('Unsupported exercise type');
                              }

                              // Save the workout set
                              final recordUseCase =
                                  GetIt.instance<RecordWorkoutSetUseCase>();
                              await recordUseCase.execute(
                                workoutSet: workoutSet,
                              );

                              // Close dialog
                              if (mounted) {
                                Navigator.of(context).pop();
                                // Notify parent to reload
                                widget.onSetAdded();
                                // Show success message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Set added',
                                      style: TextStyle(
                                        color: AppColors.pureBlack,
                                      ),
                                    ),
                                    backgroundColor: AppColors.limeGreen,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            } catch (e) {
                              debugPrint('Error saving workout set: $e');
                              if (mounted) {
                                setState(() {
                                  _isSaving = false;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to save set'),
                                    backgroundColor: AppColors.error,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            }
                          }
                        : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: canSubmit && !_isSaving
                            ? AppColors.limeGreen
                            : AppColors.limeGreen.withOpacity(0.3),
                        borderRadius: BorderRadius.zero,
                      ),
                      alignment: Alignment.center,
                      child: _isSaving
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: AppColors.pureBlack,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Add Set',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: canSubmit && !_isSaving
                                    ? AppColors.pureBlack
                                    : AppColors.pureBlack.withOpacity(0.3),
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
  }
}
