// ignore_for_file: camel_case_types

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
            children: children,
          ),
        ),
      ],
    );
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
