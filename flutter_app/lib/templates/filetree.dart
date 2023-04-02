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
  final String path;
  final String name;
  final IconData icon;
  final List<Widget> elements;

  // Constructor
  const T_FileTreeItem(
      {super.key,
      required this.icon,
      required this.name,
      required this.path,
      required this.elements});

  @override
  Widget build(BuildContext context) {
    return Row(
        children: <Widget>[Icon(icon), Text(name)] +
            elements +
            <Widget>[Text("<Hash dropdown>")]);
  }

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
      bool expanded = false,
      List<T_FileTreeItem> subitems = const []})
      : super(icon: Icons.folder, name: name, path: path, elements: []);
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
      : super(icon: Icons.description, name: name, path: path, elements: []);
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
