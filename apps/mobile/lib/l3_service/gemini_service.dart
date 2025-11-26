import 'package:google_generative_ai/google_generative_ai.dart';
import '../config.dart';
import 'function_declarations.dart';
import 'workout_function_executor.dart';

/// Service for handling Gemini AI chat functionality with function calling support
class GeminiService {
  static GeminiService? _instance;
  GenerativeModel? _model;
  GenerativeModel? _modelWithFunctions;
  ChatSession? _chat;
  ChatSession? _chatWithFunctions;
  bool _isInitialized = false;
  bool _isInitializedWithFunctions = false;
  final WorkoutFunctionExecutor _functionExecutor = WorkoutFunctionExecutor();

  GeminiService._();

  /// Get singleton instance
  static GeminiService getInstance() {
    _instance ??= GeminiService._();
    return _instance!;
  }

  /// Initialize the Gemini model with system prompt and function calling
  void _initializeModelWithFunctions() {
    if (_isInitializedWithFunctions) return;

    // Initialize model with function calling support
    _modelWithFunctions = GenerativeModel(
      model: 'gemini-2.5-flash-lite',
      apiKey: Config.geminiApiKey,
      generationConfig: GenerationConfig(
        maxOutputTokens: Config.geminiMaxTokens,
        temperature: 0.7,
      ),
      systemInstruction: Content.text('''
You are Phil, a friendly and encouraging fitness coach assistant that helps users log their workouts through voice.

CORE RESPONSIBILITIES:
- Help users log exercises using the available functions
- Understand natural voice input and extract workout details
- Use the appropriate function (strength/cardio/flexibility) based on exercise type
- Always respond in the SAME LANGUAGE the user speaks to you

AVAILABLE FUNCTIONS:
- log_strength_exercise: For weights, resistance training (bench press, squats, curls, etc.)
- log_cardio_exercise: For running, cycling, rowing, swimming, etc.
- log_flexibility_exercise: For stretching, yoga, mobility work

RULES:
- When user mentions an exercise, ALWAYS use a function to log it
- Match exercise names from the valid exercise lists in function descriptions
- Extract all mentioned parameters (sets, reps, weight, duration, distance, etc.)
- Convert imperial units to metric (lbs → kg × 0.453592, miles → km × 1.60934)
- Be conversational and encouraging
- Keep responses SHORT after logging (1-2 sentences)
- If unsure about details, ask clarifying questions

EXAMPLES:
User: "I did 3 sets of 10 bench press at 135 pounds"
→ Call log_strength_exercise(exercise_name="Barbell Bench Press", sets=3, reps=10, weight_kg=61.2)
→ Respond: "Nice! Logged 3 sets of 10 Barbell Bench Press at 61.2kg 💪"

User: "Ran 5K in 25 minutes"
→ Call log_cardio_exercise(exercise_name="Running", duration_minutes=25, distance_km=5, pace_min_per_km=5)
→ Respond: "Great run! Logged 5km in 25 min (5:00/km pace) 🏃"

User: "Stretched hamstrings for 30 seconds, 3 times"
→ Call log_flexibility_exercise(exercise_name="Hamstring Stretch", hold_duration_seconds=30, sets=3)
→ Respond: "Good work on flexibility! Logged 3x30s hamstring stretches 🧘"
'''),
      tools: [
        Tool(
          functionDeclarations: WorkoutFunctionDeclarations.getDeclarations(),
        ),
      ],
    );

    // Start chat session
    _chatWithFunctions = _modelWithFunctions!.startChat();
    _isInitializedWithFunctions = true;
  }

  /// Initialize the Gemini model with system prompt (without functions)
  void _initializeModel() {
    if (_isInitialized) return;

    // Initialize model - using gemini-1.5-flash which works with the deprecated SDK
    _model = GenerativeModel(
      model: 'gemini-2.5-flash-lite',
      apiKey: Config.geminiApiKey,
      generationConfig: GenerationConfig(
        maxOutputTokens: Config.geminiMaxTokens,
        temperature: 0.7,
      ),
      systemInstruction: Content.text('''
You are Phil, a friendly and encouraging fitness coach assistant.

RULES:
- ONLY discuss fitness, exercise, workouts, and health topics
- If user asks about anything else (food, weather, news, etc.), politely redirect to fitness
- Keep responses short (1-3 sentences) and encouraging
- Be conversational and supportive
- Use simple, clear language
- ALWAYS respond in the SAME LANGUAGE the user speaks to you (English, Thai, or any other language)

EXAMPLES:
User: "Hello" → "Hey! Ready to crush your workout today? What are you training?"
User: "I did bench press" → "Nice! How many sets and reps did you do?"
User: "สวัสดี" → "สวัสดีครับ! พร้อมออกกำลังกายแล้วหรือยัง? วันนี้จะฝึกอะไร?"
User: "ฉันทำเบนช์เพรส" → "เยี่ยมเลย! ทำกี่เซ็ต กี่ครั้ง?"
User: "Where should I eat dinner?" → "I'm your workout buddy, not a food guide! 😄 Want to log your training session?"
User: "3 sets of 10 at 135 pounds" → "Awesome work! 3 sets of 10 at 135 lbs. Keep it up! 💪"
'''),
    );

    // Start chat session
    _chat = _model!.startChat();
    _isInitialized = true;
  }

  /// Send a message to Gemini and get response (for general chat)
  Future<String> sendMessage(String userMessage) async {
    try {
      // Initialize if needed
      if (!_isInitialized) {
        _initializeModel();
      }

      // Send message using chat session
      final response = await _chat!.sendMessage(Content.text(userMessage));
      final aiMessage =
          response.text?.trim() ??
          "Sorry, I didn't catch that. Can you try again?";

      return aiMessage;
    } catch (e) {
      print('Error sending message to Gemini: $e');

      // Provide helpful error messages
      if (e.toString().contains('API_KEY') ||
          e.toString().contains('API key')) {
        return "⚠️ API key not configured. Please add your Gemini API key to config.dart";
      }

      return "Oops! Something went wrong. Let's try that again?";
    }
  }

  /// Send a message with function calling support for workout logging
  Future<({String message, FunctionExecutionResult? result})>
  sendMessageWithFunctions(String userMessage) async {
    try {
      // Initialize if needed
      if (!_isInitializedWithFunctions) {
        _initializeModelWithFunctions();
      }

      // Send message using chat session with functions
      var response = await _chatWithFunctions!.sendMessage(
        Content.text(userMessage),
      );

      // Check if the model wants to call a function
      final functionCalls = response.functionCalls.toList();

      if (functionCalls.isNotEmpty) {
        // Execute the first function call
        final functionCall = functionCalls.first;
        final executionResult = await _functionExecutor.executeFunction(
          functionCall,
        );

        // Send function response back to model using FunctionResponse
        response = await _chatWithFunctions!.sendMessage(
          Content.functionResponse(
            functionCall.name,
            executionResult.functionResponse ?? {},
          ),
        );

        // Get the model's natural language response after function execution
        final aiMessage = response.text?.trim() ?? executionResult.message;

        return (message: aiMessage, result: executionResult);
      }

      // No function call - just return the text response
      final aiMessage =
          response.text?.trim() ??
          "I'm here to help you log workouts! What did you do today?";
      return (message: aiMessage, result: null);
    } catch (e) {
      print('Error sending message with functions to Gemini: $e');

      // If it's a chat history corruption issue, clear and reinitialize
      if (e.toString().contains('Unhandled format for Content') ||
          e.toString().contains('{role: model}')) {
        print('🔄 Chat history corrupted, reinitializing...');
        _isInitializedWithFunctions = false;
        _chatWithFunctions = null;
        _initializeModelWithFunctions();

        // Retry the request with fresh chat
        try {
          var response = await _chatWithFunctions!.sendMessage(
            Content.text(userMessage),
          );
          final functionCalls = response.functionCalls.toList();

          if (functionCalls.isNotEmpty) {
            final functionCall = functionCalls.first;
            final executionResult = await _functionExecutor.executeFunction(
              functionCall,
            );
            response = await _chatWithFunctions!.sendMessage(
              Content.functionResponse(
                functionCall.name,
                executionResult.functionResponse ?? {},
              ),
            );
            final aiMessage = response.text?.trim() ?? executionResult.message;
            return (message: aiMessage, result: executionResult);
          }

          final aiMessage =
              response.text?.trim() ?? "I'm here to help you log workouts!";
          return (message: aiMessage, result: null);
        } catch (retryError) {
          print('Error after retry: $retryError');
        }
      }

      // Provide helpful error messages
      if (e.toString().contains('API_KEY') ||
          e.toString().contains('API key')) {
        return (
          message:
              "⚠️ API key not configured. Please add your Gemini API key to config.dart",
          result: null,
        );
      }

      return (
        message: "Oops! Something went wrong. Let's try that again?",
        result: null,
      );
    }
  }

  /// Clear conversation history (start fresh)
  void clearHistory() {
    _isInitialized = false;
    _chat = null;
  }

  /// Get conversation history length
  int get historyLength => _chat?.history.length ?? 0;
}
