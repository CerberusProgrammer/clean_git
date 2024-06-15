import 'package:clean_git/git.riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final gitRepoAsyncValue = ref.watch(gitRepoProvider);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text('Abrir explorador de archivos'),
              onPressed: () async {
                ref.read(gitRepoProvider.notifier).openDirectory();
              },
            ),
            gitRepoAsyncValue.when(
              data: (gitRepo) {
                if (gitRepo.author.isEmpty &&
                    gitRepo.commits.isEmpty &&
                    gitRepo.branches.isEmpty) {
                  return const Text('No data');
                } else {
                  return Column(
                    children: [
                      Text('Author: ${gitRepo.author}'),
                      ...gitRepo.commits
                          .map((commit) => Text('Commit: ${commit.date}')),
                      ...gitRepo.branches
                          .map((branch) => Text('Branch: ${branch.name}')),
                    ],
                  );
                }
              },
              loading: () => const CircularProgressIndicator(),
              error: (error, stackTrace) {
                return Text('Error: $error');
              },
            ),
          ],
        ),
      ),
    );
  }
}
