// ####################################################################################################
// # @file contentarea.dart
// # @author Nils Henrich
// # @brief Big content clusters like header bar or body
// # @version 0.0.0+1
// # @date 2023-03-30
// #
// # @copyright Copyright (c) 2023
// #
// ####################################################################################################

import 'package:flutter/material.dart';
import 'package:file_tree_hasher/templates/headercontroller.dart';
import 'package:flutter_treeview/flutter_treeview.dart';

// ##################################################
// # CONTENT
// # Header bar containing general control elements
// ##################################################
class T_HeaderBar extends StatelessWidget implements PreferredSizeWidget {
  const T_HeaderBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
        flexibleSpace: Row(children: <Widget>[
      // -------------------- Section: File tree --------------------
      T_HeaderControlSection(headingText: "File tree control", items: [
        // ---------- Button: load file tree ----------
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.drive_folder_upload),
          tooltip: "Load file tree",
        ),
        // ---------- Button: Load single file ----------
        IconButton(
            onPressed: () {},
            icon: const Icon(Icons.upload_file),
            tooltip: "Load single file"),
        // ---------- Button: clear all ----------
        IconButton(
            onPressed: () {},
            icon: const Icon(Icons.delete_forever_outlined),
            tooltip: "Clear all loaded files")
      ]),
      // -------------------- Section: Hash algorithm --------------------
      const T_HeaderControlSection(
          headingText: "Algorithm selection", items: [GlobalHashSelector()]),
      // -------------------- Section: Comparison --------------------
      T_HeaderControlSection(headingText: "Comparison", items: [
        IconButton(
            onPressed: () {},
            icon: const Icon(Icons.upload_outlined),
            tooltip: "Load checksum file"),
        IconButton(
            onPressed: () {},
            icon: const Icon(Icons.download_outlined),
            tooltip: "Safe checksum file"),
        IconButton(
            onPressed: () {},
            icon: const Icon(Icons.delete_forever_outlined),
            tooltip: "Clear comparison strings")
      ])
    ]));
  }

  @override
  Size get preferredSize => const Size.fromHeight(89); // TODO: Set auto height
}

// ##################################################
// # CONTENT
// # Body containing loaded files and comparisons
// ##################################################
// TODO: Fill content
class T_BodyContent extends StatefulWidget {
  const T_BodyContent({super.key});

  @override
  State<StatefulWidget> createState() => _T_BodyContent();
}

// Body state
class _T_BodyContent extends State<T_BodyContent> {
// Tree view controller
  final TreeViewController _controller =
      TreeViewController(children: _exampleFileTree);

  @override
  Widget build(BuildContext context) {
    return TreeView(controller: _controller);
  }
}

// DEV: Example file tree
const List<Node> _exampleFileTree = [
  Node(key: "f1", label: "Folder", expanded: true, children: [
    Node(
      key: "f2",
      label: "Inner file",
    )
  ])
];
