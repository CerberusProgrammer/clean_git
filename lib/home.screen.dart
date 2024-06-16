import 'package:clean_git/git.riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

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
                  return Expanded(
                    child: ListView.builder(
                      itemCount: gitRepo.commits.length,
                      itemBuilder: (context, index) {
                        final commit = gitRepo.commits[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 50,
                                child: Center(
                                  child: Container(
                                    height: 20,
                                    width: 20,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Commit: ${commit.sha}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text('Author: ${commit.author}'),
                                    Text('Message: ${commit.message}'),
                                    Text(
                                        'Date: ${DateFormat('yyyy-MM-dd HH:mm').format(commit.date)}'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                }
              },
              loading: () => const CircularProgressIndicator(),
              error: (error, stackTrace) {
                throw error;
              },
            ),
          ],
        ),
      ),
    );
  }
}
