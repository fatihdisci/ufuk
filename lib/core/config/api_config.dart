class ApiConfig {
  static const String geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');
  
  static bool get hasGeminiKey => geminiApiKey.isNotEmpty;
}
