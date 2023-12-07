// ####################################################################################################
// # @file filetree.dart
// # @author Nils Henrich
// # @brief Build file tree from system path and provide hash generating and checking
// # @version 1.0.1+4
// # @date 2023-12-07
// #
// # @copyright Copyright (c) 2023
// #
// ####################################################################################################

// ignore_for_file: camel_case_types

import 'dart:async';
import 'dart:io';

import 'package:file_tree_hasher/definies/styles.dart';
import 'package:file_tree_hasher/functions/general.dart';
import 'package:flutter/material.dart';

// ##################################################
// # TEMPLATE
// # File tree item to be shown in file tree
// ##################################################
abstract class T_FileTree_Item extends StatefulWidget {
  // Parameter
  final String name; // Elements name (to be shown in GUI)
  final String path; // Elements absolute system path (used for hash generation and shown in tree header)
  final String parent; // Elements parents absolute system path
  final bool showFullPath; // True := Set full path as name ; False := Set just item name as name

  // Constructor
  T_FileTree_Item({super.key, required this.path, required this.showFullPath})
      : name = GetFileName(path),
        parent = GetParentPath(path);
}

// ##################################################
// # ITEM
// # Folder item
// ##################################################
// TODO: Make InheritedWidget, so all children can be updated on change
class I_FileTree_Folder extends T_FileTree_Item {
  // Constructor
  I_FileTree_Folder({super.key, required super.path, super.showFullPath = false});

  @override
  State<StatefulWidget> createState() => I_FileTree_Folder_state();
}

// ##################################################
// # STATE
// # Folder item
// ##################################################
class I_FileTree_Folder_state extends State<I_FileTree_Folder> {
  // State parameter
  bool expanded = true; // Is folder expanded
  List<T_FileTree_Item> children = []; // Direct child items to be shown in tree
  StreamController<T_FileTree_Item> s_children = StreamController(); // Stream to add a child item with live update

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.folder),
            Text(widget.name),
          ],
        ),
        Offstage(
          offstage: !expanded,
          child: Row(
            children: [
              const SizedBox(
                width: Style_FileTree_SubItem_ShiftRight_px,
              ),
              Column(
                children: children,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    // ---------- Add event listener to be triggered when adding a new child item ----------
    s_children.stream.listen((item) {
      setState(() {
        children.add(item);
      });
    });

    // ---------- Call base method as usual ----------
    super.initState();

    // ---------- Load all direct children items from system ----------
    loadChildren();
  }

  // ##################################################
  // @brief: Load child items from system path
  // ##################################################
  void loadChildren() async {
    Directory systemDir = Directory(widget.path);
    Stream<FileSystemEntity> systemItems = systemDir.list();
    await for (FileSystemEntity sysItem in systemItems) {
      T_FileTree_Item item;

      // ---------- Item is a file ----------
      if (sysItem is File) {
        item = I_FileTree_File(
          path: sysItem.path,
          showFullPath: false,
        );
      }

      // ---------- Item is a folder ----------
      else if (sysItem is Directory) {
        item = I_FileTree_Folder(path: sysItem.path);
      }

      // ---------- Item is none of these ----------
      else {
        continue;
      }

      // ---------- Trigger stram listener to add new item as sub-item ----------
      if (!s_children.isClosed) s_children.sink.addStream(Stream.value(item));
      // await Future.delayed(Duration(seconds: 1)); // DEV: To simulate calculation time
      await Future.delayed(Duration.zero); // Use await to work consecutively on items
    }
  }
}

// ##################################################
// # ITEM
// # File tree head (differently designed folder under the hood)
// ##################################################
class I_FileTree_Head extends I_FileTree_Folder {
  // Constructor
  I_FileTree_Head({super.key, required super.path, super.showFullPath = true});
}

// ##################################################
// # ITEM
// # File item
// ##################################################
class I_FileTree_File extends T_FileTree_Item {
  // Constructor
  I_FileTree_File({super.key, required super.path, required super.showFullPath});

  @override
  State<StatefulWidget> createState() => I_FileTree_File_state();
}

// ##################################################
// # STATE
// # File item
// ##################################################
class I_FileTree_File_state extends State<I_FileTree_File> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.description),
        Text(widget.name),
      ],
    );
  }
}
