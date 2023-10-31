// ####################################################################################################
// # @file filetree.dart
// # @author Nils Henrich
// # @brief Templates for loaded file, file tree and corresponding hashing and comparison funcionality
// # @version 1.0.1+4
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
import 'package:file_tree_hasher/definies/hashalgorithms.dart';
import 'package:file_tree_hasher/definies/styles.dart';
import 'package:file_tree_hasher/functions/general.dart';
import 'package:file_tree_hasher/templates/hashselector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:percent_indicator/percent_indicator.dart';

// ##################################################
// # TEMPLATE
// # Single file tree element (folder or file)
// ##################################################
abstract class T_FileTreeItem extends StatefulWidget {
  // Parameter
  final String name; // File name used for view
  final String path; // Absolute file path used for loading file
  final String namePathPart; // Path to parent folder if name is given as a path

  // Hash algorithm selector key
  final globKey_HashAlgorithm = GlobalKey<T_HashSelector_state>();

  // Constructor
  T_FileTreeItem({super.key, required name, required this.path})
      : name = GetFileName(name),
        namePathPart = GetParentPath(name);
}

// ##################################################
// # TEMPLATE
// # Single folder view
// ##################################################
class T_FolderView extends T_FileTreeItem {
  // Parameter
  final List<T_FileTreeItem> subitems;

  // Constructor
  T_FolderView({super.key, required super.path, required super.name, this.subitems = const []});

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
        Text(widget.namePathPart, style: Style_FileTree_Text_ParentPath),
        Expanded(child: Text(widget.name)),
        const SizedBox(width: Style_FileTree_Item_ElementSpaces_px),
        T_FileHashSelector(key: widget.globKey_HashAlgorithm, onChanged: change_hashAlgorithm),
        const SizedBox(width: Style_FileTree_Item_ElementSpaces_px),
        const SizedBox(width: Style_FileTree_ComparisonInput_Width_px),
      ]),
      buildSubitems()
    ]);
  }

  // Sub-items
  // TODO: Can be implemented directly without function
  Offstage buildSubitems() {
    return Offstage(
        offstage: !expanded,
        child: Row(children: [const SizedBox(width: Style_FileTree_SubItem_ShiftRight_px), Expanded(child: Column(children: widget.subitems))]));
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
      subitem.globKey_HashAlgorithm.currentState!.set(selected);
    }
  }
}

// ##################################################
// # TEMPLATE
// # Single file view
// ##################################################
class T_FileView extends T_FileTreeItem {
  final globKey_HashGenerationView = GlobalKey<T_HashGenerationView_state>();
  final globKey_HashComparisonView = GlobalKey<T_HashComparisonView_state>();

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
  // No state attributes

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      const SizedBox(width: Style_FileTree_Icon_Width_px),
      const Icon(Icons.description),
      Text(widget.namePathPart, style: Style_FileTree_Text_ParentPath),
      Text(widget.name),
      const SizedBox(width: Style_FileTree_Item_ElementSpaces_px),
      Expanded(
          child: T_HashGenerationView(
              key: widget.globKey_HashGenerationView, filepath: widget.path, globKey_HashComparisonView: widget.globKey_HashComparisonView)),
      const SizedBox(width: Style_FileTree_Item_ElementSpaces_px),
      T_FileHashSelector(
          key: widget.globKey_HashAlgorithm,
          onChanged: (selected) {
            T_HashGenerationView_state hashGen = widget.globKey_HashGenerationView.currentState!;
            hashGen.abortHashGeneration();
            hashGen.generateHash(selected);
          }),
      const SizedBox(width: Style_FileTree_Item_ElementSpaces_px),
      T_HashComparisonView(
          key: widget.globKey_HashComparisonView,
          onChanged: (value) {
            widget.globKey_HashGenerationView.currentState!.compareHashes(value);
          }),
    ]);
  }
}

// ##################################################
// # TEMPLATE
// # File tree view area
// ##################################################
class T_FileTreeView extends T_FolderView {
  // Constructor
  T_FileTreeView({super.key, required super.path, super.subitems = const []}) : super(name: path);

  @override
  State<T_FileTreeView> createState() => T_FileTreeView_state();
}

class T_FileTreeView_state extends State<T_FileTreeView> {
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 10),
      ExpansionTile(
          maintainState: true,
          initiallyExpanded: true,
          leading: const Icon(Icons.folder),
          title: Text(widget.path, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          childrenPadding: const EdgeInsets.symmetric(horizontal: Style_FileTree_Item_ElementSpaces_px),
          children: [const SizedBox(height: 10), Column(children: widget.subitems), const SizedBox(height: 10)])
    ]);
  }

  // ##################################################
  // @brief: Add an item
  // @param: item
  // ##################################################
  void add(T_FileTreeItem item) {
    setState(() {
      widget.subitems.add(item);
    });
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
  final GlobalKey<T_HashComparisonView_state> globKey_HashComparisonView;

  // Constructor
  const T_HashGenerationView({super.key, required this.filepath, required this.globKey_HashComparisonView});

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
  bool _ongoing = false;
  E_HashComparisonResult _comparisonResult = E_HashComparisonResult.none;

  @override
  Widget build(BuildContext context) {
    return _hashGen.isEmpty
        ? LinearPercentIndicator(
            percent: _genProgress,
            lineHeight: Style_FileTree_HashGen_Prg_Height_px,
            center: Text("${(_genProgress * 100).toStringAsFixed(1)}%", style: Style_FileTree_HashGen_Prg_Text),
            progressColor: Style_FileTree_HashGen_Prg_Color)
        : Row(children: [
            Flexible(
                child:
                    Container(color: Style_FileTree_HashComp_Colors[_comparisonResult], child: Text(_hashGen, style: Style_FileTree_HashGen_Text))),
            SizedBox(
                height: Style_FileTree_HashSelector_FontSize_px,
                child: IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _hashGen));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Copied to clipboard")));
                    },
                    iconSize: Style_FileTree_HashSelector_FontSize_px,
                    padding: EdgeInsets.zero,
                    color: Style_FileTree_HashGen_Text.color,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    icon: const Icon(Icons.copy)))
          ]);
  }

  @override
  void initState() {
    super.initState();
    generateHash(SelectedGlobalHashAlg);
  }

  // ##################################################
  // @brief: Compare generated hash with text input
  // @param: hashComp
  // ##################################################
  void compareHashes(String hashComp) {
    setState(() {
      // If any of both hashes is empty, no comparison is done
      if (_hashGen.isEmpty || hashComp.isEmpty) {
        _comparisonResult = E_HashComparisonResult.none;
        return;
      }

      // For 2 valid inputs, the result is equal or not equal
      _comparisonResult = _hashGen.toLowerCase() == hashComp.toLowerCase() ? E_HashComparisonResult.equal : E_HashComparisonResult.notEqual;

      return;
    });
  }

  // ##################################################
  // @brief: Calculate hash and update GUI
  // @param alg
  // ##################################################
  void generateHash(String? alg) async {
    // -------------------- Read file --------------------
    File file = File(widget.filepath);
    if (!await file.exists()) {
      // throw FileSystemException("File ${widget.filepath} does not exist");
      setState(() {
        _hashGen = "<Can't find file in file system>";
        _genProgress = 0;
        _comparisonResult = E_HashComparisonResult.none;
      });
      return;
    }

    // -------------------- Generate hash --------------------

    // Reset old hash and comparison
    setState(() {
      _genProgress = 0;
      _hashGen = "";
      _comparisonResult = E_HashComparisonResult.none;
    });

    // File size and processed size for progress calculation
    int totalBytes = await file.length();
    int bytesRead = 0;

    // Select hash algorithm
    var hashOut = AccumulatorSink<Digest>();
    ByteConversionSink hasher;
    if (alg == E_HashAlgorithms.MD5.value) {
      hasher = md5.startChunkedConversion(hashOut);
    } else if (alg == E_HashAlgorithms.SHA1.value) {
      hasher = sha1.startChunkedConversion(hashOut);
    } else if (alg == E_HashAlgorithms.SHA256.value) {
      hasher = sha256.startChunkedConversion(hashOut);
    } else if (alg == E_HashAlgorithms.SHA384.value) {
      hasher = sha384.startChunkedConversion(hashOut);
    } else if (alg == E_HashAlgorithms.SHA512.value) {
      hasher = sha512.startChunkedConversion(hashOut);
    } else if (alg == E_HashAlgorithms.NONE.value) {
      setState(() {
        _hashGen = "<No hash to create>";
      });
      return;
    } else {
      setState(() {
        _hashGen = "<Can't use hash algorithm '$alg'>";
      });
      return;
    }

    // -------------------- Start --------------------
    _ongoing = true;

    // Read file step by step and generate hash
    await for (var chunk in file.openRead()) {
      // Abort process here if flag is unset
      if (!_ongoing) {
        return;
      }

      // Generate hash for next file part
      bytesRead += chunk.length;
      hasher.add(chunk);

      // Update progress bar
      if (!mounted) {
        return;
      }
      setState(() {
        _genProgress = bytesRead / totalBytes;
      });
    }

    _ongoing = false;
    // -------------------- Done --------------------

    // Extract hash string
    hasher.close();
    String hashString = hashOut.events.single.toString();

    _hashGen = hashString;
    compareHashes(widget.globKey_HashComparisonView.currentState!.get());
  }

  // ##################################################
  // @brief: Abort current hash generation
  // ##################################################
  void abortHashGeneration() {
    // Unset flag to mark abortion
    _ongoing = false;

    // Reset hash generation view
    setState(() {
      _hashGen = "<aborted>";
    });
  }

  // ##################################################
  // @brief: Getter: generated hash
  // @return: String
  // ##################################################
  String get HashGen {
    return _hashGen;
  }
}

// ##################################################
// # TEMPLATE
// # Hash comparison view
// # This widget can be inserted into file view to provide user input for hash comparison
// ##################################################
class T_HashComparisonView extends StatefulWidget {
  // Function call on changed
  final Function(String)? onChanged;

  // Constructor
  T_HashComparisonView({super.key, this.onChanged});

  // Hash comparison view key
  final globKey_HashCompView = GlobalKey<T_HashComparisonView_state>();

  @override
  State<StatefulWidget> createState() => T_HashComparisonView_state();
}

// ##################################################
// # STATE
// # Hash comparison view state
// ##################################################
class T_HashComparisonView_state extends State<T_HashComparisonView> {
  // state attributes
  String _hashComp = "";

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: Style_FileTree_ComparisonInput_Width_px,
        height: Style_FileTree_ComparisonInput_Height_px,
        child: TextField(
            style: Style_FileTree_ComparisonInput_Text,
            decoration: Style_FileTree_ComparisonInput_Decoration,
            controller: TextEditingController(text: _hashComp),
            onChanged: _onChange));
  }

  // ##################################################
  // @brief: Work on onChange
  // @param: value
  // ##################################################
  void _onChange(String value) {
    _hashComp = value;
    if (widget.onChanged != null) {
      widget.onChanged!(value);
    }
  }

  // ##################################################
  // @brief: Getter/Setter
  // @param: val
  // @return: String
  // ##################################################
  String get() {
    return _hashComp;
  }

  void set(String val) {
    setState(() {
      _hashComp = val;
    });
    _onChange(val);
  }
}
