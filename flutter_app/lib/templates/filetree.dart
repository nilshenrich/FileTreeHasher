// ####################################################################################################
// # @file filetree.dart
// # @author Nils Henrich
// # @brief Templates for loaded file, file tree and corresponding hashing and comparison funcionality
// # @version 0.0.0+1
// # @date 2023-03-30
// #
// # @copyright Copyright (c) 2023
// #
// ####################################################################################################

import 'package:flutter/material.dart';

// ##################################################
// # TEMPLATE
// # Single file tree element (folder or file)
// ##################################################
abstract class T_FileTreeItem extends StatelessWidget {
  // Parameter
  final String name;
  final String path;

  // Constructor
  const T_FileTreeItem({super.key, required this.name, required this.path});

  // ##################################################
  // @brief: Get item path
  // @return: String
  // ##################################################
}

// ##################################################
// # TEMPLATE
// # Single folder view
// ##################################################
class T_FolderView extends T_FileTreeItem {
  // Constructor
  T_FolderView(
      {required String path,
      required String name,
      List<T_FileTreeItem> subitems = const []})
      : super(name: name, path: path);

  @override
  Widget build(BuildContext context) {
    return Row(children: [Icon(Icons.folder), Text(name)]);
  }

  // Sub-items
}

// ##################################################
// # TEMPLATE
// # Single file view
// ##################################################
class T_FileView extends T_FileTreeItem {
  // Constructor
  T_FileView(
      {required String path,
      required String name,
      String hashGen = "",
      String hashComp = ""})
      : super(name: name, path: path);

  @override
  Widget build(BuildContext context) {
    return Row(children: [Icon(Icons.description), Text(name)]);
  }
}

// ##################################################
// # TEMPLATE
// # File tree view area
// ##################################################
class T_FileTreeView extends StatelessWidget {
  final List<T_FileTreeItem> items;

  const T_FileTreeView({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(children: items);
  }
}
