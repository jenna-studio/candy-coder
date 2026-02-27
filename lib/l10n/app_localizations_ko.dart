import 'app_localizations.dart';

class AppLocalizationsKo extends AppLocalizations {
  // Common
  @override
  String get appName => '캔디 코더';
  @override
  String get home => '홈';
  @override
  String get practice => '연습';
  @override
  String get mock => '모의고사';
  @override
  String get learn => '학습';
  @override
  String get points => '포인트';
  @override
  String get solved => '해결';
  @override
  String get submissions => '제출';
  @override
  String get successRate => '성공률';
  @override
  String get achievements => '업적';
  @override
  String get difficulty => '난이도';
  @override
  String get topic => '주제';
  @override
  String get easy => '쉬움';
  @override
  String get medium => '보통';
  @override
  String get hard => '어려움';
  @override
  String get submit => '제출';
  @override
  String get cancel => '취소';
  @override
  String get save => '저장';
  @override
  String get delete => '삭제';
  @override
  String get edit => '수정';
  @override
  String get add => '추가';
  @override
  String get refresh => '새로고침';
  @override
  String get loading => '로딩 중...';
  @override
  String get error => '오류';
  @override
  String get success => '성공';
  @override
  String get warning => '경고';
  @override
  String get info => '정보';
  @override
  String get close => '닫기';
  @override
  String get back => '뒤로';
  @override
  String get next => '다음';
  @override
  String get previous => '이전';
  @override
  String get done => '완료';
  @override
  String get skip => '건너뛰기';
  @override
  String get retry => '재시도';
  @override
  String get confirm => '확인';

  // Dashboard
  @override
  String get welcome => '다시 오신 것을 환영합니다!';
  @override
  String get todaysGoal => '오늘의 목표';
  @override
  String get recentSubmissions => '최근 제출';
  @override
  String get quickActions => '빠른 실행';
  @override
  String get solveProblem => '문제 풀기';
  @override
  String get takeMockTest => '모의고사 보기';
  @override
  String get explorePaths => '학습 경로 탐색';
  @override
  String get viewLeaderboard => '리더보드 보기';
  @override
  String get viewProfile => '프로필 보기';
  @override
  String get problemsSolved => '해결한 문제';
  @override
  String get dayStreak => '연속 일수';

  // Practice
  @override
  String get pickChallenge => '도전 과제 선택';
  @override
  String get importProblem => '불러오기';
  @override
  String get noProblems => '아직 문제가 없습니다. 문제를 불러와서 시작하세요!';
  @override
  String get startPracticing => '연습 시작하기';

  // Mock Test
  @override
  String get mockTestMode => '모의고사 모드';
  @override
  String get mockTestDescription => '실전 코딩 인터뷰를 시뮬레이션합니다. 3문제, 90분. 힌트 없음!';
  @override
  String get startMockTest => '모의고사 시작';
  @override
  String get mockTestRequirement => '모의고사를 시작하려면 최소 3개의 문제가 필요합니다.';
  @override
  String get currentProblems => '현재 문제 수';
  @override
  String get importMoreProblems => '더 많은 문제 불러오기';
  @override
  String get timeRemaining => '남은 시간';
  @override
  String get problemsCompleted => '완료한 문제';

  // Learning Paths
  @override
  String get learningPaths => '학습 경로';
  @override
  String get structuredLearning => '체계적인 학습';
  @override
  String get masterAlgorithms => '알고리즘을 단계별로 마스터하세요';
  @override
  String get chooseYourPath => '학습 경로 선택';
  @override
  String get modules => '모듈';
  @override
  String get modulesCompleted => '완료한 모듈';
  @override
  String get estimatedHours => '시간';
  @override
  String get practiceProblems => '연습 문제';
  @override
  String get practiceProblemsComingSoon => '연습 문제가 곧 제공됩니다! 문제를 불러와서 학습을 시작하세요.';
  @override
  String get dynamicProgramming => '동적 프로그래밍';
  @override
  String get dynamicProgrammingDesc => '복잡한 문제를 더 간단한 하위 문제로 나누어 해결하는 기술을 마스터하세요';
  @override
  String get graphTheory => '그래프 이론';
  @override
  String get graphTheoryDesc => '그래프, 트리, BFS, DFS, 다익스트라와 같은 그래프 알고리즘을 탐색하세요';
  @override
  String get greedyAlgorithms => '그리디 알고리즘';
  @override
  String get greedyAlgorithmsDesc => '지역적으로 최적의 선택을 통해 전역 해를 찾는 방법을 배우세요';
  @override
  String get dataStructures => '자료구조';
  @override
  String get dataStructuresDesc => '기본 및 고급 자료구조를 마스터하세요';

  // Leaderboard
  @override
  String get leaderboard => '리더보드';
  @override
  String get globalRankings => '글로벌 순위';
  @override
  String get competeWorldwide => '전 세계 코더들과 경쟁하세요';
  @override
  String get allRankings => '전체 순위';
  @override
  String get rank => '순위';
  @override
  String get you => '나';

  // Profile
  @override
  String get profile => '프로필';
  @override
  String get statistics => '통계';
  @override
  String get problemsByDifficulty => '난이도별 문제';
  @override
  String get topicsMastered => '마스터한 주제';
  @override
  String get recentActivity => '최근 활동';
  @override
  String get noAchievements => '아직 업적이 없습니다. 문제를 계속 풀어보세요!';
  @override
  String get keepSolving => '문제를 계속 풀어보세요!';
  @override
  String get noRecentActivity => '최근 활동이 없습니다';

  // Import Problem
  @override
  String get importProblemTitle => '문제 불러오기';
  @override
  String get problemUrl => '문제 URL 또는 ID';
  @override
  String get problemUrlHint => 'https://acmicpc.net/problem/1000 또는 https://leetcode.com/problems/two-sum';
  @override
  String get problemDetails => '문제 상세';
  @override
  String get problemId => '문제 ID';
  @override
  String get title => '제목';
  @override
  String get description => '설명';
  @override
  String get descriptionEn => 'Description (English)';
  @override
  String get descriptionKo => '설명 (한국어)';
  @override
  String get inputFormat => '입력 형식';
  @override
  String get outputFormat => '출력 형식';
  @override
  String get constraints => '제약 조건';
  @override
  String get sampleTestCases => '샘플 테스트 케이스';
  @override
  String get sampleInput => '입력';
  @override
  String get expectedOutput => '예상 출력';
  @override
  String get quickTemplates => '빠른 템플릿';
  @override
  String get importing => '불러오는 중...';
  @override
  String get importSuccess => '문제를 성공적으로 불러왔습니다!';
  @override
  String get importError => '문제 불러오기 오류';
  @override
  String get howToImport => '불러오기 방법';
  @override
  String get importFromUrl => 'URL에서 불러오기';
  @override
  String get manualImport => '수동 불러오기';
  @override
  String get tipUseTemplates => '팁: 빠른 템플릿을 사용하면 더 빠르게 시작할 수 있습니다!';
  @override
  String get gotIt => '알겠습니다';

  // Problem Detail
  @override
  String get yourSolution => '내 솔루션';
  @override
  String get language => '언어';
  @override
  String get runCode => '코드 실행';
  @override
  String get submitSolution => '솔루션 제출';
  @override
  String get runningCode => '코드를 실행 중입니다...';
  @override
  String get allTestsPassed => '모든 테스트를 통과했습니다!';
  @override
  String get testsFailed => '테스트 실패';
  @override
  String get runtimeError => '런타임 오류';
  @override
  String get wrongAnswer => '오답';
  @override
  String get timeLimitExceeded => '시간 초과';
  @override
  String get submittedSuccessfully => '솔루션을 성공적으로 제출했습니다!';

  // Code Editor
  @override
  String get ready => '준비됨';
  @override
  String get writeCodeHere => '여기에 코드를 작성하세요...';

  // Settings
  @override
  String get settings => '설정';
  @override
  String get languageSettings => '언어 설정';
  @override
  String get selectLanguage => '언어 선택';
  @override
  String get english => 'English';
  @override
  String get korean => '한국어';
  @override
  String get changeLanguage => '언어 변경';
  @override
  String get languageChanged => '언어가 성공적으로 변경되었습니다';

  // Achievements
  @override
  String get firstSteps => '첫 걸음';
  @override
  String get problemSolver => '문제 해결사';
  @override
  String get risingStar => '떠오르는 별';
  @override
  String get codeMaster => '코드 마스터';
  @override
  String get perfectionist => '완벽주의자';
  @override
  String get committed => '헌신적인';
  @override
  String get dedicated => '전념하는';
  @override
  String get unstoppable => '멈출 수 없는';
  @override
  String get centuryClub => '센추리 클럽';
  @override
  String get pointChampion => '포인트 챔피언';

  // Topics
  @override
  String get array => '배열';
  @override
  String get string => '문자열';
  @override
  String get math => '수학';
  @override
  String get dp => '동적 프로그래밍';
  @override
  String get graph => '그래프';
  @override
  String get greedy => '그리디';
  @override
  String get implementation => '구현';
  @override
  String get bruteForce => '브루트포스';
  @override
  String get stack => '스택';
  @override
  String get queue => '큐';
  @override
  String get tree => '트리';
  @override
  String get binarySearch => '이진 탐색';
  @override
  String get sorting => '정렬';
  @override
  String get twoPointers => '투 포인터';
  @override
  String get slidingWindow => '슬라이딩 윈도우';
  @override
  String get backtracking => '백트래킹';
  @override
  String get divideAndConquer => '분할 정복';

  // Time
  @override
  String get justNow => '방금 전';
  @override
  String minutesAgo(int minutes) => '$minutes분 전';
  @override
  String hoursAgo(int hours) => '$hours시간 전';
  @override
  String daysAgo(int days) => '$days일 전';
  @override
  String get dayStreakCount => '일 연속';
}
