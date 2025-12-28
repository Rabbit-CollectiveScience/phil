import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'l1_ui/pages/workout_home_page.dart';
import 'l2_domain/models/workout_set.dart';
import 'l2_domain/use_cases/workout_use_cases/get_recommended_exercises_use_case.dart';
import 'l2_domain/use_cases/workout_use_cases/record_workout_set_use_case.dart';
import 'l3_data/repositories/exercise_repository.dart';
import 'l3_data/repositories/stub_exercise_repository.dart';
import 'l3_data/repositories/workout_set_repository.dart';
import 'l3_data/repositories/hive_workout_set_repository.dart';

// Global GetIt instance for dependency injection
final getIt = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Register Hive adapters
  Hive.registerAdapter(WorkoutSetAdapter());

  // Open Hive boxes
  await Hive.openBox<WorkoutSet>('workout_sets');

  // Setup dependency injection
  _setupDependencies();

  runApp(const MyApp());
}

/// Configure all dependencies for the app
/// L3 (Data) -> L2 (Domain) dependency chain
void _setupDependencies() {
  // Register L3 - Data Layer (Repositories)
  getIt.registerSingleton<ExerciseRepository>(StubExerciseRepository());
  getIt.registerSingleton<WorkoutSetRepository>(HiveWorkoutSetRepository());

  // Register L2 - Domain Layer (Use Cases)
  getIt.registerFactory<GetRecommendedExercisesUseCase>(
    () => GetRecommendedExercisesUseCase(getIt<ExerciseRepository>()),
  );
  getIt.registerFactory<RecordWorkoutSetUseCase>(
    () => RecordWorkoutSetUseCase(getIt<WorkoutSetRepository>()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Phil',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.white,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(
          0xFF1A1A1A,
        ), // Bold Studio: deep charcoal
        useMaterial3: true,
      ),
      home: const WorkoutHomePage(),
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
