class GitHubComment {
  final String body;
  final String url;
  final String issueUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  GitHubComment({
    required this.body,
    required this.url,
    required this.issueUrl,
    required this.createdAt,
    required this.updatedAt,
  });
}
