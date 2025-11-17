# DOKTER GRAMMAR - CURRENT APP FEATURES AND WORKFLOW

## WHAT IS THIS APP

Dokter Grammar is a mobile app that helps people learn English grammar. It is made with Flutter and works on phones and computers. The app uses smart templates to create many different grammar questions automatically.

## CURRENT WORKING FEATURES

### 1. APP STARTUP
- When you open the app, you see a splash screen with the app name and logo
- Then you go to the home screen with a big button to start learning
- The app has a yellow and orange color theme that looks nice

### 2. USER PROFILE
- You can see user information like name, age, language, and country
- The profile shows "Andra Kusuma" as example user
- There is an edit button but it shows a message that the feature will come later
- Profile page has nice cards with icons for each piece of information

### 3. DAILY PRACTICE PAGE
- This page shows 4 categories in a grid: Tenses, Articles, Prepositions, Vocabulary
- Each category has a nice card with an icon
- When you tap a category, it shows a message "Starting practice for [category name]"
- The categories are not fully working yet - they are just for show

### 4. CUSTOM PRACTICE QUIZ
- This is a 10-question quiz that tests your grammar knowledge
- Questions are multiple choice with 4 options each
- After you answer each question, you see if you got it right or wrong
- You get an explanation for each answer
- At the end, you see your score out of 10
- Then you go to the AI analysis page

### 5. MAIN TEST
- This is a big test with 50 questions
- You see a progress bar showing how many questions you have done
- Questions appear one by one with smooth animation
- You can exit the test but it will not save your progress
- At the end, you get your score and go to AI analysis

### 6. AI ANALYSIS PAGE
- Shows your score as a percentage
- Shows how many questions you got right out of total
- Gives feedback like "Good job!" or "Keep practicing!"
- Lists your strengths and areas that need improvement
- Has a button to review all your answers
- When you tap review, a bottom sheet opens showing all questions and answers

### 7. QUESTION GENERATION SYSTEM
- The app creates questions automatically using templates
- Templates are stored in JSON files in the assets/data folder
- Templates have placeholders like [subject], [verb], [noun]
- The app fills these placeholders with random words from vocabulary lists
- This way, the app can create unlimited different questions
- Questions cover grammar topics like tenses, articles, prepositions

### 8. DATA STORAGE
- The app saves your quiz results using Hive database
- Data is stored locally on your device
- No internet connection needed to use the app
- Progress is saved when you finish a quiz

## HOW THE APP WORKS STEP BY STEP

### STARTING THE APP
1. Open the app
2. See splash screen for 2 seconds
3. Go to home screen
4. Tap the "Mulai" button to see the main menu

### DOING A CUSTOM PRACTICE QUIZ
1. Go to home screen
2. Tap "Mulai" button
3. Choose "Custom Practice" from the menu
4. Wait for questions to load (shows loading spinner)
5. Answer 10 questions one by one
6. After each answer, see if correct and read explanation
7. Tap "Continue" to go to next question
8. After last question, see final score
9. Automatically go to AI analysis page
10. See your results and feedback
11. Can review all answers if you want

### DOING THE MAIN TEST
1. Go to home screen
2. Tap "Mulai" button
3. Choose "Main Test" from the menu
4. Tap "Start Test" button
5. Answer 50 questions
6. See progress bar at top
7. Tap "Next" to go to next question
8. After all questions, see results
9. Go to AI analysis page

### VIEWING YOUR PROFILE
1. Tap the person icon in top left of home screen
2. See user information in nice cards
3. Tap "Edit Profile" button (shows message that feature comes later)

## TECHNICAL DETAILS FOR DEVELOPERS

### FOLDER STRUCTURE
- lib/pages/ - All screen pages
- lib/services/ - Business logic services
- lib/models/ - Data models
- lib/widgets/ - Reusable UI components
- assets/data/ - JSON data files for templates and vocabulary

### KEY SERVICES
- QuestionGeneratorService - Creates questions from templates
- TemplateStorageService - Loads and manages templates
- HiveStorageService - Saves data locally
- LocalAiService - Does AI analysis (currently fake)

### DATA FILES
- templates.json - Question templates with placeholders
- vocabulary.json - Words to fill in templates
- grammar_rules.json - Grammar rules (not used much yet)

### HOW QUESTIONS ARE MADE
1. App loads templates from JSON file
2. For each template, finds placeholders like [subject]
3. Gets random words from vocabulary for each placeholder
4. Puts words into template to make complete sentence
5. Creates wrong answer options using grammar rules
6. Shows question to user

## WHAT IS NOT WORKING YET

### BROKEN OR PLACEHOLDER FEATURES
- Daily Practice categories do not start actual quizzes
- AI analysis gives fake feedback, not real AI
- Main Test results page has old code that is not used
- Settings button in home screen does nothing
- Edit Profile button shows message instead of working

### MISSING FEATURES FROM ROADMAP
- Real AI analysis with TensorFlow Lite
- More grammar categories
- Difficulty levels
- Progress charts
- Voice practice
- Cloud sync

## HOW TO ADD NEW FEATURES

### TO ADD A NEW QUIZ TYPE
1. Create new page in lib/pages/
2. Use QuestionGeneratorService to get questions
3. Add navigation from home screen menu
4. Save results with HiveStorageService

### TO ADD NEW QUESTION TEMPLATES
1. Edit assets/data/templates.json
2. Add new template with placeholders
3. Add vocabulary words to assets/data/vocabulary.json
4. Test with QuestionGeneratorService

### TO IMPROVE AI ANALYSIS
1. Replace LocalAiService with real analysis
2. Use user answers to find patterns
3. Give personalized feedback based on mistakes

## NEXT STEPS FOR DEVELOPMENT

### IMMEDIATE TASKS
- Fix Daily Practice to actually start quizzes for each category
- Remove unused service files that are not connected
- Clean up old code in Main Test results page
- Make Settings button work or remove it

### SHORT TERM GOALS
- Add real AI analysis instead of fake feedback
- Add more question categories
- Add progress tracking charts
- Improve user interface

### LONG TERM GOALS
- Add voice pronunciation practice
- Add different difficulty levels
- Add study plans and learning paths
- Make app work on iOS and Android phones
