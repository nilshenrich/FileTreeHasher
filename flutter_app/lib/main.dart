import 'package:flutter/material.dart';

void main() {
  runApp(const FileTreeHasher());
}

class FileTreeHasher extends StatelessWidget {
  const FileTreeHasher({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'File Tree Hasher',
      home: ControlHeader(),
    );
  }
}

class ControlHeader extends StatelessWidget {
  const ControlHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("General controls"),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.input),
            alignment: Alignment.centerLeft,
            onPressed: () {},
          )
        ],
      ),
    );
  }
}
