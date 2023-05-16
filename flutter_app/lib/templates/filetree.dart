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

import 'dart:convert';
import 'dart:io';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:file_tree_hasher/definies/datatypes.dart';
import 'package:file_tree_hasher/definies/defaults.dart';
import 'package:file_tree_hasher/definies/styles.dart';
import 'package:file_tree_hasher/templates/hashselector.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

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
  String _hashComp = "";

  @override
  Widget build(BuildContext context) {
    GlobalKey<T_HashGenerationView_state> hashGenerationView =
        GlobalKey<T_HashGenerationView_state>();
    return Row(children: [
      const SizedBox(width: Style_FileTree_Icon_Width_px),
      const Icon(Icons.description),
      Text(widget.name),
      const SizedBox(width: Style_FileTree_Item_ElementSpaces_px),
      Expanded(
          child: T_HashGenerationView(
              key: hashGenerationView, filepath: widget.path)),
      const SizedBox(width: Style_FileTree_Item_ElementSpaces_px),
      T_FileHashSelector(
          key: widget.globKey_HashAlg,
          onChanged: (selected) {
            hashGenerationView.currentState!.updateHashAlg(selected);
          }),
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
                hashGenerationView.currentState!.compareHashes(value);
              }))
    ]);
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

// ##################################################
// # STATE
// # File tree view area
// ##################################################
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
  // Attributes
  final String filepath;

  // Constructor
  T_HashGenerationView({super.key, required this.filepath});

  // Hash generation view key
  final GlobalKey<T_HashGenerationView_state> globKey_HashGenView =
      GlobalKey<T_HashGenerationView_state>();

  @override
  State<StatefulWidget> createState() => T_HashGenerationView_state();
}

// ##################################################
// # STATE
// # Hash generation view state
// ##################################################
class T_HashGenerationView_state extends State<T_HashGenerationView> {
  // State attributes
  String _hashGen = "";
  double _genProgress = 0;
  E_HashComparisonResult _comparisonResult = E_HashComparisonResult.none;

  @override
  Widget build(BuildContext context) {
    return _hashGen.isEmpty
        ? LinearPercentIndicator(
            percent: _genProgress,
            lineHeight: Style_FileTree_HashGen_Prg_Height_px,
            center: Text("${(_genProgress * 100).toStringAsFixed(1)}%",
                style: Style_FileTree_HashGen_Prg_Text),
            progressColor: Style_FileTree_HashGen_Prg_Color)
        : Container(
            color: Style_FileTree_HashComp_Colors[_comparisonResult],
            child: Text(_hashGen, style: Style_FileTree_HashGen));
  }

  @override
  void initState() {
    super.initState();
    _generateHash(DefaultHashAlgorithm.value);
  }

  // ##################################################
  // @brief: Update hash algorith
  //         This will rebuild the whole widget
  // @param: alg
  // ##################################################
  void updateHashAlg(String? alg) {
    _generateHash(alg);
  }

  // ##################################################
  // @brief: Compare generated hash with text input
  // @param: hashGen
  // @param: hashComp
  // ##################################################
  // TODO: Whole line is recreated but only hash background color changes
  void compareHashes(String hashComp) {
    setState(() {
      // If any of both hashes is empty, no comparison is done
      if (_hashGen.isEmpty || hashComp.isEmpty) {
        _comparisonResult = E_HashComparisonResult.none;
        return;
      }

      // For 2 valid inputs, the result is equal or not equal
      _comparisonResult = _hashGen == hashComp
          ? E_HashComparisonResult.equal
          : E_HashComparisonResult.notEqual;

      return;
    });
  }

  // ##################################################
  // @brief: Calculate hash and update GUI
  // ##################################################
  void _generateHash(String? alg) async {
    // -------------------- Read file --------------------
    File file = File(widget.filepath);
    if (!await file.exists()) {
      throw FileSystemException("File ${widget.filepath} does not exist");
    }

    // -------------------- Generate hash --------------------

    // Reset old hash
    setState(() {
      _hashGen = "";
    });

    // File size and processed size for progress calculation
    int totalBytes = await file.length();
    int bytesRead = 0;

    // Select hash algorithm
    var hashOut = AccumulatorSink<Digest>();
    ByteConversionSink hasher;
    hasher = sha256.startChunkedConversion(
        hashOut); // TODO: Select algorithm based on selection

    // Read file step by step and generate hash
    await for (var chunk in file.openRead()) {
      // Generate hash for next file part
      bytesRead += chunk.length;
      hasher.add(chunk);

      // Update progress bar
      setState(() {
        _genProgress = bytesRead / totalBytes;
      });
    }

    // -------------------- Done --------------------

    // Extract hash string
    hasher.close();
    String hashString = hashOut.events.single.toString();

    setState(() {
      _hashGen = hashString;
    });
  }
}
