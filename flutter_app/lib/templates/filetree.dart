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
import 'package:flutter_treeview/flutter_treeview.dart';

// ##################################################
// # TEMPLATE
// # Single file tree element (folder or file)
// ##################################################
abstract class T_FileTreeItem extends Node {
  // Constructor
  const T_FileTreeItem(
      {required String path,
      required String name,
      required IconData icon,
      required bool expanded,
      List<T_FileTreeItem> content = const []})
      : super(
            key: path,
            label: name,
            icon: icon,
            children: content,
            expanded: expanded);

  // ##################################################
  // @brief: Get item path
  // @return: String
  // ##################################################
  String get path => super.key;
}

// ##################################################
// # TEMPLATE
// # Single folder view
// ##################################################
class T_FolderView extends T_FileTreeItem {
  // Constructor
  const T_FolderView(
      {required String path,
      required String name,
      bool expanded = false,
      List<T_FileTreeItem> content = const []})
      : super(
            path: path,
            name: name,
            icon: Icons.folder,
            expanded: expanded,
            content: content);
}

// ##################################################
// # TEMPLATE
// # Single file view
// ##################################################
class T_FileView extends T_FileTreeItem {
  // Constructor
  const T_FileView(
      {required String path,
      required String name,
      String hashGen = "",
      String hashComp = ""})
      : super(path: path, name: name, icon: Icons.description, expanded: false);
}
