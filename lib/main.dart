import 'package:clean_git/git.riverpod.dart';
import 'package:clean_git/models/branch.dart';
import 'package:clean_git/models/commit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:git/git.dart';

void main() {
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('en', 'US'), // Define el locale
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      theme: ThemeData(brightness: Brightness.dark),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String authorName = ref.watch(authorProvider);
    List<CustomCommit> commits = ref.watch(commitsProvider);
    List<Branch> branches = ref.watch(branchesProvider);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text('Abrir explorador de archivos'),
              onPressed: () async {
                try {
                  String? directoryPath =
                      await FilePicker.platform.getDirectoryPath();

                  if (directoryPath != null) {
                    Directory directory = Directory(directoryPath);
                    bool gitFolderExists =
                        await Directory('${directory.path}/.git').exists();
                    if (gitFolderExists) {
                      GitDir gitDir = await GitDir.fromExisting(directory.path);

                      ProcessResult result =
                          await gitDir.runCommand(['config', 'user.name']);

                      ref.watch(authorProvider.notifier).state =
                          result.stdout.trim();

                      ProcessResult resultCommits = await gitDir.runCommand([
                        'log',
                        '--all',
                        '--decorate',
                        '--oneline',
                        '--pretty=format:%H %s (%an, %d)'
                      ]);
                      List<String> rawCommits =
                          resultCommits.stdout.trim().split('\n');

                      ref.watch(commitsProvider.notifier).state = rawCommits
                          .map(
                            (commit) => CustomCommit(
                              sha: commit.split(' ')[0],
                              message: commit.split(' ')[1],
                              author: commit.split(' ')[2],
                              branch: commit.split(' ')[3],
                            ),
                          )
                          .toList();

                      ProcessResult resultBranches =
                          await gitDir.runCommand(['branch', '-a']);

                      ref.watch(branchesProvider.notifier).state = [];

                      ref.watch(branchesProvider.notifier).state = [];

                      List<String> rawBranches =
                          resultBranches.stdout.trim().split('\n');

                      var br = rawBranches.map((branch) async {
                        branch = branch.trim().replaceFirst('*', '').trim();
                        branch = branch.split(' ').last;

                        ProcessResult resultLastCommit =
                            await gitDir.runCommand(['log', '-1', branch]);
                        String lastCommit =
                            resultLastCommit.stdout.trim().split('\n').first;
                        ProcessResult resultTotalCommits = await gitDir
                            .runCommand(['rev-list', '--count', branch]);
                        String totalCommits = resultTotalCommits.stdout.trim();

                        return Branch(
                          name: branch,
                          lastCommit: lastCommit,
                          totalCommits: int.parse(totalCommits),
                        );
                      }).toList();

                      Future.wait(br).then((completedBr) {
                        ref.watch(branchesProvider.notifier).state =
                            completedBr;
                      });
                    }
                  }
                } catch (e) {
                  // showDialog(
                  //     context: context,
                  //     builder: (builder) =>
                  //         showMessageDialog('Error', e.toString()));
                }
              },
            ),
            Text('Nombre del autor: $authorName'),
            const Text('Commits:'),
            Expanded(
              child: ListView.builder(
                itemCount: commits.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(commits[index].toString()),
                  );
                },
              ),
            ),
            const Text('Ramas:'),
            Expanded(
              child: ListView.builder(
                itemCount: branches.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(branches[index].toString()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
