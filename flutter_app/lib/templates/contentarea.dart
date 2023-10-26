// ####################################################################################################
// # @file contentarea.dart
// # @author Nils Henrich
// # @brief Big content clusters like header bar or body
// # @version 1.0.1+4
// # @date 2023-03-30
// #
// # @copyright Copyright (c) 2023
// #
// ####################################################################################################

// ignore_for_file: camel_case_types, non_constant_identifier_names, library_private_types_in_public_api

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:file_tree_hasher/definies/datatypes.dart';
import 'package:file_tree_hasher/definies/defaults.dart';
import 'package:file_tree_hasher/definies/styles.dart';
import 'package:file_tree_hasher/functions/hashfile.dart';
import 'package:file_tree_hasher/templates/contentdivider.dart';
import 'package:file_tree_hasher/functions/general.dart';
import 'package:flutter/material.dart';
import 'package:file_tree_hasher/templates/hashselector.dart';
import 'package:file_tree_hasher/templates/headercontroller.dart';
import 'package:file_tree_hasher/templates/filetree.dart';
import 'package:path/path.dart' as libpath;

// ##################################################
// # Body content
// ##################################################
GlobalKey<T_BodyContent_state> BodyContent = GlobalKey<T_BodyContent_state>();

// ##################################################
// # CONTENT
// # Header bar containing general control elements
// ##################################################
class T_HeaderBar extends StatelessWidget implements PreferredSizeWidget {
  const T_HeaderBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
        flexibleSpace: Column(children: [
      const SizedBox(height: 10),
      Row(children: <Widget>[
        // -------------------- Section: File tree --------------------
        T_HeaderControlSection(headingText: "File tree control", items: [
          // ---------- Button: load file tree ----------
          IconButton(onPressed: BodyContent.currentState!.selectNewFolder, icon: const Icon(Icons.drive_folder_upload), tooltip: "Load file tree"),
          // ---------- Button: Load single file ----------
          // ---------- Button: clear all ----------
          IconButton(
              onPressed: BodyContent.currentState!.clearContent,
              icon: const Icon(Icons.delete_forever_outlined),
              tooltip: "Clear all loaded files and file trees")
        ]),
        // -------------------- Section: Hash algorithm --------------------
        T_HeaderControlSection(headingText: "Algorithm selection", items: [
          T_GlobalHashSelector(onChanged: (selected) {
            SelectedGlobalHashAlg = selected;
          })
        ]),
        // -------------------- Section: Comparison --------------------
      ])
    ]));
  }

  @override
  Size get preferredSize => const Size.fromHeight(100);
}

// ##################################################
// # CONTENT
// # Body containing loaded files and comparisons
// ##################################################
class T_BodyContent extends StatefulWidget {
  const T_BodyContent({super.key});

  @override
  State<StatefulWidget> createState() => T_BodyContent_state();
}

// ##################################################
// # STATE
// # Body containing loaded files and comparisons
// ##################################################
class T_BodyContent_state extends State<T_BodyContent> {
  // Currently loaded file trees
  final List<Text> _loadedTrees = [];

  @override
  Widget build(BuildContext context) {
    return Column(children: [ContentDivider_folders(visible: _loadedTrees.isNotEmpty), Column(children: _loadedTrees)]);
  }

  // ##################################################
  // @brief: Let user select a folder to show file tree of.
  //         The new tree view is added to the view under new expandable
  // ##################################################
  void selectNewFolder() async {
    // -------------------- Select folder from system --------------------
    // TODO: Multiple folders could be selected (Button description to be adapted). Think that is not possible for folders
    String filetreePath = "/home/nils/Dokumente/testfiles"; // DEV: Use predefined path for debugging

    // -------------------- Show selected folder as tree view --------------------
    // _showNewFolder(filetreePath);
    Text newTree = Text("This should be added");
    setState(() {
      _loadedTrees.add(newTree);
    });
    // sleep(Duration(seconds: 4));
    await Future.delayed(Duration.zero);
    // _loadFolder(Directory(path), newTree.items);
    _loadedTrees.add(Text("!! This should not appear !!"));
  }

  // ##################################################
  // @brief: Remove all loaded file trees and files
  // ##################################################
  void clearContent() {
    setState(() {
      // Remove all loaded trees and files
      _loadedTrees.clear();
    });
  }

  // ##################################################
  // @brief: Show file tree from a given path
  // @param: path
  // ##################################################
  void _showNewFolder(String path) {
    Text newTree = Text("This should be added");
    setState(() {
      _loadedTrees.add(newTree);
    });
    sleep(Duration(seconds: 4));
    // _loadFolder(Directory(path), newTree.items);
    _loadedTrees.add(Text("!! This should not appear !!"));
  }

  // ##################################################
  // @brief: Load folders and files and add to given list
  // @param: rootFolder
  // @return list of items
  // ##################################################
  void _loadFolder(Directory rootFolder, List<T_FileTreeItem> itemsList) {
    List<FileSystemEntity> items = rootFolder.listSync();

    // Loop over all files and subdirectories
    for (FileSystemEntity item in items) {
      // sleep(Duration(milliseconds: 500));
      // For subfolders
      // if (item is Directory) {
      //   // Load all sub items of this subfolder and add to list
      //   T_FolderView subfolder = T_FolderView(path: item.path, name: GetFileName(item.path), subitems: _loadFolder(item));
      //   itemsList.add(subfolder);
      // }

      // For files
      if (item is File) {
        // Add file element to list
        T_FileView file = T_FileView(path: item.path, name: GetFileName(item.path));
        itemsList.add(file);
      }
    }
  }
}

// ##################################################
// # TEMPLATE
// # Storage chooser row for hash file creation
// ##################################################
class T_StorageChooserRow extends StatelessWidget {
  // Attributes
  final String title;
  final T_FileTreeView? fileTreeView; // null means single files
  final TextEditingController _textEditingController = TextEditingController();

  // Constructor
  T_StorageChooserRow({super.key, required this.title, this.fileTreeView});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(title),
      const SizedBox(width: 10),
      Expanded(
          child: SizedBox(
        // height: 24,
        child: TextField(
            controller: _textEditingController,
            decoration: InputDecoration(
                hintText: "Select hash file path",
                suffixIcon: IconButton(
                  onPressed: () async {
                    String? path = await selectStoragePath();
                    if (path != null) _textEditingController.text = path;
                  },
                  icon: const Icon(Icons.more_horiz),
                ))),
      ))
    ]);
  }

  // ##################################################
  // @brief: Open user dialog to select a path to stora a file
  // @return: Future<String?>
  // ##################################################
  Future<String?> selectStoragePath() async {
    String? hashfile = await FilePicker.platform.saveFile(
        dialogTitle: "Choose a file to store hashes to", initialDirectory: GetHomeDir().path, lockParentWindow: true, allowedExtensions: ["hash"]);
    if (hashfile != null) {
      if (hashfile.endsWith(".hash")) {
        return hashfile;
      }
      return "$hashfile.hash";
    }
    return null;
  }

  // ##################################################
  // @brief: Get chosen file storage path
  // @return: String
  // ##################################################
  String getStoragePath() {
    return _textEditingController.text;
  }
}
