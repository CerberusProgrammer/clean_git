import 'package:clean_git/models/branch.dart';
import 'package:git/git.dart';

class Timeline {
  final List<Commit> commits;
  final List<Branch> branches;

  Timeline({
    required this.commits,
    required this.branches,
  });

  @override
  String toString() {
    return 'Timeline(commits: $commits, branches: $branches)';
  }
}
