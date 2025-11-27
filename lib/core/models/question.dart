class Question {
  final String id;
  final String type; // 'multiple_choice', 'gap_fill', etc.
  final int difficulty; // 1-5
  final int topicId;
  final String prompt;
  final String answer; // JSON string for complex answers
  final String? explanationTemplate;
  final String? exampleSentence;
  final List<QuestionChoice> choices;
  final List<QuestionTag> tags;

  Question({
    required this.id,
    required this.type,
    required this.difficulty,
    required this.topicId,
    required this.prompt,
    required this.answer,
    this.explanationTemplate,
    this.exampleSentence,
    required this.choices,
    required this.tags,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'difficulty': difficulty,
    'topicId': topicId,
    'prompt': prompt,
    'answer': answer,
    'explanationTemplate': explanationTemplate,
    'exampleSentence': exampleSentence,
    'choices': choices.map((c) => c.toJson()).toList(),
    'tags': tags.map((t) => t.toJson()).toList(),
  };

  factory Question.fromJson(Map<String, dynamic> json) => Question(
    id: json['id'],
    type: json['type'],
    difficulty: json['difficulty'],
    topicId: json['topicId'],
    prompt: json['prompt'],
    answer: json['answer'],
    explanationTemplate: json['explanationTemplate'],
    exampleSentence: json['exampleSentence'],
    choices: (json['choices'] as List?)
        ?.map((c) => QuestionChoice.fromJson(c))
        .toList() ?? [],
    tags: (json['tags'] as List?)
        ?.map((t) => QuestionTag.fromJson(t))
        .toList() ?? [],
  );
}

class QuestionChoice {
  final String choiceId; // 'a', 'b', 'c', 'd'
  final String text;
  final bool isCorrect;

  QuestionChoice({
    required this.choiceId,
    required this.text,
    this.isCorrect = false,
  });

  Map<String, dynamic> toJson() => {
    'choiceId': choiceId,
    'text': text,
    'isCorrect': isCorrect,
  };

  factory QuestionChoice.fromJson(Map<String, dynamic> json) => QuestionChoice(
    choiceId: json['choiceId'],
    text: json['text'],
    isCorrect: json['isCorrect'] ?? false,
  );
}

class QuestionTag {
  final String tagType; // 'interest', 'tense', 'grammar_point'
  final String tagValue; // 'anime', 'past', 'conditional_3'

  QuestionTag({
    required this.tagType,
    required this.tagValue,
  });

  Map<String, dynamic> toJson() => {
    'tagType': tagType,
    'tagValue': tagValue,
  };

  factory QuestionTag.fromJson(Map<String, dynamic> json) => QuestionTag(
    tagType: json['tagType'],
    tagValue: json['tagValue'],
  );
}

