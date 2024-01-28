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

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_tree_hasher/definies/datatypes.dart';
import 'package:file_tree_hasher/definies/defaults.dart';
import 'package:file_tree_hasher/definies/info.dart';
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
// # Hash input update trigger object
// # Items are identified by path. Null means all items are included
// # Can update comparison input and selected hash algorithm. Null means not to be updated
// ##################################################
class HashInputUpdater {
  String? itempath; // Itentifies item by path. Null means all items
  String? compInput; // Hash comparison input to be set. Null means don't update
  String? hashAlg; // Hash algorithm to be selected. Null means don't update
  HashInputUpdater({required this.itempath, this.compInput, this.hashAlg});
}

// ##################################################
// # Global stream controllers every widget can listen to
// ##################################################
StreamController<C_HashAlg> Controller_SelectedGlobalHashAlg = StreamController.broadcast(); // Globally selected hash algorithm
StreamController<HashInputUpdater> Controller_ComparisonInput = StreamController.broadcast(); // Comparison input to be updated

// ##################################################
// # CONTENT
// # Header bar containing general control elements
// ##################################################
class T_HeaderBar extends StatelessWidget implements PreferredSizeWidget {
  // Constructor
  T_HeaderBar({super.key});

  @override
  Widget build(BuildContext context) {
    Controller_SelectedGlobalHashAlg.stream.listen((selected) {
      SelectedGlobalHashAlg = selected.value;
    });
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
            Controller_SelectedGlobalHashAlg.add(C_HashAlg(selected));
          })
        ]),
        // -------------------- Section: Comparison --------------------
        T_HeaderControlSection(headingText: "Comparison", items: [
          IconButton(onPressed: BodyContent.currentState!.loadHashfile, icon: const Icon(Icons.upload_outlined), tooltip: "Load checksum file(s)"),
          IconButton(onPressed: BodyContent.currentState!.safeHashFile, icon: const Icon(Icons.download_outlined), tooltip: "Safe checksum file(s)"),
          IconButton(
              onPressed: () => Controller_ComparisonInput.add(HashInputUpdater(itempath: null, compInput: "")),
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
  List<S_FileTree_StreamControlled_Item> loadedTrees = List.empty(growable: true);
  List<S_FileTree_StreamControlled_Item> loadedFiles = List.empty(growable: true);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      ContentDivider_folders(visible: loadedTrees.isNotEmpty),
      Column(children: loadedTrees.map((c) => c.item).toList()),
      ContentDivider_files(visible: loadedFiles.isNotEmpty),
      Row(children: [
        Flexible(child: Column(children: loadedFiles.map((c) => c.item).toList())),
        const SizedBox(width: Style_FileTree_Item_ElementSpaces_px)
      ])
    ]);
  }

  // ##################################################
  // @brief: Let user select a folder to show file tree of.
  //         The new tree view is added to the view under new expandable
  // ##################################################
  void selectNewFolder() async {
    // -------------------- Select folder from system --------------------
    // TODO: Multiple folders could be selected (Button description to be adapted). Think that is not possible for folders
    String? filetreePath = await FilePicker.platform.getDirectoryPath(initialDirectory: GetHomeDir().path);
    if (filetreePath == null) {
      return;
    }

    // -------------------- Show selected folder as tree view --------------------
    StreamController<C_HashFile_SavePath> controller_HashFile_SavePath = StreamController();
    setState(() {
      loadedTrees.add(S_FileTree_StreamControlled_Item(
          item: I_FileTree_Head(
              path: filetreePath!,
              stream_hashAlg: Controller_SelectedGlobalHashAlg.stream,
              stream_hashFile_savePath: controller_HashFile_SavePath.stream),
          controllers: [Controller_SelectedGlobalHashAlg, controller_HashFile_SavePath]));
    });
  }

  // ##################################################
  // @brief: Let user select single files to show
  //         The new files are added to the view on its own
  // ##################################################
  void selectNewFiles() async {
    // -------------------- Select files from system --------------------
    FilePickerResult? picked = await FilePicker.platform.pickFiles(initialDirectory: GetHomeDir().path, allowMultiple: true);
    if (picked == null) {
      return;
    }

    // -------------------- Show selected files in body --------------------
    List<S_FileTree_StreamControlled_Item> l_loadedFiles = loadedFiles;
    for (PlatformFile sysFile in picked.files) {
      String? path = sysFile.path;
      if (path == null) continue;
      StreamController<C_HashFile_SavePath> controller_HashFile_SavePath = StreamController();
      I_FileTree_File file = I_FileTree_File(
          path: path,
          stream_hashAlg: Controller_SelectedGlobalHashAlg.stream,
          stream_hashFile_savePath: controller_HashFile_SavePath.stream,
          showFullPath: true);
      l_loadedFiles.add(S_FileTree_StreamControlled_Item(item: file, controllers: [Controller_SelectedGlobalHashAlg, controller_HashFile_SavePath]));
    }
    setState(() {
      loadedFiles = l_loadedFiles;
    });
  }

  // ##################################################
  // @brief: Remove all loaded file trees and files
  // ##################################################
  void clearContent() {
    // Remove all loaded trees and files
    setState(() {
      loadedTrees.clear();
      loadedFiles.clear();
    });
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
    // Get all file trees and single files into widgets
    List<Widget> dialogRows = [];
    for (S_FileTree_StreamControlled_Item view in loadedTrees) {
      dialogRows.add(T_StorageChooserRow(title: view.item.path, fileTreeView: view));
    }
    if (loadedFiles.isNotEmpty) {
      dialogRows.add(T_StorageChooserRow(title: HashfileSingletext));
    }
    if (dialogRows.isEmpty) {
      showDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return AlertDialog(title: const Text("Nothing to be saved"), actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("OK"))
            ]);
          });
      return;
    }

    // Add exit buttons at the end
    dialogRows.add(Row(children: [
      const Expanded(child: SizedBox.shrink()),
      IconButton(
          onPressed: () {
            for (Widget row in dialogRows) {
              if (row is! T_StorageChooserRow) continue;
              String hashFilePath = row.getStoragePath();
              File hashFileSocket = File(hashFilePath);
              hashFileSocket.writeAsStringSync("${HashFileHeader}\n\n");
              if (row.fileTreeView == null) {
                hashFileSocket.writeAsStringSync("${HashfileSingletext}\n", mode: FileMode.append);
                for (S_FileTree_StreamControlled_Item file in loadedFiles) {
                  file.send(C_HashFile_SavePath(hashFileSocket));
                }
              } else {
                hashFileSocket.writeAsStringSync("${GetParentPath(hashFilePath)}\n", mode: FileMode.append);
                S_FileTree_StreamControlled_Item view = row.fileTreeView!;
                view.send(C_HashFile_SavePath(hashFileSocket, row.fileTreeView!.item.path));
              }
            }
            Navigator.pop(context);
          },
          icon: const Icon(Icons.check)), // Exit with saving
      IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)) // Exit without saving
    ]));

    // Show dialog
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            title: const Text("Choose storage locations for hash files"),
            children: [Column(children: dialogRows)],
          );
        });
  }

  // ##################################################
  // @brief: Load hash file from system and set comparison texts and hash algorithms accordingly
  // ##################################################
  void loadHashfile() async {
    // -------------------- Pick hash files to load --------------------
    FilePickerResult? filePaths = await FilePicker.platform
        .pickFiles(initialDirectory: GetHomeDir().path, allowMultiple: true, type: FileType.custom, allowedExtensions: ['hash']);
    if (filePaths == null) {
      return;
    }

    // -------------------- Update file views --------------------
    List<String?> paths = filePaths.paths;
    for (String? path in paths) {
      // Load and parse hash file
      if (path == null) {
        continue;
      }

      // Read file line by line
      // Ignore all lines before the mpty line, they are part of the file header
      bool isRealData = false;
      String? rootPath;
      File(path).openRead().transform(utf8.decoder).transform(LineSplitter()).forEach((line) {
        // Search for empty line to identify usable data
        if (line.isEmpty) {
          isRealData = true;
          return;
        }
        if (!isRealData) return;

        // First line of usable data is the tree view root path or the marker for single files
        if (rootPath == null) {
          rootPath = line;
          return;
        }

        // Get 3 CSV columns from line
        List<List<String>> csvrow_list = const CsvToListConverter()
            .convert(line, fieldDelimiter: ",", textDelimiter: '"', textEndDelimiter: '"', eol: LineendingChar, shouldParseNumbers: false);
        if (csvrow_list.isEmpty) return;
        List csvrow = csvrow_list[0];
        if (csvrow.length != 3) return;
        String hashstring = csvrow[0];
        String hashalg = csvrow[1];
        String filepath = csvrow[2];

        // Trigger input update
        // TODO: Update selected hash algorithm as well
        Controller_ComparisonInput.add(HashInputUpdater(itempath: "${rootPath}/${filepath}", compInput: hashstring, hashAlg: hashalg));
      });
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
  final S_FileTree_StreamControlled_Item? fileTreeView; // null means single files
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
