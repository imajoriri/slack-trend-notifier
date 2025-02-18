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
  final DateTime? mergedAt;
  final bool isPullRequest;
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
    required this.mergedAt,
    required this.isOpen,
    required this.labels,
    required this.user,
    required this.isPullRequest,
  });

  factory GitHubIssue.fromJson(Map<String, dynamic> json) {
    final pullRequest = json['pull_request'];

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
      mergedAt:
          json['pull_request'] == null ||
                  json['pull_request']['merged_at'] == null
              ? null
              : DateTime.parse(json['pull_request']['merged_at'] as String),
      isOpen: json['state'] == 'open',
      labels:
          (json['labels'] as List)
              .map((e) => GitHubLabel.fromJson(e as Map<String, dynamic>))
              .toList(),
      user: GitHubUser.fromJson(json['user'] as Map<String, dynamic>),
      isPullRequest: pullRequest != null,
    );
  }
}
