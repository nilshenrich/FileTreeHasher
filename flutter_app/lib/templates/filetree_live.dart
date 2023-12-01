// ignore_for_file: camel_case_types

import 'dart:io';

import 'package:file_tree_hasher/definies/styles.dart';
import 'package:file_tree_hasher/functions/general.dart';
import 'package:flutter/material.dart';

abstract class T_FileTree_Item extends StatefulWidget {
  // Parameter
  final String name; // Elements name (to be shown in GUI)
  final String path; // Elements absolute system path (used for hash generation and shown in tree header)
  final String parent; // Elements parents absolute system path
  final bool showFullPath; // True := Set full path as name ; False := Set just item name as name

  T_FileTree_Item({super.key, required this.path, required this.showFullPath})
      : name = GetFileName(path),
        parent = GetParentPath(path);
}

class T_FileTree_Folder extends T_FileTree_Item {
  // Constructor
  T_FileTree_Folder({super.key, required super.path, super.showFullPath = false});

  @override
  State<StatefulWidget> createState() => T_FileTree_Folder_state();
}

class T_FileTree_Folder_state extends State<T_FileTree_Folder> {
  // State parameter
  bool expanded = true;
  List<T_FileTree_Item> children = [];

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
    super.initState();
    loadChildren();
  }

  // ##################################################
  // @brief: Load child items from system path
  // ##################################################
  Future<void> loadChildren() async {
    Directory systemDir = Directory(widget.path);
    Stream<FileSystemEntity> systemItems = systemDir.list();
    await for (FileSystemEntity sysItem in systemItems) {
      T_FileTree_Item item;

      // ---------- Item is a file ----------
      if (sysItem is File) {
        item = T_FileTree_File(
          path: sysItem.path,
          showFullPath: false,
        );
      }

      // ---------- Item is a folder ----------
      else if (sysItem is Directory) {
        item = T_FileTree_Folder(path: sysItem.path);
      }

      // ---------- Item is none of these ----------
      else {
        continue;
      }

      // ---------- Add new item as sub-item ----------
      setState(() {
        children.add(item);
      });
    }
  }
}

class T_FileTree_Tree extends T_FileTree_Folder {
  T_FileTree_Tree({super.key, required super.path, super.showFullPath = true});
}

class T_FileTree_File extends T_FileTree_Item {
  // Constructor
  T_FileTree_File({super.key, required super.path, required super.showFullPath});

  @override
  State<StatefulWidget> createState() => T_FileTree_File_state();
}

class T_FileTree_File_state extends State<T_FileTree_File> {
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
