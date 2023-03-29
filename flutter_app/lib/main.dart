// ####################################################################################################
// # @file main.dart
// # @author Nils Henrich
// # @brief App entry point
// # @version 0.0.0+1
// # @date 2023-03-19
// #
// # @copyright Copyright (c) 2023
// #
// ####################################################################################################

import 'package:flutter/material.dart';
import 'package:file_tree_hasher/templates/headercontroller.dart';

void main() {
  runApp(const FileTreeHasher());
}

// ##################################################
// # Actual entry point to app
// ##################################################
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

// ##################################################
// # App bar
// # A header bar with global controls:
// #  1. Load/clear file tree
// #  2. Select global hash algorithm
// #  3. Compare generated hashes, create/load checksum file
// ##################################################
class ControlHeader extends StatelessWidget {
  const ControlHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            toolbarHeight: 89, // TODO: Set auto height
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
