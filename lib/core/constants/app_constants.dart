class AppConstants {
  // App Info
  static const String appName = 'Dokter Grammar';
  static const String appTagline = 'Diagnose. Latih. Sembuh.';
  
  // Test Configuration
  static const int placementTestQuestions = 50;
  static const int customTestDefaultQuestions = 20;
  static const int dailyTestQuestions = 5;
  static const int reassessmentFullQuestions = 50;
  static const int reassessmentTargetedQuestions = 20;
  
  // Level Thresholds (0.0 to 1.0)
  static const double beginnerMax = 0.39;
  static const double elementaryMax = 0.54;
  static const double intermediateMax = 0.69;
  static const double upperIntermediateMax = 0.84;
  static const double advancedMax = 1.0;
  
  // Adaptive Test Distribution
  static const double weakestTopicsWeight = 0.5;  // 50% from top 3 weakest
  static const double mediumTopicsWeight = 0.3;   // 30% from medium
  static const double strongTopicsWeight = 0.2;   // 20% from strengths
  
  // Database
  static const String databaseName = 'dokter_grammar.db';
  static const int databaseVersion = 1;
  
  // User Goals
  static const List<String> availableGoals = [
    'pass_exam',
    'academic_writing',
    'speaking_grammar',
    'general_improvement',
  ];
  
  // User Interests
  static const List<String> availableInterests = [
    'anime',
    'k-pop',
    'film',
    'literature',
    'academic_english',
    'music',
    'sports',
    'technology',
  ];
  
  // Question Types
  static const String questionTypeMultipleChoice = 'multiple_choice';
  static const String questionTypeGapFill = 'gap_fill';
  static const String questionTypeReorder = 'reorder';
  static const String questionTypeShortAnswer = 'short_answer';
  static const String questionTypeErrorIdentification = 'error_identification';
  
  // Session Types
  static const String sessionTypePlacement = 'placement';
  static const String sessionTypeCustom = 'custom';
  static const String sessionTypeDaily = 'daily';
  static const String sessionTypeReassessment = 'reassessment';
  
  // Levels
  static const List<String> levels = [
    'beginner',
    'elementary',
    'intermediate',
    'upper_intermediate',
    'advanced',
  ];
}

