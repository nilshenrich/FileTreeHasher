import 'package:flutter/material.dart';
import 'package:file_tree_hasher/templates/ControlHeader.dart';

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
            toolbarHeight: 73, // TODO: Set auto height
            flexibleSpace: Row(children: <Widget>[
              // -------------------- Row: File tree --------------------
              T_HeaderControlSection(headingText: "File tree control", items: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.drive_folder_upload),
                  tooltip: "Load file tree",
                )
              ]),
              // -------------------- Row: Hash algorithm --------------------
              const T_HeaderControlSection(headingText: "Algorithm selection"),
              // -------------------- Row: Comparison --------------------
              const T_HeaderControlSection(headingText: "Comparison")
            ])));
  }
}
