/// Utility for parsing problem URLs from various platforms
class ProblemUrlParser {
  /// Parse a URL and extract platform and problem ID
  static ProblemUrlInfo? parse(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;

    // Baekjoon: https://www.acmicpc.net/problem/1000
    if (uri.host.contains('acmicpc.net')) {
      final match = RegExp(r'/problem/(\d+)').firstMatch(uri.path);
      if (match != null) {
        return ProblemUrlInfo(
          platform: ProblemPlatform.baekjoon,
          problemId: match.group(1)!,
          url: url,
        );
      }
    }

    // LeetCode: https://leetcode.com/problems/two-sum/
    if (uri.host.contains('leetcode.com')) {
      final match = RegExp(r'/problems/([\w-]+)/?').firstMatch(uri.path);
      if (match != null) {
        return ProblemUrlInfo(
          platform: ProblemPlatform.leetcode,
          problemId: match.group(1)!,
          url: url,
        );
      }
    }

    return null;
  }

  /// Check if a string looks like a URL
  static bool looksLikeUrl(String text) {
    return text.startsWith('http://') ||
           text.startsWith('https://') ||
           text.contains('acmicpc.net') ||
           text.contains('leetcode.com');
  }
}

/// Information extracted from a problem URL
class ProblemUrlInfo {
  final ProblemPlatform platform;
  final String problemId;
  final String url;

  ProblemUrlInfo({
    required this.platform,
    required this.problemId,
    required this.url,
  });

  String get platformName {
    switch (platform) {
      case ProblemPlatform.baekjoon:
        return 'Baekjoon';
      case ProblemPlatform.leetcode:
        return 'LeetCode';
    }
  }

  String get displayId {
    switch (platform) {
      case ProblemPlatform.baekjoon:
        return problemId;
      case ProblemPlatform.leetcode:
        return problemId.split('-').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ');
    }
  }
}

enum ProblemPlatform {
  baekjoon,
  leetcode,
}
