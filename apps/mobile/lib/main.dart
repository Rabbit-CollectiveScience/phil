import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'l1_ui/features/workout/workout_home_page.dart';
import 'l1_ui/shared/theme/app_colors.dart';
import 'l1_ui/shared/providers/preferences_provider.dart';
import 'l2_domain/use_cases/preferences/get_user_preferences_use_case.dart';
import 'l2_domain/use_cases/preferences/update_user_preferences_use_case.dart';
import 'l3_data/repositories/user_preferences_repository.dart';
import 'l2_domain/use_cases/exercises/get_recommended_exercises_use_case.dart';
import 'l2_domain/use_cases/exercises/search_exercises_use_case.dart';
import 'l2_domain/use_cases/workout_sets/record_workout_set_use_case.dart';
import 'l2_domain/use_cases/workout_sets/remove_workout_set_use_case.dart';
import 'l2_domain/use_cases/workout_sets/get_today_completed_count_use_case.dart';
import 'l2_domain/use_cases/workout_sets/get_today_completed_list_use_case.dart';
import 'l2_domain/use_cases/workout_sets/get_workout_sets_by_date_use_case.dart';
import 'l2_domain/use_cases/stats/get_today_stats_overview_use_case.dart';
import 'l2_domain/use_cases/stats/get_today_exercise_details_use_case.dart';
import 'l2_domain/use_cases/stats/get_weekly_stats_use_case.dart';
import 'l2_domain/use_cases/filters/get_last_filter_selection_use_case.dart';
import 'l2_domain/use_cases/filters/record_filter_selection_use_case.dart';
import 'l2_domain/use_cases/filters/should_show_filter_page_use_case.dart';
import 'l2_domain/use_cases/personal_records/get_all_prs_use_case.dart';
import 'l2_domain/use_cases/personal_records/recalculate_prs_for_exercise_use_case.dart';
import 'l2_domain/use_cases/dev/add_mock_data_use_case.dart';
import 'l2_domain/use_cases/dev/clear_all_data_use_case.dart';
import 'l2_domain/use_cases/dev/export_data_use_case.dart';
import 'l2_domain/use_cases/dev/import_data_use_case.dart';
import 'l3_data/repositories/exercise_repository.dart';
import 'l3_data/repositories/workout_set_repository.dart';
import 'l3_data/repositories/preferences_repository.dart';
import 'l3_data/repositories/local_preferences_repository.dart';
import 'l3_data/repositories/personal_record_repository.dart';
import 'l3_data/adapters/exercise_seeder.dart';

// Global GetIt instance for dependency injection
final getIt = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Open Hive boxes (storing JSON maps, not typed objects)
  await Hive.openBox<Map<dynamic, dynamic>>('exercises');
  await Hive.openBox<Map<dynamic, dynamic>>('workout_sets');
  await Hive.openBox<Map<dynamic, dynamic>>('personal_records');

  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

  // Setup dependency injection
  _setupDependencies(sharedPreferences);

  // Seed exercises on first launch
  final exerciseRepo = getIt<ExerciseRepository>();
  final seeder = ExerciseSeeder(exerciseRepo);
  await seeder.seedIfEmpty();

  runApp(const MyApp());
}

/// Configure all dependencies for the app
/// L3 (Data) -> L2 (Domain) dependency chain
void _setupDependencies(SharedPreferences sharedPreferences) {
  // Register L3 - Data Layer (Repositories)
  getIt.registerSingleton<ExerciseRepository>(ExerciseRepository());
  getIt.registerSingleton<WorkoutSetRepository>(WorkoutSetRepository());
  getIt.registerSingleton<PersonalRecordRepository>(PersonalRecordRepository());
  getIt.registerSingleton<PreferencesRepository>(
    LocalPreferencesRepository(sharedPreferences),
  );
  getIt.registerSingleton<UserPreferencesRepository>(
    UserPreferencesRepository(),
  );

  // Register L2 - Domain Layer (Use Cases)
  getIt.registerFactory<GetRecommendedExercisesUseCase>(
    () => GetRecommendedExercisesUseCase(getIt<ExerciseRepository>()),
  );
  getIt.registerFactory<SearchExercisesUseCase>(
    () => SearchExercisesUseCase(getIt<ExerciseRepository>()),
  );
  getIt.registerFactory<RecordWorkoutSetUseCase>(
    () => RecordWorkoutSetUseCase(
      getIt<WorkoutSetRepository>(),
      prRepository: getIt<PersonalRecordRepository>(),
      exerciseRepository: getIt<ExerciseRepository>(),
    ),
  );
  getIt.registerFactory<RemoveWorkoutSetUseCase>(
    () => RemoveWorkoutSetUseCase(
      getIt<WorkoutSetRepository>(),
      prRepository: getIt<PersonalRecordRepository>(),
      exerciseRepository: getIt<ExerciseRepository>(),
    ),
  );
  getIt.registerFactory<GetTodayCompletedCountUseCase>(
    () => GetTodayCompletedCountUseCase(getIt<WorkoutSetRepository>()),
  );
  getIt.registerFactory<GetTodayCompletedListUseCase>(
    () => GetTodayCompletedListUseCase(
      getIt<WorkoutSetRepository>(),
      getIt<ExerciseRepository>(),
    ),
  );
  getIt.registerFactory<GetWorkoutSetsByDateUseCase>(
    () => GetWorkoutSetsByDateUseCase(
      getIt<WorkoutSetRepository>(),
      getIt<ExerciseRepository>(),
    ),
  );

  // Stats use cases
  getIt.registerFactory<GetTodayStatsOverviewUseCase>(
    () => GetTodayStatsOverviewUseCase(
      getIt<GetWorkoutSetsByDateUseCase>(),
      getIt<ExerciseRepository>(),
    ),
  );
  getIt.registerFactory<GetTodayExerciseDetailsUseCase>(
    () => GetTodayExerciseDetailsUseCase(
      getIt<GetWorkoutSetsByDateUseCase>(),
      prRepository: getIt<PersonalRecordRepository>(),
    ),
  );
  getIt.registerFactory<GetWeeklyStatsUseCase>(
    () => GetWeeklyStatsUseCase(
      getIt<GetWorkoutSetsByDateUseCase>(),
      getIt<ExerciseRepository>(),
    ),
  );

  // Preferences use cases
  getIt.registerFactory<GetUserPreferencesUseCase>(
    () => GetUserPreferencesUseCase(
      repository: getIt<UserPreferencesRepository>(),
    ),
  );
  getIt.registerFactory<UpdateUserPreferencesUseCase>(
    () => UpdateUserPreferencesUseCase(
      repository: getIt<UserPreferencesRepository>(),
    ),
  );

  // Filter use cases
  getIt.registerFactory<GetLastFilterSelectionUseCase>(
    () => GetLastFilterSelectionUseCase(getIt<PreferencesRepository>()),
  );
  getIt.registerFactory<RecordFilterSelectionUseCase>(
    () => RecordFilterSelectionUseCase(getIt<PreferencesRepository>()),
  );
  getIt.registerFactory<ShouldShowFilterPageUseCase>(
    () => ShouldShowFilterPageUseCase(getIt<PreferencesRepository>()),
  );

  // Personal Record use cases
  getIt.registerFactory<GetAllPRsUseCase>(
    () => GetAllPRsUseCase(
      getIt<PersonalRecordRepository>(),
      getIt<ExerciseRepository>(),
    ),
  );
  getIt.registerFactory<RecalculatePRsForExerciseUseCase>(
    () => RecalculatePRsForExerciseUseCase(
      getIt<PersonalRecordRepository>(),
      getIt<WorkoutSetRepository>(),
      getIt<ExerciseRepository>(),
    ),
  );

  // Dev tools use cases
  getIt.registerFactory<AddMockDataUseCase>(
    () => AddMockDataUseCase(
      getIt<WorkoutSetRepository>(),
      getIt<ExerciseRepository>(),
      getIt<RecalculatePRsForExerciseUseCase>(),
    ),
  );
  getIt.registerFactory<ClearAllDataUseCase>(
    () => ClearAllDataUseCase(
      getIt<WorkoutSetRepository>(),
      getIt<PersonalRecordRepository>(),
    ),
  );
  getIt.registerFactory<ExportDataUseCase>(
    () => ExportDataUseCase(
      getIt<WorkoutSetRepository>(),
      getIt<PersonalRecordRepository>(),
      getIt<ExerciseRepository>(),
    ),
  );
  getIt.registerFactory<ImportDataUseCase>(
    () => ImportDataUseCase(getIt<ClearAllDataUseCase>()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PreferencesProvider(
        getUserPreferencesUseCase: getIt<GetUserPreferencesUseCase>(),
        updateUserPreferencesUseCase: getIt<UpdateUserPreferencesUseCase>(),
      )..initialize(),
      child: MaterialApp(
        title: 'Phil',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.white,
            brightness: Brightness.dark,
          ),
          scaffoldBackgroundColor: AppColors.deepCharcoal,
          useMaterial3: true,
        ),
        home: const WorkoutHomePage(),
      ),
    );
  }
}

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [const WorkoutHomePage()];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _pages[_currentIndex]);
  }
}
