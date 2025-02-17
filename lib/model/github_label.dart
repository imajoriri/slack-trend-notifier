class GitHubLabel {
  final String name;
  final String color;

  GitHubLabel.fromJson(Map<String, dynamic> label)
    : name = label['name'],
      color = label['color'];
}
