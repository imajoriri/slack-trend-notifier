import 'package:flutter_trend/model/github_label.dart';
import 'package:flutter_trend/model/github_user.dart';

/// Issueのclass
class GitHubIssue {
  final String title;
  final String body;
  final String url;
  final int number;
  final bool isOpen;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? closedAt;
  final bool isPullRequest;
  final List<GitHubLabel> labels;
  final GitHubUser user;

  GitHubIssue.fromJson(Map<String, dynamic> issue)
    : title = issue['title'],
      body = issue['body'],
      url = issue['html_url'],
      number = issue['number'],
      isOpen = issue['state'] == 'open',
      createdAt = DateTime.parse(issue['created_at']),
      updatedAt = DateTime.parse(issue['updated_at']),
      closedAt =
          issue['closed_at'] != null
              ? DateTime.parse(issue['closed_at'])
              : null,
      isPullRequest = issue['pull_request'] != null,
      labels =
          (issue['labels'] as List)
              .map((label) => GitHubLabel.fromJson(label))
              .toList(),
      user = GitHubUser.fromJson(issue['user']);
}
