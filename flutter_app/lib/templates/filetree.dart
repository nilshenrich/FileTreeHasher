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
  // Parameter
  final String m_path;
  final String m_name;
  final IconData m_icon;

  // Constructor
  const T_FileTreeItem(this.m_path, this.m_name, this.m_icon,
      {List<T_FileTreeItem> content = const []})
      : super(key: m_path, label: m_name, icon: m_icon, children: content);
}

// ##################################################
// # TEMPLATE
// # Single folder view
// ##################################################
class T_FolderView extends T_FileTreeItem {
  // Parameter
  final String path;
  final String name;

  // Constructor
  const T_FolderView(this.path, this.name,
      {List<T_FileTreeItem> content = const []})
      : super(path, name, Icons.folder, content: content);
}

// ##################################################
// # TEMPLATE
// # Single file view
// ##################################################
class T_FileView extends T_FileTreeItem {
  // Parameter
  final String path;
  final String name;

  // Constructor
  const T_FileView(this.path, this.name,
      {String hashGen = "", String hashComp = ""})
      : super(path, name, Icons.description);
}
