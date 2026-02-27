import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/problem.dart';
import '../models/submission.dart';
import '../models/user.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'candy_coder.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE problems (
        id TEXT PRIMARY KEY,
        title TEXT,
        topic TEXT,
        difficulty TEXT,
        description TEXT,
        description_ko TEXT,
        templates TEXT,
        test_cases TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE submissions (
        id TEXT PRIMARY KEY,
        problem_id TEXT,
        language TEXT,
        code TEXT,
        status TEXT,
        feedback TEXT,
        timestamp INTEGER,
        runtime TEXT,
        stdout TEXT,
        stderr TEXT,
        exitCode INTEGER,
        passedTestCases INTEGER,
        totalTestCases INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT,
        avatar TEXT,
        points INTEGER,
        streak INTEGER,
        last_submission_date TEXT
      )
    ''');

    // Seed default user
    await db.insert('users', {
      'id': 'default',
      'name': 'Candy Coder',
      'avatar': 'https://picsum.photos/seed/candy/200/200',
      'points': 0,
      'streak': 0,
      'last_submission_date': '',
    });

    // Seed competitors
    final competitors = [
      {
        'id': 'c1',
        'name': 'Sugar Rush',
        'avatar': 'https://picsum.photos/seed/sugar/200/200',
        'points': 450,
        'streak': 5,
        'last_submission_date': '2024-01-01'
      },
      {
        'id': 'c2',
        'name': 'Marshmallow',
        'avatar': 'https://picsum.photos/seed/marsh/200/200',
        'points': 320,
        'streak': 3,
        'last_submission_date': '2024-01-01'
      },
      {
        'id': 'c3',
        'name': 'Gummy Bear',
        'avatar': 'https://picsum.photos/seed/gummy/200/200',
        'points': 150,
        'streak': 2,
        'last_submission_date': '2024-01-01'
      },
      {
        'id': 'c4',
        'name': 'Lollipop',
        'avatar': 'https://picsum.photos/seed/pop/200/200',
        'points': 800,
        'streak': 12,
        'last_submission_date': '2024-01-01'
      },
    ];

    for (var competitor in competitors) {
      await db.insert('users', competitor);
    }

    // Seed some problems
    final seedProblems = [
      {
        'id': '1',
        'title': 'Two Sum',
        'topic': 'Array',
        'difficulty': 'Easy',
        'description':
            'Given an array of integers `nums` and an integer `target`, return indices of the two numbers such that they add up to `target`.',
        'description_ko': null,
        'templates': jsonEncode({
          'JavaScript': 'function twoSum(nums, target) {\n  // Write your code here\n}',
          'Python': 'def two_sum(nums, target):\n    # Write your code here\n    pass',
          'C++':
              'class Solution {\npublic:\n    vector<int> twoSum(vector<int>& nums, int target) {\n        // Write your code here\n    }\n};',
          'Java':
              'class Solution {\n    public int[] twoSum(int[] nums, int target) {\n        // Write your code here\n    }\n}'
        }),
        'test_cases': jsonEncode([
          {'input': '[2,7,11,15], 9', 'expectedOutput': '[0,1]'}
        ])
      },
      {
        'id': '2',
        'title': 'Climbing Stairs',
        'topic': 'DP',
        'difficulty': 'Easy',
        'description':
            'You are climbing a staircase. It takes `n` steps to reach the top. Each time you can either climb 1 or 2 steps. In how many distinct ways can you climb to the top?',
        'description_ko': null,
        'templates': jsonEncode({
          'JavaScript': 'function climbStairs(n) {\n  // Write your code here\n}',
          'Python': 'def climb_stairs(n):\n    # Write your code here\n    pass',
          'C++':
              'class Solution {\npublic:\n    int climbStairs(int n) {\n        // Write your code here\n    }\n};',
          'Java':
              'class Solution {\n    public int climbStairs(int n) {\n        // Write your code here\n    }\n}'
        }),
        'test_cases': jsonEncode([
          {'input': '2', 'expectedOutput': '2'},
          {'input': '3', 'expectedOutput': '3'}
        ])
      },
      {
        'id': '3',
        'title': 'Valid Parentheses',
        'topic': 'Stack',
        'difficulty': 'Easy',
        'description':
            "Given a string `s` containing just the characters '(', ')', '{', '}', '[' and ']', determine if the input string is valid.",
        'description_ko': null,
        'templates': jsonEncode({
          'JavaScript': 'function isValid(s) {\n  // Write your code here\n}',
          'Python': 'def is_valid(s):\n    # Write your code here\n    pass',
          'C++':
              'class Solution {\npublic:\n    bool isValid(string s) {\n        // Write your code here\n    }\n};',
          'Java':
              'class Solution {\n    public boolean isValid(String s) {\n        // Write your code here\n    }\n}'
        }),
        'test_cases': jsonEncode([
          {'input': "'()'", 'expectedOutput': 'true'},
          {'input': "'()[]{}'", 'expectedOutput': 'true'}
        ])
      },
      {
        'id': '4',
        'title': 'House Robber',
        'topic': 'DP',
        'difficulty': 'Medium',
        'description':
            'You are a professional robber planning to rob houses along a street. Each house has a certain amount of money stashed, the only constraint stopping you from robbing each of them is that adjacent houses have security systems connected.',
        'description_ko': null,
        'templates': jsonEncode({
          'JavaScript': 'function rob(nums) {\n  // Write your code here\n}',
          'Python': 'def rob(nums):\n    # Write your code here\n    pass',
          'C++':
              'class Solution {\npublic:\n    int rob(vector<int>& nums) {\n        // Write your code here\n    }\n};',
          'Java':
              'class Solution {\n    public int rob(int[] nums) {\n        // Write your code here\n    }\n}'
        }),
        'test_cases': jsonEncode([
          {'input': '[1,2,3,1]', 'expectedOutput': '4'}
        ])
      }
    ];

    for (var problem in seedProblems) {
      await db.insert('problems', problem);
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add new columns to submissions table for Piston API execution details
      await db.execute('ALTER TABLE submissions ADD COLUMN runtime TEXT');
      await db.execute('ALTER TABLE submissions ADD COLUMN stdout TEXT');
      await db.execute('ALTER TABLE submissions ADD COLUMN stderr TEXT');
      await db.execute('ALTER TABLE submissions ADD COLUMN exitCode INTEGER');
      await db.execute('ALTER TABLE submissions ADD COLUMN passedTestCases INTEGER');
      await db.execute('ALTER TABLE submissions ADD COLUMN totalTestCases INTEGER');
    }
  }

  // Problems
  Future<List<Problem>> getProblems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('problems');

    return maps.map((map) {
      return Problem(
        id: map['id'] as String,
        title: map['title'] as String,
        topic: map['topic'] as String,
        difficulty: map['difficulty'] as String,
        description: map['description'] as String,
        descriptionKo: map['description_ko'] as String?,
        templates: Map<String, String>.from(jsonDecode(map['templates'] as String)),
        testCases: (jsonDecode(map['test_cases'] as String) as List)
            .map((tc) => TestCase.fromMap(tc))
            .toList(),
      );
    }).toList();
  }

  Future<void> insertProblem(Problem problem) async {
    final db = await database;
    await db.insert(
      'problems',
      {
        'id': problem.id,
        'title': problem.title,
        'topic': problem.topic,
        'difficulty': problem.difficulty,
        'description': problem.description,
        'description_ko': problem.descriptionKo,
        'templates': jsonEncode(problem.templates),
        'test_cases': jsonEncode(problem.testCases.map((tc) => tc.toMap()).toList()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Submissions
  Future<List<Submission>> getSubmissions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'submissions',
      orderBy: 'timestamp DESC',
    );

    return maps.map((map) => Submission.fromMap(map)).toList();
  }

  Future<void> insertSubmission(Submission submission) async {
    final db = await database;
    await db.insert('submissions', submission.toMap());
  }

  // Users
  Future<User?> getUser(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return User.fromMap(maps.first);
  }

  Future<List<User>> getLeaderboard() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      orderBy: 'points DESC',
      limit: 10,
    );

    return maps.map((map) => User.fromMap(map)).toList();
  }

  Future<void> updateUser(User user) async {
    final db = await database;
    await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }
}
