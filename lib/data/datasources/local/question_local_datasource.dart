import 'package:sqflite/sqflite.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/models/question.dart';

class QuestionLocalDataSource {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<void> insertQuestion(Question question) async {
    final db = await _dbHelper.database;
    
    // Insert question
    await db.insert(
      'questions',
      {
        'id': question.id,
        'type': question.type,
        'difficulty': question.difficulty,
        'topic_id': question.topicId,
        'prompt': question.prompt,
        'answer': question.answer,
        'explanation_template': question.explanationTemplate,
        'example_sentence': question.exampleSentence,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Insert choices
    for (final choice in question.choices) {
      await db.insert(
        'question_choices',
        {
          'question_id': question.id,
          'choice_id': choice.choiceId,
          'text': choice.text,
          'is_correct': choice.isCorrect ? 1 : 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    // Insert tags
    for (final tag in question.tags) {
      await db.insert(
        'question_tags',
        {
          'question_id': question.id,
          'tag_type': tag.tagType,
          'tag_value': tag.tagValue,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  Future<void> insertQuestions(List<Question> questions) async {
    final batch = (await _dbHelper.database).batch();
    
    for (final question in questions) {
      batch.insert(
        'questions',
        {
          'id': question.id,
          'type': question.type,
          'difficulty': question.difficulty,
          'topic_id': question.topicId,
          'prompt': question.prompt,
          'answer': question.answer,
          'explanation_template': question.explanationTemplate,
          'example_sentence': question.exampleSentence,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      for (final choice in question.choices) {
        batch.insert(
          'question_choices',
          {
            'question_id': question.id,
            'choice_id': choice.choiceId,
            'text': choice.text,
            'is_correct': choice.isCorrect ? 1 : 0,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      for (final tag in question.tags) {
        batch.insert(
          'question_tags',
          {
            'question_id': question.id,
            'tag_type': tag.tagType,
            'tag_value': tag.tagValue,
          },
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
    }
    
    await batch.commit(noResult: true);
  }

  Future<Question?> getQuestionById(String questionId) async {
    final db = await _dbHelper.database;
    
    final questionMaps = await db.query(
      'questions',
      where: 'id = ?',
      whereArgs: [questionId],
      limit: 1,
    );

    if (questionMaps.isEmpty) return null;

    final questionMap = questionMaps.first;
    
    // Get choices
    final choiceMaps = await db.query(
      'question_choices',
      where: 'question_id = ?',
      whereArgs: [questionId],
      orderBy: 'choice_id',
    );
    final choices = choiceMaps.map((map) => QuestionChoice(
      choiceId: map['choice_id'] as String,
      text: map['text'] as String,
      isCorrect: (map['is_correct'] as int) == 1,
    )).toList();

    // Get tags
    final tagMaps = await db.query(
      'question_tags',
      where: 'question_id = ?',
      whereArgs: [questionId],
    );
    final tags = tagMaps.map((map) => QuestionTag(
      tagType: map['tag_type'] as String,
      tagValue: map['tag_value'] as String,
    )).toList();

    return Question(
      id: questionMap['id'] as String,
      type: questionMap['type'] as String,
      difficulty: questionMap['difficulty'] as int,
      topicId: questionMap['topic_id'] as int,
      prompt: questionMap['prompt'] as String,
      answer: questionMap['answer'] as String,
      explanationTemplate: questionMap['explanation_template'] as String?,
      exampleSentence: questionMap['example_sentence'] as String?,
      choices: choices,
      tags: tags,
    );
  }

  Future<List<Question>> getQuestionsByTopic(int topicId, {int? limit}) async {
    final db = await _dbHelper.database;
    
    final questionMaps = await db.query(
      'questions',
      where: 'topic_id = ?',
      whereArgs: [topicId],
      limit: limit,
    );

    final questions = <Question>[];
    
    for (final questionMap in questionMaps) {
      final questionId = questionMap['id'] as String;
      
      // Get choices
      final choiceMaps = await db.query(
        'question_choices',
        where: 'question_id = ?',
        whereArgs: [questionId],
        orderBy: 'choice_id',
      );
      final choices = choiceMaps.map((map) => QuestionChoice(
        choiceId: map['choice_id'] as String,
        text: map['text'] as String,
        isCorrect: (map['is_correct'] as int) == 1,
      )).toList();

      // Get tags
      final tagMaps = await db.query(
        'question_tags',
        where: 'question_id = ?',
        whereArgs: [questionId],
      );
      final tags = tagMaps.map((map) => QuestionTag(
        tagType: map['tag_type'] as String,
        tagValue: map['tag_value'] as String,
      )).toList();

      questions.add(Question(
        id: questionId,
        type: questionMap['type'] as String,
        difficulty: questionMap['difficulty'] as int,
        topicId: questionMap['topic_id'] as int,
        prompt: questionMap['prompt'] as String,
        answer: questionMap['answer'] as String,
        explanationTemplate: questionMap['explanation_template'] as String?,
        exampleSentence: questionMap['example_sentence'] as String?,
        choices: choices,
        tags: tags,
      ));
    }

    return questions;
  }

  Future<List<Question>> getQuestionsForPlacement({
    required List<String> userInterests,
    int totalQuestions = 50,
  }) async {
    final db = await _dbHelper.database;
    
    // Get all topics
    final topicMaps = await db.query('topics');
    final topics = topicMaps.map((map) => map['id'] as int).toList();
    
    // Distribute questions across topics
    final questionsPerTopic = (totalQuestions / topics.length).ceil();
    final allQuestions = <Question>[];
    
    for (final topicId in topics) {
      final topicQuestions = await getQuestionsByTopic(topicId, limit: questionsPerTopic);
      
      // Filter by interests if possible, otherwise take any
      final filtered = topicQuestions.where((q) {
        if (userInterests.isEmpty) return true;
        return q.tags.any((tag) => 
          tag.tagType == 'interest' && userInterests.contains(tag.tagValue)
        );
      }).toList();
      
      if (filtered.isNotEmpty) {
        allQuestions.addAll(filtered.take(questionsPerTopic));
      } else {
        allQuestions.addAll(topicQuestions.take(questionsPerTopic));
      }
    }
    
    // Shuffle and limit to totalQuestions
    allQuestions.shuffle();
    return allQuestions.take(totalQuestions).toList();
  }

  Future<int> getQuestionCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM questions');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}

