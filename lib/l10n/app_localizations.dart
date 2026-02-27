import 'package:flutter/material.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

abstract class AppLocalizations {
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  // Common
  String get appName;
  String get home;
  String get practice;
  String get mock;
  String get learn;
  String get points;
  String get solved;
  String get submissions;
  String get successRate;
  String get achievements;
  String get difficulty;
  String get topic;
  String get easy;
  String get medium;
  String get hard;
  String get submit;
  String get cancel;
  String get save;
  String get delete;
  String get edit;
  String get add;
  String get refresh;
  String get loading;
  String get error;
  String get success;
  String get warning;
  String get info;
  String get close;
  String get back;
  String get next;
  String get previous;
  String get done;
  String get skip;
  String get retry;
  String get confirm;

  // Dashboard
  String get welcome;
  String get todaysGoal;
  String get recentSubmissions;
  String get quickActions;
  String get solveProblem;
  String get takeMockTest;
  String get explorePaths;
  String get viewLeaderboard;
  String get viewProfile;
  String get problemsSolved;
  String get dayStreak;

  // Practice
  String get pickChallenge;
  String get importProblem;
  String get noProblems;
  String get startPracticing;

  // Mock Test
  String get mockTestMode;
  String get mockTestDescription;
  String get startMockTest;
  String get mockTestRequirement;
  String get currentProblems;
  String get importMoreProblems;
  String get timeRemaining;
  String get problemsCompleted;

  // Learning Paths
  String get learningPaths;
  String get structuredLearning;
  String get masterAlgorithms;
  String get chooseYourPath;
  String get modules;
  String get modulesCompleted;
  String get estimatedHours;
  String get practiceProblems;
  String get practiceProblemsComingSoon;
  String get dynamicProgramming;
  String get dynamicProgrammingDesc;
  String get graphTheory;
  String get graphTheoryDesc;
  String get greedyAlgorithms;
  String get greedyAlgorithmsDesc;
  String get dataStructures;
  String get dataStructuresDesc;

  // Leaderboard
  String get leaderboard;
  String get globalRankings;
  String get competeWorldwide;
  String get allRankings;
  String get rank;
  String get you;

  // Profile
  String get profile;
  String get statistics;
  String get problemsByDifficulty;
  String get topicsMastered;
  String get recentActivity;
  String get noAchievements;
  String get keepSolving;
  String get noRecentActivity;

  // Import Problem
  String get importProblemTitle;
  String get problemUrl;
  String get problemUrlHint;
  String get problemDetails;
  String get problemId;
  String get title;
  String get description;
  String get descriptionEn;
  String get descriptionKo;
  String get inputFormat;
  String get outputFormat;
  String get constraints;
  String get sampleTestCases;
  String get sampleInput;
  String get expectedOutput;
  String get quickTemplates;
  String get importing;
  String get importSuccess;
  String get importError;
  String get howToImport;
  String get importFromUrl;
  String get manualImport;
  String get tipUseTemplates;
  String get gotIt;

  // Problem Detail
  String get yourSolution;
  String get language;
  String get runCode;
  String get submitSolution;
  String get runningCode;
  String get allTestsPassed;
  String get testsFailed;
  String get runtimeError;
  String get wrongAnswer;
  String get timeLimitExceeded;
  String get submittedSuccessfully;

  // Code Editor
  String get ready;
  String get writeCodeHere;

  // Settings
  String get settings;
  String get languageSettings;
  String get selectLanguage;
  String get english;
  String get korean;
  String get changeLanguage;
  String get languageChanged;

  // Achievements
  String get firstSteps;
  String get problemSolver;
  String get risingStar;
  String get codeMaster;
  String get perfectionist;
  String get committed;
  String get dedicated;
  String get unstoppable;
  String get centuryClub;
  String get pointChampion;

  // Topics
  String get array;
  String get string;
  String get math;
  String get dp;
  String get graph;
  String get greedy;
  String get implementation;
  String get bruteForce;
  String get stack;
  String get queue;
  String get tree;
  String get binarySearch;
  String get sorting;
  String get twoPointers;
  String get slidingWindow;
  String get backtracking;
  String get divideAndConquer;

  // Time
  String get justNow;
  String minutesAgo(int minutes);
  String hoursAgo(int hours);
  String daysAgo(int days);
  String get dayStreakCount;
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ko'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    switch (locale.languageCode) {
      case 'ko':
        return AppLocalizationsKo();
      case 'en':
      default:
        return AppLocalizationsEn();
    }
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
