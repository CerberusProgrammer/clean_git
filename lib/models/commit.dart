class CustomCommit {
  final String sha;
  final String message;
  final String author;
  final DateTime date;
  final List<String> branches;

  CustomCommit({
    required this.sha,
    required this.message,
    required this.author,
    required this.date,
    required this.branches,
  });

  @override
  String toString() {
    return 'Commit(sha: $sha, message: $message, author: $author, date: $date, branches: $branches)';
  }
}
