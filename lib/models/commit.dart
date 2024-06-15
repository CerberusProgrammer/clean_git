class CustomCommit {
  String sha;
  String message;
  String author;
  String branch;

  CustomCommit({
    required this.sha,
    required this.message,
    required this.author,
    required this.branch,
  });

  factory CustomCommit.fromJson(Map<String, dynamic> json) {
    return CustomCommit(
        sha: json['sha'],
        message: json['commit']['message'],
        author: json['commit']['author']['name'],
        branch: json['commit']['author']['branch']);
  }

  Map<String, dynamic> toJson() {
    return {
      'sha': sha,
      'message': message,
      'author': author,
      'branch': branch,
    };
  }

  @override
  String toString() {
    return 'Commit: $sha, $message, $author, $branch';
  }
}
