import 'package:clean_git/models/commit.dart';

class Branch {
  final String name;
  final List<CustomCommit> commits;

  Branch({
    required this.name,
    required this.commits,
  });

  @override
  String toString() {
    return 'Branch(name: $name, commits: $commits)';
  }
}
