# Dokter Grammar - AI-Powered Grammar Learning App

## Current Features (Version 1.0)

### Core Functionality
- **Splash Screen**: Beautiful animated welcome screen with app branding
- **Home Dashboard**: Clean, modern interface with navigation to all features
- **User Profile**: Basic user profile management (placeholder)
- **Daily Practice**: Grid-based category selection for grammar topics (Tenses, Articles, Prepositions, Vocabulary)
- **Custom Practice**: Interactive quiz system with 10 questions per session
- **Main Test**: Placeholder for comprehensive testing (not implemented yet)
- **AI Analysis**: Detailed results page showing quiz performance, strengths, weaknesses, and personalized feedback

### Quiz System
- **Question Generation**: Generates 10 unique grammar questions per quiz
- **Multiple Choice**: 4 options per question with one correct answer
- **Immediate Feedback**: Shows correct/incorrect status and explanations after each answer
- **Progress Tracking**: Visual progress bar and question counter
- **Scoring System**: Calculates percentage score and tracks answers
- **Results Analysis**: Provides detailed breakdown of performance

### Data Persistence
- **Local Storage**: Uses Hive database for offline data storage
- **User Progress**: Saves quiz results and user statistics
- **Answer History**: Stores all quiz answers for review

### UI/UX Features
- **Consistent Design**: Yellow/orange color scheme with soft shadows
- **Responsive Layout**: Works on desktop and mobile devices
- **Smooth Animations**: Card-based navigation with hover effects
- **Bottom Sheet Menu**: Elegant navigation menu for feature access

## AI System Logic

The AI system works by combining grammar rule templates with dynamic vocabulary substitution to generate unlimited unique questions. It starts with predefined grammar patterns for different categories (tenses, prepositions, articles) that contain placeholders like [subject], [verb], and [object]. When generating questions, the AI randomly selects words from vocabulary banks to fill these placeholders, creating complete sentences. It then applies transformation rules to generate both correct answers and plausible wrong options based on common grammatical mistakes. For assessment, the system analyzes which grammar categories the user struggles with most and calculates priority scores for each weakness. Based on this analysis, it creates personalized learning sessions that target the user's weakest areas by generating new questions specifically for those categories and difficulty levels. The entire system runs offline using rule-based logic rather than machine learning, making it completely self-contained while still providing adaptive, personalized grammar practice.

## Future Development Roadmap

### Phase 1: Core Enhancement (Next 2 weeks)
- [ ] Integrate real AI for dynamic question generation
- [ ] Add more grammar categories (conditionals, passive voice, etc.)
- [ ] Implement difficulty levels (beginner, intermediate, advanced)
- [ ] Add question categories selection in custom practice

### Phase 2: Learning Analytics (Next 4 weeks)
- [ ] Detailed progress charts and statistics
- [ ] Learning streak tracking and achievements
- [ ] Weakness analysis with targeted practice recommendations
- [ ] Performance trends over time

### Phase 3: Advanced Features (Next 6 weeks)
- [ ] Voice pronunciation practice
- [ ] Grammar rule explanations with examples
- [ ] Study plans and learning paths
- [ ] Social features (leaderboards, challenges)

### Phase 4: Platform Expansion (Next 8 weeks)
- [ ] Mobile app optimization (iOS/Android)
- [ ] Cloud sync for cross-device progress
- [ ] Multi-language support
- [ ] Offline content downloads

### Technical Improvements
- [ ] Unit and integration tests
- [ ] Performance optimization
- [ ] Error handling and crash reporting
- [ ] Code documentation and refactoring

## Technology Stack
- **Framework**: Flutter (Dart)
- **State Management**: StatefulWidget with setState
- **Local Storage**: Hive database
- **UI Components**: Material Design 3
- **Platform**: Windows (primary), cross-platform ready

## Installation & Setup
1. Ensure Flutter SDK is installed
2. Clone the repository
3. Run `flutter pub get` to install dependencies
4. Run `flutter run` to start the app

## Contributing
This is an educational project focused on grammar learning. Contributions for improving the learning experience and adding new features are welcome.
