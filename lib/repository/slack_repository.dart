import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_trend/model/github_color.dart';
import 'package:flutter_trend/model/github_issue.dart';
import 'package:flutter_trend/model/github_pulls.dart';

/// Slackのtokenを設定
final slackToken = Platform.environment['SLACK_TOKEN'];

class SlackRepository {
  final Dio dio = Dio();

  Future<void> sendPullRequestMessage({
    required GitHubPull pulls,
    required String slackChannel,
  }) async {
    final attachments = [
      {
        'color': switch (pulls.state) {
          GitHubPullState.open => GitHubColor.gitHubOpen.color,
          GitHubPullState.closed => GitHubColor.gitHubClosed.color,
          GitHubPullState.merged => GitHubColor.gitHubClosed.color,
        },
        'title': pulls.title,
        'title_link': pulls.url,
        'text':
            '${pulls.body.substring(0, pulls.body.length > 300 ? 300 : pulls.body.length)}'
            '${pulls.body.length > 300 ? "..." : ""}\n\n${pulls.labels.map((label) => '`${label.name}`').join(' ')}',
        'author_name': pulls.user.login,
        'author_icon': pulls.user.avatarUrl,
      },
    ];

    final payload = {
      'channel': slackChannel,
      'text': '',
      'attachments': attachments,
    };

    final response = await dio.post(
      'https://slack.com/api/chat.postMessage',
      data: jsonEncode(payload),
      options: Options(
        headers: {
          'Authorization': 'Bearer ${Platform.environment['SLACK_TOKEN']}',
        },
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(response.data);
    }
  }

  Future<void> sendIssueMessage({
    required GitHubIssue issue,
    required String slackChannel,
  }) async {
    final attachments = [
      {
        'color': switch (issue.state) {
          GitHubIssueState.open => GitHubColor.gitHubOpen.color,
          GitHubIssueState.closed => GitHubColor.gitHubClosed.color,
        },
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
      'channel': slackChannel,
      'text': '',
      'attachments': attachments,
    };

    final response = await dio.post(
      'https://slack.com/api/chat.postMessage',
      data: jsonEncode(payload),
      options: Options(
        headers: {
          'Authorization': 'Bearer ${Platform.environment['SLACK_TOKEN']}',
        },
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(response.data);
    }
  }
}
