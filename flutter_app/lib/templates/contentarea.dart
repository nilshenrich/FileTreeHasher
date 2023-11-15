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
  List<T_FileTree> _loadedTrees = [];
  final List<T_FileItem> _loadedFiles = [];

  @override
  Widget build(BuildContext context) {
    _loadedTrees = context.watch<P_FileTrees>().loadedTrees;
    return Column(children: [
      ContentDivider_folders(visible: _loadedTrees.isNotEmpty),
      Column(children: _loadedTrees),
      ContentDivider_files(visible: _loadedFiles.isNotEmpty),
      Row(children: [Flexible(child: Column(children: _loadedFiles)), const SizedBox(width: Style_FileTree_Item_ElementSpaces_px)])
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
    filetreePath = "/home/nils/Dokumente/testfiles"; // DEV: Use predefined path for debugging
    if (filetreePath == null) {
      return;
    }

    // -------------------- Show selected folder as tree view --------------------
    context.read<P_FileTrees>().loadFileTree(filetreePath);
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
        _loadedFiles.add(T_FileItem(path: path!, showFullPath: true));
      });
    }
  }

  // ##################################################
  // @brief: Remove all loaded file trees and files
  // ##################################################
  void clearContent() {
    // Remove all loaded trees and files
    context.read<P_FileTrees>().clear();
    setState(() {
      _loadedFiles.clear();
    });
  }

  // ##################################################
  // @brief: Update all hash algorithms recursively
  // @param: selected
  // ##################################################
  void updateHashAlg(String? selected) {
    for (T_FileTree view in _loadedTrees) {
      for (T_TreeItem item in view.children) {
        item.globKey_HashAlgorithm.currentState!.set(selected);
      }
    }
    for (T_FileItem item in _loadedFiles) {
      item.globKey_HashAlgorithm.currentState!.set(selected);
    }
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
    for (T_FileTree view in _loadedTrees) {
      dialogRows.add(T_StorageChooserRow(title: view.path, fileTreeView: view));
    }
    if (_loadedFiles.isNotEmpty) {
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
              String storagepath = row.getStoragePath();
              if (row.fileTreeView == null) {
                GenerateHashfile(SingleFiles_to_FileViewHashes(_loadedFiles, HashfileSingletext), storagepath);
              } else {
                T_FileTree view = row.fileTreeView!;
                GenerateHashfile(FileTreeItems_to_FileViewHashes(view.children, view.path, view.path), storagepath);
              }
            }
            Navigator.pop(context);
          },
          icon: const Icon(Icons.check)),
      IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close))
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
      C_FileViewHashes? parsedHashfile = LoadHashfile(path);
      if (parsedHashfile == null) {
        continue;
      }
      String viewpath = parsedHashfile.name;
      List<C_FileHashPair> hashlist = parsedHashfile.files;

      // ---------- Update single files ----------
      if (viewpath == HashfileSingletext) {
        // For all hash string pairs:
        // Just find if a single file exists with matching path
        for (C_FileHashPair hashPair in hashlist) {
          for (T_FileItem singlefile in _loadedFiles) {
            if (singlefile.path == hashPair.file) {
              singlefile.globKey_HashAlgorithm.currentState!.set(hashPair.algorithm);
              singlefile.globKey_HashComparisonView.currentState!.set(hashPair.hash ?? "");
            }
          }
        }
      }

      // ---------- Update tree views ----------
      else {
        // Find matching file tree view
        T_FileTree? matchingview;
        for (T_FileTree view in _loadedTrees) {
          if (view.path == viewpath) matchingview = view;
        }
        if (matchingview == null) {
          continue;
        }

        // For all hash string pairs:
        // Go along file path and update file view if existing
        for (C_FileHashPair hashpair in hashlist) {
          List<String> pathparts = libpath.split(hashpair.file);
          List<String> folders = pathparts.sublist(0, pathparts.length - 1);
          String file = pathparts.last;
          T_FileItem? matchingFileview = _getMatchingFileview(matchingview.children, folders, file);
          if (matchingFileview == null) {
            continue;
          }
          matchingFileview.globKey_HashAlgorithm.currentState!.set(hashpair.algorithm);
          matchingFileview.globKey_HashComparisonView.currentState!.set(hashpair.hash ?? "");
        }
      }
    }
  }

  // ##################################################
  // @brief: Clear all inputs for comparison hash
  // ##################################################
  void clearComparisonInputs() {
    for (T_FileTree view in _loadedTrees) {
      for (T_TreeItem item in view.children) {
        if (item is T_FileItem) {
          item.globKey_HashComparisonView.currentState!.set("");
        } else if (item is T_FolderItem) {
          _clearCompInp(item);
        }
      }
    }
    for (T_FileItem item in _loadedFiles) {
      item.globKey_HashComparisonView.currentState!.set("");
    }
  }

  // ##################################################
  // @brief: Clear all inputs for comparison hash for folder sub-items
  // @param: folder
  // ##################################################
  void _clearCompInp(T_FolderItem folder) {
    for (T_TreeItem item in folder.children) {
      if (item is T_FileItem) {
        item.globKey_HashComparisonView.currentState!.set("");
      } else if (item is T_FolderItem) {
        _clearCompInp(item);
      }
    }
  }

  // ##################################################
  // @brief: Get file view element (if existing) that matches a folder path
  // @param: viewitems
  // @param: folders
  // @param: file
  // @return: T_FileView?
  // ##################################################
  T_FileItem? _getMatchingFileview(List<T_TreeItem> viewitems, List<String> folders, String file) {
    for (T_TreeItem item in viewitems) {
      // Work on folder
      if (item is T_FolderItem) {
        if (folders.isEmpty) {
          continue; // File searched, folder found
        }
        T_FileItem? found = _getMatchingFileview(item.children, folders.sublist(1, folders.length), file);
        if (found != null) {
          return found;
        }
      }

      // Work on file
      if (item is T_FileItem) {
        if (folders.isNotEmpty) {
          continue; // Folder searched, file found
        }
        if (item.name == file) {
          return item;
        }
      }
    }
    return null;
  }
}

// ##################################################
// # TEMPLATE
// # Storage chooser row for hash file creation
// ##################################################
class T_StorageChooserRow extends StatelessWidget {
  // Attributes
  final String title;
  final T_FileTree? fileTreeView; // null means single files
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
