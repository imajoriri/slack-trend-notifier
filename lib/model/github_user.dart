class GitHubUser {
  final String login;
  final String avatarUrl;

  GitHubUser({required this.login, required this.avatarUrl});

  factory GitHubUser.fromJson(Map<String, dynamic> user) {
    return GitHubUser(login: user['login'], avatarUrl: user['avatar_url']);
  }
}
