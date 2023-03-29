import 'package:flutter/material.dart';
import 'package:file_tree_hasher/templates/header_controller.dart';

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
                // ---------- Button: load file tree ----------
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.drive_folder_upload),
                  tooltip: "Load file tree",
                ),
                // ---------- Button: clear file tree ----------
                IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.delete_forever_outlined),
                    tooltip: "Clear loaded file tree")
              ]),
              // -------------------- Row: Hash algorithm --------------------
              const T_HeaderControlSection(headingText: "Algorithm selection"),
              // -------------------- Row: Comparison --------------------
              const T_HeaderControlSection(headingText: "Comparison")
            ])));
  }
}
