import 'package:flutter/material.dart';
import 'package:file_tree_hasher/templates/header_controller.dart';
import 'package:file_tree_hasher/definies/defines_global.dart';

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
              const T_HeaderControlSection(
                  headingText: "Algorithm selection",
                  items: [GlobalHashSelector()]),
              // -------------------- Row: Comparison --------------------
              const T_HeaderControlSection(headingText: "Comparison")
            ])));
  }
}

class GlobalHashSelector extends StatefulWidget {
  const GlobalHashSelector({super.key});

  @override
  State<StatefulWidget> createState() => _GlobalHashSelector();
}

class _GlobalHashSelector extends State<GlobalHashSelector> {
  // Currently selected hash algorithm
  String? _selected = E_HashAlgorithms.MD5.value;

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
        value: _selected,
        items: getHashAlgorithmNames()
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (selected) {
          setState(() {
            _selected = selected;
          });
        });
  }
}
