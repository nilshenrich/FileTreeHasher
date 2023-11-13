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
import 'package:provider/provider.dart';

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
          IconButton(onPressed: BodyContent.currentState!.selectNewFiles, icon: const Icon(Icons.upload_file), tooltip: "Load single file(s)"),
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
            BodyContent.currentState!.updateHashAlg(selected);
          })
        ]),
        // -------------------- Section: Comparison --------------------
        T_HeaderControlSection(headingText: "Comparison", items: [
          IconButton(onPressed: BodyContent.currentState!.loadHashfile, icon: const Icon(Icons.upload_outlined), tooltip: "Load checksum file(s)"),
          IconButton(onPressed: BodyContent.currentState!.safeHashFile, icon: const Icon(Icons.download_outlined), tooltip: "Safe checksum file(s)"),
          IconButton(
              onPressed: BodyContent.currentState!.clearComparisonInputs,
              icon: const Icon(Icons.delete_forever_outlined),
              tooltip: "Clear comparison strings")
        ])
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
  // TODO: Restore code

  @override
  Widget build(BuildContext context) {
    return Column(
        children:
            // DEV: Show folder
            context.watch<P_FileTree>().loadedTrees

        // TODO: Restore code
        );
  }

  // ##################################################
  // @brief: Let user select a folder to show file tree of.
  //         The new tree view is added to the view under new expandable
  // ##################################################
  void selectNewFolder() async {
    // -------------------- Select folder from system --------------------
    // TODO: Multiple folders could be selected (Button description to be adapted). Think that is not possible for folders
    String? filetreePath = await FilePicker.platform.getDirectoryPath(initialDirectory: GetHomeDir().path);
    filetreePath = "/home/nils/Dokumente/testfiles"; // DEV: Use predefined path for debugging
    if (filetreePath == null) {
      return;
    }

    // -------------------- Show selected folder as tree view --------------------
    // DEV: Set folder name
    context.read<P_FileTree>().loadFileTree(filetreePath);

    // TODO: Restore code
  }

  // ##################################################
  // @brief: Let user select single files to show
  //         The new files are added to the view on its own
  // ##################################################
  void selectNewFiles() async {
    // -------------------- Select files from system --------------------
    FilePickerResult? filePaths = await FilePicker.platform.pickFiles(initialDirectory: GetHomeDir().path, allowMultiple: true);
    if (filePaths == null) {
      return;
    }

    // -------------------- Show selected files in body --------------------
    List<String?> paths = filePaths.paths;
    for (String? path in paths) {
      setState(() {
        // TODO: Restore code
      });
    }
  }

  // ##################################################
  // @brief: Remove all loaded file trees and files
  // ##################################################
  void clearContent() {
    setState(() {
      // Remove all loaded trees and files
      // TODO: Restore code
    });
  }

  // ##################################################
  // @brief: Update all hash algorithms recursively
  // @param: selected
  // ##################################################
  void updateHashAlg(String? selected) {
    // TODO: Restore code
  }

  // ##################################################
  // @brief: Create hash files from generated hashes
  //         Hash file clusters:
  //            - Each file tree gets its own hash file
  //            - The single file section also gets its own hash file for all single files
  //         Hash file storage location:
  //            - Before the file is created, a popup opens where the user can select the storage location for each of the planned hash files
  //              It is build like a table where the user can see the loaded trees and single files and belonging storage paths that can be changed via file selectors (file can be added or replaced)
  //            - Default locations:
  //                - For file trees the hash files default location is directly inside the loaded folder
  //                - For single file section the hash files default location is the users home directory
  // ##################################################
  // TODO: What if hash generation is ongoing?
  void safeHashFile() {
    // TODO: Restore code
  }

  // ##################################################
  // @brief: Load hash file from system and set comparison texts and hash algorithms accordingly
  // ##################################################
  void loadHashfile() async {
    // TODO: Restore code
  }

  // ##################################################
  // @brief: Clear all inputs for comparison hash
  // ##################################################
  void clearComparisonInputs() {
    // TODO: Restore code
  }

  // ##################################################
  // @brief: Clear all inputs for comparison hash for folder sub-items
  // @param: folder
  // ##################################################
  // TODO: Restore code

  // ##################################################
  // @brief: Get file view element (if existing) that matches a folder path
  // @param: viewitems
  // @param: folders
  // @param: file
  // @return: T_FileView?
  // ##################################################
  // TODO: Restore code
}

// ##################################################
// # TEMPLATE
// # Storage chooser row for hash file creation
// ##################################################
class T_StorageChooserRow extends StatelessWidget {
  // Attributes
  final String title;
  // TODO: Restore code // null means single files
  final TextEditingController _textEditingController = TextEditingController();

  // Constructor
  T_StorageChooserRow({super.key, required this.title});

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
