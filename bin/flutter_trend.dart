import 'package:dio/dio.dart';
import 'package:flutter_trend/model/github_issue.dart';
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
  log.i(oneHourAgo);

  final githubRepository = GitHubRepository();
  final slackRepository = SlackRepository();
  final pulls = await githubRepository.fetchPulls(since: oneHourAgo);
  for (final pull in pulls) {
    log.i(pull.url);
    await slackRepository.sendPullRequestMessage(
      slackChannel: '#repo-pull-request-all',
      pulls: pull,
    );
  }

  // 直近`oneHourAgo`からCloseされたIssueを取得してSlackに送信する。
  final closedIssues = await githubRepository.fetchIssues(
    since: oneHourAgo,
    state: GitHubIssueState.closed,
    labels: ['f: material design', 'f: cupertino'],
  );
  for (final issue in closedIssues) {
    log.i(issue.url);
    await slackRepository.sendIssueMessage(
      slackChannel: '#repo-pull-request-all',
      issue: issue,
    );
  }
}
