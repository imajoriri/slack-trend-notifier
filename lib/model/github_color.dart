enum GitHubColor {
  gitHubOpen,
  gitHubClosed;

  String get color {
    switch (this) {
      case GitHubColor.gitHubOpen:
        return '#1f883d';
      case GitHubColor.gitHubClosed:
        return '#8250df';
    }
  }
}
