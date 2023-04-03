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

// ignore_for_file: camel_case_types, non_constant_identifier_names

import 'package:file_tree_hasher/templates/hashselector.dart';
import 'package:flutter/material.dart';

// ##################################################
// # TEMPLATE
// # Single file tree element (folder or file)
// ##################################################
abstract class T_FileTreeItem extends StatefulWidget {
  // Parameter
  final String name;
  final String path;

  // Constructor
  const T_FileTreeItem({super.key, required this.name, required this.path});
}

// ##################################################
// # TEMPLATE
// # Single folder view
// ##################################################
class T_FolderView extends T_FileTreeItem {
  // Parameter
  final List<T_FileTreeItem> subitems;

  // Constructor
  const T_FolderView(
      {super.key,
      required String path,
      required String name,
      this.subitems = const []})
      : super(name: name, path: path);

  @override
  State<StatefulWidget> createState() => _T_FolderView();
}

// ##################################################
// # STATE
// # Single folder view state
// ##################################################
class _T_FolderView extends State<T_FolderView> {
  // States
  bool expanded = true; // Is folder extended?

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(children: [
        SizedBox(
            width: 24,
            height: 24,
            child: IconButton(
              icon: Icon(expanded ? Icons.chevron_right : Icons.expand_more),
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              padding: EdgeInsets.zero,
              onPressed: click_expander,
            )),
        const Icon(Icons.folder),
        Expanded(child: Text(widget.name)),
        T_FileHashSelector()
      ]),
      buildSubitems()
    ]);
  }

  // Sub-items
  Visibility buildSubitems() {
    return Visibility(
        visible: expanded,
        child: Row(children: [
          const SizedBox(width: 20),
          Expanded(child: Column(children: widget.subitems))
        ]));
  }

  // Expand or collapse content
  // TODO: If top folder expands, all sub folders are expanded too even if they were not expanded before
  void click_expander() {
    setState(() {
      expanded = !expanded;
    });
  }
}

// ##################################################
// # TEMPLATE
// # Single file view
// ##################################################
class T_FileView extends T_FileTreeItem {
  // Constructor
  const T_FileView(
      {super.key,
      required String path,
      required String name,
      String hashGen = "",
      String hashComp = ""})
      : super(name: name, path: path);

  @override
  State<StatefulWidget> createState() => _T_FileView();
}

// ##################################################
// # STATE
// # Single file view state
// ##################################################
class _T_FileView extends State<T_FileView> {
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      const SizedBox(width: 24),
      const Icon(Icons.description),
      Expanded(child: Text(widget.name)),
      T_FileHashSelector()
    ]);
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
