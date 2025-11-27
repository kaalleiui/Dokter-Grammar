# Dokter Grammar

**Offline English Grammar Learning App for Android**

Dokter Grammar is a fully offline Android application designed to help English literature students identify grammar weaknesses, receive level assessment, and access adaptive custom practice tailored to their needs.

## 🎯 Features

### Core Features
- ✅ **Placement Test**: 50-question assessment to determine grammar level
- ✅ **Custom Test**: Adaptive tests focusing on weak areas (50% weak, 30% medium, 20% strong topics)
- ✅ **Daily Test**: Quick 5-question practice sessions
- ✅ **Reassessment**: Full or targeted tests for level progression
- ✅ **Adaptive Learning**: Smart question selection based on performance
- ✅ **Progress Tracking**: Visual analytics with charts and topic breakdown
- ✅ **Gamification**: Streaks, badges, and achievements
- ✅ **Offline First**: All features work completely offline

### Advanced Features
- ✅ **Explanation System**: Rule-based explanations for each question
- ✅ **Topic Performance**: Detailed tracking per grammar topic
- ✅ **Badge System**: Automatic badge awarding for achievements
- ✅ **Streak Tracking**: Daily practice streak management
- ✅ **Backup & Restore**: Export/import user data
- ✅ **Settings**: Profile management and app configuration

## 📱 Screenshots

*Screenshots coming soon*

## 🏗️ Architecture

### Tech Stack
- **Framework**: Flutter (Dart)
- **Database**: SQLite (sqflite)
- **State Management**: Provider
- **Charts**: fl_chart
- **Architecture**: Clean Architecture (Data, Domain, Presentation layers)

### Project Structure
```
lib/
├── core/              # Core functionality
│   ├── constants/     # App constants, colors, strings
│   ├── database/      # Database schema and helper
│   ├── models/        # Data models
│   └── services/      # Business logic services
├── data/              # Data layer
│   ├── datasources/   # Local data sources
│   └── repositories/  # Data repositories
└── presentation/      # UI layer
    ├── screens/       # App screens
    ├── widgets/       # Reusable widgets
    └── theme/         # App theme
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.7.0 or higher)
- Android Studio / VS Code
- Android device or emulator

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd dokter_grammar2
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### First Run
1. Complete onboarding (nickname, goal, interests)
2. Take placement test (50 questions)
3. Review results and explanations
4. Start practicing with Custom Test or Daily Test

## 📊 Database Schema

The app uses SQLite with the following main tables:
- `users` - User profiles
- `questions` - Question bank
- `test_sessions` - Test attempts
- `test_attempts` - Individual question answers
- `user_topic_performance` - Topic-level performance
- `badges` - Earned achievements
- `daily_activities` - Daily practice tracking

## 🎨 Design

### Color Scheme
- **Primary**: Lemon gradient (soft pastel)
- **Secondary**: Orange accents
- **Text**: Dark colors for readability
- **Background**: White

### UI Components
- Material Design 3
- Custom gradients and cards
- Responsive layouts
- Accessible color contrasts

## 📈 Adaptive Algorithm

The app uses an intelligent adaptive algorithm for question selection:

- **Custom Test**: 50% from weakest topics, 30% medium, 20% strong
- **Daily Test**: 40% from weak areas, 60% random
- **Reassessment**: Targeted (weak areas) or full (placement-style)

## 🏆 Gamification

### Badges
- Streak badges (7, 30, 100 days)
- Level badges (intermediate, advanced)
- Test completion badges (10, 50 tests)
- Topic mastery badges (3, 5 topics)

### Streaks
- Daily practice tracking
- Automatic streak calculation
- Streak reset on missed days

## 💾 Backup & Restore

Users can export their data to JSON files and restore later:
- Export: Creates timestamped JSON backup
- Import: Restores all user data
- File management: List and delete backups

## 🔒 Privacy

- **100% Offline**: No network connections required
- **Local Storage**: All data stored on device
- **No Analytics**: No data collection
- **User Control**: Full backup/restore capability

## 📝 Development Status

**Current Progress: 95%**

See [STATUS.md](STATUS.md) for detailed development progress and version history.

## 🛠️ Development

### Running Tests
```bash
flutter test
```

### Building APK
```bash
flutter build apk --release
```

### Code Structure
- Follows Flutter best practices
- Clean architecture pattern
- Separation of concerns
- Repository pattern for data access

## 📚 Content

### Grammar Topics Covered
1. Tenses
2. Modals & Auxiliaries
3. Conditionals
4. Complex Sentences
5. Sentence Combining & Punctuation
6. Articles & Determiners
7. Subject-Verb Agreement
8. Passive Voice
9. Reported Speech
10. Prepositions
11. Adjective Clauses
12. Pronouns & Reference

## 🤝 Contributing

This is a private project. For questions or suggestions, please contact the development team.

## 📄 License

*License information to be added*

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- SQLite for reliable local storage
- All contributors and testers

---

**Version**: 0.1.0  
**Last Updated**: 2024-11-26  
**Status**: MVP Complete, Ready for Testing
