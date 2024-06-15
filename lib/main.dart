import 'package:clean_git/models/branch.dart';
import 'package:clean_git/models/commit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:git/git.dart';

void main() {
  runApp(const MainApp());
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
      home: const MyApp(),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String authorName = '';
  List<CustomCommit> commits = [];
  List<Branch> branches = [];

  Widget showMessageDialog(String title, String message) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          child: const Text('Cerrar'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
                      setState(() {
                        authorName = result.stdout.trim();
                      });

                      ProcessResult resultCommits = await gitDir.runCommand([
                        'log',
                        '--all',
                        '--decorate',
                        '--oneline',
                        '--pretty=format:%H %s (%an, %d)'
                      ]);
                      setState(() {
                        List<String> rawCommits =
                            resultCommits.stdout.trim().split('\n');
                        commits = rawCommits
                            .map(
                              (commit) => CustomCommit(
                                sha: commit.split(' ')[0],
                                message: commit.split(' ')[1],
                                author: commit.split(' ')[2],
                                branch: commit.split(' ')[3],
                              ),
                            )
                            .toList();
                      });

                      ProcessResult resultBranches =
                          await gitDir.runCommand(['branch', '-a']);

                      setState(() {
                        List<String> rawBranches =
                            resultBranches.stdout.trim().split('\n');

                        var br = rawBranches.map((branch) async {
                          branch = branch.trim().replaceFirst('*', '').trim();

                          ProcessResult resultLastCommit =
                              await gitDir.runCommand(['log', '-1', branch]);
                          String lastCommit =
                              resultLastCommit.stdout.trim().split('\n').first;
                          ProcessResult resultTotalCommits = await gitDir
                              .runCommand(['rev-list', '--count', branch]);
                          String totalCommits =
                              resultTotalCommits.stdout.trim();

                          return Branch(
                            name: branch,
                            lastCommit: lastCommit,
                            totalCommits: int.parse(totalCommits),
                          );
                        }).toList();

                        Future.wait(br).then((completedBr) {
                          setState(() {
                            branches = completedBr;
                          });
                        });
                      });
                    }
                  }
                } catch (e) {
                  showDialog(
                      context: context,
                      builder: (builder) =>
                          showMessageDialog('Error', e.toString()));
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
