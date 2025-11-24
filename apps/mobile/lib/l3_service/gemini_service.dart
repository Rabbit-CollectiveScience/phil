import 'package:google_generative_ai/google_generative_ai.dart';
import '../config.dart';

/// Service for handling Gemini AI chat functionality
class GeminiService {
  static GeminiService? _instance;
  GenerativeModel? _model;
  ChatSession? _chat;
  bool _isInitialized = false;

  GeminiService._();

  /// Get singleton instance
  static GeminiService getInstance() {
    _instance ??= GeminiService._();
    return _instance!;
  }

  /// Initialize the Gemini model with system prompt
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

  /// Send a message to Gemini and get response
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

  /// Clear conversation history (start fresh)
  void clearHistory() {
    _isInitialized = false;
    _chat = null;
  }

  /// Get conversation history length
  int get historyLength => _chat?.history.length ?? 0;
}
