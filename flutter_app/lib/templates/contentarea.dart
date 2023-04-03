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

// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';
import 'package:file_tree_hasher/templates/hashselector.dart';
import 'package:file_tree_hasher/templates/headercontroller.dart';
import 'package:file_tree_hasher/templates/filetree.dart';

// ##################################################
// # Global hash selector
// ##################################################
T_GlobalHashSelector GlobalHashSelector = const T_GlobalHashSelector();

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
      T_HeaderControlSection(
          headingText: "Algorithm selection", items: [GlobalHashSelector]),
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
class T_BodyContent extends StatelessWidget {
  const T_BodyContent({super.key});

  @override
  Widget build(BuildContext context) {
    return _exampleFileTree;
  }
}

// DEV: Example file tree
T_FileTreeView _exampleFileTree = const T_FileTreeView(
  items: [
    T_FolderView(path: "/root/folder", name: "top-folder", subitems: [
      T_FolderView(path: "/root/folder/folder", name: "sub-folder", subitems: [
        T_FolderView(
            path: "/root/folder/folder/folder", name: "sub-sub-folder"),
        T_FileView(path: "/root/folder/folder/file", name: "sub-sub-file")
      ]),
      T_FolderView(
          path: "/root/folder/folder-long", name: "sub-folder-with-long-name"),
      T_FileView(path: "/root/folder/file", name: "sub-file"),
      T_FileView(
          path: "/root/folder/file-long", name: "sub-file-with-long-name")
    ]),
    T_FolderView(path: "/root/folder-long", name: "folder-with-long-name"),
    T_FileView(path: "/root/file", name: "top-file")
  ],
);
