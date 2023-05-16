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

import 'package:file_tree_hasher/definies/datatypes.dart';
import 'package:file_tree_hasher/definies/styles.dart';
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

  // Hash algorithm selector key
  final GlobalKey<T_HashSelector_state> globKey_HashAlg =
      GlobalKey<T_HashSelector_state>();

  // Constructor
  T_FileTreeItem({super.key, required this.name, required this.path});
}

// ##################################################
// # TEMPLATE
// # Single folder view
// ##################################################
class T_FolderView extends T_FileTreeItem {
  // Parameter
  final List<T_FileTreeItem> subitems;

  // Constructor
  T_FolderView(
      {super.key,
      required super.path,
      required super.name,
      this.subitems = const []});

  @override
  State<StatefulWidget> createState() => _T_FolderView_state();
}

// ##################################################
// # STATE
// # Single folder view state
// ##################################################
class _T_FolderView_state extends State<T_FolderView> {
  // States
  bool expanded = true; // Is folder extended?

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(children: [
        SizedBox(
            width: Style_FileTree_Icon_Width_px,
            height: Style_FileTree_Icon_Height_px,
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
        const SizedBox(width: Style_FileTree_Item_ElementSpaces_px),
        T_FileHashSelector(
            key: widget.globKey_HashAlg, onChanged: change_hashAlgorithm),
        const SizedBox(width: Style_FileTree_Item_ElementSpaces_px),
        const SizedBox(width: Style_FileTree_ComparisonInput_Width_px)
      ]),
      buildSubitems()
    ]);
  }

  // Sub-items
  Offstage buildSubitems() {
    return Offstage(
        offstage: !expanded,
        child: Row(children: [
          const SizedBox(width: Style_FileTree_SubItem_ShiftRight_px),
          Expanded(child: Column(children: widget.subitems))
        ]));
  }

  // ##################################################
  // # Event handlers
  // ##################################################

  // ##################################################
  // @brief: Click handler: Expander button
  //         Expand or collapse this folder and rotate expasion icon respectively
  // ##################################################
  void click_expander() {
    setState(() {
      expanded = !expanded;
    });
  }

  // ##################################################
  // @brief: Change handler: Selected hash algorithm has changed
  //         Also change selected hash algorithm for all sub-items
  // @param: selected
  // ##################################################
  void change_hashAlgorithm(String? selected) {
    // For all sub-elements change hash algorithm to same vale (Sub-folders will automatically do for their sub-elements)
    for (T_FileTreeItem subitem in widget.subitems) {
      subitem.globKey_HashAlg.currentState?.updateSelected(selected);
    }
  }
}

// ##################################################
// # TEMPLATE
// # Single file view
// ##################################################
class T_FileView extends T_FileTreeItem {
  // Constructor
  T_FileView({super.key, required super.path, required super.name});

  @override
  State<StatefulWidget> createState() => _T_FileView_state();
}

// ##################################################
// # STATE
// # Single file view state
// ##################################################
class _T_FileView_state extends State<T_FileView> {
  // State attributes
  String _hashGen = "";
  String _hashComp = "";
  E_HashComparisonResult _comparisonResult = E_HashComparisonResult.none;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      const SizedBox(width: Style_FileTree_Icon_Width_px),
      const Icon(Icons.description),
      Text(widget.name),
      const SizedBox(width: Style_FileTree_Item_ElementSpaces_px),
      T_HashGenerationView(),
      T_FileHashSelector(key: widget.globKey_HashAlg),
      const SizedBox(width: Style_FileTree_Item_ElementSpaces_px),
      SizedBox(
          width: Style_FileTree_ComparisonInput_Width_px,
          height: Style_FileTree_ComparisonInput_Height_px,
          child: TextField(
              style: const TextStyle(
                  fontSize: Style_FileTree_ComparisonInput_FontSize_px),
              decoration: const InputDecoration(border: OutlineInputBorder()),
              controller: TextEditingController(text: _hashComp),
              onChanged: (value) {
                _hashComp = value;
                _compareHashes(hashComp: value);
              }))
    ]);
  }

  // ##################################################
  // @brief: Compare generated hash with text input
  // @param: hashGen
  // @param: hashComp
  // ##################################################
  // TODO: Whole line is recreated but only hash background color changes
  void _compareHashes({String? hashGen, String? hashComp}) {
    // Get hashes if not passed
    String hash_generated = hashGen ?? getHashGen();
    String hash_comparison = hashComp ?? getHashComp();

    setState(() {
      // If any of both hashes is empty, no comparison is done
      if (hash_generated.isEmpty || hash_comparison.isEmpty) {
        _comparisonResult = E_HashComparisonResult.none;
        return;
      }

      // For 2 valid inputs, the result is equal or not equal
      _comparisonResult = hash_generated == hash_comparison
          ? E_HashComparisonResult.equal
          : E_HashComparisonResult.notEqual;
    });
  }

  // ##################################################
  // @brief: Getter/Setter for hash strings
  // @return: String
  // ##################################################
  String getHashGen() {
    return _hashGen;
  }

  String getHashComp() {
    return _hashComp;
  }

  void setHashGen(String s) {
    setState(() {
      _hashGen = s;
    });
  }

  void setHashComp(String s) {
    setState(() {
      _hashComp = s;
    });
  }
}

// ##################################################
// # TEMPLATE
// # File tree view area
// ##################################################
class T_FileTreeView extends StatefulWidget {
  final String title;
  final List<T_FileTreeItem> items;

  // Constructor
  const T_FileTreeView({super.key, required this.items, required this.title});

  @override
  State<StatefulWidget> createState() => _T_FileTreeView_state();
}

class _T_FileTreeView_state extends State<T_FileTreeView> {
  // Is file tree visible
  // FIXME: View is not fully removed but replaced with placeholder. This could blow up the memory for long usage
  bool _visible = true;

  @override
  Widget build(BuildContext context) {
    return _visible
        ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 10),
            ExpansionTile(
                maintainState: true,
                initiallyExpanded: true,
                leading: const Icon(Icons.folder), // benutzerdefiniertes Icon
                trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        _visible = false;
                      });
                    }),
                title: Text(widget.title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                childrenPadding: const EdgeInsets.symmetric(horizontal: 10),
                children: [
                  const SizedBox(height: 10),
                  Column(children: widget.items),
                  const SizedBox(height: 10)
                ])
          ])
        : const SizedBox.shrink();
  }
}

// ##################################################
// # TEMPLATE
// # Hash generation view
// # This widget can be inserted into file view to show hash calculation progress or generated hash comparison
// ##################################################
class T_HashGenerationView extends StatefulWidget {
  // Constructor
  const T_HashGenerationView({super.key});

  @override
  State<StatefulWidget> createState() => _T_HashGenerationView_state();
}

// ##################################################
// # STATE
// # Hash generation view state
// ##################################################
class _T_HashGenerationView_state extends State<T_HashGenerationView> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Container(
            color: Style_FileTree_HashComp_Colors[E_HashComparisonResult.equal],
            child: Text("", style: Style_FileTree_HashGen)));
  }
}
