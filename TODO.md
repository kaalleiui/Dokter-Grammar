# TODO List for Implementing Quiz Flow in halaman_latihan_custom.dart

## 1. Fix RenderFlex Overflow in halaman_latihan_harian.dart
- [x] Wrap the Column in SingleChildScrollView to make the body scrollable.

## 2. Define Models
- [x] Implement UserProgress class in lib/models/user_progress.dart with fields for progress tracking (e.g., scores, completed quizzes).
- [x] Implement Answer class in lib/models/answer.dart with fields for question, selected answer, correctness.
- [x] Implement AnalysisResult class in lib/models/analysis_result.dart with fields for quiz analysis (e.g., score, feedback).

## 3. Implement Services
- [x] Implement QuestionGeneratorService in lib/services/question_generator_service.dart with method to generate 10-20 questions (mock for now).
- [x] Implement HiveStorageService in lib/services/hive_storage_service.dart with methods to save/load UserProgress.

## 4. Build Widgets
- [x] Build QuestionCard widget in lib/widgets/question_card.dart to display question text, options, and handle selection.
- [x] Build ExplanationBox widget in lib/widgets/explanation_box.dart to show feedback (correct/incorrect, explanation).

## 5. Implement halaman_latihan_custom.dart
- [x] Convert to StatefulWidget.
- [x] Add state variables: list of questions, current index, selected answer, score, answers list.
- [x] On init: Generate questions using QuestionGeneratorService.
- [x] Display current question using QuestionCard.
- [x] On answer selection: Show feedback using ExplanationBox, update score, move to next.
- [x] On completion: Calculate score, update UserProgress, navigate to halaman_penjelasan_ai.

## 6. Followup Steps
- [x] Test the app to ensure quiz flow works, navigation is correct, and UI matches aesthetic.
- [x] Run flutter analyze and fix any issues.
- [x] Fix Hive initialization error by adding Hive.initFlutter() in main.dart
- [x] Fix explanation box centering by wrapping in Center widget
- [x] Add isLastQuestion parameter to ExplanationBox to show "Finish" on last question
- [x] Update halaman_latihan_custom.dart to pass isLastQuestion parameter
- If needed, integrate real AI for question generation.
