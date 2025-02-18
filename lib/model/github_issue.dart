import 'package:flutter_trend/model/github_label.dart';
import 'package:flutter_trend/model/github_user.dart';

enum GitHubIssueState { open, closed }

/// Issueのclass
class GitHubIssue {
  final String title;
  final String body;
  final String url;
  final int number;
  final GitHubIssueState state;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? closedAt;
  final List<GitHubLabel> labels;
  final GitHubUser user;

  GitHubIssue({
    required this.title,
    required this.body,
    required this.url,
    required this.number,
    required this.createdAt,
    required this.updatedAt,
    required this.closedAt,
    required this.state,
    required this.labels,
    required this.user,
  });

  factory GitHubIssue.fromJson(Map<String, dynamic> json) {
    return GitHubIssue(
      title: json['title'] as String,
      body: json['body'] as String? ?? '',
      url: json['html_url'] as String,
      number: json['number'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      closedAt:
          json['closed_at'] == null
              ? null
              : DateTime.parse(json['closed_at'] as String),
      state:
          json['state'] == 'open'
              ? GitHubIssueState.open
              : GitHubIssueState.closed,
      labels:
          (json['labels'] as List)
              .map((e) => GitHubLabel.fromJson(e as Map<String, dynamic>))
              .toList(),
      user: GitHubUser.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
