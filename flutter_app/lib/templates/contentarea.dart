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

// ignore_for_file: camel_case_types, non_constant_identifier_names, library_private_types_in_public_api

import 'dart:io';

import 'package:file_tree_hasher/functions/general.dart';
import 'package:flutter/material.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
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
  const T_HeaderBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
        flexibleSpace: Row(children: <Widget>[
      // -------------------- Section: File tree --------------------
      T_HeaderControlSection(headingText: "File tree control", items: [
        // ---------- Button: load file tree ----------
        IconButton(
          onPressed: BodyContent.currentState?.loadNew,
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
class T_BodyContent extends StatefulWidget {
  const T_BodyContent({super.key});

  @override
  State<StatefulWidget> createState() => _T_BodyContent();
}

// ##################################################
// # STATE
// # Body containing loaded files and comparisons
// ##################################################
class _T_BodyContent extends State<T_BodyContent> {
  // Currently loaded file trees
  final List<T_FileTreeView> _loadedTrees = [];

  @override
  Widget build(BuildContext context) {
    return Column(children: _loadedTrees);
  }

  void loadNew() async {
    String? filetreePath = await FilesystemPicker.openDialog(
        title: "Select folder",
        context: context,
        rootDirectory: getHomeDir(),
        fsType: FilesystemType.folder,
        pickText: "Select folder to load file tree from");
    setState(() {
      _loadedTrees.add(_exampleFileTree);
    });
  }
}

GlobalKey<_T_BodyContent> BodyContent = GlobalKey<_T_BodyContent>();

// DEV: Example file tree
T_FileTreeView _exampleFileTree = const T_FileTreeView(
  title: "<First loaded file tree>",
  items: [
    T_FolderView(path: "/root/folder", name: "top-folder", subitems: [
      T_FolderView(path: "/root/folder/folder", name: "sub-folder", subitems: [
        T_FolderView(
            path: "/root/folder/folder/folder", name: "sub-sub-folder"),
        T_FileView(
          path: "/root/folder/folder/file",
          name: "sub-sub-file",
          hashGen: "abcd5ff",
          hashComp: "abcd5ff",
        )
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
