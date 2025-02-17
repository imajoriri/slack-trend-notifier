import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_trend/model/github_color.dart';
import 'package:flutter_trend/model/github_issue.dart';
import 'package:flutter_trend/model/github_state.dart';
import 'package:logger/web.dart';

final dio = Dio();

/// Slackのtokenを設定
final token = Platform.environment['SLACK_TOKEN'];

/// GitHubのtokenを設定
final githubToken = Platform.environment['PVT_GITHUB_TOKEN'];

/// ログをデバッグでも表示するためのクラス。
// github actionsで使う想定のため問題ない。
class MyFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    return true;
  }
}

final log = Logger(
  printer: PrettyPrinter(),
  output: ConsoleOutput(),
  level: Level.all,
  filter: MyFilter(),
);

void main(List<String> arguments) async {
  // 1時間前
  final oneHourAgo = DateTime.now().toUtc().subtract(Duration(hours: 1));
  print(oneHourAgo);

  final queries = [
    GitHubIssueQuery(
      slackChannel: '#repo-material-design',
      label: 'f: material design',
      since: oneHourAgo,
      state: GitHubState.open,
    ),
    GitHubIssueQuery(
      slackChannel: '#repo-cupertino',
      label: 'f: cupertino',
      since: oneHourAgo,
      state: GitHubState.open,
    ),
    GitHubIssueQuery(
      slackChannel: '#repo-animation',
      label: 'a: animation',
      since: oneHourAgo,
      state: GitHubState.open,
    ),
    GitHubIssueQuery(
      slackChannel: '#repo-animation',
      label: 'p: animations',
      since: oneHourAgo,
      state: GitHubState.open,
    ),
    GitHubIssueQuery(
      slackChannel: '#repo-pull-request-all',
      since: oneHourAgo,
      state: GitHubState.open,
    ),
  ];

  for (final query in queries) {
    final url = query.generateUrl();
    log.i(url);

    late final Response response;
    try {
      response = await dio.get(
        url,
        options: Options(headers: {'Authorization': 'Bearer $githubToken'}),
      );
    } on DioException catch (e) {
      log.e(e);
      continue;
    }
    final issues =
        (response.data as List).map((e) => GitHubIssue.fromJson(e)).toList();

    for (final issue in issues) {
      // 1時間前に作成されたissueで、1時間前に閉じられたissueは除外
      if (issue.createdAt.isBefore(oneHourAgo) &&
          (issue.closedAt?.isBefore(oneHourAgo) ?? true)) {
        continue;
      }
      log.i(issue.title);
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

      try {
        final response = await dio.post(
          'https://slack.com/api/chat.postMessage',
          data: jsonEncode(payload),
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );
        log.i(response.data);
      } on DioException catch (e) {
        log.e(e);
      }
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
