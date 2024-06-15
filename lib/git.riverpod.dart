import 'package:clean_git/models/branch.dart';
import 'package:clean_git/models/commit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:git/git.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

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

          ProcessResult resultCommits = await gitDir.runCommand([
            'log',
            '--all',
            '--decorate',
            '--oneline',
            '--pretty=format:%H %s (%an, %d)'
          ]);
          List<String> rawCommits = resultCommits.stdout.trim().split('\n');

          List<CustomCommit> commits = rawCommits.map((commit) {
            List<String> parts = commit.split(' ');
            String sha = parts.removeAt(0);
            String message = parts.join(' ');
            return CustomCommit(
                sha: sha, message: message, author: parts[2], branch: parts[3]);
          }).toList();

          ProcessResult resultBranches =
              await gitDir.runCommand(['branch', '-a']);
          List<String> rawBranches = resultBranches.stdout.trim().split('\n');
          List<Branch> branches = [];
          for (String branch in rawBranches) {
            branch = branch.trim().replaceFirst('*', '').trim();
            ProcessResult resultLastCommit =
                await gitDir.runCommand(['log', '-1', branch]);
            String lastCommit =
                resultLastCommit.stdout.trim().split('\n').first;
            ProcessResult resultTotalCommits =
                await gitDir.runCommand(['rev-list', '--count', branch]);
            int totalCommits = int.parse(resultTotalCommits.stdout.trim());

            branches.add(Branch(
                name: branch,
                lastCommit: lastCommit,
                totalCommits: totalCommits));
          }

          state = AsyncValue.data(
              GitRepo(author: author, commits: commits, branches: branches));
        }
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
