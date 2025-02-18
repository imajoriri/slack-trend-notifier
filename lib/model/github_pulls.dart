import 'package:flutter_trend/model/github_label.dart';
import 'package:flutter_trend/model/github_user.dart';

enum GitHubPullState { open, closed, merged }

/// Issueのclass
class GitHubPull {
  final String title;
  final String body;
  final String url;
  final int number;
  final GitHubPullState state;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? closedAt;
  final DateTime? mergedAt;
  final List<GitHubLabel> labels;
  final GitHubUser user;

  GitHubPull({
    required this.title,
    required this.body,
    required this.url,
    required this.number,
    required this.createdAt,
    required this.updatedAt,
    required this.closedAt,
    required this.mergedAt,
    required this.state,
    required this.labels,
    required this.user,
  });
}
