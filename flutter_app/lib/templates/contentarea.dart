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
        flexibleSpace: Row(children: <Widget>[
      // -------------------- Section: File tree --------------------
      T_HeaderControlSection(headingText: "File tree control", items: [
        // ---------- Button: load file tree ----------
        IconButton(onPressed: BodyContent.currentState!.selectNewFolder, icon: const Icon(Icons.drive_folder_upload), tooltip: "Load file tree"),
        // ---------- Button: Load single file ----------
        IconButton(onPressed: BodyContent.currentState!.selectNewFiles, icon: const Icon(Icons.upload_file), tooltip: "Load single files"),
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
        IconButton(onPressed: BodyContent.currentState!.loadHashfile, icon: const Icon(Icons.upload_outlined), tooltip: "Load checksum file"),
        IconButton(onPressed: BodyContent.currentState!.safeHashFile, icon: const Icon(Icons.download_outlined), tooltip: "Safe checksum file"),
        IconButton(
            onPressed: BodyContent.currentState!.clearComparisonInputs,
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
  State<StatefulWidget> createState() => T_BodyContent_state();
}

// ##################################################
// # STATE
// # Body containing loaded files and comparisons
// ##################################################
class T_BodyContent_state extends State<T_BodyContent> {
  // Currently loaded file trees
  final List<T_FileTreeView> _loadedTrees = [_exampleFileTree];
  final List<T_FileView> _loadedFiles = [_exampleFile];

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const ContentDivider_folders(),
      Column(children: _loadedTrees),
      const ContentDivider_files(),
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
    if (filetreePath == null) {
      return;
    }

    // -------------------- Show selected folder as tree view --------------------
    _showNewFolder(filetreePath);
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
        _loadedFiles.add(T_FileView(path: path!, name: libpath.basename(path)));
      });
    }
  }

  // ##################################################
  // @brief: Remove all loaded file trees and files
  // ##################################################
  void clearContent() {
    setState(() {
      _loadedTrees.clear();
      _loadedFiles.clear();
    });
  }

  // ##################################################
  // @brief: Update all hash algorithms recursively
  // @param: selected
  // ##################################################
  void updateHashAlg(String? selected) {
    for (T_FileTreeView view in _loadedTrees) {
      for (T_FileTreeItem item in view.items) {
        item.globKey_HashAlgorithm.currentState!.set(selected);
      }
    }
    for (T_FileView item in _loadedFiles) {
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
  // BUG: Deletd files and views are shown as a path selector
  // TODO: What if hash generation is ongoing?
  void safeHashFile() {
    // Get all file trees and single files into widgets
    List<Widget> dialogRows = [];
    for (T_FileTreeView views in _loadedTrees) {
      dialogRows.add(T_StorageChooserRow(title: views.title, fileTreeViewKey: views.key as GlobalKey<T_FileTreeView_state>));
    }
    dialogRows.add(T_StorageChooserRow(title: HashfileSingletext));

    // Add exit buttons at the end
    dialogRows.add(Row(children: [
      const Expanded(child: SizedBox.shrink()),
      IconButton(
          onPressed: () {
            for (Widget row in dialogRows) {
              if (row is! T_StorageChooserRow) continue;
              String storagepath = row.getStoragePath();
              GlobalKey<T_FileTreeView_state>? key = row.fileTreeViewKey;
              if (key == null) {
                GenerateHashfile(SingleFiles_to_FileViewHashes(_loadedFiles, "Single files"), storagepath);
              } else {
                T_FileTreeView view = row.fileTreeViewKey!.currentState!.widget;
                GenerateHashfile(FileTreeItems_to_FileViewHashes(view.items, view.title), storagepath);
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
  // TODO: Not done for single files
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

      // Find matching file tree view
      T_FileTreeView? matchingview;
      for (T_FileTreeView view in _loadedTrees) {
        if (view.title == viewpath) matchingview = view;
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
        T_FileView? matchingFileview = _getMatchingFileview(matchingview.items, folders, file);
        if (matchingFileview == null) {
          continue;
        }
        matchingFileview.globKey_HashAlgorithm.currentState!.set(hashpair.algorithm);
        matchingFileview.globKey_HashComparisonView.currentState!.set(hashpair.hash ?? "");
      }
    }
  }

  // ##################################################
  // @brief: Clear all inputs for comparison hash
  // ##################################################
  void clearComparisonInputs() {
    for (T_FileTreeView view in _loadedTrees) {
      for (T_FileTreeItem item in view.items) {
        if (item is T_FileView) {
          item.globKey_HashComparisonView.currentState!.set("");
        } else if (item is T_FolderView) {
          _clearCompInp(item);
        }
      }
    }
    for (T_FileView item in _loadedFiles) {
      item.globKey_HashComparisonView.currentState!.set("");
    }
  }

  // ##################################################
  // @brief: Show file tree from a given path
  // @param: path
  // ##################################################
  void _showNewFolder(String path) {
    setState(() {
      _loadedTrees.add(T_FileTreeView(key: GlobalKey<T_FileTreeView_state>(), items: _loadFolder(Directory(path)), title: path));
    });
  }

  // ##################################################
  // @brief: Load folders and files and add to given list
  // @param: rootFolder
  // @return list of items
  // ##################################################
  List<T_FileTreeItem> _loadFolder(Directory rootFolder) {
    List<T_FileTreeItem> itemsList = [];
    List<FileSystemEntity> items = rootFolder.listSync();

    // Loop over all files and subdirectories
    for (FileSystemEntity item in items) {
      // For subfolders
      if (item is Directory) {
        // Load all sub items of this subfolder and add to list
        T_FolderView subfolder = T_FolderView(path: item.path, name: GetFileName(item.path), subitems: _loadFolder(item));
        itemsList.add(subfolder);
      }

      // For files
      else if (item is File) {
        // Add file element to list
        T_FileView file = T_FileView(path: item.path, name: GetFileName(item.path));
        itemsList.add(file);
      }
    }
    return itemsList;
  }

  // ##################################################
  // @brief: Clear all inputs for comparison hash for folder sub-items
  // @param: folder
  // ##################################################
  void _clearCompInp(T_FolderView folder) {
    for (T_FileTreeItem item in folder.subitems) {
      if (item is T_FileView) {
        item.globKey_HashComparisonView.currentState!.set("");
      } else if (item is T_FolderView) {
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
  T_FileView? _getMatchingFileview(List<T_FileTreeItem> viewitems, List<String> folders, String file) {
    for (T_FileTreeItem item in viewitems) {
      // Work on folder
      if (item is T_FolderView) {
        if (folders.isEmpty) {
          continue; // File searched, folder found
        }
        T_FileView? found = _getMatchingFileview(item.subitems, folders.sublist(1, folders.length), file);
        if (found != null) {
          return found;
        }
      }

      // Work on file
      if (item is T_FileView) {
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
  final GlobalKey<T_FileTreeView_state>? fileTreeViewKey; // null means single files
  final TextEditingController _textEditingController = TextEditingController();

  // Constructor
  T_StorageChooserRow({super.key, required this.title, this.fileTreeViewKey});

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

// DEV: Example file tree
T_FileTreeView _exampleFileTree = T_FileTreeView(
  key: GlobalKey<T_FileTreeView_state>(),
  title: "<First loaded file tree>",
  items: [
    T_FolderView(path: "/root/folder/top-folder", name: "top-folder", subitems: [
      T_FolderView(path: "/root/folder/top-folder/sub-folder", name: "sub-folder", subitems: [
        T_FolderView(path: "/root/folder/top-folder/sub-folder/sub-sub-folder", name: "sub-sub-folder"),
        T_FileView(path: "/root/folder/top-folder/sub-folder/sub-sub-file", name: "sub-sub-file")
      ]),
      T_FolderView(path: "/root/folder/top-folder/sub-folder-with-long-name", name: "sub-folder-with-long-name"),
      T_FileView(path: "/root/folder/top-folder/sub-file", name: "sub-file"),
      T_FileView(path: "/root/folder/top-folder/sub-file-with-long-name", name: "sub-file-with-long-name")
    ]),
    T_FolderView(path: "/root/folder/folder-with-long-name", name: "folder-with-long-name"),
    T_FileView(path: "/root/folder/top-file", name: "top-file")
  ],
);
T_FileView _exampleFile = T_FileView(path: "/root/folder/file.txt", name: "/root/folder/file.txt");
