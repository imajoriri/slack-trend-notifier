class GitHubLabel {
  final String name;
  final String color;

  GitHubLabel({required this.name, required this.color});

  factory GitHubLabel.fromJson(Map<String, dynamic> label) {
    return GitHubLabel(name: label['name'], color: label['color']);
  }
}
