import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_trend/model/github_color.dart';
import 'package:flutter_trend/model/github_issue.dart';
import 'package:flutter_trend/model/github_state.dart';

final dio = Dio();

/// Slackのtokenを設定
final token = Platform.environment['SLACK_TOKEN'];

/// GitHubのtokenを設定
final githubToken = Platform.environment['PVT_GITHUB_TOKEN'];

void main(List<String> arguments) async {
  // 1時間前
  final oneHourAgo = DateTime.now().subtract(Duration(hours: 24));

  final queries = [
    GitHubIssueQuery(
      slackChannel: '#flutter',
      // label: 'f: cupertino',
      since: oneHourAgo,
      state: GitHubState.open,
    ),
  ];

  for (final query in queries) {
    final url = query.generateUrl();
    print(url);

    final response = await dio.get(url);
    final issues =
        (response.data as List).map((e) => GitHubIssue.fromJson(e)).toList();

    for (final issue in issues) {
      final attachments = [
        {
          'color':
              issue.isOpen
                  ? GitHubColor.gitHubOpen.color
                  : GitHubColor.gitHubClosed.color,
          'title': issue.title,
          'title_link': issue.url,
          'text':
              '${issue.body.substring(0, issue.body.length > 300 ? 300 : issue.body.length)}'
              '${issue.body.length > 300 ? "..." : ""}\n\n${issue.labels.map((label) => '`${label.name}`').join(' ')}',
          'author_name': issue.user.login,
          'author_icon': issue.user.avatarUrl,
        },
      ];

      final payload = {
        'channel': query.slackChannel,
        'text': '',
        'attachments': attachments,
      };

      print(token);

      final response = await dio.post(
        'https://slack.com/api/chat.postMessage',
        data: jsonEncode(payload),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print(response.data);
    }
  }
}

/// 参考 https://docs.github.com/ja/rest/issues/issues?apiVersion=2022-11-28#list-repository-issues
class GitHubIssueQuery {
  final String slackChannel;
  final String? label;
  final DateTime since;
  final GitHubState state;

  GitHubIssueQuery({
    required this.slackChannel,
    required this.since,
    required this.state,
    this.label,
  });

  String generateUrl([String repository = 'flutter/flutter']) {
    final baseUrl = 'https://api.github.com/repos/$repository/issues';
    final params = {
      'labels': label,
      'since': since.toIso8601String(),
      'state': state.name,
      'per_page': '1',
    };
    final queryString = params.entries
        .map(
          (e) =>
              e.value == null
                  ? ''
                  : '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value!)}',
        )
        .join('&');
    return '$baseUrl?$queryString';
  }
}
