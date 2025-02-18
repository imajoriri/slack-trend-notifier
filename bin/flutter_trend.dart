import 'package:dio/dio.dart';
import 'package:flutter_trend/model/github_state.dart';
import 'package:flutter_trend/repository/github_repository.dart';
import 'package:flutter_trend/repository/slack_repository.dart';
import 'package:logger/web.dart';

final dio = Dio();

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
    // テスト用
    // GitHubIssueQueryVariables(
    //   slackChannel: '#test',
    //   label: 'framework',
    //   since: oneHourAgo,
    //   state: GitHubState.all,
    // ),
    // GitHubIssueQueryVariables(
    //   slackChannel: '#repo-material-design',
    //   label: 'f: material design',
    //   since: oneHourAgo,
    //   state: GitHubState.open,
    // ),
    // GitHubIssueQueryVariables(
    //   slackChannel: '#repo-cupertino',
    //   label: 'f: cupertino',
    //   since: oneHourAgo,
    //   state: GitHubState.open,
    // ),
    // GitHubIssueQueryVariables(
    //   slackChannel: '#repo-animation',
    //   label: 'a: animation',
    //   since: oneHourAgo,
    //   state: GitHubState.open,
    // ),
    // GitHubIssueQueryVariables(
    //   slackChannel: '#repo-animation',
    //   label: 'p: animations',
    //   since: oneHourAgo,
    //   state: GitHubState.open,
    // ),
    // GitHubIssueQueryVariables(
    //   slackChannel: '#repo-pull-request-all',
    //   since: oneHourAgo,
    //   state: GitHubState.closed,
    // ),
  ];

  final githubRepository = GitHubRepository();
  final slackRepository = SlackRepository();
  final pulls = await githubRepository.fetchPulls(since: oneHourAgo);
  for (final pull in pulls) {
    await slackRepository.sendPullRequestMessage(
      slackChannel: '#repo-pull-request-all',
      pulls: pull,
    );
  }

  for (final query in queries) {
    final issues = await githubRepository.fetchIssues(
      label: query.label,
      since: query.since,
    );
    for (final issue in issues) {
      log.i(issue.url);
      await slackRepository.sendIssueMessage(
        slackChannel: query.slackChannel,
        issue: issue,
      );
    }
  }
}

/// 参考 https://docs.github.com/ja/rest/issues/issues?apiVersion=2022-11-28#list-repository-issues
class GitHubIssueQueryVariables {
  final String slackChannel;
  final String? label;
  final DateTime since;
  final GitHubState state;

  GitHubIssueQueryVariables({
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
      'per_page': '100',
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

  String generateGraphqlUrl([String repository = 'flutter/flutter']) {
    return 'https://api.github.com/graphql';
  }
}
