import 'package:clean_git/models/commit.dart';

class Branch {
  final String name;
  final List<CustomCommit> commits;
  final String originBranch;
  final List<String> mergedBranches;
  final List<String> unmergedBranches;
  final List<String> authors;
  final int ahead;
  final int behind;

  Branch({
    required this.name,
    required this.commits,
    required this.originBranch,
    required this.mergedBranches,
    required this.unmergedBranches,
    required this.authors,
    required this.ahead,
    required this.behind,
  });

  @override
  String toString() {
    return 'Branch(name: $name, commits: $commits, originBranch: $originBranch, mergedBranches: $mergedBranches, unmergedBranches: $unmergedBranches, authors: $authors, ahead: $ahead, behind: $behind)';
  }
}
