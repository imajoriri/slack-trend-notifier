import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_trend/model/github_issue.dart';
import 'package:flutter_trend/model/github_label.dart';
import 'package:flutter_trend/model/github_pulls.dart';
import 'package:flutter_trend/model/github_user.dart';
import 'package:graphql/client.dart';

/// GitHubのtokenを設定
final githubToken = Platform.environment['PVT_GITHUB_TOKEN'];

GraphQLClient getGithubGraphQLClient() {
  final Link link = HttpLink(
    'https://api.github.com/graphql',
    defaultHeaders: {'Authorization': 'Bearer $githubToken'},
  );

  return GraphQLClient(cache: GraphQLCache(), link: link);
}

class GitHubRepository {
  final Dio dio = Dio();

  Future<List<GitHubPull>> fetchPulls({
    required DateTime since,
    String? label,
  }) async {
    final GraphQLClient client = getGithubGraphQLClient();

    final searchQuery =
        'type:pr repo:flutter/flutter ${label != null ? 'label:"$label"' : ''} merged:>${since.toUtc().toIso8601String().replaceAll('Z', '+00:00')}';

    final QueryOptions options = QueryOptions(
      document: gql(r'''
        query SearchPulls($searchQuery: String!) {
          search(query: $searchQuery, type: ISSUE, first: 20) {
            nodes {
              ... on PullRequest {
                id
                title
                body
                url
                number
                createdAt
                updatedAt
                closedAt
                mergedAt
                labels(first: 10) {
                  nodes {
                    name
                    color
                  }
                }
                author {
                  login
                  avatarUrl
                }
              }
            }
          }
        }
      '''),
      variables: {'searchQuery': searchQuery},
    );

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      throw Exception(result.exception);
    }

    final pulls =
        (result.data!['search']['nodes'] as List)
            .map<GitHubPull>(
              (dynamic node) => GitHubPull(
                title: node['title'] as String,
                body: node['body'] as String? ?? '',
                url: node['url'] as String,
                number: node['number'] as int,
                createdAt: DateTime.parse(node['createdAt'] as String),
                updatedAt: DateTime.parse(node['updatedAt'] as String),
                closedAt:
                    node['closedAt'] == null
                        ? null
                        : DateTime.parse(node['closedAt'] as String),
                mergedAt:
                    node['mergedAt'] == null
                        ? null
                        : DateTime.parse(node['mergedAt'] as String),
                state:
                    node['mergedAt'] != null
                        ? GitHubPullState.merged
                        : node['closedAt'] != null
                        ? GitHubPullState.closed
                        : GitHubPullState.open,
                labels:
                    (node['labels']['nodes'] as List)
                        .map(
                          (label) => GitHubLabel(
                            name: label['name'] as String,
                            color: label['color'] as String,
                          ),
                        )
                        .toList(),
                user: GitHubUser(
                  login: node['author']['login'] as String,
                  avatarUrl: node['author']['avatarUrl'] as String,
                ),
              ),
            )
            .toList();

    return pulls;
  }

  Future<List<GitHubIssue>> fetchIssues({
    required DateTime since,
    List<String>? labels,
    GitHubIssueState state = GitHubIssueState.open,
  }) async {
    final GraphQLClient client = getGithubGraphQLClient();

    // 参考: https://docs.github.com/ja/search-github/searching-on-github/searching-issues-and-pull-requests
    final searchQueryType = 'type:issue';
    final searchQueryRepo = 'repo:flutter/flutter';
    final searchQueryLabel =
        labels != null ? 'label:${labels.map((l) => '"$l"').join(',')}' : '';
    final searchQueryCreated =
        'created:>${since.toUtc().toIso8601String().replaceAll('Z', '+00:00')}';
    final searchQueryState = 'state:${state.name}';
    final searchQueryReason = 'reason:completed';
    final searchQuery =
        '$searchQueryType $searchQueryRepo $searchQueryLabel $searchQueryCreated $searchQueryState $searchQueryReason';
    print(searchQuery);

    final QueryOptions options = QueryOptions(
      document: gql(r'''
        query SearchIssues($searchQuery: String!) {
          search(query: $searchQuery, type: ISSUE, first: 20) {
            nodes {
              ... on Issue {
                id
                title
                body
                url
                number
                state
                createdAt
                updatedAt
                closedAt
                labels(first: 10) {
                  nodes {
                    name
                    color
                  }
                }
                author {
                  login
                  avatarUrl
                }
              }
            }
          }
        }
      '''),
      variables: {'searchQuery': searchQuery},
    );

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      throw Exception(result.exception);
    }

    final issues =
        (result.data!['search']['nodes'] as List)
            .map<GitHubIssue>(
              (dynamic node) => GitHubIssue(
                title: node['title'] as String,
                body: node['body'] as String? ?? '',
                url: node['url'] as String,
                number: node['number'] as int,
                createdAt: DateTime.parse(node['createdAt'] as String),
                updatedAt: DateTime.parse(node['updatedAt'] as String),
                closedAt:
                    node['closedAt'] == null
                        ? null
                        : DateTime.parse(node['closedAt'] as String),
                state:
                    node['state'] == 'OPEN'
                        ? GitHubIssueState.open
                        : GitHubIssueState.closed,
                labels:
                    (node['labels']['nodes'] as List)
                        .map(
                          (label) => GitHubLabel(
                            name: label['name'] as String,
                            color: label['color'] as String,
                          ),
                        )
                        .toList(),
                user: GitHubUser(
                  login: node['author']['login'] as String,
                  avatarUrl: node['author']['avatarUrl'] as String,
                ),
              ),
            )
            .toList();

    return issues;
  }
}
