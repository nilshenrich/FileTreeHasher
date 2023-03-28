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
            title: Row(children: [
      // Row: File tree
      DecoratedBox(
          decoration: const BoxDecoration(color: Colors.red),
          child: Row(children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.drive_folder_upload),
              tooltip: "Load file tree",
            )
          ])),
      // Row: Hash algorithm
      DecoratedBox(
          decoration: const BoxDecoration(color: Colors.yellow),
          child: Row(children: const [Text("<Hash alg>")])),
      // Row: Comparison
      DecoratedBox(
          decoration: const BoxDecoration(color: Colors.green),
          child: Row(children: const [Text("<comparison>")]))
    ])));
  }
}
