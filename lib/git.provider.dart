import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:git/git.dart';

final authorProvider = StateProvider<String>((ref) => '');
final commitsProvider = StateProvider<List<Commit>>((ref) => []);
final branchesProvider = StateProvider<List<String>>((ref) => []);

class GitStateNotifier extends StateNotifier<GitState> {
  GitStateNotifier() : super(GitState());

  void updateAuthor(String author) {
    state = GitState(
        author: author, commits: state.commits, branches: state.branches);
  }

  void updateCommits(List<Commit> commits) {
    state = GitState(
        author: state.author, commits: commits, branches: state.branches);
  }

  void updateBranches(List<String> branches) {
    state = GitState(
        author: state.author, commits: state.commits, branches: branches);
  }
}

class GitState {
  final String author;
  final List<Commit> commits;
  final List<String> branches;

  GitState(
      {this.author = '', this.commits = const [], this.branches = const []});
}

final gitStateProvider =
    StateNotifierProvider.autoDispose<GitStateNotifier, GitState>(
        (ref) => GitStateNotifier());
