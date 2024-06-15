import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(brightness: Brightness.dark),
      home: Scaffold(
        body: Center(
          child: ElevatedButton(
            child: Text('Abrir explorador de archivos'),
            onPressed: () async {
              try {
                String? directoryPath =
                    await FilePicker.platform.getDirectoryPath();

                if (directoryPath != null) {
                  print('Carpeta seleccionada: $directoryPath');
                } else {
                  // El usuario canceló la selección
                }
              } catch (e) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Error'),
                      content: Text(
                          'No se encontró zenity. Por favor, instálalo usando tu gestor de paquetes.'),
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
            },
          ),
        ),
      ),
    );
  }
}
