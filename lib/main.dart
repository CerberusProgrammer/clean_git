import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:git/git.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: Locale('en', 'US'), // Define el locale
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      theme: ThemeData(brightness: Brightness.dark),
      home: MyApp(),
    );
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String authorName = '';
  List<String> commits = [];
  List<String> branches = [];

  void showMessageDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
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
              child: Text('Abrir explorador de archivos'),
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
                      if (gitDir != null) {
                        showMessageDialog(context, 'Información',
                            'El repositorio Git en $directoryPath es válido.');
                        // Aquí puedes ejecutar comandos de Git, como obtener el nombre del autor
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
                          commits = resultCommits.stdout.trim().split('\n');
                        });
                        // Obtener las ramas
                        ProcessResult resultBranches =
                            await gitDir.runCommand(['branch', '-a']);
                        setState(() {
                          branches = resultBranches.stdout.trim().split('\n');
                        });
                      } else {
                        showMessageDialog(context, 'Error',
                            'El repositorio Git en $directoryPath no es válido.');
                      }
                    } else {
                      showMessageDialog(context, 'Error',
                          'La carpeta .git no fue encontrada en $directoryPath');
                    }
                  } else {
                    // El usuario canceló la selección
                  }
                } catch (e) {
                  showMessageDialog(context, 'Error',
                      'No se encontró zenity. Por favor, instálalo usando tu gestor de paquetes.');
                }
              },
            ),
            Text('Nombre del autor: $authorName'),
            Text('Commits:'),
            Expanded(
              child: ListView.builder(
                itemCount: commits.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(commits[index]),
                  );
                },
              ),
            ),
            Text('Ramas:'),
            Expanded(
              child: ListView.builder(
                itemCount: branches.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(branches[index]),
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
