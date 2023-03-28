import 'package:flutter/material.dart';

void main() {
  runApp(const FileTreeHasher());
}

class FileTreeHasher extends StatelessWidget {
  const FileTreeHasher({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Hello World!'),
        ),
      ),
    );
  }
}
