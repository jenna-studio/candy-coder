import '../models/problem.dart';
import 'url_parser.dart';
import 'baekjoon_service.dart';
import 'leetcode_service.dart';

/// Unified service for importing problems from multiple platforms
class ProblemImportService {
  final BaekjoonService _baekjoonService = BaekjoonService();
  final LeetCodeService _leetCodeService = LeetCodeService();

  /// Import a problem from URL or manual entry
  ///
  /// This method tries to parse the URL and determine the platform,
  /// then creates the appropriate problem structure.
  Problem? createProblemFromUrl({
    required String urlOrId,
    required String title,
    required String description,
    String? descriptionKo,
    String? inputFormat,
    String? outputFormat,
    String? constraints,
    required List<Map<String, String>> sampleCases,
    String? difficulty,
    String? topic,
  }) {
    // Try to parse URL
    final urlInfo = ProblemUrlParser.parse(urlOrId);

    if (urlInfo != null) {
      // URL was successfully parsed
      return _createFromParsedUrl(
        urlInfo: urlInfo,
        title: title,
        description: description,
        descriptionKo: descriptionKo,
        inputFormat: inputFormat,
        outputFormat: outputFormat,
        constraints: constraints,
        sampleCases: sampleCases,
        difficulty: difficulty,
        topic: topic,
      );
    } else {
      // Not a URL, treat as manual entry
      // Default to Baekjoon format if numeric, LeetCode otherwise
      final isNumeric = int.tryParse(urlOrId) != null;

      if (isNumeric) {
        return _baekjoonService.createProblemFromManualEntry(
          problemId: urlOrId,
          title: title,
          description: description,
          inputFormat: inputFormat ?? '',
          outputFormat: outputFormat ?? '',
          sampleCases: sampleCases,
          difficulty: difficulty ?? 'Medium',
          topic: topic ?? 'Implementation',
        );
      } else {
        return _leetCodeService.createProblemFromManualEntry(
          problemId: urlOrId,
          title: title,
          description: description,
          descriptionKo: descriptionKo,
          constraints: constraints,
          sampleCases: sampleCases,
          difficulty: difficulty ?? 'Medium',
          topic: topic ?? 'Algorithm',
        );
      }
    }
  }

  /// Create problem from parsed URL info
  Problem _createFromParsedUrl({
    required ProblemUrlInfo urlInfo,
    required String title,
    required String description,
    String? descriptionKo,
    String? inputFormat,
    String? outputFormat,
    String? constraints,
    required List<Map<String, String>> sampleCases,
    String? difficulty,
    String? topic,
  }) {
    switch (urlInfo.platform) {
      case ProblemPlatform.baekjoon:
        return _baekjoonService.createProblemFromManualEntry(
          problemId: urlInfo.problemId,
          title: title,
          description: description,
          inputFormat: inputFormat ?? '',
          outputFormat: outputFormat ?? '',
          sampleCases: sampleCases,
          difficulty: difficulty ?? BaekjoonService.suggestDifficulty(urlInfo.problemId),
          topic: topic ?? 'Implementation',
        );

      case ProblemPlatform.leetcode:
        return _leetCodeService.createProblemFromManualEntry(
          problemId: urlInfo.problemId,
          title: title,
          description: description,
          descriptionKo: descriptionKo,
          constraints: constraints,
          sampleCases: sampleCases,
          difficulty: difficulty ?? LeetCodeService.suggestDifficulty(title),
          topic: topic ?? 'Algorithm',
        );
    }
  }

  /// Get platform-specific templates
  List<dynamic> getTemplates(ProblemPlatform? platform) {
    if (platform == null) {
      return [
        ...BaekjoonService.getCommonTemplates(),
        ...LeetCodeService.getCommonTemplates(),
      ];
    }

    switch (platform) {
      case ProblemPlatform.baekjoon:
        return BaekjoonService.getCommonTemplates();
      case ProblemPlatform.leetcode:
        return LeetCodeService.getCommonTemplates();
    }
  }

  /// Get topic suggestions based on platform
  List<String> getTopicSuggestions(ProblemPlatform? platform) {
    if (platform == null) {
      // Merge both lists
      final topics = <String>{
        ...BaekjoonService.getTopicSuggestions(),
        ...LeetCodeService.getTopicSuggestions(),
      };
      return topics.toList()..sort();
    }

    switch (platform) {
      case ProblemPlatform.baekjoon:
        return BaekjoonService.getTopicSuggestions();
      case ProblemPlatform.leetcode:
        return LeetCodeService.getTopicSuggestions();
    }
  }

  /// Validate problem ID based on platform
  bool isValidProblemId(String id, ProblemPlatform? platform) {
    if (platform == null) {
      return BaekjoonService.isValidProblemId(id) ||
             LeetCodeService.isValidProblemId(id);
    }

    switch (platform) {
      case ProblemPlatform.baekjoon:
        return BaekjoonService.isValidProblemId(id);
      case ProblemPlatform.leetcode:
        return LeetCodeService.isValidProblemId(id);
    }
  }

  /// Get smart suggestions based on URL or ID
  ImportSuggestions getSuggestions(String urlOrId) {
    final urlInfo = ProblemUrlParser.parse(urlOrId);

    if (urlInfo != null) {
      return ImportSuggestions(
        platform: urlInfo.platform,
        problemId: urlInfo.problemId,
        suggestedDifficulty: _getSuggestedDifficulty(urlInfo),
        suggestedTopics: getTopicSuggestions(urlInfo.platform),
        helpText: 'Detected ${urlInfo.platformName} problem ${urlInfo.problemId}. '
                  'Fill in the details from the problem page.',
      );
    }

    // Try to infer from ID format
    final isNumeric = int.tryParse(urlOrId) != null;
    final platform = isNumeric ? ProblemPlatform.baekjoon : ProblemPlatform.leetcode;

    return ImportSuggestions(
      platform: platform,
      problemId: urlOrId,
      suggestedDifficulty: isNumeric
          ? BaekjoonService.suggestDifficulty(urlOrId)
          : 'Medium',
      suggestedTopics: getTopicSuggestions(platform),
      helpText: 'Detected ${platform == ProblemPlatform.baekjoon ? 'Baekjoon' : 'LeetCode'} format. '
                'Enter problem details manually.',
    );
  }

  String _getSuggestedDifficulty(ProblemUrlInfo urlInfo) {
    switch (urlInfo.platform) {
      case ProblemPlatform.baekjoon:
        return BaekjoonService.suggestDifficulty(urlInfo.problemId);
      case ProblemPlatform.leetcode:
        return 'Medium';
    }
  }
}

/// Suggestions for import based on URL/ID analysis
class ImportSuggestions {
  final ProblemPlatform platform;
  final String problemId;
  final String suggestedDifficulty;
  final List<String> suggestedTopics;
  final String helpText;

  ImportSuggestions({
    required this.platform,
    required this.problemId,
    required this.suggestedDifficulty,
    required this.suggestedTopics,
    required this.helpText,
  });
}
