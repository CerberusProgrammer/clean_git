import 'package:clean_git/models/branch.dart';
import 'package:clean_git/models/commit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:git/git.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

final gitRepoProvider =
    StateNotifierProvider<GitRepoNotifier, AsyncValue<GitRepo>>(
        (ref) => GitRepoNotifier());

class GitRepo {
  final String author;
  final List<CustomCommit> commits;
  final List<Branch> branches;

  GitRepo({
    required this.author,
    required this.commits,
    required this.branches,
  });
}

class GitRepoNotifier extends StateNotifier<AsyncValue<GitRepo>> {
  GitRepoNotifier()
      : super(AsyncValue.data(GitRepo(author: "", commits: [], branches: [])));

  Future<void> openDirectory() async {
    state = const AsyncValue.loading();

    try {
      String? directoryPath = await FilePicker.platform.getDirectoryPath();
      if (directoryPath != null) {
        Directory directory = Directory(directoryPath);
        bool gitFolderExists =
            await Directory('${directory.path}/.git').exists();
        if (gitFolderExists) {
          GitDir gitDir = await GitDir.fromExisting(directory.path);
          ProcessResult result =
              await gitDir.runCommand(['config', 'user.name']);
          String author = result.stdout.trim();

          List<CustomCommit> commits = await getCommits(gitDir);
          List<Branch> branches = await getBranches(gitDir, commits);

          state = AsyncValue.data(
              GitRepo(author: author, commits: commits, branches: branches));
        }
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<List<CustomCommit>> getCommits(GitDir gitDir) async {
    ProcessResult resultCommits = await gitDir.runCommand([
      'log',
      '--all',
      '--decorate',
      '--oneline',
      '--pretty=format:%H %s (%an, %ad)'
    ]);
    List<String> rawCommits = resultCommits.stdout.trim().split('\n');

    return rawCommits.map((commit) {
      List<String> parts = commit.split(' ');
      String sha = parts.removeAt(0);
      String message = parts.join(' ');
      String dateString = parts.sublist(parts.length - 6).join(' ');
      DateFormat format = DateFormat('E MMM d HH:mm:ss yyyy Z');
      DateTime date = format.parse(dateString);
      return CustomCommit(
        sha: sha,
        message: message,
        author: parts[2],
        date: date,
        branch: '',
        filesModified: [],
        linesInserted: 0,
        linesDeleted: 0,
      );
    }).toList();
  }

  Future<List<Branch>> getBranches(
      GitDir gitDir, List<CustomCommit> commits) async {
    ProcessResult resultBranches = await gitDir.runCommand(['branch', '-a']);
    List<String> rawBranches = resultBranches.stdout.trim().split('\n');
    List<Branch> branches = [];
    for (String branch in rawBranches) {
      branch = branch.trim().replaceFirst('*', '').trim();
      List<CustomCommit> branchCommits =
          commits.where((commit) => commit.branch.contains(branch)).toList();

      branches.add(Branch(
          name: branch,
          commits: branchCommits,
          originBranch: '',
          mergedBranches: [],
          unmergedBranches: [],
          authors: [],
          ahead: 0,
          behind: 0));
    }

    return branches;
  }
}
