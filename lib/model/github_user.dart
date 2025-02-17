class GitHubUser {
  final String login;
  final String avatarUrl;

  GitHubUser.fromJson(Map<String, dynamic> user)
    : login = user['login'],
      avatarUrl = user['avatar_url'];
}
