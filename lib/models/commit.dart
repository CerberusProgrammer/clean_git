class CustomCommit {
  final String sha;
  final String message;
  final String author;
  final DateTime date;
  final List<String> filesModified;
  final int linesInserted;
  final int linesDeleted;
  final String branch;

  CustomCommit({
    required this.sha,
    required this.message,
    required this.author,
    required this.date,
    required this.filesModified,
    required this.branch,
    required this.linesInserted,
    required this.linesDeleted,
  });

  @override
  String toString() {
    return 'Commit(sha: $sha, message: $message, author: $author, date: $date, filesModified: $filesModified, linesInserted: $linesInserted, linesDeleted: $linesDeleted)';
  }
}
